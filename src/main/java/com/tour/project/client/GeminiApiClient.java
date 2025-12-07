package com.tour.project.client;

import com.tour.project.dto.gemini.GeminiRequest;
import com.tour.project.dto.gemini.GeminiResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.List;

/**
 * Gemini API 클라이언트
 * - Gemini 2.0 Flash API 호출 담당
 * - 에러 처리 및 재시도 로직 포함
 * - 동기/비동기 요청 지원
 */
@Slf4j
@Component
public class GeminiApiClient {

    private final WebClient webClient;

    public GeminiApiClient(@Qualifier("geminiWebClient") WebClient webClient) {
        this.webClient = webClient;
    }

    /**
     * Gemini API에 요청 전송
     *
     * @param request Gemini 요청 객체
     * @return Gemini 응답 객체
     */
    public GeminiResponse sendRequest(GeminiRequest request) {
        log.debug("Gemini API 요청 시작 - 최대토큰: {}",
                request.getGenerationConfig() != null ?
                    request.getGenerationConfig().getMaxOutputTokens() : "default");

        try {
            GeminiResponse response = webClient
                .post()
                .uri("")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(GeminiResponse.class)
                .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                    .filter(throwable -> {
                        boolean shouldRetry = isRetryableException(throwable);
                        if (shouldRetry) {
                            if (throwable instanceof WebClientResponseException) {
                                WebClientResponseException ex = (WebClientResponseException) throwable;
                                int rawStatusCode = ex.getRawStatusCode();
                                log.warn("Gemini API overloaded ({}). Retrying...", rawStatusCode);
                            } else {
                                log.warn("재시도 가능한 오류 발생: {}", throwable.getMessage());
                            }
                        }
                        return shouldRetry;
                    })
                    .doAfterRetry(retrySignal -> {
                        log.info("Gemini API 재시도 완료 - 시도: {}",
                                retrySignal.totalRetries() + 1);
                    }))
                .timeout(Duration.ofSeconds(60))
                .block();

            if (response != null) {
                if (response.isSuccess()) {
                    log.info("Gemini API 응답 성공 - 토큰 사용량: {} (입력: {}, 출력: {})",
                            response.getTotalTokens(),
                            response.getInputTokens(),
                            response.getOutputTokens());
                } else {
                    log.warn("Gemini API 응답 실패: {}", response.getErrorMessage());
                }
            }

            return response;

        } catch (WebClientResponseException e) {
            log.error("Gemini API 요청 실패 - 상태코드: {}, 응답: {}",
                    e.getStatusCode(), e.getResponseBodyAsString());
            throw new GeminiApiException("Gemini API 요청 실패: " + e.getMessage(), e);

        } catch (Exception e) {
            log.error("Gemini API 호출 중 예외 발생", e);
            throw new GeminiApiException("Gemini API 호출 실패: " + e.getMessage(), e);
        }
    }

    /**
     * 비동기 요청 전송
     *
     * @param request Gemini 요청 객체
     * @return Gemini 응답 Mono
     */
    public Mono<GeminiResponse> sendRequestAsync(GeminiRequest request) {
        log.debug("Gemini API 비동기 요청 시작");

        return webClient
            .post()
            .uri("")
            .bodyValue(request)
            .retrieve()
            .bodyToMono(GeminiResponse.class)
            .retryWhen(Retry.backoff(3, Duration.ofSeconds(1))
                .filter(this::isRetryableException))
            .timeout(Duration.ofSeconds(30))
            .doOnSuccess(response -> {
                if (response != null) {
                    log.info("Gemini API 비동기 응답 성공 - 토큰 사용량: {}",
                            response.getTotalTokens());
                }
            })
            .doOnError(error -> {
                log.error("Gemini API 비동기 요청 실패", error);
            });
    }

    /**
     * 간단한 텍스트 질의
     *
     * @param prompt 질의 텍스트
     * @return 응답 텍스트
     */
    public String simpleQuery(String prompt) {
        GeminiRequest request = GeminiRequest.defaultBuilder()
            .contents(List.of(
                GeminiRequest.Content.of("user", prompt)
            ))
            .build();

        GeminiResponse response = sendRequest(request);
        return response != null ? response.getContentText() : "";
    }

    /**
     * 시스템 프롬프트와 함께 질의
     *
     * @param systemPrompt 시스템 프롬프트
     * @param userPrompt 사용자 프롬프트
     * @return 응답 텍스트
     */
    public String queryWithSystem(String systemPrompt, String userPrompt) {
        GeminiRequest request = GeminiRequest.defaultBuilder()
            .systemInstruction(GeminiRequest.SystemInstruction.of(systemPrompt))
            .contents(List.of(
                GeminiRequest.Content.of("user", userPrompt)
            ))
            .build();

        GeminiResponse response = sendRequest(request);
        return response != null ? response.getContentText() : "";
    }

    /**
     * 재시도 가능한 예외인지 확인
     */
    private boolean isRetryableException(Throwable throwable) {
        if (throwable instanceof WebClientResponseException) {
            WebClientResponseException ex = (WebClientResponseException) throwable;
            try {
                int statusCode = ex.getStatusCode().value();

                // 4xx 클라이언트 오류는 재시도하지 않음 (401, 403, 404 등)
                // 단, 429 (Rate Limit)는 재시도
                // 5xx 서버 오류는 재시도
                return statusCode >= 500 || statusCode == 429 || statusCode == 503;
            } catch (IllegalArgumentException e) {
                int rawStatusCode = ex.getRawStatusCode();
                log.warn("알 수 없는 HTTP 상태 코드: {}, 재시도 진행", rawStatusCode);
                return rawStatusCode >= 500;
            }
        }

        if (throwable instanceof IllegalArgumentException) {
            return false;
        }

        // 네트워크 오류 등은 재시도
        return true;
    }

    /**
     * API 상태 확인
     */
    public boolean isApiHealthy() {
        try {
            GeminiRequest testRequest = GeminiRequest.defaultBuilder()
                .contents(List.of(
                    GeminiRequest.Content.of("user", "Hello")
                ))
                .generationConfig(GeminiRequest.GenerationConfig.builder()
                    .maxOutputTokens(10)
                    .temperature(0.1)
                    .build())
                .build();

            GeminiResponse response = sendRequest(testRequest);
            return response != null && response.isSuccess();

        } catch (Exception e) {
            log.warn("Gemini API 상태 확인 실패", e);
            return false;
        }
    }

    /**
     * Gemini API 예외 클래스
     */
    public static class GeminiApiException extends RuntimeException {
        public GeminiApiException(String message) {
            super(message);
        }

        public GeminiApiException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
