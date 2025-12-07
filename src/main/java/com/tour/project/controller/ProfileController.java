package com.tour.project.controller;

import com.tour.project.dao.*;
import com.tour.project.dto.*;
import com.tour.project.service.BadgeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/profile")
public class ProfileController {
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private BadgeDAO badgeDAO;
    
    @Autowired
    private MannerEvaluationDAO mannerEvaluationDAO;
    
    @Autowired
    private TravelMbtiDAO travelMbtiDAO;
    
    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private BoardDAO boardDAO;
    
    @Autowired
    private CommentDAO commentDAO;
    
    @Autowired
    private BadgeService badgeService;

    @Autowired
    private ReportDAO reportDAO;

    @Autowired
    private ReviewDAO reviewDAO;

    // 프로필 페이지 보기
    @GetMapping("/view/{userId}")
    public String viewProfile(@PathVariable String userId, Model model, HttpSession session) {
        try {
            // 사용자 기본 정보
            MemberDTO member = memberDAO.getMemberById(userId);
            if (member == null) {
                model.addAttribute("error", "사용자를 찾을 수 없습니다.");
                return "error/404";
            }

            // 매너 통계
            UserMannerStatsDTO mannerStats = null;
            try {
                mannerStats = mannerEvaluationDAO.getUserMannerStats(userId);
            } catch (Exception e) {
                System.out.println("매너 통계 조회 실패: " + e.getMessage());
            }

            // 뱃지 목록
            List<BadgeDTO> badges = null;
            try {
                badges = badgeDAO.getUserBadges(userId);
            } catch (Exception e) {
                System.out.println("뱃지 목록 조회 실패: " + e.getMessage());
            }

            // 뱃지 진행도
            Map<String, Object> badgeProgress = null;
            try {
                badgeProgress = badgeService.getBadgeProgress(userId);
            } catch (Exception e) {
                System.out.println("뱃지 진행도 조회 실패: " + e.getMessage());
            }

            // 여행 MBTI
            UserTravelMbtiDTO userMbti = null;
            TravelMbtiResultDTO mbtiResult = null;
            try {
                userMbti = travelMbtiDAO.getLatestUserMbti(userId);
                if (userMbti != null) {
                    mbtiResult = travelMbtiDAO.getResultByType(userMbti.getMbtiType());
                }
            } catch (Exception e) {
                System.out.println("여행 MBTI 조회 실패: " + e.getMessage());
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
                System.out.println("최근 여행 계획 조회 실패: " + e.getMessage());
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
                System.out.println("최근 게시글 조회 실패: " + e.getMessage());
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
                System.out.println("통계 정보 조회 실패: " + e.getMessage());
            }

            // 신고 이력 조회 (reports 테이블이 없으면 null로 처리)
            List<ReportDTO> reportHistory = null;
            try {
                if (reportDAO != null) {
                    reportHistory = reportDAO.getUserReportHistory(userId);
                }
            } catch (Exception e) {
                // ReportDAO가 없거나 오류 시 무시
            }

            // 받은 리뷰 조회 (ReviewDAO가 없으면 null로 처리)
            List<ReviewDTO> userReviews = null;
            try {
                if (reviewDAO != null) {
                    userReviews = reviewDAO.getUserReceivedReviews(userId);
                }
            } catch (Exception e) {
                // ReviewDAO가 없거나 오류 시 무시
            }

            // 받은 매너 평가 조회
            List<MannerEvaluationDTO> mannerEvaluations = null;
            try {
                mannerEvaluations = mannerEvaluationDAO.getEvaluationsByEvaluated(userId);
            } catch (Exception e) {
                System.out.println("매너 평가 조회 실패: " + e.getMessage());
            }

            // 모델에 데이터 추가
            model.addAttribute("profileUser", member);
            model.addAttribute("mannerStats", mannerStats);
            model.addAttribute("badges", badges);
            model.addAttribute("badgeProgress", badgeProgress);
            model.addAttribute("mbtiResult", mbtiResult);
            model.addAttribute("recentTravelPlans", recentTravelPlans);
            model.addAttribute("recentPosts", recentPosts);
            model.addAttribute("totalTravelPlans", totalTravelPlans);
            model.addAttribute("completedTravels", completedTravels);
            model.addAttribute("totalPosts", totalPosts);
            model.addAttribute("totalComments", totalComments);
            model.addAttribute("reportHistory", reportHistory);
            model.addAttribute("userReviews", userReviews);
            model.addAttribute("mannerEvaluations", mannerEvaluations);

            // 현재 로그인한 사용자 정보
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            model.addAttribute("isOwnProfile", loginUser != null && loginUser.getUserId().equals(userId));

            return "member/profile";
            
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "프로필을 불러오는 중 오류가 발생했습니다.");
            return "error/500";
        }
    }
    
    // AJAX용 프로필 모달 데이터
    @GetMapping("/view/{userId}/modal")
    @ResponseBody
    public Map<String, Object> getProfileModal(@PathVariable String userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 사용자 기본 정보
            MemberDTO member = memberDAO.getMemberById(userId);
            if (member == null) {
                response.put("success", false);
                response.put("message", "사용자를 찾을 수 없습니다.");
                return response;
            }
            
            // 매너 통계
            UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(userId);
            
            // 뱃지 목록 (최대 6개)
            List<BadgeDTO> badges = badgeDAO.getUserBadges(userId);
            if (badges.size() > 6) {
                badges = badges.subList(0, 6);
            }
            
            // 여행 MBTI
            UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(userId);
            TravelMbtiResultDTO mbtiResult = null;
            if (userMbti != null) {
                mbtiResult = travelMbtiDAO.getResultByType(userMbti.getMbtiType());
            }
            
            // 최근 여행 계획 (3개)
            Map<String, Object> travelParams = new HashMap<>();
            travelParams.put("userId", userId);
            travelParams.put("offset", 0);
            travelParams.put("limit", 3);
            List<TravelPlanDTO> recentTravelPlans = travelPlanDAO.selectUserTravelPlans(travelParams);
            
            // 최근 게시글 (3개)
            Map<String, Object> boardParams = new HashMap<>();
            boardParams.put("userId", userId);
            boardParams.put("offset", 0);
            boardParams.put("limit", 3);
            List<BoardDTO> recentPosts = boardDAO.selectUserPosts(boardParams);
            
            // 응답 데이터 구성
            response.put("success", true);
            response.put("user", member);
            response.put("mannerStats", mannerStats);
            response.put("badges", badges);
            response.put("mbtiResult", mbtiResult);
            response.put("recentTravelPlans", recentTravelPlans);
            response.put("recentPosts", recentPosts);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "프로필을 불러오는 중 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    // 사용자 뱃지 부여 (관리자용)
    @PostMapping("/badge/award")
    @ResponseBody
    public Map<String, Object> awardBadge(@RequestParam String userId, 
                                          @RequestParam int badgeId,
                                          HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 체크
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"admin".equals(loginUser.getUserId())) {
                response.put("success", false);
                response.put("message", "권한이 없습니다.");
                return response;
            }
            
            // 이미 가지고 있는 뱃지인지 확인
            if (badgeDAO.hasUserBadge(userId, badgeId)) {
                response.put("success", false);
                response.put("message", "이미 보유한 뱃지입니다.");
                return response;
            }
            
            // 뱃지 부여
            int result = badgeDAO.awardBadge(userId, badgeId);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "뱃지가 부여되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "뱃지 부여에 실패했습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }
        
        return response;
    }
}