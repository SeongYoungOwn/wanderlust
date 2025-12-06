package com.tour.project.dto.playlist;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

/**
 * 플레이리스트 저장 요청 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlaylistSaveRequestDTO {
    
    private Long playlistId;         // 생성된 플레이리스트 ID (저장 후 설정됨)
    private String musicOrigin;      // 음악 국가
    private String destinationType;  // 여행지 타입
    private String musicGenre;       // 음악 장르
    private String timeOfDay;        // 시간대
    private String travelStyle;      // 여행 스타일
    private List<SelectedSong> selectedSongs; // 선택된 음악 리스트
    
    /**
     * 선택된 음악 정보
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SelectedSong {
        private String songTitle;  // 곡 제목
        private String artist;     // 아티스트
        private String reason;     // 추천 이유
        private String genre;      // 장르
    }
}