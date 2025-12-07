package com.tour.project.dao;

import com.tour.project.dto.TravelJoinRequestDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Mapper
@Repository
public interface TravelJoinRequestDAO {
    
    int insertJoinRequest(TravelJoinRequestDTO request);
    
    TravelJoinRequestDTO getJoinRequestById(Integer requestId);
    
    List<TravelJoinRequestDTO> getJoinRequestsByTravelPlan(Integer travelPlanId);
    
    List<TravelJoinRequestDTO> getJoinRequestsByRequester(String requesterId);
    
    List<TravelJoinRequestDTO> getJoinRequestsByPlanWriter(String planWriterId);
    
    List<TravelJoinRequestDTO> getJoinRequestsByStatus(String status);
    
    int updateJoinRequestStatus(@Param("requestId") Integer requestId, 
                                @Param("status") String status, 
                                @Param("responseMessage") String responseMessage, 
                                @Param("respondedBy") String respondedBy);
    
    int deleteJoinRequest(Integer requestId);
    
    boolean isAlreadyRequested(@Param("travelPlanId") Integer travelPlanId, 
                               @Param("requesterId") String requesterId);
    
    int getJoinRequestCount(Integer travelPlanId);
    
    int getPendingRequestCount(String planWriterId);
    
    boolean isApprovedForTravel(@Param("travelPlanId") Integer travelPlanId,
                               @Param("userId") String userId);

    // 거절된 신청 삭제 (재신청을 위해)
    int deleteRejectedRequest(@Param("travelPlanId") Integer travelPlanId,
                              @Param("requesterId") String requesterId);
}