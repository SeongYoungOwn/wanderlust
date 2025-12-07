package com.tour.project.service;

import com.tour.project.client.ClaudeApiClient;
import com.tour.project.client.GeminiApiClient;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import com.tour.project.dto.gemini.GeminiRequest;
import com.tour.project.dto.gemini.GeminiResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * AI Provider 통합 서비스
 * - Claude와 Gemini API 통합 관리
 * - Primary Provider 우선 사용, 실패 시 Fallback
 * - 통합된 응답 형식 제공
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiProviderService {

    private final ClaudeApiClient claudeApiClient;
    private final GeminiApiClient geminiApiClient;
    private final ApiKeyService apiKeyService;

    /**
     * AI Provider 응답 결과
     */
    public static class AiResponse {
        private final String content;
        private final String provider;
        private final boolean success;
        private final String errorMessage;
        private final Integer inputTokens;
        private final Integer outputTokens;
        private final Integer totalTokens;

        private AiResponse(String content, String provider, boolean success, String errorMessage,
                          Integer inputTokens, Integer outputTokens, Integer totalTokens) {
            this.content = content;
            this.provider = provider;
            this.success = success;
            this.errorMessage = errorMessage;
            this.inputTokens = inputTokens;
            this.outputTokens = outputTokens;
            this.totalTokens = totalTokens;
        }

        public static AiResponse success(String content, String provider,
                                         Integer inputTokens, Integer outputTokens, Integer totalTokens) {
            return new AiResponse(content, provider, true, null, inputTokens, outputTokens, totalTokens);
        }

        public static AiResponse failure(String errorMessage, String provider) {
            return new AiResponse(null, provider, false, errorMessage, null, null, null);
        }

        public String getContent() { return content; }
        public String getProvider() { return provider; }
        public boolean isSuccess() { return success; }
        public String getErrorMessage() { return errorMessage; }
        public Integer getInputTokens() { return inputTokens; }
        public Integer getOutputTokens() { return outputTokens; }
        public Integer getTotalTokens() { return totalTokens; }
    }

    /**
     * 간단한 텍스트 질의 (Fallback 지원)
     * Primary Provider 실패 시 자동으로 Secondary Provider로 전환
     *
     * @param prompt 사용자 프롬프트
     * @return AI 응답
     */
    public AiResponse query(String prompt) {
        return queryWithSystem(null, prompt);
    }

    /**
     * 시스템 프롬프트와 함께 질의 (Fallback 지원)
     *
     * @param systemPrompt 시스템 프롬프트 (optional)
     * @param userPrompt 사용자 프롬프트
     * @return AI 응답
     */
    public AiResponse queryWithSystem(String systemPrompt, String userPrompt) {
        return queryWithSystemAndConfig(systemPrompt, userPrompt, 4000, 0.3);
    }

    /**
     * 설정과 함께 질의 (Fallback 지원)
     *
     * @param systemPrompt 시스템 프롬프트 (optional)
     * @param userPrompt 사용자 프롬프트
     * @param maxTokens 최대 출력 토큰
     * @param temperature 온도 설정
     * @return AI 응답
     */
    public AiResponse queryWithSystemAndConfig(String systemPrompt, String userPrompt,
                                               Integer maxTokens, Double temperature) {
        String primaryProvider = apiKeyService.getPrimaryProvider();

        log.info("AI 요청 시작 - Primary Provider: {}, Fallback 가능: {}",
                primaryProvider, apiKeyService.isFallbackAvailable());

        // Primary Provider로 시도
        AiResponse response = executeWithProvider(primaryProvider, systemPrompt, userPrompt, maxTokens, temperature);

        if (response.isSuccess()) {
            return response;
        }

        // Primary 실패 시 Fallback 시도
        if (apiKeyService.isFallbackAvailable()) {
            String fallbackProvider = ApiKeyService.PROVIDER_CLAUDE.equals(primaryProvider)
                    ? ApiKeyService.PROVIDER_GEMINI
                    : ApiKeyService.PROVIDER_CLAUDE;

            log.warn("Primary Provider({}) 실패, Fallback Provider({})로 전환 - 원인: {}",
                    primaryProvider, fallbackProvider, response.getErrorMessage());

            AiResponse fallbackResponse = executeWithProvider(fallbackProvider, systemPrompt, userPrompt, maxTokens, temperature);

            if (fallbackResponse.isSuccess()) {
                log.info("Fallback Provider({}) 성공", fallbackProvider);
                return fallbackResponse;
            }

            log.error("Fallback Provider({})도 실패 - 원인: {}", fallbackProvider, fallbackResponse.getErrorMessage());
        }

        return response;
    }

    /**
     * 특정 Provider로 요청 실행
     */
    private AiResponse executeWithProvider(String provider, String systemPrompt, String userPrompt,
                                           Integer maxTokens, Double temperature) {
        try {
            if (ApiKeyService.PROVIDER_CLAUDE.equals(provider)) {
                return executeWithClaude(systemPrompt, userPrompt, maxTokens, temperature);
            } else if (ApiKeyService.PROVIDER_GEMINI.equals(provider)) {
                return executeWithGemini(systemPrompt, userPrompt, maxTokens, temperature);
            } else {
                return AiResponse.failure("알 수 없는 Provider: " + provider, provider);
            }
        } catch (Exception e) {
            log.error("{} Provider 실행 중 예외 발생", provider, e);
            return AiResponse.failure(e.getMessage(), provider);
        }
    }

    /**
     * Claude로 요청 실행
     */
    private AiResponse executeWithClaude(String systemPrompt, String userPrompt,
                                         Integer maxTokens, Double temperature) {
        if (!apiKeyService.isApiKeyConfigured()) {
            return AiResponse.failure("Claude API 키가 설정되지 않음", ApiKeyService.PROVIDER_CLAUDE);
        }

        try {
            ClaudeRequest.ClaudeRequestBuilder builder = ClaudeRequest.defaultBuilder()
                    .messages(List.of(new ClaudeRequest.Message("user", userPrompt)))
                    .maxTokens(maxTokens != null ? maxTokens : 4000);

            if (systemPrompt != null && !systemPrompt.isEmpty()) {
                builder.system(systemPrompt);
            }

            if (temperature != null) {
                builder.temperature(temperature);
            }

            ClaudeRequest request = builder.build();
            ClaudeResponse response = claudeApiClient.sendRequest(request);

            if (response != null && response.isSuccess()) {
                return AiResponse.success(
                        response.getContentText(),
                        ApiKeyService.PROVIDER_CLAUDE,
                        response.getUsage() != null ? response.getUsage().getInputTokens() : null,
                        response.getUsage() != null ? response.getUsage().getOutputTokens() : null,
                        response.getTotalTokens()
                );
            } else {
                String errorMsg = response != null ? "응답 실패" : "응답 없음";
                return AiResponse.failure(errorMsg, ApiKeyService.PROVIDER_CLAUDE);
            }
        } catch (ClaudeApiClient.ClaudeApiException e) {
            return AiResponse.failure(e.getMessage(), ApiKeyService.PROVIDER_CLAUDE);
        }
    }

    /**
     * Gemini로 요청 실행
     */
    private AiResponse executeWithGemini(String systemPrompt, String userPrompt,
                                         Integer maxTokens, Double temperature) {
        if (!apiKeyService.isGeminiApiKeyConfigured()) {
            return AiResponse.failure("Gemini API 키가 설정되지 않음", ApiKeyService.PROVIDER_GEMINI);
        }

        try {
            GeminiRequest.GeminiRequestBuilder builder = GeminiRequest.builder()
                    .contents(List.of(GeminiRequest.Content.of("user", userPrompt)))
                    .generationConfig(GeminiRequest.GenerationConfig.builder()
                            .maxOutputTokens(maxTokens != null ? maxTokens : 4000)
                            .temperature(temperature != null ? temperature : 0.3)
                            .topP(0.9)
                            .topK(40)
                            .build());

            if (systemPrompt != null && !systemPrompt.isEmpty()) {
                builder.systemInstruction(GeminiRequest.SystemInstruction.of(systemPrompt));
            }

            GeminiRequest request = builder.build();
            GeminiResponse response = geminiApiClient.sendRequest(request);

            if (response != null && response.isSuccess()) {
                return AiResponse.success(
                        response.getContentText(),
                        ApiKeyService.PROVIDER_GEMINI,
                        response.getInputTokens(),
                        response.getOutputTokens(),
                        response.getTotalTokens()
                );
            } else {
                String errorMsg = response != null ? response.getErrorMessage() : "응답 없음";
                return AiResponse.failure(errorMsg, ApiKeyService.PROVIDER_GEMINI);
            }
        } catch (GeminiApiClient.GeminiApiException e) {
            return AiResponse.failure(e.getMessage(), ApiKeyService.PROVIDER_GEMINI);
        }
    }

    /**
     * Claude API로 직접 요청 (Fallback 없음)
     */
    public ClaudeResponse sendClaudeRequest(ClaudeRequest request) {
        if (!apiKeyService.isApiKeyConfigured()) {
            throw new IllegalStateException("Claude API 키가 설정되지 않았습니다.");
        }
        return claudeApiClient.sendRequest(request);
    }

    /**
     * Gemini API로 직접 요청 (Fallback 없음)
     */
    public GeminiResponse sendGeminiRequest(GeminiRequest request) {
        if (!apiKeyService.isGeminiApiKeyConfigured()) {
            throw new IllegalStateException("Gemini API 키가 설정되지 않았습니다.");
        }
        return geminiApiClient.sendRequest(request);
    }

    /**
     * Claude 요청을 Gemini로 변환하여 실행
     */
    public AiResponse executeClaudeRequestWithFallback(ClaudeRequest claudeRequest) {
        String primaryProvider = apiKeyService.getPrimaryProvider();

        // Claude Request에서 정보 추출
        String systemPrompt = claudeRequest.getSystem();
        String userPrompt = claudeRequest.getMessages().stream()
                .filter(m -> "user".equals(m.getRole()))
                .map(ClaudeRequest.Message::getContent)
                .collect(Collectors.joining("\n"));
        Integer maxTokens = claudeRequest.getMaxTokens();
        Double temperature = claudeRequest.getTemperature();

        return queryWithSystemAndConfig(systemPrompt, userPrompt, maxTokens, temperature);
    }

    /**
     * Primary Provider 상태 확인
     */
    public boolean isPrimaryProviderHealthy() {
        String provider = apiKeyService.getPrimaryProvider();

        if (ApiKeyService.PROVIDER_CLAUDE.equals(provider)) {
            return apiKeyService.isApiKeyConfigured() && claudeApiClient.isApiHealthy();
        } else {
            return apiKeyService.isGeminiApiKeyConfigured() && geminiApiClient.isApiHealthy();
        }
    }

    /**
     * 사용 가능한 Provider 존재 여부
     */
    public boolean isAnyProviderAvailable() {
        return apiKeyService.isAnyProviderAvailable();
    }

    /**
     * 현재 Primary Provider 반환
     */
    public String getPrimaryProvider() {
        return apiKeyService.getPrimaryProvider();
    }

    /**
     * Provider 상태 정보 조회
     */
    public ProviderStatus getProviderStatus() {
        return new ProviderStatus(
                apiKeyService.getPrimaryProvider(),
                apiKeyService.isApiKeyConfigured(),
                apiKeyService.isGeminiApiKeyConfigured(),
                apiKeyService.isFallbackAvailable()
        );
    }

    /**
     * Provider 상태 정보 클래스
     */
    public static class ProviderStatus {
        private final String primaryProvider;
        private final boolean claudeConfigured;
        private final boolean geminiConfigured;
        private final boolean fallbackAvailable;

        public ProviderStatus(String primaryProvider, boolean claudeConfigured,
                             boolean geminiConfigured, boolean fallbackAvailable) {
            this.primaryProvider = primaryProvider;
            this.claudeConfigured = claudeConfigured;
            this.geminiConfigured = geminiConfigured;
            this.fallbackAvailable = fallbackAvailable;
        }

        public String getPrimaryProvider() { return primaryProvider; }
        public boolean isClaudeConfigured() { return claudeConfigured; }
        public boolean isGeminiConfigured() { return geminiConfigured; }
        public boolean isFallbackAvailable() { return fallbackAvailable; }
    }
}
