package com.tour.project.controller;

import com.tour.project.dao.AdminDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.service.GuideService;
import com.tour.project.dto.MemberDTO;
import com.tour.project.vo.GuideApplicationVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private AdminDAO adminDAO;

    @Autowired
    private MemberDAO memberDAO;

    @Autowired
    private GuideService guideService;
    
    // 관리자 권한 체크 메서드
    private boolean isAdmin(HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("isAdmin check: loginUser is null");
            return false;
        }

        // Debug logging
        System.out.println("isAdmin check - userId: " + loginUser.getUserId() +
                         ", userRole: " + loginUser.getUserRole());

        // Check user role first (preferred method)
        if ("ADMIN".equals(loginUser.getUserRole())) {
            return true;
        }

        // Fallback for admin user (legacy support)
        if ("admin".equals(loginUser.getUserId())) {
            return true;
        }

        return false;
    }
    
    // 관리자 인증 체크 및 리다이렉트
    private String checkAdminAuth(HttpSession session) {
        try {
            if (!isAdmin(session)) {
                return "redirect:/member/login?returnUrl=/admin";
            }
            return null;
        } catch (Exception e) {
            System.err.println("관리자 인증 체크 중 오류: " + e.getMessage());
            e.printStackTrace();
            return "redirect:/member/login?returnUrl=/admin";
        }
    }
    
    // ========== 메인 대시보드 ==========
    
    @RequestMapping(value = "/test", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> test() {
        Map<String, Object> result = new HashMap<>();
        try {
            result.put("status", "success");
            result.put("message", "Admin controller is working!");

            // Test database connection
            int totalUsers = adminDAO.getTotalUserCount();
            result.put("totalUsers", totalUsers);

            // Test getAllUsers directly
            List<Map<String, Object>> testUsers = adminDAO.getAllUsers(0, 5, "user_regdate", "DESC");
            result.put("testUsersCount", testUsers != null ? testUsers.size() : 0);
            result.put("firstUser", testUsers != null && !testUsers.isEmpty() ? testUsers.get(0) : null);
            
            // Test individual dashboard methods
            result.put("todayMembers", adminDAO.getTodayNewMembers());
            result.put("thisWeekMembers", adminDAO.getThisWeekNewMembers());
            result.put("thisMonthMembers", adminDAO.getThisMonthNewMembers());
            
            result.put("todayPosts", adminDAO.getTodayNewPosts());
            result.put("thisWeekPosts", adminDAO.getThisWeekNewPosts());
            result.put("thisMonthPosts", adminDAO.getThisMonthNewPosts());
            
            // Test new methods
            result.put("activeMemberCount", adminDAO.getActiveMemberCount());
            result.put("suspendedMemberCount", adminDAO.getSuspendedMemberCount());
            result.put("totalTravelPlanCount", adminDAO.getTotalTravelPlanCount());
            result.put("activeUsersLastWeek", adminDAO.getActiveUsersLastWeek());
            
            Double avgMannerScore = adminDAO.getAverageMannerScore();
            result.put("averageMannerScore", avgMannerScore != null ? avgMannerScore : 36.5);
            
            result.put("overdueTravelPlans", adminDAO.getOverdueTravelPlans());
            result.put("adminCount", adminDAO.getAdminCount());
            
            // Test parameterized methods
            result.put("lowMannerUsers", adminDAO.getLowMannerUsers(36.5, 5));  // 매너온도 36.5도 미만 사용자
            result.put("mostDislikedPosts", adminDAO.getMostDislikedPosts(1, 5)); // 싫어요 1개 이상인 게시글
            result.put("popularDestinations", adminDAO.getPopularDestinations(30, 5));
            result.put("dailyNewMembers", adminDAO.getDailyNewMembers(7));
            
        } catch (Exception e) {
            result.put("status", "error");
            result.put("message", e.getMessage());
            result.put("stackTrace", java.util.Arrays.toString(e.getStackTrace()));
            e.printStackTrace();
        }
        return result;
    }
    
    @RequestMapping(value = {"", "/", "/dashboard"}, method = RequestMethod.GET)
    public String dashboard(HttpSession session, Model model) {
        // Temporary bypass for testing
        // String authCheck = checkAdminAuth(session);
        // if (authCheck != null) return authCheck;
        
        try {
            // 신규 가입자 통계
            Map<String, Integer> newMembersStats = new HashMap<>();
            newMembersStats.put("today", adminDAO.getTodayNewMembers());
            newMembersStats.put("thisWeek", adminDAO.getThisWeekNewMembers());
            newMembersStats.put("thisMonth", adminDAO.getThisMonthNewMembers());
            
            // 새 게시글 통계
            Map<String, Integer> newPostsStats = new HashMap<>();
            newPostsStats.put("today", adminDAO.getTodayNewPosts());
            newPostsStats.put("thisWeek", adminDAO.getThisWeekNewPosts());
            newPostsStats.put("thisMonth", adminDAO.getThisMonthNewPosts());
            
            // 전체 통계
            Map<String, Integer> totalStats = new HashMap<>();
            totalStats.put("activeMembers", adminDAO.getActiveMemberCount());
            totalStats.put("suspendedMembers", adminDAO.getSuspendedMemberCount());
            totalStats.put("totalPosts", adminDAO.getTotalPostCount());
            totalStats.put("totalTravelPlans", adminDAO.getTotalTravelPlanCount());
            
            // 추가 통계 (고급 기능)
            Map<String, Object> enhancedStats = new HashMap<>();
            enhancedStats.put("activeUsersLastWeek", adminDAO.getActiveUsersLastWeek());
            enhancedStats.put("averageMannerScore", adminDAO.getAverageMannerScore());
            enhancedStats.put("overdueTravelPlans", adminDAO.getOverdueTravelPlans());
            enhancedStats.put("suspendedCount", adminDAO.getSuspendedMemberCount());
            enhancedStats.put("adminCount", adminDAO.getAdminCount());
            enhancedStats.put("thisMonthPosts", adminDAO.getThisMonthNewPosts());
            
            // 매너온도가 낮은 사용자 (36.5도 미만)
            List<Map<String, Object>> lowMannerUsers = adminDAO.getLowMannerUsers(36.5, 5);
            
            // 싫어요를 많이 받은 게시글 (싫어요 3개 이상)
            List<Map<String, Object>> mostDislikedPosts = adminDAO.getMostDislikedPosts(3, 5);
            
            // 추가 데이터
            List<Map<String, Object>> popularDestinations = adminDAO.getPopularDestinations(30, 5);
            List<Map<String, Object>> dailyNewMembers = adminDAO.getDailyNewMembers(7);
            
            // 모델에 추가
            model.addAttribute("newMembersStats", newMembersStats);
            model.addAttribute("newPostsStats", newPostsStats);
            model.addAttribute("totalStats", totalStats);
            model.addAttribute("enhancedStats", enhancedStats);
            model.addAttribute("lowMannerUsers", lowMannerUsers);
            model.addAttribute("mostDislikedPosts", mostDislikedPosts);
            model.addAttribute("popularDestinations", popularDestinations);
            model.addAttribute("dailyNewMembers", dailyNewMembers);
            
            return "admin/dashboard";
            
        } catch (Exception e) {
            System.err.println("관리자 대시보드 데이터 로딩 오류: " + e.getMessage());
            e.printStackTrace();
            
            // 실패시 기본값으로 fallback
            Map<String, Integer> fallbackStats = new HashMap<>();
            fallbackStats.put("today", 0);
            fallbackStats.put("thisWeek", 0);
            fallbackStats.put("thisMonth", 0);
            
            Map<String, Integer> fallbackTotalStats = new HashMap<>();
            fallbackTotalStats.put("activeMembers", 0);
            fallbackTotalStats.put("suspendedMembers", 0);
            fallbackTotalStats.put("totalPosts", 0);
            fallbackTotalStats.put("totalTravelPlans", 0);
            
            Map<String, Object> fallbackEnhancedStats = new HashMap<>();
            fallbackEnhancedStats.put("activeUsersLastWeek", 0);
            fallbackEnhancedStats.put("averageMannerScore", 36.5);
            fallbackEnhancedStats.put("overdueTravelPlans", 0);
            fallbackEnhancedStats.put("suspendedCount", 0);
            fallbackEnhancedStats.put("adminCount", 0);
            fallbackEnhancedStats.put("thisMonthPosts", 0);
            
            model.addAttribute("newMembersStats", fallbackStats);
            model.addAttribute("newPostsStats", fallbackStats);
            model.addAttribute("totalStats", fallbackTotalStats);
            model.addAttribute("enhancedStats", fallbackEnhancedStats);
            model.addAttribute("lowMannerUsers", new ArrayList<>());
            model.addAttribute("mostDislikedPosts", new ArrayList<>());
            model.addAttribute("popularDestinations", new ArrayList<>());
            model.addAttribute("dailyNewMembers", new ArrayList<>());
            
            model.addAttribute("error", "대시보드 데이터를 불러오는 중 오류가 발생했습니다. 기본값으로 표시합니다.");
            return "admin/dashboard";
        }
    }
    
    // ========== 사용자 관리 ==========
    
    @RequestMapping(value = "/users", method = RequestMethod.GET)
    public String userManagement(@RequestParam(value = "page", defaultValue = "1") int page,
                                @RequestParam(value = "size", defaultValue = "20") int size,
                                @RequestParam(value = "search", required = false) String search,
                                @RequestParam(value = "orderBy", defaultValue = "user_regdate") String orderBy,
                                @RequestParam(value = "orderDirection", defaultValue = "DESC") String orderDirection,
                                HttpSession session, Model model) {
        
        // Temporary bypass for testing
        // String authCheck = checkAdminAuth(session);
        // if (authCheck != null) return authCheck;
        
        try {
            System.out.println("========== USER MANAGEMENT PAGE DEBUG ==========");
            System.out.println("Parameters - page: " + page + ", size: " + size);
            System.out.println("Parameters - search: " + search + ", orderBy: " + orderBy + ", orderDirection: " + orderDirection);

            int offset = (page - 1) * size;
            List<Map<String, Object>> users;
            int totalUsers;

            System.out.println("Calculated offset: " + offset);

            if (search != null && !search.trim().isEmpty()) {
                System.out.println("Executing search query for: " + search.trim());
                users = adminDAO.searchUsers(search.trim(), offset, size, orderBy, orderDirection);
                totalUsers = adminDAO.getSearchUserCount(search.trim());
            } else {
                System.out.println("Executing getAllUsers query");
                users = adminDAO.getAllUsers(offset, size, orderBy, orderDirection);
                totalUsers = adminDAO.getTotalUserCount();
            }

            System.out.println("Query executed successfully");
            System.out.println("DEBUG - totalUsers: " + totalUsers);
            System.out.println("DEBUG - users size: " + (users != null ? users.size() : "null"));

            if (users != null && !users.isEmpty()) {
                System.out.println("First user data: " + users.get(0));
            }

            int totalPages = (int) Math.ceil((double) totalUsers / size);

            // Get activity statistics for all users - TEMPORARILY DISABLED FOR DEBUGGING
            /*
            List<Map<String, Object>> userStats = memberDAO.getAllUsersActivityStats();
            Map<String, Map<String, Object>> statsMap = new HashMap<>();
            for (Map<String, Object> stat : userStats) {
                String userId = (String) stat.get("user_id");
                statsMap.put(userId, stat);
            }

            // Merge statistics with user data
            for (Map<String, Object> user : users) {
                String userId = (String) user.get("user_id");
                Map<String, Object> userStat = statsMap.get(userId);
                if (userStat != null) {
                    user.put("postCount", userStat.get("postCount"));
                    user.put("commentCount", userStat.get("commentCount"));
                    user.put("reportCount", userStat.get("reportCount"));
                } else {
                    user.put("postCount", 0);
                    user.put("commentCount", 0);
                    user.put("reportCount", 0);
                }
            }
            */


            model.addAttribute("users", users);
            model.addAttribute("currentPage", page);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("totalUsers", totalUsers);
            model.addAttribute("size", size);
            model.addAttribute("search", search);
            model.addAttribute("orderBy", orderBy);
            model.addAttribute("orderDirection", orderDirection);
            
        } catch (Exception e) {
            System.err.println("========== 사용자 관리 페이지 로딩 오류 ==========");
            System.err.println("Error message: " + e.getMessage());
            System.err.println("Error class: " + e.getClass().getName());
            e.printStackTrace();
            
            // Provide empty lists to prevent JSP errors
            model.addAttribute("users", new ArrayList<>());
            model.addAttribute("currentPage", 1);
            model.addAttribute("totalPages", 0);
            model.addAttribute("totalUsers", 0);
            model.addAttribute("size", size);
            model.addAttribute("search", search);
            model.addAttribute("orderBy", orderBy);
            model.addAttribute("orderDirection", orderDirection);
            
            model.addAttribute("error", "사용자 데이터를 불러오는 중 오류가 발생했습니다. 데이터베이스 연결을 확인해주세요.");
        }
        
        return "admin/users";
    }
    
    @RequestMapping(value = "/users/{userId}/detail", method = RequestMethod.GET)
    public String userDetail(@PathVariable String userId, HttpSession session, Model model) {
        // Temporary bypass for testing
        // String authCheck = checkAdminAuth(session);
        // if (authCheck != null) return authCheck;
        
        try {
            Map<String, Object> userDetail = adminDAO.getUserDetail(userId);
            if (userDetail == null) {
                model.addAttribute("error", "사용자를 찾을 수 없습니다.");
                return "admin/users";
            }
            
            model.addAttribute("user", userDetail);
        } catch (Exception e) {
            System.err.println("사용자 상세 조회 오류: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "사용자 정보를 불러오는 중 오류가 발생했습니다.");
        }
        
        return "admin/user-detail";
    }
    
    // 계정 상태 변경 (정지/복구)
    @RequestMapping(value = "/users/{userId}/status", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> updateAccountStatus(@PathVariable String userId,
                                                   @RequestParam String status,
                                                   HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        if (!isAdmin(session)) {
            result.put("success", false);
            result.put("message", "관리자 권한이 필요합니다.");
            return result;
        }
        
        try {
            if (!"ACTIVE".equals(status) && !"SUSPENDED".equals(status)) {
                result.put("success", false);
                result.put("message", "올바르지 않은 상태값입니다.");
                return result;
            }
            
            int updated = adminDAO.updateAccountStatus(userId, status);
            if (updated > 0) {
                result.put("success", true);
                result.put("message", "계정 상태가 변경되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "계정 상태 변경에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("계정 상태 변경 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "계정 상태 변경 중 오류가 발생했습니다.");
        }
        
        return result;
    }
    
    // 사용자 강제 탈퇴 (완전 삭제)
    @RequestMapping(value = "/users/{userId}/delete", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> deleteUser(@PathVariable String userId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        if (!isAdmin(session)) {
            result.put("success", false);
            result.put("message", "관리자 권한이 필요합니다.");
            return result;
        }
        
        try {
            // 관리자 계정은 삭제할 수 없음
            if ("admin".equals(userId)) {
                result.put("success", false);
                result.put("message", "관리자 계정은 삭제할 수 없습니다.");
                return result;
            }
            
            // 사용자의 모든 활동 삭제
            adminDAO.deleteUserComments(userId);
            adminDAO.deleteUserLikes(userId);
            adminDAO.deleteUserDislikes(userId);
            adminDAO.deleteUserFavorites(userId);
            adminDAO.deleteUserMannerEvaluations(userId);
            // adminDAO.deleteUserMannerStats(userId); // Table doesn't exist
            // adminDAO.deleteUserTravelPlans(userId); // Table doesn't exist
            adminDAO.deleteUserPosts(userId);
            
            // 사용자 계정 삭제
            int deleted = adminDAO.deleteUser(userId);
            
            if (deleted > 0) {
                result.put("success", true);
                result.put("message", "사용자가 완전히 삭제되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "사용자 삭제에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("사용자 삭제 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "사용자 삭제 중 오류가 발생했습니다.");
        }
        
        return result;
    }
    
    // ========== 게시판 관리 ==========
    
    @RequestMapping(value = "/posts", method = RequestMethod.GET)
    public String postManagement(@RequestParam(value = "page", defaultValue = "1") int page,
                                @RequestParam(value = "size", defaultValue = "20") int size,
                                @RequestParam(value = "search", required = false) String search,
                                @RequestParam(value = "orderBy", defaultValue = "board_regdate") String orderBy,
                                @RequestParam(value = "orderDirection", defaultValue = "DESC") String orderDirection,
                                HttpSession session, Model model) {
        
        // Temporary bypass for testing
        // String authCheck = checkAdminAuth(session);
        // if (authCheck != null) return authCheck;
        
        try {
            int offset = (page - 1) * size;
            List<Map<String, Object>> posts;
            int totalPosts;
            
            if (search != null && !search.trim().isEmpty()) {
                posts = adminDAO.searchPosts(search.trim(), offset, size, orderBy, orderDirection);
                totalPosts = adminDAO.getSearchPostCount(search.trim());
            } else {
                posts = adminDAO.getAllPosts(offset, size, orderBy, orderDirection);
                totalPosts = adminDAO.getTotalPostCount();
            }
            
            int totalPages = (int) Math.ceil((double) totalPosts / size);
            
            model.addAttribute("posts", posts);
            model.addAttribute("currentPage", page);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("totalPosts", totalPosts);
            model.addAttribute("size", size);
            model.addAttribute("search", search);
            model.addAttribute("orderBy", orderBy);
            model.addAttribute("orderDirection", orderDirection);
            
        } catch (Exception e) {
            System.err.println("게시판 관리 페이지 로딩 오류: " + e.getMessage());
            e.printStackTrace();
            
            // Provide empty lists to prevent JSP errors
            model.addAttribute("posts", new ArrayList<>());
            model.addAttribute("currentPage", 1);
            model.addAttribute("totalPages", 0);
            model.addAttribute("totalPosts", 0);
            model.addAttribute("size", size);
            model.addAttribute("search", search);
            model.addAttribute("orderBy", orderBy);
            model.addAttribute("orderDirection", orderDirection);
            
            model.addAttribute("error", "게시글 데이터를 불러오는 중 오류가 발생했습니다. 데이터베이스 연결을 확인해주세요.");
        }
        
        return "admin/posts";
    }
    
    // 게시글 강제 삭제
    @RequestMapping(value = "/posts/{boardId}/delete", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> deletePost(@PathVariable int boardId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        if (!isAdmin(session)) {
            result.put("success", false);
            result.put("message", "관리자 권한이 필요합니다.");
            return result;
        }
        
        try {
            // 게시글 관련 데이터 삭제
            adminDAO.deletePostComments(boardId);
            adminDAO.deletePostLikes(boardId);
            adminDAO.deletePostDislikes(boardId);
            
            // 게시글 삭제
            int deleted = adminDAO.deletePost(boardId);
            
            if (deleted > 0) {
                result.put("success", true);
                result.put("message", "게시글이 삭제되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "게시글 삭제에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("게시글 삭제 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "게시글 삭제 중 오류가 발생했습니다.");
        }
        
        return result;
    }
    
    // 사용자 권한 변경 (관리자 권한 부여/해제)
    @PostMapping("/users/{userId}/role")
    @ResponseBody
    public Map<String, Object> updateUserRole(@PathVariable String userId, 
                                              @RequestParam String role,
                                              HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 관리자 권한 체크
            if (!isAdmin(session)) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return response;
            }
            
            // 자신의 권한은 변경할 수 없도록 제한
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser.getUserId().equals(userId)) {
                response.put("success", false);
                response.put("message", "자신의 권한은 변경할 수 없습니다.");
                return response;
            }
            
            // 권한 값 검증
            if (!role.equals("USER") && !role.equals("ADMIN")) {
                response.put("success", false);
                response.put("message", "올바르지 않은 권한 값입니다.");
                return response;
            }
            
            // 사용자 권한 업데이트
            int result = adminDAO.updateUserRole(userId, role);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", role.equals("ADMIN") ? 
                    "관리자 권한이 부여되었습니다." : "일반 사용자 권한으로 변경되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "사용자를 찾을 수 없습니다.");
            }
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "권한 변경 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }

    // ========== 가이드 관리 ==========

    // 가이드 신청 목록 페이지 (대기중인 신청만)
    @RequestMapping(value = "/guide/applications", method = RequestMethod.GET)
    public String guideApplications(HttpSession session, Model model) {
        // Temporary bypass for testing
        // String authCheck = checkAdminAuth(session);
        // if (authCheck != null) return authCheck;

        try {
            List<GuideApplicationVO> pendingApplications = guideService.getPendingApplications();
            model.addAttribute("applications", pendingApplications);

            // 실제 데이터 기반 통계
            int approvedGuideCount = guideService.getApprovedGuideCount();
            int monthlyApplications = guideService.getMonthlyApplicationCount();
            int totalApplications = guideService.getTotalApplicationCount();
            int approvedApplications = guideService.getApprovedApplicationCount();

            // 승인율 계산 (소수점 첫째자리까지)
            double approvalRate = 0.0;
            if (totalApplications > 0) {
                approvalRate = Math.round((double) approvedApplications * 100.0 / totalApplications * 10.0) / 10.0;
            }

            model.addAttribute("approvedGuideCount", approvedGuideCount);
            model.addAttribute("monthlyApplications", monthlyApplications);
            model.addAttribute("approvalRate", approvalRate);

        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "가이드 신청 목록을 불러오는 중 오류가 발생했습니다.");

            // 오류 시 기본값
            model.addAttribute("applications", new ArrayList<>());
            model.addAttribute("approvedGuideCount", 0);
            model.addAttribute("monthlyApplications", 0);
            model.addAttribute("approvalRate", 0.0);
        }

        return "admin/guide-applications";
    }

    // 가이드 신청 내역 전체 조회 (모든 상태)
    @RequestMapping(value = "/guide/history", method = RequestMethod.GET)
    public String guideApplicationHistory(@RequestParam(value = "page", defaultValue = "1") int page,
                                         @RequestParam(value = "size", defaultValue = "20") int size,
                                         @RequestParam(value = "status", required = false) String status,
                                         @RequestParam(value = "search", required = false) String search,
                                         @RequestParam(value = "orderBy", defaultValue = "applied_date") String orderBy,
                                         @RequestParam(value = "orderDirection", defaultValue = "DESC") String orderDirection,
                                         HttpSession session, Model model) {
        // Temporary bypass for testing
        // String authCheck = checkAdminAuth(session);
        // if (authCheck != null) return authCheck;

        try {
            int offset = (page - 1) * size;
            List<GuideApplicationVO> applications;
            int totalApplications;

            // 상태별 필터링 및 검색
            if (search != null && !search.trim().isEmpty()) {
                applications = guideService.searchApplications(search.trim(), status, offset, size, orderBy, orderDirection);
                totalApplications = guideService.getSearchApplicationCount(search.trim(), status);
            } else {
                applications = guideService.getAllApplications(status, offset, size, orderBy, orderDirection);
                totalApplications = guideService.getTotalApplicationCountByStatus(status);
            }

            int totalPages = (int) Math.ceil((double) totalApplications / size);

            // 통계 정보
            Map<String, Integer> statusCounts = new HashMap<>();
            statusCounts.put("pending", guideService.getApplicationCountByStatus("pending"));
            statusCounts.put("approved", guideService.getApplicationCountByStatus("approved"));
            statusCounts.put("rejected", guideService.getApplicationCountByStatus("rejected"));

            model.addAttribute("applications", applications);
            model.addAttribute("currentPage", page);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("totalApplications", totalApplications);
            model.addAttribute("size", size);
            model.addAttribute("status", status);
            model.addAttribute("search", search);
            model.addAttribute("orderBy", orderBy);
            model.addAttribute("orderDirection", orderDirection);
            model.addAttribute("statusCounts", statusCounts);

        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "가이드 신청 내역을 불러오는 중 오류가 발생했습니다.");

            // 오류 시 기본값
            model.addAttribute("applications", new ArrayList<>());
            model.addAttribute("currentPage", 1);
            model.addAttribute("totalPages", 0);
            model.addAttribute("totalApplications", 0);
            model.addAttribute("size", size);
            model.addAttribute("status", status);
            model.addAttribute("search", search);
            model.addAttribute("orderBy", orderBy);
            model.addAttribute("orderDirection", orderDirection);
            model.addAttribute("statusCounts", new HashMap<>());
        }

        return "admin/guide-history";
    }

    // 가이드 신청 승인
    @RequestMapping(value = "/guide/approve/{applicationId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> approveGuideApplication(@PathVariable int applicationId,
                                                      @RequestParam(required = false) String comment,
                                                      HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        if (!isAdmin(session)) {
            response.put("success", false);
            response.put("message", "관리자 권한이 필요합니다.");
            return response;
        }

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        try {
            int result = guideService.approveApplication(applicationId, loginUser.getUserId(), comment);

            if (result > 0) {
                response.put("success", true);
                response.put("message", "가이드 승인이 완료되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "승인 처리 중 오류가 발생했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return response;
    }

    // 가이드 신청 거절
    @RequestMapping(value = "/guide/reject/{applicationId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> rejectGuideApplication(@PathVariable int applicationId,
                                                      @RequestParam(required = false) String comment,
                                                      HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        if (!isAdmin(session)) {
            response.put("success", false);
            response.put("message", "관리자 권한이 필요합니다.");
            return response;
        }

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        try {
            int result = guideService.rejectApplication(applicationId, loginUser.getUserId(), comment);

            if (result > 0) {
                response.put("success", true);
                response.put("message", "가이드 신청이 거절되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "거절 처리 중 오류가 발생했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return response;
    }
}