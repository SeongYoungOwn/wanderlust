package com.tour.project.dto.playlist;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

/**
 * 여행 플레이리스트 추천 요청 DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlaylistRequestDTO {
    
    /**
     * 음악 국가 선택 (korean/foreign)
     */
    private String musicOrigin;
    
    /**
     * 여행지 타입 (pension/highway/beach/resort/mountain/city/camping/hotspring)
     */
    private String destinationType;
    
    /**
     * 음악 장르 (classic/rock/energetic/calm/jazz/pop/hiphop/indie/ballad)
     */
    private String musicGenre;
    
    /**
     * 시간대 (morning/afternoon/evening/night)
     */
    private String timeOfDay;
    
    /**
     * 여행 스타일 (alone/couple/family/friends)
     */
    private String travelStyle;
    
    /**
     * 사용자 ID (세션용)
     */
    private String userId;
}