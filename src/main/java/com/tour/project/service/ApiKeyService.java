package com.tour.project.service;

import com.tour.project.dao.SystemSettingDAO;
import com.tour.project.dto.SystemSettingDTO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.concurrent.atomic.AtomicReference;

/**
 * API 키 관리 서비스
 * - Claude API 키 암호화/복호화
 * - Gemini API 키 암호화/복호화
 * - DB에서 동적으로 API 키 로딩
 * - 캐싱으로 성능 최적화
 * - Primary Provider 설정 (Claude/Gemini)
 */
@Slf4j
@Service
public class ApiKeyService {

    private static final String CLAUDE_API_KEY = "CLAUDE_API_KEY";
    private static final String CLAUDE_API_URL = "CLAUDE_API_URL";
    private static final String DEFAULT_API_URL = "https://api.anthropic.com/v1/messages";

    // Gemini API 관련 상수
    private static final String GEMINI_API_KEY = "GEMINI_API_KEY";
    private static final String PRIMARY_AI_PROVIDER = "PRIMARY_AI_PROVIDER";
    public static final String PROVIDER_CLAUDE = "claude";
    public static final String PROVIDER_GEMINI = "gemini";

    // AES 암호화 키 (실제 운영에서는 환경변수로 관리)
    @Value("${api.encryption.key:WanderlustSecretKey2024!}")
    private String encryptionKey;

    // 기본 API 키 (application.properties에서)
    @Value("${claude.api.key:}")
    private String defaultApiKey;

    @Value("${gemini.api.key:}")
    private String defaultGeminiApiKey;

    @Autowired
    private SystemSettingDAO systemSettingDAO;

    // 캐시된 API 키 (성능 최적화)
    private final AtomicReference<String> cachedApiKey = new AtomicReference<>(null);
    private final AtomicReference<Long> cacheTimestamp = new AtomicReference<>(0L);
    private static final long CACHE_DURATION_MS = 60000; // 1분 캐시

    // Gemini API 키 캐시
    private final AtomicReference<String> cachedGeminiApiKey = new AtomicReference<>(null);
    private final AtomicReference<Long> geminiCacheTimestamp = new AtomicReference<>(0L);

    // Primary Provider 캐시
    private final AtomicReference<String> cachedPrimaryProvider = new AtomicReference<>(null);
    private final AtomicReference<Long> providerCacheTimestamp = new AtomicReference<>(0L);

    @PostConstruct
    public void init() {
        try {
            log.info("ApiKeyService 초기화 시작");
            // 초기 로딩 시 캐시 갱신 (실패해도 서비스는 시작)
            refreshCache();
            log.info("ApiKeyService 초기화 완료");
        } catch (Exception e) {
            log.warn("ApiKeyService 초기화 중 오류 발생 (서비스는 정상 시작): {}", e.getMessage());
        }
    }

    /**
     * Claude API 키 조회 (캐시 사용)
     * DB에 설정된 키가 있으면 사용, 없으면 properties 파일의 기본값 사용
     */
    public String getApiKey() {
        // 캐시 확인
        long now = System.currentTimeMillis();
        if (cachedApiKey.get() != null && (now - cacheTimestamp.get()) < CACHE_DURATION_MS) {
            return cachedApiKey.get();
        }

        // DB에서 조회
        String apiKey = getApiKeyFromDB();

        // DB에 키가 없거나 비활성화 상태면 기본값 사용
        if (apiKey == null || apiKey.isEmpty()) {
            apiKey = defaultApiKey;
        }

        // 캐시 업데이트
        cachedApiKey.set(apiKey);
        cacheTimestamp.set(now);

        return apiKey;
    }

    /**
     * DB에서 API 키 조회 (복호화)
     */
    private String getApiKeyFromDB() {
        try {
            SystemSettingDTO setting = systemSettingDAO.getSettingByKey(CLAUDE_API_KEY);

            if (setting == null || setting.getSettingValue() == null || !Boolean.TRUE.equals(setting.getIsActive())) {
                return null;
            }

            // 암호화된 경우 복호화
            if (Boolean.TRUE.equals(setting.getIsEncrypted())) {
                return decrypt(setting.getSettingValue());
            }

            return setting.getSettingValue();
        } catch (Exception e) {
            log.error("DB에서 API 키 조회 실패", e);
            return null;
        }
    }

