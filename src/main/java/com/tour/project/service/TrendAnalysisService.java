package com.tour.project.service;

import com.tour.project.dto.trend.TrendAnalysisResponseDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 트렌드 분석 서비스
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TrendAnalysisService {
    
    private final ClaudeAnalysisService claudeAnalysisService;
    
    // 임시 데이터 저장소 (추후 Redis나 DB로 교체)
    private final ConcurrentHashMap<String, Object> analysisCache = new ConcurrentHashMap<>();
    
    /**
     * 1단계: 급상승 여행지 분석
     */
    public TrendAnalysisResponseDTO.PopularDestinationsResponse analyzePopularDestinations(String userId) {
        try {
            log.info("급상승 여행지 분석 시작 - 사용자: {}", userId);
            
            // Claude API를 통한 실제 트렌드 분석
            List<TrendAnalysisResponseDTO.PopularDestination> destinations = 
                claudeAnalysisService.analyzeTrends("급상승 여행지 분석");
            
            // 캐시에 저장
            analysisCache.put(userId + "_popular", destinations);
            
            return TrendAnalysisResponseDTO.PopularDestinationsResponse.builder()
                    .success(true)
                    .message("급상승 여행지 분석이 완료되었습니다.")
                    .destinations(destinations)
                    .analysisTime(LocalDateTime.now())
                    .analysisStep("1/4")
                    .build();
                    
        } catch (Exception e) {
            log.error("급상승 여행지 분석 실패", e);
            return TrendAnalysisResponseDTO.PopularDestinationsResponse.builder()
                    .success(false)
                    .message("급상승 여행지 분석 중 오류가 발생했습니다.")
                    .build();
        }
    }
    
    /**
     * 2단계: MBTI 기반 맞춤 추천
     */
    public TrendAnalysisResponseDTO.MBTIRecommendationResponse getMBTIRecommendations(String userId, String mbtiType) {
        try {
            log.info("MBTI 맞춤 추천 시작 - 사용자: {}, MBTI: {}", userId, mbtiType);
            
            // MBTI 테스트 확인
            if (mbtiType == null || mbtiType.isEmpty()) {
                return TrendAnalysisResponseDTO.MBTIRecommendationResponse.builder()
                        .success(false)
                        .message("MBTI 테스트가 필요합니다.")
                        .mbtiTestRequired(true)
                        .analysisStep("2/4")
                        .build();
            }
            
            // Claude API를 통한 MBTI 맞춤 추천
            List<TrendAnalysisResponseDTO.MBTIRecommendation> recommendations = 
                claudeAnalysisService.analyzeMBTITrends("MBTI 맞춤 추천", mbtiType);
            
            // 캐시에 저장
            analysisCache.put(userId + "_mbti", recommendations);
            
            return TrendAnalysisResponseDTO.MBTIRecommendationResponse.builder()
                    .success(true)
                    .message("MBTI 맞춤 추천이 완료되었습니다.")
                    .mbtiType(mbtiType)
                    .recommendations(recommendations)
                    .analysisTime(LocalDateTime.now())
                    .analysisStep("2/4")
                    .mbtiTestRequired(false)
                    .build();
                    
        } catch (Exception e) {
            log.error("MBTI 맞춤 추천 실패", e);
            return TrendAnalysisResponseDTO.MBTIRecommendationResponse.builder()
                    .success(false)
                    .message("MBTI 맞춤 추천 중 오류가 발생했습니다.")
                    .build();
        }
    }
    
    /**
     * 3단계: 지역별 인기도 분석
     */
    public TrendAnalysisResponseDTO.RegionPopularityResponse analyzeRegionPopularity(String userId) {
        try {
            log.info("지역별 인기도 분석 시작 - 사용자: {}", userId);
            
            // Claude API를 통한 지역별 인기도 분석
            List<TrendAnalysisResponseDTO.RegionPopularity> regions = 
                claudeAnalysisService.analyzeRegions("지역별 인기도 분석");
            
            // 캐시에 저장
            analysisCache.put(userId + "_region", regions);
            
            return TrendAnalysisResponseDTO.RegionPopularityResponse.builder()
                    .success(true)
                    .message("지역별 인기도 분석이 완료되었습니다.")
                    .regions(regions)
                    .analysisTime(LocalDateTime.now())
                    .analysisStep("3/4")
                    .build();
                    
        } catch (Exception e) {
            log.error("지역별 인기도 분석 실패", e);
            return TrendAnalysisResponseDTO.RegionPopularityResponse.builder()
                    .success(false)
                    .message("지역별 인기도 분석 중 오류가 발생했습니다.")
                    .build();
        }
    }
    
    /**
     * 4단계: 종합 분석 결과
     */
    @SuppressWarnings("unchecked")
    public TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse generateComprehensiveAnalysis(String userId) {
        try {
            log.info("종합 분석 시작 - 사용자: {}", userId);
            
            // 이전 단계 데이터 조회
            List<TrendAnalysisResponseDTO.PopularDestination> popularData = 
                (List<TrendAnalysisResponseDTO.PopularDestination>) analysisCache.get(userId + "_popular");
            List<TrendAnalysisResponseDTO.MBTIRecommendation> mbtiData = 
                (List<TrendAnalysisResponseDTO.MBTIRecommendation>) analysisCache.get(userId + "_mbti");
            List<TrendAnalysisResponseDTO.RegionPopularity> regionData = 
                (List<TrendAnalysisResponseDTO.RegionPopularity>) analysisCache.get(userId + "_region");
            
            if (popularData == null || mbtiData == null || regionData == null) {
                return TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse.builder()
                        .success(false)
                        .message("이전 분석 데이터가 없습니다. 처음부터 다시 분석해주세요.")
                        .build();
            }
            
            // Claude API를 통한 종합 분석
            TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse result = 
                claudeAnalysisService.generateFinalAnalysis("종합 분석");
            
            // 분석 시간과 단계 정보 업데이트
            result.setAnalysisTime(LocalDateTime.now());
            result.setAnalysisStep("4/4");
            
            return result;
                    
        } catch (Exception e) {
            log.error("종합 분석 실패", e);
            return TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse.builder()
                    .success(false)
                    .message("종합 분석 중 오류가 발생했습니다.")
                    .build();
        }
    }
    
    /**
     * 전체 분석 실행 (4단계 순차 실행)
     */
    public TrendAnalysisResponseDTO.FullAnalysisResponse executeFullAnalysis(String userId, String mbtiType) {
        try {
            log.info("전체 트렌드 분석 시작 - 사용자: {}", userId);
            
            // 1단계: 급상승 여행지
            TrendAnalysisResponseDTO.PopularDestinationsResponse popular = analyzePopularDestinations(userId);
            if (!popular.isSuccess()) {
                return TrendAnalysisResponseDTO.FullAnalysisResponse.builder()
                        .success(false)
                        .message("1단계 분석 실패: " + popular.getMessage())
                        .build();
            }
            
            // 2단계: MBTI 추천
            TrendAnalysisResponseDTO.MBTIRecommendationResponse mbti = getMBTIRecommendations(userId, mbtiType);
            if (!mbti.isSuccess()) {
                return TrendAnalysisResponseDTO.FullAnalysisResponse.builder()
                        .success(false)
                        .message("2단계 분석 실패: " + mbti.getMessage())
                        .popularDestinations(popular)
                        .build();
            }
            
            // 3단계: 지역별 분석
            TrendAnalysisResponseDTO.RegionPopularityResponse region = analyzeRegionPopularity(userId);
            if (!region.isSuccess()) {
                return TrendAnalysisResponseDTO.FullAnalysisResponse.builder()
                        .success(false)
                        .message("3단계 분석 실패: " + region.getMessage())
                        .popularDestinations(popular)
                        .mbtiRecommendations(mbti)
                        .build();
            }
            
            // 4단계: 종합 분석
            TrendAnalysisResponseDTO.ComprehensiveAnalysisResponse comprehensive = generateComprehensiveAnalysis(userId);
            
            return TrendAnalysisResponseDTO.FullAnalysisResponse.builder()
                    .success(comprehensive.isSuccess())
                    .message(comprehensive.isSuccess() ? "전체 분석이 완료되었습니다." : comprehensive.getMessage())
                    .popularDestinations(popular)
                    .mbtiRecommendations(mbti)
                    .regionPopularity(region)
                    .comprehensiveAnalysis(comprehensive)
                    .analysisTime(LocalDateTime.now())
                    .build();
                    
        } catch (Exception e) {
            log.error("전체 트렌드 분석 실패", e);
            return TrendAnalysisResponseDTO.FullAnalysisResponse.builder()
                    .success(false)
                    .message("전체 분석 중 오류가 발생했습니다.")
                    .build();
        }
    }
    
    /**
     * 분석 데이터 존재 여부 확인
     */
    public boolean hasAnalysisData(String userId) {
        return analysisCache.containsKey(userId + "_popular") &&
               analysisCache.containsKey(userId + "_mbti") &&
               analysisCache.containsKey(userId + "_region");
    }
    
    // ==================== 목업 데이터 생성 메소드들 ====================
    
    private List<TrendAnalysisResponseDTO.PopularDestination> createMockPopularDestinations() {
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
    
    private List<TrendAnalysisResponseDTO.MBTIRecommendation> createMockMBTIRecommendations(String mbtiType) {
        // MBTI 타입별 다른 추천 제공 (예시)
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
    
    private List<TrendAnalysisResponseDTO.RegionPopularity> createMockRegionPopularity() {
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
    
    private List<TrendAnalysisResponseDTO.BestDestination> createMockBestDestinations() {
        return Arrays.asList(
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
    }
    
    private TrendAnalysisResponseDTO.AnalysisSummary createMockSummary() {
        return TrendAnalysisResponseDTO.AnalysisSummary.builder()
                .analysisDate("2024-11-20")
                .totalDestinations(15)
                .topTrendSource("Instagram (45%), YouTube (30%), 네이버 블로그 (25%)")
                .seasonalTrend("가을 단풍, 억새밭 여행지 인기 급상승")
                .emergingDestinations(Arrays.asList("강릉 안반데기", "태안 신두리", "양평 두물머리"))
                .build();
    }
}