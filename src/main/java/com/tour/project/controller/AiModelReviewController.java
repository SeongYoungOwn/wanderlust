package com.tour.project.controller;

import com.tour.project.dao.AiModelReviewDAO;
import com.tour.project.dto.AiModelReviewDTO;
import com.tour.project.dto.MemberDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/ai/review")
public class AiModelReviewController {

    @Autowired
    private AiModelReviewDAO aiModelReviewDAO;

    /**
     * 특정 모델의 리뷰 목록 조회 (Ajax)
     */
    @GetMapping("/list/{modelId}")
    @ResponseBody
    public Map<String, Object> getReviewList(@PathVariable String modelId,
                                           @RequestParam(defaultValue = "1") int page,
                                           @RequestParam(defaultValue = "10") int pageSize,
                                           HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            String currentUserId = loginUser != null ? loginUser.getUserId() : null;
            
            // 페이징 계산
            int offset = (page - 1) * pageSize;
            
            // 리뷰 목록 조회
            List<AiModelReviewDTO> reviews = aiModelReviewDAO.getReviewsByModelId(
                modelId, currentUserId, offset, pageSize);
            
            // 총 리뷰 개수
            int totalReviews = aiModelReviewDAO.getReviewCountByModelId(modelId);
            
            // 평점 통계
            Map<String, Object> stats = aiModelReviewDAO.getReviewStatsByModelId(modelId);
            
            result.put("success", true);
            result.put("reviews", reviews);
            result.put("totalReviews", totalReviews);
            result.put("currentPage", page);
            result.put("pageSize", pageSize);
            result.put("totalPages", (int) Math.ceil((double) totalReviews / pageSize));
            result.put("stats", stats);
            result.put("isLoggedIn", loginUser != null);
            
            if (loginUser != null) {
                // 사용자가 이미 리뷰를 작성했는지 확인
                boolean hasReviewed = aiModelReviewDAO.hasUserReviewedModel(modelId, loginUser.getUserId());
                result.put("hasUserReviewed", hasReviewed);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "리뷰 목록을 불러오는 중 오류가 발생했습니다.");
        }
        
