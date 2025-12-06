package com.tour.project.service;

import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class AdvancedTravelMatchingService {

    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private TravelMbtiDAO travelMbtiDAO;
    
    @Autowired
    private UserPreferenceLearner userPreferenceLearner;
    
    @Autowired
    private MBTICompatibilityEngine mbtiEngine;
    
    @Autowired
    private CollaborativeFilteringService collaborativeService;

    /**
     * 개인화된 여행 매칭 추천 메인 메서드
     */
    public List<TravelPlanDTO> getPersonalizedRecommendations(
            String userMessage, 
            Long userId,
            int limit
    ) {
        try {
            // 1. 사용자 프로필 및 이력 로드
            UserPreferenceModel userProfile = userPreferenceLearner.learnUserPreferences(userId);
            UserHistoryDTO userHistory = loadUserHistory(userId);
            
            // 2. 키워드 추출 및 의도 분석
            List<String> keywords = extractKeywords(userMessage);
            TravelIntent userIntent = analyzeIntent(userMessage);
            
            // 3. 후보 여행 계획 추출
            List<TravelPlanDTO> candidates = getCandidatePlans(keywords, userIntent);
            
            if (candidates.isEmpty()) {
                return new ArrayList<>();
            }
            
            // 4. 다층 점수 계산
            Map<TravelPlanDTO, Double> scoredPlans = calculateAdvancedScores(
                candidates, userProfile, keywords, userHistory, userId
            );
            
            // 5. 개인화 가중치 적용
            applyPersonalizedWeights(scoredPlans, userProfile);
            
            // 6. 최종 정렬 및 다양성 보장
            List<TravelPlanDTO> results = scoredPlans.entrySet().stream()
                .sorted(Map.Entry.<TravelPlanDTO, Double>comparingByValue().reversed())
                .map(Map.Entry::getKey)
                .limit(limit * 2) // 다양성을 위해 더 많이 가져옴
                .collect(Collectors.toList());
                
            return diversifyResults(results, limit);
            
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 기본 매칭으로 fallback
            return getFallbackRecommendations(userMessage, limit);
        }
    }

    /**
     * 다층 점수 계산 시스템
     * 기본 매칭 40% + 개인화 30% + 협업 필터링 20% + 시간 가중치 10%
     */
    private Map<TravelPlanDTO, Double> calculateAdvancedScores(
            List<TravelPlanDTO> candidates,
            UserPreferenceModel userProfile,
            List<String> keywords,
            UserHistoryDTO userHistory,
            Long userId
    ) {
        Map<TravelPlanDTO, Double> scores = new HashMap<>();
        
        for (TravelPlanDTO plan : candidates) {
            double totalScore = 0.0;
            
            // 1. 기본 매칭 점수 (40%)
            double basicScore = calculateBasicMatchScore(plan, keywords, userProfile);
            totalScore += basicScore * 0.4;
            
            // 2. 개인화 점수 (30%)
            double personalizationScore = calculatePersonalizationScore(plan, userProfile, userHistory);
            totalScore += personalizationScore * 0.3;
            
            // 3. 협업 필터링 점수 (20%)
            double collaborativeScore = collaborativeService.getCollaborativeScore(String.valueOf(userId), (long) plan.getPlanId());
            totalScore += collaborativeScore * 0.2;
            
            // 4. 시간 가중치 (10%)
            double timeWeightScore = calculateTimeWeightScore(plan);
            totalScore += timeWeightScore * 0.1;
            
            scores.put(plan, Math.max(0, Math.min(100, totalScore))); // 0-100 범위로 제한
        }
        
        return scores;
    }

    /**
     * 기본 매칭 점수 계산 (최대 100점)
     */
    private double calculateBasicMatchScore(TravelPlanDTO plan, List<String> keywords, UserPreferenceModel userProfile) {
        double score = 0.0;
        
        // 목적지 일치 (50점)
        if (matchesDestination(plan, keywords, userProfile)) {
            score += 50.0;
        }
        
        // 기간 일치 (30점)
        if (matchesDuration(plan, keywords, userProfile)) {
            score += 30.0;
        }
        
        // 예산 일치 (25점)
        score += calculateBudgetMatch(plan, userProfile) * 25.0;
        
        // 여행 스타일 일치 (35점)
        score += calculateStyleMatch(plan, keywords, userProfile) * 35.0;
        
        // 태그 매칭 (태그당 5점, 최대 15점)
        score += Math.min(15.0, calculateTagMatch(plan, keywords) * 5.0);
        
        return Math.min(100.0, score);
    }

    /**
     * 개인화 점수 계산 (최대 100점)
     */
    private double calculatePersonalizationScore(TravelPlanDTO plan, UserPreferenceModel userProfile, UserHistoryDTO userHistory) {
        double score = 0.0;
        
        try {
            // 과거 비슷한 여행 참여 이력 (40점)
            score += calculateSimilarTravelHistory(plan, userHistory) * 40.0;
            
            // 선호 여행 스타일 일치도 (30점)
            score += calculatePreferredStyleMatch(plan, userProfile) * 30.0;
            
            // MBTI 궁합도 (20점)
            MemberDTO planOwner = memberDAO.getMemberById(plan.getPlanWriter());
            if (planOwner != null && planOwner.getMbtiType() != null) {
                UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(String.valueOf(userProfile.getUserId()));
                if (userMbti != null) {
                    score += mbtiEngine.calculateMBTIScore(userMbti.getMbtiType(), planOwner.getMbtiType()) * 20.0;
                }
            }
            
            // 연령대/성별 선호도 (10점)
            score += calculateDemographicMatch(plan, userProfile) * 10.0;
            
        } catch (Exception e) {
            // 개인화 점수 계산 실패 시 기본 점수
            score = 50.0;
        }
        
        return Math.min(100.0, score);
    }

    /**
     * 시간 가중치 계산 (최대 100점)
     */
    private double calculateTimeWeightScore(TravelPlanDTO plan) {
        double score = 50.0; // 기본 점수
        
        try {
            LocalDateTime now = LocalDateTime.now();
            
            // 최근 활동 가중치 (30일 이내 활동은 1.5배)
            if (plan.getPlanCreatedDate() != null) {
                long daysAgo = ChronoUnit.DAYS.between(plan.getPlanCreatedDate(), now);
                if (daysAgo <= 30) {
                    score *= 1.5;
                }
            }
            
            // 계절성 매칭 (비슷한 시기 여행 선호도 +15점)
            if (plan.getPlanStartDate() != null) {
                int planMonth = plan.getPlanStartDate().toLocalDate().getMonthValue();
                int currentMonth = now.getMonthValue();
                
                // 같은 계절이면 보너스
                if (isSameSeason(planMonth, currentMonth)) {
                    score += 15.0;
                }
            }
            
        } catch (Exception e) {
            score = 50.0;
        }
        
        return Math.min(100.0, score);
    }

    /**
     * 목적지 매칭 검사
     */
    private boolean matchesDestination(TravelPlanDTO plan, List<String> keywords, UserPreferenceModel userProfile) {
        // 키워드와 목적지 매칭
        for (String keyword : keywords) {
            if (plan.getPlanDestination().toLowerCase().contains(keyword.toLowerCase())) {
                return true;
            }
        }
        
        // 사용자 선호 목적지와 매칭
        if (userProfile.getFavoriteDestinations() != null) {
            for (String favDest : userProfile.getFavoriteDestinations()) {
                if (plan.getPlanDestination().toLowerCase().contains(favDest.toLowerCase())) {
                    return true;
                }
            }
        }
        
        return false;
    }

    /**
     * 기간 매칭 검사
     */
    private boolean matchesDuration(TravelPlanDTO plan, List<String> keywords, UserPreferenceModel userProfile) {
        if (plan.getPlanStartDate() == null || plan.getPlanEndDate() == null) {
            return false;
        }
        
        long planDays = ChronoUnit.DAYS.between(
            plan.getPlanStartDate().toLocalDate(),
            plan.getPlanEndDate().toLocalDate()
        ) + 1;
        
        // 키워드에서 기간 추출하여 매칭
        for (String keyword : keywords) {
            if (keyword.contains("3박4일") || keyword.contains("4일")) {
                return planDays >= 3 && planDays <= 5;
            }
            if (keyword.contains("2박3일") || keyword.contains("3일")) {
                return planDays >= 2 && planDays <= 4;
            }
            if (keyword.contains("1주일") || keyword.contains("7일")) {
                return planDays >= 6 && planDays <= 8;
            }
        }
        
        // 사용자 선호 기간과 매칭
        if (userProfile.getAvgDurationDays() != null) {
            return Math.abs(planDays - userProfile.getAvgDurationDays()) <= 2;
        }
        
        return false;
    }

    /**
     * 예산 매칭 계산 (0.0 ~ 1.0)
     */
    private double calculateBudgetMatch(TravelPlanDTO plan, UserPreferenceModel userProfile) {
        if (plan.getPlanBudget() == null || userProfile.getAvgBudget() == null) {
            return 0.5; // 정보 부족 시 중간 점수
        }
        
        double planBudget = plan.getPlanBudget();
        double userBudget = userProfile.getAvgBudget();
        
        // 예산 차이가 적을수록 높은 점수
        double budgetRatio = Math.min(planBudget, userBudget) / Math.max(planBudget, userBudget);
        
        return budgetRatio;
    }

    /**
     * 여행 스타일 매칭 계산 (0.0 ~ 1.0)
     */
    private double calculateStyleMatch(TravelPlanDTO plan, List<String> keywords, UserPreferenceModel userProfile) {
        double score = 0.0;
        String planContent = (plan.getPlanTitle() + " " + plan.getPlanContent() + " " + plan.getPlanTags()).toLowerCase();
        
        // 키워드 기반 스타일 매칭
        for (String keyword : keywords) {
            if (planContent.contains(keyword.toLowerCase())) {
                score += 0.3;
            }
        }
        
        // 사용자 선호 스타일 매칭
        if (userProfile.getStylePreferences() != null) {
            for (Map.Entry<String, Double> styleEntry : userProfile.getStylePreferences().entrySet()) {
                if (planContent.contains(styleEntry.getKey().toLowerCase())) {
                    score += styleEntry.getValue() / 100.0 * 0.7;
                }
            }
        }
        
        return Math.min(1.0, score);
    }

    /**
     * 태그 매칭 계산
     */
    private int calculateTagMatch(TravelPlanDTO plan, List<String> keywords) {
        if (plan.getPlanTags() == null || plan.getPlanTags().isEmpty()) {
            return 0;
        }
        
        int matches = 0;
        String planTags = plan.getPlanTags().toLowerCase();
        
        for (String keyword : keywords) {
            if (planTags.contains(keyword.toLowerCase())) {
                matches++;
            }
        }
        
        return matches;
    }

    /**
     * 비슷한 여행 이력 계산 (0.0 ~ 1.0)
     */
    private double calculateSimilarTravelHistory(TravelPlanDTO plan, UserHistoryDTO userHistory) {
        if (userHistory == null || userHistory.getDestinationHistory() == null) {
            return 0.3; // 이력 없을 때 기본 점수
        }
        
        String planDestination = extractDestinationCategory(plan.getPlanDestination());
        Integer visitCount = userHistory.getDestinationHistory().get(planDestination);
        
        if (visitCount != null && visitCount > 0) {
            // 방문 경험이 있는 목적지일수록 높은 점수
            return Math.min(1.0, visitCount * 0.3);
        }
        
        return 0.1;
    }

    /**
     * 선호 스타일 매칭 계산 (0.0 ~ 1.0)
     */
    private double calculatePreferredStyleMatch(TravelPlanDTO plan, UserPreferenceModel userProfile) {
        if (userProfile.getStylePreferences() == null || userProfile.getStylePreferences().isEmpty()) {
            return 0.5;
        }
        
        String planContent = (plan.getPlanTitle() + " " + plan.getPlanContent() + " " + plan.getPlanTags()).toLowerCase();
        double totalScore = 0.0;
        double totalWeight = 0.0;
        
        for (Map.Entry<String, Double> styleEntry : userProfile.getStylePreferences().entrySet()) {
            String style = styleEntry.getKey().toLowerCase();
            Double preference = styleEntry.getValue();
            
            if (planContent.contains(style)) {
                totalScore += preference;
                totalWeight += 100.0;
            }
        }
        
        return totalWeight > 0 ? totalScore / totalWeight : 0.3;
    }

    /**
     * 인구통계학적 매칭 계산 (0.0 ~ 1.0)
     */
    private double calculateDemographicMatch(TravelPlanDTO plan, UserPreferenceModel userProfile) {
        // 현재는 기본 점수 반환, 추후 연령/성별 데이터 추가 시 구현
        return 0.5;
    }

    /**
     * 키워드 추출
     */
    private List<String> extractKeywords(String userMessage) {
        List<String> keywords = new ArrayList<>();
        if (userMessage == null) return keywords;
        
        String lowerMessage = userMessage.toLowerCase();
        
        // 목적지 키워드
        if (lowerMessage.contains("일본") || lowerMessage.contains("도쿄") || lowerMessage.contains("오사카")) {
            keywords.add("일본");
        }
        if (lowerMessage.contains("동남아") || lowerMessage.contains("태국") || lowerMessage.contains("베트남")) {
            keywords.add("동남아");
        }
        if (lowerMessage.contains("유럽") || lowerMessage.contains("프랑스") || lowerMessage.contains("독일")) {
            keywords.add("유럽");
        }
        if (lowerMessage.contains("국내") || lowerMessage.contains("제주") || lowerMessage.contains("부산")) {
            keywords.add("국내");
        }
        
        // 스타일 키워드
        if (lowerMessage.contains("배낭") || lowerMessage.contains("백패킹")) {
            keywords.add("배낭여행");
        }
        if (lowerMessage.contains("휴양") || lowerMessage.contains("힐링")) {
            keywords.add("휴양");
        }
        if (lowerMessage.contains("모험") || lowerMessage.contains("액티비티")) {
            keywords.add("모험");
        }
        if (lowerMessage.contains("문화") || lowerMessage.contains("관광")) {
            keywords.add("문화");
        }
        
        // 기간 키워드
        if (lowerMessage.contains("3박4일") || lowerMessage.contains("4일")) {
            keywords.add("3박4일");
        }
        if (lowerMessage.contains("2박3일") || lowerMessage.contains("3일")) {
            keywords.add("2박3일");
        }
        
        return keywords;
    }

    /**
     * 여행 의도 분석
     */
    private TravelIntent analyzeIntent(String userMessage) {
        // 간단한 의도 분석 (추후 NLP 모델로 개선 가능)
        return TravelIntent.GENERAL_MATCHING;
    }

    /**
     * 후보 여행 계획 추출
     */
    private List<TravelPlanDTO> getCandidatePlans(List<String> keywords, TravelIntent intent) {
        List<TravelPlanDTO> allPlans = travelPlanDAO.getAllTravelPlans();
        
        return allPlans.stream()
            .filter(plan -> "ACTIVE".equals(plan.getPlanStatus()))
            .filter(plan -> plan.getPlanStartDate() != null)
            .filter(plan -> plan.getPlanStartDate().toLocalDate().isAfter(LocalDateTime.now().toLocalDate()))
            .collect(Collectors.toList());
    }

    /**
     * 개인화 가중치 적용
     */
    private void applyPersonalizedWeights(Map<TravelPlanDTO, Double> scoredPlans, UserPreferenceModel userProfile) {
        Map<String, Double> weights = userPreferenceLearner.getPersonalizedWeights(userProfile);
        
        // 현재는 기본 가중치 적용, 추후 더 세밀한 가중치 적용 가능
        for (Map.Entry<TravelPlanDTO, Double> entry : scoredPlans.entrySet()) {
            Double currentScore = entry.getValue();
            // 가중치에 따른 점수 조정 로직
            entry.setValue(currentScore);
        }
    }

    /**
     * 결과 다양성 보장 (MMR 알고리즘 적용)
     */
    private List<TravelPlanDTO> diversifyResults(List<TravelPlanDTO> plans, int limit) {
        if (plans.size() <= limit) {
            return plans;
        }
        
        List<TravelPlanDTO> diversified = new ArrayList<>();
        Set<String> seenDestinations = new HashSet<>();
        Set<String> seenStyles = new HashSet<>();
        
        for (TravelPlanDTO plan : plans) {
            if (diversified.size() >= limit) break;
            
            String destination = extractDestinationCategory(plan.getPlanDestination());
            String style = extractStyleFromContent(plan);
            
            // 다양성을 위해 같은 목적지/스타일이 너무 많으면 제한
            boolean addPlan = true;
            if (seenDestinations.contains(destination) && seenDestinations.size() < 3) {
                long destCount = diversified.stream()
                    .filter(p -> extractDestinationCategory(p.getPlanDestination()).equals(destination))
                    .count();
                if (destCount >= 2) addPlan = false;
            }
            
            if (addPlan) {
                diversified.add(plan);
                seenDestinations.add(destination);
                seenStyles.add(style);
            }
        }
        
        // 다양성 보장이 부족하면 나머지 추가
        if (diversified.size() < limit) {
            for (TravelPlanDTO plan : plans) {
                if (diversified.size() >= limit) break;
                if (!diversified.contains(plan)) {
                    diversified.add(plan);
                }
            }
        }
        
        return diversified;
    }

    /**
     * 사용자 이력 로드
     */
    private UserHistoryDTO loadUserHistory(Long userId) {
        UserHistoryDTO history = new UserHistoryDTO(userId);
        
        try {
            List<TravelPlanDTO> userPlans = travelPlanDAO.getTravelPlansByWriter(String.valueOf(userId));
            history.setPastTravels(userPlans);
            history.setTotalTrips(userPlans.size());
            
            // 목적지 이력 구축
            Map<String, Integer> destHistory = new HashMap<>();
            for (TravelPlanDTO plan : userPlans) {
                String dest = extractDestinationCategory(plan.getPlanDestination());
                destHistory.merge(dest, 1, Integer::sum);
            }
            history.setDestinationHistory(destHistory);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return history;
    }

    /**
     * Fallback 추천 (에러 시 사용)
     */
    private List<TravelPlanDTO> getFallbackRecommendations(String userMessage, int limit) {
        List<TravelPlanDTO> allPlans = travelPlanDAO.getAllTravelPlans();
        
        return allPlans.stream()
            .filter(plan -> "ACTIVE".equals(plan.getPlanStatus()))
            .filter(plan -> plan.getPlanStartDate() != null)
            .filter(plan -> plan.getPlanStartDate().toLocalDate().isAfter(LocalDateTime.now().toLocalDate()))
            .limit(limit)
            .collect(Collectors.toList());
    }

    /**
     * 목적지 카테고리 추출
     */
    private String extractDestinationCategory(String destination) {
        if (destination == null) return "기타";
        
        String dest = destination.toLowerCase();
        if (dest.contains("일본") || dest.contains("도쿄") || dest.contains("오사카")) {
            return "일본";
        } else if (dest.contains("태국") || dest.contains("베트남") || dest.contains("동남아")) {
            return "동남아";
        } else if (dest.contains("유럽") || dest.contains("프랑스") || dest.contains("독일")) {
            return "유럽";
        } else if (dest.contains("제주") || dest.contains("부산") || dest.contains("국내")) {
            return "국내";
        }
        return "기타";
    }

    /**
     * 콘텐츠에서 스타일 추출
     */
    private String extractStyleFromContent(TravelPlanDTO plan) {
        String content = (plan.getPlanTitle() + " " + plan.getPlanContent() + " " + plan.getPlanTags()).toLowerCase();
        
        if (content.contains("배낭") || content.contains("자유")) {
            return "배낭여행";
        } else if (content.contains("휴양") || content.contains("힐링")) {
            return "휴양";
        } else if (content.contains("모험") || content.contains("액티비티")) {
            return "모험";
        } else if (content.contains("문화") || content.contains("관광")) {
            return "문화";
        }
        return "일반";
    }

    /**
     * 같은 계절인지 확인
     */
    private boolean isSameSeason(int month1, int month2) {
        int season1 = (month1 - 1) / 3; // 0:겨울, 1:봄, 2:여름, 3:가을
        int season2 = (month2 - 1) / 3;
        return season1 == season2;
    }

    /**
     * 여행 의도 열거형
     */
    enum TravelIntent {
        GENERAL_MATCHING,
        BUDGET_FOCUSED,
        DESTINATION_FOCUSED,
        STYLE_FOCUSED,
        TIME_FOCUSED
    }
}