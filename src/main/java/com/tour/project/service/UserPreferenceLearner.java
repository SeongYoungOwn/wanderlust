package com.tour.project.service;

import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Component
public class UserPreferenceLearner {

    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private MemberDAO memberDAO;

    /**
     * 사용자의 과거 행동 패턴을 학습하여 선호도 모델 생성
     */
    public UserPreferenceModel learnUserPreferences(Long userId) {
        UserPreferenceModel model = new UserPreferenceModel(userId);
        
        try {
            // 1. 과거 여행 이력 분석
            List<TravelPlanDTO> userPlans = travelPlanDAO.getTravelPlansByWriter(String.valueOf(userId));
            analyzeUserTravelHistory(model, userPlans);
            
            // 2. 사용자의 개인화된 가중치 계산
            Map<String, Double> personalizedWeights = calculatePersonalizedWeights(model, userPlans);
            model.setPersonalizedWeights(personalizedWeights);
            
            // 3. 협업 필터링을 위한 유사 사용자 분석
            Double collaborativeScore = calculateCollaborativeScore(userId);
            model.setCollaborativeScore(collaborativeScore);
            
            model.setLastUpdated(LocalDateTime.now());
            
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 기본 모델 반환
            return getDefaultModel(userId);
        }
        
        return model;
    }

    /**
     * 사용자 여행 이력 분석
     */
    private void analyzeUserTravelHistory(UserPreferenceModel model, List<TravelPlanDTO> userPlans) {
        if (userPlans.isEmpty()) {
            setDefaultPreferences(model);
            return;
        }

        // 목적지 선호도 분석
        Map<String, Double> destinationPrefs = new HashMap<>();
        Map<String, Integer> destinationCount = new HashMap<>();
        
        // 여행 스타일 선호도 분석  
        Map<String, Double> stylePrefs = new HashMap<>();
        Map<String, Integer> styleCount = new HashMap<>();
        
        // 예산 범위 분석
        List<Integer> budgets = new ArrayList<>();
        
        // 여행 기간 분석
        List<Integer> durations = new ArrayList<>();

        for (TravelPlanDTO plan : userPlans) {
            // 목적지 분석
            String destination = extractDestinationCategory(plan.getPlanDestination());
            destinationCount.merge(destination, 1, Integer::sum);
            
            // 스타일 분석 (태그에서 추출)
            if (plan.getPlanTags() != null && !plan.getPlanTags().isEmpty()) {
                String style = extractStyleFromTags(plan.getPlanTags());
                if (!style.isEmpty()) {
                    styleCount.merge(style, 1, Integer::sum);
                }
            }
            
            // 예산 분석
            if (plan.getPlanBudget() != null && plan.getPlanBudget() > 0) {
                budgets.add(plan.getPlanBudget());
            }
            
            // 기간 분석
            if (plan.getPlanStartDate() != null && plan.getPlanEndDate() != null) {
                long days = ChronoUnit.DAYS.between(
                    plan.getPlanStartDate().toLocalDate(), 
                    plan.getPlanEndDate().toLocalDate()
                ) + 1;
                durations.add((int) days);
            }
        }

        // 선호도 점수 계산 (빈도 기반)
        int totalPlans = userPlans.size();
        destinationCount.forEach((dest, count) -> 
            destinationPrefs.put(dest, (double) count / totalPlans * 100));
        styleCount.forEach((style, count) -> 
            stylePrefs.put(style, (double) count / totalPlans * 100));

        model.setDestinationPreferences(destinationPrefs);
        model.setStylePreferences(stylePrefs);

        // 평균 예산 및 기간 계산
        if (!budgets.isEmpty()) {
            model.setAvgBudget(budgets.stream().mapToInt(Integer::intValue).average().orElse(0.0));
        }
        if (!durations.isEmpty()) {
            model.setAvgDurationDays(durations.stream().mapToInt(Integer::intValue).sum() / durations.size());
        }

        // 선호 목적지 리스트 생성 (상위 3개)
        List<String> favoriteDestinations = destinationPrefs.entrySet().stream()
            .sorted(Map.Entry.<String, Double>comparingByValue().reversed())
            .limit(3)
            .map(Map.Entry::getKey)
            .collect(Collectors.toList());
        model.setFavoriteDestinations(favoriteDestinations);
    }

