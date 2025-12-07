package com.tour.project.dto.trend;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 트렌드 분석 응답 DTO 모음
 */
public class TrendAnalysisResponseDTO {
    
    /**
     * 1단계: 급상승 여행지 응답
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class PopularDestinationsResponse {
        private boolean success;
        private String message;
        private List<PopularDestination> destinations;
        private LocalDateTime analysisTime;
        private String analysisStep;
    }
    
    /**
     * 2단계: MBTI 맞춤 추천 응답
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MBTIRecommendationResponse {
        private boolean success;
        private String message;
        private String mbtiType;
        private List<MBTIRecommendation> recommendations;
        private LocalDateTime analysisTime;
        private String analysisStep;
        private boolean mbtiTestRequired;
    }
    
    /**
     * 3단계: 지역별 인기도 응답
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RegionPopularityResponse {
        private boolean success;
        private String message;
        private List<RegionPopularity> regions;
        private LocalDateTime analysisTime;
        private String analysisStep;
    }
    
    /**
     * 4단계: 종합 분석 응답
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class ComprehensiveAnalysisResponse {
        private boolean success;
        private String message;
        private List<BestDestination> bestDestinations;
        private LocalDateTime analysisTime;
        private String analysisStep;
        private AnalysisSummary summary;
    }
    
    /**
     * 전체 분석 응답
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class FullAnalysisResponse {
        private boolean success;
        private String message;
        private PopularDestinationsResponse popularDestinations;
        private MBTIRecommendationResponse mbtiRecommendations;
        private RegionPopularityResponse regionPopularity;
        private ComprehensiveAnalysisResponse comprehensiveAnalysis;
        private LocalDateTime analysisTime;
    }
    
    /**
     * 급상승 여행지 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class PopularDestination {
        private String destinationName;      // 여행지명
        private int trendScore;             // 트렌드 점수 (1-100)
        private String popularityReason;    // 인기 이유
        private String category;            // 카테고리 (자연/도시/문화 등)
        private List<String> hashtags;      // 관련 해시태그
        private int rank;                   // 순위 (1-5)
        private String imageUrl;            // 이미지 URL
    }
    
    /**
     * MBTI 기반 추천 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MBTIRecommendation {
        private String destinationName;
        private String mbtiType;
        private String recommendationReason;
        private int matchingScore;          // MBTI 매칭 점수 (1-100)
        private List<String> attractions;   // 주요 매력 포인트
        private String personalityFit;      // 성향 적합성 설명
    }
    
    /**
     * 지역별 인기도 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RegionPopularity {
        private String regionName;          // 지역명
        private double latitude;            // 위도 (지도 표시용)
        private double longitude;           // 경도
        private int popularityScore;        // 인기도 점수 (1-100)
        private List<String> hotSpots;      // 핫스팟 목록
        private String trendDescription;    // 트렌드 설명
        private String markerColor;         // 지도 마커 색상
        private int mentionCount;           // SNS 언급 횟수
    }
    
    /**
     * 베스트 여행지 (종합 결과)
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class BestDestination {
        private String destinationName;
        private int rank;                   // 순위 (1-3)
        private int totalScore;             // 종합 점수
        private String selectionReason;     // 선정 이유
        private List<String> highlights;    // 주요 특징
        private String trendSource;         // 트렌드 출처 (SNS/뉴스/블로그)
        private RecommendationMetrics metrics;
    }
    
    /**
     * 추천 지표
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RecommendationMetrics {
        private int popularityScore;        // 인기도 점수
        private int mbtiCompatibility;      // MBTI 호환성
        private int regionTrendScore;       // 지역 트렌드 점수
        private int overallRating;          // 종합 평점
    }
    
    /**
     * 분석 요약 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class AnalysisSummary {
        private String analysisDate;        // 분석 날짜
        private int totalDestinations;      // 분석된 총 여행지 수
        private String topTrendSource;      // 주요 트렌드 소스
        private String seasonalTrend;       // 계절별 트렌드
        private List<String> emergingDestinations; // 신흥 여행지
    }
}