package com.tour.project.controller;

import com.tour.project.dao.NoticeDAO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.NoticeDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/notice")
public class NoticeController {
    
    @Autowired
    private NoticeDAO noticeDAO;
    
    // 공지사항 목록 조회
    @GetMapping("/list")
    public String noticeList(
            @RequestParam(value = "page", defaultValue = "1") int page,
            @RequestParam(value = "size", defaultValue = "20") int size,
            @RequestParam(value = "search", required = false) String search,
            Model model) {
        
        int offset = (page - 1) * size;
        List<NoticeDTO> noticeList;
        int totalCount;
        
        if (search != null && !search.trim().isEmpty()) {
            noticeList = noticeDAO.searchNotices(search.trim(), offset, size);
            totalCount = noticeDAO.getSearchNoticeCount(search.trim());
        } else {
            noticeList = noticeDAO.getNoticeList(offset, size);
            totalCount = noticeDAO.getTotalNoticeCount();
        }
        
        int totalPages = (int) Math.ceil((double) totalCount / size);
        
        model.addAttribute("noticeList", noticeList);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("size", size);
        model.addAttribute("search", search);
        
        return "notice/list";
    }
    
    // 공지사항 상세보기
    @GetMapping("/detail/{noticeId}")
    public String noticeDetail(@PathVariable Long noticeId, Model model, HttpSession session) {
        // 조회수 증가
        noticeDAO.incrementViews(noticeId);
        
        NoticeDTO notice = noticeDAO.getNoticeDetail(noticeId);
        if (notice == null) {
            model.addAttribute("error", "존재하지 않는 공지사항입니다.");
            return "redirect:/notice/list";
        }
        
        model.addAttribute("notice", notice);
        
        // 관리자 권한 확인 (수정/삭제 버튼 표시용)
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        boolean isAdmin = loginUser != null && 
                         (loginUser.getUserId().equals("admin") || 
                          (loginUser.getUserRole() != null && loginUser.getUserRole().equals("ADMIN")));
        model.addAttribute("isAdmin", isAdmin);
        
        return "notice/detail";
    }
    
    // 공지사항 작성 페이지 (관리자만)
    @GetMapping("/create")
    public String createNoticeForm(HttpSession session, RedirectAttributes redirectAttributes) {
        // 관리자 권한 체크
        if (!isAdmin(session)) {
            redirectAttributes.addFlashAttribute("error", "관리자만 공지사항을 작성할 수 있습니다.");
            return "redirect:/notice/list";
        }
        
        return "notice/create";
    }
    
    // 공지사항 작성 처리 (관리자만)
    @PostMapping("/create")
    public String createNotice(
            @RequestParam String noticeTitle,
            @RequestParam String noticeContent,
            @RequestParam(value = "isImportant", defaultValue = "false") boolean isImportant,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        // 관리자 권한 체크
        if (!isAdmin(session)) {
            redirectAttributes.addFlashAttribute("error", "관리자만 공지사항을 작성할 수 있습니다.");
            return "redirect:/notice/list";
        }
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        NoticeDTO notice = new NoticeDTO();
        notice.setNoticeTitle(noticeTitle);
        notice.setNoticeContent(noticeContent);
        notice.setNoticeWriter(loginUser.getUserId());
        notice.setImportant(isImportant);
        
        try {
            int result = noticeDAO.insertNotice(notice);
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "공지사항이 등록되었습니다.");
            } else {
                redirectAttributes.addFlashAttribute("error", "공지사항 등록에 실패했습니다.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "공지사항 등록 중 오류가 발생했습니다.");
        }
        
        return "redirect:/notice/list";
    }
    
    // 공지사항 수정 페이지 (관리자만)
    @GetMapping("/edit/{noticeId}")
    public String editNoticeForm(@PathVariable Long noticeId, HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        // 관리자 권한 체크
        if (!isAdmin(session)) {
            redirectAttributes.addFlashAttribute("error", "관리자만 공지사항을 수정할 수 있습니다.");
            return "redirect:/notice/list";
        }
        
        NoticeDTO notice = noticeDAO.getNoticeDetail(noticeId);
        if (notice == null) {
            redirectAttributes.addFlashAttribute("error", "존재하지 않는 공지사항입니다.");
            return "redirect:/notice/list";
        }
        
        model.addAttribute("notice", notice);
        return "notice/edit";
    }
    
    // 공지사항 수정 처리 (관리자만)
    @PostMapping("/edit/{noticeId}")
    public String editNotice(
            @PathVariable Long noticeId,
            @RequestParam String noticeTitle,
            @RequestParam String noticeContent,
            @RequestParam(value = "isImportant", defaultValue = "false") boolean isImportant,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        
        // 관리자 권한 체크
        if (!isAdmin(session)) {
            redirectAttributes.addFlashAttribute("error", "관리자만 공지사항을 수정할 수 있습니다.");
            return "redirect:/notice/list";
        }
        
        NoticeDTO notice = new NoticeDTO();
        notice.setNoticeId(noticeId);
        notice.setNoticeTitle(noticeTitle);
        notice.setNoticeContent(noticeContent);
        notice.setImportant(isImportant);
        
        try {
            int result = noticeDAO.updateNotice(notice);
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "공지사항이 수정되었습니다.");
            } else {
                redirectAttributes.addFlashAttribute("error", "공지사항 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "공지사항 수정 중 오류가 발생했습니다.");
        }
        
        return "redirect:/notice/detail/" + noticeId;
    }
    
    // 공지사항 삭제 (관리자만)
    @PostMapping("/delete/{noticeId}")
    public String deleteNotice(@PathVariable Long noticeId, HttpSession session, RedirectAttributes redirectAttributes) {
        // 관리자 권한 체크
        if (!isAdmin(session)) {
            redirectAttributes.addFlashAttribute("error", "관리자만 공지사항을 삭제할 수 있습니다.");
            return "redirect:/notice/list";
        }
        
        try {
            int result = noticeDAO.deleteNotice(noticeId);
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "공지사항이 삭제되었습니다.");
            } else {
                redirectAttributes.addFlashAttribute("error", "공지사항 삭제에 실패했습니다.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "공지사항 삭제 중 오류가 발생했습니다.");
        }
        
        return "redirect:/notice/list";
    }
    
    // 관리자 권한 확인 메소드
    private boolean isAdmin(HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        return loginUser != null && 
               (loginUser.getUserId().equals("admin") || 
                (loginUser.getUserRole() != null && loginUser.getUserRole().equals("ADMIN")));
    }
}