    /**
     * 학습된 모델로 개인화 가중치 동적 조정
     */
    public Map<String, Double> getPersonalizedWeights(UserPreferenceModel model) {
        Map<String, Double> weights = new HashMap<>();
        
        // 기본 가중치
        weights.put("destination", 0.3);
        weights.put("budget", 0.25);
        weights.put("duration", 0.2);
        weights.put("style", 0.15);
        weights.put("mbti", 0.1);
        
        // 사용자 선호도에 따른 가중치 조정
        if (model.getDestinationPreferences() != null && !model.getDestinationPreferences().isEmpty()) {
            // 목적지 선호도가 강할 경우 가중치 증가
            double maxDestPref = model.getDestinationPreferences().values().stream()
                .mapToDouble(Double::doubleValue).max().orElse(0);
            if (maxDestPref > 70) {
                weights.put("destination", 0.4);
                weights.put("budget", 0.2);
            }
        }
        
        if (model.getAvgBudget() != null) {
            // 예산 일관성이 높을 경우
            if (model.getAvgBudget() > 1000000) { // 고예산 사용자
                weights.put("budget", 0.3);
                weights.put("style", 0.2);
            }
        }
        
        return weights;
    }

    /**
     * 개인화된 가중치 계산
     */
    private Map<String, Double> calculatePersonalizedWeights(UserPreferenceModel model, List<TravelPlanDTO> userPlans) {
        Map<String, Double> weights = new HashMap<>();
        
        // 기본 가중치 설정
        weights.put("basic_matching", 0.4);
        weights.put("personalization", 0.3);
        weights.put("collaborative", 0.2);
        weights.put("time_weight", 0.1);
        
        // 사용자 이력 기반 조정
        if (userPlans.size() >= 3) {
            // 경험 많은 사용자는 개인화 가중치 증가
            weights.put("personalization", 0.35);
            weights.put("basic_matching", 0.35);
        }
        
        if (userPlans.size() >= 10) {
            // 매우 경험 많은 사용자는 협업 필터링 가중치 증가
            weights.put("collaborative", 0.25);
            weights.put("personalization", 0.4);
            weights.put("basic_matching", 0.25);
        }
        
        return weights;
    }

    /**
     * 협업 필터링 점수 계산
     */
    private Double calculateCollaborativeScore(Long userId) {
        try {
            // 모든 사용자의 여행 패턴 분석하여 유사도 계산
            List<MemberDTO> allUsers = memberDAO.getAllMembers();
            List<TravelPlanDTO> userPlans = travelPlanDAO.getTravelPlansByWriter(String.valueOf(userId));
            
            if (userPlans.isEmpty() || allUsers.size() < 5) {
                return 50.0; // 기본 점수
            }
            
            double totalSimilarity = 0.0;
            int similarUserCount = 0;
            
            for (MemberDTO otherUser : allUsers) {
                if (otherUser.getUserId().equals(userId)) continue;
                
                List<TravelPlanDTO> otherPlans = travelPlanDAO.getTravelPlansByWriter(otherUser.getUserId());
                if (otherPlans.isEmpty()) continue;
                
                double similarity = calculateUserSimilarity(userPlans, otherPlans);
                if (similarity > 0.3) { // 30% 이상 유사한 사용자만 고려
                    totalSimilarity += similarity;
                    similarUserCount++;
                }
            }
            
            return similarUserCount > 0 ? (totalSimilarity / similarUserCount) * 100 : 50.0;
            
        } catch (Exception e) {
            return 50.0; // 에러 시 기본 점수
        }
    }

