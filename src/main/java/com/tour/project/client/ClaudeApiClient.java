package com.tour.project.client;

import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import reactor.core.publisher.Mono;
import reactor.util.retry.Retry;

import java.time.Duration;

/**
 * Claude API 클라이언트
 * - Claude API 호출 담당
 * - 에러 처리 및 재시도 로직 포함
 * - 토큰 사용량 모니터링
 */
@Slf4j
@Component
public class ClaudeApiClient {

    private final WebClient webClient;

    public ClaudeApiClient(@Qualifier("claudeWebClient") WebClient webClient) {
        this.webClient = webClient;
    }
    
    /**
     * Claude API에 요청 전송
     * 
     * @param request Claude 요청 객체
     * @return Claude 응답 객체
     */
    public ClaudeResponse sendRequest(ClaudeRequest request) {
        log.debug("Claude API 요청 시작 - 모델: {}, 최대토큰: {}", 
                 request.getModel(), request.getMaxTokens());
        
        try {
            ClaudeResponse response = webClient
                .post()
                .uri("")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(ClaudeResponse.class)
                .retryWhen(Retry.backoff(3, Duration.ofSeconds(2))
                    .filter(throwable -> {
                        boolean shouldRetry = isRetryableException(throwable);
                        if (shouldRetry) {
                            if (throwable instanceof WebClientResponseException) {
                                WebClientResponseException ex = (WebClientResponseException) throwable;
                                int rawStatusCode = ex.getRawStatusCode();
                                log.warn("API overloaded ({}). Retrying in {}ms... (Attempt {}/3)", 
                                        rawStatusCode, 2000, getCurrentRetryAttempt());
                            } else {
                                log.warn("재시도 가능한 오류 발생: {}", throwable.getMessage());
                            }
                        }
                        return shouldRetry;
                    })
                    .doAfterRetry(retrySignal -> {
                        log.info("Max retries exceeded for {} error", 
                                getStatusCodeFromThrowable(retrySignal.failure()));
                    }))
                .timeout(Duration.ofSeconds(60))
                .block();
            
            if (response != null) {
                log.info("Claude API 응답 성공 - 토큰 사용량: {} (입력: {}, 출력: {})",
                        response.getTotalTokens(),
                        response.getUsage() != null ? response.getUsage().getInputTokens() : 0,
                        response.getUsage() != null ? response.getUsage().getOutputTokens() : 0);
                
                // 응답 검증
                if (!response.isSuccess()) {
                    log.warn("Claude API 응답이 성공적이지 않음: {}", response);
                }
            }
            
            return response;
            
        } catch (WebClientResponseException e) {
            log.error("Claude API 요청 실패 - 상태코드: {}, 응답: {}", 
                     e.getStatusCode(), e.getResponseBodyAsString());
            throw new ClaudeApiException("Claude API 요청 실패: " + e.getMessage(), e);
            
        } catch (Exception e) {
            log.error("Claude API 호출 중 예외 발생", e);
            throw new ClaudeApiException("Claude API 호출 실패: " + e.getMessage(), e);
        }
    }
    
    /**
     * 비동기 요청 전송
     * 
     * @param request Claude 요청 객체
     * @return Claude 응답 Mono
     */
    public Mono<ClaudeResponse> sendRequestAsync(ClaudeRequest request) {
        log.debug("Claude API 비동기 요청 시작 - 모델: {}", request.getModel());
        
        return webClient
            .post()
            .uri("")
            .bodyValue(request)
            .retrieve()
            .bodyToMono(ClaudeResponse.class)
            .retryWhen(Retry.backoff(3, Duration.ofSeconds(1))
                .filter(this::isRetryableException))
            .timeout(Duration.ofSeconds(30))
            .doOnSuccess(response -> {
                if (response != null) {
                    log.info("Claude API 비동기 응답 성공 - 토큰 사용량: {}", 
                            response.getTotalTokens());
                }
            })
            .doOnError(error -> {
                log.error("Claude API 비동기 요청 실패", error);
            });
    }
    
    /**
     * 간단한 텍스트 질의
     * 
     * @param prompt 질의 텍스트
     * @return 응답 텍스트
     */
    public String simpleQuery(String prompt) {
        ClaudeRequest request = ClaudeRequest.defaultBuilder()
            .messages(java.util.List.of(
                new ClaudeRequest.Message("user", prompt)
            ))
            .build();
        
        ClaudeResponse response = sendRequest(request);
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
                // 5xx 서버 오류와 429 (Rate Limit)는 재시도
                return statusCode >= 500 || statusCode == 429;
            } catch (IllegalArgumentException e) {
                // HttpStatus enum에 정의되지 않은 상태 코드 (예: 529) 처리
                int rawStatusCode = ex.getRawStatusCode();
                log.warn("알 수 없는 HTTP 상태 코드: {}, 재시도 진행", rawStatusCode);
                
                // 5xx 범위의 상태 코드는 재시도
                return rawStatusCode >= 500;
            }
        }
        
        // IllegalArgumentException 자체는 재시도하지 않음 (잘못된 요청)
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
            ClaudeRequest testRequest = ClaudeRequest.defaultBuilder()
                .messages(java.util.List.of(
                    new ClaudeRequest.Message("user", "Hello")
                ))
                .maxTokens(10)
                .build();
            
            ClaudeResponse response = sendRequest(testRequest);
            return response != null && response.isSuccess();
            
        } catch (Exception e) {
            log.warn("Claude API 상태 확인 실패", e);
            return false;
        }
    }
    
    /**
     * 현재 재시도 횟수 반환 (단순화된 버전)
     */
    private int getCurrentRetryAttempt() {
        // 실제 재시도 횟수는 Reactor의 RetrySignal에서 가져와야 하지만,
        // 여기서는 단순화하여 고정값 반환
        return 1;
    }
    
    /**
     * 예외에서 상태 코드 추출
     */
    private String getStatusCodeFromThrowable(Throwable throwable) {
        if (throwable instanceof WebClientResponseException) {
            WebClientResponseException ex = (WebClientResponseException) throwable;
            return String.valueOf(ex.getRawStatusCode());
        }
        return "unknown";
    }
    
    /**
     * Claude API 예외 클래스
     */
    public static class ClaudeApiException extends RuntimeException {
        public ClaudeApiException(String message) {
            super(message);
        }
        
        public ClaudeApiException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}