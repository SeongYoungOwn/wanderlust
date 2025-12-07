package com.tour.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.tour.project.dto.MannerEvaluationDTO;
import com.tour.project.dto.UserMannerStatsDTO;

import java.util.List;

@Mapper
@Repository
public interface MannerEvaluationDAO {
    
    // 매너 평가 관련
    int insertEvaluation(MannerEvaluationDTO evaluation);
    int updateEvaluation(MannerEvaluationDTO evaluation);
    int deleteEvaluation(@Param("evaluationId") int evaluationId);
    
    MannerEvaluationDTO getEvaluation(@Param("evaluationId") int evaluationId);
    MannerEvaluationDTO getEvaluationByIds(@Param("travelPlanId") int travelPlanId, 
                                          @Param("evaluatorId") String evaluatorId, 
                                          @Param("evaluatedId") String evaluatedId);
    
    List<MannerEvaluationDTO> getEvaluationsByTravelPlan(@Param("travelPlanId") int travelPlanId);
    List<MannerEvaluationDTO> getEvaluationsByEvaluator(@Param("evaluatorId") String evaluatorId);
    List<MannerEvaluationDTO> getEvaluationsByEvaluated(@Param("evaluatedId") String evaluatedId);
    
    // 평가 가능한 사용자 조회 (같은 여행 참여자 중 본인 제외)
    List<String> getEvaluatableUsers(@Param("travelPlanId") int travelPlanId, 
                                    @Param("evaluatorId") String evaluatorId);
    
    // 평가 권한 체크
    boolean canEvaluate(@Param("travelPlanId") int travelPlanId, 
                       @Param("evaluatorId") String evaluatorId,
                       @Param("evaluatedId") String evaluatedId);
    
    // 여행 완료 처리
    int completeTravelPlan(@Param("planId") int planId, @Param("authorId") String authorId);
    boolean isTravelCompleted(@Param("planId") int planId);
    boolean isTravelAuthor(@Param("planId") int planId, @Param("userId") String userId);
    
    // 사용자 매너 통계 관련
    UserMannerStatsDTO getUserMannerStats(@Param("userId") String userId);
    int insertUserMannerStats(UserMannerStatsDTO stats);
    int updateUserMannerStats(UserMannerStatsDTO stats);
    int deleteUserMannerStats(@Param("userId") String userId);
    
    // 매너 통계 계산 및 업데이트
    void recalculateUserStats(@Param("userId") String userId);
    
    // 평가 통계
    int getTotalEvaluationsCount(@Param("userId") String userId);
    double getAverageMannerScore(@Param("userId") String userId);
    int getTotalLikesCount(@Param("userId") String userId);
    int getTotalDislikesCount(@Param("userId") String userId);
    int getCompletedTravelsCount(@Param("userId") String userId);

    // 모바일 API용 메서드
    boolean hasAlreadyEvaluated(@Param("travelPlanId") int travelPlanId,
                                @Param("evaluatorId") String evaluatorId,
                                @Param("targetUserId") String targetUserId);

    int getPendingEvaluationCount(@Param("travelPlanId") int travelPlanId,
                                  @Param("evaluatorId") String evaluatorId);
}