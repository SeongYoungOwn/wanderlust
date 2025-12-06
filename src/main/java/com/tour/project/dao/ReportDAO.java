package com.tour.project.dao;

import com.tour.project.dto.ReportDTO;
import org.apache.ibatis.annotations.*;
import java.util.List;
import java.util.Map;

@Mapper
public interface ReportDAO {
    
    // 신고 등록
    @Insert("INSERT INTO reports (reporter_id, reported_content_type, reported_content_id, " +
            "reported_user_id, report_category, report_content) " +
            "VALUES (#{reporterId}, #{reportedContentType}, #{reportedContentId}, " +
            "#{reportedUserId}, #{reportCategory}, #{reportContent})")
    @Options(useGeneratedKeys = true, keyProperty = "reportId")
    int insertReport(ReportDTO report);
    
    // 중복 신고 확인
    @Select("SELECT COUNT(*) FROM reports WHERE reporter_id = #{reporterId} " +
            "AND reported_content_type = #{contentType} AND reported_content_id = #{contentId}")
    int checkDuplicateReport(@Param("reporterId") String reporterId, 
                           @Param("contentType") String contentType, 
                           @Param("contentId") int contentId);
    
    // 미처리 신고 수
    @Select("SELECT COUNT(*) FROM reports WHERE report_status = 'PENDING'")
    int getPendingReportsCount();
    
    // 전체 신고 수
    @Select("SELECT COUNT(*) FROM reports")
    int getTotalReportsCount();
    
    // 전체 신고 목록 (페이징)
    @Select("<script>" +
            "SELECT r.*, " +
            "m1.user_name as reporter_name, " +
            "m2.user_name as reported_user_name, " +
            "m3.user_name as processed_by_name, " +
            "CASE " +
            "WHEN r.reported_content_type = 'BOARD' THEN b.board_title " +
            "WHEN r.reported_content_type = 'PLAN' THEN p.plan_title " +
            "END as content_title " +
            "FROM reports r " +
            "LEFT JOIN member m1 ON r.reporter_id = m1.user_id " +
            "LEFT JOIN member m2 ON r.reported_user_id = m2.user_id " +
            "LEFT JOIN member m3 ON r.processed_by = m3.user_id " +
            "LEFT JOIN board b ON r.reported_content_type = 'BOARD' AND r.reported_content_id = b.board_id " +
            "LEFT JOIN travel_plan p ON r.reported_content_type = 'PLAN' AND r.reported_content_id = p.plan_id " +
            "<where>" +
            "<if test='status != null and status != \"\"'>AND r.report_status = #{status}</if>" +
            "<if test='category != null and category != \"\"'>AND r.report_category = #{category}</if>" +
            "<if test='contentType != null and contentType != \"\"'>AND r.reported_content_type = #{contentType}</if>" +
            "</where>" +
            "ORDER BY r.created_at DESC " +
            "LIMIT #{offset}, #{limit}" +
            "</script>")
    List<ReportDTO> getReportList(@Param("offset") int offset, 
                                @Param("limit") int limit,
                                @Param("status") String status,
                                @Param("category") String category,
                                @Param("contentType") String contentType);
    
    // 신고 목록 카운트 (페이징용)
    @Select("<script>" +
            "SELECT COUNT(*) FROM reports r " +
            "<where>" +
            "<if test='status != null and status != \"\"'>AND r.report_status = #{status}</if>" +
            "<if test='category != null and category != \"\"'>AND r.report_category = #{category}</if>" +
            "<if test='contentType != null and contentType != \"\"'>AND r.reported_content_type = #{contentType}</if>" +
            "</where>" +
            "</script>")
    int getReportCount(@Param("status") String status,
                      @Param("category") String category,
                      @Param("contentType") String contentType);
    
