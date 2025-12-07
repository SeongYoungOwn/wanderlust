package com.tour.project.service;

import com.tour.project.dto.UserPreferenceDTO;
import com.tour.project.client.ClaudeApiClient;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 사용자 선호도 학습 서비스
 * - 사용자 행동 패턴 분석
 * - 개인화 추천 정확도 향상
 * - 실시간 선호도 업데이트
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserPreferenceLearningService {
    
    private final ClaudeApiClient claudeApiClient;
    private final ObjectMapper objectMapper;
    
    // 메모리 기반 사용자 선호도 저장소 (실제 환경에서는 DB 사용)
    private final Map<String, UserPreferenceDTO> userPreferences = new ConcurrentHashMap<>();
    
    /**
     * 사용자 상호작용 기록 및 선호도 업데이트
     */
    public void recordUserInteraction(String userId, String interactionType, Map<String, Object> data) {
        log.info("사용자({}) 상호작용 기록: {}", userId, interactionType);
        
        UserPreferenceDTO preference = userPreferences.getOrDefault(userId, createDefaultPreference(userId));
        
        // 상호작용 횟수 증가
        preference.setTotalInteractions(preference.getTotalInteractions() + 1);
        
        // 상호작용 유형별 처리
        switch (interactionType) {
            case "destination_click":
                updateDestinationPreference(preference, data);
                break;
            case "search":
                updateSearchPreference(preference, data);
                break;
            case "favorite":
                updateFavoritePreference(preference, data);
                break;
            case "travel_plan_create":
                updateTravelPlanPreference(preference, data);
                break;
            case "recommendation_feedback":
                updateRecommendationFeedback(preference, data);
                break;
        }
        
        // 선호도 정확도 재계산
        updateAccuracyScore(preference);
        
        preference.setLastUpdated(LocalDateTime.now());
        userPreferences.put(userId, preference);
        
        log.info("사용자({}) 선호도 업데이트 완료 - 정확도: {}%", 
                userId, String.format("%.1f", preference.getAccuracyScore() * 100));
    }
    
    /**
     * AI 기반 개인화 추천 생성
     */
    public Map<String, Object> generatePersonalizedRecommendations(String userId, String context) {
        log.info("사용자({}) 개인화 추천 생성 시작", userId);
        
        UserPreferenceDTO preference = userPreferences.get(userId);
        if (preference == null) {
            log.warn("사용자({}) 선호도 데이터 없음 - 기본 추천 반환", userId);
            return getDefaultRecommendations();
        }
        
        try {
            String prompt = buildPersonalizedPrompt(preference, context);
            
            ClaudeRequest request = ClaudeRequest.personalizationBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parsePersonalizedRecommendations(response.getContentText(), preference);
            }
            
        } catch (Exception e) {
            log.error("개인화 추천 생성 실패", e);
        }
        
        return getDefaultRecommendations();
    }
    
    /**
     * 사용자 선호도 분석 리포트 생성
     */
    public Map<String, Object> generatePreferenceAnalysis(String userId) {
        UserPreferenceDTO preference = userPreferences.get(userId);
        if (preference == null) {
            return Map.of("error", "사용자 데이터가 없습니다.");
        }
        
        Map<String, Object> analysis = new HashMap<>();
        analysis.put("userId", userId);
        analysis.put("accuracyScore", preference.getAccuracyScore());
        analysis.put("totalInteractions", preference.getTotalInteractions());
        analysis.put("learningDays", calculateLearningDays(preference));
        analysis.put("topCategories", getTopCategories(preference));
        analysis.put("travelStyle", preference.getTravelStyle());
        analysis.put("budgetRange", preference.getBudgetRange());
        analysis.put("preferredActivities", preference.getPreferredActivities());
        analysis.put("preferredRegions", preference.getPreferredRegions());
        analysis.put("lastUpdated", preference.getLastUpdated());
        
        return analysis;
    }
    
    /**
     * 기본 사용자 선호도 생성
     */
    private UserPreferenceDTO createDefaultPreference(String userId) {
        return UserPreferenceDTO.builder()
            .userId(userId)
            .travelStyle("자유여행")
            .budgetRange("medium")
            .groupSize("small_group")
            .preferredActivities(new ArrayList<>())
            .preferredRegions(new ArrayList<>())
            .preferredSeasons(new ArrayList<>())
            .categoryScores(new HashMap<>())
            .recentSearches(new ArrayList<>())
            .favoriteDestinations(new ArrayList<>())
            .accuracyScore(0.5)
            .totalInteractions(0)
            .learningStartTime(LocalDateTime.now())
            .lastUpdated(LocalDateTime.now())
            .build();
    }
    
    /**
     * 여행지 클릭 선호도 업데이트
     */
    private void updateDestinationPreference(UserPreferenceDTO preference, Map<String, Object> data) {
        String destinationName = (String) data.get("destinationName");
        String region = (String) data.get("region");
        String category = (String) data.get("category");
        
        // 지역 선호도 업데이트
        if (region != null) {
            List<String> regions = preference.getPreferredRegions();
            if (!regions.contains(region)) {
                regions.add(region);
                if (regions.size() > 10) regions.remove(0); // 최대 10개 유지
            }
        }
        
        // 카테고리 점수 업데이트
        if (category != null) {
            Map<String, Double> scores = preference.getCategoryScores();
            scores.put(category, scores.getOrDefault(category, 0.0) + 0.1);
        }
        
        // 즐겨찾기 목록 업데이트
        if (destinationName != null) {
            List<String> favorites = preference.getFavoriteDestinations();
            if (!favorites.contains(destinationName)) {
                favorites.add(destinationName);
                if (favorites.size() > 20) favorites.remove(0); // 최대 20개 유지
            }
        }
    }
    
    /**
     * 검색 선호도 업데이트
     */
    private void updateSearchPreference(UserPreferenceDTO preference, Map<String, Object> data) {
        String searchTerm = (String) data.get("searchTerm");
        if (searchTerm != null) {
            List<String> searches = preference.getRecentSearches();
            searches.add(searchTerm);
            if (searches.size() > 50) searches.remove(0); // 최대 50개 유지
        }
    }
    
    /**
     * 즐겨찾기 선호도 업데이트
     */
    private void updateFavoritePreference(UserPreferenceDTO preference, Map<String, Object> data) {
        String destinationName = (String) data.get("destinationName");
        Boolean isAdded = (Boolean) data.get("isAdded");
        
        List<String> favorites = preference.getFavoriteDestinations();
        if (Boolean.TRUE.equals(isAdded)) {
            if (!favorites.contains(destinationName)) {
                favorites.add(destinationName);
            }
        } else {
            favorites.remove(destinationName);
        }
    }
    
    /**
     * 여행 계획 생성 선호도 업데이트
     */
    private void updateTravelPlanPreference(UserPreferenceDTO preference, Map<String, Object> data) {
        String travelStyle = (String) data.get("travelStyle");
        String budgetRange = (String) data.get("budgetRange");
        String groupSize = (String) data.get("groupSize");
        
        if (travelStyle != null) preference.setTravelStyle(travelStyle);
        if (budgetRange != null) preference.setBudgetRange(budgetRange);
        if (groupSize != null) preference.setGroupSize(groupSize);
        
        @SuppressWarnings("unchecked")
        List<String> activities = (List<String>) data.get("activities");
        if (activities != null) {
            preference.getPreferredActivities().addAll(activities);
            // 중복 제거 및 크기 제한
            preference.setPreferredActivities(
                preference.getPreferredActivities().stream()
                    .distinct()
                    .limit(15)
                    .toList()
            );
        }
    }
    
    /**
     * 추천 피드백 처리
     */
    private void updateRecommendationFeedback(UserPreferenceDTO preference, Map<String, Object> data) {
        String feedback = (String) data.get("feedback"); // "like", "dislike", "interested"
        String destinationName = (String) data.get("destinationName");
        String category = (String) data.get("category");
        
        Map<String, Double> scores = preference.getCategoryScores();
        double adjustment = "like".equals(feedback) ? 0.2 : 
                          "interested".equals(feedback) ? 0.1 : -0.1;
        
        if (category != null) {
            scores.put(category, Math.max(0.0, scores.getOrDefault(category, 0.0) + adjustment));
        }
    }
    
    /**
     * 정확도 점수 업데이트
     */
    private void updateAccuracyScore(UserPreferenceDTO preference) {
        int interactions = preference.getTotalInteractions();
        
        // 상호작용 횟수에 따른 기본 정확도
        double baseAccuracy = Math.min(0.9, 0.5 + (interactions * 0.01));
        
        // 데이터 다양성 점수
        double diversityScore = calculateDiversityScore(preference);
        
        // 최종 정확도 계산
        preference.setAccuracyScore(Math.min(0.95, baseAccuracy * diversityScore));
    }
    
    /**
     * 데이터 다양성 점수 계산
     */
    private double calculateDiversityScore(UserPreferenceDTO preference) {
        int regionCount = preference.getPreferredRegions().size();
        int activityCount = preference.getPreferredActivities().size();
        int categoryCount = preference.getCategoryScores().size();
        int searchCount = preference.getRecentSearches().size();
        
        // 각 영역별 점수 (0.0 ~ 1.0)
        double regionScore = Math.min(1.0, regionCount / 5.0);
        double activityScore = Math.min(1.0, activityCount / 8.0);
        double categoryScore = Math.min(1.0, categoryCount / 6.0);
        double searchScore = Math.min(1.0, searchCount / 20.0);
        
        return (regionScore + activityScore + categoryScore + searchScore) / 4.0;
    }
    
    /**
     * 개인화 프롬프트 구성
     */
    private String buildPersonalizedPrompt(UserPreferenceDTO preference, String context) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 개인화 여행 추천 전문가입니다. ");
        prompt.append("사용자의 과거 선호도 데이터를 기반으로 맞춤형 추천을 제공해주세요.\n\n");
        
        prompt.append("사용자 프로필:\n");
        prompt.append("- 여행 스타일: ").append(preference.getTravelStyle()).append("\n");
        prompt.append("- 예산 범위: ").append(preference.getBudgetRange()).append("\n");
        prompt.append("- 그룹 크기: ").append(preference.getGroupSize()).append("\n");
        prompt.append("- 총 상호작용: ").append(preference.getTotalInteractions()).append("회\n");
        prompt.append("- 학습 정확도: ").append(String.format("%.1f", preference.getAccuracyScore() * 100)).append("%\n\n");
        
        if (!preference.getPreferredActivities().isEmpty()) {
            prompt.append("선호 활동: ").append(String.join(", ", preference.getPreferredActivities())).append("\n");
        }
        
        if (!preference.getPreferredRegions().isEmpty()) {
            prompt.append("선호 지역: ").append(String.join(", ", preference.getPreferredRegions())).append("\n");
        }
        
        if (!preference.getCategoryScores().isEmpty()) {
            prompt.append("카테고리 점수: ");
            preference.getCategoryScores().entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .limit(5)
                .forEach(entry -> prompt.append(entry.getKey()).append("(").append(String.format("%.1f", entry.getValue())).append(") "));
            prompt.append("\n");
        }
        
        prompt.append("\n요청 컨텍스트: ").append(context != null ? context : "일반적인 여행 추천").append("\n\n");
        
        prompt.append("다음 JSON 형식으로 개인화된 추천을 제공해주세요:\n");
        prompt.append("{\n");
        prompt.append("  \"personalizedRecommendations\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"destinationName\": \"추천 여행지\",\n");
        prompt.append("      \"region\": \"지역\",\n");
        prompt.append("      \"matchScore\": 0.95,\n");
        prompt.append("      \"personalizedReason\": \"사용자 선호도 기반 추천 이유\",\n");
        prompt.append("      \"recommendedActivities\": [\"활동1\", \"활동2\"],\n");
        prompt.append("      \"budgetFit\": \"예산 적합성\",\n");
        prompt.append("      \"bestTime\": \"최적 방문 시기\",\n");
        prompt.append("      \"personalTips\": [\"개인화 팁1\", \"개인화 팁2\"]\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"improvementSuggestions\": [\"추천 개선을 위한 제안들\"]\n");
        prompt.append("}\n\n");
        
        prompt.append("요구사항:\n");
        prompt.append("1. 사용자의 과거 선호도를 최대한 반영\n");
        prompt.append("2. 매치 점수는 실제 선호도 데이터 기반으로 계산\n");
        prompt.append("3. 개인화된 이유는 구체적이고 설득력 있게\n");
        prompt.append("4. 5개의 여행지 추천\n");
        prompt.append("5. 추천 개선 제안 포함\n");
        
        return prompt.toString();
    }
    
    /**
     * 개인화 추천 파싱
     */
    private Map<String, Object> parsePersonalizedRecommendations(String content, UserPreferenceDTO preference) {
        try {
            String jsonContent = extractJsonFromResponse(content);
            Map<String, Object> responseMap = objectMapper.readValue(jsonContent, new TypeReference<Map<String, Object>>() {});
            
            Map<String, Object> result = new HashMap<>();
            result.put("userId", preference.getUserId());
            result.put("accuracyScore", preference.getAccuracyScore());
            result.put("personalizedRecommendations", responseMap.get("personalizedRecommendations"));
            result.put("improvementSuggestions", responseMap.get("improvementSuggestions"));
            result.put("generatedAt", LocalDateTime.now());
            
            return result;
            
        } catch (Exception e) {
            log.error("개인화 추천 파싱 실패", e);
            return getDefaultRecommendations();
        }
    }
    
    /**
     * JSON 추출 (SocialTrendsService와 동일)
     */
    private String extractJsonFromResponse(String response) {
        int startIndex = response.indexOf("{");
        int endIndex = response.lastIndexOf("}");
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return response.substring(startIndex, endIndex + 1);
        }
        
        throw new RuntimeException("JSON 형식을 찾을 수 없습니다.");
    }
    
    /**
     * 기본 추천 데이터
     */
    private Map<String, Object> getDefaultRecommendations() {
        return Map.of(
            "personalizedRecommendations", List.of(),
            "improvementSuggestions", List.of("더 많은 상호작용을 통해 추천 정확도를 향상시킬 수 있습니다."),
            "accuracyScore", 0.5
        );
    }
    
    /**
     * 학습 기간 계산
     */
    private long calculateLearningDays(UserPreferenceDTO preference) {
        return java.time.Duration.between(preference.getLearningStartTime(), LocalDateTime.now()).toDays();
    }
    
    /**
     * 상위 카테고리 추출
     */
    private List<Map<String, Object>> getTopCategories(UserPreferenceDTO preference) {
        return preference.getCategoryScores().entrySet().stream()
            .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
            .limit(5)
            .map(entry -> Map.<String, Object>of(
                "category", entry.getKey(),
                "score", entry.getValue()
            ))
            .toList();
    }
    
    /**
     * 사용자 선호도 조회
     */
    public UserPreferenceDTO getUserPreference(String userId) {
        return userPreferences.get(userId);
    }
    
    /**
     * 모든 사용자 선호도 조회 (관리자용)
     */
    public Map<String, UserPreferenceDTO> getAllUserPreferences() {
        return new HashMap<>(userPreferences);
    }
}