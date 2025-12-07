package com.tour.project.dto.playlist;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 저장된 플레이리스트 조회 DTO
 */
@Data
@Builder
public class SavedPlaylistDTO {
    
    private Long playlistId;
    private String userId;
    private String musicOrigin;
    private String destinationType;
    private String musicGenre;
    private String timeOfDay;
    private String travelStyle;
    private LocalDateTime createdAt;
    private List<SavedSongDTO> songs;
    
    @Data
    @Builder
    public static class SavedSongDTO {
        private Long songId;
        private Long playlistId;
        private String songTitle;
        private String artist;
        private String genre;
        private String reason;
        private Integer songOrder;
        private LocalDateTime createdAt;
    }
    
    /**
     * 여행지 타입 한글 변환
     */
    public String getDestinationTypeDescription() {
        switch (destinationType) {
            case "pension": return "펜션";
            case "highway": return "고속도로";
            case "beach": return "바닷가";
            case "resort": return "휴양지";
            case "mountain": return "산악지대";
            case "city": return "도시여행";
            case "camping": return "캠핑장";
            case "hotspring": return "온천";
            default: return destinationType;
        }
    }
    
    /**
     * 음악 장르 한글 변환
     */
    public String getMusicGenreDescription() {
        switch (musicGenre) {
            case "classic": return "클래식";
            case "rock": return "락";
            case "energetic": return "신나는";
            case "quiet": return "조용한";
            case "jazz": return "재즈";
            case "pop": return "팝";
            case "hiphop": return "힙합";
            case "indie": return "인디";
            default: return musicGenre;
        }
    }
    
    /**
     * 시간대 한글 변환
     */
    public String getTimeOfDayDescription() {
        switch (timeOfDay) {
            case "morning": return "아침";
            case "afternoon": return "오후";
            case "evening": return "저녁";
            case "night": return "밤";
            default: return timeOfDay;
        }
    }
    
    /**
     * 여행 스타일 한글 변환
     */
    public String getTravelStyleDescription() {
        switch (travelStyle) {
            case "adventurous": return "모험적";
            case "relaxed": return "여유로운";
            case "cultural": return "문화적";
            case "romantic": return "로맨틱";
            default: return travelStyle;
        }
    }
    
    /**
     * 음악 국가 한글 변환
     */
    public String getMusicOriginDescription() {
        switch (musicOrigin) {
            case "korean": return "한국 음악";
            case "foreign": return "외국 음악";
            case "mixed": return "혼합";
            default: return musicOrigin;
        }
    }
}