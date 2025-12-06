package com.tour.project.controller;

import com.tour.project.service.SocialTrendsService;
import com.tour.project.dto.TrendAnalysisResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.Map;

/**
 * 소셜 트렌드 분석 컨트롤러
 * - Claude API를 활용한 실시간 여행 트렌드 분석
 * - MBTI 기반 맞춤 여행지 추천
 * - SNS 인기도 실시간 분석
 */
@Slf4j
@RestController
@RequestMapping("/api/social-trends")
@RequiredArgsConstructor
public class SocialTrendsController {
    
    private final SocialTrendsService socialTrendsService;
    
    /**
     * 실시간 소셜 트렌드 분석
     */
    @PostMapping("/analyze")
    public ResponseEntity<TrendAnalysisResponse> analyzeTrends(
            @RequestBody(required = false) Map<String, Object> requestData,
            HttpSession session) {
        
        log.info("소셜 트렌드 분석 요청 시작");
        
        try {
            // 사용자 정보 가져오기 (로그인 시)
            String userId = (String) session.getAttribute("userId");
            String userMbti = (String) session.getAttribute("userMbti");
            
            // 요청 데이터에서 MBTI 정보 추출 (우선순위: 요청 > 세션)
            if (requestData != null && requestData.get("mbti") != null) {
                userMbti = (String) requestData.get("mbti");
                log.info("요청에서 MBTI 정보 확인: {}", userMbti);
            }
            
            // Claude API를 통한 실시간 트렌드 분석
            TrendAnalysisResponse response = socialTrendsService.analyzeCurrentTrends(userId, userMbti);
            
            log.info("소셜 트렌드 분석 완료 - 키워드 {}개, 여행지 {}개", 
                    response.getTrendingKeywords() != null ? response.getTrendingKeywords().size() : 0, 
                    response.getPopularDestinations() != null ? response.getPopularDestinations().size() : 0);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            log.error("소셜 트렌드 분석 실패", e);
            
            // 오류 시 기본 응답 반환
            TrendAnalysisResponse fallbackResponse = socialTrendsService.getFallbackResponse();
            return ResponseEntity.ok(fallbackResponse);
        }
    }
    
    /**
     * MBTI 기반 맞춤 여행지 추천
     */
    @PostMapping("/recommendations/mbti")
    public ResponseEntity<Map<String, Object>> getMbtiRecommendations(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        log.info("MBTI 기반 맞춤 추천 요청");
        
        try {
            String userId = (String) session.getAttribute("userId");
            String userMbti = requestData.get("mbti") != null ? 
                            requestData.get("mbti").toString() : 
                            (String) session.getAttribute("userMbti");
            
            if (userMbti == null || userMbti.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "MBTI 정보가 필요합니다."));
            }
            
            Map<String, Object> recommendations = socialTrendsService.getMbtiBasedRecommendations(userMbti, userId);
            
            log.info("MBTI({}) 기반 추천 완료", userMbti);
            
            return ResponseEntity.ok(recommendations);
            
        } catch (Exception e) {
            log.error("MBTI 기반 추천 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "추천 생성 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * SNS 인기도 실시간 분석
     */
    @GetMapping("/popularity")
    public ResponseEntity<Map<String, Object>> getSnsPopularity() {
        
        log.info("SNS 인기도 실시간 분석 요청");
        
        try {
            Map<String, Object> popularityData = socialTrendsService.analyzeSnsPopularity();
            
            log.info("SNS 인기도 분석 완료");
            
            return ResponseEntity.ok(popularityData);
            
        } catch (Exception e) {
            log.error("SNS 인기도 분석 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "SNS 분석 중 오류가 발생했습니다."));
        }
    }
    
    /**
     * Claude API 연결 테스트
     */
    @GetMapping("/test")
    public ResponseEntity<Map<String, Object>> testClaudeApi() {
        log.info("Claude API 연결 테스트 요청");
        
        try {
            String testPrompt = "안녕하세요! 간단한 테스트입니다. '테스트 성공'이라고 답해주세요.";
            String result = socialTrendsService.testClaudeConnection(testPrompt);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "Claude API 연결 성공",
                "response", result
            ));
            
        } catch (Exception e) {
            log.error("Claude API 테스트 실패", e);
            return ResponseEntity.ok(Map.of(
                "status", "error",
                "message", "Claude API 연결 실패: " + e.getMessage()
            ));
        }
    }

    /**
     * 트렌드 예측 데이터
     */
    @GetMapping("/predictions")
    public ResponseEntity<Map<String, Object>> getTrendPredictions() {
        
        log.info("트렌드 예측 데이터 요청");
        
        try {
            Map<String, Object> predictions = socialTrendsService.generateTrendPredictions();
            
            log.info("트렌드 예측 완료");
            
            return ResponseEntity.ok(predictions);
            
        } catch (Exception e) {
            log.error("트렌드 예측 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "예측 생성 중 오류가 발생했습니다."));
        }
    }
}