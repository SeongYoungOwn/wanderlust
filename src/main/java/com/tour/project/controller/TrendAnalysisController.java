package com.tour.project.controller;

import com.tour.project.dto.trend.TrendAnalysisResponseDTO;
import com.tour.project.service.TrendAnalysisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

/**
 * 소셜 트렌드 분석 컨트롤러
 */
@Slf4j
@Controller
@RequestMapping("/trend")
@RequiredArgsConstructor
public class TrendAnalysisController {
    
    private final TrendAnalysisService trendAnalysisService;
    
    /**
     * 1단계: 급상승 여행지 분석
     */
    @PostMapping("/popular-destinations")
    @ResponseBody
    public ResponseEntity<TrendAnalysisResponseDTO.PopularDestinationsResponse> getPopularDestinations(
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            log.info("급상승 여행지 분석 요청 - 사용자: {}", userId);
            
            // 급상승 여행지 분석
            TrendAnalysisResponseDTO.PopularDestinationsResponse response = 
                trendAnalysisService.analyzePopularDestinations(userId);
            
            if (response.isSuccess()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            log.error("급상승 여행지 분석 실패", e);
            
            TrendAnalysisResponseDTO.PopularDestinationsResponse errorResponse = 
                TrendAnalysisResponseDTO.PopularDestinationsResponse.builder()
                    .success(false)
                    .message("급상승 여행지 분석 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * 2단계: MBTI 기반 맞춤 추천
     */
    @PostMapping("/mbti-recommendations")
    @ResponseBody
    public ResponseEntity<TrendAnalysisResponseDTO.MBTIRecommendationResponse> getMBTIRecommendations(
            @RequestParam(required = false) String mbtiType,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            log.info("MBTI 맞춤 추천 요청 - 사용자: {}, MBTI: {}", userId, mbtiType);
            
            // MBTI 기반 추천
            TrendAnalysisResponseDTO.MBTIRecommendationResponse response = 
                trendAnalysisService.getMBTIRecommendations(userId, mbtiType);
            
            if (response.isSuccess()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            log.error("MBTI 맞춤 추천 실패", e);
            
            TrendAnalysisResponseDTO.MBTIRecommendationResponse errorResponse = 
                TrendAnalysisResponseDTO.MBTIRecommendationResponse.builder()
                    .success(false)
                    .message("MBTI 맞춤 추천 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * 3단계: 지역별 인기도 분석
     */
    @PostMapping("/region-popularity")
    @ResponseBody
    public ResponseEntity<TrendAnalysisResponseDTO.RegionPopularityResponse> getRegionPopularity(
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            log.info("지역별 인기도 분석 요청 - 사용자: {}", userId);
            
            // 지역별 인기도 분석
            TrendAnalysisResponseDTO.RegionPopularityResponse response = 
                trendAnalysisService.analyzeRegionPopularity(userId);
            
            if (response.isSuccess()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            log.error("지역별 인기도 분석 실패", e);
            
            TrendAnalysisResponseDTO.RegionPopularityResponse errorResponse = 
                TrendAnalysisResponseDTO.RegionPopularityResponse.builder()
                    .success(false)
                    .message("지역별 인기도 분석 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * 4단계: 종합 분석 결과
     */
    @PostMapping("/comprehensive-analysis")
    @ResponseBody
    public ResponseEntity<TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse> getComprehensiveAnalysis(
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            log.info("종합 분석 요청 - 사용자: {}", userId);
            
            // 종합 분석 결과
            TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse response = 
                trendAnalysisService.generateComprehensiveAnalysis(userId);
            
            if (response.isSuccess()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            log.error("종합 분석 실패", e);
            
            TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse errorResponse = 
                TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse.builder()
                    .success(false)
                    .message("종합 분석 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * 전체 트렌드 분석 (4단계 순차 실행)
     */
    @PostMapping("/analyze")
    @ResponseBody
    public ResponseEntity<TrendAnalysisResponseDTO.FullAnalysisResponse> analyzeFullTrends(
            @RequestParam(required = false) String mbtiType,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            log.info("전체 트렌드 분석 요청 - 사용자: {}, MBTI: {}", userId, mbtiType);
            
            // 전체 분석 실행
            TrendAnalysisResponseDTO.FullAnalysisResponse response = 
                trendAnalysisService.executeFullAnalysis(userId, mbtiType);
            
            if (response.isSuccess()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            log.error("전체 트렌드 분석 실패", e);
            
            TrendAnalysisResponseDTO.FullAnalysisResponse errorResponse = 
                TrendAnalysisResponseDTO.FullAnalysisResponse.builder()
                    .success(false)
                    .message("트렌드 분석 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * 분석 상태 확인
     */
    @GetMapping("/status")
    @ResponseBody
    public ResponseEntity<Object> getAnalysisStatus(HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            boolean hasAnalysisData = trendAnalysisService.hasAnalysisData(userId);
            
            return ResponseEntity.ok(hasAnalysisData ? "분석 데이터 존재" : "분석 데이터 없음");
            
        } catch (Exception e) {
            log.error("분석 상태 확인 실패", e);
            return ResponseEntity.internalServerError().body("상태 확인 중 오류가 발생했습니다.");
        }
    }
    
    /**
     * 사용자 ID 생성 또는 조회
     */
    private String getOrCreateUserId(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            userId = "trend_" + System.currentTimeMillis();
            session.setAttribute("userId", userId);
        }
        return userId;
    }
}