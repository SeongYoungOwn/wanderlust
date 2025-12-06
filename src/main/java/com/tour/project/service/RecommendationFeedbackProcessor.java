package com.tour.project.service;

import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

/**
 * 추천 시스템의 실시간 학습 및 피드백 처리
 * 사용자 행동 데이터를 수집하고 모델을 지속적으로 개선
 */
@Component
public class RecommendationFeedbackProcessor {

    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private UserPreferenceLearner userPreferenceLearner;

    // 메모리 기반 피드백 저장소 (실제 환경에서는 Redis나 DB 사용)
    private Map<String, MatchingFeedback> feedbackCache = new HashMap<>();
    private Map<Long, UserBehaviorData> behaviorCache = new HashMap<>();

    /**
     * 매칭 결과에 대한 피드백 처리 (비동기)
     * @param userId 사용자 ID
     * @param planId 여행 계획 ID
     * @param interaction 사용자 상호작용 (CLICK, VIEW, APPLY, RATE 등)
     * @param satisfactionScore 만족도 점수 (1-5)
     * @param actualParticipation 실제 참여 여부
     */
    @Async
    public void processFeedback(Long userId, Long planId, String interaction, 
                              Integer satisfactionScore, Boolean actualParticipation) {
        try {
            // 1. 피드백 데이터 수집
            String feedbackKey = userId + "_" + planId;
            MatchingFeedback feedback = feedbackCache.computeIfAbsent(feedbackKey, 
                k -> new MatchingFeedback(userId, planId));
            
            // 2. 상호작용 타입별 처리
            switch (interaction.toUpperCase()) {
                case "CLICK":
                    feedback.incrementClickCount();
                    recordUserBehavior(userId, "CLICK_PLAN", planId.toString());
                    break;
                case "VIEW":
                    feedback.incrementViewCount();
                    feedback.updateViewDuration(calculateViewDuration());
                    recordUserBehavior(userId, "VIEW_DETAIL", planId.toString());
                    break;
                case "APPLY":
                    feedback.setApplied(true);
                    recordUserBehavior(userId, "APPLY_PLAN", planId.toString());
                    break;
                case "RATE":
                    if (satisfactionScore != null) {
                        feedback.setSatisfactionScore(satisfactionScore);
                        recordUserBehavior(userId, "RATE_PLAN", satisfactionScore.toString());
                    }
                    break;
                case "PARTICIPATE":
                    if (actualParticipation != null) {
                        feedback.setActualParticipation(actualParticipation);
                        recordUserBehavior(userId, "PARTICIPATE", actualParticipation.toString());
                    }
                    break;
            }
            
            feedback.setLastUpdated(LocalDateTime.now());
            
            // 3. 즉시 학습 (중요한 피드백의 경우)
            if ("RATE".equals(interaction) || "PARTICIPATE".equals(interaction)) {
                performImmediateLearning(userId, planId, feedback);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 사용자 행동 패턴 기록
     */
    private void recordUserBehavior(Long userId, String actionType, String actionValue) {
        UserBehaviorData behavior = behaviorCache.computeIfAbsent(userId, 
            k -> new UserBehaviorData(userId));
        
        UserAction action = new UserAction(actionType, actionValue, LocalDateTime.now());
        behavior.addAction(action);
        
        // 행동 패턴 분석하여 즉시 선호도 업데이트
        if (behavior.getActions().size() % 10 == 0) { // 10개 행동마다 업데이트
            updateUserPreferencesFromBehavior(userId, behavior);
        }
    }

    /**
     * 즉시 학습 실행
     */
    private void performImmediateLearning(Long userId, Long planId, MatchingFeedback feedback) {
        try {
            TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(planId);
            if (plan == null) return;
            
            // 1. 사용자 선호도 모델 업데이트
            UserPreferenceModel currentModel = userPreferenceLearner.learnUserPreferences(userId);
            
            // 2. 피드백 기반 가중치 조정
            adjustWeightsBasedOnFeedback(currentModel, plan, feedback);
            
            // 3. 부정적 피드백 처리
            if (feedback.getSatisfactionScore() != null && feedback.getSatisfactionScore() < 3) {
                processNegativeFeedback(userId, plan, feedback);
            }
            
            // 4. 긍정적 피드백 강화
            if (feedback.getSatisfactionScore() != null && feedback.getSatisfactionScore() >= 4) {
                reinforcePositiveFeedback(userId, plan, feedback);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 피드백 기반 가중치 조정
     */
    private void adjustWeightsBasedOnFeedback(UserPreferenceModel model, TravelPlanDTO plan, 
                                            MatchingFeedback feedback) {
        Map<String, Double> weights = model.getPersonalizedWeights();
        if (weights == null) {
            weights = new HashMap<>();
        }
        
        double learningRate = 0.1; // 학습률
        
        if (feedback.getSatisfactionScore() != null) {
            double satisfactionNormalized = (feedback.getSatisfactionScore() - 3.0) / 2.0; // -1 to 1
            
            // 만족도에 따른 가중치 조정
            if (satisfactionNormalized > 0) {
                // 긍정적 피드백 - 매칭된 특성들의 가중치 증가
                increaseMatchingFeatureWeights(weights, plan, learningRate * satisfactionNormalized);
            } else {
                // 부정적 피드백 - 매칭된 특성들의 가중치 감소
                decreaseMatchingFeatureWeights(weights, plan, learningRate * Math.abs(satisfactionNormalized));
            }
        }
        
        // 클릭률 기반 조정
        if (feedback.getClickCount() > 0) {
            double clickRate = feedback.getClickCount() / Math.max(1.0, feedback.getViewCount());
            if (clickRate > 0.3) { // 높은 클릭률
                increaseMatchingFeatureWeights(weights, plan, learningRate * 0.5);
            }
        }
        
        model.setPersonalizedWeights(weights);
    }

    /**
     * 매칭 특성 가중치 증가
     */
    private void increaseMatchingFeatureWeights(Map<String, Double> weights, TravelPlanDTO plan, 
                                              double adjustment) {
        // 목적지 가중치 조정
        String destination = extractDestinationCategory(plan.getPlanDestination());
        weights.merge("destination_" + destination, adjustment, Double::sum);
        
        // 예산 가중치 조정
        if (plan.getPlanBudget() != null) {
            String budgetRange = getBudgetRange(plan.getPlanBudget());
            weights.merge("budget_" + budgetRange, adjustment, Double::sum);
        }
        
        // 스타일 가중치 조정
        String style = extractTravelStyle(plan);
        weights.merge("style_" + style, adjustment, Double::sum);
    }

    /**
     * 매칭 특성 가중치 감소
     */
    private void decreaseMatchingFeatureWeights(Map<String, Double> weights, TravelPlanDTO plan, 
                                              double adjustment) {
        String destination = extractDestinationCategory(plan.getPlanDestination());
        weights.merge("destination_" + destination, -adjustment, Double::sum);
        
        if (plan.getPlanBudget() != null) {
            String budgetRange = getBudgetRange(plan.getPlanBudget());
            weights.merge("budget_" + budgetRange, -adjustment, Double::sum);
        }
        
        String style = extractTravelStyle(plan);
        weights.merge("style_" + style, -adjustment, Double::sum);
    }

    /**
     * 부정적 피드백 처리
     */
    private void processNegativeFeedback(Long userId, TravelPlanDTO plan, MatchingFeedback feedback) {
        // 사용자의 비선호 목적지에 추가
        UserPreferenceModel model = userPreferenceLearner.learnUserPreferences(userId);
        List<String> dislikedDestinations = model.getDislikedDestinations();
        if (dislikedDestinations == null) {
            dislikedDestinations = new ArrayList<>();
        }
        
        String destination = extractDestinationCategory(plan.getPlanDestination());
        if (!dislikedDestinations.contains(destination)) {
            dislikedDestinations.add(destination);
            model.setDislikedDestinations(dislikedDestinations);
        }
    }

    /**
     * 긍정적 피드백 강화
     */
    private void reinforcePositiveFeedback(Long userId, TravelPlanDTO plan, MatchingFeedback feedback) {
        UserPreferenceModel model = userPreferenceLearner.learnUserPreferences(userId);
        
        // 선호 목적지 강화
        Map<String, Double> destPrefs = model.getDestinationPreferences();
        if (destPrefs == null) {
            destPrefs = new HashMap<>();
        }
        
        String destination = extractDestinationCategory(plan.getPlanDestination());
        destPrefs.merge(destination, 10.0, Double::sum); // 선호도 증가
        model.setDestinationPreferences(destPrefs);
        
        // 선호 스타일 강화
        Map<String, Double> stylePrefs = model.getStylePreferences();
        if (stylePrefs == null) {
            stylePrefs = new HashMap<>();
        }
        
        String style = extractTravelStyle(plan);
        stylePrefs.merge(style, 10.0, Double::sum);
        model.setStylePreferences(stylePrefs);
    }

    /**
     * 행동 패턴 기반 선호도 업데이트
     */
    private void updateUserPreferencesFromBehavior(Long userId, UserBehaviorData behavior) {
        try {
            UserPreferenceModel model = userPreferenceLearner.learnUserPreferences(userId);
            
            // 최근 행동 패턴 분석
            List<UserAction> recentActions = behavior.getRecentActions(30); // 최근 30개 행동
            
            // 클릭 패턴 분석
            Map<String, Long> clickPatterns = recentActions.stream()
                .filter(action -> "CLICK_PLAN".equals(action.getActionType()))
                .collect(Collectors.groupingBy(
                    action -> extractDestinationFromPlanId(action.getActionValue()),
                    Collectors.counting()
                ));
            
            // 클릭 패턴을 선호도에 반영
            Map<String, Double> destPrefs = model.getDestinationPreferences();
            if (destPrefs == null) {
                destPrefs = new HashMap<>();
            }
            
            for (Map.Entry<String, Long> entry : clickPatterns.entrySet()) {
                destPrefs.merge(entry.getKey(), entry.getValue() * 2.0, Double::sum);
            }
            
            model.setDestinationPreferences(destPrefs);
            model.setLastUpdated(LocalDateTime.now());
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 배치로 주기적 모델 업데이트 (매일 새벽 2시)
     */
    @Scheduled(cron = "0 0 2 * * ?")
    public void updateRecommendationModel() {
        try {
            // 1. 일일 피드백 데이터 분석
            analyzeDailyFeedback();
            
            // 2. 전체 사용자의 선호도 패턴 업데이트
            updateGlobalPreferencePatterns();
            
            // 3. 추천 품질 지표 계산
            calculateRecommendationMetrics();
            
            // 4. 모델 성능 평가
            evaluateModelPerformance();
            
            // 5. 캐시 정리 (오래된 데이터 제거)
            cleanupOldCache();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 일일 피드백 분석
     */
    private void analyzeDailyFeedback() {
        LocalDateTime yesterday = LocalDateTime.now().minusDays(1);
        
        // 어제의 피드백 데이터 수집
        List<MatchingFeedback> dailyFeedbacks = feedbackCache.values().stream()
            .filter(feedback -> feedback.getLastUpdated().isAfter(yesterday))
            .collect(Collectors.toList());
        
        // 평균 만족도 계산
        double avgSatisfaction = dailyFeedbacks.stream()
            .filter(feedback -> feedback.getSatisfactionScore() != null)
            .mapToInt(MatchingFeedback::getSatisfactionScore)
            .average().orElse(3.0);
        
        // 클릭률 계산
        double avgClickRate = dailyFeedbacks.stream()
            .filter(feedback -> feedback.getViewCount() > 0)
            .mapToDouble(feedback -> (double) feedback.getClickCount() / feedback.getViewCount())
            .average().orElse(0.0);
        
        // 참여율 계산
        long participationCount = dailyFeedbacks.stream()
            .filter(feedback -> Boolean.TRUE.equals(feedback.getActualParticipation()))
            .count();
        double participationRate = dailyFeedbacks.isEmpty() ? 0.0 : 
            (double) participationCount / dailyFeedbacks.size();
        
        // 성과 지표 로깅
        System.out.println("=== 일일 추천 시스템 성과 ===");
        System.out.println("평균 만족도: " + String.format("%.2f", avgSatisfaction));
        System.out.println("평균 클릭률: " + String.format("%.2f%%", avgClickRate * 100));
        System.out.println("참여율: " + String.format("%.2f%%", participationRate * 100));
    }

    /**
     * 전체 선호도 패턴 업데이트
     */
    private void updateGlobalPreferencePatterns() {
        try {
            List<MemberDTO> allMembers = memberDAO.getAllMembers();
            
            for (MemberDTO member : allMembers) {
                UserBehaviorData behavior = behaviorCache.get(member.getUserId());
                if (behavior != null && behavior.hasRecentActivity(7)) { // 최근 7일 활동이 있는 경우
                    try {
                        updateUserPreferencesFromBehavior(Long.parseLong(member.getUserId()), behavior);
                    } catch (NumberFormatException e) {
                        // Skip non-numeric userIds for now
                        continue;
                    }
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 추천 품질 지표 계산
     */
    private void calculateRecommendationMetrics() {
        // CTR (Click-Through Rate)
        double ctr = calculateCTR();
        
        // 매칭 성공률
        double matchingSuccessRate = calculateMatchingSuccessRate();
        
        // 사용자 만족도
        double userSatisfaction = calculateAverageUserSatisfaction();
        
        // 재사용률
        double retentionRate = calculateRetentionRate();
        
        // 추천 다양성 지수
        double diversityIndex = calculateDiversityIndex();
        
        System.out.println("=== 추천 시스템 품질 지표 ===");
        System.out.println("CTR: " + String.format("%.2f%%", ctr * 100));
        System.out.println("매칭 성공률: " + String.format("%.2f%%", matchingSuccessRate * 100));
        System.out.println("사용자 만족도: " + String.format("%.2f", userSatisfaction));
        System.out.println("재사용률: " + String.format("%.2f%%", retentionRate * 100));
        System.out.println("다양성 지수: " + String.format("%.2f", diversityIndex));
    }

    /**
     * 모델 성능 평가
     */
    private void evaluateModelPerformance() {
        // A/B 테스트 결과 분석 (추후 구현)
        // 정확도, 재현율, F1 점수 계산 (추후 구현)
        // 사용자 세그먼트별 성능 분석 (추후 구현)
    }

    /**
     * 오래된 캐시 데이터 정리
     */
    private void cleanupOldCache() {
        LocalDateTime cutoff = LocalDateTime.now().minusDays(30);
        
        // 30일 이상 된 피드백 데이터 제거
        feedbackCache.entrySet().removeIf(entry -> 
            entry.getValue().getLastUpdated().isBefore(cutoff));
        
        // 30일 이상 된 행동 데이터 제거
        behaviorCache.values().forEach(behavior -> 
            behavior.removeOldActions(cutoff));
    }

    // ===== 유틸리티 메서드들 =====

    private double calculateCTR() {
        long totalViews = feedbackCache.values().stream()
            .mapToLong(MatchingFeedback::getViewCount).sum();
        long totalClicks = feedbackCache.values().stream()
            .mapToLong(MatchingFeedback::getClickCount).sum();
        
        return totalViews > 0 ? (double) totalClicks / totalViews : 0.0;
    }

    private double calculateMatchingSuccessRate() {
        long totalFeedbacks = feedbackCache.size();
        long successfulMatches = feedbackCache.values().stream()
            .filter(feedback -> Boolean.TRUE.equals(feedback.getActualParticipation()))
            .count();
        
        return totalFeedbacks > 0 ? (double) successfulMatches / totalFeedbacks : 0.0;
    }

    private double calculateAverageUserSatisfaction() {
        return feedbackCache.values().stream()
            .filter(feedback -> feedback.getSatisfactionScore() != null)
            .mapToInt(MatchingFeedback::getSatisfactionScore)
            .average().orElse(3.0);
    }

    private double calculateRetentionRate() {
        // 재사용률 계산 로직 (간단한 버전)
        Set<Long> activeUsers = behaviorCache.keySet();
        long returnUsers = activeUsers.stream()
            .filter(userId -> behaviorCache.get(userId).hasRecentActivity(30))
            .count();
        
        return activeUsers.isEmpty() ? 0.0 : (double) returnUsers / activeUsers.size();
    }

    private double calculateDiversityIndex() {
        // 추천 다양성 계산 (간단한 버전)
        Set<String> recommendedDestinations = new HashSet<>();
        feedbackCache.values().forEach(feedback -> {
            try {
                TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(feedback.getPlanId());
                if (plan != null) {
                    recommendedDestinations.add(extractDestinationCategory(plan.getPlanDestination()));
                }
            } catch (Exception e) {
                // 무시
            }
        });
        
        return recommendedDestinations.size() / 5.0; // 5개 주요 목적지 대비
    }

    private long calculateViewDuration() {
        // 실제로는 클라이언트에서 전송받아야 하는 값
        return 30 + (long) (Math.random() * 120); // 30-150초 랜덤
    }

    private String extractDestinationCategory(String destination) {
        if (destination == null) return "기타";
        
        String dest = destination.toLowerCase();
        if (dest.contains("일본")) return "일본";
        if (dest.contains("동남아") || dest.contains("태국") || dest.contains("베트남")) return "동남아";
        if (dest.contains("유럽")) return "유럽";
        if (dest.contains("국내") || dest.contains("제주")) return "국내";
        return "기타";
    }

    private String extractTravelStyle(TravelPlanDTO plan) {
        String content = (plan.getPlanTitle() + " " + plan.getPlanContent() + " " + plan.getPlanTags()).toLowerCase();
        
        if (content.contains("배낭")) return "배낭여행";
        if (content.contains("휴양")) return "휴양";
        if (content.contains("모험")) return "모험";
        if (content.contains("문화")) return "문화";
        return "일반";
    }

    private String getBudgetRange(Integer budget) {
        if (budget < 500000) return "저예산";
        if (budget < 1000000) return "중예산";
        if (budget < 2000000) return "고예산";
        return "프리미엄";
    }

    private String extractDestinationFromPlanId(String planIdStr) {
        try {
            Long planId = Long.valueOf(planIdStr);
            TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(planId);
            return plan != null ? extractDestinationCategory(plan.getPlanDestination()) : "기타";
        } catch (Exception e) {
            return "기타";
        }
    }

    // ===== 내부 클래스들 =====

    /**
     * 매칭 피드백 데이터
     */
    private static class MatchingFeedback {
        private Long userId;
        private Long planId;
        private int clickCount = 0;
        private int viewCount = 0;
        private long totalViewDuration = 0;
        private boolean applied = false;
        private Integer satisfactionScore;
        private Boolean actualParticipation;
        private LocalDateTime lastUpdated;

        public MatchingFeedback(Long userId, Long planId) {
            this.userId = userId;
            this.planId = planId;
            this.lastUpdated = LocalDateTime.now();
        }

        // Getters and methods
        public Long getUserId() { return userId; }
        public Long getPlanId() { return planId; }
        public int getClickCount() { return clickCount; }
        public int getViewCount() { return viewCount; }
        public Integer getSatisfactionScore() { return satisfactionScore; }
        public Boolean getActualParticipation() { return actualParticipation; }
        public LocalDateTime getLastUpdated() { return lastUpdated; }

        public void incrementClickCount() { this.clickCount++; }
        public void incrementViewCount() { this.viewCount++; }
        public void updateViewDuration(long duration) { this.totalViewDuration += duration; }
        public void setApplied(boolean applied) { this.applied = applied; }
        public void setSatisfactionScore(Integer score) { this.satisfactionScore = score; }
        public void setActualParticipation(Boolean participation) { this.actualParticipation = participation; }
        public void setLastUpdated(LocalDateTime time) { this.lastUpdated = time; }
    }

    /**
     * 사용자 행동 데이터
     */
    private static class UserBehaviorData {
        private Long userId;
        private List<UserAction> actions;

        public UserBehaviorData(Long userId) {
            this.userId = userId;
            this.actions = new ArrayList<>();
        }

        public void addAction(UserAction action) {
            this.actions.add(action);
            // 메모리 관리를 위해 최근 1000개 행동만 유지
            if (this.actions.size() > 1000) {
                this.actions = this.actions.subList(this.actions.size() - 1000, this.actions.size());
            }
        }

        public List<UserAction> getActions() { return actions; }
        
        public List<UserAction> getRecentActions(int count) {
            int size = actions.size();
            return size <= count ? actions : actions.subList(size - count, size);
        }

        public boolean hasRecentActivity(int days) {
            LocalDateTime cutoff = LocalDateTime.now().minusDays(days);
            return actions.stream().anyMatch(action -> action.getTimestamp().isAfter(cutoff));
        }

        public void removeOldActions(LocalDateTime cutoff) {
            actions.removeIf(action -> action.getTimestamp().isBefore(cutoff));
        }
    }

    /**
     * 사용자 액션
     */
    private static class UserAction {
        private String actionType;
        private String actionValue;
        private LocalDateTime timestamp;

        public UserAction(String actionType, String actionValue, LocalDateTime timestamp) {
            this.actionType = actionType;
            this.actionValue = actionValue;
            this.timestamp = timestamp;
        }

        public String getActionType() { return actionType; }
        public String getActionValue() { return actionValue; }
        public LocalDateTime getTimestamp() { return timestamp; }
    }
}