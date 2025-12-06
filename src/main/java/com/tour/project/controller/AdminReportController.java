package com.tour.project.controller;

import com.tour.project.dao.ReportDAO;
import com.tour.project.dto.ReportDTO;
import com.tour.project.dto.MemberDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/admin/reports")
public class AdminReportController {
    
    @Autowired
    private ReportDAO reportDAO;
    
    // 관리자 권한 체크 메서드
    private boolean isAdmin(HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return false;
        }
        
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
    
    // 신고 관리 페이지
    @RequestMapping("")
    public String reportManagement(Model model, 
                                 @RequestParam(defaultValue = "1") int page,
                                 @RequestParam(defaultValue = "") String status,
                                 @RequestParam(defaultValue = "") String category,
                                 @RequestParam(defaultValue = "") String contentType,
                                 HttpSession session) {
        
        // 관리자 권한 체크
        if (!isAdmin(session)) {
            return "redirect:/member/login?returnUrl=/admin/reports";
        }
        
        int limit = 20;
        int offset = (page - 1) * limit;
        
        // 신고 목록 조회
        List<ReportDTO> reportList = reportDAO.getReportList(
            offset, limit, status, category, contentType
        );
        
        // 전체 개수 조회 (페이징용)
        int totalCount = reportDAO.getReportCount(status, category, contentType);
        int totalPages = (int) Math.ceil((double) totalCount / limit);
        
        // 통계 정보 조회
        int pendingCount = reportDAO.getPendingReportsCount();
        int totalReports = reportDAO.getTotalReportsCount();
        int todayReports = reportDAO.getTodayReportsCount();
        int weeklyReports = reportDAO.getWeeklyReportsCount();
        
        // 신고 많이 받은 사용자 목록
        List<Map<String, Object>> frequentUsers = reportDAO.getFrequentlyReportedUsers(3, 5);
        
        model.addAttribute("reportList", reportList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("status", status);
        model.addAttribute("category", category);
        model.addAttribute("contentType", contentType);
        
        // 통계 정보
        model.addAttribute("pendingCount", pendingCount);
        model.addAttribute("totalReports", totalReports);
        model.addAttribute("todayReports", todayReports);
        model.addAttribute("weeklyReports", weeklyReports);
        model.addAttribute("frequentUsers", frequentUsers);
        
        return "admin/reports";
    }
    
    // 대시보드에서 보여줄 신고 통계 (AJAX)
    @GetMapping("/stats")
    @ResponseBody
    public Map<String, Object> getReportStats(HttpSession session) {
        Map<String, Object> stats = new java.util.HashMap<>();
        
        if (!isAdmin(session)) {
            stats.put("error", "Unauthorized");
            return stats;
        }
        
        stats.put("pendingCount", reportDAO.getPendingReportsCount());
        stats.put("totalReports", reportDAO.getTotalReportsCount());
        stats.put("todayReports", reportDAO.getTodayReportsCount());
        stats.put("weeklyReports", reportDAO.getWeeklyReportsCount());
        
        // 최근 미처리 신고 5개
        List<ReportDTO> recentReports = reportDAO.getRecentPendingReports(5);
        stats.put("recentReports", recentReports);
        
        return stats;
    }
}