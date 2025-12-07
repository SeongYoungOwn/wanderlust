package com.tour.project.dto.gemini;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.ArrayList;
import java.util.List;

/**
 * Gemini API 요청 DTO
 * - Gemini 2.0 Flash 모델 지원
 * - Claude와의 호환성을 위한 변환 메서드 포함
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GeminiRequest {

    /**
     * 대화 내용 배열
     */
    private List<Content> contents;

    /**
     * 생성 설정
     */
    @JsonProperty("generationConfig")
    private GenerationConfig generationConfig;

    /**
     * 시스템 프롬프트
     */
    @JsonProperty("systemInstruction")
    private SystemInstruction systemInstruction;

    /**
     * 안전 설정
     */
    @JsonProperty("safetySettings")
    private List<SafetySetting> safetySettings;

    /**
     * 대화 내용 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Content {
        /**
         * 역할 (user, model)
         */
        private String role;

        /**
         * 메시지 파트 배열
         */
        private List<Part> parts;

        /**
         * 간편 생성자 - 텍스트만 포함
         */
        public static Content of(String role, String text) {
            List<Part> parts = new ArrayList<>();
            parts.add(Part.of(text));
            return Content.builder()
                .role(role)
                .parts(parts)
                .build();
        }
    }

    /**
     * 메시지 파트 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Part {
        /**
         * 텍스트 내용
         */
        private String text;

        /**
         * 간편 생성자
         */
        public static Part of(String text) {
            return Part.builder().text(text).build();
        }
    }

    /**
     * 생성 설정 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GenerationConfig {
        /**
         * 최대 출력 토큰 수
         */
        @JsonProperty("maxOutputTokens")
        private Integer maxOutputTokens;

        /**
         * 온도 설정 (0.0 ~ 2.0)
         */
        private Double temperature;

        /**
         * Top-p 설정
         */
        @JsonProperty("topP")
        private Double topP;

        /**
         * Top-k 설정
         */
        @JsonProperty("topK")
        private Integer topK;

        /**
         * 정지 시퀀스
         */
        @JsonProperty("stopSequences")
        private List<String> stopSequences;
    }

    /**
     * 시스템 프롬프트 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SystemInstruction {
        /**
         * 파트 배열
         */
        private List<Part> parts;

        /**
         * 간편 생성자
         */
        public static SystemInstruction of(String text) {
            List<Part> parts = new ArrayList<>();
            parts.add(Part.of(text));
            return SystemInstruction.builder().parts(parts).build();
        }
    }

    /**
     * 안전 설정 클래스
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SafetySetting {
        /**
         * 카테고리 (HARM_CATEGORY_HARASSMENT, HARM_CATEGORY_HATE_SPEECH 등)
         */
        private String category;

        /**
         * 차단 임계값 (BLOCK_NONE, BLOCK_LOW_AND_ABOVE, BLOCK_MEDIUM_AND_ABOVE, BLOCK_HIGH_ONLY)
         */
        private String threshold;
    }

    /**
     * 기본 설정으로 빌더 생성
     */
    public static GeminiRequestBuilder defaultBuilder() {
        return GeminiRequest.builder()
            .generationConfig(GenerationConfig.builder()
                .maxOutputTokens(4000)
                .temperature(0.3)
                .topP(0.9)
                .topK(40)
                .build());
    }

    /**
     * 트렌드 분석용 설정
     */
    public static GeminiRequestBuilder trendAnalysisBuilder() {
        return GeminiRequest.builder()
            .generationConfig(GenerationConfig.builder()
                .maxOutputTokens(4000)
                .temperature(0.3)
                .topP(0.9)
                .topK(40)
                .build());
    }

    /**
     * 개인화 추천용 설정
     */
    public static GeminiRequestBuilder personalizationBuilder() {
        return GeminiRequest.builder()
            .generationConfig(GenerationConfig.builder()
                .maxOutputTokens(3000)
                .temperature(0.4)
                .topP(0.8)
                .topK(40)
                .build());
    }

    /**
     * Claude 요청 형식에서 Gemini 형식으로 변환
     */
    public static GeminiRequest fromClaudeFormat(String model, List<Message> messages,
            Integer maxTokens, Double temperature, String systemPrompt) {

        List<Content> contents = new ArrayList<>();
        for (Message msg : messages) {
            // Claude의 "assistant" 역할은 Gemini의 "model"로 변환
            String role = "assistant".equals(msg.getRole()) ? "model" : msg.getRole();
            contents.add(Content.of(role, msg.getContent()));
        }

        GeminiRequestBuilder builder = GeminiRequest.builder()
            .contents(contents)
            .generationConfig(GenerationConfig.builder()
                .maxOutputTokens(maxTokens != null ? maxTokens : 4000)
                .temperature(temperature != null ? temperature : 0.3)
                .topP(0.9)
                .topK(40)
                .build());

        if (systemPrompt != null && !systemPrompt.isEmpty()) {
            builder.systemInstruction(SystemInstruction.of(systemPrompt));
        }

        return builder.build();
    }

    /**
     * Claude 호환 메시지 클래스 (변환용)
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Message {
        private String role;
        private String content;
    }
}
