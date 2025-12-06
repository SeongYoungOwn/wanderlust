package com.tour.project.controller;

import com.tour.project.service.TravelPlanTrendIntegrationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.Map;

/**
 * 여행 계획과 트렌드 분석 연동 컨트롤러
 * - 트렌드 기반 여행 계획 최적화
 * - 실시간 일정 조정
 * - AI 기반 추천 서비스
 */
@Slf4j
@RestController
@RequestMapping("/api/travel-plan-integration")
@RequiredArgsConstructor
public class TravelPlanIntegrationController {
    
    private final TravelPlanTrendIntegrationService integrationService;
    
    /**
     * 트렌드 기반 여행 계획 최적화
     */
    @PostMapping("/optimize")
    public ResponseEntity<Map<String, Object>> optimizeTravelPlan(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                userId = "guest_" + System.currentTimeMillis();
                session.setAttribute("userId", userId);
            }
            
            @SuppressWarnings("unchecked")
            Map<String, Object> travelPlan = (Map<String, Object>) requestData.get("travelPlan");
            
            if (travelPlan == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "여행 계획 데이터가 필요합니다."));
            }
            
            Map<String, Object> optimizedPlan = 
                integrationService.optimizeTravelPlanWithTrends(userId, travelPlan);
            
            log.info("사용자({}) 여행 계획 최적화 완료", userId);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "userId", userId,
                "optimizedPlan", optimizedPlan,
                "optimizedAt", java.time.LocalDateTime.now()
            ));
            
        } catch (Exception e) {
            log.error("여행 계획 최적화 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "최적화에 실패했습니다."));
        }
    }
    
    /**
     * 실시간 트렌드 기반 일정 조정
     */
    @PostMapping("/adjust-schedule")
    public ResponseEntity<Map<String, Object>> adjustSchedule(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            @SuppressWarnings("unchecked")
            Map<String, Object> currentSchedule = (Map<String, Object>) requestData.get("schedule");
            
            if (currentSchedule == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "현재 일정 데이터가 필요합니다."));
            }
            
            Map<String, Object> adjustedSchedule = 
                integrationService.adjustScheduleByTrends(userId, currentSchedule);
            
            log.info("사용자({}) 일정 조정 완료", userId);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "adjustedSchedule", adjustedSchedule,
                "adjustedAt", java.time.LocalDateTime.now()
            ));
            
        } catch (Exception e) {
            log.error("일정 조정 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "일정 조정에 실패했습니다."));
        }
    }
    
    /**
     * AI 기반 여행 경로 추천
     */
    @PostMapping("/recommend-route")
    public ResponseEntity<Map<String, Object>> recommendRoute(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            @SuppressWarnings("unchecked")
            Map<String, Object> destinations = (Map<String, Object>) requestData.get("destinations");
            
            if (destinations == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "여행지 정보가 필요합니다."));
            }
            
            Map<String, Object> routeRecommendation = 
                integrationService.recommendTravelRoute(userId, destinations);
            
            log.info("사용자({}) 여행 경로 추천 완료", userId);
            
            return ResponseEntity.ok(routeRecommendation);
            
        } catch (Exception e) {
            log.error("여행 경로 추천 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "경로 추천에 실패했습니다."));
        }
    }
    
    /**
     * 트렌드 기반 숙박 추천
     */
    @PostMapping("/recommend-accommodation")
    public ResponseEntity<Map<String, Object>> recommendAccommodation(
            @RequestBody Map<String, Object> requestData) {
        
        try {
            String destination = (String) requestData.get("destination");
            @SuppressWarnings("unchecked")
            Map<String, Object> preferences = (Map<String, Object>) requestData.get("preferences");
            
            if (destination == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "목적지 정보가 필요합니다."));
            }
            
            Map<String, Object> accommodationRecommendation = 
                integrationService.recommendAccommodationByTrends(destination, preferences != null ? preferences : Map.of());
            
            log.info("숙박 추천 완료 - 목적지: {}", destination);
            
            return ResponseEntity.ok(accommodationRecommendation);
            
        } catch (Exception e) {
            log.error("숙박 추천 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "숙박 추천에 실패했습니다."));
        }
    }
    
    /**
     * 트렌드 기반 활동 추천
     */
    @PostMapping("/recommend-activities")
    public ResponseEntity<Map<String, Object>> recommendActivities(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String destination = (String) requestData.get("destination");
            String season = (String) requestData.get("season");
            
            if (destination == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "목적지 정보가 필요합니다."));
            }
            
            // 사용자 프로필 구성
            String userId = (String) session.getAttribute("userId");
            Map<String, Object> userProfile = Map.of(
                "userId", userId != null ? userId : "guest",
                "preferences", requestData.getOrDefault("preferences", Map.of())
            );
            
            Map<String, Object> activitiesRecommendation = 
                integrationService.recommendActivitiesByTrends(
                    destination, 
                    season != null ? season : getCurrentSeason(), 
                    userProfile
                );
            
            log.info("활동 추천 완료 - 목적지: {}, 계절: {}", destination, season);
            
            return ResponseEntity.ok(activitiesRecommendation);
            
        } catch (Exception e) {
            log.error("활동 추천 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "활동 추천에 실패했습니다."));
        }
    }
    
    /**
     * 예산 최적화 추천
     */
    @PostMapping("/optimize-budget")
    public ResponseEntity<Map<String, Object>> optimizeBudget(
            @RequestBody Map<String, Object> requestData) {
        
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> travelPlan = (Map<String, Object>) requestData.get("travelPlan");
            Object budgetObj = requestData.get("totalBudget");
            
            if (travelPlan == null || budgetObj == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "여행 계획과 예산 정보가 필요합니다."));
            }
            
            double totalBudget;
            if (budgetObj instanceof Number) {
                totalBudget = ((Number) budgetObj).doubleValue();
            } else {
                totalBudget = Double.parseDouble(budgetObj.toString());
            }
            
            Map<String, Object> budgetOptimization = 
                integrationService.optimizeBudgetWithTrends(travelPlan, totalBudget);
            
            log.info("예산 최적화 완료 - 총 예산: {}", totalBudget);
            
            return ResponseEntity.ok(budgetOptimization);
            
        } catch (Exception e) {
            log.error("예산 최적화 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "예산 최적화에 실패했습니다."));
        }
    }
    
    /**
     * 종합 여행 계획 추천
     */
    @PostMapping("/comprehensive-recommendation")
    public ResponseEntity<Map<String, Object>> getComprehensiveRecommendation(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                userId = "guest_" + System.currentTimeMillis();
                session.setAttribute("userId", userId);
            }
            
            String destination = (String) requestData.get("destination");
            String season = (String) requestData.get("season");
            Object budgetObj = requestData.get("budget");
            Integer days = (Integer) requestData.get("days");
            
            if (destination == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "목적지 정보가 필요합니다."));
            }
            
            // 기본 여행 계획 생성
            Map<String, Object> basicPlan = Map.of(
                "destination", destination,
                "season", season != null ? season : getCurrentSeason(),
                "days", days != null ? days : 3,
                "budget", budgetObj != null ? budgetObj : 500000
            );
            
            // 여러 추천 서비스 통합 호출
            Map<String, Object> comprehensiveRecommendation = Map.of(
                "optimizedPlan", integrationService.optimizeTravelPlanWithTrends(userId, basicPlan),
                "activities", integrationService.recommendActivitiesByTrends(destination, season, Map.of("userId", userId)),
                "accommodation", integrationService.recommendAccommodationByTrends(destination, Map.of()),
                "budget", budgetObj != null ? 
                    integrationService.optimizeBudgetWithTrends(basicPlan, ((Number) budgetObj).doubleValue()) : 
                    Map.of("message", "예산 정보가 제공되지 않았습니다."),
                "generatedAt", java.time.LocalDateTime.now()
            );
            
            log.info("사용자({}) 종합 여행 계획 추천 완료", userId);
            
            return ResponseEntity.ok(comprehensiveRecommendation);
            
        } catch (Exception e) {
            log.error("종합 여행 계획 추천 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "종합 추천에 실패했습니다."));
        }
    }
    
    /**
     * 현재 계절 확인
     */
    private String getCurrentSeason() {
        int month = java.time.LocalDateTime.now().getMonthValue();
        if (month >= 3 && month <= 5) return "봄";
        if (month >= 6 && month <= 8) return "여름";
        if (month >= 9 && month <= 11) return "가을";
        return "겨울";
    }
}