    /**
     * 두 사용자 간 유사도 계산
     */
    private double calculateUserSimilarity(List<TravelPlanDTO> userPlans, List<TravelPlanDTO> otherPlans) {
        // 목적지 유사도
        Set<String> userDestinations = userPlans.stream()
            .map(plan -> extractDestinationCategory(plan.getPlanDestination()))
            .collect(Collectors.toSet());
        
        Set<String> otherDestinations = otherPlans.stream()
            .map(plan -> extractDestinationCategory(plan.getPlanDestination()))
            .collect(Collectors.toSet());
        
        Set<String> commonDestinations = new HashSet<>(userDestinations);
        commonDestinations.retainAll(otherDestinations);
        
        double destinationSimilarity = userDestinations.isEmpty() ? 0 : 
            (double) commonDestinations.size() / Math.max(userDestinations.size(), otherDestinations.size());
        
        // 예산 유사도
        double avgUserBudget = userPlans.stream()
            .filter(plan -> plan.getPlanBudget() != null && plan.getPlanBudget() > 0)
            .mapToInt(TravelPlanDTO::getPlanBudget)
            .average().orElse(0);
        
        double avgOtherBudget = otherPlans.stream()
            .filter(plan -> plan.getPlanBudget() != null && plan.getPlanBudget() > 0)
            .mapToInt(TravelPlanDTO::getPlanBudget)
            .average().orElse(0);
        
        double budgetSimilarity = 0;
        if (avgUserBudget > 0 && avgOtherBudget > 0) {
            double budgetDiff = Math.abs(avgUserBudget - avgOtherBudget) / Math.max(avgUserBudget, avgOtherBudget);
            budgetSimilarity = 1.0 - budgetDiff;
        }
        
        // 가중 평균으로 최종 유사도 계산
        return destinationSimilarity * 0.6 + budgetSimilarity * 0.4;
    }

    /**
     * 목적지 카테고리 추출
     */
    private String extractDestinationCategory(String destination) {
        if (destination == null) return "기타";
        
        String dest = destination.toLowerCase();
        if (dest.contains("일본") || dest.contains("도쿄") || dest.contains("오사카") || dest.contains("교토")) {
            return "일본";
        } else if (dest.contains("태국") || dest.contains("베트남") || dest.contains("동남아") || dest.contains("방콕")) {
            return "동남아";
        } else if (dest.contains("유럽") || dest.contains("프랑스") || dest.contains("독일") || dest.contains("이탈리아")) {
            return "유럽";
        } else if (dest.contains("제주") || dest.contains("부산") || dest.contains("서울") || dest.contains("국내")) {
            return "국내";
        } else {
            return "기타";
        }
    }

    /**
     * 태그에서 여행 스타일 추출
     */
    private String extractStyleFromTags(String tags) {
        if (tags == null) return "";
        
        String lowerTags = tags.toLowerCase();
        if (lowerTags.contains("배낭") || lowerTags.contains("백패킹") || lowerTags.contains("자유")) {
            return "배낭여행";
        } else if (lowerTags.contains("휴양") || lowerTags.contains("힐링")) {
            return "휴양";
        } else if (lowerTags.contains("모험") || lowerTags.contains("액티비티")) {
            return "모험";
        } else if (lowerTags.contains("문화") || lowerTags.contains("역사")) {
            return "문화";
        }
        return "";
    }

    /**
     * 기본 선호도 설정
     */
    private void setDefaultPreferences(UserPreferenceModel model) {
        Map<String, Double> defaultDestinations = Map.of(
            "일본", 25.0,
            "동남아", 25.0,
            "유럽", 25.0,
            "국내", 25.0
        );
        
        Map<String, Double> defaultStyles = Map.of(
            "자유여행", 30.0,
            "휴양", 25.0,
            "문화", 25.0,
            "모험", 20.0
        );
        
        model.setDestinationPreferences(defaultDestinations);
        model.setStylePreferences(defaultStyles);
        model.setAvgBudget(500000.0);
        model.setAvgDurationDays(4);
        model.setFavoriteDestinations(List.of("일본", "동남아", "유럽"));
    }

    /**
     * 기본 모델 반환
     */
    private UserPreferenceModel getDefaultModel(Long userId) {
        UserPreferenceModel model = new UserPreferenceModel(userId);
        setDefaultPreferences(model);
        
        Map<String, Double> defaultWeights = Map.of(
            "basic_matching", 0.5,
            "personalization", 0.2,
            "collaborative", 0.2,
            "time_weight", 0.1
        );
        model.setPersonalizedWeights(defaultWeights);
        model.setCollaborativeScore(50.0);
        model.setLastUpdated(LocalDateTime.now());
        
        return model;
    }
}