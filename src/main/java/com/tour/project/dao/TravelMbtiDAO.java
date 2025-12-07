package com.tour.project.dao;

import com.tour.project.dto.TravelMbtiQuestionDTO;
import com.tour.project.dto.TravelMbtiResultDTO;
import com.tour.project.dto.UserTravelMbtiDTO;
import com.tour.project.dto.MbtiMatchUserDTO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface TravelMbtiDAO {
    
    // 질문 관련
    List<TravelMbtiQuestionDTO> getAllQuestions();
    
    // 결과 관련
    TravelMbtiResultDTO getResultByType(String mbtiType);
    List<TravelMbtiResultDTO> getAllResults();
    
    // 사용자 MBTI 기록 관련
    void insertUserMbti(UserTravelMbtiDTO userMbti);
    UserTravelMbtiDTO getLatestUserMbti(String userId);
    List<UserTravelMbtiDTO> getUserMbtiHistory(String userId);
    
    // 통계 관련
    int getTotalTestCount();
    List<String> getPopularMbtiTypes();
    
    // 매칭 사용자 관련
    List<MbtiMatchUserDTO> getUsersByMbtiType(String mbtiType);
}