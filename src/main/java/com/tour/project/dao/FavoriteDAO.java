package com.tour.project.dao;

import com.tour.project.dto.FavoriteDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Mapper
@Repository
public interface FavoriteDAO {
    
    // 찜하기 추가
    int addFavorite(@Param("userId") String userId, @Param("itemType") String itemType, @Param("itemId") Integer itemId);
    
    // 찜하기 삭제
    int removeFavorite(@Param("userId") String userId, @Param("itemType") String itemType, @Param("itemId") Integer itemId);
    
    // 찜하기 여부 확인
    boolean isFavorite(@Param("userId") String userId, @Param("itemType") String itemType, @Param("itemId") Integer itemId);
    
    // 사용자별 찜 목록 조회 (여행계획과 커뮤니티 게시글 통합)
    List<FavoriteDTO> getFavoritesByUserId(String userId);
    
    // 사용자별 여행계획 찜 목록만 조회
    List<FavoriteDTO> getTravelPlanFavoritesByUserId(String userId);
    
    // 사용자별 커뮤니티 게시글 찜 목록만 조회
    List<FavoriteDTO> getBoardFavoritesByUserId(String userId);
    
    // 특정 항목의 찜 개수 조회
    int getFavoriteCount(@Param("itemType") String itemType, @Param("itemId") Integer itemId);
    
    // 사용자의 전체 찜 개수 조회
    int getUserFavoriteCount(String userId);
    
    // 사용자의 유효한 여행계획 찜 개수 조회
    int getValidTravelPlanFavoriteCount(String userId);
    
    // 사용자의 유효한 게시글 찜 개수 조회
    int getValidBoardFavoriteCount(String userId);
}