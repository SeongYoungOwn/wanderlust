package com.tour.project.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonInclude;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * 사용자 선호도 데이터 DTO
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class UserPreferenceDTO {
    
    /**
     * 사용자 ID
     */
    private String userId;
    
    /**
     * 선호하는 여행 스타일
     */
    private String travelStyle;
    
    /**
     * 선호하는 예산 범위
     */
    private String budgetRange;
    
    /**
     * 선호하는 여행 그룹 크기
     */
    private String groupSize;
    
    /**
     * 선호하는 활동 유형들
     */
    private List<String> preferredActivities;
    
    /**
     * 선호하는 지역들
     */
    private List<String> preferredRegions;
    
    /**
     * 선호하는 계절
     */
    private List<String> preferredSeasons;
    
    /**
     * 클릭한 여행지들의 카테고리 점수
     */
    private Map<String, Double> categoryScores;
    
    /**
     * 최근 검색 키워드들
     */
    private List<String> recentSearches;
    
    /**
     * 즐겨찾기한 여행지들
     */
    private List<String> favoriteDestinations;
    
    /**
     * 선호도 학습 정확도 점수
     */
    private Double accuracyScore;
    
    /**
     * 마지막 업데이트 시간
     */
    private LocalDateTime lastUpdated;
    
    /**
     * 학습 데이터 수집 시작 시간
     */
    private LocalDateTime learningStartTime;
    
    /**
     * 총 상호작용 횟수
     */
    private Integer totalInteractions;
}