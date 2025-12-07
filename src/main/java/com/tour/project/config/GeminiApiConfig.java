package com.tour.project.config;

import com.tour.project.service.ApiKeyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.web.reactive.function.client.ClientRequest;
import org.springframework.web.reactive.function.client.ExchangeFilterFunction;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;
import reactor.core.publisher.Mono;

import java.net.URI;

/**
 * Gemini API 설정 클래스
 * - Gemini 2.0 Flash API 클라이언트 설정
 * - HTTP 클라이언트 빈 생성
 * - 동적 API 키 로딩 지원 (DB에서 실시간 조회)
 */
@Configuration
public class GeminiApiConfig {

    // Gemini API URL (gemini-2.0-flash 모델)
    private static final String GEMINI_API_BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

    @Value("${gemini.api.model:gemini-2.0-flash}")
    private String model;

    @Lazy
    @Autowired
    private ApiKeyService apiKeyService;

    /**
     * Gemini API용 WebClient 빈 생성
     * - 동적으로 API 키를 로딩하는 필터 적용
     */
    @Bean(name = "geminiWebClient")
    public WebClient geminiWebClient() {
        return WebClient.builder()
            .baseUrl(GEMINI_API_BASE_URL)
            .defaultHeader("Content-Type", "application/json")
            .filter(dynamicApiKeyFilter())
            .codecs(configurer -> configurer
                .defaultCodecs()
                .maxInMemorySize(16 * 1024 * 1024)) // 16MB
            .build();
    }

    /**
     * 동적 API 키 필터
     * - 매 요청 시 DB에서 최신 Gemini API 키 조회
     * - URL에 key 쿼리 파라미터로 추가
     */
    private ExchangeFilterFunction dynamicApiKeyFilter() {
        return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
            String apiKey = getGeminiApiKey();

            // URL에 API 키를 쿼리 파라미터로 추가
            URI originalUri = clientRequest.url();
            URI newUri = UriComponentsBuilder.fromUri(originalUri)
                .queryParam("key", apiKey)
                .build()
                .toUri();

            ClientRequest newRequest = ClientRequest.from(clientRequest)
                .url(newUri)
                .build();

            return Mono.just(newRequest);
        });
    }

    /**
     * Gemini API 키 조회 (ApiKeyService 사용)
     */
    public String getGeminiApiKey() {
        if (apiKeyService != null) {
            return apiKeyService.getGeminiApiKey();
        }
        return "";
    }

    /**
     * Gemini API 키 검증
     */
    public boolean isGeminiApiKeyValid() {
        String apiKey = getGeminiApiKey();
        return apiKey != null && !apiKey.trim().isEmpty() && apiKey.startsWith("AIza");
    }

    /**
     * Gemini API 키 설정 여부 확인
     */
    public boolean isGeminiApiKeyConfigured() {
        if (apiKeyService != null) {
            return apiKeyService.isGeminiApiKeyConfigured();
        }
        return false;
    }

    /**
     * Gemini API URL 반환
     */
    public String getGeminiApiUrl() {
        return GEMINI_API_BASE_URL;
    }

    /**
     * 마스킹된 Gemini API 키 반환
     */
    public String getGeminiApiKeyMasked() {
        if (apiKeyService != null) {
            return apiKeyService.getMaskedGeminiApiKey();
        }
        return "****";
    }

    /**
     * 사용 모델 반환
     */
    public String getModel() {
        return model;
    }
}
