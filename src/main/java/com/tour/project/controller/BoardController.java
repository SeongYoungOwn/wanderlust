package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tour.project.dao.BoardDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dao.CommentDAO;
import com.tour.project.dao.FavoriteDAO;
import com.tour.project.dto.BoardDTO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.CommentDTO;
import com.tour.project.util.AuthUtil;
import com.tour.project.service.BadgeService;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/board")
public class BoardController {

    @Value("${upload.path}")
    private String uploadPath;

    @Autowired
    private BoardDAO boardDAO;

    @Autowired
    private MemberDAO memberDAO;

    @Autowired
    private CommentDAO commentDAO;

    @Autowired
    private FavoriteDAO favoriteDAO;

    @Autowired
    private BadgeService badgeService;
    
    
    // 게시글 목록
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public String list(@RequestParam(required = false) String category,
                      @RequestParam(required = false) String searchType,
                      @RequestParam(required = false) String searchKeyword,
                      @RequestParam(required = false) String sortBy,
                      Model model, HttpSession session) {
        System.out.println("=== 게시글 목록 요청 ===");
        System.out.println("category: " + category);
        System.out.println("searchType: " + searchType);
        System.out.println("searchKeyword: " + searchKeyword);
        System.out.println("sortBy: " + sortBy);
        
        try {
            // 검색 및 정렬 파라미터 구성
            Map<String, Object> params = new HashMap<>();
            
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                params.put("searchType", searchType != null ? searchType : "all");
                params.put("searchKeyword", searchKeyword.trim());
            }
            
            if (category != null && !category.trim().isEmpty()) {
                params.put("category", category);
            }
            
            if (sortBy != null && !sortBy.isEmpty()) {
                params.put("sortType", sortBy);
            }
            
            // 모든 목록 조회 (페이징 없음)
            List<BoardDTO> boards = boardDAO.getAllBoards(params);
            
            System.out.println("=== 목록 조회 결과 ===");
            System.out.println("조회된 게시글 수: " + (boards != null ? boards.size() : 0));
            
            // 로그인한 사용자 정보
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            
            // 각 게시글의 댓글 수와 찜하기 정보 가져오기
            java.util.Map<Integer, Integer> commentCounts = new java.util.HashMap<>();
            for (BoardDTO board : boards) {
                try {
                    int commentCount = commentDAO.getCommentCountByBoardId(board.getBoardId());
                    commentCounts.put(board.getBoardId(), commentCount);
                    
                    // 로그인한 사용자의 찜하기 여부 확인
                    if (loginUser != null) {
                        boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "BOARD", board.getBoardId());
                        board.setFavorite(isFavorite);
                    }
                } catch (Exception e) {
                    System.out.println("댓글 수 조회 오류 (게시글 ID: " + board.getBoardId() + "): " + e.getMessage());
                    commentCounts.put(board.getBoardId(), 0);
                    if (loginUser != null) {
                        board.setFavorite(false);
                    }
                }
            }
            
            
            // 모델에 데이터 추가
            model.addAttribute("boards", boards);
            model.addAttribute("commentCounts", commentCounts);
            model.addAttribute("selectedCategory", category);
            
