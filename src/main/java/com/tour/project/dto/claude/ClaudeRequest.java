package com.tour.project.dto.claude;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

/**
 * Claude API 요청 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ClaudeRequest {
    
    /**
     * 사용할 Claude 모델
     */
    private String model;
    
    /**
     * 메시지 배열
     */
    private List<Message> messages;
    
    /**
     * 최대 토큰 수
     */
    @JsonProperty("max_tokens")
    private Integer maxTokens;
    
    /**
     * 온도 설정 (0.0 ~ 1.0)
     */
    private Double temperature;
    
    /**
     * Top-p 설정
     */
    @JsonProperty("top_p")
    private Double topP;
    
    /**
     * Top-k 설정
     */
    @JsonProperty("top_k")
    private Integer topK;
    
    /**
     * 스트림 응답 여부
     */
    private Boolean stream;
    
    /**
     * 정지 시퀀스
     */
    @JsonProperty("stop_sequences")
    private List<String> stopSequences;
    
    /**
     * 메시지 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Message {
        /**
         * 역할 (user, assistant)
         */
        private String role;
        
        /**
         * 메시지 내용
         */
        private String content;
    }
    
    /**
     * 기본 설정으로 빌더 생성
     */
    public static ClaudeRequestBuilder defaultBuilder() {
        return ClaudeRequest.builder()
            .model("claude-sonnet-4-20250514")
            .maxTokens(4000)
            .temperature(0.3)
            .stream(false);
    }
    
    /**
     * 트렌드 분석용 설정
     */
    public static ClaudeRequestBuilder trendAnalysisBuilder() {
        return ClaudeRequest.builder()
            .model("claude-sonnet-4-20250514")
            .maxTokens(4000)
            .temperature(0.3)
            .topP(0.9)
            .stream(false);
    }
    
    /**
     * 개인화 추천용 설정
     */
    public static ClaudeRequestBuilder personalizationBuilder() {
        return ClaudeRequest.builder()
            .model("claude-sonnet-4-20250514")
            .maxTokens(3000)
            .temperature(0.4)
            .topP(0.8)
            .stream(false);
    }
    
    /**
     * 감정 분석용 설정
     */
    public static ClaudeRequestBuilder sentimentAnalysisBuilder() {
        return ClaudeRequest.builder()
            .model("claude-sonnet-4-20250514")
            .maxTokens(2000)
            .temperature(0.2)
            .topP(0.7)
            .stream(false);
    }
    
    /**
     * 예측 분석용 설정
     */
    public static ClaudeRequestBuilder predictionBuilder() {
        return ClaudeRequest.builder()
            .model("claude-sonnet-4-20250514")
            .maxTokens(2500)
            .temperature(0.3)
            .topP(0.8)
            .stream(false);
    }
}