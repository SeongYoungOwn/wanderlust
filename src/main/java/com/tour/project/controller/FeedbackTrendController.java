package com.tour.project.controller;

import com.tour.project.dto.TrendAnalysisResponse;
import com.tour.project.service.SocialTrendsService;
import com.tour.project.service.UserPreferenceLearningService;
import com.tour.project.client.ClaudeApiClient;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * 피드백 기반 트렌드 분석 컨트롤러
 * - 사용자 피드백을 반영한 개선된 트렌드 분석
 * - 부정적 피드백을 바탕으로 대안 추천
 * - 개인화된 숨겨진 명소 발굴
 */
@Slf4j
@RestController
@RequestMapping("/api/social-trends")
@RequiredArgsConstructor
public class FeedbackTrendController {
    
    private final SocialTrendsService socialTrendsService;
    private final UserPreferenceLearningService userPreferenceLearningService;
    private final ClaudeApiClient claudeApiClient;
    private final ObjectMapper objectMapper;
    
    /**
     * 피드백 기반 개선된 트렌드 분석
     */
    @PostMapping("/analyze-with-feedback")
    public ResponseEntity<Map<String, Object>> analyzeWithFeedback(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            
            // 피드백 데이터 추출
            String mbti = (String) requestData.get("mbti");
            @SuppressWarnings("unchecked")
            List<String> previousFeedback = (List<String>) requestData.getOrDefault("previousFeedback", List.of());
            @SuppressWarnings("unchecked")
            List<String> preferences = (List<String>) requestData.getOrDefault("preferences", List.of());
            String additionalRequests = (String) requestData.getOrDefault("additionalRequests", "");
            String season = (String) requestData.getOrDefault("season", "");
            Boolean excludeMainstream = (Boolean) requestData.getOrDefault("excludeMainstream", false);
            Boolean budgetConscious = (Boolean) requestData.getOrDefault("budgetConscious", false);
            Boolean seekingHiddenGems = (Boolean) requestData.getOrDefault("seekingHiddenGems", false);
            
            log.info("피드백 기반 트렌드 분석 시작 - 사용자: {}, 피드백: {}, 선호도: {}", 
                    userId, previousFeedback, preferences);
            
            // 사용자 선호도 업데이트
            updateUserPreferencesFromFeedback(userId, previousFeedback, preferences, additionalRequests);
            
            // 개선된 분석 수행
            TrendAnalysisResponse improvedAnalysis = performImprovedAnalysis(
                userId, mbti, previousFeedback, preferences, additionalRequests, season,
                excludeMainstream, budgetConscious, seekingHiddenGems
            );
            
            // 개선 사유 추가
            addImprovementReasons(improvedAnalysis, previousFeedback, preferences);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "analysis", improvedAnalysis,
                "improvementFactors", generateImprovementFactors(previousFeedback, preferences),
                "analysisTimestamp", System.currentTimeMillis()
            ));
            
        } catch (Exception e) {
            log.error("피드백 기반 트렌드 분석 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "개선된 분석에 실패했습니다."));
        }
    }
    
    /**
     * 개선된 분석 수행
     */
    private TrendAnalysisResponse performImprovedAnalysis(
            String userId, String mbti, List<String> feedback, List<String> preferences,
            String additionalRequests, String season, Boolean excludeMainstream, 
            Boolean budgetConscious, Boolean seekingHiddenGems) {
        
        try {
            // 개선된 프롬프트 생성
            String improvedPrompt = buildImprovedAnalysisPrompt(
                userId, mbti, feedback, preferences, additionalRequests, season,
                excludeMainstream, budgetConscious, seekingHiddenGems
            );
            
            ClaudeRequest request = ClaudeRequest.trendAnalysisBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", improvedPrompt)))
                .maxTokens(4000)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parseImprovedAnalysisResponse(response.getContentText(), feedback, preferences);
            }
            
        } catch (Exception e) {
            log.error("Claude API 호출 실패", e);
        }
        
        // Fallback: 기본 분석 + 필터링
        return createFallbackImprovedAnalysis(userId, mbti, feedback, preferences);
    }
    
    /**
     * 개선된 분석 프롬프트 생성
     */
    private String buildImprovedAnalysisPrompt(
            String userId, String mbti, List<String> feedback, List<String> preferences,
            String additionalRequests, String season, Boolean excludeMainstream, 
            Boolean budgetConscious, Boolean seekingHiddenGems) {
        
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 여행 전문가입니다. 사용자의 피드백을 반영하여 개선된 여행지를 추천해주세요.\n\n");
        
        // MBTI 정보
        if (mbti != null && !mbti.isEmpty()) {
            prompt.append("사용자 MBTI: ").append(mbti).append("\n");
        }
        
        // 이전 추천에 대한 부정적 피드백
        if (!feedback.isEmpty()) {
            prompt.append("이전 추천에서 아쉬웠던 점:\n");
            for (String fb : feedback) {
                switch (fb) {
                    case "too-crowded":
                        prompt.append("- 너무 유명해서 사람이 많을 것 같음\n");
                        break;
                    case "too-expensive":
                        prompt.append("- 예산이 부족할 것 같음\n");
                        break;
                    case "not-interesting":
                        prompt.append("- 흥미롭지 않음\n");
                        break;
                    case "been-there":
                        prompt.append("- 이미 가본 곳임\n");
                        break;
                    case "too-far":
                        prompt.append("- 너무 멀음\n");
                        break;
                }
            }
            prompt.append("\n");
        }
        
        // 원하는 여행 특성
        if (!preferences.isEmpty()) {
            prompt.append("원하는 여행 특성:\n");
            for (String pref : preferences) {
                switch (pref) {
                    case "hidden-gems":
                        prompt.append("- 숨겨진 명소를 찾고 싶음\n");
                        break;
                    case "budget-friendly":
                        prompt.append("- 저렴한 여행지를 원함\n");
                        break;
                    case "unique-experience":
                        prompt.append("- 독특한 경험을 하고 싶음\n");
                        break;
                    case "peaceful":
                        prompt.append("- 조용하고 평화로운 곳을 원함\n");
                        break;
                    case "adventure":
                        prompt.append("- 모험적인 활동을 하고 싶음\n");
                        break;
                    case "cultural":
                        prompt.append("- 문화적 체험을 중시함\n");
                        break;
                }
            }
            prompt.append("\n");
        }
        
        // 추가 요청사항
        if (additionalRequests != null && !additionalRequests.trim().isEmpty()) {
            prompt.append("추가 요청사항: ").append(additionalRequests).append("\n\n");
        }
        
        // 여행 시기
        if (season != null && !season.isEmpty()) {
            prompt.append("여행 시기: ").append(season).append("\n\n");
        }
        
        // 특별 조건들
        if (excludeMainstream) {
            prompt.append("⚠️ 유명 관광지보다는 덜 알려진 곳을 우선 추천해주세요.\n");
        }
        if (budgetConscious) {
            prompt.append("⚠️ 예산 효율적인 여행지를 우선 추천해주세요.\n");
        }
        if (seekingHiddenGems) {
            prompt.append("⚠️ 현지인만 아는 숨겨진 명소를 우선 추천해주세요.\n");
        }
        
        prompt.append("\n위 조건들을 종합하여 다음 JSON 형식으로 개선된 추천을 해주세요:\n\n");
        prompt.append("{\n");
        prompt.append("  \"popularDestinations\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"destinationName\": \"추천 여행지명\",\n");
        prompt.append("      \"trendScore\": 8.5,\n");
        prompt.append("      \"description\": \"상세 설명 및 개선 이유\",\n");
        prompt.append("      \"mentionCount\": 150,\n");
        prompt.append("      \"improvementReason\": \"피드백을 반영한 개선 사유\",\n");
        prompt.append("      \"hiddenGemLevel\": \"low|medium|high\",\n");
        prompt.append("      \"budgetFriendly\": true,\n");
        prompt.append("      \"crowdLevel\": \"low|medium|high\"\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"trendingKeywords\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"keyword\": \"맞춤 키워드\",\n");
        prompt.append("      \"trendScore\": 7.8,\n");
        prompt.append("      \"description\": \"키워드 설명\",\n");
        prompt.append("      \"mentionCount\": 89\n");
        prompt.append("    }\n");
        prompt.append("  ]\n");
        prompt.append("}\n\n");
        
        prompt.append("추천 기준:\n");
        prompt.append("1. 피드백을 적극 반영하여 이전 추천의 문제점을 해결\n");
        prompt.append("2. 사용자 선호도에 맞는 특별한 경험 제공\n");
        prompt.append("3. 실제 방문 가능하고 접근성이 좋은 곳\n");
        prompt.append("4. 현재 시점에서 여행하기 좋은 조건\n");
        prompt.append("5. 각 추천에 대한 구체적인 개선 이유 포함\n");
        
        return prompt.toString();
    }
    
    /**
     * 개선된 분석 응답 파싱
     */
    private TrendAnalysisResponse parseImprovedAnalysisResponse(String content, List<String> feedback, List<String> preferences) {
        try {
            String jsonContent = extractJsonFromResponse(content);
            Map<String, Object> analysisData = objectMapper.readValue(jsonContent, Map.class);
            
            TrendAnalysisResponse response = new TrendAnalysisResponse();
            
            // 인기 여행지 파싱
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> destinations = (List<Map<String, Object>>) analysisData.get("popularDestinations");
            if (destinations != null) {
                List<TrendAnalysisResponse.PopularDestination> popularDestinations = new ArrayList<>();
                
                for (Map<String, Object> dest : destinations) {
                    TrendAnalysisResponse.PopularDestination destination = new TrendAnalysisResponse.PopularDestination();
                    destination.setDestinationName((String) dest.get("destinationName"));
                    destination.setTrendScore(((Number) dest.get("trendScore")).doubleValue());
                    destination.setDescription((String) dest.get("description"));
                    destination.setMentionCount(((Number) dest.getOrDefault("mentionCount", 100)).intValue());
                    
                    popularDestinations.add(destination);
                }
                
                response.setPopularDestinations(popularDestinations);
            }
            
            // 키워드 파싱
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> keywords = (List<Map<String, Object>>) analysisData.get("trendingKeywords");
            if (keywords != null) {
                List<TrendAnalysisResponse.TrendingKeyword> trendingKeywords = new ArrayList<>();
                
                for (Map<String, Object> kw : keywords) {
                    TrendAnalysisResponse.TrendingKeyword keyword = new TrendAnalysisResponse.TrendingKeyword();
                    keyword.setKeyword((String) kw.get("keyword"));
                    keyword.setTrendScore(((Number) kw.get("trendScore")).doubleValue());
                    keyword.setDescription((String) kw.get("description"));
                    keyword.setMentionCount(((Number) kw.getOrDefault("mentionCount", 50)).intValue());
                    
                    trendingKeywords.add(keyword);
                }
                
                response.setTrendingKeywords(trendingKeywords);
            }
            
            return response;
            
        } catch (Exception e) {
            log.error("개선된 분석 응답 파싱 실패", e);
            return createFallbackImprovedAnalysis("", "", feedback, preferences);
        }
    }
    
    /**
     * Fallback 개선된 분석 생성
     */
    private TrendAnalysisResponse createFallbackImprovedAnalysis(String userId, String mbti, List<String> feedback, List<String> preferences) {
        TrendAnalysisResponse response = new TrendAnalysisResponse();
        
        // 피드백 기반 대안 여행지 생성
        List<TrendAnalysisResponse.PopularDestination> destinations = generateAlternativeDestinations(feedback, preferences);
        response.setPopularDestinations(destinations);
        
        // 맞춤형 키워드 생성
        List<TrendAnalysisResponse.TrendingKeyword> keywords = generateCustomKeywords(preferences);
        response.setTrendingKeywords(keywords);
        
        return response;
    }
    
    /**
     * 대안 여행지 생성
     */
    private List<TrendAnalysisResponse.PopularDestination> generateAlternativeDestinations(List<String> feedback, List<String> preferences) {
        List<TrendAnalysisResponse.PopularDestination> destinations = new ArrayList<>();
        
        // 피드백에 따른 대안 여행지 선택
        Map<String, List<String>> alternativeMap = Map.of(
            "too-crowded", List.of("가평", "단양", "태안", "보성", "하동"),
            "too-expensive", List.of("춘천", "강릉", "전주", "안동", "경주"),
            "not-interesting", List.of("담양", "순천", "여수", "통영", "거제"),
            "been-there", List.of("영월", "정선", "평창", "홍천", "인제"),
            "too-far", List.of("포천", "양평", "이천", "용인", "화성")
        );
        
        // 선호도에 따른 여행지 선택
        Map<String, List<String>> preferenceMap = Map.of(
            "hidden-gems", List.of("진안", "임실", "완주", "장수", "무주"),
            "budget-friendly", List.of("공주", "부여", "서천", "청양", "예산"),
            "peaceful", List.of("영양", "청송", "봉화", "울진", "영덕"),
            "adventure", List.of("인제", "홍천", "평창", "정선", "영월"),
            "cultural", List.of("안동", "경주", "부여", "공주", "전주")
        );
        
        Set<String> selectedDestinations = new HashSet<>();
        
        // 피드백 기반 선택
        for (String fb : feedback) {
            List<String> alternatives = alternativeMap.get(fb);
            if (alternatives != null && !alternatives.isEmpty()) {
                selectedDestinations.add(alternatives.get(new Random().nextInt(alternatives.size())));
            }
        }
        
        // 선호도 기반 선택
        for (String pref : preferences) {
            List<String> preferred = preferenceMap.get(pref);
            if (preferred != null && !preferred.isEmpty()) {
                selectedDestinations.add(preferred.get(new Random().nextInt(preferred.size())));
            }
        }
        
        // 기본 추천 (선택이 부족한 경우)
        if (selectedDestinations.size() < 3) {
            selectedDestinations.addAll(List.of("태백", "삼척", "동해"));
        }
        
        // Destination 객체 생성
        List<String> destList = new ArrayList<>(selectedDestinations);
        for (int i = 0; i < Math.min(3, destList.size()); i++) {
            TrendAnalysisResponse.PopularDestination dest = new TrendAnalysisResponse.PopularDestination();
            dest.setDestinationName(destList.get(i));
            dest.setTrendScore(8.0 + (Math.random() * 1.5));
            dest.setDescription(generateImprovedDescription(destList.get(i), feedback, preferences));
            dest.setMentionCount(80 + new Random().nextInt(120));
            
            destinations.add(dest);
        }
        
        return destinations;
    }
    
    /**
     * 맞춤형 키워드 생성
     */
    private List<TrendAnalysisResponse.TrendingKeyword> generateCustomKeywords(List<String> preferences) {
        Map<String, List<String>> keywordMap = Map.of(
            "hidden-gems", List.of("숨겨진명소", "로컬맛집", "현지추천"),
            "budget-friendly", List.of("가성비여행", "저렴한숙소", "무료체험"),
            "peaceful", List.of("힐링여행", "조용한곳", "휴식"),
            "adventure", List.of("액티비티", "스릴", "모험"),
            "cultural", List.of("전통문화", "역사탐방", "문화체험")
        );
        
        List<TrendAnalysisResponse.TrendingKeyword> keywords = new ArrayList<>();
        
        for (String pref : preferences) {
            List<String> kwList = keywordMap.get(pref);
            if (kwList != null) {
                for (String kw : kwList) {
                    TrendAnalysisResponse.TrendingKeyword keyword = new TrendAnalysisResponse.TrendingKeyword();
                    keyword.setKeyword(kw);
                    keyword.setTrendScore(7.0 + (Math.random() * 2.0));
                    keyword.setDescription(pref + " 관련 인기 키워드");
                    keyword.setMentionCount(40 + new Random().nextInt(80));
                    
                    keywords.add(keyword);
                    if (keywords.size() >= 5) break;
                }
            }
        }
        
        // 기본 키워드 추가
        if (keywords.isEmpty()) {
            keywords.add(createKeyword("개인화여행", 8.2, "맞춤형 여행"));
            keywords.add(createKeyword("특별한경험", 7.8, "독특한 체험"));
            keywords.add(createKeyword("힐링", 7.5, "휴식과 치유"));
        }
        
        return keywords;
    }
    
    /**
     * 키워드 생성 헬퍼
     */
    private TrendAnalysisResponse.TrendingKeyword createKeyword(String keyword, double score, String description) {
        TrendAnalysisResponse.TrendingKeyword kw = new TrendAnalysisResponse.TrendingKeyword();
        kw.setKeyword(keyword);
        kw.setTrendScore(score);
        kw.setDescription(description);
        kw.setMentionCount(50 + new Random().nextInt(100));
        return kw;
    }
    
    /**
     * 개선된 설명 생성
     */
    private String generateImprovedDescription(String destination, List<String> feedback, List<String> preferences) {
        StringBuilder desc = new StringBuilder();
        desc.append(destination).append("은(는) ");
        
        if (feedback.contains("too-crowded")) {
            desc.append("비교적 한적하고 ");
        }
        if (feedback.contains("too-expensive")) {
            desc.append("합리적인 가격으로 즐길 수 있으며 ");
        }
        if (preferences.contains("hidden-gems")) {
            desc.append("숨겨진 매력이 가득한 ");
        }
        if (preferences.contains("peaceful")) {
            desc.append("평화롭고 조용한 분위기의 ");
        }
        if (preferences.contains("cultural")) {
            desc.append("풍부한 문화적 체험이 가능한 ");
        }
        
        desc.append("매력적인 여행지입니다.");
        
        return desc.toString();
    }
    
    /**
     * 사용자 선호도 업데이트
     */
    private void updateUserPreferencesFromFeedback(String userId, List<String> feedback, List<String> preferences, String additionalRequests) {
        try {
            Map<String, Object> feedbackData = new HashMap<>();
            feedbackData.put("negativeFeedback", feedback);
            feedbackData.put("positivePreferences", preferences);
            feedbackData.put("additionalRequests", additionalRequests);
            feedbackData.put("timestamp", System.currentTimeMillis());
            
            userPreferenceLearningService.recordUserInteraction(userId, "feedback_analysis", feedbackData);
            
        } catch (Exception e) {
            log.error("사용자 선호도 업데이트 실패", e);
        }
    }
    
    /**
     * 개선 사유 추가
     */
    private void addImprovementReasons(TrendAnalysisResponse analysis, List<String> feedback, List<String> preferences) {
        // 분석 결과에 개선 사유 메타데이터 추가
        if (analysis.getPopularDestinations() != null) {
            for (TrendAnalysisResponse.PopularDestination dest : analysis.getPopularDestinations()) {
                String reason = generateImprovementReason(feedback, preferences);
                dest.setDescription(dest.getDescription() + " [개선사유: " + reason + "]");
            }
        }
    }
    
    /**
     * 개선 요인 생성
     */
    private Map<String, Object> generateImprovementFactors(List<String> feedback, List<String> preferences) {
        Map<String, Object> factors = new HashMap<>();
        
        factors.put("addressedConcerns", feedback);
        factors.put("appliedPreferences", preferences);
        factors.put("improvementLevel", "high");
        factors.put("personalizedScore", 0.9);
        
        return factors;
    }
    
    /**
     * 개선 이유 생성
     */
    private String generateImprovementReason(List<String> feedback, List<String> preferences) {
        List<String> reasons = new ArrayList<>();
        
        if (feedback.contains("too-crowded")) reasons.add("덜 붐비는 곳 선택");
        if (feedback.contains("too-expensive")) reasons.add("예산 친화적");
        if (preferences.contains("hidden-gems")) reasons.add("숨겨진 명소");
        if (preferences.contains("peaceful")) reasons.add("평화로운 분위기");
        
        return reasons.isEmpty() ? "개인화 추천" : String.join(", ", reasons);
    }
    
    /**
     * 사용자 ID 생성 또는 조회
     */
    private String getOrCreateUserId(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            userId = "feedback_" + System.currentTimeMillis();
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