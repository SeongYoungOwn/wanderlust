package com.tour.project.dao;

import com.tour.project.dto.MbtiCompatibilityDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MbtiCompatibilityDAO {
    
    // 특정 MBTI의 최적 매칭 MBTI 조회
    MbtiCompatibilityDTO getBestMatch(String mbtiType);
    
    // 두 MBTI 간의 호환성 점수 조회
    int getCompatibilityScore(@Param("mbti1") String mbti1, @Param("mbti2") String mbti2);
    
    // 모든 호환성 데이터 조회
    List<MbtiCompatibilityDTO> getAllCompatibilities();
    
    // 특정 MBTI와 호환되는 모든 MBTI 조회
    List<MbtiCompatibilityDTO> getCompatibleMbtis(String mbtiType);
}