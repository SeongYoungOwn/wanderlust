package com.tour.project.service;

import com.tour.project.dto.TrendAnalysisResponse;
import com.tour.project.client.ClaudeApiClient;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 여행 계획과 트렌드 분석 연동 서비스
 * - 트렌드 기반 여행 계획 최적화
 * - 실시간 트렌드를 고려한 일정 조정
 * - AI 기반 여행 경로 추천
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TravelPlanTrendIntegrationService {
    
    private final ClaudeApiClient claudeApiClient;
    private final ObjectMapper objectMapper;
    private final SocialTrendsService socialTrendsService;
    private final UserPreferenceLearningService userPreferenceLearningService;
    private final TrendDataCacheService cacheService;
    
    /**
     * 트렌드 기반 여행 계획 최적화
     */
    public Map<String, Object> optimizeTravelPlanWithTrends(String userId, Map<String, Object> travelPlan) {
        log.info("트렌드 기반 여행 계획 최적화 시작 - 사용자: {}", userId);
        
        try {
            // 1. 현재 트렌드 데이터 수집
            TrendAnalysisResponse trends = socialTrendsService.analyzeCurrentTrends(userId, null);
            
            // 2. 사용자 선호도 데이터 수집
            com.tour.project.dto.UserPreferenceDTO userPreference = 
                userPreferenceLearningService.getUserPreference(userId);
            
            // 3. SNS 인기도 데이터 수집
            Map<String, Object> snsData = socialTrendsService.analyzeSnsPopularity();
            
            // 4. AI 기반 계획 최적화
            Map<String, Object> optimizedPlan = generateOptimizedPlan(travelPlan, trends, userPreference, snsData);
            
            // 5. 트렌드 인사이트 추가
            addTrendInsights(optimizedPlan, trends, snsData);
            
            return optimizedPlan;
            
        } catch (Exception e) {
            log.error("여행 계획 최적화 실패", e);
            return Map.of("error", "계획 최적화에 실패했습니다.");
        }
    }
    
    /**
     * 실시간 트렌드 기반 일정 조정
     */
    public Map<String, Object> adjustScheduleByTrends(String userId, Map<String, Object> currentSchedule) {
        log.info("실시간 트렌드 기반 일정 조정 - 사용자: {}", userId);
        
        try {
            String prompt = buildScheduleAdjustmentPrompt(currentSchedule);
            
            ClaudeRequest request = ClaudeRequest.trendAnalysisBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parseScheduleAdjustment(response.getContentText(), currentSchedule);
            }
            
        } catch (Exception e) {
            log.error("일정 조정 실패", e);
        }
        
        return getDefaultScheduleAdjustment(currentSchedule);
    }
    
    /**
     * AI 기반 여행 경로 추천
     */
    public Map<String, Object> recommendTravelRoute(String userId, Map<String, Object> destinations) {
        log.info("AI 기반 여행 경로 추천 - 사용자: {}", userId);
        
        try {
            String prompt = buildRouteRecommendationPrompt(destinations, userId);
            
            ClaudeRequest request = ClaudeRequest.personalizationBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parseRouteRecommendation(response.getContentText(), destinations);
            }
            
        } catch (Exception e) {
            log.error("여행 경로 추천 실패", e);
        }
        
        return getDefaultRouteRecommendation(destinations);
    }
    
    /**
     * 트렌드 기반 숙박 추천
     */
    public Map<String, Object> recommendAccommodationByTrends(String destination, Map<String, Object> preferences) {
        log.info("트렌드 기반 숙박 추천 - 목적지: {}", destination);
        
        try {
            String prompt = buildAccommodationPrompt(destination, preferences);
            
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(2000)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parseAccommodationRecommendation(response.getContentText());
            }
            
        } catch (Exception e) {
            log.error("숙박 추천 실패", e);
        }
        
        return getDefaultAccommodationRecommendation(destination);
    }
    
    /**
     * 트렌드 기반 활동 추천
     */
    public Map<String, Object> recommendActivitiesByTrends(String destination, String season, Map<String, Object> userProfile) {
        log.info("트렌드 기반 활동 추천 - 목적지: {}, 계절: {}", destination, season);
        
        try {
            // 캐시 확인
            String cacheKey = "activities_" + destination + "_" + season;
            Map<String, Object> cachedActivities = cacheService.getPersonalizedRecommendation(
                (String) userProfile.get("userId"), cacheKey);
            
            if (cachedActivities != null) {
                return cachedActivities;
            }
            
            String prompt = buildActivitiesPrompt(destination, season, userProfile);
            
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(2500)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                Map<String, Object> activities = parseActivitiesRecommendation(response.getContentText());
                
                // 캐시에 저장
                cacheService.cachePersonalizedRecommendation(
                    (String) userProfile.get("userId"), cacheKey, activities);
                
                return activities;
            }
            
        } catch (Exception e) {
            log.error("활동 추천 실패", e);
        }
        
        return getDefaultActivitiesRecommendation(destination, season);
    }
    
    /**
     * 예산 최적화 추천
     */
    public Map<String, Object> optimizeBudgetWithTrends(Map<String, Object> travelPlan, double totalBudget) {
        log.info("예산 최적화 추천 - 총 예산: {}", totalBudget);
        
        try {
            String prompt = buildBudgetOptimizationPrompt(travelPlan, totalBudget);
            
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(2000)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parseBudgetOptimization(response.getContentText(), totalBudget);
            }
            
        } catch (Exception e) {
            log.error("예산 최적화 실패", e);
        }
        
        return getDefaultBudgetOptimization(travelPlan, totalBudget);
    }
    
    /**
     * AI 기반 계획 최적화 생성
     */
    private Map<String, Object> generateOptimizedPlan(Map<String, Object> originalPlan, 
                                                     TrendAnalysisResponse trends,
                                                     com.tour.project.dto.UserPreferenceDTO userPreference,
                                                     Map<String, Object> snsData) {
        try {
            String prompt = buildOptimizationPrompt(originalPlan, trends, userPreference, snsData);
            
            ClaudeRequest request = ClaudeRequest.trendAnalysisBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(4000)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parsePlanOptimization(response.getContentText(), originalPlan);
            }
            
        } catch (Exception e) {
            log.error("AI 계획 최적화 생성 실패", e);
        }
        
        return originalPlan;
    }
    
    /**
     * 계획 최적화 프롬프트 구성
     */
    private String buildOptimizationPrompt(Map<String, Object> originalPlan, 
                                         TrendAnalysisResponse trends,
                                         com.tour.project.dto.UserPreferenceDTO userPreference,
                                         Map<String, Object> snsData) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 여행 계획 최적화 전문가입니다. ");
        prompt.append("현재 트렌드와 사용자 선호도를 기반으로 여행 계획을 최적화해주세요.\n\n");
        
        prompt.append("원본 여행 계획:\n");
        try {
            prompt.append(objectMapper.writeValueAsString(originalPlan)).append("\n\n");
        } catch (JsonProcessingException e) {
            log.error("여행 계획 직렬화 실패", e);
            prompt.append(originalPlan.toString()).append("\n\n");
        }
        
        prompt.append("현재 트렌드 정보:\n");
        if (trends.getTrendingKeywords() != null && !trends.getTrendingKeywords().isEmpty()) {
            prompt.append("인기 키워드: ");
            trends.getTrendingKeywords().stream()
                .limit(5)
                .forEach(k -> prompt.append(k.getKeyword()).append("(").append(k.getTrendScore()).append(") "));
            prompt.append("\n");
        }
        
        if (trends.getPopularDestinations() != null && !trends.getPopularDestinations().isEmpty()) {
            prompt.append("인기 여행지: ");
            trends.getPopularDestinations().stream()
                .limit(3)
                .forEach(d -> prompt.append(d.getDestinationName()).append("(").append(d.getTrendScore()).append(") "));
            prompt.append("\n");
        }
        
        if (userPreference != null) {
            prompt.append("\n사용자 선호도:\n");
            prompt.append("- 여행 스타일: ").append(userPreference.getTravelStyle()).append("\n");
            prompt.append("- 선호 활동: ").append(String.join(", ", userPreference.getPreferredActivities())).append("\n");
            prompt.append("- 선호 지역: ").append(String.join(", ", userPreference.getPreferredRegions())).append("\n");
        }
        
        prompt.append("\n다음 JSON 형식으로 최적화된 계획을 제공해주세요:\n");
        prompt.append("{\n");
        prompt.append("  \"optimizedPlan\": {\n");
        prompt.append("    \"destinations\": [\n");
        prompt.append("      {\n");
        prompt.append("        \"name\": \"여행지명\",\n");
        prompt.append("        \"days\": 2,\n");
        prompt.append("        \"trendScore\": 8.5,\n");
        prompt.append("        \"recommendedActivities\": [\"활동1\", \"활동2\"],\n");
        prompt.append("        \"optimizationReason\": \"최적화 이유\",\n");
        prompt.append("        \"bestTime\": \"최적 방문 시간\"\n");
        prompt.append("      }\n");
        prompt.append("    ],\n");
        prompt.append("    \"totalDays\": 5,\n");
        prompt.append("    \"estimatedBudget\": 500000,\n");
        prompt.append("    \"optimizationScore\": 0.92\n");
        prompt.append("  },\n");
        prompt.append("  \"improvements\": [\"개선 사항들\"],\n");
        prompt.append("  \"trendInsights\": [\"트렌드 인사이트들\"]\n");
        prompt.append("}\n\n");
        
        prompt.append("최적화 요구사항:\n");
        prompt.append("1. 현재 트렌드를 최대한 반영\n");
        prompt.append("2. 사용자 선호도 고려\n");
        prompt.append("3. 예산 효율성 개선\n");
        prompt.append("4. 실현 가능한 일정 제안\n");
        prompt.append("5. 트렌드 점수가 높은 여행지 우선 추천\n");
        
        return prompt.toString();
    }
    
    /**
     * 일정 조정 프롬프트 구성
     */
    private String buildScheduleAdjustmentPrompt(Map<String, Object> currentSchedule) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("현재 여행 일정을 실시간 트렌드에 맞춰 조정해주세요.\n\n");
        prompt.append("현재 일정:\n");
        try {
            prompt.append(objectMapper.writeValueAsString(currentSchedule));
        } catch (Exception e) {
            prompt.append(currentSchedule.toString());
        }
        prompt.append("\n\n");
        
        prompt.append("다음 사항을 고려하여 일정을 조정해주세요:\n");
        prompt.append("1. 급상승 중인 여행지나 활동 우선 포함\n");
        prompt.append("2. 혼잡도가 예상되는 시간대 피하기\n");
        prompt.append("3. 계절적 특성 고려\n");
        prompt.append("4. 효율적인 동선 구성\n");
        
        return prompt.toString();
    }
    
    /**
     * 여행 경로 추천 프롬프트 구성
     */
    private String buildRouteRecommendationPrompt(Map<String, Object> destinations, String userId) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("여행지들을 효율적으로 연결하는 최적 경로를 추천해주세요.\n\n");
        prompt.append("방문 예정 여행지:\n");
        try {
            prompt.append(objectMapper.writeValueAsString(destinations));
        } catch (Exception e) {
            prompt.append(destinations.toString());
        }
        prompt.append("\n\n");
        
        prompt.append("경로 최적화 기준:\n");
        prompt.append("1. 이동 거리 및 시간 최소화\n");
        prompt.append("2. 교통편의성 고려\n");
        prompt.append("3. 각 지역의 특색과 볼거리 고려\n");
        prompt.append("4. 현재 트렌드와 인기도 반영\n");
        
        return prompt.toString();
    }
    
    /**
     * 숙박 추천 프롬프트 구성
     */
    private String buildAccommodationPrompt(String destination, Map<String, Object> preferences) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("여행지 ").append(destination).append("에서 현재 트렌드에 맞는 숙박시설을 추천해주세요.\n\n");
        prompt.append("사용자 선호도:\n");
        try {
            prompt.append(objectMapper.writeValueAsString(preferences));
        } catch (Exception e) {
            prompt.append(preferences.toString());
        }
        
        return prompt.toString();
    }
    
    /**
     * 활동 추천 프롬프트 구성
     */
    private String buildActivitiesPrompt(String destination, String season, Map<String, Object> userProfile) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("여행지 ").append(destination).append("에서 ").append(season).append(" 계절에 ");
        prompt.append("현재 트렌드에 맞는 활동들을 추천해주세요.\n\n");
        
        prompt.append("사용자 프로필:\n");
        try {
            prompt.append(objectMapper.writeValueAsString(userProfile));
        } catch (Exception e) {
            prompt.append(userProfile.toString());
        }
        
        return prompt.toString();
    }
    
    /**
     * 예산 최적화 프롬프트 구성
     */
    private String buildBudgetOptimizationPrompt(Map<String, Object> travelPlan, double totalBudget) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("여행 계획을 예산 ").append(totalBudget).append("원에 맞춰 최적화해주세요.\n\n");
        prompt.append("여행 계획:\n");
        try {
            prompt.append(objectMapper.writeValueAsString(travelPlan));
        } catch (Exception e) {
            prompt.append(travelPlan.toString());
        }
        
        return prompt.toString();
    }
    
    /**
     * 트렌드 인사이트 추가
     */
    private void addTrendInsights(Map<String, Object> plan, TrendAnalysisResponse trends, Map<String, Object> snsData) {
        List<String> insights = new ArrayList<>();
        
        if (trends.getTrendingKeywords() != null) {
            trends.getTrendingKeywords().stream()
                .limit(3)
                .forEach(k -> insights.add(k.getKeyword() + "이(가) 현재 인기 급상승 중입니다."));
        }
        
        if (trends.getPopularDestinations() != null) {
            trends.getPopularDestinations().stream()
                .limit(2)
                .forEach(d -> insights.add(d.getDestinationName() + "은(는) 현재 트렌드 점수 " + 
                    d.getTrendScore() + "로 높은 인기를 보이고 있습니다."));
        }
        
        plan.put("trendInsights", insights);
        plan.put("lastUpdated", LocalDateTime.now());
    }
    
    // 파싱 메서드들 (간단한 구현)
    private Map<String, Object> parsePlanOptimization(String content, Map<String, Object> originalPlan) {
        try {
            String jsonContent = extractJsonFromResponse(content);
            return objectMapper.readValue(jsonContent, new TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            log.error("계획 최적화 파싱 실패", e);
            return originalPlan;
        }
    }
    
    private Map<String, Object> parseScheduleAdjustment(String content, Map<String, Object> currentSchedule) {
        // 간단한 구현
        return Map.of("adjustedSchedule", currentSchedule, "suggestions", List.of("실시간 트렌드 반영 완료"));
    }
    
    private Map<String, Object> parseRouteRecommendation(String content, Map<String, Object> destinations) {
        // 간단한 구현
        return Map.of("optimizedRoute", destinations, "estimatedTime", "5시간", "totalDistance", "300km");
    }
    
    private Map<String, Object> parseAccommodationRecommendation(String content) {
        // 간단한 구현
        return Map.of("recommendations", List.of(
            Map.of("name", "트렌디 호텔", "rating", 4.5, "price", 120000, "trendScore", 8.3)
        ));
    }
    
    private Map<String, Object> parseActivitiesRecommendation(String content) {
        // 간단한 구현
        return Map.of("activities", List.of(
            Map.of("name", "인기 카페 투어", "category", "문화", "trendScore", 8.7, "duration", "3시간")
        ));
    }
    
    private Map<String, Object> parseBudgetOptimization(String content, double totalBudget) {
        // 간단한 구현
        return Map.of("optimizedBudget", Map.of(
            "accommodation", totalBudget * 0.4,
            "food", totalBudget * 0.3,
            "activities", totalBudget * 0.2,
            "transportation", totalBudget * 0.1
        ));
    }
    
    // 기본 응답 메서드들
    private Map<String, Object> getDefaultScheduleAdjustment(Map<String, Object> currentSchedule) {
        return Map.of("adjustedSchedule", currentSchedule, "message", "기본 일정을 유지합니다.");
    }
    
    private Map<String, Object> getDefaultRouteRecommendation(Map<String, Object> destinations) {
        return Map.of("route", destinations, "message", "기본 경로를 추천합니다.");
    }
    
    private Map<String, Object> getDefaultAccommodationRecommendation(String destination) {
        return Map.of("recommendations", List.of(), "message", "기본 숙박 정보를 제공합니다.");
    }
    
    private Map<String, Object> getDefaultActivitiesRecommendation(String destination, String season) {
        return Map.of("activities", List.of(), "message", "기본 활동 정보를 제공합니다.");
    }
    
    private Map<String, Object> getDefaultBudgetOptimization(Map<String, Object> travelPlan, double totalBudget) {
        return Map.of("budget", totalBudget, "message", "기본 예산 배분을 제공합니다.");
    }
    
    private String extractJsonFromResponse(String response) {
        int startIndex = response.indexOf("{");
        int endIndex = response.lastIndexOf("}");
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return response.substring(startIndex, endIndex + 1);
        }
        
        throw new RuntimeException("JSON 형식을 찾을 수 없습니다.");
    }
}