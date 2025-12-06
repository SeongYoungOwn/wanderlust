package com.tour.project.dao;

import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.BoardDTO;
import org.apache.ibatis.annotations.*;
import java.util.List;
import java.util.Map;

@Mapper
public interface AdminDAO {
    
    // ========== Dashboard Statistics ==========
    
    // 신규 가입자 수 (오늘/이번 주/이번 달)
    @Select("SELECT COUNT(*) FROM member WHERE DATE(user_regdate) = CURDATE()")
    int getTodayNewMembers();
    
    @Select("SELECT COUNT(*) FROM member WHERE YEARWEEK(user_regdate, 1) = YEARWEEK(CURDATE(), 1)")
    int getThisWeekNewMembers();
    
    @Select("SELECT COUNT(*) FROM member WHERE YEAR(user_regdate) = YEAR(CURDATE()) AND MONTH(user_regdate) = MONTH(CURDATE())")
    int getThisMonthNewMembers();
    
    // 전체 게시글 수 (오늘/이번 주/이번 달)
    @Select("SELECT COUNT(*) FROM board WHERE DATE(board_regdate) = CURDATE()")
    int getTodayNewPosts();
    
    @Select("SELECT COUNT(*) FROM board WHERE YEARWEEK(board_regdate, 1) = YEARWEEK(CURDATE(), 1)")
    int getThisWeekNewPosts();
    
    @Select("SELECT COUNT(*) FROM board WHERE YEAR(board_regdate) = YEAR(CURDATE()) AND MONTH(board_regdate) = MONTH(CURDATE())")
    int getThisMonthNewPosts();
    
    // 최근 활동이 적은 사용자 (매너 온도 대신 최근 게시글이 적은 사용자)
    @Select("SELECT m.user_id, m.user_name, " +
            "COALESCE(m.nickname, m.user_name) as nickname, " +
            "m.user_regdate, " +
            "COALESCE(m.manner_temperature, 36.5) as manner_score " +
            "FROM member m " +
            "WHERE COALESCE(m.manner_temperature, 36.5) < #{threshold} " +
            "ORDER BY manner_score ASC " +
            "LIMIT #{limit}")
    List<Map<String, Object>> getLowMannerUsers(@Param("threshold") double threshold, @Param("limit") int limit);
    
    // 싫어요를 많이 받은 게시글
    @Select("SELECT b.board_id, b.board_title, b.board_writer, b.board_regdate, " +
            "COALESCE(b.board_dislikes, 0) as board_dislikes " +
            "FROM board b " +
            "WHERE COALESCE(b.board_dislikes, 0) >= #{minDislikes} " +
            "ORDER BY board_dislikes DESC " +
            "LIMIT #{limit}")
    List<Map<String, Object>> getMostDislikedPosts(@Param("minDislikes") int minDislikes, @Param("limit") int limit);
    
    // ========== User Management ==========
    
    // 모든 사용자 목록 조회 (페이징)
    @Select("<script>" +
            "SELECT m.user_id as userId, m.user_name as userName, " +
            "COALESCE(m.nickname, m.user_name) as nickname, " +
            "m.user_email as userEmail, " +
            "m.user_regdate as userRegdate, " +
            "COALESCE(m.account_status, 'ACTIVE') as accountStatus, " +
            "COALESCE(m.user_role, 'USER') as userRole, " +
            "COALESCE(m.manner_temperature, 36.5) as mannerTemperature, " +
            "COALESCE(post_count.cnt, 0) as postCount, " +
            "COALESCE(comment_count.cnt, 0) as commentCount " +
            "FROM member m " +
            "LEFT JOIN (SELECT board_writer, COUNT(*) as cnt FROM board GROUP BY board_writer) post_count ON m.user_id = post_count.board_writer " +
            "LEFT JOIN (SELECT comment_writer, COUNT(*) as cnt FROM comments GROUP BY comment_writer) comment_count ON m.user_id = comment_count.comment_writer " +
            "<choose>" +
            "<when test='orderBy == \"user_regdate\"'>ORDER BY m.user_regdate ${orderDirection}</when>" +
            "<when test='orderBy == \"user_id\"'>ORDER BY m.user_id ${orderDirection}</when>" +
            "<when test='orderBy == \"manner_score\"'>ORDER BY COALESCE(m.manner_temperature, 36.5) ${orderDirection}</when>" +
            "<otherwise>ORDER BY m.user_regdate DESC</otherwise>" +
            "</choose>" +
            " LIMIT #{offset}, #{limit}" +
            "</script>")
    List<Map<String, Object>> getAllUsers(@Param("offset") int offset,
                                           @Param("limit") int limit,
                                           @Param("orderBy") String orderBy,
                                           @Param("orderDirection") String orderDirection);
    
