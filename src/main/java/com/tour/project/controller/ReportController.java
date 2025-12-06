package com.tour.project.controller;

import com.tour.project.dao.ReportDAO;
import com.tour.project.dto.ReportDTO;
import com.tour.project.dto.MemberDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/reports")
public class ReportController {
    
    @Autowired
    private ReportDAO reportDAO;
    
    // 신고하기
    @PostMapping("/submit")
    @ResponseBody
    public Map<String, Object> submitReport(@RequestBody ReportDTO report, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            // 자기 자신의 게시물 신고 방지
            if (loginUser.getUserId().equals(report.getReportedUserId())) {
                response.put("success", false);
                response.put("message", "자신의 게시물은 신고할 수 없습니다.");
                return response;
            }
            
            // 중복 신고 확인
            int duplicateCount = reportDAO.checkDuplicateReport(
                loginUser.getUserId(), 
                report.getReportedContentType(), 
                report.getReportedContentId()
            );
            
            if (duplicateCount > 0) {
                response.put("success", false);
                response.put("message", "이미 신고한 게시글입니다.");
                return response;
            }
            
            // 신고 내용 유효성 검사
            if (report.getReportContent() == null || report.getReportContent().trim().length() < 10) {
                response.put("success", false);
                response.put("message", "신고 내용을 10자 이상 작성해주세요.");
                return response;
            }
            
            if (report.getReportContent().length() > 1000) {
                response.put("success", false);
                response.put("message", "신고 내용은 1000자 이내로 작성해주세요.");
                return response;
            }
            
            report.setReporterId(loginUser.getUserId());
            
            int result = reportDAO.insertReport(report);
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "신고가 접수되었습니다. 관리자가 검토 후 처리하겠습니다.");
            } else {
                response.put("success", false);
                response.put("message", "신고 접수에 실패했습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "시스템 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // 신고 상세 조회 (관리자용)
    @GetMapping("/{reportId}")
    @ResponseBody
    public Map<String, Object> getReportDetail(@PathVariable int reportId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return response;
            }
            
            ReportDTO report = reportDAO.getReportDetail(reportId);
            
            if (report != null) {
                response.put("success", true);
                response.put("report", report);
            } else {
                response.put("success", false);
                response.put("message", "신고 정보를 찾을 수 없습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "시스템 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    // 신고 처리 (관리자용)
    @PostMapping("/{reportId}/process")
    @ResponseBody
    public Map<String, Object> processReport(@PathVariable int reportId,
                                           @RequestParam String status,
                                           @RequestParam(required = false) String adminComment,
                                           HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO admin = (MemberDTO) session.getAttribute("loginUser");
            if (admin == null || !"ADMIN".equals(admin.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return response;
            }
            
            // 유효한 상태값 확인
            if (!status.equals("APPROVED") && !status.equals("REJECTED") && !status.equals("RESOLVED")) {
                response.put("success", false);
                response.put("message", "유효하지 않은 상태값입니다.");
                return response;
            }
            
            int result = reportDAO.processReport(reportId, status, adminComment, admin.getUserId());
            
            if (result > 0) {
                response.put("success", true);
                response.put("message", "신고가 처리되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "처리에 실패했습니다.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "시스템 오류가 발생했습니다.");
        }
        
        return response;
    }
}