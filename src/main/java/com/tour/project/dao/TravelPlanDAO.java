package com.tour.project.dao;

import com.tour.project.dto.TravelPlanDTO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface TravelPlanDAO {
    
    int insertTravelPlan(TravelPlanDTO travelPlan);
    
    TravelPlanDTO getTravelPlan(int planId);
    
    TravelPlanDTO getTravelPlanById(Long planId);
    
    int updateTravelPlan(TravelPlanDTO travelPlan);
    
    int deleteTravelPlan(int planId);
    
    List<TravelPlanDTO> getAllTravelPlans();
    
    List<TravelPlanDTO> getAllTravelPlans(Map<String, Object> params);
    
    List<TravelPlanDTO> getTravelPlansByWriter(String planWriter);
    
    List<TravelPlanDTO> getTravelPlansByWriterId(Long planWriter);
    
    int getTravelPlanCountByWriter(String planWriter);
    
    // 검색 관련 메서드들
    List<TravelPlanDTO> searchPlansByTitle(String keyword);
    
    List<TravelPlanDTO> searchPlansByDestination(String keyword);
    
    List<TravelPlanDTO> searchPlansByWriter(String keyword);
    
    List<TravelPlanDTO> searchPlansByTitleOrContent(String keyword);
    
    // 태그 필터링 메서드
    List<TravelPlanDTO> searchPlansByTags(Map<String, Object> searchParams);
    
    // 조회수 관련 메서드
    int increaseViewCount(int planId);

    // 정렬 관련 메서드
    List<TravelPlanDTO> getTravelPlansByViewCount();
    
    List<TravelPlanDTO> getTravelPlansByFavoriteCount();
    
    // 페이징 관련 메서드
    List<TravelPlanDTO> getTravelPlansWithPaging(Map<String, Object> params);
    
    int getTotalTravelPlanCount();
    
    List<TravelPlanDTO> searchPlansWithPaging(Map<String, Object> params);
    
    // 프로필용 메소드들
    List<TravelPlanDTO> selectUserTravelPlans(Map<String, Object> params);

    int countUserTravelPlans(String userId);

    int countUserCompletedTravels(String userId);

    int getSearchResultCount(Map<String, Object> params);

    // 채팅방 목록 조회 (사용자가 참여 중인 여행 계획)
    List<TravelPlanDTO> getMyParticipatingTravelPlans(String userId);
}