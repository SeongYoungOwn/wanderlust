package com.tour.project.controller;

import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.service.SocialTrendsService;
import com.tour.project.service.UserPreferenceLearningService;
import com.tour.project.service.TravelPlanTrendIntegrationService;
import com.tour.project.dto.TrendAnalysisResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tour.project.dao.NoticeDAO;
import com.tour.project.dto.NoticeDTO;
import com.tour.project.dao.BoardDAO;
import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.TravelJoinRequestDAO;
import com.tour.project.dto.BoardDTO;
import com.tour.project.dto.TravelPlanDTO;
import com.tour.project.dto.TravelJoinRequestDTO;
import com.tour.project.service.BadgeService;
import com.tour.project.dao.PlaylistDAO;
import com.tour.project.dto.playlist.SavedPlaylistDTO;
import org.springframework.security.crypto.password.PasswordEncoder;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.tour.project.dao.TravelDAO;
import com.tour.project.dao.MannerEvaluationDAO;
import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dao.FavoriteDAO;
import com.tour.project.dao.CommentDAO;
import com.tour.project.dto.UserMannerStatsDTO;
import com.tour.project.dto.UserTravelMbtiDTO;
import com.tour.project.dao.MessageDAO;
import com.tour.project.dto.MessageDTO;
import com.tour.project.dao.ChatMessageDAO;
import com.tour.project.dto.ChatMessageDTO;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import com.tour.project.dto.TravelParticipantDTO;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.ArrayList;

/**
 * 모바일 최적화 API 컨트롤러
 * - 모바일 디바이스에 최적화된 API 응답
 * - 압축된 데이터 전송
 * - 빠른 응답 시간 보장
 */
@Slf4j
@RestController
@RequestMapping("/api/mobile")
@RequiredArgsConstructor
public class MobileApiController {

    private final SocialTrendsService socialTrendsService;
    private final UserPreferenceLearningService userPreferenceLearningService;
    private final TravelPlanTrendIntegrationService travelPlanService;
    private final MemberDAO memberDAO;
    private final PasswordEncoder passwordEncoder;
    private final TravelPlanDAO travelPlanDAO;
    private final BoardDAO boardDAO;
    private final TravelJoinRequestDAO travelJoinRequestDAO;
    private final BadgeService badgeService;
    private final PlaylistDAO playlistDAO;
    private final NoticeDAO noticeDAO;
    private final TravelDAO travelDAO;
    private final MannerEvaluationDAO mannerEvaluationDAO;
    private final TravelMbtiDAO travelMbtiDAO;
    private final FavoriteDAO favoriteDAO;
    private final CommentDAO commentDAO;
    private final MessageDAO messageDAO;
    private final ChatMessageDAO chatMessageDAO;

    @Autowired(required = false)
    private SimpMessageSendingOperations messagingTemplate;

    @Value("${upload.path:uploads/}")
    private String uploadPath;

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> loginRequest, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        String userId = loginRequest.get("userId");
        String userPassword = loginRequest.get("userPassword");

        try {
            MemberDTO member = memberDAO.getMember(userId);

            if (member != null && passwordEncoder.matches(userPassword, member.getUserPassword())) {
                String accountStatus = member.getAccountStatus();
                if (accountStatus != null && "SUSPENDED".equals(accountStatus)) {
                    response.put("status", "error");
                    response.put("message", "계정이 정지되었습니다. 관리자에게 문의해주세요.");
                    return ResponseEntity.status(403).body(response);
                }

                session.setAttribute("loginUser", member);
                response.put("status", "success");
                response.put("message", "로그인 성공");
                response.put("user", member);
                response.put("sessionId", session.getId());
                return ResponseEntity.ok(response);
            } else {
                response.put("status", "error");
                response.put("message", "아이디 또는 비밀번호가 일치하지 않습니다.");
                return ResponseEntity.status(401).body(response);
            }
        } catch (Exception e) {
            log.error("모바일 로그인 실패", e);
            response.put("status", "error");
            response.put("message", "로그인 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/travel/list")
    public ResponseEntity<List<TravelPlanDTO>> getTravelPlans(
            HttpSession session,
            @RequestParam(required = false) String searchKeyword,
            @RequestParam(required = false) String sortBy) {
        try {
            Map<String, Object> params = new HashMap<>();

            // 검색어 파라미터 추가
            if (searchKeyword != null && !searchKeyword.isEmpty()) {
                params.put("searchKeyword", searchKeyword);
                params.put("searchType", "all");
            }

            // 정렬 파라미터 매핑 (프론트엔드 → 백엔드)
            if (sortBy != null && !sortBy.isEmpty()) {
                String sortType;
                switch (sortBy) {
                    case "popular":
                        sortType = "favorite";
                        break;
                    case "deadline":
                        sortType = "startdate_asc";
                        break;
                    case "budget_low":
                        sortType = "price_asc";
                        break;
                    case "budget_high":
                        sortType = "price_desc";
                        break;
                    case "latest":
                    default:
                        sortType = null; // 기본값: regdate DESC
                        break;
                }
                if (sortType != null) {
                    params.put("sortType", sortType);
                }
            }

            List<TravelPlanDTO> travelPlans = travelPlanDAO.getAllTravelPlans(params);

            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

            for (TravelPlanDTO plan : travelPlans) {
                try {
                    int participantCount = travelDAO.getParticipantCount(Long.valueOf(plan.getPlanId()));
                    plan.setParticipantCount(participantCount);

                    String writerId = plan.getPlanWriter();
                    if (writerId != null) {
                        MemberDTO writer = memberDAO.getMember(writerId);
                        if (writer != null) {
                            plan.setWriterName(writer.getUserName());
                        }

                        UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(writerId);
                        if (mannerStats != null) {
                            plan.setMannerTemperature(mannerStats.getAverageMannerScore());
                        }

                        UserTravelMbtiDTO mbtiInfo = travelMbtiDAO.getLatestUserMbti(writerId);
                        if (mbtiInfo != null) {
                            plan.setWriterMbti(mbtiInfo.getMbtiType());
                        }
                    }

                    if (loginUser != null) {
                        boolean isJoined = travelDAO.isUserJoined(Long.valueOf(plan.getPlanId()), loginUser.getUserId());
                        plan.setUserJoined(isJoined);

                        boolean isApproved = travelJoinRequestDAO.isApprovedForTravel(plan.getPlanId(), loginUser.getUserId());
                        plan.setUserApproved(isApproved);

                        boolean isPending = travelJoinRequestDAO.isAlreadyRequested(plan.getPlanId(), loginUser.getUserId()) && !isApproved;
                        plan.setUserRequestPending(isPending);

                        boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "TRAVEL_PLAN", plan.getPlanId());
                        plan.setFavorite(isFavorite);
                    }
                } catch (Exception e) {
                    log.error("Error enriching travel plan", e);
                }
            }

            return ResponseEntity.ok(travelPlans);
        } catch (Exception e) {
            log.error("모바일 여행 계획 목록 조회 실패", e);
            return ResponseEntity.status(500).body(null);
        }
    }

    @GetMapping("/travel/participants/{planId}")
    public ResponseEntity<Map<String, Object>> getTravelParticipants(@PathVariable int planId) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<com.tour.project.dto.TravelParticipantDTO> participants = travelDAO.getParticipantsByTravelId((long) planId);

            // 참여자 정보에 추가 데이터 보강
            List<Map<String, Object>> enrichedParticipants = new java.util.ArrayList<>();
            for (com.tour.project.dto.TravelParticipantDTO participant : participants) {
                Map<String, Object> participantData = new HashMap<>();
                participantData.put("participantId", participant.getParticipantId());
                participantData.put("userId", participant.getUserId());
                participantData.put("userName", participant.getUserName() != null ? participant.getUserName() : participant.getNickname());
                participantData.put("status", participant.getStatus());
                participantData.put("joinedDate", participant.getJoinedDate());

                // 매너온도와 MBTI 정보 추가
                try {
                    UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(participant.getUserId());
                    if (mannerStats != null) {
                        participantData.put("mannerTemperature", mannerStats.getAverageMannerScore());
                    }

                    UserTravelMbtiDTO mbtiInfo = travelMbtiDAO.getLatestUserMbti(participant.getUserId());
                    if (mbtiInfo != null) {
                        participantData.put("mbti", mbtiInfo.getMbtiType());
                    }
                } catch (Exception ex) {
                    log.debug("참여자 추가 정보 조회 오류: {}", ex.getMessage());
                }

                enrichedParticipants.add(participantData);
            }

            response.put("success", true);
            response.put("participants", enrichedParticipants);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("참여자 목록 조회 실패", e);
            response.put("success", false);
            response.put("message", "참여자 목록 조회에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/travel/detail/{planId}")
    public ResponseEntity<TravelPlanDTO> getTravelPlanDetail(@PathVariable int planId, HttpSession session) {
        try {
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                return ResponseEntity.notFound().build();
            }

            travelPlanDAO.increaseViewCount(planId);

            // 참여자 수 조회 및 설정
            int participantCount = travelDAO.getParticipantCount(Long.valueOf(planId));
            travelPlan.setParticipantCount(participantCount);

            MemberDTO writer = memberDAO.getMember(travelPlan.getPlanWriter());
            if (writer != null) {
                travelPlan.setWriterName(writer.getUserName());
            }

            UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(travelPlan.getPlanWriter());
            if (mannerStats != null) {
                travelPlan.setMannerTemperature(mannerStats.getAverageMannerScore());
            }

            UserTravelMbtiDTO mbtiInfo = travelMbtiDAO.getLatestUserMbti(travelPlan.getPlanWriter());
            if (mbtiInfo != null) {
                travelPlan.setWriterMbti(mbtiInfo.getMbtiType());
            }

            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser != null) {
                boolean isJoined = travelDAO.isUserJoined(Long.valueOf(planId), loginUser.getUserId());
                travelPlan.setUserJoined(isJoined);

                boolean isApproved = travelJoinRequestDAO.isApprovedForTravel(planId, loginUser.getUserId());
                travelPlan.setUserApproved(isApproved);

                boolean isPending = travelJoinRequestDAO.isAlreadyRequested(planId, loginUser.getUserId()) && !isApproved;
                travelPlan.setUserRequestPending(isPending);

                boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
                travelPlan.setFavorite(isFavorite);
            }