        return result;
    }

    /**
     * 리뷰 작성 (Ajax)
     */
    @PostMapping("/create")
    @ResponseBody
    public Map<String, Object> createReview(@RequestBody AiModelReviewDTO reviewDTO, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }

            // 이미 리뷰를 작성했는지 확인
            boolean hasReviewed = aiModelReviewDAO.hasUserReviewedModel(
                reviewDTO.getModelId(), loginUser.getUserId());
            if (hasReviewed) {
                result.put("success", false);
                result.put("message", "이미 이 모델에 대한 리뷰를 작성하셨습니다.");
                return result;
            }

            // 사용자 ID 설정
            reviewDTO.setUserId(loginUser.getUserId());
            
            // 유효성 검사
            if (reviewDTO.getRating() == null || reviewDTO.getRating() < 1 || reviewDTO.getRating() > 5) {
                result.put("success", false);
                result.put("message", "평점은 1~5점 사이로 입력해주세요.");
                return result;
            }
            
            if (reviewDTO.getReviewTitle() == null || reviewDTO.getReviewTitle().trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "리뷰 제목을 입력해주세요.");
                return result;
            }
            
            if (reviewDTO.getReviewContent() == null || reviewDTO.getReviewContent().trim().isEmpty()) {
                result.put("success", false);
                result.put("message", "리뷰 내용을 입력해주세요.");
                return result;
            }

            // 리뷰 작성
            int insertResult = aiModelReviewDAO.insertReview(reviewDTO);
            
            if (insertResult > 0) {
                result.put("success", true);
                result.put("message", "리뷰가 성공적으로 작성되었습니다.");
                result.put("reviewId", reviewDTO.getReviewId());
            } else {
                result.put("success", false);
                result.put("message", "리뷰 작성에 실패했습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "리뷰 작성 중 오류가 발생했습니다.");
        }
        
        return result;
    }

    /**
     * 도움됨 토글 (Ajax)
     */
    @PostMapping("/helpful/{reviewId}")
    @ResponseBody
    public Map<String, Object> toggleHelpful(@PathVariable Long reviewId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }

            String userId = loginUser.getUserId();
            
            // 현재 도움됨 상태 확인
            boolean isHelped = aiModelReviewDAO.isHelpedByUser(reviewId, userId);
            
            if (isHelped) {
                // 도움됨 취소
                aiModelReviewDAO.deleteHelpful(reviewId, userId);
                result.put("action", "removed");
            } else {
                // 도움됨 추가
                aiModelReviewDAO.insertHelpful(reviewId, userId);
                result.put("action", "added");
            }
            
            // 도움됨 개수 업데이트
            aiModelReviewDAO.updateHelpfulCount(reviewId);
            
            // 업데이트된 리뷰 정보 조회
            AiModelReviewDTO review = aiModelReviewDAO.getReviewById(reviewId, userId);
            
            result.put("success", true);
            result.put("helpfulCount", review.getHelpfulCount());
            result.put("isHelpedByCurrentUser", !isHelped);
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "처리 중 오류가 발생했습니다.");
        }
        
        return result;
    }

    /**
     * 리뷰 수정 (Ajax)
     */
    @PutMapping("/{reviewId}")
    @ResponseBody
    public Map<String, Object> updateReview(@PathVariable Long reviewId, 
                                          @RequestBody AiModelReviewDTO reviewDTO, 
                                          HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }

            reviewDTO.setReviewId(reviewId);
            reviewDTO.setUserId(loginUser.getUserId());
            
            // 유효성 검사
            if (reviewDTO.getRating() == null || reviewDTO.getRating() < 1 || reviewDTO.getRating() > 5) {
                result.put("success", false);
                result.put("message", "평점은 1~5점 사이로 입력해주세요.");
                return result;
            }

            // 리뷰 수정
            int updateResult = aiModelReviewDAO.updateReview(reviewDTO);
            
            if (updateResult > 0) {
                result.put("success", true);
                result.put("message", "리뷰가 성공적으로 수정되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "리뷰 수정에 실패했습니다. 본인의 리뷰만 수정할 수 있습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "리뷰 수정 중 오류가 발생했습니다.");
        }
        
        return result;
    }

    /**
     * 리뷰 삭제 (Ajax)
     */
    @DeleteMapping("/{reviewId}")
    @ResponseBody
    public Map<String, Object> deleteReview(@PathVariable Long reviewId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }

            // 리뷰 삭제
            int deleteResult = aiModelReviewDAO.deleteReview(reviewId, loginUser.getUserId());
            
            if (deleteResult > 0) {
                result.put("success", true);
                result.put("message", "리뷰가 성공적으로 삭제되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "리뷰 삭제에 실패했습니다. 본인의 리뷰만 삭제할 수 있습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "리뷰 삭제 중 오류가 발생했습니다.");
        }
        
        return result;
    }

    /**
     * 모든 AI 모델의 리뷰 통합 조회 (Ajax)
     */
    @GetMapping("/list/all")
    @ResponseBody
    public Map<String, Object> getAllReviews(@RequestParam(defaultValue = "1") int page,
                                           @RequestParam(defaultValue = "10") int pageSize,
                                           @RequestParam(defaultValue = "latest") String sort,
                                           @RequestParam(required = false) Integer rating,
                                           HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            String currentUserId = loginUser != null ? loginUser.getUserId() : null;
            
            // 페이징 계산
            int offset = (page - 1) * pageSize;
            
            // 모든 리뷰 목록 조회
            List<AiModelReviewDTO> reviews = aiModelReviewDAO.getAllReviews(
                currentUserId, offset, pageSize, sort, rating);
            
            // 총 리뷰 개수
            int totalReviews = aiModelReviewDAO.getTotalReviewCount(rating);
            
            // 전체 평점 통계
            Map<String, Object> stats = aiModelReviewDAO.getAllReviewStats();
            
            result.put("success", true);
            result.put("reviews", reviews);
            result.put("totalReviews", totalReviews);
            result.put("currentPage", page);
            result.put("pageSize", pageSize);
            result.put("totalPages", (int) Math.ceil((double) totalReviews / pageSize));
            result.put("stats", stats);
            result.put("isLoggedIn", loginUser != null);
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "전체 리뷰 목록을 불러오는 중 오류가 발생했습니다.");
        }
        
        return result;
    }

    /**
     * 사용자의 모든 리뷰 조회 (마이페이지용)
     */
    @GetMapping("/my-reviews")
    @ResponseBody
    public Map<String, Object> getMyReviews(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return result;
            }

            List<AiModelReviewDTO> reviews = aiModelReviewDAO.getReviewsByUserId(loginUser.getUserId());
            
            result.put("success", true);
            result.put("reviews", reviews);
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "리뷰 목록을 불러오는 중 오류가 발생했습니다.");
        }
        
        return result;
    }
}