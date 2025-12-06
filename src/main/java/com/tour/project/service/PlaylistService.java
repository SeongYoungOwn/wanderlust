package com.tour.project.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.tour.project.client.ClaudeApiClient;
import com.tour.project.dto.claude.ClaudeRequest;
import com.tour.project.dto.claude.ClaudeResponse;
import com.tour.project.dto.playlist.PlaylistRequestDTO;
import com.tour.project.dto.playlist.PlaylistResponseDTO;
import com.tour.project.dto.playlist.PlaylistSaveRequestDTO;
import com.tour.project.dao.PlaylistDAO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * 여행 플레이리스트 추천 서비스
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PlaylistService {
    
    private final ClaudeApiClient claudeApiClient;
    private final ObjectMapper objectMapper;
    private final PlaylistDAO playlistDAO;
    
    /**
     * 여행 플레이리스트 추천
     */
    public PlaylistResponseDTO generatePlaylist(PlaylistRequestDTO request) {
        try {
            log.info("플레이리스트 추천 요청 - 음악국가: {}, 여행지: {}, 장르: {}", 
                    request.getMusicOrigin(), request.getDestinationType(), request.getMusicGenre());
            
            // Claude API 프롬프트 생성
            String prompt = buildPlaylistPrompt(request);
            
            // Claude API 호출 (다양성을 위해 temperature 설정)
            ClaudeRequest claudeRequest = ClaudeRequest.trendAnalysisBuilder()
                    .messages(List.of(new ClaudeRequest.Message("user", prompt)))
                    .maxTokens(4000)
                    .temperature(0.8) // 다양한 결과를 위한 높은 temperature 설정
                    .build();
            
            ClaudeResponse response = claudeApiClient.sendRequest(claudeRequest);
            
            if (response != null && response.isSuccess()) {
                return parsePlaylistResponse(response.getContentText(), request);
            } else {
                return createFallbackPlaylist(request);
            }
            
        } catch (Exception e) {
            log.error("플레이리스트 생성 실패", e);
            return createErrorResponse(e.getMessage());
        }
    }
    
    /**
     * Claude API 프롬프트 생성
     */
    private String buildPlaylistPrompt(PlaylistRequestDTO request) {
        StringBuilder prompt = new StringBuilder();
        
        // 음악 국가에 따른 전문가 설정
        if ("korean".equals(request.getMusicOrigin())) {
            prompt.append("당신은 K-POP과 한국 음악 전문가입니다. 오직 한국 아티스트의 한국 음악만 추천해주세요.\n\n");
        } else if ("mixed".equals(request.getMusicOrigin())) {
            prompt.append("당신은 전 세계 음악 전문가입니다. 한국 음악과 외국 음악을 적절히 섞어서 추천해주세요.\n\n");
        } else {
            prompt.append("당신은 전 세계 음악 전문가입니다. 오직 외국 아티스트의 음악만 추천해주세요.\n\n");
        }
        
        // 여행 정보 추가
        prompt.append("여행 정보:\n");
        prompt.append("- 여행지: ").append(getDestinationDescription(request.getDestinationType())).append("\n");
        prompt.append("- 선호 장르: ").append(getGenreDescription(request.getMusicGenre())).append("\n");
        prompt.append("- 시간대: ").append(getTimeDescription(request.getTimeOfDay())).append("\n");
        prompt.append("- 여행 스타일: ").append(getStyleDescription(request.getTravelStyle())).append("\n\n");
        
        // 추천 조건
        prompt.append("추천 조건:\n");
        if ("korean".equals(request.getMusicOrigin())) {
            prompt.append("- 5곡 모두 한국 음악 (K-POP, K-인디, K-발라드, K-힙합 등)\n");
            prompt.append("- 아티스트명과 곡명을 한국어로 표기\n");
        } else if ("mixed".equals(request.getMusicOrigin())) {
            prompt.append("- 한국 음악 2-3곡과 외국 음악 2-3곡을 적절히 섞어서 추천\n");
            prompt.append("- 한국 음악은 K-POP, K-발라드 등, 외국 음악은 팝, 록, 재즈 등\n");
            prompt.append("- 아티스트명과 곡명을 각각 적절한 언어로 표기\n");
        } else {
            prompt.append("- 5곡 모두 외국 음악 (팝, 록, 재즈, 클래식 등)\n");
            prompt.append("- 아티스트명과 곡명을 원어로 표기\n");
        }
        prompt.append("- 각 곡마다 구체적인 추천 이유 포함 (30-50자)\n");
        prompt.append("- 여행지와 장르에 맞는 분위기의 음악 선별\n");
        prompt.append("- 실제로 존재하는 유명한 곡들로만 추천\n");
        prompt.append("- 매번 새로운 다양한 곡들을 추천하여 중복을 피해주세요\n");
        prompt.append("- 현재 시각: ").append(java.time.LocalDateTime.now().toString()).append("\n\n");
        
        // JSON 형식 요청
        prompt.append("다음 JSON 형식으로 정확히 응답해주세요:\n\n");
        prompt.append("{\n");
        prompt.append("  \"recommendations\": [\n");
        prompt.append("    {\n");
        prompt.append("      \"songTitle\": \"곡명\",\n");
        prompt.append("      \"artist\": \"아티스트명\",\n");
        prompt.append("      \"reason\": \"추천 이유 (50자 내외)\",\n");
        prompt.append("      \"genre\": \"장르\",\n");
        prompt.append("      \"order\": 1\n");
        prompt.append("    }\n");
        prompt.append("  ]\n");
        prompt.append("}\n");
        
        return prompt.toString();
    }
    
    /**
     * 플레이리스트 저장
     */
    public boolean savePlaylist(String userId, PlaylistSaveRequestDTO saveRequest) {
        try {
            log.info("플레이리스트 저장 시작 - 사용자: {}, 선택된 음악 수: {}", 
                    userId, saveRequest.getSelectedSongs().size());
            
            // 1. 플레이리스트 기본 정보 저장
            playlistDAO.insertPlaylist(userId, saveRequest);
            
            Long playlistId = saveRequest.getPlaylistId();
            if (playlistId == null || playlistId <= 0) {
                log.error("플레이리스트 기본 정보 저장 실패 - 생성된 ID가 없습니다");
                return false;
            }
            
            log.info("플레이리스트 기본 정보 저장 완료 - playlist_id: {}", playlistId);
            
            // 2. 선택된 음악들 저장
            int savedCount = 0;
            for (int i = 0; i < saveRequest.getSelectedSongs().size(); i++) {
                PlaylistSaveRequestDTO.SelectedSong song = saveRequest.getSelectedSongs().get(i);
                
                int result = playlistDAO.insertPlaylistSong(playlistId, song, i + 1);
                if (result > 0) {
                    savedCount++;
                    log.info("음악 저장 완료 - {}: {} - {}", i + 1, song.getSongTitle(), song.getArtist());
                } else {
                    log.warn("음악 저장 실패 - {}: {} - {}", i + 1, song.getSongTitle(), song.getArtist());
                }
            }
            
            // 3. 저장 결과 확인
            boolean success = savedCount == saveRequest.getSelectedSongs().size();
            
            if (success) {
                log.info("플레이리스트 저장 완료 - playlist_id: {}, 저장된 음악 수: {}/{}", 
                        playlistId, savedCount, saveRequest.getSelectedSongs().size());
            } else {
                log.warn("일부 음악 저장 실패 - playlist_id: {}, 저장된 음악 수: {}/{}", 
                        playlistId, savedCount, saveRequest.getSelectedSongs().size());
            }
            
            return success;
            
        } catch (Exception e) {
            log.error("플레이리스트 저장 중 오류 발생", e);
            return false;
        }
    }
    
    /**
     * Claude 응답 파싱
     */
    private PlaylistResponseDTO parsePlaylistResponse(String content, PlaylistRequestDTO request) {
        try {
            String jsonContent = extractJsonFromResponse(content);
            @SuppressWarnings("unchecked")
            Map<String, Object> responseMap = objectMapper.readValue(jsonContent, Map.class);
            
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> recommendationsList = (List<Map<String, Object>>) responseMap.get("recommendations");
            
            List<PlaylistResponseDTO.MusicRecommendation> recommendations = new ArrayList<>();
            
            for (int i = 0; i < recommendationsList.size() && i < 5; i++) {
                Map<String, Object> rec = recommendationsList.get(i);
                
                PlaylistResponseDTO.MusicRecommendation recommendation = PlaylistResponseDTO.MusicRecommendation.builder()
                        .songTitle((String) rec.get("songTitle"))
                        .artist((String) rec.get("artist"))
                        .reason((String) rec.get("reason"))
                        .genre((String) rec.get("genre"))
                        .country(request.getMusicOrigin())
                        .order(i + 1)
                        .build();
                
                recommendations.add(recommendation);
            }
            
            return PlaylistResponseDTO.builder()
                    .success(true)
                    .message("플레이리스트 추천이 완료되었습니다.")
                    .recommendations(recommendations)
                    .musicOrigin(request.getMusicOrigin())
                    .analysisTime(LocalDateTime.now())
                    .criteria(PlaylistResponseDTO.RecommendationCriteria.builder()
                            .destinationType(request.getDestinationType())
                            .musicGenre(request.getMusicGenre())
                            .timeOfDay(request.getTimeOfDay())
                            .travelStyle(request.getTravelStyle())
                            .musicOrigin(request.getMusicOrigin())
                            .build())
                    .build();
            
        } catch (Exception e) {
            log.error("Claude 응답 파싱 실패", e);
            return createFallbackPlaylist(request);
        }
    }
    
    /**
     * Fallback 플레이리스트 생성
     */
    private PlaylistResponseDTO createFallbackPlaylist(PlaylistRequestDTO request) {
        List<PlaylistResponseDTO.MusicRecommendation> recommendations = new ArrayList<>();
        
        if ("korean".equals(request.getMusicOrigin())) {
            // 한국 음악 기본 추천
            recommendations.add(createRecommendation("Spring Day", "BTS", "여행의 설렘을 표현한 감성적인 K-POP", "K-POP", 1));
            recommendations.add(createRecommendation("밤편지", "아이유", "조용한 여행 시간에 어울리는 힐링 발라드", "K-발라드", 2));
            recommendations.add(createRecommendation("Weekend", "태연", "주말 여행의 여유로운 분위기", "K-POP", 3));
            recommendations.add(createRecommendation("으르렁", "EXO", "신나는 여행 드라이브에 완벽한 리듬", "K-POP", 4));
            recommendations.add(createRecommendation("Celebrity", "아이유", "특별한 여행 순간을 빛내줄 세련된 곡", "K-POP", 5));
        } else if ("mixed".equals(request.getMusicOrigin())) {
            // 혼합 음악 기본 추천 (한국 + 외국)
            recommendations.add(createRecommendation("Dynamite", "BTS", "글로벌한 매력의 K-POP 대표곡", "K-POP", 1));
            recommendations.add(createRecommendation("Don't Stop Me Now", "Queen", "여행의 즐거움을 극대화하는 클래식 록", "Rock", 2));
            recommendations.add(createRecommendation("밤편지", "아이유", "조용한 여행 시간에 어울리는 힐링 발라드", "K-발라드", 3));
            recommendations.add(createRecommendation("Mr. Blue Sky", "ELO", "맑은 날 여행에 완벽한 경쾌한 멜로디", "Rock", 4));
            recommendations.add(createRecommendation("Weekend", "태연", "주말 여행의 여유로운 분위기", "K-POP", 5));
        } else {
            // 외국 음악 기본 추천
            recommendations.add(createRecommendation("Don't Stop Me Now", "Queen", "여행의 즐거움을 극대화하는 클래식 록", "Rock", 1));
            recommendations.add(createRecommendation("Mr. Blue Sky", "ELO", "맑은 날 여행에 완벽한 경쾌한 멜로디", "Rock", 2));
            recommendations.add(createRecommendation("Born to Run", "Bruce Springsteen", "자유로운 여행 정신을 표현한 명곡", "Rock", 3));
            recommendations.add(createRecommendation("Life is a Highway", "Tom Cochrane", "드라이브 여행의 대표적인 앤썸", "Rock", 4));
            recommendations.add(createRecommendation("Good Vibrations", "The Beach Boys", "여행의 좋은 에너지를 전달하는 클래식", "Pop", 5));
        }
        
        return PlaylistResponseDTO.builder()
                .success(true)
                .message("기본 플레이리스트를 추천드립니다.")
                .recommendations(recommendations)
                .musicOrigin(request.getMusicOrigin())
                .analysisTime(LocalDateTime.now())
                .criteria(PlaylistResponseDTO.RecommendationCriteria.builder()
                        .destinationType(request.getDestinationType())
                        .musicGenre(request.getMusicGenre())
                        .timeOfDay(request.getTimeOfDay())
                        .travelStyle(request.getTravelStyle())
                        .musicOrigin(request.getMusicOrigin())
                        .build())
                .build();
    }
    
    private PlaylistResponseDTO.MusicRecommendation createRecommendation(String title, String artist, String reason, String genre, int order) {
        return PlaylistResponseDTO.MusicRecommendation.builder()
                .songTitle(title)
                .artist(artist)
                .reason(reason)
                .genre(genre)
                .country("foreign")
                .order(order)
                .build();
    }
    
    /**
     * 에러 응답 생성
     */
    private PlaylistResponseDTO createErrorResponse(String errorMessage) {
        return PlaylistResponseDTO.builder()
                .success(false)
                .message("플레이리스트 생성에 실패했습니다: " + errorMessage)
                .recommendations(new ArrayList<>())
                .analysisTime(LocalDateTime.now())
                .build();
    }
    
    /**
     * JSON 추출
     */
    private String extractJsonFromResponse(String response) {
        int startIndex = response.indexOf("{");
        int endIndex = response.lastIndexOf("}");
        
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
            return response.substring(startIndex, endIndex + 1);
        }
        
        throw new RuntimeException("JSON 형식을 찾을 수 없습니다.");
    }
    
    // 설명 메소드들
    private String getDestinationDescription(String type) {
        switch (type) {
            case "pension": return "펜션";
            case "highway": return "고속도로";
            case "beach": return "바닷가";
            case "resort": return "휴양지";
            case "mountain": return "산악지대";
            case "city": return "도시여행";
            case "camping": return "캠핑장";
            case "hotspring": return "온천";
            default: return type;
        }
    }
    
    private String getGenreDescription(String genre) {
        switch (genre) {
            case "classic": return "클래식";
            case "rock": return "락";
            case "energetic": return "신나는";
            case "quiet": return "조용한";
            case "jazz": return "재즈";
            case "pop": return "팝";
            case "hiphop": return "힙합";
            case "indie": return "인디";
            default: return genre;
        }
    }
    
    private String getTimeDescription(String time) {
        switch (time) {
            case "morning": return "아침";
            case "afternoon": return "오후";
            case "evening": return "저녁";
            case "night": return "밤";
            default: return time;
        }
    }
    
    private String getStyleDescription(String style) {
        switch (style) {
            case "alone": return "혼자";
            case "couple": return "연인";
            case "family": return "가족";
            case "friends": return "친구들";
            default: return style;
        }
    }
}