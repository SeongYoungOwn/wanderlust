package com.tour.project.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tour.project.vo.GuideVO;
import com.tour.project.vo.GuideApplicationVO;

@Mapper
public interface GuideDAO {

    // 가이드 신청 등록
    int insertGuideApplication(GuideApplicationVO application);

    // 사용자의 가이드 신청 상태 확인
    GuideApplicationVO getApplicationByUserId(String userId);

    // 대기 중인 가이드 신청 목록 조회 (관리자용)
    List<GuideApplicationVO> getPendingApplications();

    // 신청 ID로 조회
    GuideApplicationVO getApplicationById(int applicationId);

    // 가이드로 등록
    int insertGuide(GuideApplicationVO application);

    // 가이드 신청 상태 업데이트
    int updateApplicationStatus(@Param("applicationId") int applicationId,
                               @Param("status") String status,
                               @Param("adminId") String adminId,
                               @Param("adminComment") String adminComment);

    // 가이드 신청 거절
    int rejectApplication(@Param("applicationId") int applicationId,
                         @Param("adminId") String adminId,
                         @Param("adminComment") String adminComment);

    // 가이드 목록 조회
    List<GuideVO> getGuideList(@Param("region") String region,
                               @Param("theme") String theme,
                               @Param("minRating") Double minRating);

    // 가이드 상세 정보 조회
    GuideVO getGuideById(int guideId);

    // 사용자 ID로 가이드 정보 조회
    GuideVO getGuideByUserId(String userId);

    // 승인된 가이드 수 조회
    int getApprovedGuideCount();

    // 이번 달 신청 수 조회
    int getMonthlyApplicationCount();

    // 전체 신청 수 조회
    int getTotalApplicationCount();

    // 승인된 신청 수 조회
    int getApprovedApplicationCount();

    // 모든 가이드 신청 조회 (페이징, 상태 필터)
    List<GuideApplicationVO> getAllApplications(@Param("status") String status,
                                               @Param("offset") int offset,
                                               @Param("size") int size,
                                               @Param("orderBy") String orderBy,
                                               @Param("orderDirection") String orderDirection);

    // 가이드 신청 검색 (페이징, 상태 필터)
    List<GuideApplicationVO> searchApplications(@Param("search") String search,
                                               @Param("status") String status,
                                               @Param("offset") int offset,
                                               @Param("size") int size,
                                               @Param("orderBy") String orderBy,
                                               @Param("orderDirection") String orderDirection);

    // 상태별 신청 수 조회
    int getTotalApplicationCountByStatus(@Param("status") String status);

    // 검색 결과 신청 수 조회
    int getSearchApplicationCount(@Param("search") String search, @Param("status") String status);

    // 특정 상태의 신청 수 조회
    int getApplicationCountByStatus(@Param("status") String status);

    // 가이드 삭제
    int deleteGuide(int guideId);
}