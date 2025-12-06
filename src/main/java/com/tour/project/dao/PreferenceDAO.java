package com.tour.project.dao;

import com.tour.project.dto.UserPreferenceModel;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface PreferenceDAO {

    /**
     * 사용자 선호도 조회
     */
    UserPreferenceModel getUserPreferences(@Param("userId") Long userId);

    /**
     * 사용자 선호도 저장
     */
    int insertUserPreferences(UserPreferenceModel preferences);

    /**
     * 사용자 선호도 업데이트
     */
    int updateUserPreferences(UserPreferenceModel preferences);

    /**
     * 사용자 선호도 존재 여부 확인
     */
    boolean existsUserPreferences(@Param("userId") Long userId);

    /**
     * 사용자 선호도 삭제
     */
    int deleteUserPreferences(@Param("userId") Long userId);

    /**
     * 특정 MBTI를 가진 사용자들의 선호도 조회
     */
    List<UserPreferenceModel> getUserPreferencesByMbti(@Param("mbtiType") String mbtiType);

    /**
     * 모든 사용자의 선호도 조회 (배치 처리용)
     */
    List<UserPreferenceModel> getAllUserPreferences();

    /**
     * 사용자 여행 이력 추가
     */
    int insertUserTravelHistory(@Param("userId") Long userId,
                               @Param("planId") Long planId,
                               @Param("destinationCategory") String destinationCategory,
                               @Param("travelStyle") String travelStyle,
                               @Param("budgetRange") String budgetRange,
                               @Param("durationDays") Integer durationDays,
                               @Param("rating") Double rating);

    /**
     * 사용자 여행 이력 조회
     */
    List<Map<String, Object>> getUserTravelHistory(@Param("userId") Long userId);

    /**
     * 사용자 행동 로그 추가
     */
    int insertUserBehaviorLog(@Param("userId") Long userId,
                             @Param("actionType") String actionType,
                             @Param("actionValue") String actionValue,
                             @Param("actionMetadata") String actionMetadata,
                             @Param("sessionId") String sessionId);

    /**
     * 사용자 행동 로그 조회
     */
    List<Map<String, Object>> getUserBehaviorLogs(@Param("userId") Long userId,
                                                  @Param("limit") Integer limit);

    /**
     * 사용자 유사도 캐시 저장
     */
    int insertUserSimilarityCache(@Param("userId1") Long userId1,
                                 @Param("userId2") Long userId2,
                                 @Param("similarityScore") Double similarityScore);

    /**
     * 사용자 유사도 캐시 조회
     */
    Double getUserSimilarityScore(@Param("userId1") Long userId1,
                                 @Param("userId2") Long userId2);

    /**
     * 유사 사용자 목록 조회
     */
    List<Map<String, Object>> getSimilarUsers(@Param("userId") Long userId,
                                              @Param("limit") Integer limit);

    /**
     * 추천 캐시 저장
     */
    int insertRecommendationCache(@Param("cacheKey") String cacheKey,
                                 @Param("userId") Long userId,
                                 @Param("recommendationData") String recommendationData,
                                 @Param("expiresInMinutes") Integer expiresInMinutes);

    /**
     * 추천 캐시 조회
     */
    String getRecommendationCache(@Param("cacheKey") String cacheKey);

    /**
     * 만료된 캐시 삭제
     */
    int deleteExpiredCache();

    /**
     * 목적지별 인기도 조회
     */
    List<Map<String, Object>> getDestinationPopularity();

    /**
     * 사용자별 추천 성과 조회
     */
    Map<String, Object> getUserRecommendationPerformance(@Param("userId") Long userId);
}