package com.tour.project.service;

import com.tour.project.dto.TrendAnalysisResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 실시간 알림 서비스
 * - 급상승 여행지 알림
 * - 사용자 맞춤 알림
 * - WebSocket 실시간 푸시
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TrendAlertService {
    
    private final SimpMessagingTemplate messagingTemplate;
    private final SocialTrendsService socialTrendsService;
    private final UserPreferenceLearningService userPreferenceLearningService;
    
    // 이전 트렌드 데이터 저장 (변화 감지용)
    private final Map<String, Double> previousTrendScores = new ConcurrentHashMap<>();
    private final Map<String, Integer> previousMentionCounts = new ConcurrentHashMap<>();
    
    // 사용자 알림 설정
    private final Map<String, UserNotificationSettings> userSettings = new ConcurrentHashMap<>();
    
    // 스케줄러
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(3);
    
    // 알림 임계값
    private static final double TREND_INCREASE_THRESHOLD = 1.5; // 1.5점 이상 증가
    private static final double MENTION_INCREASE_THRESHOLD = 0.3; // 30% 이상 증가
    private static final int MIN_MENTION_COUNT = 100; // 최소 언급량
    
    // 스케줄러 시작을 위한 초기화
    @PostConstruct
    private void init() {
        // 트렌드 모니터링 스케줄러 시작
        startTrendMonitoring();
    }
    
    /**
     * 트렌드 모니터링 스케줄러 시작
     */
    private void startTrendMonitoring() {
        // 급상승 트렌드 모니터링 (15분마다)
        scheduler.scheduleAtFixedRate(this::monitorTrendChanges, 1, 15, TimeUnit.MINUTES);

        // 개인화 알림 모니터링 (30분마다)
        scheduler.scheduleAtFixedRate(this::monitorPersonalizedAlerts, 5, 30, TimeUnit.MINUTES);

        // SNS 급상승 모니터링 (10분마다)
        scheduler.scheduleAtFixedRate(this::monitorSnsSpikes, 3, 10, TimeUnit.MINUTES);
    }

    /**
     * 애플리케이션 종료 시 스케줄러 정리
     */
    @PreDestroy
    public void destroy() {
        log.info("TrendAlertService 종료 중 - 스케줄러 정리 시작");

        try {
            // 새로운 작업 수락 중지
            scheduler.shutdown();

            // 실행 중인 작업이 완료될 때까지 대기 (최대 30초)
            if (!scheduler.awaitTermination(30, TimeUnit.SECONDS)) {
                log.warn("스케줄러가 30초 내에 종료되지 않음 - 강제 종료 시도");

                // 강제 종료
                scheduler.shutdownNow();

                // 강제 종료 후 추가 대기 (최대 10초)
                if (!scheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                    log.error("스케줄러 강제 종료 실패");
                }
            }

            log.info("TrendAlertService 스케줄러 정상 종료 완료");

        } catch (InterruptedException e) {
            log.error("스케줄러 종료 중 인터럽트 발생", e);

            // 인터럽트 발생 시 강제 종료 시도
            scheduler.shutdownNow();

            // 현재 스레드의 인터럽트 상태 복원
            Thread.currentThread().interrupt();
        }
    }
    
    /**
     * 트렌드 변화 모니터링
     */
    private void monitorTrendChanges() {
        try {
            log.info("트렌드 변화 모니터링 시작");
            
            TrendAnalysisResponse currentTrends = socialTrendsService.analyzeCurrentTrends(null, null);
            
            // 키워드 트렌드 분석
            analyzeKeywordTrends(currentTrends.getTrendingKeywords());
            
            // 여행지 트렌드 분석
            analyzeDestinationTrends(currentTrends.getPopularDestinations());
            
        } catch (Exception e) {
            log.error("트렌드 변화 모니터링 중 오류 발생", e);
        }
    }
    
    /**
     * 키워드 트렌드 분석
     */
    private void analyzeKeywordTrends(List<TrendAnalysisResponse.TrendingKeyword> keywords) {
        for (TrendAnalysisResponse.TrendingKeyword keyword : keywords) {
            String key = "keyword_" + keyword.getKeyword();
            
            Double previousScore = previousTrendScores.get(key);
            Integer previousMentions = previousMentionCounts.get(key);
            
            if (previousScore != null && previousMentions != null) {
                double scoreIncrease = keyword.getTrendScore() - previousScore;
                double mentionIncrease = (double) (keyword.getMentionCount() - previousMentions) / previousMentions;
                
                // 급상승 조건 확인
                if (scoreIncrease >= TREND_INCREASE_THRESHOLD && 
                    mentionIncrease >= MENTION_INCREASE_THRESHOLD &&
                    keyword.getMentionCount() >= MIN_MENTION_COUNT) {
                    
                    sendTrendAlert("keyword", keyword.getKeyword(), scoreIncrease, mentionIncrease, 
                                  keyword.getDescription());
                }
            }
            
            // 현재 데이터 저장
            previousTrendScores.put(key, keyword.getTrendScore());
            previousMentionCounts.put(key, keyword.getMentionCount());
        }
    }
    
    /**
     * 여행지 트렌드 분석
     */
    private void analyzeDestinationTrends(List<TrendAnalysisResponse.PopularDestination> destinations) {
        for (TrendAnalysisResponse.PopularDestination destination : destinations) {
            String key = "destination_" + destination.getDestinationName();
            
            Double previousScore = previousTrendScores.get(key);
            Integer previousMentions = previousMentionCounts.get(key);
            
            if (previousScore != null && previousMentions != null) {
                double scoreIncrease = destination.getTrendScore() - previousScore;
                double mentionIncrease = (double) (destination.getMentionCount() - previousMentions) / previousMentions;
                
                // 급상승 조건 확인
                if (scoreIncrease >= TREND_INCREASE_THRESHOLD && 
                    mentionIncrease >= MENTION_INCREASE_THRESHOLD &&
                    destination.getMentionCount() >= MIN_MENTION_COUNT) {
                    
                    sendTrendAlert("destination", destination.getDestinationName(), scoreIncrease, mentionIncrease, 
                                  destination.getDescription());
                }
            }
            
            // 현재 데이터 저장
            previousTrendScores.put(key, destination.getTrendScore());
            previousMentionCounts.put(key, destination.getMentionCount());
        }
    }
    
    /**
     * 개인화 알림 모니터링
     */
    private void monitorPersonalizedAlerts() {
        try {
            log.info("개인화 알림 모니터링 시작");
            
            // 활성 사용자들의 선호도 기반 알림 확인
            Map<String, com.tour.project.dto.UserPreferenceDTO> allPreferences = 
                userPreferenceLearningService.getAllUserPreferences();
            
            for (String userId : allPreferences.keySet()) {
                UserNotificationSettings settings = userSettings.get(userId);
                if (settings != null && settings.isPersonalizedAlertsEnabled()) {
                    checkPersonalizedAlerts(userId, allPreferences.get(userId));
                }
            }
            
        } catch (Exception e) {
            log.error("개인화 알림 모니터링 중 오류 발생", e);
        }
    }
    
    /**
     * SNS 급상승 모니터링
     */
    private void monitorSnsSpikes() {
        try {
            log.info("SNS 급상승 모니터링 시작");
            
            Map<String, Object> snsData = socialTrendsService.analyzeSnsPopularity();
            
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> destinations = 
                (List<Map<String, Object>>) snsData.get("trendingDestinations");
            
            if (destinations != null) {
                for (Map<String, Object> destination : destinations) {
                    analyzeSnsSpike(destination);
                }
            }
            
        } catch (Exception e) {
            log.error("SNS 급상승 모니터링 중 오류 발생", e);
        }
    }
    
    /**
     * SNS 급상승 분석
     */
    private void analyzeSnsSpike(Map<String, Object> destination) {
        String destinationName = (String) destination.get("destinationName");
        Double changeRate = (Double) destination.get("changeRate");
        
        if (changeRate != null && changeRate >= 20.0) { // 20% 이상 증가
            sendSnsAlert(destinationName, changeRate, destination);
        }
    }
    
    /**
     * 개인화 알림 확인
     */
    private void checkPersonalizedAlerts(String userId, com.tour.project.dto.UserPreferenceDTO preference) {
        try {
            // 사용자 선호 지역이 급상승하는지 확인
            for (String region : preference.getPreferredRegions()) {
                if (isRegionTrending(region)) {
                    sendPersonalizedAlert(userId, "region", region, 
                        "관심 지역 " + region + "이(가) 현재 급상승 트렌드입니다!");
                }
            }
            
            // 사용자 선호 활동이 인기인지 확인
            for (String activity : preference.getPreferredActivities()) {
                if (isActivityTrending(activity)) {
                    sendPersonalizedAlert(userId, "activity", activity, 
                        "선호하는 활동 " + activity + "이(가) 현재 인기 상승 중입니다!");
                }
            }
            
        } catch (Exception e) {
            log.error("개인화 알림 확인 중 오류 발생: {}", userId, e);
        }
    }
    
    /**
     * 트렌드 알림 전송
     */
    private void sendTrendAlert(String type, String name, double scoreIncrease, double mentionIncrease, String description) {
        Map<String, Object> alert = new HashMap<>();
        alert.put("type", "trend_spike");
        alert.put("category", type);
        alert.put("name", name);
        alert.put("scoreIncrease", String.format("%.1f", scoreIncrease));
        alert.put("mentionIncrease", String.format("%.1f%%", mentionIncrease * 100));
        alert.put("description", description);
        alert.put("timestamp", LocalDateTime.now());
        alert.put("severity", getSeverity(scoreIncrease, mentionIncrease));
        
        // 전체 사용자에게 브로드캐스트
        messagingTemplate.convertAndSend("/topic/alerts", alert);
        
        log.info("트렌드 급상승 알림 전송: {} - {}", type, name);
    }
    
    /**
     * SNS 알림 전송
     */
    private void sendSnsAlert(String destinationName, double changeRate, Map<String, Object> data) {
        Map<String, Object> alert = new HashMap<>();
        alert.put("type", "sns_spike");
        alert.put("destinationName", destinationName);
        alert.put("changeRate", String.format("%.1f%%", changeRate));
        alert.put("data", data);
        alert.put("timestamp", LocalDateTime.now());
        alert.put("message", destinationName + "이(가) SNS에서 " + String.format("%.1f%%", changeRate) + " 급상승!");
        
        // 전체 사용자에게 브로드캐스트
        messagingTemplate.convertAndSend("/topic/sns-alerts", alert);
        
        log.info("SNS 급상승 알림 전송: {} - {}%", destinationName, changeRate);
    }
    
    /**
     * 개인화 알림 전송
     */
    private void sendPersonalizedAlert(String userId, String category, String item, String message) {
        Map<String, Object> alert = new HashMap<>();
        alert.put("type", "personalized");
        alert.put("category", category);
        alert.put("item", item);
        alert.put("message", message);
        alert.put("timestamp", LocalDateTime.now());
        
        // 특정 사용자에게 전송
        messagingTemplate.convertAndSendToUser(userId, "/queue/alerts", alert);
        
        log.info("개인화 알림 전송: {} - {}", userId, message);
    }
    
    /**
     * 알림 설정 업데이트
     */
    public void updateNotificationSettings(String userId, UserNotificationSettings settings) {
        userSettings.put(userId, settings);
        log.info("사용자({}) 알림 설정 업데이트 완료", userId);
    }
    
    /**
     * 알림 설정 조회
     */
    public UserNotificationSettings getNotificationSettings(String userId) {
        return userSettings.getOrDefault(userId, new UserNotificationSettings());
    }
    
    /**
     * 심각도 계산
     */
    private String getSeverity(double scoreIncrease, double mentionIncrease) {
        if (scoreIncrease >= 3.0 || mentionIncrease >= 0.5) {
            return "high";
        } else if (scoreIncrease >= 2.0 || mentionIncrease >= 0.4) {
            return "medium";
        } else {
            return "low";
        }
    }
    
    /**
     * 지역 트렌드 확인 (간단한 구현)
     */
    private boolean isRegionTrending(String region) {
        // 실제로는 더 정교한 로직 필요
        return previousTrendScores.entrySet().stream()
            .anyMatch(entry -> entry.getKey().contains(region) && entry.getValue() > 8.0);
    }
    
    /**
     * 활동 트렌드 확인 (간단한 구현)
     */
    private boolean isActivityTrending(String activity) {
        // 실제로는 더 정교한 로직 필요
        return previousTrendScores.entrySet().stream()
            .anyMatch(entry -> entry.getKey().contains(activity) && entry.getValue() > 7.5);
    }
    
    /**
     * 사용자 알림 설정 클래스
     */
    public static class UserNotificationSettings {
        private boolean trendAlertsEnabled = true;
        private boolean snsAlertsEnabled = true;
        private boolean personalizedAlertsEnabled = true;
        private String alertFrequency = "realtime"; // realtime, hourly, daily
        private List<String> alertCategories = List.of("destination", "activity", "food");
        
        // Getters and Setters
        public boolean isTrendAlertsEnabled() { return trendAlertsEnabled; }
        public void setTrendAlertsEnabled(boolean trendAlertsEnabled) { this.trendAlertsEnabled = trendAlertsEnabled; }
        
        public boolean isSnsAlertsEnabled() { return snsAlertsEnabled; }
        public void setSnsAlertsEnabled(boolean snsAlertsEnabled) { this.snsAlertsEnabled = snsAlertsEnabled; }
        
        public boolean isPersonalizedAlertsEnabled() { return personalizedAlertsEnabled; }
        public void setPersonalizedAlertsEnabled(boolean personalizedAlertsEnabled) { this.personalizedAlertsEnabled = personalizedAlertsEnabled; }
        
        public String getAlertFrequency() { return alertFrequency; }
        public void setAlertFrequency(String alertFrequency) { this.alertFrequency = alertFrequency; }
        
        public List<String> getAlertCategories() { return alertCategories; }
        public void setAlertCategories(List<String> alertCategories) { this.alertCategories = alertCategories; }
    }
}