    /**
     * API 키 저장 (암호화)
     */
    public boolean saveApiKey(String apiKey, String adminId) {
        try {
            // API 키 유효성 검증
            if (!isValidApiKeyFormat(apiKey)) {
                log.warn("잘못된 API 키 형식: {}", maskApiKey(apiKey));
                return false;
            }

            // 암호화
            String encryptedKey = encrypt(apiKey);

            // 설정 존재 여부 확인
            if (systemSettingDAO.existsByKey(CLAUDE_API_KEY)) {
                // 업데이트
                int result = systemSettingDAO.updateSettingValue(
                        CLAUDE_API_KEY, encryptedKey, true, adminId);

                if (result > 0) {
                    log.info("API 키 업데이트 성공 - 관리자: {}", adminId);
                    refreshCache();
                    return true;
                }
            } else {
                // 신규 삽입
                SystemSettingDTO newSetting = new SystemSettingDTO();
                newSetting.setSettingKey(CLAUDE_API_KEY);
                newSetting.setSettingValue(encryptedKey);
                newSetting.setSettingDescription("Claude AI API 키");
                newSetting.setIsEncrypted(true);
                newSetting.setIsActive(true);
                newSetting.setUpdatedBy(adminId);

                int result = systemSettingDAO.insertSetting(newSetting);

                if (result > 0) {
                    log.info("API 키 신규 저장 성공 - 관리자: {}", adminId);
                    refreshCache();
                    return true;
                }
            }

            return false;
        } catch (Exception e) {
            log.error("API 키 저장 실패", e);
            return false;
        }
    }

    /**
     * API 키 삭제 (비활성화)
     */
    public boolean deleteApiKey(String adminId) {
        try {
            int result = systemSettingDAO.deactivateSetting(CLAUDE_API_KEY, adminId);

            if (result > 0) {
                log.info("API 키 삭제 성공 - 관리자: {}", adminId);
                refreshCache();
                return true;
            }

            return false;
        } catch (Exception e) {
            log.error("API 키 삭제 실패", e);
            return false;
        }
    }

    /**
     * API 키 설정 여부 확인
     */
    public boolean isApiKeyConfigured() {
        String apiKey = getApiKey();
        return apiKey != null && !apiKey.isEmpty() && isValidApiKeyFormat(apiKey);
    }

    /**
     * API 키 활성화 상태 확인
     */
    public boolean isApiKeyActive() {
        try {
            Boolean isActive = systemSettingDAO.isSettingActive(CLAUDE_API_KEY);
            return Boolean.TRUE.equals(isActive);
        } catch (Exception e) {
            log.error("API 키 활성화 상태 확인 실패", e);
            return false;
        }
    }

    /**
     * 마스킹된 API 키 조회 (UI 표시용)
     */
    public String getMaskedApiKey() {
        String apiKey = getApiKey();
        return maskApiKey(apiKey);
    }

    /**
     * API 키 마스킹
     */
    public String maskApiKey(String apiKey) {
        if (apiKey == null || apiKey.length() < 15) {
            return "설정되지 않음";
        }
        return apiKey.substring(0, 12) + "****" + apiKey.substring(apiKey.length() - 4);
    }

