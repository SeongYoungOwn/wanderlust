package com.tour.project.service;

import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class CollaborativeFilteringService {

    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private MemberDAO memberDAO;

    /**
     * 유사한 사용자들을 찾아 협업 필터링 점수 계산
     * @param userId 대상 사용자 ID
     * @param planId 여행 계획 ID
     * @return 협업 필터링 점수 (0 ~ 100)
     */
    public double getCollaborativeScore(String userId, Long planId) {
        try {
            // 1. 유사 사용자 찾기
            List<String> similarUsers = findSimilarUsers(userId, 10);
            
            if (similarUsers.isEmpty()) {
                return 50.0; // 유사 사용자 없을 때 기본 점수
            }
            
            // 2. 유사 사용자들의 해당 계획에 대한 선호도 계산
            double totalScore = 0.0;
            double totalWeight = 0.0;
            
            for (String similarUserId : similarUsers) {
                double similarity = calculateUserSimilarity(userId, similarUserId);
                double preference = calculateUserPreferenceForPlan(similarUserId, planId);
                
                totalScore += similarity * preference;
                totalWeight += similarity;
            }
            
            // 3. 가중 평균 계산
            double collaborativeScore = totalWeight > 0 ? (totalScore / totalWeight) : 50.0;
            
            // 4. 신뢰도 보정 (유사 사용자 수가 적으면 점수 보정)
            double confidenceAdjustment = Math.min(1.0, similarUsers.size() / 5.0);
            collaborativeScore = collaborativeScore * confidenceAdjustment + 50.0 * (1 - confidenceAdjustment);
            
            return Math.max(0.0, Math.min(100.0, collaborativeScore));
            
        } catch (Exception e) {
            e.printStackTrace();
            return 50.0; // 에러 시 기본 점수
        }
    }

    /**
     * 코사인 유사도 기반으로 유사한 사용자들 찾기
     * @param userId 기준 사용자 ID
     * @param limit 반환할 유사 사용자 수
     * @return 유사도가 높은 사용자 ID 리스트
     */
    public List<String> findSimilarUsers(String userId, int limit) {
        try {
            // 1. 모든 사용자의 여행 프로필 생성
            Map<String, UserTravelProfile> userProfiles = buildUserProfiles();
            
            UserTravelProfile targetProfile = userProfiles.get(userId);
            if (targetProfile == null) {
                return new ArrayList<>();
            }
            
            // 2. 다른 모든 사용자와 유사도 계산
            Map<String, Double> similarities = new HashMap<>();
            
            for (Map.Entry<String, UserTravelProfile> entry : userProfiles.entrySet()) {
                String otherUserId = entry.getKey();
                if (!otherUserId.equals(userId)) {
                    double similarity = calculateProfileSimilarity(targetProfile, entry.getValue());
                    if (similarity > 0.3) { // 유사도 임계값
                        similarities.put(otherUserId, similarity);
                    }
                }
            }
            
            // 3. 유사도 순으로 정렬하여 상위 N명 반환
            return similarities.entrySet().stream()
                .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
                .limit(limit)
                .map(Map.Entry::getKey)
                .collect(Collectors.toList());
                
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    /**
     * 두 사용자 간의 유사도 계산
     * @param userId1 사용자1 ID
     * @param userId2 사용자2 ID  
     * @return 유사도 점수 (0.0 ~ 1.0)
     */
    public double calculateUserSimilarity(String userId1, String userId2) {
        try {
            List<TravelPlanDTO> user1Plans = travelPlanDAO.getTravelPlansByWriter(userId1);
            List<TravelPlanDTO> user2Plans = travelPlanDAO.getTravelPlansByWriter(userId2);
            
            if (user1Plans.isEmpty() || user2Plans.isEmpty()) {
                return 0.0;
            }
            
            // 1. 목적지 유사도 계산
            double destinationSimilarity = calculateDestinationSimilarity(user1Plans, user2Plans);
            
            // 2. 예산 유사도 계산  
            double budgetSimilarity = calculateBudgetSimilarity(user1Plans, user2Plans);
            
            // 3. 여행 스타일 유사도 계산
            double styleSimilarity = calculateStyleSimilarity(user1Plans, user2Plans);
            
            // 4. 여행 기간 유사도 계산
            double durationSimilarity = calculateDurationSimilarity(user1Plans, user2Plans);
            
            // 5. 가중 평균으로 최종 유사도 계산
            return destinationSimilarity * 0.35 + 
                   budgetSimilarity * 0.25 + 
                   styleSimilarity * 0.25 + 
                   durationSimilarity * 0.15;
                   
        } catch (Exception e) {
            return 0.0;
        }
    }

    /**
     * 사용자의 특정 여행 계획에 대한 선호도 예측
     * @param userId 사용자 ID
     * @param planId 여행 계획 ID
     * @return 예측 선호도 점수 (0 ~ 100)
     */
    private double calculateUserPreferenceForPlan(String userId, Long planId) {
        try {
            TravelPlanDTO targetPlan = travelPlanDAO.getTravelPlanById(planId);
            List<TravelPlanDTO> userPlans = travelPlanDAO.getTravelPlansByWriter(userId);
            
            if (targetPlan == null || userPlans.isEmpty()) {
                return 50.0; // 정보 부족 시 중간 점수
            }
            
            double preferenceScore = 0.0;
            
            // 1. 목적지 선호도
            String targetDestination = extractDestinationCategory(targetPlan.getPlanDestination());
            long matchingDestinations = userPlans.stream()
                .filter(plan -> extractDestinationCategory(plan.getPlanDestination()).equals(targetDestination))
                .count();
            preferenceScore += (matchingDestinations / (double) userPlans.size()) * 30.0;
            
            // 2. 예산 선호도
            if (targetPlan.getPlanBudget() != null) {
                double avgUserBudget = userPlans.stream()
                    .filter(plan -> plan.getPlanBudget() != null)
                    .mapToInt(TravelPlanDTO::getPlanBudget)
                    .average().orElse(0);
                    
                if (avgUserBudget > 0) {
                    double budgetRatio = Math.min(targetPlan.getPlanBudget(), avgUserBudget) / 
                                       Math.max(targetPlan.getPlanBudget(), avgUserBudget);
                    preferenceScore += budgetRatio * 25.0;
                }
            }
            
            // 3. 스타일 선호도
            String targetStyle = extractTravelStyle(targetPlan);
            long matchingStyles = userPlans.stream()
                .filter(plan -> extractTravelStyle(plan).equals(targetStyle))
                .count();
            preferenceScore += (matchingStyles / (double) userPlans.size()) * 25.0;
            
            // 4. 기간 선호도  
            if (targetPlan.getPlanStartDate() != null && targetPlan.getPlanEndDate() != null) {
                long targetDuration = java.time.temporal.ChronoUnit.DAYS.between(
                    targetPlan.getPlanStartDate().toLocalDate(),
                    targetPlan.getPlanEndDate().toLocalDate()) + 1;
                    
                double avgUserDuration = userPlans.stream()
                    .filter(plan -> plan.getPlanStartDate() != null && plan.getPlanEndDate() != null)
                    .mapToLong(plan -> java.time.temporal.ChronoUnit.DAYS.between(
                        plan.getPlanStartDate().toLocalDate(),
                        plan.getPlanEndDate().toLocalDate()) + 1)
                    .average().orElse(0);
                    
                if (avgUserDuration > 0) {
                    double durationRatio = Math.min(targetDuration, avgUserDuration) / 
                                         Math.max(targetDuration, avgUserDuration);
                    preferenceScore += durationRatio * 20.0;
                }
            }
            
            return Math.max(0.0, Math.min(100.0, preferenceScore));
            
        } catch (Exception e) {
            return 50.0;
        }
    }

    /**
     * 모든 사용자의 여행 프로필 구축
     */
    private Map<String, UserTravelProfile> buildUserProfiles() {
        Map<String, UserTravelProfile> profiles = new HashMap<>();
        
        try {
            List<MemberDTO> allMembers = memberDAO.getAllMembers();
            
            for (MemberDTO member : allMembers) {
                List<TravelPlanDTO> userPlans = travelPlanDAO.getTravelPlansByWriter(member.getUserId());
                
                if (!userPlans.isEmpty()) {
                    UserTravelProfile profile = new UserTravelProfile();
                    profile.setUserId(member.getUserId());
                    
                    // 목적지 선호도 계산
                    Map<String, Integer> destinations = new HashMap<>();
                    for (TravelPlanDTO plan : userPlans) {
                        String dest = extractDestinationCategory(plan.getPlanDestination());
                        destinations.merge(dest, 1, Integer::sum);
                    }
                    profile.setDestinationPreferences(destinations);
                    
                    // 예산 범위 계산
                    List<Integer> budgets = userPlans.stream()
                        .filter(plan -> plan.getPlanBudget() != null)
                        .map(TravelPlanDTO::getPlanBudget)
                        .collect(Collectors.toList());
                    if (!budgets.isEmpty()) {
                        profile.setAvgBudget(budgets.stream().mapToInt(Integer::intValue).average().orElse(0));
                    }
                    
                    // 스타일 선호도 계산
                    Map<String, Integer> styles = new HashMap<>();
                    for (TravelPlanDTO plan : userPlans) {
                        String style = extractTravelStyle(plan);
                        styles.merge(style, 1, Integer::sum);
                    }
                    profile.setStylePreferences(styles);
                    
                    profiles.put(member.getUserId(), profile);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return profiles;
    }

    /**
     * 두 사용자 프로필 간 유사도 계산
     */
    private double calculateProfileSimilarity(UserTravelProfile profile1, UserTravelProfile profile2) {
        double similarity = 0.0;
        
        // 1. 목적지 선호도 유사도 (코사인 유사도)
        similarity += calculateDestinationPreferenceSimilarity(
            profile1.getDestinationPreferences(), 
            profile2.getDestinationPreferences()
        ) * 0.4;
        
        // 2. 예산 유사도
        if (profile1.getAvgBudget() > 0 && profile2.getAvgBudget() > 0) {
            double budgetRatio = Math.min(profile1.getAvgBudget(), profile2.getAvgBudget()) / 
                               Math.max(profile1.getAvgBudget(), profile2.getAvgBudget());
            similarity += budgetRatio * 0.3;
        }
        
        // 3. 스타일 선호도 유사도
        similarity += calculateStylePreferenceSimilarity(
            profile1.getStylePreferences(),
            profile2.getStylePreferences()
        ) * 0.3;
        
        return similarity;
    }

    /**
     * 목적지 유사도 계산
     */
    private double calculateDestinationSimilarity(List<TravelPlanDTO> plans1, List<TravelPlanDTO> plans2) {
        Set<String> destinations1 = plans1.stream()
            .map(plan -> extractDestinationCategory(plan.getPlanDestination()))
            .collect(Collectors.toSet());
            
        Set<String> destinations2 = plans2.stream()
            .map(plan -> extractDestinationCategory(plan.getPlanDestination()))
            .collect(Collectors.toSet());
        
        Set<String> intersection = new HashSet<>(destinations1);
        intersection.retainAll(destinations2);
        
        Set<String> union = new HashSet<>(destinations1);
        union.addAll(destinations2);
        
        return union.isEmpty() ? 0.0 : (double) intersection.size() / union.size();
    }

    /**
     * 예산 유사도 계산
     */
    private double calculateBudgetSimilarity(List<TravelPlanDTO> plans1, List<TravelPlanDTO> plans2) {
        double avgBudget1 = plans1.stream()
            .filter(plan -> plan.getPlanBudget() != null)
            .mapToInt(TravelPlanDTO::getPlanBudget)
            .average().orElse(0);
            
        double avgBudget2 = plans2.stream()
            .filter(plan -> plan.getPlanBudget() != null)
            .mapToInt(TravelPlanDTO::getPlanBudget)
            .average().orElse(0);
        
        if (avgBudget1 == 0 || avgBudget2 == 0) {
            return 0.0;
        }
        
        return Math.min(avgBudget1, avgBudget2) / Math.max(avgBudget1, avgBudget2);
    }

    /**
     * 여행 스타일 유사도 계산
     */
    private double calculateStyleSimilarity(List<TravelPlanDTO> plans1, List<TravelPlanDTO> plans2) {
        Set<String> styles1 = plans1.stream()
            .map(this::extractTravelStyle)
            .collect(Collectors.toSet());
            
        Set<String> styles2 = plans2.stream()
            .map(this::extractTravelStyle)
            .collect(Collectors.toSet());
        
        Set<String> intersection = new HashSet<>(styles1);
        intersection.retainAll(styles2);
        
        Set<String> union = new HashSet<>(styles1);
        union.addAll(styles2);
        
        return union.isEmpty() ? 0.0 : (double) intersection.size() / union.size();
    }

    /**
     * 여행 기간 유사도 계산
     */
    private double calculateDurationSimilarity(List<TravelPlanDTO> plans1, List<TravelPlanDTO> plans2) {
        double avgDuration1 = plans1.stream()
            .filter(plan -> plan.getPlanStartDate() != null && plan.getPlanEndDate() != null)
            .mapToLong(plan -> java.time.temporal.ChronoUnit.DAYS.between(
                plan.getPlanStartDate().toLocalDate(),
                plan.getPlanEndDate().toLocalDate()) + 1)
            .average().orElse(0);
            
        double avgDuration2 = plans2.stream()
            .filter(plan -> plan.getPlanStartDate() != null && plan.getPlanEndDate() != null)
            .mapToLong(plan -> java.time.temporal.ChronoUnit.DAYS.between(
                plan.getPlanStartDate().toLocalDate(),
                plan.getPlanEndDate().toLocalDate()) + 1)
            .average().orElse(0);
        
        if (avgDuration1 == 0 || avgDuration2 == 0) {
            return 0.0;
        }
        
        return Math.min(avgDuration1, avgDuration2) / Math.max(avgDuration1, avgDuration2);
    }

    /**
     * 목적지 선호도 맵 유사도 계산 (코사인 유사도)
     */
    private double calculateDestinationPreferenceSimilarity(Map<String, Integer> prefs1, Map<String, Integer> prefs2) {
        if (prefs1.isEmpty() || prefs2.isEmpty()) {
            return 0.0;
        }
        
        Set<String> allDestinations = new HashSet<>();
        allDestinations.addAll(prefs1.keySet());
        allDestinations.addAll(prefs2.keySet());
        
        double dotProduct = 0.0;
        double norm1 = 0.0;
        double norm2 = 0.0;
        
        for (String dest : allDestinations) {
            int count1 = prefs1.getOrDefault(dest, 0);
            int count2 = prefs2.getOrDefault(dest, 0);
            
            dotProduct += count1 * count2;
            norm1 += count1 * count1;
            norm2 += count2 * count2;
        }
        
        if (norm1 == 0.0 || norm2 == 0.0) {
            return 0.0;
        }
        
        return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
    }

    /**
     * 스타일 선호도 맵 유사도 계산
     */
    private double calculateStylePreferenceSimilarity(Map<String, Integer> styles1, Map<String, Integer> styles2) {
        if (styles1.isEmpty() || styles2.isEmpty()) {
            return 0.0;
        }
        
        Set<String> allStyles = new HashSet<>();
        allStyles.addAll(styles1.keySet());
        allStyles.addAll(styles2.keySet());
        
        double dotProduct = 0.0;
        double norm1 = 0.0;
        double norm2 = 0.0;
        
        for (String style : allStyles) {
            int count1 = styles1.getOrDefault(style, 0);
            int count2 = styles2.getOrDefault(style, 0);
            
            dotProduct += count1 * count2;
            norm1 += count1 * count1;
            norm2 += count2 * count2;
        }
        
        if (norm1 == 0.0 || norm2 == 0.0) {
            return 0.0;
        }
        
        return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
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
     * 여행 스타일 추출
     */
    private String extractTravelStyle(TravelPlanDTO plan) {
        String content = (plan.getPlanTitle() + " " + plan.getPlanContent() + " " + plan.getPlanTags()).toLowerCase();
        
        if (content.contains("배낭") || content.contains("백패킹")) {
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
     * 사용자 여행 프로필 내부 클래스
     */
    private static class UserTravelProfile {
        private String userId;
        private Map<String, Integer> destinationPreferences;
        private Map<String, Integer> stylePreferences;
        private double avgBudget;
        
        // Getters and Setters
        public String getUserId() { return userId; }
        public void setUserId(String userId) { this.userId = userId; }
        
        public Map<String, Integer> getDestinationPreferences() { return destinationPreferences; }
        public void setDestinationPreferences(Map<String, Integer> destinationPreferences) { 
            this.destinationPreferences = destinationPreferences; 
        }
        
        public Map<String, Integer> getStylePreferences() { return stylePreferences; }
        public void setStylePreferences(Map<String, Integer> stylePreferences) { 
            this.stylePreferences = stylePreferences; 
        }
        
        public double getAvgBudget() { return avgBudget; }
        public void setAvgBudget(double avgBudget) { this.avgBudget = avgBudget; }
    }
}