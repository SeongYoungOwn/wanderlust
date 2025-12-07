package com.tour.project.controller;

import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.SystemSettingDTO;
import com.tour.project.service.ApiKeyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * 관리자 API 설정 컨트롤러
 * - Claude API 키 관리
 * - Gemini API 키 관리
 * - Primary Provider 설정
 * - API 키 저장/삭제/테스트
 */
@Slf4j
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminApiSettingsController {

    private final ApiKeyService apiKeyService;

    /**
     * API 설정 페이지
     */
    @GetMapping("/api-settings")
    public String apiSettingsPage(Model model, HttpSession session) {
        // 관리자 확인
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
            return "redirect:/member/login";
        }

        // Claude API 키 정보 조회
        SystemSettingDTO claudeApiKeyInfo = apiKeyService.getApiKeyInfo();
        boolean isClaudeConfigured = apiKeyService.isApiKeyConfigured();
        boolean isClaudeActive = apiKeyService.isApiKeyActive();
        String claudeMaskedKey = apiKeyService.getMaskedApiKey();
        String apiUrl = apiKeyService.getApiUrl();

        // Gemini API 키 정보 조회
        SystemSettingDTO geminiApiKeyInfo = apiKeyService.getGeminiApiKeyInfo();
        boolean isGeminiConfigured = apiKeyService.isGeminiApiKeyConfigured();
        boolean isGeminiActive = apiKeyService.isGeminiApiKeyActive();
        String geminiMaskedKey = apiKeyService.getMaskedGeminiApiKey();

        // Primary Provider 정보
        String primaryProvider = apiKeyService.getPrimaryProvider();
        boolean isFallbackAvailable = apiKeyService.isFallbackAvailable();

        // Claude 정보 (기존 호환성)
        model.addAttribute("apiKeyInfo", claudeApiKeyInfo);
        model.addAttribute("isConfigured", isClaudeConfigured);
        model.addAttribute("isActive", isClaudeActive);
        model.addAttribute("maskedKey", claudeMaskedKey);
        model.addAttribute("apiUrl", apiUrl);

        // Gemini 정보
        model.addAttribute("geminiApiKeyInfo", geminiApiKeyInfo);
        model.addAttribute("isGeminiConfigured", isGeminiConfigured);
        model.addAttribute("isGeminiActive", isGeminiActive);
        model.addAttribute("geminiMaskedKey", geminiMaskedKey);

        // Provider 정보
        model.addAttribute("primaryProvider", primaryProvider);
        model.addAttribute("isFallbackAvailable", isFallbackAvailable);
        model.addAttribute("isAnyProviderAvailable", apiKeyService.isAnyProviderAvailable());

        return "admin/api-settings";
    }

    /**
     * API 키 저장
     */
    @PostMapping("/api-settings/save")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveApiKey(
            @RequestParam("apiKey") String apiKey,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // API 키 형식 검증
            if (!apiKeyService.isValidApiKeyFormat(apiKey)) {
                response.put("success", false);
                response.put("message", "올바른 Claude API 키 형식이 아닙니다. (sk-ant-api... 형식)");
                return ResponseEntity.badRequest().body(response);
            }

            // 저장
            boolean result = apiKeyService.saveApiKey(apiKey, loginUser.getUserId());

            if (result) {
                log.info("API 키 저장 성공 - 관리자: {}", loginUser.getUserId());
                response.put("success", true);
                response.put("message", "API 키가 성공적으로 저장되었습니다.");
                response.put("maskedKey", apiKeyService.getMaskedApiKey());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "API 키 저장에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }

        } catch (Exception e) {
            log.error("API 키 저장 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * API 키 삭제
     */
    @PostMapping("/api-settings/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteApiKey(HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 삭제
            boolean result = apiKeyService.deleteApiKey(loginUser.getUserId());

            if (result) {
                log.info("API 키 삭제 성공 - 관리자: {}", loginUser.getUserId());
                response.put("success", true);
                response.put("message", "API 키가 삭제되었습니다. AI 기능이 비활성화됩니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "API 키 삭제에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }

        } catch (Exception e) {
            log.error("API 키 삭제 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * API 키 테스트 (형식 검증)
     */
    @PostMapping("/api-settings/test")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> testApiKey(
            @RequestParam("apiKey") String apiKey,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 형식 검증
            boolean isValid = apiKeyService.isValidApiKeyFormat(apiKey);

            if (isValid) {
                response.put("success", true);
                response.put("message", "API 키 형식이 올바릅니다.");
                response.put("maskedKey", apiKeyService.maskApiKey(apiKey));
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "올바른 Claude API 키 형식이 아닙니다.");
                return ResponseEntity.badRequest().body(response);
            }

        } catch (Exception e) {
            log.error("API 키 테스트 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * API 상태 조회 (AJAX용)
     */
    @GetMapping("/api-settings/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getApiStatus(HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            response.put("success", true);
            response.put("isConfigured", apiKeyService.isApiKeyConfigured());
            response.put("isActive", apiKeyService.isApiKeyActive());
            response.put("maskedKey", apiKeyService.getMaskedApiKey());
            response.put("apiUrl", apiKeyService.getApiUrl());

            SystemSettingDTO info = apiKeyService.getApiKeyInfo();
            if (info != null) {
                response.put("updatedAt", info.getUpdatedAt());
                response.put("updatedBy", info.getUpdatedBy());
            }

            // Gemini 정보 추가
            response.put("isGeminiConfigured", apiKeyService.isGeminiApiKeyConfigured());
            response.put("isGeminiActive", apiKeyService.isGeminiApiKeyActive());
            response.put("geminiMaskedKey", apiKeyService.getMaskedGeminiApiKey());

            // Provider 정보 추가
            response.put("primaryProvider", apiKeyService.getPrimaryProvider());
            response.put("isFallbackAvailable", apiKeyService.isFallbackAvailable());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("API 상태 조회 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    // ==================== Gemini API 관리 ====================

    /**
     * Gemini API 키 저장
     */
    @PostMapping("/api-settings/gemini/save")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveGeminiApiKey(
            @RequestParam("apiKey") String apiKey,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // API 키 형식 검증
            if (!apiKeyService.isValidGeminiApiKeyFormat(apiKey)) {
                response.put("success", false);
                response.put("message", "올바른 Gemini API 키 형식이 아닙니다. (AIza... 형식)");
                return ResponseEntity.badRequest().body(response);
            }

            // 저장
            boolean result = apiKeyService.saveGeminiApiKey(apiKey, loginUser.getUserId());

            if (result) {
                log.info("Gemini API 키 저장 성공 - 관리자: {}", loginUser.getUserId());
                response.put("success", true);
                response.put("message", "Gemini API 키가 성공적으로 저장되었습니다.");
                response.put("maskedKey", apiKeyService.getMaskedGeminiApiKey());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Gemini API 키 저장에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }

        } catch (Exception e) {
            log.error("Gemini API 키 저장 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * Gemini API 키 삭제
     */
    @PostMapping("/api-settings/gemini/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteGeminiApiKey(HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 삭제
            boolean result = apiKeyService.deleteGeminiApiKey(loginUser.getUserId());

            if (result) {
                log.info("Gemini API 키 삭제 성공 - 관리자: {}", loginUser.getUserId());
                response.put("success", true);
                response.put("message", "Gemini API 키가 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Gemini API 키 삭제에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }

        } catch (Exception e) {
            log.error("Gemini API 키 삭제 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * Gemini API 키 테스트 (형식 검증)
     */
    @PostMapping("/api-settings/gemini/test")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> testGeminiApiKey(
            @RequestParam("apiKey") String apiKey,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 형식 검증
            boolean isValid = apiKeyService.isValidGeminiApiKeyFormat(apiKey);

            if (isValid) {
                response.put("success", true);
                response.put("message", "Gemini API 키 형식이 올바릅니다.");
                response.put("maskedKey", apiKeyService.maskGeminiApiKey(apiKey));
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "올바른 Gemini API 키 형식이 아닙니다. (AIza... 형식)");
                return ResponseEntity.badRequest().body(response);
            }

        } catch (Exception e) {
            log.error("Gemini API 키 테스트 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    // ==================== Primary Provider 관리 ====================

    /**
     * Primary Provider 변경
     */
    @PostMapping("/api-settings/provider")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> setPrimaryProvider(
            @RequestParam("provider") String provider,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // Provider 유효성 검증
            if (!ApiKeyService.PROVIDER_CLAUDE.equals(provider) &&
                !ApiKeyService.PROVIDER_GEMINI.equals(provider)) {
                response.put("success", false);
                response.put("message", "올바른 Provider가 아닙니다. (claude 또는 gemini)");
                return ResponseEntity.badRequest().body(response);
            }

            // 해당 Provider의 API 키가 설정되어 있는지 확인
            if (ApiKeyService.PROVIDER_CLAUDE.equals(provider) && !apiKeyService.isApiKeyConfigured()) {
                response.put("success", false);
                response.put("message", "Claude API 키가 설정되어 있지 않습니다. 먼저 API 키를 설정해주세요.");
                return ResponseEntity.badRequest().body(response);
            }
            if (ApiKeyService.PROVIDER_GEMINI.equals(provider) && !apiKeyService.isGeminiApiKeyConfigured()) {
                response.put("success", false);
                response.put("message", "Gemini API 키가 설정되어 있지 않습니다. 먼저 API 키를 설정해주세요.");
                return ResponseEntity.badRequest().body(response);
            }

            // Primary Provider 변경
            boolean result = apiKeyService.setPrimaryProvider(provider, loginUser.getUserId());

            if (result) {
                log.info("Primary Provider 변경 성공: {} - 관리자: {}", provider, loginUser.getUserId());
                response.put("success", true);
                response.put("message", "Primary Provider가 " + provider.toUpperCase() + "(으)로 변경되었습니다.");
                response.put("primaryProvider", provider);
                response.put("isFallbackAvailable", apiKeyService.isFallbackAvailable());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Primary Provider 변경에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }

        } catch (Exception e) {
            log.error("Primary Provider 변경 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * Provider 상태 조회 (상세)
     */
    @GetMapping("/api-settings/provider/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getProviderStatus(HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            response.put("success", true);

            // Claude 상태
            response.put("claude", Map.of(
                    "configured", apiKeyService.isApiKeyConfigured(),
                    "active", apiKeyService.isApiKeyActive(),
                    "maskedKey", apiKeyService.getMaskedApiKey()
            ));

            // Gemini 상태
            response.put("gemini", Map.of(
                    "configured", apiKeyService.isGeminiApiKeyConfigured(),
                    "active", apiKeyService.isGeminiApiKeyActive(),
                    "maskedKey", apiKeyService.getMaskedGeminiApiKey()
            ));

            // Provider 상태
            response.put("primaryProvider", apiKeyService.getPrimaryProvider());
            response.put("isFallbackAvailable", apiKeyService.isFallbackAvailable());
            response.put("isAnyProviderAvailable", apiKeyService.isAnyProviderAvailable());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("Provider 상태 조회 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
}
