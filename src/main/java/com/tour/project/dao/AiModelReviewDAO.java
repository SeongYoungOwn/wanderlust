package com.tour.project.dao;

import com.tour.project.dto.AiModelReviewDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AiModelReviewDAO {
    
    // 리뷰 작성
    int insertReview(AiModelReviewDTO review);
    
    // 특정 모델의 모든 리뷰 조회 (페이징, 사용자 정보 포함)
    List<AiModelReviewDTO> getReviewsByModelId(@Param("modelId") String modelId, 
                                              @Param("currentUserId") String currentUserId,
                                              @Param("offset") int offset, 
                                              @Param("limit") int limit);
    
    // 특정 모델의 리뷰 총 개수
    int getReviewCountByModelId(@Param("modelId") String modelId);
    
    // 특정 모델의 평점 통계
    Map<String, Object> getReviewStatsByModelId(@Param("modelId") String modelId);
    
    // 리뷰 상세 조회
    AiModelReviewDTO getReviewById(@Param("reviewId") Long reviewId, 
                                  @Param("currentUserId") String currentUserId);
    
    // 리뷰 수정
    int updateReview(AiModelReviewDTO review);
    
    // 리뷰 삭제
    int deleteReview(@Param("reviewId") Long reviewId, @Param("userId") String userId);
    
    // 도움됨 추가
    int insertHelpful(@Param("reviewId") Long reviewId, @Param("userId") String userId);
    
    // 도움됨 취소
    int deleteHelpful(@Param("reviewId") Long reviewId, @Param("userId") String userId);
    
    // 도움됨 개수 업데이트
    int updateHelpfulCount(@Param("reviewId") Long reviewId);
    
    // 사용자가 특정 리뷰에 도움됨을 눌렀는지 확인
    boolean isHelpedByUser(@Param("reviewId") Long reviewId, @Param("userId") String userId);
    
    // 사용자가 특정 모델에 리뷰를 작성했는지 확인
    boolean hasUserReviewedModel(@Param("modelId") String modelId, @Param("userId") String userId);
    
    // 사용자의 모든 리뷰 조회
    List<AiModelReviewDTO> getReviewsByUserId(@Param("userId") String userId);
    
    // 최근 리뷰 조회 (홈페이지용)
    List<AiModelReviewDTO> getRecentReviews(@Param("limit") int limit);
    
    // 모든 AI 모델의 리뷰 통합 조회 (페이징, 정렬, 필터링)
    List<AiModelReviewDTO> getAllReviews(@Param("currentUserId") String currentUserId,
                                        @Param("offset") int offset, 
                                        @Param("limit") int limit,
                                        @Param("sort") String sort,
                                        @Param("rating") Integer rating);
    
    // 전체 리뷰 총 개수 (필터링 적용)
    int getTotalReviewCount(@Param("rating") Integer rating);
    
    // 전체 평점 통계
    Map<String, Object> getAllReviewStats();
}