    // 신고 상세 조회
    @Select("SELECT r.*, " +
            "m1.user_name as reporter_name, " +
            "m2.user_name as reported_user_name, " +
            "m3.user_name as processed_by_name, " +
            "CASE " +
            "WHEN r.reported_content_type = 'BOARD' THEN b.board_title " +
            "WHEN r.reported_content_type = 'PLAN' THEN p.plan_title " +
            "END as content_title " +
            "FROM reports r " +
            "LEFT JOIN member m1 ON r.reporter_id = m1.user_id " +
            "LEFT JOIN member m2 ON r.reported_user_id = m2.user_id " +
            "LEFT JOIN member m3 ON r.processed_by = m3.user_id " +
            "LEFT JOIN board b ON r.reported_content_type = 'BOARD' AND r.reported_content_id = b.board_id " +
            "LEFT JOIN travel_plan p ON r.reported_content_type = 'PLAN' AND r.reported_content_id = p.plan_id " +
            "WHERE r.report_id = #{reportId}")
    ReportDTO getReportDetail(@Param("reportId") int reportId);
    
    // 신고 처리 (상태 변경)
    @Update("UPDATE reports SET report_status = #{status}, admin_comment = #{adminComment}, " +
            "processed_by = #{processedBy}, processed_at = NOW() WHERE report_id = #{reportId}")
    int processReport(@Param("reportId") int reportId, 
                     @Param("status") String status, 
                     @Param("adminComment") String adminComment, 
                     @Param("processedBy") String processedBy);
    
    // 사용자별 신고 통계
    @Select("SELECT reported_user_id, COUNT(*) as total_reports, " +
            "SUM(CASE WHEN report_status = 'APPROVED' THEN 1 ELSE 0 END) as approved_reports, " +
            "MAX(created_at) as last_reported_at " +
            "FROM reports WHERE reported_user_id = #{userId} GROUP BY reported_user_id")
    Map<String, Object> getUserReportStats(@Param("userId") String userId);
    
    // 신고 많이 받은 사용자 목록
    @Select("SELECT r.reported_user_id, m.user_name, COUNT(*) as report_count, " +
            "SUM(CASE WHEN r.report_status = 'APPROVED' THEN 1 ELSE 0 END) as approved_count, " +
            "MAX(r.created_at) as last_reported " +
            "FROM reports r " +
            "LEFT JOIN member m ON r.reported_user_id = m.user_id " +
            "GROUP BY r.reported_user_id, m.user_name " +
            "HAVING report_count >= #{minReports} " +
            "ORDER BY report_count DESC, last_reported DESC " +
            "LIMIT #{limit}")
    List<Map<String, Object>> getFrequentlyReportedUsers(@Param("minReports") int minReports, 
                                                        @Param("limit") int limit);
    
    // 최근 신고 목록 (대시보드용)
    @Select("SELECT r.*, " +
            "m1.user_name as reporter_name, " +
            "m2.user_name as reported_user_name, " +
            "CASE " +
            "WHEN r.reported_content_type = 'BOARD' THEN b.board_title " +
            "WHEN r.reported_content_type = 'PLAN' THEN p.plan_title " +
            "END as content_title " +
            "FROM reports r " +
            "LEFT JOIN member m1 ON r.reporter_id = m1.user_id " +
            "LEFT JOIN member m2 ON r.reported_user_id = m2.user_id " +
            "LEFT JOIN board b ON r.reported_content_type = 'BOARD' AND r.reported_content_id = b.board_id " +
            "LEFT JOIN travel_plan p ON r.reported_content_type = 'PLAN' AND r.reported_content_id = p.plan_id " +
            "WHERE r.report_status = 'PENDING' " +
            "ORDER BY r.created_at DESC " +
            "LIMIT #{limit}")
    List<ReportDTO> getRecentPendingReports(@Param("limit") int limit);
    
    // 오늘 들어온 신고 수
    @Select("SELECT COUNT(*) FROM reports WHERE DATE(created_at) = CURDATE()")
    int getTodayReportsCount();
    
    // 이번 주 신고 수
    @Select("SELECT COUNT(*) FROM reports WHERE YEARWEEK(created_at, 1) = YEARWEEK(CURDATE(), 1)")
    int getWeeklyReportsCount();

    // 사용자 신고 이력 조회
    @Select("SELECT r.report_id, r.report_category as reportReason, r.report_content as reportContent, " +
            "r.created_at as reportDate, r.report_status as reportStatus, " +
            "r.admin_comment as adminComment " +
            "FROM reports r " +
            "WHERE r.reported_user_id = #{userId} " +
            "ORDER BY r.created_at DESC")
    List<ReportDTO> getUserReportHistory(@Param("userId") String userId);
}