package com.tour.project.dao;

import com.tour.project.dto.AiTravelPlanDTO;
import com.tour.project.dto.TravelPlanSummaryDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * AI 플래너 여행 계획 저장/불러오기 기능을 위한 DAO
 * 기존 TravelPlanDAO와는 별개로 동작
 */
@Mapper
@Repository
public interface AiTravelPlanDAO {
    
    /**
     * AI 여행 계획 저장
     */
    int insertAiTravelPlan(AiTravelPlanDTO travelPlan);
    
    /**
     * AI 여행 계획 상세 조회
     */
    AiTravelPlanDTO getAiTravelPlan(@Param("planId") Long planId);
    
    /**
     * 사용자별 AI 여행 계획 목록 조회 (요약 정보)
     */
    List<TravelPlanSummaryDTO> getUserTravelPlans(@Param("userId") String userId);
    
    /**
     * 사용자별 AI 여행 계획 목록 조회 (필터링)
     */
    List<TravelPlanSummaryDTO> getUserTravelPlansWithFilter(Map<String, Object> params);
    
    /**
     * AI 여행 계획 수정
     */
    int updateAiTravelPlan(AiTravelPlanDTO travelPlan);
    
    /**
     * AI 여행 계획 삭제
     */
    int deleteAiTravelPlan(@Param("planId") Long planId, @Param("userId") String userId);
    
    /**
     * 계획 소유권 확인
     */
    boolean isOwner(@Param("planId") Long planId, @Param("userId") String userId);
    
    /**
     * 템플릿 계획 목록 조회
     */
    List<TravelPlanSummaryDTO> getTemplateList(Map<String, Object> params);
    
    /**
     * 인기 계획 목록 조회
     */
    List<TravelPlanSummaryDTO> getPopularPlans(Map<String, Object> params);
    
    /**
     * 사용자 계획 검색
     */
    List<TravelPlanSummaryDTO> searchUserPlans(Map<String, Object> params);
    
    /**
     * 태그별 계획 검색
     */
    List<TravelPlanSummaryDTO> getPlansByTags(Map<String, Object> params);
}