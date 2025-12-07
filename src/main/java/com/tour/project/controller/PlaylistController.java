package com.tour.project.controller;

import com.tour.project.dto.playlist.PlaylistRequestDTO;
import com.tour.project.dto.playlist.PlaylistResponseDTO;
import com.tour.project.dto.playlist.PlaylistSaveRequestDTO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.service.PlaylistService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import com.tour.project.dto.playlist.SavedPlaylistDTO;
import com.tour.project.dao.PlaylistDAO;

/**
 * 여행 플레이리스트 추천 컨트롤러
 */
@Slf4j
@Controller
@RequestMapping("/playlist")
@RequiredArgsConstructor
public class PlaylistController {
    
    private final PlaylistService playlistService;
    private final PlaylistDAO playlistDAO;
    
    /**
     * 플레이리스트 추천 페이지
     */
    @GetMapping("")
    public String playlistPage() {
        return "playlist/index";
    }
    
    /**
     * 플레이리스트 추천 API
     */
    @PostMapping("/recommend")
    @ResponseBody
    public ResponseEntity<PlaylistResponseDTO> recommendPlaylist(
            @RequestBody PlaylistRequestDTO request,
            HttpSession session) {
        
        try {
            // 사용자 ID 설정
            String userId = getOrCreateUserId(session);
            request.setUserId(userId);
            
            log.info("플레이리스트 추천 요청 - 사용자: {}, 음악국가: {}, 여행지: {}", 
                    userId, request.getMusicOrigin(), request.getDestinationType());
            
            // 플레이리스트 생성
            PlaylistResponseDTO response = playlistService.generatePlaylist(request);
            
            if (response.isSuccess()) {
                return ResponseEntity.ok(response);
            } else {
                return ResponseEntity.badRequest().body(response);
            }
            
        } catch (Exception e) {
            log.error("플레이리스트 추천 실패", e);
            
            PlaylistResponseDTO errorResponse = PlaylistResponseDTO.builder()
                    .success(false)
                    .message("플레이리스트 추천 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
            
            return ResponseEntity.internalServerError().body(errorResponse);
        }
    }
    
    /**
     * 플레이리스트 저장 API
     */
    @PostMapping("/save")
    @ResponseBody
    public ResponseEntity<Object> savePlaylist(
            @RequestBody PlaylistSaveRequestDTO saveRequest,
            HttpSession session) {
        
        try {
            log.info("=== 플레이리스트 저장 요청 디버깅 시작 ===");
            log.info("세션 ID: {}", session.getId());
            
            // 세션 속성 전체 확인
            log.info("세션 속성 목록:");
            session.getAttributeNames().asIterator().forEachRemaining(name -> {
                Object value = session.getAttribute(name);
                log.info("  - {}: {}", name, value);
            });
            
            // 사용자 ID 설정 (로그인된 경우 사용자 ID, 아닌 경우 임시 ID 사용)
            String userId;
            MemberDTO loginMember = (MemberDTO) session.getAttribute("loginUser");
            log.info("loginUser 세션 값: {}", loginMember);
            
            if (loginMember != null) {
                userId = loginMember.getUserId();
                log.info("로그인된 사용자 ID: {}", userId);
            } else {
                // 로그인하지 않은 경우 임시 사용자 ID 생성
                userId = getOrCreateUserId(session);
                log.info("임시 사용자 ID 생성: {}", userId);
            }
            
            // 선택된 음악이 있는지 확인
            if (saveRequest.getSelectedSongs() == null || saveRequest.getSelectedSongs().isEmpty()) {
                return ResponseEntity.badRequest().body("저장할 음악을 선택해주세요.");
            }
            
            log.info("플레이리스트 저장 요청 - 사용자: {}, 선택된 음악 수: {}", 
                    userId, saveRequest.getSelectedSongs().size());
            
            // 플레이리스트 실제 DB 저장
            boolean success = playlistService.savePlaylist(userId, saveRequest);
            
            if (success) {
                return ResponseEntity.ok().body(Map.of(
                    "success", true,
                    "message", "플레이리스트가 성공적으로 저장되었습니다.",
                    "savedCount", saveRequest.getSelectedSongs().size()
                ));
            } else {
                return ResponseEntity.internalServerError().body(Map.of(
                    "success", false,
                    "message", "플레이리스트 저장 중 오류가 발생했습니다."
                ));
            }
            
        } catch (Exception e) {
            log.error("플레이리스트 저장 실패", e);
            return ResponseEntity.internalServerError().body("플레이리스트 저장 중 오류가 발생했습니다.");
        }
    }

    /**
     * 모든 플레이리스트 조회 (디버그용)
     */
    @GetMapping("/debug/all")
    @ResponseBody
    public ResponseEntity<Object> getAllPlaylists() {
        try {
            // 임시 사용자 플레이리스트 조회
            List<SavedPlaylistDTO> tempPlaylists = playlistDAO.getTempUserPlaylists();
            
            log.info("=== 디버그: 모든 플레이리스트 조회 ===");
            log.info("임시 사용자 플레이리스트: {}개", tempPlaylists.size());
            
            Map<String, Object> result = new HashMap<>();
            result.put("tempPlaylists", tempPlaylists);
            result.put("tempCount", tempPlaylists.size());
            
            return ResponseEntity.ok(result);
            
        } catch (Exception e) {
            log.error("플레이리스트 디버그 조회 실패", e);
            return ResponseEntity.internalServerError().body("디버그 조회 실패: " + e.getMessage());
        }
    }

    /**
     * 추천 기준 검증 API
     */
    @PostMapping("/validate")
    @ResponseBody
    public ResponseEntity<Object> validateRequest(@RequestBody PlaylistRequestDTO request) {
        
        try {
            // 필수 필드 검증
            if (request.getMusicOrigin() == null || request.getMusicOrigin().isEmpty()) {
                return ResponseEntity.badRequest().body("음악 국가를 선택해주세요.");
            }
            
            if (request.getDestinationType() == null || request.getDestinationType().isEmpty()) {
                return ResponseEntity.badRequest().body("여행지 타입을 선택해주세요.");
            }
            
            if (request.getMusicGenre() == null || request.getMusicGenre().isEmpty()) {
                return ResponseEntity.badRequest().body("음악 장르를 선택해주세요.");
            }
            
            if (request.getTimeOfDay() == null || request.getTimeOfDay().isEmpty()) {
                return ResponseEntity.badRequest().body("시간대를 선택해주세요.");
            }
            
            if (request.getTravelStyle() == null || request.getTravelStyle().isEmpty()) {
                return ResponseEntity.badRequest().body("여행 스타일을 선택해주세요.");
            }
            
            // 유효한 값 검증
            if (!isValidMusicOrigin(request.getMusicOrigin())) {
                return ResponseEntity.badRequest().body("유효하지 않은 음악 국가입니다.");
            }
            
            if (!isValidDestinationType(request.getDestinationType())) {
                return ResponseEntity.badRequest().body("유효하지 않은 여행지 타입입니다.");
            }
            
            if (!isValidMusicGenre(request.getMusicGenre())) {
                return ResponseEntity.badRequest().body("유효하지 않은 음악 장르입니다.");
            }
            
            if (!isValidTimeOfDay(request.getTimeOfDay())) {
                return ResponseEntity.badRequest().body("유효하지 않은 시간대입니다.");
            }
            
            if (!isValidTravelStyle(request.getTravelStyle())) {
                return ResponseEntity.badRequest().body("유효하지 않은 여행 스타일입니다.");
            }
            
            return ResponseEntity.ok("유효한 요청입니다.");
            
        } catch (Exception e) {
            log.error("요청 검증 실패", e);
            return ResponseEntity.internalServerError().body("요청 검증 중 오류가 발생했습니다.");
        }
    }
    
    /**
     * 사용자 ID 생성 또는 조회
     */
    private String getOrCreateUserId(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            userId = "playlist_" + System.currentTimeMillis();
            session.setAttribute("userId", userId);
        }
        return userId;
    }
    
    // 유효성 검증 메소드들
    private boolean isValidMusicOrigin(String musicOrigin) {
        return "korean".equals(musicOrigin) || "foreign".equals(musicOrigin) || "mixed".equals(musicOrigin);
    }
    
    private boolean isValidDestinationType(String destinationType) {
        switch (destinationType) {
            case "pension":
            case "highway":
            case "beach":
            case "resort":
            case "mountain":
            case "city":
            case "camping":
            case "hotspring":
                return true;
            default:
                return false;
        }
    }
    
    private boolean isValidMusicGenre(String musicGenre) {
        switch (musicGenre) {
            case "classic":
            case "rock":
            case "energetic":
            case "quiet":
            case "jazz":
            case "pop":
            case "hiphop":
            case "indie":
                return true;
            default:
                return false;
        }
    }
    
    private boolean isValidTimeOfDay(String timeOfDay) {
        switch (timeOfDay) {
            case "morning":
            case "afternoon":
            case "evening":
            case "night":
                return true;
            default:
                return false;
        }
    }
    
    private boolean isValidTravelStyle(String travelStyle) {
        switch (travelStyle) {
            case "adventurous":
            case "relaxed":
            case "cultural":
            case "romantic":
                return true;
            default:
                return false;
        }
    }
}