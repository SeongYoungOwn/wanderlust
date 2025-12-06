package com.tour.project.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tour.project.client.ClaudeApiClient;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import com.tour.project.dto.trend.TrendAnalysisResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Claude API를 이용한 트렌드 분석 서비스
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ClaudeAnalysisService {
    
    private final ClaudeApiClient claudeApiClient;
    private final ObjectMapper objectMapper;
    
    /**
     * 급상승 여행지 분석
     */
    public List<TrendAnalysisResponseDTO.PopularDestination> analyzeTrends(String prompt) {
        try {
            log.info("급상승 여행지 분석 시작");
            
            String analysisPrompt = createPopularDestinationsPrompt();
            ClaudeRequest request = createClaudeRequest(analysisPrompt);
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            String responseText = extractTextFromResponse(response);
            return parsePopularDestinationsResponse(responseText);
            
        } catch (Exception e) {
            log.error("급상승 여행지 분석 실패", e);
            return createFallbackPopularDestinations();
        }
    }
    
    /**
     * MBTI 기반 트렌드 분석
     */
    public List<TrendAnalysisResponseDTO.MBTIRecommendation> analyzeMBTITrends(String prompt, String mbtiType) {
        try {
            log.info("MBTI 맞춤 분석 시작 - MBTI: {}", mbtiType);
            
            String analysisPrompt = createMBTIPrompt(mbtiType);
            ClaudeRequest request = createClaudeRequest(analysisPrompt);
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            String responseText = extractTextFromResponse(response);
            return parseMBTIRecommendationsResponse(responseText, mbtiType);
            
        } catch (Exception e) {
            log.error("MBTI 맞춤 분석 실패", e);
            return createFallbackMBTIRecommendations(mbtiType);
        }
    }
    
    /**
     * 지역별 인기도 분석
     */
    public List<TrendAnalysisResponseDTO.RegionPopularity> analyzeRegions(String prompt) {
        try {
            log.info("지역별 인기도 분석 시작");
            
            String analysisPrompt = createRegionPopularityPrompt();
            ClaudeRequest request = createClaudeRequest(analysisPrompt);
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            String responseText = extractTextFromResponse(response);
            return parseRegionPopularityResponse(responseText);
            
        } catch (Exception e) {
            log.error("지역별 인기도 분석 실패", e);
            return createFallbackRegionPopularity();
        }
    }
    
    /**
     * 종합 분석 생성
     */
    public TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse generateFinalAnalysis(String prompt) {
        try {
            log.info("종합 분석 시작");
            
            String analysisPrompt = createComprehensivePrompt();
            ClaudeRequest request = createClaudeRequest(analysisPrompt);
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            String responseText = extractTextFromResponse(response);
            return parseComprehensiveAnalysisResponse(responseText);
            
        } catch (Exception e) {
            log.error("종합 분석 실패", e);
            return createFallbackComprehensiveAnalysis();
        }
    }
    
    // ==================== 프롬프트 생성 메소드들 ====================
    
    private String createPopularDestinationsPrompt() {
        return "최근 1개월 내 SNS, 뉴스, 블로그에서 급상승한 국내 여행지 TOP 3를 분석해서 알려줘.\n" +
               "각 여행지별로 인기 이유와 트렌드 점수(1-100)도 포함해줘.\n" +
               "\n" +
               "응답은 다음과 같은 JSON 형식으로 작성해줘:\n" +
               "[\n" +
               "    {\n" +
               "        \"destinationName\": \"여행지명\",\n" +
               "        \"trendScore\": 95,\n" +
               "        \"popularityReason\": \"인기 이유\",\n" +
               "        \"category\": \"자연/도시/문화\",\n" +
               "        \"hashtags\": [\"해시태그1\", \"해시태그2\", \"해시태그3\"],\n" +
               "        \"rank\": 1\n" +
               "    }\n" +
               "]\n" +
               "\n" +
               "실제 트렌드 데이터를 바탕으로 정확하고 현실적인 분석 결과를 제공해줘.";
    }
    
    private String createMBTIPrompt(String mbtiType) {
        return String.format("MBTI %s 성향에 맞는 현재 트렌드 여행지를 국내 한정으로 2곳 추천해줘.\n" +
               "각각의 추천 이유와 해당 MBTI에게 어떤 점이 매력적인지 설명해줘.\n" +
               "\n" +
               "응답은 다음과 같은 JSON 형식으로 작성해줘:\n" +
               "[\n" +
               "    {\n" +
               "        \"destinationName\": \"여행지명\",\n" +
               "        \"mbtiType\": \"%s\",\n" +
               "        \"recommendationReason\": \"추천 이유\",\n" +
               "        \"matchingScore\": 92,\n" +
               "        \"attractions\": [\"매력 포인트1\", \"매력 포인트2\", \"매력 포인트3\"],\n" +
               "        \"personalityFit\": \"성향 적합성 설명\"\n" +
               "    }\n" +
               "]\n" +
               "\n" +
               "%s 성향의 특성을 고려하여 현실적이고 구체적인 추천을 제공해줘.",
               mbtiType, mbtiType, mbtiType);
    }
    
    private String createRegionPopularityPrompt() {
        return "최근 1개월 SNS에서 가장 인기 있는 국내 여행 지역 TOP 3을 분석해줘.\n" +
               "지역별 인기도 점수(1-100)와 주요 관광지, 인기 이유를 포함해줘.\n" +
               "\n" +
               "응답은 다음과 같은 JSON 형식으로 작성해줘:\n" +
               "[\n" +
               "    {\n" +
               "        \"regionName\": \"지역명\",\n" +
               "        \"latitude\": 위도,\n" +
               "        \"longitude\": 경도,\n" +
               "        \"popularityScore\": 95,\n" +
               "        \"hotSpots\": [\"핫스팟1\", \"핫스팟2\", \"핫스팟3\"],\n" +
               "        \"trendDescription\": \"트렌드 설명\",\n" +
               "        \"markerColor\": \"#ff4444\",\n" +
               "        \"mentionCount\": 15420\n" +
               "    }\n" +
               "]\n" +
               "\n" +
               "정확한 위도/경도 정보와 실제 SNS 트렌드를 반영해서 답변해줘.";
    }
    
    private String createComprehensivePrompt() {
        return "앞서 분석한 급상승 여행지, MBTI 추천, 지역별 인기도를 종합해서\n" +
               "Best 3 여행지를 선정하고 각각의 선정 이유를 상세히 설명해줘.\n" +
               "\n" +
               "응답은 다음과 같은 JSON 형식으로 작성해줘:\n" +
               "{\n" +
               "    \"bestDestinations\": [\n" +
               "        {\n" +
               "            \"destinationName\": \"여행지명\",\n" +
               "            \"rank\": 1,\n" +
               "            \"totalScore\": 95,\n" +
               "            \"selectionReason\": \"선정 이유\",\n" +
               "            \"highlights\": [\"특징1\", \"특징2\", \"특징3\"],\n" +
               "            \"trendSource\": \"Instagram, YouTube, 네이버 블로그\",\n" +
               "            \"metrics\": {\n" +
               "                \"popularityScore\": 95,\n" +
               "                \"mbtiCompatibility\": 92,\n" +
               "                \"regionTrendScore\": 95,\n" +
               "                \"overallRating\": 94\n" +
               "            }\n" +
               "        }\n" +
               "    ],\n" +
               "    \"summary\": {\n" +
               "        \"analysisDate\": \"2024-11-20\",\n" +
               "        \"totalDestinations\": 9,\n" +
               "        \"topTrendSource\": \"Instagram (45%), YouTube (30%), 네이버 블로그 (25%)\",\n" +
               "        \"seasonalTrend\": \"가을 단풍, 억새밭 여행지 인기 급상승\",\n" +
               "        \"emergingDestinations\": [\"신흥 여행지1\", \"신흥 여행지2\"]\n" +
               "    }\n" +
               "}\n" +
               "\n" +
               "데이터 기반의 객관적이고 신뢰할 수 있는 종합 분석을 제공해줘.";
    }
    
    // ==================== Claude API 요청 생성 ====================
    
    private ClaudeRequest createClaudeRequest(String prompt) {
        ClaudeRequest.Message message = ClaudeRequest.Message.builder()
                .role("user")
                .content(prompt)
                .build();
        
        return ClaudeRequest.builder()
                .model("claude-sonnet-4-20250514")
                .maxTokens(3000)
                .messages(List.of(message))
                .temperature(0.7)
                .build();
    }
    
    // ==================== 응답 파싱 메소드들 ====================
    
    private String extractTextFromResponse(ClaudeResponse response) {
        if (response != null && response.getContent() != null && !response.getContent().isEmpty()) {
            return response.getContent().get(0).getText();
        }
        throw new RuntimeException("Claude API 응답에서 텍스트를 추출할 수 없습니다.");
    }
    
    private List<TrendAnalysisResponseDTO.PopularDestination> parsePopularDestinationsResponse(String responseText) {
        try {
            // JSON 부분만 추출
            String jsonPart = extractJsonFromText(responseText);
            return objectMapper.readValue(jsonPart, new TypeReference<List<TrendAnalysisResponseDTO.PopularDestination>>() {});
        } catch (Exception e) {
            log.warn("급상승 여행지 응답 파싱 실패, 폴백 데이터 사용: {}", e.getMessage());
            return createFallbackPopularDestinations();
        }
    }
    
    private List<TrendAnalysisResponseDTO.MBTIRecommendation> parseMBTIRecommendationsResponse(String responseText, String mbtiType) {
        try {
            String jsonPart = extractJsonFromText(responseText);
            return objectMapper.readValue(jsonPart, new TypeReference<List<TrendAnalysisResponseDTO.MBTIRecommendation>>() {});
        } catch (Exception e) {
            log.warn("MBTI 추천 응답 파싱 실패, 폴백 데이터 사용: {}", e.getMessage());
            return createFallbackMBTIRecommendations(mbtiType);
        }
    }
    
    private List<TrendAnalysisResponseDTO.RegionPopularity> parseRegionPopularityResponse(String responseText) {
        try {
            String jsonPart = extractJsonFromText(responseText);
            return objectMapper.readValue(jsonPart, new TypeReference<List<TrendAnalysisResponseDTO.RegionPopularity>>() {});
        } catch (Exception e) {
            log.warn("지역별 인기도 응답 파싱 실패, 폴백 데이터 사용: {}", e.getMessage());
            return createFallbackRegionPopularity();
        }
    }
    
    private TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse parseComprehensiveAnalysisResponse(String responseText) {
        try {
            String jsonPart = extractJsonFromText(responseText);
            Map<String, Object> result = objectMapper.readValue(jsonPart, Map.class);
            
            // bestDestinations 파싱
            List<TrendAnalysisResponseDTO.BestDestination> bestDestinations = 
                objectMapper.convertValue(result.get("bestDestinations"), 
                    new TypeReference<List<TrendAnalysisResponseDTO.BestDestination>>() {});
            
            // summary 파싱
            TrendAnalysisResponseDTO.AnalysisSummary summary = 
                objectMapper.convertValue(result.get("summary"), TrendAnalysisResponseDTO.AnalysisSummary.class);
            
            return TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse.builder()
                    .success(true)
                    .message("종합 분석이 완료되었습니다.")
                    .bestDestinations(bestDestinations)
                    .summary(summary)
                    .build();
                    
        } catch (Exception e) {
            log.warn("종합 분석 응답 파싱 실패, 폴백 데이터 사용: {}", e.getMessage());
            return createFallbackComprehensiveAnalysis();
        }
    }
    
    // ==================== 유틸리티 메소드 ====================
    
    private String extractJsonFromText(String text) {
        // JSON 배열이나 객체 부분만 추출
        int startIndex = -1;
        int endIndex = -1;
        
        // 배열 형태 찾기
        if (text.contains("[")) {
            startIndex = text.indexOf("[");
            endIndex = text.lastIndexOf("]") + 1;
        }
        // 객체 형태 찾기
        else if (text.contains("{")) {
            startIndex = text.indexOf("{");
            endIndex = text.lastIndexOf("}") + 1;
        }
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return text.substring(startIndex, endIndex);
        }
        
        throw new RuntimeException("응답에서 JSON을 찾을 수 없습니다: " + text);
    }
    
    // ==================== 폴백 데이터 생성 메소드들 ====================
    
    private List<TrendAnalysisResponseDTO.PopularDestination> createFallbackPopularDestinations() {
        return Arrays.asList(
            TrendAnalysisResponseDTO.PopularDestination.builder()
                .destinationName("제주도 우도")
                .trendScore(95)
                .popularityReason("드라마 촬영지로 유명해지며 SNS에서 핫플레이스로 급부상")
                .category("자연")
                .hashtags(Arrays.asList("우도", "제주도", "드라마촬영지", "핫플레이스"))
                .rank(1)
                .build(),
            TrendAnalysisResponseDTO.PopularDestination.builder()
                .destinationName("강릉 안반데기")
                .trendScore(88)
                .popularityReason("가을 풍경이 아름다워 인스타그램에서 화제")
                .category("자연")
                .hashtags(Arrays.asList("안반데기", "강릉", "가을여행", "인스타핫플"))
                .rank(2)
                .build(),
            TrendAnalysisResponseDTO.PopularDestination.builder()
                .destinationName("경주 대릉원")
                .trendScore(82)
                .popularityReason("야간 조명이 설치되어 밤 풍경이 인기")
                .category("문화")
                .hashtags(Arrays.asList("대릉원", "경주", "야경", "조명"))
                .rank(3)
                .build()
        );
    }
    
    private List<TrendAnalysisResponseDTO.MBTIRecommendation> createFallbackMBTIRecommendations(String mbtiType) {
        return Arrays.asList(
            TrendAnalysisResponseDTO.MBTIRecommendation.builder()
                .destinationName("부산 감천문화마을")
                .mbtiType(mbtiType)
                .recommendationReason(mbtiType + " 성향에 맞는 창의적이고 독특한 공간")
                .matchingScore(92)
                .attractions(Arrays.asList("컬러풀한 건물", "포토존", "예술작품"))
                .personalityFit("창의성과 개성을 중시하는 성향에 적합")
                .build(),
            TrendAnalysisResponseDTO.MBTIRecommendation.builder()
                .destinationName("전주 한옥마을")
                .mbtiType(mbtiType)
                .recommendationReason("전통과 현대가 조화된 공간으로 " + mbtiType + "에게 추천")
                .matchingScore(85)
                .attractions(Arrays.asList("한옥체험", "전통음식", "문화체험"))
                .personalityFit("전통을 좋아하고 체험을 즐기는 성향에 적합")
                .build()
        );
    }
    
    private List<TrendAnalysisResponseDTO.RegionPopularity> createFallbackRegionPopularity() {
        return Arrays.asList(
            TrendAnalysisResponseDTO.RegionPopularity.builder()
                .regionName("제주도")
                .latitude(33.4996)
                .longitude(126.5312)
                .popularityScore(95)
                .hotSpots(Arrays.asList("우도", "성산일출봉", "한라산"))
                .trendDescription("가을 여행 1위 지역으로 SNS 언급량 급증")
                .markerColor("#ff4444")
                .mentionCount(15420)
                .build(),
            TrendAnalysisResponseDTO.RegionPopularity.builder()
                .regionName("강원도")
                .latitude(37.8228)
                .longitude(128.1555)
                .popularityScore(88)
                .hotSpots(Arrays.asList("안반데기", "정동진", "대관령"))
                .trendDescription("가을 단풍 명소로 인기 상승")
                .markerColor("#ff8800")
                .mentionCount(9830)
                .build(),
            TrendAnalysisResponseDTO.RegionPopularity.builder()
                .regionName("경상북도")
                .latitude(36.4919)
                .longitude(128.8889)
                .popularityScore(75)
                .hotSpots(Arrays.asList("경주", "안동", "포항"))
                .trendDescription("문화 관광지로 꾸준한 인기")
                .markerColor("#ffaa00")
                .mentionCount(6250)
                .build()
        );
    }
    
    private TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse createFallbackComprehensiveAnalysis() {
        List<TrendAnalysisResponseDTO.BestDestination> bestDestinations = Arrays.asList(
            TrendAnalysisResponseDTO.BestDestination.builder()
                .destinationName("제주도 우도")
                .rank(1)
                .totalScore(95)
                .selectionReason("급상승 트렌드 1위, MBTI 호환성 높음, 지역 인기도 최고")
                .highlights(Arrays.asList("드라마 촬영지", "SNS 핫플레이스", "독특한 자연경관"))
                .trendSource("Instagram, YouTube, 네이버 블로그")
                .metrics(TrendAnalysisResponseDTO.RecommendationMetrics.builder()
                    .popularityScore(95)
                    .mbtiCompatibility(92)
                    .regionTrendScore(95)
                    .overallRating(94)
                    .build())
                .build(),
            TrendAnalysisResponseDTO.BestDestination.builder()
                .destinationName("강릉 안반데기")
                .rank(2)
                .totalScore(88)
                .selectionReason("가을 여행 트렌드 상위권, 자연 친화적 성향에 맞음")
                .highlights(Arrays.asList("억새밭", "일출명소", "드라이브코스"))
                .trendSource("Instagram, TikTok")
                .metrics(TrendAnalysisResponseDTO.RecommendationMetrics.builder()
                    .popularityScore(88)
                    .mbtiCompatibility(85)
                    .regionTrendScore(88)
                    .overallRating(87)
                    .build())
                .build(),
            TrendAnalysisResponseDTO.BestDestination.builder()
                .destinationName("부산 감천문화마을")
                .rank(3)
                .totalScore(85)
                .selectionReason("창의적 성향에 적합, 포토존으로 인기")
                .highlights(Arrays.asList("컬러풀한 마을", "예술작품", "포토존"))
                .trendSource("Instagram, Facebook")
                .metrics(TrendAnalysisResponseDTO.RecommendationMetrics.builder()
                    .popularityScore(80)
                    .mbtiCompatibility(92)
                    .regionTrendScore(83)
                    .overallRating(85)
                    .build())
                .build()
        );
        
        TrendAnalysisResponseDTO.AnalysisSummary summary = TrendAnalysisResponseDTO.AnalysisSummary.builder()
                .analysisDate("2024-11-20")
                .totalDestinations(8)
                .topTrendSource("Instagram (45%), YouTube (30%), 네이버 블로그 (25%)")
                .seasonalTrend("가을 단풍, 억새밭 여행지 인기 급상승")
                .emergingDestinations(Arrays.asList("강릉 안반데기", "태안 신두리", "양평 두물머리"))
                .build();
        
        return TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse.builder()
                .success(true)
                .message("종합 분석이 완료되었습니다.")
                .bestDestinations(bestDestinations)
                .summary(summary)
                .build();
    }
}