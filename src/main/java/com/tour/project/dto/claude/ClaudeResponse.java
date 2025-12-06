package com.tour.project.dto.claude;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

/**
 * Claude API 응답 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ClaudeResponse {
    
    /**
     * 응답 ID
     */
    private String id;
    
    /**
     * 응답 타입
     */
    private String type;
    
    /**
     * 역할 (항상 "assistant")
     */
    private String role;
    
    /**
     * 콘텐츠 배열
     */
    private List<Content> content;
    
    /**
     * 사용한 모델
     */
    private String model;
    
    /**
     * 정지 이유
     */
    @JsonProperty("stop_reason")
    private String stopReason;
    
    /**
     * 정지 시퀀스
     */
    @JsonProperty("stop_sequence")
    private String stopSequence;
    
    /**
     * 사용량 정보
     */
    private Usage usage;
    
    /**
     * 콘텐츠 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Content {
        /**
         * 콘텐츠 타입 (text)
         */
        private String type;
        
        /**
         * 텍스트 내용
         */
        private String text;
    }
    
    /**
     * 사용량 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Usage {
        /**
         * 입력 토큰 수
         */
        @JsonProperty("input_tokens")
        private Integer inputTokens;
        
        /**
         * 출력 토큰 수
         */
        @JsonProperty("output_tokens")
        private Integer outputTokens;
    }
    
    /**
     * 응답 텍스트 추출
     */
    public String getContentText() {
        if (content != null && !content.isEmpty()) {
            Content firstContent = content.get(0);
            if (firstContent != null && "text".equals(firstContent.getType())) {
                return firstContent.getText();
            }
        }
        return "";
    }
    
    /**
     * 전체 토큰 수 계산
     */
    public Integer getTotalTokens() {
        if (usage != null) {
            int input = usage.getInputTokens() != null ? usage.getInputTokens() : 0;
            int output = usage.getOutputTokens() != null ? usage.getOutputTokens() : 0;
            return input + output;
        }
        return 0;
    }
    
    /**
     * 성공 여부 확인
     */
    public boolean isSuccess() {
        return "message".equals(type) && content != null && !content.isEmpty();
    }
    
    /**
     * 응답이 완료되었는지 확인
     */
    public boolean isComplete() {
        return "end_turn".equals(stopReason) || "max_tokens".equals(stopReason);
    }
}