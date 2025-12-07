package com.tour.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * AI 여행 계획 태그 관리를 위한 DAO
 */
@Mapper
@Repository
public interface PlanTagDAO {
    
    /**
     * 계획의 태그들 저장
     */
    int insertPlanTags(Long planId, List<String> tags);
    
    /**
     * 계획의 태그들 조회
     */
    List<String> getPlanTags(Long planId);
    
    /**
     * 계획의 태그들 삭제
     */
    int deletePlanTags(Long planId);
    
    /**
     * 계획의 태그들 업데이트를 위한 기존 태그 삭제
     */
    int updatePlanTagsDelete(Long planId);
    
    /**
     * 계획의 태그들 업데이트를 위한 새 태그 추가
     */
    int updatePlanTagsInsert(Long planId, List<String> tags);
    
    /**
     * 인기 태그 목록 조회
     */
    List<String> getPopularTags(int limit);
    
    /**
     * 사용자별 자주 사용하는 태그 조회
     */
    List<String> getUserFrequentTags(String userId, int limit);
}