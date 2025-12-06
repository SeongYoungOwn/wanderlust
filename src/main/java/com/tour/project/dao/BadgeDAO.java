package com.tour.project.dao;

import com.tour.project.dto.BadgeDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface BadgeDAO {
    
    // 사용자의 모든 뱃지 조회
    List<BadgeDTO> getUserBadges(@Param("userId") String userId);
    
    // 특정 뱃지 정보 조회
    BadgeDTO getBadgeById(@Param("badgeId") int badgeId);
    
    // 모든 뱃지 목록 조회
    List<BadgeDTO> getAllBadges();
    
    // 사용자에게 뱃지 부여
    int awardBadge(@Param("userId") String userId, @Param("badgeId") int badgeId);
    
    // 사용자가 특정 뱃지를 가지고 있는지 확인
    boolean hasUserBadge(@Param("userId") String userId, @Param("badgeId") int badgeId);
    
    // 뱃지 타입별 조회
    List<BadgeDTO> getBadgesByType(@Param("badgeType") String badgeType);
    
    // 사용자 뱃지 개수 조회
    int getUserBadgeCount(@Param("userId") String userId);
}