    // 사용자 검색
    @Select("<script>" +
            "SELECT m.user_id as userId, m.user_name as userName, " +
            "COALESCE(m.nickname, m.user_name) as nickname, " +
            "m.user_email as userEmail, " +
            "m.user_regdate as userRegdate, " +
            "COALESCE(m.account_status, 'ACTIVE') as accountStatus, " +
            "COALESCE(m.user_role, 'USER') as userRole, " +
            "COALESCE(m.manner_temperature, 36.5) as mannerTemperature, " +
            "COALESCE(post_count.cnt, 0) as postCount, " +
            "COALESCE(comment_count.cnt, 0) as commentCount " +
            "FROM member m " +
            "LEFT JOIN (SELECT board_writer, COUNT(*) as cnt FROM board GROUP BY board_writer) post_count ON m.user_id = post_count.board_writer " +
            "LEFT JOIN (SELECT comment_writer, COUNT(*) as cnt FROM comments GROUP BY comment_writer) comment_count ON m.user_id = comment_count.comment_writer " +
            "WHERE (m.user_id LIKE CONCAT('%', #{keyword}, '%') OR COALESCE(m.nickname, m.user_name) LIKE CONCAT('%', #{keyword}, '%')) " +
            "<choose>" +
            "<when test='orderBy == \"user_regdate\"'>ORDER BY m.user_regdate ${orderDirection}</when>" +
            "<when test='orderBy == \"user_id\"'>ORDER BY m.user_id ${orderDirection}</when>" +
            "<when test='orderBy == \"manner_score\"'>ORDER BY COALESCE(m.manner_temperature, 36.5) ${orderDirection}</when>" +
            "<otherwise>ORDER BY m.user_regdate DESC</otherwise>" +
            "</choose>" +
            " LIMIT #{offset}, #{limit}" +
            "</script>")
    List<Map<String, Object>> searchUsers(@Param("keyword") String keyword,
                                           @Param("offset") int offset,
                                           @Param("limit") int limit,
                                           @Param("orderBy") String orderBy,
                                           @Param("orderDirection") String orderDirection);
    
    // 전체 사용자 수
    @Select("SELECT COUNT(*) FROM member")
    int getTotalUserCount();
    
    // 검색된 사용자 수
    @Select("SELECT COUNT(*) FROM member " +
            "WHERE (user_id LIKE CONCAT('%', #{keyword}, '%') OR COALESCE(nickname, user_name) LIKE CONCAT('%', #{keyword}, '%'))")
    int getSearchUserCount(@Param("keyword") String keyword);
    
    // 사용자 상세 정보 조회
    @Select("SELECT m.user_id as userId, m.user_name as userName, " +
            "m.user_email as userEmail, m.user_mbti as userMbti, " +
            "COALESCE(m.nickname, m.user_name) as nickname, " +
            "m.gender, m.age, m.bio, " +
            "COALESCE(m.manner_temperature, 36.5) as mannerTemperature, " +
            "m.profile_image as profileImage, " +
            "m.user_regdate as userRegdate, " +
            "COALESCE(m.account_status, 'ACTIVE') as accountStatus, " +
            "COALESCE(m.user_role, 'USER') as userRole, " +
            "COALESCE(post_count.cnt, 0) as totalPosts, " +
            "0 as totalPlans " +
            "FROM member m " +
            "LEFT JOIN (SELECT board_writer, COUNT(*) as cnt FROM board GROUP BY board_writer) post_count ON m.user_id = post_count.board_writer " +
            "WHERE m.user_id = #{userId}")
    Map<String, Object> getUserDetail(@Param("userId") String userId);
    
    // 계정 상태 변경
    @Update("UPDATE member SET account_status = #{status} WHERE user_id = #{userId}")
    int updateAccountStatus(@Param("userId") String userId, @Param("status") String status);
    
    // 사용자 강제 삭제 (완전 삭제)
    @Delete("DELETE FROM member WHERE user_id = #{userId}")
    int deleteUser(@Param("userId") String userId);
    
    // 사용자의 모든 활동 삭제
    @Delete("DELETE FROM board WHERE board_writer = #{userId}")
    int deleteUserPosts(@Param("userId") String userId);
    
    @Delete("DELETE FROM COMMENTS WHERE comment_writer = #{userId}")
    int deleteUserComments(@Param("userId") String userId);
    
