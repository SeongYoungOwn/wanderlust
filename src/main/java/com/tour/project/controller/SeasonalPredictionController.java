package com.tour.project.controller;

import com.tour.project.client.ClaudeApiClient;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import com.tour.project.service.UserPreferenceLearningService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.http.HttpSession;
import java.time.LocalDate;
import java.time.Month;
import java.util.*;

/**
 * 계절별 트렌드 예측 컨트롤러
 * - Claude AI를 활용한 계절별 여행 트렌드 예측
 * - 현재 월 기준 상승 예측 트렌드 분석
 * - 월별 특화 여행지 및 액티비티 추천
 */
@Slf4j
@RestController
@RequestMapping("/api/seasonal-prediction")
@RequiredArgsConstructor
public class SeasonalPredictionController {
    
    private final ClaudeApiClient claudeApiClient;
    private final UserPreferenceLearningService userPreferenceLearningService;
    private final ObjectMapper objectMapper;
    
    /**
     * 현재 월 기준 트렌드 상승 예측
     */
    @PostMapping("/current-month")
    public ResponseEntity<Map<String, Object>> getCurrentMonthPrediction(
            @RequestBody(required = false) Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            int currentMonth = LocalDate.now().getMonthValue();
            String monthName = getKoreanMonthName(currentMonth);
            
            log.info("{}월 트렌드 상승 예측 요청 - 사용자: {}", currentMonth, userId);
            
            // 사용자 선호도 기록
            recordUserInteraction(userId, "seasonal_prediction", Map.of("month", currentMonth));
            
            // Claude AI를 통한 예측 분석
            Map<String, Object> prediction = performSeasonalPrediction(currentMonth, monthName);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "currentMonth", currentMonth,
                "monthName", monthName,
                "prediction", prediction,
                "analysisTime", System.currentTimeMillis()
            ));
            
        } catch (Exception e) {
            log.error("계절별 트렌드 예측 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "트렌드 예측에 실패했습니다."));
        }
    }
    
    /**
     * 특정 월 트렌드 예측
     */
    @PostMapping("/month/{month}")
    public ResponseEntity<Map<String, Object>> getMonthPrediction(
            @PathVariable int month,
            @RequestBody(required = false) Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            if (month < 1 || month > 12) {
                return ResponseEntity.badRequest()
                    .body(Map.of("status", "error", "message", "올바른 월을 입력해주세요 (1-12)."));
            }
            
            String userId = getOrCreateUserId(session);
            String monthName = getKoreanMonthName(month);
            
            log.info("{}월 트렌드 예측 요청 - 사용자: {}", month, userId);
            
            // Claude AI를 통한 예측 분석
            Map<String, Object> prediction = performSeasonalPrediction(month, monthName);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "targetMonth", month,
                "monthName", monthName,
                "prediction", prediction,
                "analysisTime", System.currentTimeMillis()
            ));
            
        } catch (Exception e) {
            log.error("{}월 트렌드 예측 실패", month, e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "트렌드 예측에 실패했습니다."));
        }
    }
    
    /**
     * 계절별 트렌드 예측 수행
     */
    private Map<String, Object> performSeasonalPrediction(int month, String monthName) {
        try {
            String predictionPrompt = buildSeasonalPredictionPrompt(month, monthName);
            
            ClaudeRequest request = ClaudeRequest.trendAnalysisBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", predictionPrompt)))
                .maxTokens(3500)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parseSeasonalPrediction(response.getContentText(), month);
            }
            
        } catch (Exception e) {
            log.error("Claude API 호출 실패", e);
        }
        
        // Fallback: 기본 예측 데이터
        return createFallbackPrediction(month, monthName);
    }
    
    /**
     * 계절별 예측 프롬프트 생성
     */
    private String buildSeasonalPredictionPrompt(int month, String monthName) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 여행 트렌드 분석 전문가입니다. ");
        prompt.append(monthName).append("(").append(month).append("월)에 대한 여행 트렌드 상승 예측을 해주세요.\n\n");
        
        prompt.append("분석 요구사항:\n");
        prompt.append("1. ").append(month).append("월의 기후적 특성과 계절감을 고려\n");
        prompt.append("2. 해당 월에 인기 상승이 예상되는 여행지 TOP 5\n");
        prompt.append("3. 상승 이유와 구체적인 근거 제시\n");
        prompt.append("4. 추천 액티비티 및 특별 경험\n");
        prompt.append("5. 예상 트렌드 점수 (1-10점)\n");
        prompt.append("6. 최적 여행 시기 (상순/중순/하순)\n\n");
        
        // 월별 특성 정보 추가
        prompt.append("참고 정보:\n");
        switch (month) {
            case 8:
                prompt.append("- 여름 성수기, 휴가철, 무더위 대피 여행지 관심 증가\n- 바다, 계곡, 피서지 트렌드\n- 페스티벌 및 여름 이벤트 많음\n");
                break;
            case 9:
                prompt.append("- 가을 시작, 선선한 날씨, 단풍 준비기\n- 등산, 트레킹 관심 증가\n- 추석 연휴 고려\n");
                break;
            case 10:
                prompt.append("- 단풍 절정기, 선선한 날씨\n- 등산, 드라이브 여행 인기\n- 가을 축제 시즌\n");
                break;
            case 11:
                prompt.append("- 늦가을, 단풍 마지막, 겨울 준비\n- 온천, 실내 관광지 관심 증가\n");
                break;
            case 12:
                prompt.append("- 겨울 시작, 연말연시 분위기\n- 스키, 온천, 겨울 축제\n- 크리스마스, 신정 여행\n");
                break;
            case 1:
                prompt.append("- 신년, 겨울 성수기\n- 스키리조트, 온천, 해외여행\n- 신년 일출명소\n");
                break;
            case 2:
                prompt.append("- 늦겨울, 매화 시즌\n- 따뜻한 남쪽 지역 관심\n- 겨울 스포츠 마지막\n");
                break;
            case 3:
                prompt.append("- 봄 시작, 꽃 피는 시기\n- 벚꽃, 매화 명소 관심\n- 졸업여행 시즌\n");
                break;
            case 4:
                prompt.append("- 봄 절정, 벚꽃 만개\n- 꽃구경, 봄나들이 트렌드\n- 신학기 가족여행\n");
                break;
            case 5:
                prompt.append("- 늦봄, 완연한 봄날씨\n- 가정의 달, 가족여행 증가\n- 야외 액티비티 최적기\n");
                break;
            case 6:
                prompt.append("- 초여름, 장마 전\n- 해외여행 성수기 시작\n- 바다 시즌 오픈\n");
                break;
            case 7:
                prompt.append("- 여름 본격 시작, 휴가철\n- 피서지, 물놀이 관심 급증\n- 여름 페스티벌 시즌\n");
                break;
        }
        
        prompt.append("\n다음 JSON 형식으로 예측 결과를 제공해주세요:\n\n");
        prompt.append("{\n");
        prompt.append("  \"risingDestinations\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"destinationName\": \"여행지명\",\n");
        prompt.append("      \"predictedScore\": 8.5,\n");
        prompt.append("      \"currentScore\": 7.2,\n");
        prompt.append("      \"growthRate\": \"+18%\",\n");
        prompt.append("      \"risingReason\": \"상승 이유\",\n");
        prompt.append("      \"bestTiming\": \"상순|중순|하순\",\n");
        prompt.append("      \"specialFeatures\": [\"특징1\", \"특징2\"],\n");
        prompt.append("      \"recommendedActivities\": [\"액티비티1\", \"액티비티2\"]\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"seasonalInsights\": {\n");
        prompt.append("    \"weatherAdvantage\": \"날씨상 장점\",\n");
        prompt.append("    \"popularActivities\": [\"인기 액티비티들\"],\n");
        prompt.append("    \"avoidanceFactors\": [\"피해야 할 요소들\"],\n");
        prompt.append("    \"budgetTrend\": \"high|medium|low\",\n");
        prompt.append("    \"crowdLevel\": \"high|medium|low\"\n");
        prompt.append("  },\n");
        prompt.append("  \"marketPredictions\": {\n");
        prompt.append("    \"overallTrend\": \"상승|하락|유지\",\n");
        prompt.append("    \"hotSpots\": [\"핫스팟 지역들\"],\n");
        prompt.append("    \"emergingDestinations\": [\"신흥 여행지들\"],\n");
        prompt.append("    \"priceExpectation\": \"상승|하락|유지\"\n");
        prompt.append("  }\n");
        prompt.append("}\n");
        
        return prompt.toString();
    }
    
    /**
     * 계절별 예측 파싱
     */
    private Map<String, Object> parseSeasonalPrediction(String content, int month) {
        try {
            String jsonContent = extractJsonFromResponse(content);
            @SuppressWarnings("unchecked")
            Map<String, Object> prediction = objectMapper.readValue(jsonContent, Map.class);
            
            // 추가 메타데이터
            prediction.put("analysisMonth", month);
            prediction.put("analysisDate", LocalDate.now().toString());
            prediction.put("source", "Claude AI Analysis");
            
            return prediction;
            
        } catch (Exception e) {
            log.error("계절별 예측 파싱 실패", e);
            return createFallbackPrediction(month, getKoreanMonthName(month));
        }
    }
    
    /**
     * Fallback 예측 데이터 생성
     */
    private Map<String, Object> createFallbackPrediction(int month, String monthName) {
        Map<String, Object> prediction = new HashMap<>();
        
        // 8월 기준 기본 예측 데이터
        if (month == 8) {
            prediction.put("risingDestinations", List.of(
                Map.of(
                    "destinationName", "강릉",
                    "predictedScore", 8.8,
                    "currentScore", 7.5,
                    "growthRate", "+17%",
                    "risingReason", "시원한 바다와 피서철 특수로 인한 수요 급증",
                    "bestTiming", "중순",
                    "specialFeatures", List.of("해수욕장", "카페거리", "시원한 바람"),
                    "recommendedActivities", List.of("해수욕", "서핑", "카페투어")
                ),
                Map.of(
                    "destinationName", "평창",
                    "predictedScore", 8.5,
                    "currentScore", 7.0,
                    "growthRate", "+21%",
                    "risingReason", "시원한 고원지대로 피서 목적지로 각광",
                    "bestTiming", "하순",
                    "specialFeatures", List.of("서늘한 기후", "양떼목장", "청정자연"),
                    "recommendedActivities", List.of("목장체험", "트레킹", "캠핑")
                ),
                Map.of(
                    "destinationName", "거제도",
                    "predictedScore", 8.3,
                    "currentScore", 6.8,
                    "growthRate", "+22%",
                    "risingReason", "섬 여행 트렌드와 깨끗한 바다로 인기 상승",
                    "bestTiming", "상순",
                    "specialFeatures", List.of("몽돌해변", "해상케이블카", "외도보타니아"),
                    "recommendedActivities", List.of("해수욕", "드라이브", "섬투어")
                )
            ));
            
            prediction.put("seasonalInsights", Map.of(
                "weatherAdvantage", "무더위 피할 수 있는 시원한 지역 선호",
                "popularActivities", List.of("해수욕", "계곡놀이", "피서", "워터파크"),
                "avoidanceFactors", List.of("과도한 더위", "혼잡한 해변", "높은 숙박비"),
                "budgetTrend", "high",
                "crowdLevel", "high"
            ));
            
            prediction.put("marketPredictions", Map.of(
                "overallTrend", "상승",
                "hotSpots", List.of("동해안", "계곡지대", "고원지대"),
                "emergingDestinations", List.of("양양", "인제", "태백"),
                "priceExpectation", "상승"
            ));
        }
        
        prediction.put("analysisMonth", month);
        prediction.put("analysisDate", LocalDate.now().toString());
        prediction.put("source", "Fallback Analysis");
        
        return prediction;
    }
    
    /**
     * 사용자 상호작용 기록
     */
    private void recordUserInteraction(String userId, String interactionType, Map<String, Object> data) {
        try {
            userPreferenceLearningService.recordUserInteraction(userId, interactionType, data);
        } catch (Exception e) {
            log.error("사용자 상호작용 기록 실패", e);
        }
    }
    
    /**
     * 한국어 월명 변환
     */
    private String getKoreanMonthName(int month) {
        String[] monthNames = {
            "", "1월", "2월", "3월", "4월", "5월", "6월",
            "7월", "8월", "9월", "10월", "11월", "12월"
        };
        return monthNames[month];
    }
    
    /**
     * 사용자 ID 생성 또는 조회
     */
    private String getOrCreateUserId(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            userId = "seasonal_" + System.currentTimeMillis();
            session.setAttribute("userId", userId);
        }
        return userId;
    }
    
    /**
     * JSON 추출
     */
    private String extractJsonFromResponse(String response) {
        int startIndex = response.indexOf("{");
        int endIndex = response.lastIndexOf("}");
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return response.substring(startIndex, endIndex + 1);
        }
        
        throw new RuntimeException("JSON 형식을 찾을 수 없습니다.");
    }
}