            // 검색 파라미터 유지
            model.addAttribute("searchType", searchType);
            model.addAttribute("searchKeyword", searchKeyword);
            model.addAttribute("sortBy", sortBy);
            
        } catch (Exception e) {
            System.out.println("게시글 목록 조회 오류: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "게시글을 불러오는 중 오류가 발생했습니다.");
            model.addAttribute("boards", java.util.Collections.emptyList());
        }
        return "board/list";
    }
    
    // 게시글 작성 폼
    @RequestMapping(value = "/create", method = RequestMethod.GET)
    public String createForm(HttpSession session, RedirectAttributes redirectAttributes) {
        // 권한 체크: 로그인 + 활성 계정만 가능
        if (!AuthUtil.canWrite(session)) {
            String message = AuthUtil.getAuthMessage(session);
            redirectAttributes.addFlashAttribute("error", message);
            return "redirect:/member/login";
        }
        
        return "board/create";
    }
    
    // 게시글 작성 처리
    @RequestMapping(value = "/create", method = RequestMethod.POST)
    public String create(@RequestParam(value = "boardTitle", required = true) String boardTitle,
                        @RequestParam(value = "boardCategory", required = true) String boardCategory,
                        @RequestParam(value = "boardContent", required = true) String boardContent,
                        @RequestParam(value = "boardImage", required = false) org.springframework.web.multipart.MultipartFile imageFile,
                        HttpSession session, RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            BoardDTO board = new BoardDTO();
            board.setBoardTitle(boardTitle);
            board.setBoardCategory(boardCategory);
            board.setBoardContent(boardContent);
            board.setBoardWriter(loginUser.getUserId());
            
            // 이미지 업로드 처리
            if (imageFile != null && !imageFile.isEmpty()) {
                // 업로드 디렉토리 설정 (application.properties에서 주입)
                java.io.File uploadDir = new java.io.File(this.uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String originalFilename = imageFile.getOriginalFilename();
                String extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();

                // 파일 확장자 검증
                if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)$")) {
                    redirectAttributes.addFlashAttribute("error", "이미지 파일만 업로드 가능합니다.");
                    return "redirect:/board/create";
                }

                // 파일 크기 검증 (10MB)
                if (imageFile.getSize() > 10 * 1024 * 1024) {
                    redirectAttributes.addFlashAttribute("error", "파일 크기는 10MB를 초과할 수 없습니다.");
                    return "redirect:/board/create";
                }

                // 고유한 파일명 생성
                String newFilename = java.util.UUID.randomUUID().toString() + extension;
                java.nio.file.Path filePath = java.nio.file.Paths.get(this.uploadPath, newFilename);

                // 파일 저장
                java.nio.file.Files.copy(imageFile.getInputStream(), filePath);
                board.setBoardImage(newFilename);

                System.out.println("=== 게시글 이미지 업로드 성공 ===");
                System.out.println("저장 경로: " + uploadDir.getAbsolutePath());
                System.out.println("파일명: " + newFilename);
            }
            
            System.out.println("=== 게시글 등록 시도 ===");
            System.out.println("제목: " + board.getBoardTitle());
            System.out.println("카테고리: " + board.getBoardCategory());
            System.out.println("내용: " + board.getBoardContent());
            System.out.println("이미지: " + board.getBoardImage());
            System.out.println("작성자: " + board.getBoardWriter());
            
            int result = boardDAO.insertBoard(board);
            System.out.println("등록 결과: " + result);
            
            if (result > 0) {
                // 게시글 작성 성공 후 뱃지 체크
                try {
                    badgeService.checkAndAwardBadges(loginUser.getUserId());
                } catch (Exception e) {
                    System.err.println("뱃지 체크 중 오류 발생: " + e.getMessage());
                }
                
                redirectAttributes.addFlashAttribute("success", "게시글이 등록되었습니다.");
                return "redirect:/board/list";
            } else {
                redirectAttributes.addFlashAttribute("error", "게시글 등록에 실패했습니다.");
                return "redirect:/board/create";
            }
        } catch (Exception e) {
            System.out.println("게시글 등록 오류: " + e.getMessage());
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "게시글 등록 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/board/create";
        }
    }
    
    // 게시글 상세보기
    @RequestMapping(value = "/detail/{boardId}", method = RequestMethod.GET)
    public String detail(@PathVariable int boardId, Model model, HttpSession session,
                        RedirectAttributes redirectAttributes) {
        try {
            System.err.println("=== Board Detail 시작 ===");
            System.err.println("요청된 boardId: " + boardId);
            
            BoardDTO board = boardDAO.getBoard(boardId);
            System.err.println("BoardDAO.getBoard 결과: " + (board != null ? "정상" : "null"));
            
            if (board == null) {
                System.err.println("게시글이 존재하지 않음 - boardId: " + boardId);
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 게시글입니다.");
                return "redirect:/board/list";
            }
            
            System.err.println("게시글 정보: ID=" + board.getBoardId() + ", 제목=" + board.getBoardTitle() + ", 작성자=" + board.getBoardWriter());
            
            // 조회수 증가
            System.err.println("조회수 증가 시작");
            boardDAO.increaseViews(boardId);
            System.err.println("조회수 증가 완료");
            
            // 작성자 정보 추가
            System.err.println("작성자 정보 조회 시작: " + board.getBoardWriter());
            MemberDTO writer = memberDAO.getMember(board.getBoardWriter());
            System.err.println("작성자 정보 조회 결과: " + (writer != null ? "정상" : "null"));
            
            // 댓글 목록 및 개수 가져오기
            System.err.println("댓글 목록 조회 시작");
            List<CommentDTO> comments = commentDAO.getCommentsByBoardId(boardId);
            System.err.println("댓글 목록 조회 완료: " + (comments != null ? comments.size() + "개" : "null"));
            
            System.err.println("댓글 수 조회 시작");
            int commentCount = commentDAO.getCommentCountByBoardId(boardId);
            System.err.println("댓글 수 조회 완료: " + commentCount + "개");
            
            // 로그인한 사용자의 찜하기 여부 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            boolean userFavorite = false;
            if (loginUser != null) {
                try {
                    userFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "BOARD", boardId);
                    System.err.println("사용자 찜하기 여부: " + userFavorite);
                } catch (Exception e) {
                    System.err.println("찜하기 정보 조회 중 오류: " + e.getMessage());
                    userFavorite = false;
                }
            }
            
            // 인기 게시글 5개 가져오기
            System.err.println("인기 게시글 조회 시작");
            List<BoardDTO> popularBoards = boardDAO.getPopularBoards(5);
            System.err.println("인기 게시글 조회 완료: " + (popularBoards != null ? popularBoards.size() + "개" : "null"));

            System.err.println("모델 속성 설정 시작");
            model.addAttribute("board", board);
            model.addAttribute("writer", writer);
            model.addAttribute("comments", comments);
            model.addAttribute("commentCount", commentCount);
            model.addAttribute("userFavorite", userFavorite);
            model.addAttribute("popularBoards", popularBoards);
            System.err.println("모델 속성 설정 완료");
            
        } catch (Exception e) {
            System.err.println("=== Board Detail 오류 ===");
            System.err.println("boardId: " + boardId);
            System.err.println("오류 클래스: " + e.getClass().getName());
            System.err.println("오류 메시지: " + e.getMessage());
            if (e.getCause() != null) {
                System.err.println("원인: " + e.getCause().getClass().getName() + " - " + e.getCause().getMessage());
            }
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "게시글을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/board/list";
        }
        
        return "board/detail";
    }
    
    // 게시글 수정 폼
    @RequestMapping(value = "/edit/{boardId}", method = RequestMethod.GET)
    public String editForm(@PathVariable int boardId, HttpSession session, Model model,
                          RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            BoardDTO board = boardDAO.getBoard(boardId);
            
            if (board == null) {
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 게시글입니다.");
                return "redirect:/board/list";
            }
            
            // 작성자 확인
            if (!board.getBoardWriter().equals(loginUser.getUserId())) {
                redirectAttributes.addFlashAttribute("error", "수정 권한이 없습니다.");
                return "redirect:/board/detail/" + boardId;
            }
            
            model.addAttribute("board", board);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "게시글을 불러오는 중 오류가 발생했습니다.");
            return "redirect:/board/list";
        }
        
        return "board/edit";
    }
    
    // 게시글 수정 처리
    @RequestMapping(value = "/edit/{boardId}", method = RequestMethod.POST)
    public String edit(@PathVariable int boardId, BoardDTO board, 
                      HttpSession session, RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            // 기존 게시글 확인
            BoardDTO existingBoard = boardDAO.getBoard(boardId);
            
            if (existingBoard == null) {
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 게시글입니다.");
                return "redirect:/board/list";
            }
            
            // 작성자 확인
            if (!existingBoard.getBoardWriter().equals(loginUser.getUserId())) {
                redirectAttributes.addFlashAttribute("error", "수정 권한이 없습니다.");
                return "redirect:/board/detail/" + boardId;
            }
            
            board.setBoardId(boardId);
            board.setBoardWriter(loginUser.getUserId());
            
            int result = boardDAO.updateBoard(board);
            
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "게시글이 수정되었습니다.");
                return "redirect:/board/detail/" + boardId;
            } else {
                redirectAttributes.addFlashAttribute("error", "게시글 수정에 실패했습니다.");
                return "redirect:/board/edit/" + boardId;
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "게시글 수정 중 오류가 발생했습니다.");
            return "redirect:/board/edit/" + boardId;
        }
    }
    
    // 게시글 삭제
    @RequestMapping(value = "/delete/{boardId}", method = RequestMethod.POST)
    public String delete(@PathVariable int boardId, HttpSession session,
                        RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }

        try {
            BoardDTO board = boardDAO.getBoard(boardId);

            if (board == null) {
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 게시글입니다.");
                return "redirect:/board/list";
            }

            // 작성자 또는 관리자 확인
            boolean isWriter = board.getBoardWriter().equals(loginUser.getUserId());
            boolean isAdmin = "ADMIN".equals(loginUser.getUserRole());

            if (!isWriter && !isAdmin) {
                redirectAttributes.addFlashAttribute("error", "삭제 권한이 없습니다.");
                return "redirect:/board/detail/" + boardId;
            }

            int result = boardDAO.deleteBoard(boardId);

            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "게시글이 삭제되었습니다.");
                return "redirect:/board/list";
            } else {
                redirectAttributes.addFlashAttribute("error", "게시글 삭제에 실패했습니다.");
                return "redirect:/board/detail/" + boardId;
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "게시글 삭제 중 오류가 발생했습니다.");
            return "redirect:/board/detail/" + boardId;
        }
    }
    
    // 내 게시글 목록
    @RequestMapping(value = "/my", method = RequestMethod.GET)
    public String myBoards(HttpSession session, Model model,
                          RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            List<BoardDTO> myBoards = boardDAO.getBoardsByWriter(loginUser.getUserId());
            
            // 각 게시글의 댓글 수 가져오기
            java.util.Map<Integer, Integer> commentCounts = new java.util.HashMap<>();
            for (BoardDTO board : myBoards) {
                try {
                    int commentCount = commentDAO.getCommentCountByBoardId(board.getBoardId());
                    commentCounts.put(board.getBoardId(), commentCount);
                } catch (Exception e) {
                    System.out.println("댓글 수 조회 오류 (게시글 ID: " + board.getBoardId() + "): " + e.getMessage());
                    commentCounts.put(board.getBoardId(), 0);
                }
            }
            
            model.addAttribute("boards", myBoards);
            model.addAttribute("commentCounts", commentCounts);
            model.addAttribute("isMyBoards", true);
        } catch (Exception e) {
            model.addAttribute("error", "게시글을 불러오는 중 오류가 발생했습니다.");
        }
        
        return "board/list";
    }
    
    // 찜하기 토글 (통합 API)
    @RequestMapping(value = "/favorite/toggle", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> toggleFavorite(@RequestParam String targetType,
                                              @RequestParam int targetId,
                                              HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            System.out.println("=== 찜하기 토글 처리 ===");
            System.out.println("Type: " + targetType + ", ID: " + targetId);
            System.out.println("UserId: " + loginUser.getUserId());

            // 이미 찜했는지 확인
            boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), targetType, targetId);
            System.out.println("현재 찜 상태: " + isFavorite);

            if (isFavorite) {
                // 찜하기 취소
                int result_cnt = favoriteDAO.removeFavorite(loginUser.getUserId(), targetType, targetId);
                System.out.println("찜하기 취소 결과: " + result_cnt);
                if (result_cnt > 0) {
                    result.put("success", true);
                    result.put("bookmarked", false);
                    result.put("message", "찜하기가 취소되었습니다.");
                } else {
                    result.put("success", false);
                    result.put("message", "찜하기 취소에 실패했습니다.");
                }
            } else {
                // 찜하기 추가
                int result_cnt = favoriteDAO.addFavorite(loginUser.getUserId(), targetType, targetId);
                System.out.println("찜하기 추가 결과: " + result_cnt);
                if (result_cnt > 0) {
                    result.put("success", true);
                    result.put("bookmarked", true);
                    result.put("message", "찜 목록에 추가되었습니다.");
                } else {
                    result.put("success", false);
                    result.put("message", "찜하기에 실패했습니다.");
                }
            }

        } catch (Exception e) {
            System.err.println("찜하기 토글 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "처리 중 오류가 발생했습니다: " + e.getMessage());
        }

        return result;
    }

    // 커뮤니티 게시글 찜하기
    @RequestMapping(value = "/favorite/{boardId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> addFavorite(@PathVariable int boardId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 커뮤니티 게시글 찜하기 처리 시작 ===");
            System.out.println("boardId: " + boardId);
            System.out.println("userId: " + loginUser.getUserId());
            
            // 게시글 존재 확인
            BoardDTO board = boardDAO.getBoard(boardId);
            if (board == null) {
                System.out.println("게시글이 존재하지 않음");
                result.put("success", false);
                result.put("message", "존재하지 않는 게시글입니다.");
                return result;
            }
            
            // 이미 찜했는지 확인
            boolean alreadyFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "BOARD", boardId);
            if (alreadyFavorite) {
                System.out.println("이미 찜한 게시글");
                result.put("success", false);
                result.put("message", "이미 찜한 게시글입니다.");
                return result;
            }
            
            // 찜하기 처리
            int favoriteResult = favoriteDAO.addFavorite(loginUser.getUserId(), "BOARD", boardId);
            System.out.println("찜하기 처리 결과: " + favoriteResult);
            
            if (favoriteResult > 0) {
                result.put("success", true);
                result.put("message", "게시글을 찜 목록에 추가했습니다.");
                
                // 찜 개수 정보 반환
                int favoriteCount = favoriteDAO.getFavoriteCount("BOARD", boardId);
                result.put("favoriteCount", favoriteCount);
            } else {
                result.put("success", false);
                result.put("message", "찜하기에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("찜하기 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "찜하기 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 커뮤니티 게시글 찜하기 취소
    @RequestMapping(value = "/unfavorite/{boardId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> removeFavorite(@PathVariable int boardId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 커뮤니티 게시글 찜하기 취소 처리 시작 ===");
            System.out.println("boardId: " + boardId);
            System.out.println("userId: " + loginUser.getUserId());
            
            // 게시글 존재 확인
            BoardDTO board = boardDAO.getBoard(boardId);
            if (board == null) {
                System.out.println("게시글이 존재하지 않음");
                result.put("success", false);
                result.put("message", "존재하지 않는 게시글입니다.");
                return result;
            }
            
            // 찜했는지 확인
            boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "BOARD", boardId);
            if (!isFavorite) {
                System.out.println("찜하지 않은 게시글");
                result.put("success", false);
                result.put("message", "찜하지 않은 게시글입니다.");
                return result;
            }
            
            // 찜하기 취소 처리
            int unfavoriteResult = favoriteDAO.removeFavorite(loginUser.getUserId(), "BOARD", boardId);
            System.out.println("찜하기 취소 처리 결과: " + unfavoriteResult);
            
            if (unfavoriteResult > 0) {
                result.put("success", true);
                result.put("message", "찜 목록에서 제거했습니다.");
                
                // 찜 개수 정보 반환
                int favoriteCount = favoriteDAO.getFavoriteCount("BOARD", boardId);
                result.put("favoriteCount", favoriteCount);
            } else {
                result.put("success", false);
                result.put("message", "찜하기 취소에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("찜하기 취소 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "찜하기 취소 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
}