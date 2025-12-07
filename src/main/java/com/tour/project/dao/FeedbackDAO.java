package com.tour.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
public interface FeedbackDAO {

    /**
     * 매칭 피드백 추가
     */
    int insertMatchingFeedback(@Param("userId") Long userId,
                              @Param("planId") Long planId,
                              @Param("matchingScore") Double matchingScore,
                              @Param("userSatisfaction") Integer userSatisfaction,
                              @Param("actualParticipation") Boolean actualParticipation);

    /**
     * 매칭 피드백 업데이트
     */
    int updateMatchingFeedback(@Param("userId") Long userId,
                              @Param("planId") Long planId,
                              @Param("userSatisfaction") Integer userSatisfaction,
                              @Param("actualParticipation") Boolean actualParticipation);

    /**
     * 클릭 수 증가
     */
    int incrementClickCount(@Param("userId") Long userId,
                          @Param("planId") Long planId);

    /**
     * 조회 수 증가
     */
    int incrementViewCount(@Param("userId") Long userId,
                         @Param("planId") Long planId);

    /**
     * 조회 시간 업데이트
     */
    int updateViewDuration(@Param("userId") Long userId,
                          @Param("planId") Long planId,
                          @Param("durationSeconds") Long durationSeconds);

    /**
     * 지원 상태 업데이트
     */
    int updateAppliedStatus(@Param("userId") Long userId,
                           @Param("planId") Long planId,
                           @Param("applied") Boolean applied);

    /**
     * 특정 사용자의 피드백 조회
     */
    List<Map<String, Object>> getUserFeedback(@Param("userId") Long userId);

    /**
     * 특정 여행 계획의 피드백 조회
     */
    List<Map<String, Object>> getPlanFeedback(@Param("planId") Long planId);

    /**
     * 기간별 피드백 조회
     */
    List<Map<String, Object>> getFeedbackByDateRange(@Param("startDate") LocalDateTime startDate,
                                                     @Param("endDate") LocalDateTime endDate);

    /**
     * 평균 만족도 조회
     */
    Double getAverageSatisfaction(@Param("userId") Long userId);

    /**
     * 매칭 성공률 조회
     */
    Double getMatchingSuccessRate(@Param("userId") Long userId);

    /**
     * 일일 메트릭스 추가
     */
    int insertDailyMetrics(@Param("metricDate") String metricDate,
                          @Param("totalRecommendations") Integer totalRecommendations,
                          @Param("totalClicks") Integer totalClicks,
                          @Param("totalViews") Integer totalViews,
                          @Param("totalApplications") Integer totalApplications,
                          @Param("totalParticipations") Integer totalParticipations,
                          @Param("avgSatisfaction") Double avgSatisfaction,
                          @Param("ctr") Double ctr,
                          @Param("matchingSuccessRate") Double matchingSuccessRate,
                          @Param("retentionRate") Double retentionRate,
                          @Param("diversityIndex") Double diversityIndex);

    /**
     * 일일 메트릭스 조회
     */
    Map<String, Object> getDailyMetrics(@Param("metricDate") String metricDate);

    /**
     * 기간별 메트릭스 조회
     */
    List<Map<String, Object>> getMetricsByDateRange(@Param("startDate") String startDate,
                                                    @Param("endDate") String endDate);

    /**
     * MBTI 호환성 캐시 추가
     */
    int insertMbtiCompatibilityCache(@Param("mbti1") String mbti1,
                                    @Param("mbti2") String mbti2,
                                    @Param("travelStyle") String travelStyle,
                                    @Param("compatibilityScore") Double compatibilityScore,
                                    @Param("synergyDescription") String synergyDescription,
                                    @Param("recommendedDestinations") String recommendedDestinations);

    /**
     * MBTI 호환성 조회
     */
    Map<String, Object> getMbtiCompatibility(@Param("mbti1") String mbti1,
                                            @Param("mbti2") String mbti2,
                                            @Param("travelStyle") String travelStyle);

    /**
     * A/B 테스트 결과 추가
     */
    int insertAbTestResult(@Param("userId") Long userId,
                          @Param("testGroup") String testGroup,
                          @Param("testName") String testName,
                          @Param("recommendationAlgorithm") String recommendationAlgorithm,
                          @Param("clicked") Boolean clicked,
                          @Param("applied") Boolean applied,
                          @Param("satisfactionScore") Integer satisfactionScore);

    /**
     * A/B 테스트 결과 조회
     */
    List<Map<String, Object>> getAbTestResults(@Param("testName") String testName);

    /**
     * A/B 테스트 성과 비교
     */
    Map<String, Object> compareAbTestGroups(@Param("testName") String testName);

    /**
     * 사용자 세그먼트 추가
     */
    int insertUserSegment(@Param("segmentName") String segmentName,
                         @Param("segmentCriteria") String segmentCriteria,
                         @Param("userCount") Integer userCount,
                         @Param("avgSatisfaction") Double avgSatisfaction);

    /**
     * 사용자 세그먼트 업데이트
     */
    int updateUserSegment(@Param("segmentId") Integer segmentId,
                         @Param("userCount") Integer userCount,
                         @Param("avgSatisfaction") Double avgSatisfaction);

    /**
     * 모든 세그먼트 조회
     */
    List<Map<String, Object>> getAllSegments();

    /**
     * 클릭률(CTR) 계산
     */
    Double calculateCTR(@Param("userId") Long userId);

    /**
     * 전체 시스템 CTR 계산
     */
    Double calculateSystemCTR();

    /**
     * 피드백 존재 여부 확인
     */
    boolean existsFeedback(@Param("userId") Long userId,
                          @Param("planId") Long planId);

    /**
     * 오래된 피드백 데이터 삭제
     */
    int deleteOldFeedback(@Param("daysToKeep") Integer daysToKeep);
}