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
import reactor.core.publisher.Mono;

/**
 * Claude API 설정 클래스
 * - Claude API 클라이언트 설정
 * - HTTP 클라이언트 빈 생성
 * - 동적 API 키 로딩 지원 (DB에서 실시간 조회)
 */
@Configuration
public class ClaudeApiConfig {

    @Value("${claude.api.url:https://api.anthropic.com/v1/messages}")
    private String apiUrl;

    @Lazy
    @Autowired
    private ApiKeyService apiKeyService;

    /**
     * Claude API용 WebClient 빈 생성
     * - 동적으로 API 키를 로딩하는 필터 적용
     */
    @Bean(name = "claudeWebClient")
    public WebClient claudeWebClient() {
        return WebClient.builder()
            .baseUrl(apiUrl)
            .defaultHeader("Content-Type", "application/json")
            .defaultHeader("anthropic-version", "2023-06-01")
            .filter(dynamicApiKeyFilter())
            .codecs(configurer -> configurer
                .defaultCodecs()
                .maxInMemorySize(16 * 1024 * 1024)) // 16MB
            .build();
    }

    /**
     * 동적 API 키 필터
     * - 매 요청 시 DB에서 최신 API 키 조회
     */
    private ExchangeFilterFunction dynamicApiKeyFilter() {
        return ExchangeFilterFunction.ofRequestProcessor(clientRequest -> {
            String apiKey = getApiKey();

            ClientRequest newRequest = ClientRequest.from(clientRequest)
                .header("x-api-key", apiKey)
                .header("Authorization", "Bearer " + apiKey)
                .build();

            return Mono.just(newRequest);
        });
    }

    /**
     * API 키 조회 (ApiKeyService 사용)
     */
    public String getApiKey() {
        if (apiKeyService != null) {
            return apiKeyService.getApiKey();
        }
        return "";
    }

    /**
     * API 키 검증
     */
    public boolean isApiKeyValid() {
        String apiKey = getApiKey();
        return apiKey != null && !apiKey.trim().isEmpty() &&
               (apiKey.startsWith("sk-ant-api") || apiKey.startsWith("sk-"));
    }

    /**
     * API 키 설정 여부 확인
     */
    public boolean isApiKeyConfigured() {
        if (apiKeyService != null) {
            return apiKeyService.isApiKeyConfigured();
        }
        return false;
    }

    /**
     * API 설정 정보 반환
     */
    public String getApiUrl() {
        if (apiKeyService != null) {
            return apiKeyService.getApiUrl();
        }
        return apiUrl;
    }

    /**
     * 마스킹된 API 키 반환
     */
    public String getApiKeyMasked() {
        if (apiKeyService != null) {
            return apiKeyService.getMaskedApiKey();
        }
        return "****";
    }
}