package com.tour.project.controller;

import com.tour.project.service.UserPreferenceLearningService;
import com.tour.project.dto.UserPreferenceDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.Map;

/**
 * 사용자 선호도 학습 컨트롤러
 * - 사용자 상호작용 기록
 * - 개인화 추천 생성
 * - 선호도 분석 리포트
 */
@Slf4j
@RestController
@RequestMapping("/api/user-preference")
@RequiredArgsConstructor
public class UserPreferenceController {
    
    private final UserPreferenceLearningService userPreferenceLearningService;
    
    /**
     * 사용자 상호작용 기록
     */
    @PostMapping("/interaction")
    public ResponseEntity<Map<String, Object>> recordInteraction(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                userId = "guest_" + System.currentTimeMillis(); // 비로그인 사용자 임시 ID
                session.setAttribute("userId", userId);
            }
            
            String interactionType = (String) requestData.get("type");
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) requestData.get("data");
            
            userPreferenceLearningService.recordUserInteraction(userId, interactionType, data);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "상호작용이 기록되었습니다.",
                "userId", userId
            ));
            
        } catch (Exception e) {
            log.error("상호작용 기록 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "상호작용 기록에 실패했습니다."));
        }
    }
    
    /**
     * 개인화 추천 생성
     */
    @PostMapping("/recommendations")
    public ResponseEntity<Map<String, Object>> getPersonalizedRecommendations(
            @RequestBody(required = false) Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            String context = requestData != null ? 
                            (String) requestData.get("context") : "일반적인 여행 추천";
            
            Map<String, Object> recommendations = 
                userPreferenceLearningService.generatePersonalizedRecommendations(userId, context);
            
            log.info("사용자({}) 개인화 추천 생성 완료", userId);
            
            return ResponseEntity.ok(recommendations);
            
        } catch (Exception e) {
            log.error("개인화 추천 생성 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "추천 생성에 실패했습니다."));
        }
    }
    
    /**
     * 사용자 선호도 분석 리포트
     */
    @GetMapping("/analysis")
    public ResponseEntity<Map<String, Object>> getPreferenceAnalysis(HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            Map<String, Object> analysis = 
                userPreferenceLearningService.generatePreferenceAnalysis(userId);
            
            return ResponseEntity.ok(analysis);
            
        } catch (Exception e) {
            log.error("선호도 분석 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "분석에 실패했습니다."));
        }
    }
    
    /**
     * 사용자 선호도 데이터 조회
     */
    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getUserProfile(HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            UserPreferenceDTO preference = userPreferenceLearningService.getUserPreference(userId);
            if (preference == null) {
                return ResponseEntity.ok(Map.of(
                    "message", "선호도 데이터가 없습니다.",
                    "hasData", false
                ));
            }
            
            return ResponseEntity.ok(Map.of(
                "hasData", true,
                "profile", preference
            ));
            
        } catch (Exception e) {
            log.error("사용자 프로필 조회 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "프로필 조회에 실패했습니다."));
        }
    }
    
    /**
     * 추천 피드백 제출
     */
    @PostMapping("/feedback")
    public ResponseEntity<Map<String, Object>> submitFeedback(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = (String) session.getAttribute("userId");
            if (userId == null) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "사용자 정보가 필요합니다."));
            }
            
            // 피드백을 상호작용으로 기록
            userPreferenceLearningService.recordUserInteraction(userId, "recommendation_feedback", requestData);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "피드백이 기록되었습니다."
            ));
            
        } catch (Exception e) {
            log.error("피드백 제출 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "피드백 제출에 실패했습니다."));
        }
    }
    
    /**
     * 관리자용 - 모든 사용자 선호도 조회
     */
    @GetMapping("/admin/all")
    public ResponseEntity<Map<String, Object>> getAllUserPreferences(HttpSession session) {
        
        try {
            // 실제 환경에서는 관리자 권한 확인 필요
            Map<String, UserPreferenceDTO> allPreferences = 
                userPreferenceLearningService.getAllUserPreferences();
            
            return ResponseEntity.ok(Map.of(
                "totalUsers", allPreferences.size(),
                "preferences", allPreferences
            ));
            
        } catch (Exception e) {
            log.error("전체 사용자 선호도 조회 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "조회에 실패했습니다."));
        }
    }
}