            return ResponseEntity.ok(travelPlan);
        } catch (Exception e) {
            log.error("모바일 여행 계획 상세 조회 실패", e);
            return ResponseEntity.status(500).body(null);
        }
    }

    @GetMapping("/board/list")
    public ResponseEntity<List<BoardDTO>> getBoardList(
            @RequestParam(required = false) String searchKeyword,
            @RequestParam(required = false) String category,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        try {
            Map<String, Object> params = new HashMap<>();

            // 검색어 파라미터 추가
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                params.put("searchKeyword", searchKeyword.trim());
                params.put("searchType", "all");
            }

            // 카테고리 파라미터 추가
            if (category != null && !category.trim().isEmpty() && !"전체".equals(category)) {
                params.put("category", category.trim());
            }

            log.info("게시글 목록 조회 - searchKeyword: {}, category: {}", searchKeyword, category);

            List<BoardDTO> boards = boardDAO.getAllBoards(params);

            // 각 게시글에 작성자 이름과 댓글 수 추가
            for (BoardDTO board : boards) {
                try {
                    MemberDTO writer = memberDAO.getMember(board.getBoardWriter());
                    if (writer != null) {
                        board.setWriterName(writer.getUserName());
                    }
                    int commentCount = commentDAO.getCommentCountByBoardId(board.getBoardId());
                    board.setCommentCount(commentCount);
                } catch (Exception ex) {
                    log.debug("게시글 추가 정보 조회 오류: {}", ex.getMessage());
                }
            }

            return ResponseEntity.ok(boards);
        } catch (Exception e) {
            log.error("모바일 게시글 목록 조회 실패", e);
            return ResponseEntity.status(500).body(null);
        }
    }

    @PostMapping("/travel/create")
    public ResponseEntity<Map<String, Object>> createTravelPlan(@RequestBody TravelPlanDTO travelPlan, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            travelPlan.setPlanWriter(loginUser.getUserId());
            int result = travelPlanDAO.insertTravelPlan(travelPlan);

            if (result > 0) {
                badgeService.checkAndAwardBadges(loginUser.getUserId());
                response.put("success", true);
                response.put("message", "여행 계획이 등록되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "여행 계획 등록에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("모바일 여행 계획 생성 실패", e);
            response.put("success", false);
            response.put("message", "여행 계획 등록 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // ========================================
    // 여행 계획 수정 API
    // ========================================

    @PostMapping("/travel/update/{planId}")
    public ResponseEntity<Map<String, Object>> updateTravelPlan(
            @PathVariable int planId,
            @RequestBody TravelPlanDTO travelPlan,
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 기존 여행 계획 조회
            TravelPlanDTO existingPlan = travelPlanDAO.getTravelPlan(planId);
            if (existingPlan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행 계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 작성자 확인
            if (!existingPlan.getPlanWriter().equals(loginUser.getUserId())) {
                response.put("success", false);
                response.put("message", "수정 권한이 없습니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 수정할 필드 설정
            travelPlan.setPlanId(planId);
            travelPlan.setPlanWriter(loginUser.getUserId());

            int result = travelPlanDAO.updateTravelPlan(travelPlan);

            if (result > 0) {
                response.put("success", true);
                response.put("message", "여행 계획이 수정되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "여행 계획 수정에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("모바일 여행 계획 수정 실패", e);
            response.put("success", false);
            response.put("message", "여행 계획 수정 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    // ========================================
    // 여행 계획 삭제 API
    // ========================================

    @DeleteMapping("/travel/delete/{planId}")
    public ResponseEntity<Map<String, Object>> deleteTravelPlan(
            @PathVariable int planId,
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 기존 여행 계획 조회
            TravelPlanDTO existingPlan = travelPlanDAO.getTravelPlan(planId);
            if (existingPlan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행 계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 작성자 확인
            if (!existingPlan.getPlanWriter().equals(loginUser.getUserId())) {
                response.put("success", false);
                response.put("message", "삭제 권한이 없습니다.");
                return ResponseEntity.status(403).body(response);
            }

            int result = travelPlanDAO.deleteTravelPlan(planId);

            if (result > 0) {
                response.put("success", true);
                response.put("message", "여행 계획이 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "여행 계획 삭제에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("모바일 여행 계획 삭제 실패", e);
            response.put("success", false);
            response.put("message", "여행 계획 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/board/detail/{boardId}")
    public ResponseEntity<Map<String, Object>> getBoardDetail(@PathVariable int boardId, HttpSession session) {
        try {
            BoardDTO board = boardDAO.getBoard(boardId);
            if (board == null) {
                return ResponseEntity.notFound().build();
            }

            boardDAO.increaseViews(boardId);

            MemberDTO writer = memberDAO.getMember(board.getBoardWriter());
            if (writer != null) {
                board.setWriterName(writer.getUserName());
            }

            // 댓글 목록 조회
            List<com.tour.project.dto.CommentDTO> commentList = commentDAO.getCommentsByBoardId(boardId);
            int commentCount = commentList != null ? commentList.size() : 0;
            board.setCommentCount(commentCount);

            // 댓글에 작성자 이름 추가
            List<Map<String, Object>> commentsWithWriterName = new java.util.ArrayList<>();
            if (commentList != null) {
                for (com.tour.project.dto.CommentDTO comment : commentList) {
                    Map<String, Object> commentMap = new HashMap<>();
                    commentMap.put("commentId", comment.getCommentId());
                    commentMap.put("boardId", comment.getBoardId());
                    commentMap.put("commentContent", comment.getCommentContent());
                    commentMap.put("commentWriter", comment.getCommentWriter());
                    commentMap.put("commentRegdate", comment.getCommentRegdate());

                    // 작성자 이름 조회
                    MemberDTO commentWriter = memberDAO.getMember(comment.getCommentWriter());
                    if (commentWriter != null) {
                        commentMap.put("writerName", commentWriter.getNickname() != null ? commentWriter.getNickname() : commentWriter.getUserName());
                    } else {
                        commentMap.put("writerName", comment.getCommentWriter());
                    }
                    commentsWithWriterName.add(commentMap);
                }
            }

            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser != null) {
                boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "BOARD", boardId);
                board.setFavorite(isFavorite);
            }

            // 응답 맵 생성
            Map<String, Object> response = new HashMap<>();
            response.put("boardId", board.getBoardId());
            response.put("boardTitle", board.getBoardTitle());
            response.put("boardContent", board.getBoardContent());
            response.put("boardWriter", board.getBoardWriter());
            response.put("boardRegdate", board.getBoardRegdate());
            response.put("boardCategory", board.getBoardCategory());
            response.put("viewCount", board.getBoardViews());
            response.put("commentCount", commentCount);
            response.put("writerName", board.getWriterName());
            response.put("favorite", board.isFavorite());
            response.put("comments", commentsWithWriterName);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("모바일 게시글 상세 조회 실패", e);
            return ResponseEntity.status(500).body(null);
        }
    }

    // ========================================
    // 찜하기 API
    // ========================================

    @PostMapping("/travel/favorite/{planId}")
    public ResponseEntity<Map<String, Object>> favoriteTravel(@PathVariable int planId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 이미 찜했는지 확인
            boolean alreadyFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
            if (alreadyFavorite) {
                response.put("success", false);
                response.put("message", "이미 찜한 여행입니다.");
                return ResponseEntity.ok(response);
            }

            // 찜 추가
            int result = favoriteDAO.addFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "찜했습니다.");
            } else {
                response.put("success", false);
                response.put("message", "찜하기에 실패했습니다.");
            }
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("찜하기 실패", e);
            response.put("success", false);
            response.put("message", "찜하기 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @PostMapping("/travel/unfavorite/{planId}")
    public ResponseEntity<Map<String, Object>> unfavoriteTravel(@PathVariable int planId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 찜 삭제
            int result = favoriteDAO.removeFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "찜하기를 취소했습니다.");
            } else {
                response.put("success", false);
                response.put("message", "찜하기 취소에 실패했습니다.");
            }
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("찜하기 취소 실패", e);
            response.put("success", false);
            response.put("message", "찜하기 취소 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @PostMapping("/travel/join-request/{planId}")
    public ResponseEntity<Map<String, Object>> requestJoin(@PathVariable int planId, @RequestBody Map<String, String> requestBody, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행 계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            if (travelPlan.getPlanWriter().equals(loginUser.getUserId())) {
                response.put("success", false);
                response.put("message", "본인이 작성한 여행 계획에는 신청할 수 없습니다.");
                return ResponseEntity.status(400).body(response);
            }

            // 거절된 신청이 있으면 삭제 (재신청 허용)
            travelJoinRequestDAO.deleteRejectedRequest(planId, loginUser.getUserId());

            // 이미 신청했는지 확인 (PENDING 또는 APPROVED 상태만 체크)
            boolean alreadyRequested = travelJoinRequestDAO.isAlreadyRequested(planId, loginUser.getUserId());
            if (alreadyRequested) {
                response.put("success", false);
                response.put("message", "이미 참여 신청한 여행 계획입니다.");
                return ResponseEntity.status(400).body(response);
            }

            TravelJoinRequestDTO joinRequest = new TravelJoinRequestDTO();
            joinRequest.setTravelPlanId(planId);
            joinRequest.setRequesterId(loginUser.getUserId());
            joinRequest.setRequestMessage(requestBody.get("requestMessage"));
            joinRequest.setStatus("PENDING");

            int requestResult = travelJoinRequestDAO.insertJoinRequest(joinRequest);

            if (requestResult > 0) {
                response.put("success", true);
                response.put("message", "동행 신청이 완료되었습니다. 작성자의 승인을 기다려주세요.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "동행 신청에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("모바일 동행 신청 실패", e);
            response.put("success", false);
            response.put("message", "동행 신청 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/activity/timeline")
    public ResponseEntity<Map<String, Object>> getActivityTimeline(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            String userId = loginUser.getUserId();
            List<Map<String, Object>> activities = new java.util.ArrayList<>();

            // 1. 내가 작성한 여행 계획
            try {
                List<TravelPlanDTO> myTravelPlans = travelPlanDAO.getTravelPlansByWriter(userId);
                if (myTravelPlans != null) {
                    for (TravelPlanDTO plan : myTravelPlans) {
                        if (plan.getPlanRegdate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("activityType", "PLAN_CREATED");
                            activity.put("targetTitle", plan.getPlanTitle());
                            activity.put("activityDate", plan.getPlanRegdate().toString());
                            activity.put("isRead", true);
                            activity.put("targetId", plan.getPlanId());
                            activities.add(activity);
                        }
                    }
                }
            } catch (Exception e) {
                log.debug("여행 계획 활동 조회 오류: {}", e.getMessage());
            }

            // 2. 내가 작성한 게시글
            try {
                List<BoardDTO> myPosts = boardDAO.getBoardsByWriter(userId);
                if (myPosts != null) {
                    for (BoardDTO post : myPosts) {
                        if (post.getBoardRegdate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("activityType", "POST_CREATED");
                            activity.put("targetTitle", post.getBoardTitle());
                            activity.put("activityDate", post.getBoardRegdate().toString());
                            activity.put("isRead", true);
                            activity.put("targetId", post.getBoardId());
                            activities.add(activity);
                        }
                    }
                }
            } catch (Exception e) {
                log.debug("게시글 활동 조회 오류: {}", e.getMessage());
            }

            // 3. 내가 보낸 동행 신청
            try {
                List<TravelJoinRequestDTO> mySentRequests = travelJoinRequestDAO.getJoinRequestsByRequester(userId);
                if (mySentRequests != null) {
                    for (TravelJoinRequestDTO request : mySentRequests) {
                        if (request.getRequestDate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("activityType", "REQUEST_SENT");
                            activity.put("targetTitle", request.getTravelPlanTitle() != null ? request.getTravelPlanTitle() : "동행 신청");
                            activity.put("activityDate", request.getRequestDate().toString());
                            activity.put("isRead", true);
                            activity.put("targetId", request.getTravelPlanId());
                            activities.add(activity);
                        }
                    }
                }
            } catch (Exception e) {
                log.debug("보낸 신청 활동 조회 오류: {}", e.getMessage());
            }

            // 4. 내가 받은 동행 신청
            try {
                List<TravelJoinRequestDTO> myReceivedRequests = travelJoinRequestDAO.getJoinRequestsByPlanWriter(userId);
                if (myReceivedRequests != null) {
                    for (TravelJoinRequestDTO request : myReceivedRequests) {
                        if (request.getRequestDate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("activityType", "REQUEST_RECEIVED");
                            activity.put("targetTitle", (request.getRequesterName() != null ? request.getRequesterName() : "사용자") + "님이 동행 신청을 보냈습니다");
                            activity.put("activityDate", request.getRequestDate().toString());
                            activity.put("isRead", !"PENDING".equals(request.getStatus()));
                            activity.put("targetId", request.getTravelPlanId());
                            activities.add(activity);
                        }
                    }
                }
            } catch (Exception e) {
                log.debug("받은 신청 활동 조회 오류: {}", e.getMessage());
            }

            // 5. 여행 MBTI 테스트
            try {
                UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(userId);
                if (userMbti != null && userMbti.getTestDate() != null) {
                    Map<String, Object> activity = new HashMap<>();
                    activity.put("activityType", "MBTI_TEST");
                    activity.put("targetTitle", "여행 MBTI 테스트 완료: " + userMbti.getMbtiType());
                    activity.put("activityDate", userMbti.getTestDate().toString());
                    activity.put("isRead", true);
                    activities.add(activity);
                }
            } catch (Exception e) {
                log.debug("MBTI 활동 조회 오류: {}", e.getMessage());
            }

            // 날짜 기준 내림차순 정렬
            activities.sort((a, b) -> {
                String dateA = (String) a.get("activityDate");
                String dateB = (String) b.get("activityDate");
                if (dateA == null || dateB == null) return 0;
                return dateB.compareTo(dateA);
            });

            // 최근 30개만 반환
            if (activities.size() > 30) {
                activities = activities.subList(0, 30);
            }

            response.put("success", true);
            response.put("activities", activities);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("모바일 활동 타임라인 조회 실패", e);
            response.put("success", false);
            response.put("message", "활동 타임라인 조회 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @PostMapping("/board/create")
    public ResponseEntity<Map<String, Object>> createBoard(@RequestBody BoardDTO board, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            board.setBoardWriter(loginUser.getUserId());
            int result = boardDAO.insertBoard(board);

            if (result > 0) {
                badgeService.checkAndAwardBadges(loginUser.getUserId());
                response.put("success", true);
                response.put("message", "게시글이 등록되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "게시글 등록에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("모바일 게시글 생성 실패", e);
            response.put("success", false);
            response.put("message", "게시글 등록 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // ========================================
    // 댓글 API
    // ========================================

    @PostMapping("/comment/create")
    public ResponseEntity<Map<String, Object>> createComment(@RequestBody Map<String, Object> commentData, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            Integer boardId = (Integer) commentData.get("boardId");
            String commentContent = (String) commentData.get("commentContent");

            if (boardId == null || commentContent == null || commentContent.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "필수 정보가 누락되었습니다.");
                return ResponseEntity.badRequest().body(response);
            }

            com.tour.project.dto.CommentDTO comment = new com.tour.project.dto.CommentDTO();
            comment.setBoardId(boardId);
            comment.setCommentContent(commentContent.trim());
            comment.setCommentWriter(loginUser.getUserId());

            int result = commentDAO.insertComment(comment);

            if (result > 0) {
                response.put("success", true);
                response.put("message", "댓글이 등록되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "댓글 등록에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("댓글 등록 실패", e);
            response.put("success", false);
            response.put("message", "댓글 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    @DeleteMapping("/comment/delete/{commentId}")
    public ResponseEntity<Map<String, Object>> deleteComment(@PathVariable int commentId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            com.tour.project.dto.CommentDTO comment = commentDAO.getComment(commentId);

            if (comment == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 댓글입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 작성자 확인
            if (!comment.getCommentWriter().equals(loginUser.getUserId())) {
                response.put("success", false);
                response.put("message", "삭제 권한이 없습니다.");
                return ResponseEntity.status(403).body(response);
            }

            int result = commentDAO.deleteComment(commentId);

            if (result > 0) {
                response.put("success", true);
                response.put("message", "댓글이 삭제되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "댓글 삭제에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("댓글 삭제 실패", e);
            response.put("success", false);
            response.put("message", "댓글 삭제 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/mypage")
    public ResponseEntity<Map<String, Object>> getMyPage(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            String userId = loginUser.getUserId();
            List<TravelPlanDTO> myTravelPlans = travelPlanDAO.getTravelPlansByWriter(userId);
            List<TravelJoinRequestDTO> mySentRequests = travelJoinRequestDAO.getJoinRequestsByRequester(userId);
            List<TravelJoinRequestDTO> myReceivedRequests = travelJoinRequestDAO.getJoinRequestsByPlanWriter(userId);
            List<BoardDTO> myPosts = boardDAO.getBoardsByWriter(userId);
            List<com.tour.project.dto.BadgeDTO> badges = badgeService.getUserBadges(userId);
            List<SavedPlaylistDTO> savedPlaylists = playlistDAO.getUserPlaylists(userId);

            // 참여중인 여행 조회 (다른 사람이 만든 여행 중 내가 참여 승인된 것)
            List<com.tour.project.dto.TravelParticipantDTO> joinedTravels = new java.util.ArrayList<>();
            try {
                joinedTravels = travelDAO.getParticipatingTravelsByUserId(userId);
            } catch (Exception ex) {
                log.error("참여중인 여행 조회 중 오류: {}", ex.getMessage());
            }

            // 사용자 MBTI 정보 조회
            String userMbtiType = null;
            try {
                UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(userId);
                if (userMbti != null) {
                    userMbtiType = userMbti.getMbtiType();
                }
            } catch (Exception ex) {
                log.debug("MBTI 조회 중 오류: {}", ex.getMessage());
            }

            // 사용자 정보에 MBTI 추가
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("userId", loginUser.getUserId());
            userInfo.put("userName", loginUser.getUserName());
            userInfo.put("userEmail", loginUser.getEmail());
            userInfo.put("nickname", loginUser.getNickname());
            userInfo.put("profileImage", loginUser.getProfileImage());
            userInfo.put("bio", loginUser.getBio());
            if (userMbtiType != null) {
                userInfo.put("mbtiType", userMbtiType);
            }

            response.put("success", true);
            response.put("user", userInfo);
            response.put("myTravelPlans", myTravelPlans);
            response.put("mySentRequests", mySentRequests);
            response.put("myReceivedRequests", myReceivedRequests);
            response.put("myPosts", myPosts);
            response.put("badges", badges);
            response.put("savedPlaylists", savedPlaylists);
            response.put("joinedTravels", joinedTravels);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("마이페이지 데이터 조회 실패", e);
            response.put("success", false);
            response.put("message", "데이터 조회 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // ========== 프로필 관련 API ==========

    @PostMapping("/profile/update-bio")
    public ResponseEntity<Map<String, Object>> updateBio(@RequestBody Map<String, String> requestBody, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            String bio = requestBody.get("bio");
            if (bio == null) {
                bio = "";
            }

            // bio 길이 제한 (200자)
            if (bio.length() > 200) {
                bio = bio.substring(0, 200);
            }

            memberDAO.updateBio(loginUser.getUserId(), bio);

            // 세션 사용자 정보 업데이트
            loginUser.setBio(bio);
            session.setAttribute("loginUser", loginUser);

            response.put("success", true);
            response.put("message", "자기소개가 저장되었습니다.");
            response.put("bio", bio);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("자기소개 업데이트 실패", e);
            response.put("success", false);
            response.put("message", "자기소개 저장에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // ========== MBTI 관련 API ==========

    @GetMapping("/mbti/questions")
    public ResponseEntity<Map<String, Object>> getMbtiQuestions() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<com.tour.project.dto.TravelMbtiQuestionDTO> questions = travelMbtiDAO.getAllQuestions();
            response.put("success", true);
            response.put("questions", questions);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("MBTI 질문 조회 실패", e);
            response.put("success", false);
            response.put("message", "질문을 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/mbti/result/{mbtiType}")
    public ResponseEntity<Map<String, Object>> getMbtiResult(@PathVariable String mbtiType) {
        Map<String, Object> response = new HashMap<>();
        try {
            com.tour.project.dto.TravelMbtiResultDTO result = travelMbtiDAO.getResultByType(mbtiType);
            if (result == null) {
                response.put("success", false);
                response.put("message", "해당 MBTI 타입의 결과를 찾을 수 없습니다.");
                return ResponseEntity.status(404).body(response);
            }
            response.put("success", true);
            response.put("result", result);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("MBTI 결과 조회 실패", e);
            response.put("success", false);
            response.put("message", "결과를 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @PostMapping("/mbti/save")
    public ResponseEntity<Map<String, Object>> saveMbtiResult(@RequestBody Map<String, String> requestBody, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            String mbtiType = requestBody.get("mbtiType");
            String answers = requestBody.get("answers");

            if (mbtiType == null || mbtiType.isEmpty()) {
                response.put("success", false);
                response.put("message", "MBTI 타입이 필요합니다.");
                return ResponseEntity.status(400).body(response);
            }

            UserTravelMbtiDTO userMbti = new UserTravelMbtiDTO();
            userMbti.setUserId(loginUser.getUserId());
            userMbti.setMbtiType(mbtiType);
            userMbti.setAnswers(answers);

            travelMbtiDAO.insertUserMbti(userMbti);

            // 저장된 결과 조회
            com.tour.project.dto.TravelMbtiResultDTO result = travelMbtiDAO.getResultByType(mbtiType);

            response.put("success", true);
            response.put("message", "MBTI 결과가 저장되었습니다.");
            response.put("mbtiType", mbtiType);
            response.put("result", result);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("MBTI 결과 저장 실패", e);
            response.put("success", false);
            response.put("message", "결과 저장에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/mbti/my-result")
    public ResponseEntity<Map<String, Object>> getMyMbtiResult(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(loginUser.getUserId());
            if (userMbti == null) {
                response.put("success", true);
                response.put("hasResult", false);
                response.put("message", "아직 MBTI 테스트를 진행하지 않았습니다.");
                return ResponseEntity.ok(response);
            }

            com.tour.project.dto.TravelMbtiResultDTO result = travelMbtiDAO.getResultByType(userMbti.getMbtiType());

            response.put("success", true);
            response.put("hasResult", true);
            response.put("mbtiType", userMbti.getMbtiType());
            response.put("testDate", userMbti.getTestDate());
            response.put("result", result);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("MBTI 결과 조회 실패", e);
            response.put("success", false);
            response.put("message", "결과 조회에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // 같은 MBTI 타입을 가진 사용자 목록 조회
    @GetMapping("/mbti/users/{mbtiType}")
    public ResponseEntity<Map<String, Object>> getUsersByMbtiType(@PathVariable String mbtiType) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<com.tour.project.dto.MbtiMatchUserDTO> users = travelMbtiDAO.getUsersByMbtiType(mbtiType);
            response.put("success", true);
            response.put("users", users);
            response.put("mbtiType", mbtiType);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("MBTI 사용자 목록 조회 실패", e);
            response.put("success", false);
            response.put("message", "사용자 목록을 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // 사용자 프로필 조회 API
    @GetMapping("/profile/{userId}")
    public ResponseEntity<Map<String, Object>> getUserProfile(@PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();
        try {
            // 사용자 기본 정보
            MemberDTO member = memberDAO.getMemberById(userId);
            if (member == null) {
                response.put("success", false);
                response.put("message", "사용자를 찾을 수 없습니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 사용자 정보 (민감한 정보 제외)
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("userId", member.getUserId());
            userInfo.put("userName", member.getUserName());
            userInfo.put("nickname", member.getNickname());
            userInfo.put("bio", member.getBio());
            userInfo.put("profileImage", member.getProfileImage());
            userInfo.put("mannerTemperature", member.getMannerTemperature());

            // 매너 통계
            UserMannerStatsDTO mannerStats = null;
            try {
                mannerStats = mannerEvaluationDAO.getUserMannerStats(userId);
            } catch (Exception e) {
                log.debug("매너 통계 조회 실패: {}", e.getMessage());
            }

            // 여행 MBTI
            UserTravelMbtiDTO userMbti = null;
            com.tour.project.dto.TravelMbtiResultDTO mbtiResult = null;
            try {
                userMbti = travelMbtiDAO.getLatestUserMbti(userId);
                if (userMbti != null) {
                    mbtiResult = travelMbtiDAO.getResultByType(userMbti.getMbtiType());
                }
            } catch (Exception e) {
                log.debug("여행 MBTI 조회 실패: {}", e.getMessage());
            }

            // 통계 정보
            int totalTravelPlans = 0;
            int completedTravels = 0;
            int totalPosts = 0;
            int totalComments = 0;
            try {
                totalTravelPlans = travelPlanDAO.countUserTravelPlans(userId);
                completedTravels = travelPlanDAO.countUserCompletedTravels(userId);
                totalPosts = boardDAO.countUserPosts(userId);
                totalComments = commentDAO.countUserComments(userId);
            } catch (Exception e) {
                log.debug("통계 정보 조회 실패: {}", e.getMessage());
            }

            // 최근 여행 계획 (5개)
            List<TravelPlanDTO> recentTravelPlans = null;
            try {
                Map<String, Object> travelParams = new HashMap<>();
                travelParams.put("userId", userId);
                travelParams.put("offset", 0);
                travelParams.put("limit", 5);
                recentTravelPlans = travelPlanDAO.selectUserTravelPlans(travelParams);
            } catch (Exception e) {
                log.debug("최근 여행 계획 조회 실패: {}", e.getMessage());
            }

            // 최근 게시글 (5개)
            List<BoardDTO> recentPosts = null;
            try {
                Map<String, Object> boardParams = new HashMap<>();
                boardParams.put("userId", userId);
                boardParams.put("offset", 0);
                boardParams.put("limit", 5);
                recentPosts = boardDAO.selectUserPosts(boardParams);
            } catch (Exception e) {
                log.debug("최근 게시글 조회 실패: {}", e.getMessage());
            }

            // 응답 구성
            response.put("success", true);
            response.put("user", userInfo);
            response.put("mannerStats", mannerStats);
            response.put("mbtiType", userMbti != null ? userMbti.getMbtiType() : null);
            response.put("mbtiResult", mbtiResult);
            response.put("totalTravelPlans", totalTravelPlans);
            response.put("completedTravels", completedTravels);
            response.put("totalPosts", totalPosts);
            response.put("totalComments", totalComments);
            response.put("recentTravelPlans", recentTravelPlans);
            response.put("recentPosts", recentPosts);

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("프로필 조회 실패", e);
            response.put("success", false);
            response.put("message", "프로필을 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // ========================================
    // 동행 종료 API
    // ========================================

    @PostMapping("/travel/complete/{planId}")
    public ResponseEntity<Map<String, Object>> completeTravelPlan(
            @PathVariable int planId,
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 여행 계획 조회
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행 계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 작성자 확인
            if (!travelPlan.getPlanWriter().equals(loginUser.getUserId())) {
                response.put("success", false);
                response.put("message", "여행 계획 작성자만 동행을 종료할 수 있습니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 이미 완료된 경우 (대소문자 무시)
            if ("COMPLETED".equalsIgnoreCase(travelPlan.getPlanStatus())) {
                response.put("success", false);
                response.put("message", "이미 종료된 여행입니다.");
                return ResponseEntity.ok(response);
            }

            // 동행 종료 처리
            int result = mannerEvaluationDAO.completeTravelPlan(planId, loginUser.getUserId());

            if (result > 0) {
                response.put("success", true);
                response.put("message", "동행이 종료되었습니다. 이제 동행자들을 평가할 수 있습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "동행 종료에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("동행 종료 실패", e);
            response.put("success", false);
            response.put("message", "동행 종료 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    // ========================================
    // 매너 평가 API
    // ========================================

    /**
     * 평가 대상자 목록 조회
     */
    @GetMapping("/manner/targets/{planId}")
    public ResponseEntity<Map<String, Object>> getMannerEvaluationTargets(
            @PathVariable int planId,
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 여행 계획 조회
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행 계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 완료된 여행인지 확인 (대소문자 무시)
            if (!"COMPLETED".equalsIgnoreCase(travelPlan.getPlanStatus())) {
                response.put("success", false);
                response.put("message", "완료된 여행만 평가할 수 있습니다.");
                return ResponseEntity.ok(response);
            }

            // 참여자인지 확인 (작성자 또는 승인된 참가자)
            boolean isWriter = travelPlan.getPlanWriter().equals(loginUser.getUserId());
            boolean isParticipant = travelDAO.isUserJoined(Long.valueOf(planId), loginUser.getUserId());

            if (!isWriter && !isParticipant) {
                response.put("success", false);
                response.put("message", "여행 참여자만 평가할 수 있습니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 참여자 목록 조회 (나를 제외한)
            List<com.tour.project.dto.TravelParticipantDTO> allParticipants =
                travelDAO.getParticipantsByTravelId((long) planId);

            List<Map<String, Object>> evaluationTargets = new java.util.ArrayList<>();

            // 작성자도 평가 대상에 포함 (내가 작성자가 아닌 경우)
            if (!isWriter) {
                MemberDTO writer = memberDAO.getMember(travelPlan.getPlanWriter());
                if (writer != null) {
                    boolean alreadyEvaluated = mannerEvaluationDAO.hasAlreadyEvaluated(
                        planId, loginUser.getUserId(), writer.getUserId());

                    Map<String, Object> writerInfo = new HashMap<>();
                    writerInfo.put("userId", writer.getUserId());
                    writerInfo.put("userName", writer.getUserName());
                    writerInfo.put("nickname", writer.getNickname());
                    writerInfo.put("isWriter", true);
                    writerInfo.put("alreadyEvaluated", alreadyEvaluated);
                    evaluationTargets.add(writerInfo);
                }
            }

            // 참여자들을 평가 대상에 추가 (나를 제외, 작성자도 제외 - 이미 위에서 추가됨)
            for (com.tour.project.dto.TravelParticipantDTO participant : allParticipants) {
                // 자기 자신 제외, 작성자 제외 (작성자는 위에서 별도로 추가)
                if (!participant.getUserId().equals(loginUser.getUserId())
                    && !participant.getUserId().equals(travelPlan.getPlanWriter())) {
                    boolean alreadyEvaluated = mannerEvaluationDAO.hasAlreadyEvaluated(
                        planId, loginUser.getUserId(), participant.getUserId());

                    Map<String, Object> participantInfo = new HashMap<>();
                    participantInfo.put("userId", participant.getUserId());
                    participantInfo.put("userName", participant.getUserName() != null ?
                        participant.getUserName() : participant.getNickname());
                    participantInfo.put("nickname", participant.getNickname());
                    participantInfo.put("isWriter", false);
                    participantInfo.put("alreadyEvaluated", alreadyEvaluated);
                    evaluationTargets.add(participantInfo);
                }
            }

            response.put("success", true);
            response.put("targets", evaluationTargets);
            response.put("planTitle", travelPlan.getPlanTitle());
            response.put("planDestination", travelPlan.getPlanDestination());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("평가 대상자 조회 실패", e);
            response.put("success", false);
            response.put("message", "평가 대상자를 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 매너 평가 제출
     */
    @PostMapping("/manner/evaluate")
    public ResponseEntity<Map<String, Object>> submitMannerEvaluation(
            @RequestBody Map<String, Object> evaluationData,
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            log.info("=== 모바일 매너 평가 요청 ===");
            log.info("요청 데이터: {}", evaluationData);

            Integer planId = (Integer) evaluationData.get("planId");
            String targetUserId = (String) evaluationData.get("targetUserId");
            String evaluationType = (String) evaluationData.get("evaluationType"); // LIKE or DISLIKE
            String category = (String) evaluationData.get("category"); // TIME, MANNER, RESPONSE, PLAN, SELFISH, NEVER_AGAIN
            String comment = (String) evaluationData.get("comment");

            log.info("planId: {}, targetUserId: {}, evaluationType: {}, category: {}",
                    planId, targetUserId, evaluationType, category);

            // mannerScore 파싱 (Double 또는 Integer로 올 수 있음)
            Double requestMannerScore = null;
            Object mannerScoreObj = evaluationData.get("mannerScore");
            if (mannerScoreObj != null) {
                if (mannerScoreObj instanceof Double) {
                    requestMannerScore = (Double) mannerScoreObj;
                } else if (mannerScoreObj instanceof Integer) {
                    requestMannerScore = ((Integer) mannerScoreObj).doubleValue();
                } else if (mannerScoreObj instanceof String) {
                    requestMannerScore = Double.parseDouble((String) mannerScoreObj);
                }
            }

            if (planId == null || targetUserId == null || evaluationType == null) {
                response.put("success", false);
                response.put("message", "필수 정보가 누락되었습니다.");
                return ResponseEntity.badRequest().body(response);
            }

            // 여행 계획 확인 (대소문자 무시)
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null || !"COMPLETED".equalsIgnoreCase(travelPlan.getPlanStatus())) {
                response.put("success", false);
                response.put("message", "완료된 여행만 평가할 수 있습니다.");
                return ResponseEntity.ok(response);
            }

            // 자기 자신 평가 방지
            if (loginUser.getUserId().equals(targetUserId)) {
                response.put("success", false);
                response.put("message", "자기 자신을 평가할 수 없습니다.");
                return ResponseEntity.ok(response);
            }

            // 이미 평가했는지 확인
            boolean alreadyEvaluated = mannerEvaluationDAO.hasAlreadyEvaluated(
                planId, loginUser.getUserId(), targetUserId);
            if (alreadyEvaluated) {
                response.put("success", false);
                response.put("message", "이미 평가한 사용자입니다.");
                return ResponseEntity.ok(response);
            }

            // 매너 점수 계산 (기본 36.5도 + 변화량)
            int calculatedMannerScore;
            if (requestMannerScore != null) {
                // 앱에서 전달받은 변화량을 기본 온도에 더해서 계산 (36.5 + mannerScore)
                calculatedMannerScore = (int) ((36.5 + requestMannerScore) * 10);
            } else {
                // 기존 방식: LIKE면 40.0도, DISLIKE면 33.0도
                calculatedMannerScore = "LIKE".equals(evaluationType) ? 400 : 330;
            }

            // 평가 저장
            com.tour.project.dto.MannerEvaluationDTO evaluation = new com.tour.project.dto.MannerEvaluationDTO();
            evaluation.setTravelPlanId(planId);
            evaluation.setEvaluatorId(loginUser.getUserId());
            evaluation.setEvaluatedId(targetUserId);
            // LIKE/DISLIKE를 POSITIVE/NEGATIVE로 변환 (DB 호환성)
            String dbEvaluationType = "LIKE".equals(evaluationType) ? "POSITIVE" : "NEGATIVE";
            evaluation.setEvaluationType(dbEvaluationType);
            evaluation.setIsLike("LIKE".equals(evaluationType));
            evaluation.setMannerScore(calculatedMannerScore);
            evaluation.setEvaluationCategory(category);
            evaluation.setEvaluationComment(comment);

            log.info("평가 저장 시도: evaluatorId={}, evaluatedId={}, planId={}, mannerScore={}",
                    evaluation.getEvaluatorId(), evaluation.getEvaluatedId(),
                    evaluation.getTravelPlanId(), evaluation.getMannerScore());

            int result = mannerEvaluationDAO.insertEvaluation(evaluation);
            log.info("평가 저장 결과: {}", result);

            if (result > 0) {
                // 매너 통계 재계산
                mannerEvaluationDAO.recalculateUserStats(targetUserId);

                response.put("success", true);
                response.put("message", "평가가 완료되었습니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "평가 저장에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }
        } catch (Exception e) {
            log.error("매너 평가 제출 실패: {}", e.getMessage(), e);
            response.put("success", false);
            response.put("message", "평가 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 평가 필요 여부 확인
     */
    @GetMapping("/manner/need-evaluation/{planId}")
    public ResponseEntity<Map<String, Object>> checkNeedEvaluation(
            @PathVariable int planId,
            HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("needEvaluation", false);
            return ResponseEntity.status(401).body(response);
        }

        try {
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            // 대소문자 무시
            if (travelPlan == null || !"COMPLETED".equalsIgnoreCase(travelPlan.getPlanStatus())) {
                response.put("success", true);
                response.put("needEvaluation", false);
                return ResponseEntity.ok(response);
            }

            // 참여자인지 확인
            boolean isWriter = travelPlan.getPlanWriter().equals(loginUser.getUserId());
            boolean isParticipant = travelDAO.isUserJoined(Long.valueOf(planId), loginUser.getUserId());

            if (!isWriter && !isParticipant) {
                response.put("success", true);
                response.put("needEvaluation", false);
                return ResponseEntity.ok(response);
            }

            // 평가 안 한 대상이 있는지 확인
            int pendingCount = mannerEvaluationDAO.getPendingEvaluationCount(planId, loginUser.getUserId());

            response.put("success", true);
            response.put("needEvaluation", pendingCount > 0);
            response.put("pendingCount", pendingCount);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("평가 필요 여부 확인 실패", e);
            response.put("success", false);
            response.put("needEvaluation", false);
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/notice/list")
    public ResponseEntity<Map<String, Object>> getNoticeList() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<NoticeDTO> notices = noticeDAO.getNoticeList(0, 100); // Get all notices for now
            response.put("success", true);
            response.put("noticeList", notices);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("모바일 공지사항 목록 조회 실패", e);
            response.put("success", false);
            response.put("message", "공지사항 조회 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }    
    /**
     * 모바일 최적화 트렌드 분석 (경량화 버전)
     */
    @PostMapping("/trends/quick")
    public ResponseEntity<Map<String, Object>> getQuickTrends(
            @RequestBody(required = false) Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            String mbti = requestData != null ? (String) requestData.get("mbti") : null;
            
            log.info("모바일 빠른 트렌드 분석 요청 - 사용자: {}", userId);
            
            // 압축된 트렌드 데이터 조회
            TrendAnalysisResponse trendAnalysis = socialTrendsService.analyzeCurrentTrends(userId, mbti);
            
            // 모바일 최적화: 상위 3개 여행지, 5개 키워드만 반환
            Map<String, Object> mobileOptimizedResponse = Map.of(
                "status", "success",
                "quickSummary", Map.of(
                    "topDestinations", trendAnalysis.getPopularDestinations().stream()
                        .limit(3)
                        .map(dest -> Map.of(
                            "name", dest.getDestinationName(),
                            "score", dest.getTrendScore(),
                            "trend", dest.getTrendScore() > 8.0 ? "HOT" : "RISING"
                        ))
                        .toList(),
                    "trendingKeywords", trendAnalysis.getTrendingKeywords().stream()
                        .limit(5)
                        .map(keyword -> keyword.getKeyword())
                        .toList(),
                    "analysisTime", System.currentTimeMillis()
                ),
                "hasMore", true
            );
            
            return ResponseEntity.ok(mobileOptimizedResponse);
            
        } catch (Exception e) {
            log.error("모바일 트렌드 분석 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "트렌드 분석에 실패했습니다."));
        }
    }
    
    /**
     * 모바일 맞춤 추천 (간소화 버전)
     */
    @PostMapping("/recommendations/quick")
    public ResponseEntity<Map<String, Object>> getQuickRecommendations(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            
            // 사용자 상호작용 기록
            userPreferenceLearningService.recordUserInteraction(userId, "quick_recommendation", requestData);
            
            // 간단한 추천 응답 생성
            Map<String, Object> quickRecommendation = Map.of(
                "status", "success",
                "recommendations", Map.of(
                    "primaryDestination", generatePrimaryRecommendation(requestData),
                    "alternativeDestinations", generateAlternativeRecommendations(requestData),
                    "quickTips", generateQuickTips(requestData)
                ),
                "userPreference", userPreferenceLearningService.getUserPreference(userId),
                "responseTime", System.currentTimeMillis()
            );
            
            log.info("모바일 빠른 추천 완료 - 사용자: {}", userId);
            
            return ResponseEntity.ok(quickRecommendation);
            
        } catch (Exception e) {
            log.error("모바일 추천 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "추천에 실패했습니다."));
        }
    }
    
    /**
     * 모바일 여행 계획 (빠른 버전)
     */
    @PostMapping("/planning/quick")
    public ResponseEntity<Map<String, Object>> getQuickTravelPlan(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            String destination = (String) requestData.get("destination");
            Integer days = (Integer) requestData.getOrDefault("days", 3);
            
            if (destination == null || destination.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("status", "error", "message", "목적지를 입력해주세요."));
            }
            
            // 간소화된 여행 계획 생성
            Map<String, Object> quickPlan = Map.of(
                "destination", destination,
                "duration", days,
                "quickItinerary", generateQuickItinerary(destination, days),
                "estimatedBudget", estimateQuickBudget(destination, days),
                "essentialTips", generateEssentialTips(destination),
                "trendScore", calculateDestinationTrendScore(destination)
            );
            
            log.info("모바일 빠른 계획 생성 완료 - 사용자: {}, 목적지: {}", userId, destination);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "quickPlan", quickPlan,
                "generatedAt", System.currentTimeMillis()
            ));
            
        } catch (Exception e) {
            log.error("모바일 여행 계획 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "여행 계획 생성에 실패했습니다."));
        }
    }
    
    /**
     * 모바일 디바이스 정보 수집
     */
    @PostMapping("/device-info")
    public ResponseEntity<Map<String, Object>> recordDeviceInfo(
            @RequestBody Map<String, Object> deviceInfo,
            HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            
            // 디바이스 정보 로깅 (분석용)
            log.info("모바일 디바이스 정보 - 사용자: {}, 정보: {}", userId, deviceInfo);
            
            // 디바이스 특성에 따른 최적화 설정 반환
            Map<String, Object> optimizationSettings = generateOptimizationSettings(deviceInfo);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "optimizationSettings", optimizationSettings,
                "deviceId", userId
            ));
            
        } catch (Exception e) {
            log.error("디바이스 정보 처리 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "디바이스 정보 처리에 실패했습니다."));
        }
    }
    
    /**
     * 모바일 오프라인 데이터 캐시
     */
    @GetMapping("/offline-cache")
    public ResponseEntity<Map<String, Object>> getOfflineCache(HttpSession session) {
        
        try {
            String userId = getOrCreateUserId(session);
            
            // 오프라인에서 사용할 수 있는 기본 데이터 패키지
            Map<String, Object> offlineData = Map.of(
                "popularDestinations", getTopDestinationsForOffline(),
                "travelTips", getEssentialTravelTips(),
                "emergencyInfo", getEmergencyInformation(),
                "offlineFeatures", getAvailableOfflineFeatures(),
                "lastUpdated", System.currentTimeMillis(),
                "version", "1.0"
            );
            
            log.info("오프라인 캐시 데이터 제공 - 사용자: {}", userId);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "offlineData", offlineData,
                "cacheExpiry", System.currentTimeMillis() + (24 * 60 * 60 * 1000) // 24시간
            ));
            
        } catch (Exception e) {
            log.error("오프라인 캐시 생성 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "오프라인 데이터 생성에 실패했습니다."));
        }
    }
    
    /**
     * 사용자 ID 생성 또는 조회
     */
    private String getOrCreateUserId(HttpSession session) {
        String userId = (String) session.getAttribute("userId");
        if (userId == null) {
            userId = "mobile_" + System.currentTimeMillis();
            session.setAttribute("userId", userId);
        }
        return userId;
    }
    
    /**
     * 주요 추천 여행지 생성
     */
    private Map<String, Object> generatePrimaryRecommendation(Map<String, Object> requestData) {
        String travelStyle = (String) requestData.getOrDefault("travelStyle", "culture");
        
        // 간단한 룰 기반 추천
        String destination;
        switch (travelStyle) {
            case "adventure":
                destination = "제주도";
                break;
            case "relaxation":
                destination = "강릉";
                break;
            case "culture":
                destination = "경주";
                break;
            case "food":
                destination = "부산";
                break;
            case "nature":
                destination = "설악산";
                break;
            default:
                destination = "서울";
                break;
        }
        
        return Map.of(
            "name", destination,
            "reason", travelStyle + " 스타일에 최적화된 여행지",
            "score", 8.5,
            "estimatedDays", 3
        );
    }
    
    /**
     * 대안 추천 여행지 생성
     */
    private java.util.List<Map<String, Object>> generateAlternativeRecommendations(Map<String, Object> requestData) {
        return java.util.List.of(
            Map.of("name", "여수", "score", 8.2, "type", "바다"),
            Map.of("name", "춘천", "score", 7.8, "type", "호수"),
            Map.of("name", "안동", "score", 7.5, "type", "전통")
        );
    }
    
    /**
     * 빠른 팁 생성
     */
    private java.util.List<String> generateQuickTips(Map<String, Object> requestData) {
        return java.util.List.of(
            "여행 전 날씨를 확인하세요",
            "현지 맛집을 미리 검색해보세요",
            "교통편을 미리 예약하세요"
        );
    }
    
    /**
     * 간소화된 여행 일정 생성
     */
    private java.util.List<Map<String, Object>> generateQuickItinerary(String destination, int days) {
        java.util.List<Map<String, Object>> itinerary = new java.util.ArrayList<>();
        
        for (int i = 1; i <= days; i++) {
            itinerary.add(Map.of(
                "day", i,
                "title", destination + " " + i + "일차",
                "activities", java.util.List.of("관광", "식사", "휴식"),
                "estimatedCost", 100000
            ));
        }
        
        return itinerary;
    }
    
    /**
     * 빠른 예산 추정
     */
    private Map<String, Object> estimateQuickBudget(String destination, int days) {
        int baseAmount = 100000; // 기본 일일 예산
        int total = baseAmount * days;
        
        return Map.of(
            "totalEstimate", total,
            "dailyAverage", baseAmount,
            "breakdown", Map.of(
                "accommodation", total * 0.4,
                "food", total * 0.3,
                "activities", total * 0.2,
                "transportation", total * 0.1
            )
        );
    }
    
    /**
     * 필수 팁 생성
     */
    private java.util.List<String> generateEssentialTips(String destination) {
        return java.util.List.of(
            destination + " 여행 시 편한 신발을 준비하세요",
            "현지 특산품을 꼭 맛보세요",
            "사진 촬영 명소를 미리 확인하세요"
        );
    }
    
    /**
     * 목적지 트렌드 점수 계산
     */
    private double calculateDestinationTrendScore(String destination) {
        // 간단한 트렌드 점수 (실제로는 더 복잡한 계산)
        return 7.5 + (Math.random() * 2.0); // 7.5 ~ 9.5 사이
    }
    
    /**
     * 디바이스 최적화 설정 생성
     */
    private Map<String, Object> generateOptimizationSettings(Map<String, Object> deviceInfo) {
        boolean isMobile = deviceInfo.containsKey("isMobile") ? (Boolean) deviceInfo.get("isMobile") : true;
        
        return Map.of(
            "enableDataCompression", isMobile,
            "maxImageSize", isMobile ? "medium" : "large",
            "cacheStrategy", isMobile ? "aggressive" : "normal",
            "updateFrequency", isMobile ? "onDemand" : "realtime",
            "offlineMode", isMobile ? "enabled" : "disabled"
        );
    }
    
    /**
     * 오프라인용 인기 여행지
     */
    private java.util.List<Map<String, Object>> getTopDestinationsForOffline() {
        return java.util.List.of(
            Map.of("name", "제주도", "category", "섬", "score", 9.2),
            Map.of("name", "부산", "category", "해안", "score", 8.8),
            Map.of("name", "서울", "category", "도시", "score", 8.5),
            Map.of("name", "강릉", "category", "바다", "score", 8.3),
            Map.of("name", "경주", "category", "역사", "score", 8.1)
        );
    }
    
    /**
     * 필수 여행 팁
     */
    private java.util.List<String> getEssentialTravelTips() {
        return java.util.List.of(
            "여행 보험에 가입하세요",
            "응급 연락처를 미리 저장하세요",
            "현지 언어 기본 표현을 익히세요",
            "날씨에 맞는 옷을 준비하세요",
            "중요 서류의 사본을 준비하세요"
        );
    }
    
    /**
     * 응급 정보
     */
    private Map<String, Object> getEmergencyInformation() {
        return Map.of(
            "police", "112",
            "fire", "119",
            "medical", "119",
            "tourist_hotline", "1330",
            "embassy", Map.of(
                "contact", "02-397-4114",
                "emergency", "24시간 운영"
            )
        );
    }
    
    /**
     * 오프라인 기능 목록
     */
    private java.util.List<String> getAvailableOfflineFeatures() {
        return java.util.List.of(
            "저장된 여행 계획 보기",
            "오프라인 지도 (기본)",
            "필수 연락처",
            "환율 계산기 (마지막 업데이트 기준)",
            "여행 체크리스트"
        );
    }

    // ==================== 쪽지 (Message) API ====================

    /**
     * 받은 쪽지함 조회
     */
    @GetMapping("/message/inbox")
    public ResponseEntity<Map<String, Object>> getReceivedMessages(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            int offset = (page - 1) * pageSize;
            Map<String, Object> params = new HashMap<>();
            params.put("userId", loginUser.getUserId());
            params.put("offset", offset);
            params.put("limit", pageSize);

            List<MessageDTO> messages = messageDAO.getReceivedMessages(params);
            int totalCount = messageDAO.getReceivedMessageCount(loginUser.getUserId());
            int unreadCount = messageDAO.getUnreadMessageCount(loginUser.getUserId());
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);

            response.put("success", true);
            response.put("messages", messages);
            response.put("currentPage", page);
            response.put("totalPages", totalPages);
            response.put("totalCount", totalCount);
            response.put("unreadCount", unreadCount);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("받은 쪽지함 조회 실패", e);
            response.put("success", false);
            response.put("message", "쪽지함을 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 보낸 쪽지함 조회
     */
    @GetMapping("/message/outbox")
    public ResponseEntity<Map<String, Object>> getSentMessages(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            int offset = (page - 1) * pageSize;
            Map<String, Object> params = new HashMap<>();
            params.put("userId", loginUser.getUserId());
            params.put("offset", offset);
            params.put("limit", pageSize);

            List<MessageDTO> messages = messageDAO.getSentMessages(params);
            int totalCount = messageDAO.getSentMessageCount(loginUser.getUserId());
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);

            response.put("success", true);
            response.put("messages", messages);
            response.put("currentPage", page);
            response.put("totalPages", totalPages);
            response.put("totalCount", totalCount);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("보낸 쪽지함 조회 실패", e);
            response.put("success", false);
            response.put("message", "쪽지함을 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 쪽지 상세 조회
     */
    @GetMapping("/message/{messageId}")
    public ResponseEntity<Map<String, Object>> getMessageDetail(
            @PathVariable int messageId,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            MessageDTO message = messageDAO.getMessageById(messageId);

            if (message == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 쪽지입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 권한 확인
            if (!loginUser.getUserId().equals(message.getSenderId()) &&
                !loginUser.getUserId().equals(message.getReceiverId())) {
                response.put("success", false);
                response.put("message", "접근 권한이 없습니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 받은 쪽지인 경우 읽음 처리
            if (loginUser.getUserId().equals(message.getReceiverId()) && !message.isRead()) {
                messageDAO.markAsRead(messageId);
                message.setRead(true);
            }

            response.put("success", true);
            response.put("message", message);
            response.put("isReceiver", loginUser.getUserId().equals(message.getReceiverId()));
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("쪽지 상세 조회 실패", e);
            response.put("success", false);
            response.put("message", "쪽지를 불러오는데 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 쪽지 전송
     */
    @PostMapping("/message/send")
    public ResponseEntity<Map<String, Object>> sendMessage(
            @RequestBody Map<String, String> requestData,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            String receiverNickname = requestData.get("receiverNickname");
            String receiverId = requestData.get("receiverId");
            String messageTitle = requestData.get("messageTitle");
            String messageContent = requestData.get("messageContent");

            MemberDTO receiver = null;

            // receiverId가 있으면 ID로 조회, 없으면 닉네임으로 조회
            if (receiverId != null && !receiverId.trim().isEmpty()) {
                receiver = memberDAO.getMember(receiverId);
            } else if (receiverNickname != null && !receiverNickname.trim().isEmpty()) {
                receiver = memberDAO.getMemberByNickname(receiverNickname);
            }

            if (receiver == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 사용자입니다.");
                return ResponseEntity.ok(response);
            }

            // 자기 자신에게 쪽지 보내기 방지
            if (loginUser.getUserId().equals(receiver.getUserId())) {
                response.put("success", false);
                response.put("message", "자기 자신에게는 쪽지를 보낼 수 없습니다.");
                return ResponseEntity.ok(response);
            }

            // MessageDTO 생성
            MessageDTO message = new MessageDTO();
            message.setSenderId(loginUser.getUserId());
            message.setReceiverId(receiver.getUserId());
            message.setMessageTitle(messageTitle);
            message.setMessageContent(messageContent);

            int result = messageDAO.sendMessage(message);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "쪽지가 전송되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "쪽지 전송에 실패했습니다.");
            }
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("쪽지 전송 실패", e);
            response.put("success", false);
            response.put("message", "쪽지 전송에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 받은 쪽지 삭제
     */
    @PostMapping("/message/delete/received")
    public ResponseEntity<Map<String, Object>> deleteReceivedMessage(
            @RequestBody Map<String, Integer> requestData,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            Integer messageId = requestData.get("messageId");
            Map<String, Object> params = new HashMap<>();
            params.put("messageId", messageId);
            params.put("userId", loginUser.getUserId());

            int result = messageDAO.deleteReceivedMessage(params);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "쪽지가 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "쪽지 삭제에 실패했습니다.");
            }
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("받은 쪽지 삭제 실패", e);
            response.put("success", false);
            response.put("message", "쪽지 삭제에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 보낸 쪽지 삭제
     */
    @PostMapping("/message/delete/sent")
    public ResponseEntity<Map<String, Object>> deleteSentMessage(
            @RequestBody Map<String, Integer> requestData,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            Integer messageId = requestData.get("messageId");
            Map<String, Object> params = new HashMap<>();
            params.put("messageId", messageId);
            params.put("userId", loginUser.getUserId());

            int result = messageDAO.deleteSentMessage(params);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "쪽지가 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "쪽지 삭제에 실패했습니다.");
            }
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("보낸 쪽지 삭제 실패", e);
            response.put("success", false);
            response.put("message", "쪽지 삭제에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 읽지 않은 쪽지 개수 조회
     */
    @GetMapping("/message/unread-count")
    public ResponseEntity<Map<String, Object>> getUnreadMessageCount(HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("count", 0);
            return ResponseEntity.status(401).body(response);
        }

        try {
            int unreadCount = messageDAO.getUnreadMessageCount(loginUser.getUserId());
            response.put("success", true);
            response.put("count", unreadCount);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("읽지 않은 쪽지 개수 조회 실패", e);
            response.put("success", false);
            response.put("count", 0);
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 닉네임 검색 (자동완성용)
     */
    @GetMapping("/message/search-nicknames")
    public ResponseEntity<Map<String, Object>> searchNicknames(
            @RequestParam String query,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("nicknames", new java.util.ArrayList<>());
            return ResponseEntity.status(401).body(response);
        }

        try {
            List<MemberDTO> members = memberDAO.searchNicknamesByQuery(query, loginUser.getUserId());
            java.util.List<Map<String, String>> nicknames = new java.util.ArrayList<>();
            for (MemberDTO member : members) {
                if (member.getNickname() != null && !member.getNickname().trim().isEmpty()) {
                    Map<String, String> nicknameInfo = new HashMap<>();
                    nicknameInfo.put("nickname", member.getNickname());
                    nicknameInfo.put("userName", member.getUserName());
                    nicknames.add(nicknameInfo);
                }
            }

            response.put("success", true);
            response.put("nicknames", nicknames);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("닉네임 검색 실패", e);
            response.put("success", false);
            response.put("nicknames", new java.util.ArrayList<>());
            return ResponseEntity.status(500).body(response);
        }
    }

    // ============================
    // 채팅 API (웹과 연동)
    // ============================

    /**
     * 내 채팅방 목록 조회 (참여 중인 여행 계획 목록)
     */
    @GetMapping("/chat/my-rooms")
    public ResponseEntity<Map<String, Object>> getMyChatRooms(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            response.put("chatRooms", new java.util.ArrayList<>());
            return ResponseEntity.status(401).body(response);
        }

        try {
            String userId = loginUser.getUserId();
            log.info("채팅방 목록 조회 - 사용자: {}", userId);

            // 사용자가 참여 중인 여행 계획(채팅방) 목록 조회
            List<TravelPlanDTO> chatRooms = travelPlanDAO.getMyParticipatingTravelPlans(userId);

            // 각 채팅방의 최근 메시지 조회
            if (chatRooms != null && !chatRooms.isEmpty()) {
                for (TravelPlanDTO room : chatRooms) {
                    try {
                        List<ChatMessageDTO> recentMessages = chatMessageDAO.getLatestMessages(room.getPlanId(), 1);
                        if (recentMessages != null && !recentMessages.isEmpty()) {
                            room.setLastMessage(recentMessages.get(0).getContent());
                            java.time.LocalDateTime lastMsgTime = recentMessages.get(0).getTimestamp();
                            if (lastMsgTime != null) {
                                room.setLastMessageTime(java.sql.Timestamp.valueOf(lastMsgTime));
                            }
                        }
                    } catch (Exception e) {
                        log.warn("채팅방 {}의 최근 메시지 조회 오류: {}", room.getPlanId(), e.getMessage());
                    }
                }
            }

            response.put("success", true);
            response.put("chatRooms", chatRooms != null ? chatRooms : new java.util.ArrayList<>());
            log.info("채팅방 목록 조회 성공: {}개", chatRooms != null ? chatRooms.size() : 0);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("채팅방 목록 조회 실패", e);
            response.put("success", false);
            response.put("message", "채팅방 목록을 불러오는데 실패했습니다.");
            response.put("chatRooms", new java.util.ArrayList<>());
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 채팅 메시지 조회 (페이징)
     */
    @GetMapping("/chat/messages/{travelPlanId}")
    public ResponseEntity<Map<String, Object>> getChatMessages(
            @PathVariable int travelPlanId,
            @RequestParam(defaultValue = "50") int limit,
            @RequestParam(defaultValue = "0") int offset,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            response.put("messages", new java.util.ArrayList<>());
            return ResponseEntity.status(401).body(response);
        }

        try {
            log.info("채팅 메시지 조회 - planId: {}, limit: {}, offset: {}", travelPlanId, limit, offset);

            // 메시지 조회
            List<ChatMessageDTO> messages = chatMessageDAO.getRecentMessages(travelPlanId, limit, offset);
            int totalCount = chatMessageDAO.getMessageCount(travelPlanId);

            response.put("success", true);
            response.put("messages", messages != null ? messages : new java.util.ArrayList<>());
            response.put("totalCount", totalCount);
            response.put("hasMore", (offset + limit) < totalCount);

            log.info("채팅 메시지 조회 성공: {}개 / 전체 {}개", messages != null ? messages.size() : 0, totalCount);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("채팅 메시지 조회 실패", e);
            response.put("success", false);
            response.put("message", "채팅 내역을 불러올 수 없습니다.");
            response.put("messages", new java.util.ArrayList<>());
            response.put("totalCount", 0);
            response.put("hasMore", false);
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 채팅 메시지 전송 (REST API - 웹소켓 대체)
     */
    @PostMapping("/chat/send")
    public ResponseEntity<Map<String, Object>> sendChatMessage(
            @RequestBody Map<String, Object> requestData,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            Integer travelPlanId = (Integer) requestData.get("travelPlanId");
            String content = (String) requestData.get("content");

            if (travelPlanId == null || content == null || content.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "필수 정보가 누락되었습니다.");
                return ResponseEntity.badRequest().body(response);
            }

            log.info("채팅 메시지 전송 - planId: {}, sender: {}", travelPlanId, loginUser.getUserId());

            // 메시지 DTO 생성
            ChatMessageDTO chatMessage = new ChatMessageDTO();
            chatMessage.setTravelPlanId(travelPlanId);
            chatMessage.setSenderId(loginUser.getUserId());
            chatMessage.setSenderName(loginUser.getUserName());
            chatMessage.setContent(content.trim());
            chatMessage.setType(ChatMessageDTO.MessageType.CHAT);
            chatMessage.setTimestamp(LocalDateTime.now());

            // DB에 저장
            int result = chatMessageDAO.insertChatMessage(chatMessage);

            if (result > 0) {
                response.put("success", true);
                response.put("message", "메시지가 전송되었습니다.");
                response.put("chatMessage", chatMessage);
                log.info("채팅 메시지 전송 성공");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "메시지 전송에 실패했습니다.");
                return ResponseEntity.ok(response);
            }

        } catch (Exception e) {
            log.error("채팅 메시지 전송 실패", e);
            response.put("success", false);
            response.put("message", "메시지 전송에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 새 메시지 조회 (폴링용 - 특정 시간 이후 메시지)
     */
    @GetMapping("/chat/new-messages/{travelPlanId}")
    public ResponseEntity<Map<String, Object>> getNewChatMessages(
            @PathVariable int travelPlanId,
            @RequestParam String lastTimestamp,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            response.put("messages", new java.util.ArrayList<>());
            return ResponseEntity.status(401).body(response);
        }

        try {
            // ISO 8601 형식 파싱
            LocalDateTime timestamp;
            try {
                timestamp = LocalDateTime.parse(lastTimestamp, DateTimeFormatter.ISO_DATE_TIME);
            } catch (Exception e) {
                // 다른 형식 시도
                timestamp = LocalDateTime.parse(lastTimestamp.replace("Z", "").replace("T", " "),
                    DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            }

            log.debug("새 메시지 조회 - planId: {}, lastTimestamp: {}", travelPlanId, timestamp);

            // 새 메시지 조회
            List<ChatMessageDTO> newMessages = chatMessageDAO.getNewChatMessages(travelPlanId, timestamp);

            response.put("success", true);
            response.put("messages", newMessages != null ? newMessages : new java.util.ArrayList<>());
            response.put("count", newMessages != null ? newMessages.size() : 0);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("새 메시지 조회 실패", e);
            response.put("success", false);
            response.put("message", "새 메시지를 불러올 수 없습니다.");
            response.put("messages", new java.util.ArrayList<>());
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 채팅방 이미지 업로드 API (모바일용)
     * POST /api/mobile/chat/upload-image
     */
    @PostMapping("/chat/upload-image")
    public ResponseEntity<Map<String, Object>> uploadChatImage(
            @RequestParam("travelPlanId") int travelPlanId,
            @RequestParam("file") MultipartFile file,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        // 1. 로그인 세션 확인
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 2. 해당 여행계획의 참여자인지 확인
            TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(travelPlanId);
            if (plan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            String userId = loginUser.getUserId();
            boolean isWriter = userId.equals(plan.getPlanWriter());
            boolean isParticipant = travelDAO.isUserJoined((long) travelPlanId, userId);

            if (!isWriter && !isParticipant) {
                response.put("success", false);
                response.put("message", "채팅방에 참여할 권한이 없습니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 3. 파일 유효성 검사
            if (file.isEmpty()) {
                response.put("success", false);
                response.put("message", "파일이 비어있습니다.");
                return ResponseEntity.badRequest().body(response);
            }

            // 이미지 파일 타입 확인
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                response.put("success", false);
                response.put("message", "이미지 파일만 업로드 가능합니다.");
                return ResponseEntity.badRequest().body(response);
            }

            // 4. 이미지 파일을 /uploads/chat/ 폴더에 저장 (파일명은 UUID로)
            String chatUploadPath = uploadPath + "chat/";
            File uploadDir = new File(chatUploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            String originalFilename = file.getOriginalFilename();
            String fileExtension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }
            String uniqueFilename = UUID.randomUUID().toString() + fileExtension;

            Path filePath = Paths.get(chatUploadPath + uniqueFilename);
            Files.write(filePath, file.getBytes());

            // 파일 URL 생성
            String fileUrl = "/chat/file/" + uniqueFilename;

            // 5. 저장된 파일 경로를 content로 해서 채팅 메시지(type: IMAGE)를 DB에 저장
            ChatMessageDTO chatMessage = new ChatMessageDTO();
            chatMessage.setTravelPlanId(travelPlanId);
            chatMessage.setSenderId(userId);
            chatMessage.setSenderName(loginUser.getUserName());
            chatMessage.setContent(fileUrl);
            chatMessage.setType(ChatMessageDTO.MessageType.IMAGE);
            chatMessage.setTimestamp(LocalDateTime.now());
            chatMessage.setFileName(uniqueFilename);
            chatMessage.setFilePath(fileUrl);
            chatMessage.setOriginalFilename(originalFilename);
            chatMessage.setFileType(contentType);
            chatMessage.setFileSizeBytes(file.getSize());

            // 파일 크기를 읽기 좋은 형식으로 변환
            long sizeBytes = file.getSize();
            String fileSize;
            if (sizeBytes < 1024) {
                fileSize = sizeBytes + " B";
            } else if (sizeBytes < 1024 * 1024) {
                fileSize = String.format("%.1f KB", sizeBytes / 1024.0);
            } else {
                fileSize = String.format("%.1f MB", sizeBytes / (1024.0 * 1024.0));
            }
            chatMessage.setFileSize(fileSize);

            // DB에 메시지 저장
            int result = chatMessageDAO.insertChatMessage(chatMessage);

            if (result > 0) {
                // 6. WebSocket으로 채팅방 참여자들에게 메시지 브로드캐스트
                if (messagingTemplate != null) {
                    try {
                        messagingTemplate.convertAndSend("/topic/chat/" + travelPlanId, chatMessage);
                        log.debug("WebSocket 브로드캐스트 완료 - planId: {}", travelPlanId);
                    } catch (Exception e) {
                        log.warn("WebSocket 브로드캐스트 실패 (폴링으로 대체): {}", e.getMessage());
                    }
                }

                response.put("success", true);
                response.put("fileUrl", fileUrl);
                response.put("message", chatMessage);

                log.info("채팅 이미지 업로드 성공 - planId: {}, userId: {}, file: {}",
                        travelPlanId, userId, uniqueFilename);
                return ResponseEntity.ok(response);
            } else {
                // 파일은 업로드됐지만 DB 저장 실패 - 파일 삭제
                Files.deleteIfExists(filePath);
                response.put("success", false);
                response.put("message", "메시지 저장에 실패했습니다.");
                return ResponseEntity.status(500).body(response);
            }

        } catch (IOException e) {
            log.error("파일 업로드 실패", e);
            response.put("success", false);
            response.put("message", "파일 업로드 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        } catch (Exception e) {
            log.error("채팅 이미지 업로드 실패", e);
            response.put("success", false);
            response.put("message", "이미지 업로드에 실패했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 채팅방 참여자 목록 조회 API (모바일용)
     * GET /api/mobile/chat/participants/{travelPlanId}
     */
    @GetMapping("/chat/participants/{travelPlanId}")
    public ResponseEntity<Map<String, Object>> getChatParticipants(
            @PathVariable int travelPlanId,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 여행계획 조회
            TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(travelPlanId);
            if (plan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 참여자 목록 조회
            List<TravelParticipantDTO> participants = travelDAO.getParticipantsByTravelId((long) travelPlanId);

            // 작성자 정보 추가
            MemberDTO writer = memberDAO.getMember(plan.getPlanWriter());

            // 참여자 정보를 맵 형태로 변환
            List<Map<String, Object>> participantList = new ArrayList<>();

            // 작성자를 첫 번째로 추가
            if (writer != null) {
                Map<String, Object> writerInfo = new HashMap<>();
                writerInfo.put("userId", writer.getUserId());
                writerInfo.put("userName", writer.getUserName());
                writerInfo.put("profileImage", writer.getProfileImage());
                writerInfo.put("isWriter", true);
                participantList.add(writerInfo);
            }

            // 나머지 참여자 추가 (작성자 제외)
            if (participants != null) {
                for (TravelParticipantDTO participant : participants) {
                    if (!participant.getUserId().equals(plan.getPlanWriter())) {
                        MemberDTO member = memberDAO.getMember(participant.getUserId());
                        if (member != null) {
                            Map<String, Object> participantInfo = new HashMap<>();
                            participantInfo.put("userId", member.getUserId());
                            participantInfo.put("userName", member.getUserName());
                            participantInfo.put("profileImage", member.getProfileImage());
                            participantInfo.put("isWriter", false);
                            participantList.add(participantInfo);
                        }
                    }
                }
            }

            response.put("success", true);
            response.put("participants", participantList);
            response.put("count", participantList.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("참여자 목록 조회 실패", e);
            response.put("success", false);
            response.put("message", "참여자 목록을 불러올 수 없습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 채팅방 관련 게시글(여행계획) 정보 조회 API (모바일용)
     * GET /api/mobile/chat/plan-info/{travelPlanId}
     */
    @GetMapping("/chat/plan-info/{travelPlanId}")
    public ResponseEntity<Map<String, Object>> getChatPlanInfo(
            @PathVariable int travelPlanId,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return ResponseEntity.status(401).body(response);
        }

        try {
            // 여행계획 조회
            TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(travelPlanId);
            if (plan == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 여행계획입니다.");
                return ResponseEntity.status(404).body(response);
            }

            // 작성자 정보 조회
            MemberDTO writer = memberDAO.getMember(plan.getPlanWriter());

            // 응답 데이터 구성
            Map<String, Object> planInfo = new HashMap<>();
            planInfo.put("planId", plan.getPlanId());
            planInfo.put("planTitle", plan.getPlanTitle());
            planInfo.put("planDestination", plan.getPlanDestination());
            planInfo.put("planContent", plan.getPlanContent());
            planInfo.put("planWriter", plan.getPlanWriter());
            planInfo.put("writerName", writer != null ? writer.getUserName() : plan.getPlanWriter());
            planInfo.put("writerProfileImage", writer != null ? writer.getProfileImage() : null);
            planInfo.put("planStartDate", plan.getPlanStartDate());
            planInfo.put("planEndDate", plan.getPlanEndDate());
            planInfo.put("planMaxParticipants", plan.getPlanMaxParticipants());
            planInfo.put("planCurrentParticipants", plan.getPlanCurrentParticipants());
            planInfo.put("planStatus", plan.getPlanStatus());
            planInfo.put("planCreatedAt", plan.getPlanCreatedAt());

            response.put("success", true);
            response.put("planInfo", planInfo);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("여행계획 정보 조회 실패", e);
            response.put("success", false);
            response.put("message", "여행계획 정보를 불러올 수 없습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
}