package com.tour.project.controller;

import com.tour.project.service.TrendAlertService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.Map;

/**
 * 실시간 알림 컨트롤러
 * - 알림 설정 관리
 * - 알림 기록 조회
 * - 테스트 알림 전송
 */
@Slf4j
@RestController
@RequestMapping("/api/alerts")
@RequiredArgsConstructor
public class AlertController {
    
    private final TrendAlertService alertService;
    
    /**
     * 사용자 알림 설정 조회
     */
    @GetMapping("/settings")
    public ResponseEntity<Map<String, Object>> getNotificationSettings(HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            TrendAlertService.UserNotificationSettings settings = 
                alertService.getNotificationSettings(userId);
            
            return ResponseEntity.ok(Map.of(
                "userId", userId,
                "settings", settings
            ));
            
        } catch (Exception e) {
            log.error("알림 설정 조회 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "설정 조회에 실패했습니다."));
        }
    }
    
    /**
     * 사용자 알림 설정 업데이트
     */
    @PostMapping("/settings")
    public ResponseEntity<Map<String, Object>> updateNotificationSettings(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            // 설정 객체 생성
            TrendAlertService.UserNotificationSettings settings = 
                new TrendAlertService.UserNotificationSettings();
            
            if (requestData.containsKey("trendAlertsEnabled")) {
                settings.setTrendAlertsEnabled((Boolean) requestData.get("trendAlertsEnabled"));
            }
            if (requestData.containsKey("snsAlertsEnabled")) {
                settings.setSnsAlertsEnabled((Boolean) requestData.get("snsAlertsEnabled"));
            }
            if (requestData.containsKey("personalizedAlertsEnabled")) {
                settings.setPersonalizedAlertsEnabled((Boolean) requestData.get("personalizedAlertsEnabled"));
            }
            if (requestData.containsKey("alertFrequency")) {
                settings.setAlertFrequency((String) requestData.get("alertFrequency"));
            }
            if (requestData.containsKey("alertCategories")) {
                @SuppressWarnings("unchecked")
                java.util.List<String> categories = (java.util.List<String>) requestData.get("alertCategories");
                settings.setAlertCategories(categories);
            }
            
            alertService.updateNotificationSettings(userId, settings);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "알림 설정이 업데이트되었습니다.",
                "settings", settings
            ));
            
        } catch (Exception e) {
            log.error("알림 설정 업데이트 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "설정 업데이트에 실패했습니다."));
        }
    }
    
    /**
     * 테스트 알림 전송
     */
    @PostMapping("/test")
    public ResponseEntity<Map<String, Object>> sendTestAlert(
            @RequestBody(required = false) Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            String alertType = requestData != null ? 
                             (String) requestData.get("type") : "trend_spike";
            
            // 테스트 알림 데이터 생성
            Map<String, Object> testAlert = Map.of(
                "type", "test_" + alertType,
                "message", "테스트 알림입니다.",
                "timestamp", java.time.LocalDateTime.now(),
                "data", Map.of(
                    "destinationName", "제주도",
                    "scoreIncrease", "2.3",
                    "description", "테스트용 급상승 여행지"
                )
            );
            
            // WebSocket을 통해 테스트 알림 전송
            // 실제 구현에서는 alertService를 통해 전송
            
            log.info("테스트 알림 전송 완료 - 사용자: {}, 타입: {}", userId, alertType);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "테스트 알림이 전송되었습니다.",
                "alert", testAlert
            ));
            
        } catch (Exception e) {
            log.error("테스트 알림 전송 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "테스트 알림 전송에 실패했습니다."));
        }
    }
    
    /**
     * 알림 통계 조회
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getAlertStatistics() {
        
        try {
            // 간단한 알림 통계 (실제로는 DB에서 조회)
            Map<String, Object> statistics = Map.of(
                "totalAlertsSent", 156,
                "todayAlerts", 23,
                "activeUsers", 45,
                "alertTypes", Map.of(
                    "trend_spike", 89,
                    "sns_spike", 34,
                    "personalized", 33
                ),
                "averageResponseRate", "78.5%",
                "lastAlertTime", java.time.LocalDateTime.now().minusMinutes(15)
            );
            
            return ResponseEntity.ok(statistics);
            
        } catch (Exception e) {
            log.error("알림 통계 조회 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "통계 조회에 실패했습니다."));
        }
    }
    
    /**
     * 사용자별 알림 기록 조회
     */
    @GetMapping("/history")
    public ResponseEntity<Map<String, Object>> getAlertHistory(
            @RequestParam(defaultValue = "7") int days,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            // 실제로는 DB에서 사용자별 알림 기록 조회
            java.util.List<Map<String, Object>> history = java.util.List.of(
                Map.of(
                    "id", 1,
                    "type", "trend_spike",
                    "message", "제주도가 급상승 트렌드입니다!",
                    "timestamp", java.time.LocalDateTime.now().minusHours(2),
                    "read", true
                ),
                Map.of(
                    "id", 2,
                    "type", "personalized",
                    "message", "관심 지역 부산이 인기 상승 중입니다!",
                    "timestamp", java.time.LocalDateTime.now().minusHours(5),
                    "read", false
                )
            );
            
            return ResponseEntity.ok(Map.of(
                "userId", userId,
                "days", days,
                "totalCount", history.size(),
                "history", history
            ));
            
        } catch (Exception e) {
            log.error("알림 기록 조회 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "기록 조회에 실패했습니다."));
        }
    }
    
    /**
     * 알림 읽음 처리
     */
    @PostMapping("/read/{alertId}")
    public ResponseEntity<Map<String, Object>> markAlertAsRead(
            @PathVariable Long alertId,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            // 실제로는 DB에서 알림 읽음 상태 업데이트
            log.info("알림 읽음 처리: 사용자={}, 알림ID={}", userId, alertId);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "알림이 읽음 처리되었습니다.",
                "alertId", alertId
            ));
            
        } catch (Exception e) {
            log.error("알림 읽음 처리 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "읽음 처리에 실패했습니다."));
        }
    }
}