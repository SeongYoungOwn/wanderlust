package com.tour.project.dao;

import com.tour.project.dto.NoticeDTO;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
public interface NoticeDAO {
    
    // 공지사항 목록 조회 (페이징)
    @Select("SELECT n.notice_id as noticeId, n.notice_title as noticeTitle, " +
            "n.notice_content as noticeContent, n.notice_writer as noticeWriter, " +
            "n.notice_regdate as noticeRegdate, n.notice_views as noticeViews, " +
            "n.is_important as isImportant, m.user_name as writerName " +
            "FROM notice n " +
            "LEFT JOIN member m ON n.notice_writer = m.user_id " +
            "ORDER BY n.is_important DESC, n.notice_regdate DESC " +
            "LIMIT #{offset}, #{size}")
    List<NoticeDTO> getNoticeList(@Param("offset") int offset, @Param("size") int size);
    
    // 공지사항 총 개수 조회
    @Select("SELECT COUNT(*) FROM notice")
    int getTotalNoticeCount();
    
    // 공지사항 상세 조회
    @Select("SELECT n.notice_id as noticeId, n.notice_title as noticeTitle, " +
            "n.notice_content as noticeContent, n.notice_writer as noticeWriter, " +
            "n.notice_regdate as noticeRegdate, n.notice_views as noticeViews, " +
            "n.is_important as isImportant, m.user_name as writerName " +
            "FROM notice n " +
            "LEFT JOIN member m ON n.notice_writer = m.user_id " +
            "WHERE n.notice_id = #{noticeId}")
    NoticeDTO getNoticeDetail(@Param("noticeId") Long noticeId);
    
    // 공지사항 조회수 증가
    @Update("UPDATE notice SET notice_views = notice_views + 1 WHERE notice_id = #{noticeId}")
    void incrementViews(@Param("noticeId") Long noticeId);
    
    // 공지사항 등록 (관리자만)
    @Insert("INSERT INTO notice (notice_title, notice_content, notice_writer, is_important) " +
            "VALUES (#{noticeTitle}, #{noticeContent}, #{noticeWriter}, #{isImportant})")
    @Options(useGeneratedKeys = true, keyProperty = "noticeId")
    int insertNotice(NoticeDTO notice);
    
    // 공지사항 수정 (관리자만)
    @Update("UPDATE notice SET " +
            "notice_title = #{noticeTitle}, " +
            "notice_content = #{noticeContent}, " +
            "is_important = #{isImportant} " +
            "WHERE notice_id = #{noticeId}")
    int updateNotice(NoticeDTO notice);
    
    // 공지사항 삭제 (관리자만)
    @Delete("DELETE FROM notice WHERE notice_id = #{noticeId}")
    int deleteNotice(@Param("noticeId") Long noticeId);
    
    // 검색 기능 (제목 또는 내용)
    @Select("SELECT n.notice_id as noticeId, n.notice_title as noticeTitle, " +
            "n.notice_content as noticeContent, n.notice_writer as noticeWriter, " +
            "n.notice_regdate as noticeRegdate, n.notice_views as noticeViews, " +
            "n.is_important as isImportant, m.user_name as writerName " +
            "FROM notice n " +
            "LEFT JOIN member m ON n.notice_writer = m.user_id " +
            "WHERE (n.notice_title LIKE CONCAT('%', #{keyword}, '%') " +
            "   OR n.notice_content LIKE CONCAT('%', #{keyword}, '%')) " +
            "ORDER BY n.is_important DESC, n.notice_regdate DESC " +
            "LIMIT #{offset}, #{size}")
    List<NoticeDTO> searchNotices(@Param("keyword") String keyword,
                                  @Param("offset") int offset,
                                  @Param("size") int size);
    
    // 검색 결과 총 개수
    @Select("SELECT COUNT(*) FROM notice " +
            "WHERE (notice_title LIKE CONCAT('%', #{keyword}, '%') " +
            "   OR notice_content LIKE CONCAT('%', #{keyword}, '%'))")
    int getSearchNoticeCount(@Param("keyword") String keyword);
    
    // 최근 중요 공지사항 조회 (메인 페이지용)
    @Select("SELECT n.notice_id as noticeId, n.notice_title as noticeTitle, " +
            "n.notice_content as noticeContent, n.notice_writer as noticeWriter, " +
            "n.notice_regdate as noticeRegdate, n.notice_views as noticeViews, " +
            "n.is_important as isImportant, m.user_name as writerName " +
            "FROM notice n " +
            "LEFT JOIN member m ON n.notice_writer = m.user_id " +
            "WHERE n.is_important = true " +
            "ORDER BY n.notice_regdate DESC " +
            "LIMIT #{limit}")
    List<NoticeDTO> getImportantNotices(@Param("limit") int limit);
}