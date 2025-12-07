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
import java.util.*;

/**
 * MBTI 기반 맞춤 여행 트렌드 추천 컨트롤러
 * - MBTI 성격 유형별 맞춤 여행지 추천
 * - 베스트 3가지 트렌드 제공 및 상세 이유 설명
 * - Claude AI 기반 개인화 분석
 */
@Slf4j
@RestController
@RequestMapping("/api/mbti-recommendation")
@RequiredArgsConstructor
public class MbtiRecommendationController {
    
    private final ClaudeApiClient claudeApiClient;
    private final UserPreferenceLearningService userPreferenceLearningService;
    private final ObjectMapper objectMapper;
    
    /**
     * MBTI 기반 맞춤 여행 트렌드 추천
     */
    @PostMapping("/personalized")
    public ResponseEntity<Map<String, Object>> getPersonalizedRecommendations(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            String mbti = (String) requestData.get("mbti");
            String season = (String) requestData.getOrDefault("season", "현재");
            String budgetLevel = (String) requestData.getOrDefault("budgetLevel", "중간");
            String travelStyle = (String) requestData.getOrDefault("travelStyle", "자유여행");
            @SuppressWarnings("unchecked")
            List<String> interests = (List<String>) requestData.getOrDefault("interests", new ArrayList<>());
            
            // MBTI 유효성 검사
            if (mbti == null || mbti.trim().isEmpty() || !isValidMbti(mbti)) {
                return ResponseEntity.badRequest()
                    .body(Map.of("status", "error", "message", "유효한 MBTI를 입력해주세요."));
            }
            
            log.info("MBTI 기반 맞춤 추천 요청 - 사용자: {}, MBTI: {}, 계절: {}", userId, mbti, season);
            
            // 사용자 MBTI 정보 기록
            recordMbtiInteraction(userId, mbti, season, budgetLevel, travelStyle, interests);
            
            // Claude AI를 통한 MBTI 기반 추천
            Map<String, Object> recommendations = performMbtiAnalysis(mbti, season, budgetLevel, travelStyle, interests);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "mbti", mbti,
                "recommendations", recommendations,
                "analysisTime", System.currentTimeMillis(),
                "personalizedScore", calculatePersonalizationScore(mbti, interests)
            ));
            
        } catch (Exception e) {
            log.error("MBTI 기반 추천 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "맞춤 추천에 실패했습니다."));
        }
    }
    
    /**
     * MBTI별 여행 성향 분석
     */
    @GetMapping("/mbti-analysis/{mbti}")
    public ResponseEntity<Map<String, Object>> getMbtiTravelProfile(@PathVariable String mbti) {
        try {
            if (!isValidMbti(mbti)) {
                return ResponseEntity.badRequest()
                    .body(Map.of("status", "error", "message", "유효한 MBTI를 입력해주세요."));
            }
            
            Map<String, Object> profile = generateMbtiTravelProfile(mbti);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "mbti", mbti,
                "travelProfile", profile
            ));
            
        } catch (Exception e) {
            log.error("MBTI 여행 성향 분석 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "MBTI 분석에 실패했습니다."));
        }
    }
    
    /**
     * MBTI 기반 분석 수행
     */
    private Map<String, Object> performMbtiAnalysis(String mbti, String season, String budgetLevel, 
                                                   String travelStyle, List<String> interests) {
        try {
            String analysisPrompt = buildMbtiAnalysisPrompt(mbti, season, budgetLevel, travelStyle, interests);
            
            ClaudeRequest request = ClaudeRequest.trendAnalysisBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", analysisPrompt)))
                .maxTokens(4000)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parseMbtiRecommendations(response.getContentText(), mbti);
            }
            
        } catch (Exception e) {
            log.error("Claude API 호출 실패", e);
        }
        
        // Fallback: 기본 MBTI 추천
        return createFallbackMbtiRecommendations(mbti, season, budgetLevel);
    }
    
    /**
     * MBTI 분석 프롬프트 생성
     */
    private String buildMbtiAnalysisPrompt(String mbti, String season, String budgetLevel, 
                                         String travelStyle, List<String> interests) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 MBTI 전문가이자 여행 추천 전문가입니다. ");
        prompt.append(mbti).append(" 성격 유형의 사용자에게 맞춤형 여행 트렌드를 추천해주세요.\\n\\n");
        
        // MBTI 특성 분석 요청
        prompt.append("**분석 요구사항:**\\n");
        prompt.append("1. ").append(mbti).append(" 성격 유형의 여행 선호도 특성 분석\\n");
        prompt.append("2. 해당 MBTI에 가장 적합한 여행 트렌드 TOP 3 추천\\n");
        prompt.append("3. 각 추천에 대한 상세한 이유와 MBTI 연관성 설명\\n");
        prompt.append("4. 실제 여행 가능한 구체적인 목적지 제시\\n");
        prompt.append("5. 여행 스타일 및 액티비티 제안\\n\\n");
        
        // 사용자 정보
        prompt.append("**사용자 정보:**\\n");
        prompt.append("- MBTI: ").append(mbti).append("\\n");
        prompt.append("- 선호 시기: ").append(season).append("\\n");
        prompt.append("- 예산 수준: ").append(budgetLevel).append("\\n");
        prompt.append("- 여행 스타일: ").append(travelStyle).append("\\n");
        if (!interests.isEmpty()) {
            prompt.append("- 관심사: ").append(String.join(", ", interests)).append("\\n");
        }
        prompt.append("\\n");
        
        // MBTI별 특성 정보 추가
        addMbtiCharacteristics(prompt, mbti);
        
        // JSON 응답 형식 지정
        prompt.append("다음 JSON 형식으로 추천 결과를 제공해주세요:\\n\\n");
        prompt.append("{\\n");
        prompt.append("  \\\"mbtiProfile\\\": {\\n");
        prompt.append("    \\\"type\\\": \\\"").append(mbti).append("\\\",\\n");
        prompt.append("    \\\"travelPersonality\\\": \\\"여행 성향 요약\\\",\\n");
        prompt.append("    \\\"preferredStyle\\\": \\\"선호 여행 스타일\\\",\\n");
        prompt.append("    \\\"motivations\\\": [\\\"동기1\\\", \\\"동기2\\\", \\\"동기3\\\"]\\n");
        prompt.append("  },\\n");
        prompt.append("  \\\"topRecommendations\\\": [\\n");
        prompt.append("    {\\n");
        prompt.append("      \\\"rank\\\": 1,\\n");
        prompt.append("      \\\"trendName\\\": \\\"트렌드명\\\",\\n");
        prompt.append("      \\\"destination\\\": \\\"구체적 여행지\\\",\\n");
        prompt.append("      \\\"description\\\": \\\"여행지 설명\\\",\\n");
        prompt.append("      \\\"mbtiAlignment\\\": \\\"MBTI와의 연관성 설명\\\",\\n");
        prompt.append("      \\\"reasonWhy\\\": \\\"추천 이유 상세 설명\\\",\\n");
        prompt.append("      \\\"trendScore\\\": 9.2,\\n");
        prompt.append("      \\\"personalizedScore\\\": 9.5,\\n");
        prompt.append("      \\\"recommendedActivities\\\": [\\\"활동1\\\", \\\"활동2\\\", \\\"활동3\\\"],\\n");
        prompt.append("      \\\"bestTiming\\\": \\\"최적 시기\\\",\\n");
        prompt.append("      \\\"budgetRange\\\": \\\"예상 비용\\\",\\n");
        prompt.append("      \\\"travelDuration\\\": \\\"추천 여행 기간\\\"\\n");
        prompt.append("    }\\n");
        prompt.append("  ],\\n");
        prompt.append("  \\\"personalizedInsights\\\": {\\n");
        prompt.append("    \\\"strengthsForTravel\\\": [\\\"여행 시 강점들\\\"],\\n");
        prompt.append("    \\\"thingsToConsider\\\": [\\\"고려사항들\\\"],\\n");
        prompt.append("    \\\"idealTravelCompanion\\\": \\\"이상적인 동행자\\\",\\n");
        prompt.append("    \\\"avoidRecommendations\\\": [\\\"피해야 할 여행 스타일들\\\"]\\n");
        prompt.append("  }\\n");
        prompt.append("}\\n\\n");
        
        prompt.append("**추천 기준:**\\n");
        prompt.append("1. MBTI 성격 유형의 핵심 특성과 100% 부합\\n");
        prompt.append("2. 실제 방문 가능한 여행지 (국내 우선, 해외 포함)\\n");
        prompt.append("3. 현재 인기 상승 중인 트렌드\\n");
        prompt.append("4. 구체적이고 실행 가능한 여행 계획\\n");
        prompt.append("5. 개인화 점수 8.5 이상의 높은 적합성\\n");
        
        return prompt.toString();
    }
    
    /**
     * MBTI별 특성 정보 추가
     */
    private void addMbtiCharacteristics(StringBuilder prompt, String mbti) {
        prompt.append("**").append(mbti).append(" 여행 특성 참고:**\\n");
        
        Map<String, Map<String, String>> mbtiTraits = getMbtiTraitsMap();
        Map<String, String> traits = mbtiTraits.getOrDefault(mbti.toUpperCase(), new HashMap<>());
        
        if (!traits.isEmpty()) {
            prompt.append("- 성향: ").append(traits.getOrDefault("tendency", "")).append("\\n");
            prompt.append("- 선호 스타일: ").append(traits.getOrDefault("style", "")).append("\\n");
            prompt.append("- 주요 동기: ").append(traits.getOrDefault("motivation", "")).append("\\n");
        }
        prompt.append("\\n");
    }
    
    /**
     * MBTI 추천 파싱
     */
    private Map<String, Object> parseMbtiRecommendations(String content, String mbti) {
        try {
            String jsonContent = extractJsonFromResponse(content);
            @SuppressWarnings("unchecked")
            Map<String, Object> recommendations = objectMapper.readValue(jsonContent, Map.class);
            
            // 메타데이터 추가
            recommendations.put("analysisType", "MBTI-based");
            recommendations.put("targetMbti", mbti);
            recommendations.put("analysisDate", new Date().toString());
            recommendations.put("source", "Claude AI + MBTI Analysis");
            
            return recommendations;
            
        } catch (Exception e) {
            log.error("MBTI 추천 파싱 실패", e);
            return createFallbackMbtiRecommendations(mbti, "현재", "중간");
        }
    }
    
    /**
     * Fallback MBTI 추천 생성
     */
    private Map<String, Object> createFallbackMbtiRecommendations(String mbti, String season, String budgetLevel) {
        Map<String, Object> recommendations = new HashMap<>();
        
        // MBTI 프로필 생성
        Map<String, Object> mbtiProfile = generateMbtiProfile(mbti);
        recommendations.put("mbtiProfile", mbtiProfile);
        
        // TOP 3 추천 생성
        List<Map<String, Object>> topRecommendations = generateFallbackRecommendations(mbti);
        recommendations.put("topRecommendations", topRecommendations);
        
        // 개인화 인사이트
        Map<String, Object> insights = generatePersonalizedInsights(mbti);
        recommendations.put("personalizedInsights", insights);
        
        // 메타데이터
        recommendations.put("analysisType", "MBTI-based Fallback");
        recommendations.put("targetMbti", mbti);
        recommendations.put("analysisDate", new Date().toString());
        recommendations.put("source", "Fallback MBTI Analysis");
        
        return recommendations;
    }
    
    /**
     * MBTI 프로필 생성
     */
    private Map<String, Object> generateMbtiProfile(String mbti) {
        Map<String, Map<String, Object>> profileMap = getMbtiProfileMap();
        return profileMap.getOrDefault(mbti.toUpperCase(), Map.of(
            "type", mbti,
            "travelPersonality", "균형잡힌 여행 성향",
            "preferredStyle", "다양한 스타일 선호",
            "motivations", List.of("새로운 경험", "휴식", "문화체험")
        ));
    }
    
    /**
     * Fallback 추천 생성
     */
    private List<Map<String, Object>> generateFallbackRecommendations(String mbti) {
        Map<String, List<Map<String, Object>>> recommendationMap = getMbtiRecommendationMap();
        return recommendationMap.getOrDefault(mbti.toUpperCase(), List.of(
            createRecommendation(1, "힐링 여행", "제주도", "자연과 함께하는 휴식", "스트레스 해소에 도움", 8.5, 8.0),
            createRecommendation(2, "문화 탐방", "경주", "역사와 문화를 체험", "교육적 가치와 재미", 8.2, 7.8),
            createRecommendation(3, "도시 여행", "부산", "활기찬 도시 분위기", "다양한 액티비티 제공", 8.0, 7.5)
        ));
    }
    
    /**
     * 추천 항목 생성
     */
    private Map<String, Object> createRecommendation(int rank, String trendName, String destination, 
                                                   String description, String reason, double trendScore, double personalizedScore) {
        Map<String, Object> recommendation = new HashMap<>();
        recommendation.put("rank", rank);
        recommendation.put("trendName", trendName);
        recommendation.put("destination", destination);
        recommendation.put("description", description);
        recommendation.put("mbtiAlignment", "MBTI 특성과 부합");
        recommendation.put("reasonWhy", reason);
        recommendation.put("trendScore", trendScore);
        recommendation.put("personalizedScore", personalizedScore);
        recommendation.put("recommendedActivities", List.of("관광", "체험", "휴식"));
        recommendation.put("bestTiming", "연중 내내");
        recommendation.put("budgetRange", "10-30만원");
        recommendation.put("travelDuration", "2-3일");
        
        return recommendation;
    }
    
    /**
     * 개인화 인사이트 생성
     */
    private Map<String, Object> generatePersonalizedInsights(String mbti) {
        Map<String, Map<String, Object>> insightMap = getMbtiInsightMap();
        return insightMap.getOrDefault(mbti.toUpperCase(), Map.of(
            "strengthsForTravel", List.of("적응력", "호기심", "계획성"),
            "thingsToConsider", List.of("충분한 휴식", "예산 관리", "안전 고려"),
            "idealTravelCompanion", "친한 친구",
            "avoidRecommendations", List.of("과도한 일정", "위험한 활동")
        ));
    }
    
    /**
     * MBTI 여행 프로필 생성
     */
    private Map<String, Object> generateMbtiTravelProfile(String mbti) {
        Map<String, Object> profile = new HashMap<>();
        
        Map<String, Map<String, String>> traits = getMbtiTraitsMap();
        Map<String, String> mbtiTraits = traits.getOrDefault(mbti.toUpperCase(), new HashMap<>());
        
        profile.put("mbti", mbti);
        profile.put("travelTendency", mbtiTraits.getOrDefault("tendency", "균형잡힌 성향"));
        profile.put("preferredStyle", mbtiTraits.getOrDefault("style", "다양한 스타일"));
        profile.put("mainMotivation", mbtiTraits.getOrDefault("motivation", "새로운 경험"));
        profile.put("compatibility", calculateMbtiCompatibility(mbti));
        
        return profile;
    }
    
    /**
     * MBTI 호환성 계산
     */
    private Map<String, Double> calculateMbtiCompatibility(String mbti) {
        Map<String, Double> compatibility = new HashMap<>();
        
        compatibility.put("adventure", mbti.contains("E") ? 0.8 : 0.5);
        compatibility.put("culture", mbti.contains("N") ? 0.9 : 0.6);
        compatibility.put("relaxation", mbti.contains("I") ? 0.9 : 0.6);
        compatibility.put("planning", mbti.contains("J") ? 0.9 : 0.5);
        compatibility.put("spontaneous", mbti.contains("P") ? 0.9 : 0.5);
        
        return compatibility;
    }
    
    /**
     * 개인화 점수 계산
     */
    private double calculatePersonalizationScore(String mbti, List<String> interests) {
        double baseScore = 7.5;
        
        // MBTI 유효성에 따른 점수
        if (isValidMbti(mbti)) {
            baseScore += 1.0;
        }
        
        // 관심사 개수에 따른 점수
        baseScore += Math.min(interests.size() * 0.2, 1.0);
        
        return Math.min(baseScore, 10.0);
    }
    
    /**
     * MBTI 상호작용 기록
     */
    private void recordMbtiInteraction(String userId, String mbti, String season, 
                                     String budgetLevel, String travelStyle, List<String> interests) {
        try {
            Map<String, Object> interactionData = new HashMap<>();
            interactionData.put("mbti", mbti);
            interactionData.put("season", season);
            interactionData.put("budgetLevel", budgetLevel);
            interactionData.put("travelStyle", travelStyle);
            interactionData.put("interests", interests);
            interactionData.put("timestamp", System.currentTimeMillis());
            
            userPreferenceLearningService.recordUserInteraction(userId, "mbti_recommendation", interactionData);
            
        } catch (Exception e) {
            log.error("MBTI 상호작용 기록 실패", e);
        }
    }
    
    /**
     * MBTI 유효성 검사
     */
    private boolean isValidMbti(String mbti) {
        if (mbti == null || mbti.length() != 4) {
            return false;
        }
        
        String upperMbti = mbti.toUpperCase();
        return upperMbti.matches("[EI][SN][TF][JP]");
    }
    
    /**
     * 사용자 ID 생성 또는 조회
     */
    private String getOrCreateUserId(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            userId = "mbti_" + System.currentTimeMillis();
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
    
    // =============== MBTI 데이터 맵 ===============
    
    /**
     * MBTI 특성 맵
     */
    private Map<String, Map<String, String>> getMbtiTraitsMap() {
        Map<String, Map<String, String>> traits = new HashMap<>();
        
        traits.put("INTJ", Map.of(
            "tendency", "독립적이고 계획적인 여행",
            "style", "심층 탐구형 여행",
            "motivation", "지식 습득과 개인적 성장"
        ));
        
        traits.put("INFJ", Map.of(
            "tendency", "의미있고 깊이있는 여행",
            "style", "소수 동행 또는 단독 여행",
            "motivation", "내적 평화와 영감 추구"
        ));
        
        traits.put("ENFJ", Map.of(
            "tendency", "사람들과 함께하는 여행",
            "style", "문화 교류형 여행",
            "motivation", "타인과의 연결과 봉사"
        ));
        
        traits.put("ENTP", Map.of(
            "tendency", "모험적이고 즉흥적인 여행",
            "style", "새로운 경험 추구형",
            "motivation", "창의적 영감과 도전"
        ));
        
        // 다른 MBTI 타입들도 추가...
        return traits;
    }
    
    /**
     * MBTI 프로필 맵
     */
    private Map<String, Map<String, Object>> getMbtiProfileMap() {
        Map<String, Map<String, Object>> profiles = new HashMap<>();
        
        profiles.put("INTJ", Map.of(
            "type", "INTJ",
            "travelPersonality", "전략적 탐험가",
            "preferredStyle", "깊이있는 단독 여행",
            "motivations", List.of("지적 호기심", "개인적 성장", "효율적 계획")
        ));
        
        profiles.put("ENFP", Map.of(
            "type", "ENFP",
            "travelPersonality", "열정적 모험가",
            "preferredStyle", "다양한 경험 추구",
            "motivations", List.of("새로운 만남", "창의적 영감", "자유로운 탐험")
        ));
        
        // 기본값 추가...
        return profiles;
    }
    
    /**
     * MBTI 추천 맵
     */
    private Map<String, List<Map<String, Object>>> getMbtiRecommendationMap() {
        Map<String, List<Map<String, Object>>> recommendations = new HashMap<>();
        
        recommendations.put("INTJ", List.of(
            createRecommendation(1, "독립적 탐험", "교토", "조용한 사색과 깊은 문화 체험", "INTJ의 내향적 사색 성향과 완벽 부합", 9.0, 9.5),
            createRecommendation(2, "지식 여행", "박물관 투어", "체계적 학습과 지적 만족", "계획적이고 목적있는 여행 선호", 8.8, 9.2),
            createRecommendation(3, "효율적 도시", "싱가포르", "잘 짜여진 계획으로 최대 효과", "효율성을 중시하는 INTJ 특성 반영", 8.5, 8.9)
        ));
        
        recommendations.put("ENFP", List.of(
            createRecommendation(1, "다채로운 축제", "바르셀로나", "활기찬 문화와 다양한 만남", "ENFP의 외향적 에너지와 새로운 경험 추구", 9.2, 9.6),
            createRecommendation(2, "즉흥 백패킹", "동남아시아", "자유로운 일정과 예상치 못한 모험", "즉흥성과 모험을 사랑하는 성향", 8.9, 9.3),
            createRecommendation(3, "현지인 교류", "유럽 소도시", "진정한 현지 문화 체험", "사람들과의 연결을 중시하는 특성", 8.7, 9.0)
        ));
        
        return recommendations;
    }
    
    /**
     * MBTI 인사이트 맵
     */
    private Map<String, Map<String, Object>> getMbtiInsightMap() {
        Map<String, Map<String, Object>> insights = new HashMap<>();
        
        insights.put("INTJ", Map.of(
            "strengthsForTravel", List.of("철저한 계획 수립", "독립적 문제해결", "깊이있는 관찰력"),
            "thingsToConsider", List.of("충분한 혼자만의 시간", "과도한 사교활동 피하기", "유연성 허용"),
            "idealTravelCompanion", "소수의 깊은 친구 또는 단독",
            "avoidRecommendations", List.of("과도한 그룹 활동", "즉흥적 일정 변경", "시끄러운 파티 여행")
        ));
        
        insights.put("ENFP", Map.of(
            "strengthsForTravel", List.of("높은 적응력", "자연스러운 사교성", "창의적 문제해결"),
            "thingsToConsider", List.of("기본 계획은 세우되 유연하게", "에너지 소진 주의", "중요한 물품 체크"),
            "idealTravelCompanion", "활발하고 개방적인 친구들",
            "avoidRecommendations", List.of("과도하게 엄격한 일정", "단조로운 루틴", "너무 조용한 여행")
        ));
        
        return insights;
    }
}