    /**
     * API 키 형식 검증
     */
    public boolean isValidApiKeyFormat(String apiKey) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return false;
        }
        // Claude API 키는 보통 'sk-ant-api' 로 시작
        return apiKey.startsWith("sk-ant-api") || apiKey.startsWith("sk-");
    }

    /**
     * Claude API URL 조회
     */
    public String getApiUrl() {
        try {
            SystemSettingDTO setting = systemSettingDAO.getSettingByKey(CLAUDE_API_URL);
            if (setting != null && setting.getSettingValue() != null && Boolean.TRUE.equals(setting.getIsActive())) {
                return setting.getSettingValue();
            }
        } catch (Exception e) {
            log.error("API URL 조회 실패", e);
        }
        return DEFAULT_API_URL;
    }

    /**
     * API 키 테스트 (실제 API 호출)
     */
    public boolean testApiKey(String apiKey) {
        // 형식 검증만 수행 (실제 API 호출은 비용 발생)
        return isValidApiKeyFormat(apiKey);
    }

    /**
     * 캐시 강제 갱신
     */
    public void refreshCache() {
        cachedApiKey.set(null);
        cacheTimestamp.set(0L);
        log.debug("API 키 캐시 갱신됨");
    }

    /**
     * 설정 정보 조회 (마지막 수정 정보 포함)
     */
    public SystemSettingDTO getApiKeyInfo() {
        try {
            SystemSettingDTO setting = systemSettingDAO.getSettingByKey(CLAUDE_API_KEY);
            if (setting != null) {
                // 값은 마스킹 처리
                setting.setSettingValue(maskApiKey(getApiKey()));
            }
            return setting;
        } catch (Exception e) {
            log.error("API 키 정보 조회 실패", e);
            return null;
        }
    }

    // ==================== Gemini API 키 관리 ====================

    /**
     * Gemini API 키 조회 (캐시 사용)
     */
    public String getGeminiApiKey() {
        // 캐시 확인
        long now = System.currentTimeMillis();
        if (cachedGeminiApiKey.get() != null && (now - geminiCacheTimestamp.get()) < CACHE_DURATION_MS) {
            return cachedGeminiApiKey.get();
        }

        // DB에서 조회
        String apiKey = getGeminiApiKeyFromDB();

        // DB에 키가 없으면 기본값 사용
        if (apiKey == null || apiKey.isEmpty()) {
            apiKey = defaultGeminiApiKey;
        }

        // 캐시 업데이트
        cachedGeminiApiKey.set(apiKey);
        geminiCacheTimestamp.set(now);

        return apiKey;
    }

    /**
     * DB에서 Gemini API 키 조회 (복호화)
     */
    private String getGeminiApiKeyFromDB() {
        try {
            SystemSettingDTO setting = systemSettingDAO.getSettingByKey(GEMINI_API_KEY);

            if (setting == null || setting.getSettingValue() == null || !Boolean.TRUE.equals(setting.getIsActive())) {
                return null;
            }

            // 암호화된 경우 복호화
            if (Boolean.TRUE.equals(setting.getIsEncrypted())) {
                return decrypt(setting.getSettingValue());
            }

            return setting.getSettingValue();
        } catch (Exception e) {
            log.error("DB에서 Gemini API 키 조회 실패", e);
            return null;
        }
    }

    /**
     * Gemini API 키 저장 (암호화)
     */
    public boolean saveGeminiApiKey(String apiKey, String adminId) {
        try {
            // API 키 유효성 검증
            if (!isValidGeminiApiKeyFormat(apiKey)) {
                log.warn("잘못된 Gemini API 키 형식: {}", maskGeminiApiKey(apiKey));
                return false;
            }

            // 암호화
            String encryptedKey = encrypt(apiKey);

            // 설정 존재 여부 확인
            if (systemSettingDAO.existsByKey(GEMINI_API_KEY)) {
                // 업데이트
                int result = systemSettingDAO.updateSettingValue(
                        GEMINI_API_KEY, encryptedKey, true, adminId);

                if (result > 0) {
                    log.info("Gemini API 키 업데이트 성공 - 관리자: {}", adminId);
                    refreshGeminiCache();
                    return true;
                }
            } else {
                // 신규 삽입
                SystemSettingDTO newSetting = new SystemSettingDTO();
                newSetting.setSettingKey(GEMINI_API_KEY);
                newSetting.setSettingValue(encryptedKey);
                newSetting.setSettingDescription("Gemini AI API 키");
                newSetting.setIsEncrypted(true);
                newSetting.setIsActive(true);
                newSetting.setUpdatedBy(adminId);

                int result = systemSettingDAO.insertSetting(newSetting);

                if (result > 0) {
                    log.info("Gemini API 키 신규 저장 성공 - 관리자: {}", adminId);
                    refreshGeminiCache();
                    return true;
                }
            }

            return false;
        } catch (Exception e) {
            log.error("Gemini API 키 저장 실패", e);
            return false;
        }
    }

    /**
     * Gemini API 키 삭제 (비활성화)
     */
    public boolean deleteGeminiApiKey(String adminId) {
        try {
            int result = systemSettingDAO.deactivateSetting(GEMINI_API_KEY, adminId);

            if (result > 0) {
                log.info("Gemini API 키 삭제 성공 - 관리자: {}", adminId);
                refreshGeminiCache();
                return true;
            }

            return false;
        } catch (Exception e) {
            log.error("Gemini API 키 삭제 실패", e);
            return false;
        }
    }

    /**
     * Gemini API 키 설정 여부 확인
     */
    public boolean isGeminiApiKeyConfigured() {
        String apiKey = getGeminiApiKey();
        return apiKey != null && !apiKey.isEmpty() && isValidGeminiApiKeyFormat(apiKey);
    }

    /**
     * Gemini API 키 활성화 상태 확인
     */
    public boolean isGeminiApiKeyActive() {
        try {
            Boolean isActive = systemSettingDAO.isSettingActive(GEMINI_API_KEY);
            return Boolean.TRUE.equals(isActive);
        } catch (Exception e) {
            log.error("Gemini API 키 활성화 상태 확인 실패", e);
            return false;
        }
    }

    /**
     * Gemini API 키 형식 검증
     * Gemini API 키는 'AIza'로 시작
     */
    public boolean isValidGeminiApiKeyFormat(String apiKey) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return false;
        }
        return apiKey.startsWith("AIza");
    }

    /**
     * 마스킹된 Gemini API 키 조회 (UI 표시용)
     */
    public String getMaskedGeminiApiKey() {
        String apiKey = getGeminiApiKey();
        return maskGeminiApiKey(apiKey);
    }

    /**
     * Gemini API 키 마스킹
     */
    public String maskGeminiApiKey(String apiKey) {
        if (apiKey == null || apiKey.length() < 15) {
            return "설정되지 않음";
        }
        return apiKey.substring(0, 8) + "****" + apiKey.substring(apiKey.length() - 4);
    }

    /**
     * Gemini API 키 정보 조회
     */
    public SystemSettingDTO getGeminiApiKeyInfo() {
        try {
            SystemSettingDTO setting = systemSettingDAO.getSettingByKey(GEMINI_API_KEY);
            if (setting != null) {
                // 값은 마스킹 처리
                setting.setSettingValue(maskGeminiApiKey(getGeminiApiKey()));
            }
            return setting;
        } catch (Exception e) {
            log.error("Gemini API 키 정보 조회 실패", e);
            return null;
        }
    }

    /**
     * Gemini 캐시 갱신
     */
    public void refreshGeminiCache() {
        cachedGeminiApiKey.set(null);
        geminiCacheTimestamp.set(0L);
        log.debug("Gemini API 키 캐시 갱신됨");
    }

    // ==================== Primary Provider 관리 ====================

    /**
     * Primary AI Provider 조회
     * 기본값은 Claude
     */
    public String getPrimaryProvider() {
        // 캐시 확인
        long now = System.currentTimeMillis();
        if (cachedPrimaryProvider.get() != null && (now - providerCacheTimestamp.get()) < CACHE_DURATION_MS) {
            return cachedPrimaryProvider.get();
        }

        // DB에서 조회
        String provider = getPrimaryProviderFromDB();

        // DB에 설정이 없으면 기본값 (Claude)
        if (provider == null || provider.isEmpty()) {
            provider = PROVIDER_CLAUDE;
        }

        // 캐시 업데이트
        cachedPrimaryProvider.set(provider);
        providerCacheTimestamp.set(now);

        return provider;
    }

    /**
     * DB에서 Primary Provider 조회
     */
    private String getPrimaryProviderFromDB() {
        try {
            SystemSettingDTO setting = systemSettingDAO.getSettingByKey(PRIMARY_AI_PROVIDER);

            if (setting == null || setting.getSettingValue() == null || !Boolean.TRUE.equals(setting.getIsActive())) {
                return null;
            }

            return setting.getSettingValue();
        } catch (Exception e) {
            log.error("DB에서 Primary Provider 조회 실패", e);
            return null;
        }
    }

    /**
     * Primary AI Provider 설정
     */
    public boolean setPrimaryProvider(String provider, String adminId) {
        try {
            // 유효한 provider인지 확인
            if (!PROVIDER_CLAUDE.equals(provider) && !PROVIDER_GEMINI.equals(provider)) {
                log.warn("잘못된 Provider: {}", provider);
                return false;
            }

            // 설정 존재 여부 확인
            if (systemSettingDAO.existsByKey(PRIMARY_AI_PROVIDER)) {
                // 업데이트
                int result = systemSettingDAO.updateSettingValue(
                        PRIMARY_AI_PROVIDER, provider, false, adminId);

                if (result > 0) {
                    log.info("Primary Provider 변경 성공: {} - 관리자: {}", provider, adminId);
                    refreshProviderCache();
                    return true;
                }
            } else {
                // 신규 삽입
                SystemSettingDTO newSetting = new SystemSettingDTO();
                newSetting.setSettingKey(PRIMARY_AI_PROVIDER);
                newSetting.setSettingValue(provider);
                newSetting.setSettingDescription("Primary AI Provider (claude/gemini)");
                newSetting.setIsEncrypted(false);
                newSetting.setIsActive(true);
                newSetting.setUpdatedBy(adminId);

                int result = systemSettingDAO.insertSetting(newSetting);

                if (result > 0) {
                    log.info("Primary Provider 설정 성공: {} - 관리자: {}", provider, adminId);
                    refreshProviderCache();
                    return true;
                }
            }

            return false;
        } catch (Exception e) {
            log.error("Primary Provider 설정 실패", e);
            return false;
        }
    }

    /**
     * Provider 캐시 갱신
     */
    public void refreshProviderCache() {
        cachedPrimaryProvider.set(null);
        providerCacheTimestamp.set(0L);
        log.debug("Primary Provider 캐시 갱신됨");
    }

    /**
     * Claude가 Primary Provider인지 확인
     */
    public boolean isClaudePrimary() {
        return PROVIDER_CLAUDE.equals(getPrimaryProvider());
    }

    /**
     * Gemini가 Primary Provider인지 확인
     */
    public boolean isGeminiPrimary() {
        return PROVIDER_GEMINI.equals(getPrimaryProvider());
    }

    /**
     * Fallback 가능 여부 확인
     * Primary가 실패했을 때 Secondary로 전환 가능한지
     */
    public boolean isFallbackAvailable() {
        if (isClaudePrimary()) {
            return isGeminiApiKeyConfigured();
        } else {
            return isApiKeyConfigured();
        }
    }

    /**
     * 어떤 Provider든 사용 가능한지 확인
     */
    public boolean isAnyProviderAvailable() {
        return isApiKeyConfigured() || isGeminiApiKeyConfigured();
    }

    // ==================== 암호화/복호화 ====================

    /**
     * AES 암호화
     */
    private String encrypt(String value) throws Exception {
        SecretKeySpec secretKey = getSecretKey();
        Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
        byte[] encryptedBytes = cipher.doFinal(value.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(encryptedBytes);
    }

    /**
     * AES 복호화
     */
    private String decrypt(String encryptedValue) throws Exception {
        SecretKeySpec secretKey = getSecretKey();
        Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
        cipher.init(Cipher.DECRYPT_MODE, secretKey);
        byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedValue));
        return new String(decryptedBytes, StandardCharsets.UTF_8);
    }

    /**
     * AES 키 생성 (16바이트로 맞춤)
     */
    private SecretKeySpec getSecretKey() {
        byte[] keyBytes = new byte[16];
        byte[] originalKeyBytes = encryptionKey.getBytes(StandardCharsets.UTF_8);
        System.arraycopy(originalKeyBytes, 0, keyBytes, 0, Math.min(originalKeyBytes.length, 16));
        return new SecretKeySpec(keyBytes, "AES");
    }
}
