package com.tour.project.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 트렌드 분석 응답 DTO
 * - Claude API 기반 실시간 트렌드 분석 결과
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TrendAnalysisResponse {
    
    private LocalDateTime analysisTime;
    private String analysisSource;
    private boolean isRealTimeData;
    private String userMbti;
    
    // 급상승 키워드
    private List<TrendingKeyword> trendingKeywords;
    
    // 인기 여행지
    private List<PopularDestination> popularDestinations;
    
    // MBTI 기반 맞춤 추천
    private List<MbtiRecommendation> mbtiRecommendations;
    
    // SNS 인기도 분석
    private SnsPopularityData snsPopularity;
    
    // 트렌드 예측
    private TrendPrediction trendPrediction;
    
    // 개인화 추천
    private List<PersonalizedRecommendation> personalizedRecommendations;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TrendingKeyword {
        private String keyword;
        private String category; // destination, activity, food, accommodation
        private Double trendScore; // 0-10
        private Integer mentionCount;
        private String trendDirection; // up, down, stable
        private Double changeRate; // 증감률
        private String description;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PopularDestination {
        private String destinationName;
        private String region;
        private String country;
        private Double trendScore;
        private Integer mentionCount;
        private Double sentimentScore; // 0-1
        private String season; // spring, summer, fall, winter
        private List<String> popularActivities;
        private String description;
        private String imageUrl;
        private Map<String, Object> priceRange;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class MbtiRecommendation {
        private String mbtiType;
        private String destinationName;
        private String recommendationReason;
        private Double matchScore; // 0-1
        private List<String> suitableActivities;
        private String travelStyle;
        private String description;
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SnsPopularityData {
        private List<SnsDestination> topDestinations;
        private Map<String, Integer> platformMentions; // instagram, tiktok, youtube, etc.
        private List<InfluencerRecommendation> influencerPicks;
        
        @Data
        @Builder
        @NoArgsConstructor
        @AllArgsConstructor
        public static class SnsDestination {
            private String destinationName;
            private Integer totalMentions;
            private Map<String, Integer> platformBreakdown;
            private List<String> popularHashtags;
            private Double viralScore;
        }
        
        @Data
        @Builder
        @NoArgsConstructor
        @AllArgsConstructor
        public static class InfluencerRecommendation {
            private String influencerName;
            private String platform;
            private String destinationName;
            private Integer followerCount;
            private String postUrl;
            private String recommendation;
        }
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TrendPrediction {
        private List<FutureTrend> upcomingTrends;
        private List<String> seasonalPredictions;
        private Map<String, Double> regionGrowthRates;
        
        @Data
        @Builder
        @NoArgsConstructor
        @AllArgsConstructor
        public static class FutureTrend {
            private String destinationName;
            private String timeframe; // next_week, next_month, next_season
            private Double predictedGrowth;
            private String predictionReason;
            private Double confidence; // 0-1
        }
    }
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PersonalizedRecommendation {
        private String destinationName;
        private String recommendationType; // trending, mbti_match, seasonal, budget_friendly
        private Double personalizedScore;
        private String reason;
        private List<String> whyRecommended;
        private Map<String, Object> additionalInfo;
    }
}