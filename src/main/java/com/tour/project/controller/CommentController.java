package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tour.project.dao.CommentDAO;
import com.tour.project.dto.CommentDTO;
import com.tour.project.dto.MemberDTO;

import javax.servlet.http.HttpSession;

@Controller
@RequestMapping("/comment")
public class CommentController {
    
    @Autowired
    private CommentDAO commentDAO;
    
    
    // 댓글 작성
    @RequestMapping(value = "/create", method = RequestMethod.POST)
    public String create(@RequestParam int boardId,
                        @RequestParam String commentContent,
                        HttpSession session,
                        RedirectAttributes redirectAttributes) {
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        if (commentContent == null || commentContent.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "댓글 내용을 입력해주세요.");
            return "redirect:/board/detail/" + boardId;
        }
        
        try {
            CommentDTO comment = new CommentDTO();
            comment.setBoardId(boardId);
            comment.setCommentContent(commentContent.trim());
            comment.setCommentWriter(loginUser.getUserId());
            
            System.out.println("=== 댓글 등록 시도 ===");
            System.out.println("게시글 ID: " + boardId);
            System.out.println("댓글 내용: " + commentContent.trim());
            System.out.println("작성자: " + loginUser.getUserId());
            
            int result = commentDAO.insertComment(comment);
            System.out.println("댓글 등록 결과: " + result);
            
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "댓글이 등록되었습니다.");
            } else {
                redirectAttributes.addFlashAttribute("error", "댓글 등록에 실패했습니다.");
            }
        } catch (Exception e) {
            System.out.println("댓글 등록 오류: " + e.getMessage());
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "댓글 등록 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return "redirect:/board/detail/" + boardId;
    }
    
    // 댓글 수정
    @RequestMapping(value = "/edit/{commentId}", method = RequestMethod.POST)
    public String edit(@PathVariable int commentId,
                      @RequestParam int boardId,
                      @RequestParam String commentContent,
                      HttpSession session,
                      RedirectAttributes redirectAttributes) {
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        if (commentContent == null || commentContent.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "댓글 내용을 입력해주세요.");
            return "redirect:/board/detail/" + boardId;
        }
        
        try {
            // 기존 댓글 확인
            CommentDTO existingComment = commentDAO.getComment(commentId);
            
            if (existingComment == null) {
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 댓글입니다.");
                return "redirect:/board/detail/" + boardId;
            }
            
            // 작성자 확인
            if (!existingComment.getCommentWriter().equals(loginUser.getUserId())) {
                redirectAttributes.addFlashAttribute("error", "수정 권한이 없습니다.");
                return "redirect:/board/detail/" + boardId;
            }
            
            CommentDTO comment = new CommentDTO();
            comment.setCommentId(commentId);
            comment.setCommentContent(commentContent.trim());
            
            int result = commentDAO.updateComment(comment);
            
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "댓글이 수정되었습니다.");
            } else {
                redirectAttributes.addFlashAttribute("error", "댓글 수정에 실패했습니다.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "댓글 수정 중 오류가 발생했습니다.");
        }
        
        return "redirect:/board/detail/" + boardId;
    }
    
    // 댓글 삭제
    @RequestMapping(value = "/delete/{commentId}", method = RequestMethod.POST)
    public String delete(@PathVariable int commentId,
                        @RequestParam int boardId,
                        HttpSession session,
                        RedirectAttributes redirectAttributes) {
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            CommentDTO comment = commentDAO.getComment(commentId);
            
            if (comment == null) {
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 댓글입니다.");
                return "redirect:/board/detail/" + boardId;
            }
            
            // 작성자 확인
            if (!comment.getCommentWriter().equals(loginUser.getUserId())) {
                redirectAttributes.addFlashAttribute("error", "삭제 권한이 없습니다.");
                return "redirect:/board/detail/" + boardId;
            }
            
            int result = commentDAO.deleteComment(commentId);
            
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "댓글이 삭제되었습니다.");
            } else {
                redirectAttributes.addFlashAttribute("error", "댓글 삭제에 실패했습니다.");
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "댓글 삭제 중 오류가 발생했습니다.");
        }
        
        return "redirect:/board/detail/" + boardId;
    }
}