    // Travel plan table doesn't exist, commenting out
    // @Delete("DELETE FROM travel_plan WHERE plan_writer = #{userId}")
    // int deleteUserTravelPlans(@Param("userId") String userId);
    
    @Delete("DELETE FROM board_likes WHERE user_id = #{userId}")
    int deleteUserLikes(@Param("userId") String userId);
    
    @Delete("DELETE FROM board_dislikes WHERE user_id = #{userId}")
    int deleteUserDislikes(@Param("userId") String userId);
    
    @Delete("DELETE FROM favorite WHERE user_id = #{userId}")
    int deleteUserFavorites(@Param("userId") String userId);
    
    @Delete("DELETE FROM manner_evaluation WHERE evaluator_id = #{userId} OR evaluated_id = #{userId}")
    int deleteUserMannerEvaluations(@Param("userId") String userId);
    
    // User manner stats table doesn't exist, commenting out
    // @Delete("DELETE FROM user_manner_stats WHERE user_id = #{userId}")
    // int deleteUserMannerStats(@Param("userId") String userId);
    
    // ========== Board Management ==========
    
    // 모든 게시글 목록 조회 (페이징)
    @Select("<script>" +
            "SELECT board_id, board_title, board_writer, board_regdate, " +
            "COALESCE(board_views, 0) as board_views, " +
            "COALESCE(board_likes, 0) as board_likes, " +
            "COALESCE(board_dislikes, 0) as board_dislikes " +
            "FROM board " +
            "<choose>" +
            "<when test='orderBy == \"board_regdate\"'>ORDER BY board_regdate ${orderDirection}</when>" +
            "<when test='orderBy == \"board_views\"'>ORDER BY COALESCE(board_views, 0) ${orderDirection}</when>" +
            "<when test='orderBy == \"board_likes\"'>ORDER BY COALESCE(board_likes, 0) ${orderDirection}</when>" +
            "<when test='orderBy == \"board_dislikes\"'>ORDER BY COALESCE(board_dislikes, 0) ${orderDirection}</when>" +
            "<otherwise>ORDER BY board_regdate DESC</otherwise>" +
            "</choose>" +
            " LIMIT #{offset}, #{limit}" +
            "</script>")
    List<Map<String, Object>> getAllPosts(@Param("offset") int offset, 
                                           @Param("limit") int limit,
                                           @Param("orderBy") String orderBy,
                                           @Param("orderDirection") String orderDirection);
    
    // 게시글 검색
    @Select("<script>" +
            "SELECT board_id, board_title, board_writer, board_regdate, " +
            "COALESCE(board_views, 0) as board_views, " +
            "COALESCE(board_likes, 0) as board_likes, " +
            "COALESCE(board_dislikes, 0) as board_dislikes " +
            "FROM board " +
            "WHERE (board_title LIKE CONCAT('%', #{keyword}, '%') OR " +
            "board_content LIKE CONCAT('%', #{keyword}, '%') OR " +
            "board_writer LIKE CONCAT('%', #{keyword}, '%')) " +
            "<choose>" +
            "<when test='orderBy == \"board_regdate\"'>ORDER BY board_regdate ${orderDirection}</when>" +
            "<when test='orderBy == \"board_views\"'>ORDER BY COALESCE(board_views, 0) ${orderDirection}</when>" +
            "<when test='orderBy == \"board_likes\"'>ORDER BY COALESCE(board_likes, 0) ${orderDirection}</when>" +
            "<when test='orderBy == \"board_dislikes\"'>ORDER BY COALESCE(board_dislikes, 0) ${orderDirection}</when>" +
            "<otherwise>ORDER BY board_regdate DESC</otherwise>" +
            "</choose>" +
            " LIMIT #{offset}, #{limit}" +
            "</script>")
    List<Map<String, Object>> searchPosts(@Param("keyword") String keyword,
                                           @Param("offset") int offset, 
                                           @Param("limit") int limit,
                                           @Param("orderBy") String orderBy,
                                           @Param("orderDirection") String orderDirection);
    
    // 전체 게시글 수
    @Select("SELECT COUNT(*) FROM board")
    int getTotalPostCount();
    
    // 검색된 게시글 수
    @Select("SELECT COUNT(*) FROM board " +
            "WHERE (board_title LIKE CONCAT('%', #{keyword}, '%') OR " +
            "board_content LIKE CONCAT('%', #{keyword}, '%') OR " +
            "board_writer LIKE CONCAT('%', #{keyword}, '%'))")
    int getSearchPostCount(@Param("keyword") String keyword);
    
