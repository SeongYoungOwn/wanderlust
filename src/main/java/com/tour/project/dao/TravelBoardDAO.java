package com.tour.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.Map;

@Mapper
public interface TravelBoardDAO {
    
    /**
     * 사용자의 여행 게시글 수 조회
     */
    int getUserPostCount(@Param("userId") String userId);
    
    /**
     * 사용자의 여행 스타일 분석 (카테고리별 게시글 수)
     * 실제 구현 시 travel_board 테이블이 있다면 category나 tag 기반으로 분석
     */
    Map<String, Integer> getUserTravelStyles(@Param("userId") String userId);
}