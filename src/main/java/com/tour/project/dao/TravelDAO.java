package com.tour.project.dao;

import com.tour.project.dto.TravelDTO;
import com.tour.project.dto.TravelParticipantDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface TravelDAO {
    
    // 여행 계획 CRUD
    int insertTravel(TravelDTO travel);
    
    TravelDTO getTravelById(Long travelId);
    
    List<TravelDTO> getAllTravels();
    
    List<TravelDTO> getTravelsByUserId(String userId);
    
    int updateTravel(TravelDTO travel);
    
    int deleteTravel(Long travelId);
    
    // 여행 참여 관련
    int joinTravel(@Param("travelId") Long travelId, @Param("userId") String userId);
    
    int leaveTravel(@Param("travelId") Long travelId, @Param("userId") String userId);
    
    boolean isUserJoined(@Param("travelId") Long travelId, @Param("userId") String userId);
    
    List<TravelParticipantDTO> getParticipantsByTravelId(Long travelId);
    
    List<TravelParticipantDTO> getJoinedTravelsByUserId(String userId);

    // 참여중인 여행 조회 (내가 작성하지 않은 여행 중 참여 승인된 것만)
    List<TravelParticipantDTO> getParticipatingTravelsByUserId(String userId);

    int getParticipantCount(Long travelId);
    
    int updateParticipantCount(@Param("travelId") Long travelId, @Param("count") int count);
    
    // 검색 관련
    List<TravelDTO> searchTravels(Map<String, Object> searchParams);
}