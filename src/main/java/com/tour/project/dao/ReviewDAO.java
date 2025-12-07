package com.tour.project.dao;

import com.tour.project.dto.ReviewDTO;
import org.apache.ibatis.annotations.*;
import java.util.List;
import java.util.Map;

@Mapper
public interface ReviewDAO {

    // 리뷰 등록
    @Insert("INSERT INTO reviews (reviewer_id, reviewed_user_id, travel_plan_id, " +
            "rating, review_content, review_type) " +
            "VALUES (#{reviewerId}, #{reviewedUserId}, #{travelPlanId}, " +
            "#{rating}, #{reviewContent}, #{reviewType})")
    @Options(useGeneratedKeys = true, keyProperty = "reviewId")
    int insertReview(ReviewDTO review);

    // 중복 리뷰 확인
    @Select("SELECT COUNT(*) FROM reviews WHERE reviewer_id = #{reviewerId} " +
            "AND reviewed_user_id = #{reviewedUserId} AND travel_plan_id = #{travelPlanId}")
    int checkDuplicateReview(@Param("reviewerId") String reviewerId,
                           @Param("reviewedUserId") String reviewedUserId,
                           @Param("travelPlanId") int travelPlanId);

    // 사용자가 받은 리뷰 목록 조회
    @Select("SELECT r.review_id, r.reviewer_id, r.reviewed_user_id, r.travel_plan_id, " +
            "r.rating, r.review_content as reviewContent, r.review_type, " +
            "r.created_at as reviewDate, " +
            "m.user_name as reviewerName, m.profile_image as reviewerImage, " +
            "p.plan_title as travelTitle " +
            "FROM reviews r " +
            "LEFT JOIN member m ON r.reviewer_id = m.user_id " +
            "LEFT JOIN travel_plan p ON r.travel_plan_id = p.plan_id " +
            "WHERE r.reviewed_user_id = #{userId} " +
            "ORDER BY r.created_at DESC")
    List<ReviewDTO> getUserReceivedReviews(@Param("userId") String userId);

    // 사용자가 작성한 리뷰 목록 조회
    @Select("SELECT r.review_id, r.reviewer_id, r.reviewed_user_id, r.travel_plan_id, " +
            "r.rating, r.review_content, r.review_type, r.created_at, " +
            "m.user_name as reviewed_user_name, m.profile_image as reviewed_user_image, " +
            "p.plan_title as travel_title " +
            "FROM reviews r " +
            "LEFT JOIN member m ON r.reviewed_user_id = m.user_id " +
            "LEFT JOIN travel_plan p ON r.travel_plan_id = p.plan_id " +
            "WHERE r.reviewer_id = #{userId} " +
            "ORDER BY r.created_at DESC " +
            "LIMIT #{offset}, #{limit}")
    List<ReviewDTO> getUserWrittenReviews(@Param("userId") String userId,
                                         @Param("offset") int offset,
                                         @Param("limit") int limit);

    // 사용자 평균 평점 조회
    @Select("SELECT AVG(rating) FROM reviews WHERE reviewed_user_id = #{userId}")
    Double getUserAverageRating(@Param("userId") String userId);

    // 사용자 리뷰 통계 조회
    @Select("SELECT COUNT(*) as total_reviews, " +
            "AVG(rating) as average_rating, " +
            "SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star_count, " +
            "SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star_count, " +
            "SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star_count, " +
            "SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star_count, " +
            "SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star_count " +
            "FROM reviews WHERE reviewed_user_id = #{userId}")
    Map<String, Object> getUserReviewStats(@Param("userId") String userId);

    // 여행 계획별 리뷰 목록 조회
    @Select("SELECT r.*, " +
            "m1.user_name as reviewer_name, m1.profile_image as reviewer_image, " +
            "m2.user_name as reviewed_user_name, m2.profile_image as reviewed_user_image " +
            "FROM reviews r " +
            "LEFT JOIN member m1 ON r.reviewer_id = m1.user_id " +
            "LEFT JOIN member m2 ON r.reviewed_user_id = m2.user_id " +
            "WHERE r.travel_plan_id = #{travelPlanId} " +
            "ORDER BY r.created_at DESC")
    List<ReviewDTO> getTravelPlanReviews(@Param("travelPlanId") int travelPlanId);

    // 리뷰 상세 조회
    @Select("SELECT r.*, " +
            "m1.user_name as reviewer_name, m1.profile_image as reviewer_image, " +
            "m2.user_name as reviewed_user_name, m2.profile_image as reviewed_user_image, " +
            "p.plan_title as travel_title " +
            "FROM reviews r " +
            "LEFT JOIN member m1 ON r.reviewer_id = m1.user_id " +
            "LEFT JOIN member m2 ON r.reviewed_user_id = m2.user_id " +
            "LEFT JOIN travel_plan p ON r.travel_plan_id = p.plan_id " +
            "WHERE r.review_id = #{reviewId}")
    ReviewDTO getReviewDetail(@Param("reviewId") int reviewId);

    // 리뷰 수정
    @Update("UPDATE reviews SET rating = #{rating}, review_content = #{reviewContent}, " +
            "updated_at = NOW() WHERE review_id = #{reviewId}")
    int updateReview(@Param("reviewId") int reviewId,
                    @Param("rating") int rating,
                    @Param("reviewContent") String reviewContent);

    // 리뷰 삭제
    @Delete("DELETE FROM reviews WHERE review_id = #{reviewId}")
    int deleteReview(@Param("reviewId") int reviewId);

    // 최근 리뷰 목록 (대시보드용)
    @Select("SELECT r.*, " +
            "m1.user_name as reviewer_name, " +
            "m2.user_name as reviewed_user_name, " +
            "p.plan_title as travel_title " +
            "FROM reviews r " +
            "LEFT JOIN member m1 ON r.reviewer_id = m1.user_id " +
            "LEFT JOIN member m2 ON r.reviewed_user_id = m2.user_id " +
            "LEFT JOIN travel_plan p ON r.travel_plan_id = p.plan_id " +
            "ORDER BY r.created_at DESC " +
            "LIMIT #{limit}")
    List<ReviewDTO> getRecentReviews(@Param("limit") int limit);
}