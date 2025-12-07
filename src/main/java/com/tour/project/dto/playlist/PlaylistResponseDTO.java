package com.tour.project.dto.playlist;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Builder;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 여행 플레이리스트 추천 응답 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlaylistResponseDTO {
    
    /**
     * 성공 여부
     */
    private boolean success;
    
    /**
     * 응답 메시지
     */
    private String message;
    
    /**
     * 음악 추천 리스트 (5곡)
     */
    private List<MusicRecommendation> recommendations;
    
    /**
     * 선택된 음악 국가
     */
    private String musicOrigin;
    
    /**
     * 분석 시간
     */
    private LocalDateTime analysisTime;
    
    /**
     * 추천 기준 정보
     */
    private RecommendationCriteria criteria;
    
    /**
     * 음악 추천 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class MusicRecommendation {
        
        /**
         * 곡명
         */
        private String songTitle;
        
        /**
         * 아티스트
         */
        private String artist;
        
        /**
         * 추천 이유
         */
        private String reason;
        
        /**
         * 장르
         */
        private String genre;
        
        /**
         * 음악 국가 (korean/foreign)
         */
        private String country;
        
        /**
         * 순서 (1-5)
         */
        private int order;
    }
    
    /**
     * 추천 기준 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class RecommendationCriteria {
        private String destinationType;
        private String musicGenre;
        private String timeOfDay;
        private String travelStyle;
        private String musicOrigin;
    }
}