    // 게시글 강제 삭제
    @Delete("DELETE FROM board WHERE board_id = #{boardId}")
    int deletePost(@Param("boardId") int boardId);
    
    // 게시글 삭제와 함께 관련 데이터도 삭제
    @Delete("DELETE FROM comment WHERE board_id = #{boardId}")
    int deletePostComments(@Param("boardId") int boardId);
    
    @Delete("DELETE FROM board_likes WHERE board_id = #{boardId}")
    int deletePostLikes(@Param("boardId") int boardId);
    
    @Delete("DELETE FROM board_dislikes WHERE board_id = #{boardId}")
    int deletePostDislikes(@Param("boardId") int boardId);
    
    // ========== System Statistics ==========
    
    // 전체 통계
    @Select("SELECT COUNT(*) as totalMembers FROM member WHERE account_status = 'ACTIVE'")
    int getTotalActiveMembers();
    
    @Select("SELECT COUNT(*) as suspendedMembers FROM member WHERE account_status = 'SUSPENDED'")
    int getTotalSuspendedMembers();
    
    @Select("SELECT COUNT(*) FROM board")
    int getTotalPosts();
    
    // Travel plan table doesn't exist, returning 0
    @Select("SELECT 0")
    int getTotalTravelPlans();
    
    // ========== User Role Management ==========
    
    // 사용자 권한 업데이트
    @Update("UPDATE member SET user_role = #{role} WHERE user_id = #{userId}")
    int updateUserRole(@Param("userId") String userId, @Param("role") String role);
    
    // ========== Enhanced Dashboard Statistics ==========
    
    // 최근 활동 사용자 (최근 7일 내 게시글 작성한 사용자)
    @Select("SELECT COUNT(DISTINCT m.user_id) FROM member m " +
            "LEFT JOIN board b ON m.user_id = b.board_writer " +
            "WHERE b.board_regdate >= DATE_SUB(NOW(), INTERVAL 7 DAY)")
    int getActiveUsersLastWeek();
    
    // Travel plan table doesn't exist, returning 0
    @Select("SELECT 0")
    int getOverdueTravelPlans();
    
    // 평균 매너온도
    @Select("SELECT AVG(COALESCE(manner_temperature, 36.5)) FROM member")
    Double getAverageMannerScore();
    
    // 이번 달 신규 게시글 수
    @Select("SELECT COUNT(*) FROM board WHERE MONTH(board_regdate) = MONTH(CURDATE()) AND YEAR(board_regdate) = YEAR(CURDATE())")
    int getThisMonthPosts();
    
    // Travel plan table doesn't exist, returning 0
    @Select("SELECT 0")
    int getThisMonthTravelPlans();
    
    // Travel plan table doesn't exist, returning empty list
    @Select("SELECT NULL as plan_destination, 0 as count WHERE 1=0")
    List<Map<String, Object>> getPopularDestinations(@Param("days") int days, @Param("limit") int limit);
    
    // 최근 N일간 일별 신규 가입자
    @Select("SELECT DATE(user_regdate) as date, COUNT(*) as count FROM member " +
            "WHERE user_regdate >= DATE_SUB(CURDATE(), INTERVAL #{days} DAY) " +
            "GROUP BY DATE(user_regdate) ORDER BY date DESC")
    List<Map<String, Object>> getDailyNewMembers(@Param("days") int days);
    
    // 정지된 계정 수
    @Select("SELECT COUNT(*) FROM member WHERE account_status = 'SUSPENDED'")
    int getSuspendedAccountsCount();
    
    // 활성 회원 수 (account_status 컬럼이 없다면 전체 회원 수)
    @Select("SELECT COUNT(*) FROM member WHERE COALESCE(account_status, 'ACTIVE') = 'ACTIVE'")
    int getActiveMemberCount();
    
    // 정지된 회원 수
    @Select("SELECT COUNT(*) FROM member WHERE COALESCE(account_status, 'ACTIVE') = 'SUSPENDED'")
    int getSuspendedMemberCount();
    
    // Travel plan table doesn't exist, returning 0
    @Select("SELECT 0")
    int getTotalTravelPlanCount();
    
    // 관리자 계정 수 (user_role이 없다면 user_id='admin'인 계정 수)
    @Select("SELECT COUNT(*) FROM member WHERE COALESCE(user_role, 'USER') = 'ADMIN' OR user_id = 'admin'")
    int getAdminCount();
}