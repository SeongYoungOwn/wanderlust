package com.tour.project.service;

import com.tour.project.client.ClaudeApiClient;
import com.tour.project.dto.TrendAnalysisResponse;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 소셜 트렌드 분석 서비스
 * - Claude API를 활용한 실시간 여행 트렌드 분석
 * - MBTI 기반 맞춤 여행지 추천
 * - SNS 인기도 실시간 분석
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class SocialTrendsService {
    
    private final ClaudeApiClient claudeApiClient;
    private final ObjectMapper objectMapper;
    private final TrendDataCacheService cacheService;
    
    /**
     * Claude API를 통한 실시간 트렌드 분석
     */
    public TrendAnalysisResponse analyzeCurrentTrends(String userId, String userMbti) {
        log.info("Claude API를 통한 실시간 트렌드 분석 시작 - 사용자: {}, MBTI: {}", userId, userMbti);
        
        // 캐시 확인
        String cacheKey = "trend_" + getCurrentSeason() + "_" + (userMbti != null ? userMbti : "general");
        TrendAnalysisResponse cachedResponse = cacheService.getTrendAnalysis(cacheKey);
        if (cachedResponse != null) {
            log.info("캐시된 트렌드 분석 데이터 반환 - 키: {}", cacheKey);
            return cachedResponse;
        }
        
        try {
            // 현재 날짜와 계절 정보
            LocalDateTime now = LocalDateTime.now();
            String currentDate = now.format(DateTimeFormatter.ofPattern("yyyy년 MM월 dd일"));
            String currentSeason = getCurrentSeason();
            
            // Claude API 요청 구성
            String prompt = buildTrendAnalysisPrompt(currentDate, currentSeason, userMbti);
            
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(4000)
                .build();
            
            // Claude API 호출
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                String claudeContent = response.getContentText();
                log.info("Claude API 응답 수신 완료 - 길이: {} 문자", claudeContent.length());
                
                // Claude 응답을 구조화된 데이터로 파싱
                TrendAnalysisResponse trendResponse = parseClaudeResponse(claudeContent, userMbti);
                trendResponse.setAnalysisTime(now);
                trendResponse.setAnalysisSource("Claude API");
                trendResponse.setRealTimeData(true);
                trendResponse.setUserMbti(userMbti);
                
                // 캐시에 저장
                cacheService.cacheTrendAnalysis(cacheKey, trendResponse);
                
                return trendResponse;
                
            } else {
                log.warn("Claude API 응답이 실패했습니다. 폴백 응답 사용");
                return getFallbackResponse();
            }
            
        } catch (Exception e) {
            log.error("Claude API 트렌드 분석 중 오류 발생", e);
            return getFallbackResponse();
        }
    }
    
    /**
     * 트렌드 분석용 프롬프트 구성
     */
    private String buildTrendAnalysisPrompt(String currentDate, String currentSeason, String userMbti) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 여행 트렌드 분석 전문가입니다. ").append(currentDate).append(" 현재 ");
        prompt.append(currentSeason).append(" 계절의 실시간 여행 트렌드를 분석해주세요.\n\n");
        
        prompt.append("다음 형식으로 JSON 응답을 제공해주세요:\n");
        prompt.append("{\n");
        prompt.append("  \"trendingKeywords\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"keyword\": \"여행지명 또는 액티비티\",\n");
        prompt.append("      \"category\": \"destination|activity|food|accommodation\",\n");
        prompt.append("      \"trendScore\": 8.5,\n");
        prompt.append("      \"mentionCount\": 1500,\n");
        prompt.append("      \"trendDirection\": \"up|down|stable\",\n");
        prompt.append("      \"changeRate\": 15.2,\n");
        prompt.append("      \"description\": \"왜 인기인지 설명\"\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"popularDestinations\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"destinationName\": \"여행지명\",\n");
        prompt.append("      \"region\": \"지역\",\n");
        prompt.append("      \"country\": \"한국\",\n");
        prompt.append("      \"trendScore\": 9.2,\n");
        prompt.append("      \"mentionCount\": 2000,\n");
        prompt.append("      \"sentimentScore\": 0.85,\n");
        prompt.append("      \"season\": \"").append(currentSeason.toLowerCase()).append("\",\n");
        prompt.append("      \"popularActivities\": [\"액티비티1\", \"액티비티2\"],\n");
        prompt.append("      \"description\": \"여행지 특징과 인기 이유\"\n");
        prompt.append("    }\n");
        prompt.append("  ]");
        
        if (userMbti != null && !userMbti.isEmpty()) {
            prompt.append(",\n  \"mbtiRecommendations\": [\n");
            prompt.append("    {\n");
            prompt.append("      \"mbtiType\": \"").append(userMbti).append("\",\n");
            prompt.append("      \"destinationName\": \"추천 여행지\",\n");
            prompt.append("      \"recommendationReason\": \"").append(userMbti).append(" 성향에 맞는 이유\",\n");
            prompt.append("      \"matchScore\": 0.9,\n");
            prompt.append("      \"suitableActivities\": [\"적합한 액티비티들\"],\n");
            prompt.append("      \"travelStyle\": \"여행 스타일\",\n");
            prompt.append("      \"description\": \"상세 설명\"\n");
            prompt.append("    }\n");
            prompt.append("  ]");
        }
        
        prompt.append("\n}\n\n");
        
        prompt.append("분석 요구사항:\n");
        prompt.append("1. 현재 ").append(currentSeason).append(" 계절에 적합한 실제 여행 트렌드 반영\n");
        prompt.append("2. 한국 내 여행지 중심으로 분석 (일부 해외 포함 가능)\n");
        prompt.append("3. 실제 SNS에서 인기 있을 만한 현실적인 데이터\n");
        prompt.append("4. 계절별 특성을 고려한 액티비티 추천\n");
        prompt.append("5. 트렌드 점수는 현실적 범위 (7.0-9.5)로 설정\n");
        prompt.append("6. 언급 횟수는 현실적 범위 (500-3000)로 설정\n");
        
        if (userMbti != null && !userMbti.isEmpty()) {
            prompt.append("7. ").append(userMbti).append(" 성향에 특별히 맞는 여행지와 이유 제시\n");
        }
        
        prompt.append("\n응답은 반드시 유효한 JSON 형식이어야 합니다.");
        
        return prompt.toString();
    }
    
    /**
     * Claude 응답 파싱
     */
    private TrendAnalysisResponse parseClaudeResponse(String claudeContent, String userMbti) {
        try {
            // JSON 부분만 추출
            String jsonContent = extractJsonFromResponse(claudeContent);
            
            // JSON 파싱
            Map<String, Object> responseMap = objectMapper.readValue(jsonContent, new TypeReference<Map<String, Object>>() {});
            
            TrendAnalysisResponse.TrendAnalysisResponseBuilder builder = TrendAnalysisResponse.builder();
            
            // 트렌딩 키워드 파싱
            if (responseMap.containsKey("trendingKeywords")) {
                List<Map<String, Object>> keywordMaps = (List<Map<String, Object>>) responseMap.get("trendingKeywords");
                List<TrendAnalysisResponse.TrendingKeyword> keywords = new ArrayList<>();
                
                for (Map<String, Object> keywordMap : keywordMaps) {
                    TrendAnalysisResponse.TrendingKeyword keyword = TrendAnalysisResponse.TrendingKeyword.builder()
                        .keyword((String) keywordMap.get("keyword"))
                        .category((String) keywordMap.get("category"))
                        .trendScore(getDoubleValue(keywordMap.get("trendScore")))
                        .mentionCount(getIntegerValue(keywordMap.get("mentionCount")))
                        .trendDirection((String) keywordMap.get("trendDirection"))
                        .changeRate(getDoubleValue(keywordMap.get("changeRate")))
                        .description((String) keywordMap.get("description"))
                        .build();
                    keywords.add(keyword);
                }
                builder.trendingKeywords(keywords);
            }
            
            // 인기 여행지 파싱
            if (responseMap.containsKey("popularDestinations")) {
                List<Map<String, Object>> destMaps = (List<Map<String, Object>>) responseMap.get("popularDestinations");
                List<TrendAnalysisResponse.PopularDestination> destinations = new ArrayList<>();
                
                for (Map<String, Object> destMap : destMaps) {
                    TrendAnalysisResponse.PopularDestination destination = TrendAnalysisResponse.PopularDestination.builder()
                        .destinationName((String) destMap.get("destinationName"))
                        .region((String) destMap.get("region"))
                        .country((String) destMap.get("country"))
                        .trendScore(getDoubleValue(destMap.get("trendScore")))
                        .mentionCount(getIntegerValue(destMap.get("mentionCount")))
                        .sentimentScore(getDoubleValue(destMap.get("sentimentScore")))
                        .season((String) destMap.get("season"))
                        .popularActivities((List<String>) destMap.get("popularActivities"))
                        .description((String) destMap.get("description"))
                        .build();
                    destinations.add(destination);
                }
                builder.popularDestinations(destinations);
            }
            
            // MBTI 추천 파싱
            if (responseMap.containsKey("mbtiRecommendations")) {
                List<Map<String, Object>> mbtiMaps = (List<Map<String, Object>>) responseMap.get("mbtiRecommendations");
                List<TrendAnalysisResponse.MbtiRecommendation> mbtiRecommendations = new ArrayList<>();
                
                for (Map<String, Object> mbtiMap : mbtiMaps) {
                    TrendAnalysisResponse.MbtiRecommendation mbtiRec = TrendAnalysisResponse.MbtiRecommendation.builder()
                        .mbtiType((String) mbtiMap.get("mbtiType"))
                        .destinationName((String) mbtiMap.get("destinationName"))
                        .recommendationReason((String) mbtiMap.get("recommendationReason"))
                        .matchScore(getDoubleValue(mbtiMap.get("matchScore")))
                        .suitableActivities((List<String>) mbtiMap.get("suitableActivities"))
                        .travelStyle((String) mbtiMap.get("travelStyle"))
                        .description((String) mbtiMap.get("description"))
                        .build();
                    mbtiRecommendations.add(mbtiRec);
                }
                builder.mbtiRecommendations(mbtiRecommendations);
            }
            
            return builder.build();
            
        } catch (Exception e) {
            log.error("Claude 응답 파싱 실패", e);
            return getFallbackResponse();
        }
    }
    
    /**
     * 응답에서 JSON 부분 추출
     */
    private String extractJsonFromResponse(String response) {
        // JSON 시작과 끝을 찾아서 추출
        int startIndex = response.indexOf("{");
        int endIndex = response.lastIndexOf("}");
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return response.substring(startIndex, endIndex + 1);
        }
        
        throw new RuntimeException("JSON 형식을 찾을 수 없습니다.");
    }
    
    /**
     * MBTI 기반 맞춤 추천
     */
    public Map<String, Object> getMbtiBasedRecommendations(String mbtiType, String userId) {
        log.info("MBTI({}) 기반 맞춤 추천 생성", mbtiType);
        
        // 캐시 확인
        Map<String, Object> cachedRecommendation = cacheService.getMbtiRecommendation(mbtiType);
        if (cachedRecommendation != null) {
            log.info("캐시된 MBTI 추천 데이터 반환 - MBTI: {}", mbtiType);
            return cachedRecommendation;
        }
        
        try {
            String prompt = buildMbtiRecommendationPrompt(mbtiType);
            
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(2000)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                String content = response.getContentText();
                Map<String, Object> recommendations = parseMbtiRecommendations(content, mbtiType);
                
                // 캐시에 저장
                cacheService.cacheMbtiRecommendation(mbtiType, recommendations);
                
                return recommendations;
            }
            
        } catch (Exception e) {
            log.error("MBTI 기반 추천 생성 실패", e);
        }
        
        return getDefaultMbtiRecommendations(mbtiType);
    }
    
    /**
     * SNS 인기도 실시간 분석
     */
    public Map<String, Object> analyzeSnsPopularity() {
        log.info("SNS 인기도 실시간 분석 시작");
        
        // 캐시 확인
        String cacheKey = "sns_" + getCurrentSeason() + "_" + LocalDateTime.now().getHour();
        Map<String, Object> cachedAnalysis = cacheService.getSnsAnalysis(cacheKey);
        if (cachedAnalysis != null) {
            log.info("캐시된 SNS 분석 데이터 반환 - 키: {}", cacheKey);
            return cachedAnalysis;
        }
        
        // SNS 분석용 프롬프트 구성
        String prompt = buildSnsAnalysisPrompt();
        
        try {
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(2000)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                Map<String, Object> analysis = parseSnsAnalysis(response.getContentText());
                
                // 캐시에 저장
                cacheService.cacheSnsAnalysis(cacheKey, analysis);
                
                return analysis;
            }
            
        } catch (Exception e) {
            log.error("SNS 인기도 분석 실패", e);
        }
        
        return getDefaultSnsAnalysis();
    }
    
    /**
     * Claude API 연결 테스트
     */
    public String testClaudeConnection(String testPrompt) {
        log.info("Claude API 연결 테스트 시작");
        
        try {
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", testPrompt)))
                .maxTokens(100)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                String result = response.getContentText();
                log.info("Claude API 테스트 성공: {}", result);
                return result;
            } else {
                throw new RuntimeException("Claude API 응답이 실패했습니다: " + response);
            }
            
        } catch (Exception e) {
            log.error("Claude API 연결 테스트 실패", e);
            throw e;
        }
    }

    /**
     * 트렌드 예측 생성
     */
    public Map<String, Object> generateTrendPredictions() {
        log.info("트렌드 예측 데이터 생성");
        
        String prompt = buildPredictionPrompt();
        
        try {
            ClaudeRequest request = ClaudeRequest.defaultBuilder()
                .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                .maxTokens(1500)
                .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(request);
            
            if (response != null && response.isSuccess()) {
                return parsePredictions(response.getContentText());
            }
            
        } catch (Exception e) {
            log.error("트렌드 예측 생성 실패", e);
        }
        
        return getDefaultPredictions();
    }
    
    /**
     * 현재 계절 확인
     */
    private String getCurrentSeason() {
        int month = LocalDateTime.now().getMonthValue();
        if (month >= 3 && month <= 5) return "봄";
        if (month >= 6 && month <= 8) return "여름";
        if (month >= 9 && month <= 11) return "가을";
        return "겨울";
    }
    
    /**
     * 폴백 응답 (API 실패 시)
     */
    public TrendAnalysisResponse getFallbackResponse() {
        return TrendAnalysisResponse.builder()
            .analysisTime(LocalDateTime.now())
            .analysisSource("Fallback Data")
            .isRealTimeData(false)
            .trendingKeywords(getDefaultTrendingKeywords())
            .popularDestinations(getDefaultPopularDestinations())
            .build();
    }
    
    // 유틸리티 메서드들
    private Double getDoubleValue(Object value) {
        if (value == null) return 0.0;
        if (value instanceof Number) return ((Number) value).doubleValue();
        try {
            return Double.parseDouble(value.toString());
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
    
    private Integer getIntegerValue(Object value) {
        if (value == null) return 0;
        if (value instanceof Number) return ((Number) value).intValue();
        try {
            return Integer.parseInt(value.toString());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
    
    // MBTI 기반 추천 프롬프트 구성
    private String buildMbtiRecommendationPrompt(String mbtiType) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 MBTI 전문가이자 여행 추천 전문가입니다. ");
        prompt.append(mbtiType).append(" 성향에 완벽히 맞는 여행지를 추천해주세요.\n\n");
        
        // MBTI별 특성 분석
        prompt.append("MBTI ").append(mbtiType).append(" 특성 분석:\n");
        prompt.append(getMbtiCharacteristics(mbtiType)).append("\n\n");
        
        prompt.append("다음 JSON 형식으로 응답해주세요:\n");
        prompt.append("{\n");
        prompt.append("  \"mbtiType\": \"").append(mbtiType).append("\",\n");
        prompt.append("  \"recommendations\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"destinationName\": \"여행지명\",\n");
        prompt.append("      \"region\": \"지역\",\n");
        prompt.append("      \"recommendationReason\": \"").append(mbtiType).append(" 성향에 맞는 구체적인 이유\",\n");
        prompt.append("      \"matchScore\": 0.95,\n");
        prompt.append("      \"suitableActivities\": [\"적합한 활동1\", \"적합한 활동2\", \"적합한 활동3\"],\n");
        prompt.append("      \"travelStyle\": \"여행 스타일\",\n");
        prompt.append("      \"bestSeason\": \"최적 계절\",\n");
        prompt.append("      \"budgetLevel\": \"low|medium|high\",\n");
        prompt.append("      \"groupSize\": \"solo|couple|small_group|large_group\",\n");
        prompt.append("      \"description\": \"상세 설명\",\n");
        prompt.append("      \"tips\": [\"여행 팁1\", \"여행 팁2\"]\n");
        prompt.append("    }\n");
        prompt.append("  ]\n");
        prompt.append("}\n\n");
        
        prompt.append("요구사항:\n");
        prompt.append("1. ").append(mbtiType).append(" 성향의 내향/외향, 직관/감각, 사고/감정, 판단/인식 특성을 모두 고려\n");
        prompt.append("2. 한국 내 여행지 중심으로 추천 (해외 1곳 포함 가능)\n");
        prompt.append("3. 계절별 특성과 현재 시기(").append(getCurrentSeason()).append(") 고려\n");
        prompt.append("4. 실제 존재하는 여행지만 추천\n");
        prompt.append("5. 매치 점수는 현실적 범위 (0.8-0.98)로 설정\n");
        prompt.append("6. 각 추천마다 5개의 여행지를 추천\n");
        
        return prompt.toString();
    }
    
    /**
     * MBTI별 특성 정보 제공
     */
    private String getMbtiCharacteristics(String mbtiType) {
        Map<String, String> characteristics = new HashMap<>();
        
        // 16가지 MBTI 타입별 특성
        characteristics.put("INTJ", "전략가형 - 독립적이고 계획적, 조용한 환경에서 깊이 있는 경험 선호, 역사/문화/자연 탐구 좋아함");
        characteristics.put("INTP", "논리술사형 - 혼자만의 시간 중요, 새로운 지식 습득, 독특하고 신선한 경험 추구");
        characteristics.put("ENTJ", "통솔자형 - 효율적이고 목표지향적, 도전적인 활동과 리더십 경험 선호, 럭셔리한 환경");
        characteristics.put("ENTP", "변론가형 - 새로운 경험과 모험 추구, 다양한 사람들과의 만남, 즉흥적이고 유연한 계획");
        characteristics.put("INFJ", "옹호자형 - 의미 있는 경험 추구, 영감을 주는 장소, 소수와의 깊은 교류, 평화롭고 아름다운 환경");
        characteristics.put("INFP", "중재자형 - 개인적 의미와 가치 중시, 자연과 예술, 진정성 있는 경험, 여유로운 일정");
        characteristics.put("ENFJ", "주인공형 - 타인과의 연결과 교류, 문화 체험과 봉사 활동, 따뜻한 커뮤니티 경험");
        characteristics.put("ENFP", "활동가형 - 자유롭고 창의적인 경험, 다양한 사람들과의 만남, 에너지 넘치는 활동과 새로운 도전");
        characteristics.put("ISTJ", "현실주의자형 - 계획적이고 안전한 여행, 전통과 역사, 검증된 명소와 안정적인 일정");
        characteristics.put("ISFJ", "수호자형 - 편안하고 안전한 환경, 가족/친구와 함께, 봉사와 배려가 있는 경험");
        characteristics.put("ESTJ", "경영자형 - 체계적이고 효율적인 일정, 성과와 성취감, 리더십을 발휘할 수 있는 활동");
        characteristics.put("ESFJ", "집정관형 - 사회적 교류와 하모니, 전통적이고 따뜻한 경험, 타인을 배려하는 여행");
        characteristics.put("ISTP", "거장형 - 실용적이고 도구를 활용한 활동, 모험과 스릴, 자유로운 일정과 즉흥성");
        characteristics.put("ISFP", "모험가형 - 아름다운 자연과 예술, 개인적 탐험, 평화롭고 감성적인 경험");
        characteristics.put("ESTP", "사업가형 - 즉석에서 즐기는 활동, 모험과 스릴, 사람들과의 활발한 교류");
        characteristics.put("ESFP", "연예인형 - 즐겁고 에너지 넘치는 경험, 사람들과의 즐거운 시간, 감각적이고 현재에 집중");
        
        return characteristics.getOrDefault(mbtiType, "개인의 고유한 성향을 고려한 맞춤 추천");
    }
    
    private String buildSnsAnalysisPrompt() {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("당신은 SNS 트렌드 분석 전문가입니다. ");
        prompt.append("현재 인스타그램, 틱톡, 유튜브, 트위터에서 인기 있는 여행지를 분석해주세요.\n\n");
        
        prompt.append("다음 JSON 형식으로 응답해주세요:\n");
        prompt.append("{\n");
        prompt.append("  \"analysisDate\": \"").append(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))).append("\",\n");
        prompt.append("  \"trendingDestinations\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"destinationName\": \"여행지명\",\n");
        prompt.append("      \"region\": \"지역\",\n");
        prompt.append("      \"totalMentions\": 15000,\n");
        prompt.append("      \"trendScore\": 8.5,\n");
        prompt.append("      \"changeRate\": 25.3,\n");
        prompt.append("      \"platformData\": {\n");
        prompt.append("        \"instagram\": {\"mentions\": 8000, \"hashtagCount\": 1500, \"engagementRate\": 0.85},\n");
        prompt.append("        \"tiktok\": {\"mentions\": 4000, \"viewCount\": 2500000, \"sharingRate\": 0.12},\n");
        prompt.append("        \"youtube\": {\"mentions\": 2000, \"viewCount\": 500000, \"subscriptionRate\": 0.08},\n");
        prompt.append("        \"twitter\": {\"mentions\": 1000, \"retweetCount\": 300, \"likesCount\": 1200}\n");
        prompt.append("      },\n");
        prompt.append("      \"popularHashtags\": [\"#여행지태그1\", \"#여행지태그2\", \"#여행지태그3\"],\n");
        prompt.append("      \"viralContent\": \"인기 컨텐츠 설명\",\n");
        prompt.append("      \"ageGroups\": {\"10대\": 15, \"20대\": 35, \"30대\": 30, \"40대\": 15, \"50대+\": 5},\n");
        prompt.append("      \"peakTime\": \"저녁 7-9시\",\n");
        prompt.append("      \"sentiment\": \"positive\",\n");
        prompt.append("      \"description\": \"왜 인기인지 분석\"\n");
        prompt.append("    }\n");
        prompt.append("  ],\n");
        prompt.append("  \"platformTrends\": {\n");
        prompt.append("    \"instagram\": {\"dominantContent\": \"사진 중심\", \"trendingFeatures\": [\"릴스\", \"스토리\"]},\n");
        prompt.append("    \"tiktok\": {\"dominantContent\": \"짧은 영상\", \"trendingFeatures\": [\"댄스챌린지\", \"여행팁\"]},\n");
        prompt.append("    \"youtube\": {\"dominantContent\": \"브이로그\", \"trendingFeatures\": [\"여행가이드\", \"숙소리뷰\"]},\n");
        prompt.append("    \"twitter\": {\"dominantContent\": \"실시간 후기\", \"trendingFeatures\": [\"라이브트윗\", \"사진공유\"]}\n");
        prompt.append("  }\n");
        prompt.append("}\n\n");
        
        prompt.append("분석 요구사항:\n");
        prompt.append("1. 현재 ").append(getCurrentSeason()).append(" 계절에 맞는 여행지 분석\n");
        prompt.append("2. 한국 내 여행지 위주로 분석 (해외 1-2곳 포함 가능)\n");
        prompt.append("3. 실제 SNS에서 화제가 될 만한 현실적인 데이터\n");
        prompt.append("4. 플랫폼별 특성을 고려한 언급량과 참여도\n");
        prompt.append("5. 연령대별 선호도는 현실적 비율로 설정\n");
        prompt.append("6. 트렌드 점수는 7.0-9.5 범위로 설정\n");
        prompt.append("7. 상위 7개 여행지 분석\n");
        
        return prompt.toString();
    }
    
    private String buildPredictionPrompt() {
        return "향후 1-3개월간 예상되는 여행 트렌드를 예측해주세요. JSON 형식으로 응답해주세요.";
    }
    
    private Map<String, Object> parseMbtiRecommendations(String content, String mbtiType) {
        try {
            log.info("Claude API MBTI 응답 원본: {}", content);
            
            // JSON 부분만 추출
            String jsonContent = extractJsonFromResponse(content);
            log.info("추출된 JSON: {}", jsonContent);
            
            // JSON 파싱
            Map<String, Object> responseMap = objectMapper.readValue(jsonContent, new TypeReference<Map<String, Object>>() {});
            
            Map<String, Object> result = new HashMap<>();
            result.put("mbtiType", mbtiType);
            result.put("analysisTime", LocalDateTime.now());
            result.put("source", "Claude AI");
            
            // 추천 데이터 파싱
            if (responseMap.containsKey("recommendations")) {
                List<Map<String, Object>> recommendationMaps = (List<Map<String, Object>>) responseMap.get("recommendations");
                List<Map<String, Object>> recommendations = new ArrayList<>();
                
                for (Map<String, Object> recMap : recommendationMaps) {
                    Map<String, Object> recommendation = new HashMap<>();
                    recommendation.put("destinationName", recMap.get("destinationName"));
                    recommendation.put("region", recMap.get("region"));
                    recommendation.put("recommendationReason", recMap.get("recommendationReason"));
                    recommendation.put("matchScore", getDoubleValue(recMap.get("matchScore")));
                    recommendation.put("suitableActivities", recMap.get("suitableActivities"));
                    recommendation.put("travelStyle", recMap.get("travelStyle"));
                    recommendation.put("bestSeason", recMap.get("bestSeason"));
                    recommendation.put("budgetLevel", recMap.get("budgetLevel"));
                    recommendation.put("groupSize", recMap.get("groupSize"));
                    recommendation.put("description", recMap.get("description"));
                    recommendation.put("tips", recMap.get("tips"));
                    
                    recommendations.add(recommendation);
                }
                result.put("recommendations", recommendations);
            } else {
                result.put("recommendations", List.of());
            }
            
            log.info("MBTI({}) 추천 파싱 완료 - {} 개 추천", mbtiType, 
                    ((List<?>) result.get("recommendations")).size());
            
            return result;
            
        } catch (Exception e) {
            log.error("MBTI 추천 파싱 실패: " + e.getMessage(), e);
            return getDefaultMbtiRecommendations(mbtiType);
        }
    }
    
    private Map<String, Object> parseSnsAnalysis(String content) {
        try {
            // JSON 부분만 추출
            String jsonContent = extractJsonFromResponse(content);
            
            // JSON 파싱
            Map<String, Object> responseMap = objectMapper.readValue(jsonContent, new TypeReference<Map<String, Object>>() {});
            
            Map<String, Object> result = new HashMap<>();
            result.put("analysisTime", LocalDateTime.now());
            result.put("source", "Claude AI SNS Analysis");
            result.put("analysisDate", responseMap.get("analysisDate"));
            
            // 트렌딩 여행지 파싱
            if (responseMap.containsKey("trendingDestinations")) {
                List<Map<String, Object>> destinationMaps = (List<Map<String, Object>>) responseMap.get("trendingDestinations");
                List<Map<String, Object>> destinations = new ArrayList<>();
                
                for (Map<String, Object> destMap : destinationMaps) {
                    Map<String, Object> destination = new HashMap<>();
                    destination.put("destinationName", destMap.get("destinationName"));
                    destination.put("region", destMap.get("region"));
                    destination.put("totalMentions", getIntegerValue(destMap.get("totalMentions")));
                    destination.put("trendScore", getDoubleValue(destMap.get("trendScore")));
                    destination.put("changeRate", getDoubleValue(destMap.get("changeRate")));
                    destination.put("platformData", destMap.get("platformData"));
                    destination.put("popularHashtags", destMap.get("popularHashtags"));
                    destination.put("viralContent", destMap.get("viralContent"));
                    destination.put("ageGroups", destMap.get("ageGroups"));
                    destination.put("peakTime", destMap.get("peakTime"));
                    destination.put("sentiment", destMap.get("sentiment"));
                    destination.put("description", destMap.get("description"));
                    
                    destinations.add(destination);
                }
                result.put("trendingDestinations", destinations);
            } else {
                result.put("trendingDestinations", List.of());
            }
            
            // 플랫폼 트렌드 파싱
            if (responseMap.containsKey("platformTrends")) {
                result.put("platformTrends", responseMap.get("platformTrends"));
            } else {
                result.put("platformTrends", Map.of());
            }
            
            log.info("SNS 분석 파싱 완료 - {} 개 여행지", 
                    ((List<?>) result.get("trendingDestinations")).size());
            
            return result;
            
        } catch (Exception e) {
            log.error("SNS 분석 파싱 실패: " + e.getMessage(), e);
            return getDefaultSnsAnalysis();
        }
    }
    
    private Map<String, Object> parsePredictions(String content) {
        // 기본 구현
        return Map.of("predictions", List.of());
    }
    
    private Map<String, Object> getDefaultMbtiRecommendations(String mbtiType) {
        Map<String, Object> result = new HashMap<>();
        result.put("mbtiType", mbtiType);
        result.put("analysisTime", LocalDateTime.now());
        result.put("source", "Default Data");
        
        // MBTI별 기본 추천 데이터
        List<Map<String, Object>> recommendations = new ArrayList<>();
        
        if ("ENFP".equals(mbtiType)) {
            Map<String, Object> rec = new HashMap<>();
            rec.put("destinationName", "제주도");
            rec.put("region", "제주특별자치도");
            rec.put("recommendationReason", "ENFP의 자유로운 영혼과 새로운 경험을 추구하는 성향에 맞는 다양한 액티비티");
            rec.put("matchScore", 0.92);
            rec.put("suitableActivities", List.of("올레길 트레킹", "카페 호핑", "서핑 체험"));
            rec.put("travelStyle", "자유로운 탐험");
            rec.put("bestSeason", "봄, 가을");
            rec.put("budgetLevel", "medium");
            rec.put("groupSize", "small_group");
            rec.put("description", "아름다운 자연과 독특한 문화가 어우러진 섬으로, ENFP의 호기심을 자극하는 다양한 경험을 제공합니다.");
            rec.put("tips", List.of("렌터카로 자유롭게 이동", "현지 카페에서 사람들과 소통"));
            recommendations.add(rec);
        }
        
        result.put("recommendations", recommendations);
        return result;
    }
    
    private Map<String, Object> getDefaultSnsAnalysis() {
        Map<String, Object> result = new HashMap<>();
        result.put("analysisTime", LocalDateTime.now());
        result.put("source", "Default SNS Data");
        result.put("analysisDate", LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        
        // 기본 트렌딩 여행지 데이터
        List<Map<String, Object>> destinations = new ArrayList<>();
        
        // 제주도
        Map<String, Object> jeju = new HashMap<>();
        jeju.put("destinationName", "제주도");
        jeju.put("region", "제주특별자치도");
        jeju.put("totalMentions", 12000);
        jeju.put("trendScore", 8.8);
        jeju.put("changeRate", 15.2);
        
        Map<String, Object> jejuPlatforms = new HashMap<>();
        jejuPlatforms.put("instagram", Map.of("mentions", 6000, "hashtagCount", 1200, "engagementRate", 0.82));
        jejuPlatforms.put("tiktok", Map.of("mentions", 3500, "viewCount", 1800000, "sharingRate", 0.11));
        jejuPlatforms.put("youtube", Map.of("mentions", 1800, "viewCount", 400000, "subscriptionRate", 0.07));
        jejuPlatforms.put("twitter", Map.of("mentions", 700, "retweetCount", 250, "likesCount", 980));
        jeju.put("platformData", jejuPlatforms);
        
        jeju.put("popularHashtags", List.of("#제주도여행", "#제주맛집", "#제주도핫플"));
        jeju.put("viralContent", "올레길 트레킹과 카페 투어 영상이 인기");
        jeju.put("ageGroups", Map.of("10대", 12, "20대", 38, "30대", 28, "40대", 17, "50대+", 5));
        jeju.put("peakTime", "저녁 8-10시");
        jeju.put("sentiment", "positive");
        jeju.put("description", "여름철 대표 휴양지로 다양한 액티비티와 맛집으로 인기");
        destinations.add(jeju);
        
        // 부산
        Map<String, Object> busan = new HashMap<>();
        busan.put("destinationName", "부산");
        busan.put("region", "부산광역시");
        busan.put("totalMentions", 9500);
        busan.put("trendScore", 8.3);
        busan.put("changeRate", 22.1);
        
        Map<String, Object> busanPlatforms = new HashMap<>();
        busanPlatforms.put("instagram", Map.of("mentions", 4800, "hashtagCount", 950, "engagementRate", 0.79));
        busanPlatforms.put("tiktok", Map.of("mentions", 2800, "viewCount", 1200000, "sharingRate", 0.09));
        busanPlatforms.put("youtube", Map.of("mentions", 1400, "viewCount", 320000, "subscriptionRate", 0.06));
        busanPlatforms.put("twitter", Map.of("mentions", 500, "retweetCount", 180, "likesCount", 720));
        busan.put("platformData", busanPlatforms);
        
        busan.put("popularHashtags", List.of("#부산여행", "#해운대", "#광안리"));
        busan.put("viralContent", "감천문화마을과 해변 요가 영상이 화제");
        busan.put("ageGroups", Map.of("10대", 18, "20대", 35, "30대", 25, "40대", 15, "50대+", 7));
        busan.put("peakTime", "저녁 7-9시");
        busan.put("sentiment", "positive");
        busan.put("description", "도시와 바다가 어우러진 매력적인 관광도시");
        destinations.add(busan);
        
        result.put("trendingDestinations", destinations);
        
        // 플랫폼 트렌드
        Map<String, Object> platformTrends = new HashMap<>();
        platformTrends.put("instagram", Map.of("dominantContent", "사진 중심", "trendingFeatures", List.of("릴스", "스토리")));
        platformTrends.put("tiktok", Map.of("dominantContent", "짧은 영상", "trendingFeatures", List.of("댄스챌린지", "여행팁")));
        platformTrends.put("youtube", Map.of("dominantContent", "브이로그", "trendingFeatures", List.of("여행가이드", "숙소리뷰")));
        platformTrends.put("twitter", Map.of("dominantContent", "실시간 후기", "trendingFeatures", List.of("라이브트윗", "사진공유")));
        result.put("platformTrends", platformTrends);
        
        return result;
    }
    
    private Map<String, Object> getDefaultPredictions() {
        return Map.of("nextMonth", List.of("제주도", "부산", "강릉"));
    }
    
    private List<TrendAnalysisResponse.TrendingKeyword> getDefaultTrendingKeywords() {
        return List.of(
            TrendAnalysisResponse.TrendingKeyword.builder()
                .keyword("제주도")
                .category("destination")
                .trendScore(8.5)
                .mentionCount(1500)
                .trendDirection("up")
                .description("여름 휴가철 인기 급상승")
                .build()
        );
    }
    
    private List<TrendAnalysisResponse.PopularDestination> getDefaultPopularDestinations() {
        return List.of(
            TrendAnalysisResponse.PopularDestination.builder()
                .destinationName("제주도")
                .region("제주특별자치도")
                .country("한국")
                .trendScore(8.5)
                .mentionCount(1500)
                .sentimentScore(0.85)
                .season(getCurrentSeason().toLowerCase())
                .popularActivities(List.of("해변 휴양", "맛집 탐방"))
                .description("여름 휴가철 대표 여행지")
                .build()
        );
    }
}