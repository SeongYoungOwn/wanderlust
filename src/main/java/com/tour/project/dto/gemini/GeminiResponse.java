package com.tour.project.dto.gemini;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

/**
 * Gemini API 응답 DTO
 * - Gemini 2.0 Flash 모델 응답 구조
 * - Claude 응답 형식과의 호환성 메서드 포함
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GeminiResponse {

    /**
     * 후보 응답 배열
     */
    private List<Candidate> candidates;

    /**
     * 사용량 메타데이터
     */
    @JsonProperty("usageMetadata")
    private UsageMetadata usageMetadata;

    /**
     * 에러 정보 (에러 발생 시)
     */
    private Error error;

    /**
     * 후보 응답 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Candidate {
        /**
         * 응답 내용
         */
        private Content content;

        /**
         * 완료 이유
         */
        @JsonProperty("finishReason")
        private String finishReason;

        /**
         * 안전성 평가
         */
        @JsonProperty("safetyRatings")
        private List<SafetyRating> safetyRatings;

        /**
         * 인용 메타데이터
         */
        @JsonProperty("citationMetadata")
        private CitationMetadata citationMetadata;

        /**
         * 응답 인덱스
         */
        private Integer index;
    }

    /**
     * 응답 내용 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Content {
        /**
         * 파트 배열
         */
        private List<Part> parts;

        /**
         * 역할 (model)
         */
        private String role;
    }

    /**
     * 메시지 파트 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Part {
        /**
         * 텍스트 내용
         */
        private String text;
    }

    /**
     * 사용량 메타데이터 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UsageMetadata {
        /**
         * 프롬프트 토큰 수
         */
        @JsonProperty("promptTokenCount")
        private Integer promptTokenCount;

        /**
         * 후보 응답 토큰 수
         */
        @JsonProperty("candidatesTokenCount")
        private Integer candidatesTokenCount;

        /**
         * 총 토큰 수
         */
        @JsonProperty("totalTokenCount")
        private Integer totalTokenCount;
    }

    /**
     * 안전성 평가 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SafetyRating {
        /**
         * 카테고리
         */
        private String category;

        /**
         * 확률
         */
        private String probability;
    }

    /**
     * 인용 메타데이터 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CitationMetadata {
        /**
         * 인용 소스 배열
         */
        @JsonProperty("citationSources")
        private List<CitationSource> citationSources;
    }

    /**
     * 인용 소스 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CitationSource {
        /**
         * 시작 인덱스
         */
        @JsonProperty("startIndex")
        private Integer startIndex;

        /**
         * 종료 인덱스
         */
        @JsonProperty("endIndex")
        private Integer endIndex;

        /**
         * URI
         */
        private String uri;

        /**
         * 라이선스
         */
        private String license;
    }

    /**
     * 에러 클래스
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Error {
        /**
         * 에러 코드
         */
        private Integer code;

        /**
         * 에러 메시지
         */
        private String message;

        /**
         * 에러 상태
         */
        private String status;
    }

    /**
     * 응답 텍스트 추출
     */
    public String getContentText() {
        if (candidates != null && !candidates.isEmpty()) {
            Candidate firstCandidate = candidates.get(0);
            if (firstCandidate.getContent() != null &&
                firstCandidate.getContent().getParts() != null &&
                !firstCandidate.getContent().getParts().isEmpty()) {

                StringBuilder text = new StringBuilder();
                for (Part part : firstCandidate.getContent().getParts()) {
                    if (part.getText() != null) {
                        text.append(part.getText());
                    }
                }
                return text.toString();
            }
        }
        return "";
    }

    /**
     * 전체 토큰 수 계산
     */
    public Integer getTotalTokens() {
        if (usageMetadata != null && usageMetadata.getTotalTokenCount() != null) {
            return usageMetadata.getTotalTokenCount();
        }
        return 0;
    }

    /**
     * 입력 토큰 수
     */
    public Integer getInputTokens() {
        if (usageMetadata != null && usageMetadata.getPromptTokenCount() != null) {
            return usageMetadata.getPromptTokenCount();
        }
        return 0;
    }

    /**
     * 출력 토큰 수
     */
    public Integer getOutputTokens() {
        if (usageMetadata != null && usageMetadata.getCandidatesTokenCount() != null) {
            return usageMetadata.getCandidatesTokenCount();
        }
        return 0;
    }

    /**
     * 성공 여부 확인
     */
    public boolean isSuccess() {
        if (error != null) {
            return false;
        }
        return candidates != null && !candidates.isEmpty() &&
               candidates.get(0).getContent() != null &&
               candidates.get(0).getContent().getParts() != null &&
               !candidates.get(0).getContent().getParts().isEmpty();
    }

    /**
     * 응답이 완료되었는지 확인
     */
    public boolean isComplete() {
        if (candidates != null && !candidates.isEmpty()) {
            String finishReason = candidates.get(0).getFinishReason();
            return "STOP".equals(finishReason) || "MAX_TOKENS".equals(finishReason);
        }
        return false;
    }

    /**
     * 에러 메시지 반환
     */
    public String getErrorMessage() {
        if (error != null) {
            return error.getMessage();
        }
        return null;
    }

    /**
     * 완료 이유 반환
     */
    public String getStopReason() {
        if (candidates != null && !candidates.isEmpty()) {
            return candidates.get(0).getFinishReason();
        }
        return null;
    }
}
