package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.tour.project.dao.BoardDAO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.BoardDTO;
import com.tour.project.util.AuthUtil;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/like")
public class LikeController {
    
    @Autowired
    private BoardDAO boardDAO;
    
    @RequestMapping(value = "/toggle", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> toggleLike(@RequestParam int boardId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        // 권한 체크: 로그인 + 활성 계정만 가능
        if (!AuthUtil.canLike(session)) {
            result.put("success", false);
            result.put("message", AuthUtil.getAuthMessage(session));
            return result;
        }
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        try {
            String userId = loginUser.getUserId();
            boolean isLiked = boardDAO.isUserLiked(boardId, userId);
            boolean isDisliked = boardDAO.isUserDisliked(boardId, userId);
            
            if (isLiked) {
                // 좋아요 해제
                boardDAO.removeLike(boardId, userId);
                result.put("action", "removed");
            } else {
                // 싫어요가 있다면 먼저 해제
                if (isDisliked) {
                    boardDAO.removeDislike(boardId, userId);
                    boardDAO.updateDislikeCount(boardId);
                }
                // 좋아요 추가
                boardDAO.addLike(boardId, userId);
                result.put("action", "added");
            }
            
            // 좋아요 수 업데이트
            boardDAO.updateLikeCount(boardId);
            
            // 업데이트된 좋아요/싫어요 수 조회
            BoardDTO board = boardDAO.getBoard(boardId);
            int likeCount = board.getBoardLikes();
            int dislikeCount = board.getBoardDislikes();
            
            result.put("success", true);
            result.put("likeCount", likeCount);
            result.put("dislikeCount", dislikeCount);
            result.put("isLiked", !isLiked);
            result.put("isDisliked", false);
            
        } catch (Exception e) {
            System.out.println("좋아요 처리 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "좋아요 처리 중 오류가 발생했습니다.");
        }
        
        return result;
    }
    
    @RequestMapping(value = "/dislike/toggle", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> toggleDislike(@RequestParam int boardId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        // 권한 체크: 로그인 + 활성 계정만 가능
        if (!AuthUtil.canLike(session)) {
            result.put("success", false);
            result.put("message", AuthUtil.getAuthMessage(session));
            return result;
        }
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        try {
            String userId = loginUser.getUserId();
            boolean isDisliked = boardDAO.isUserDisliked(boardId, userId);
            boolean isLiked = boardDAO.isUserLiked(boardId, userId);
            
            if (isDisliked) {
                // 싫어요 해제
                boardDAO.removeDislike(boardId, userId);
                result.put("action", "removed");
            } else {
                // 좋아요가 있다면 먼저 해제
                if (isLiked) {
                    boardDAO.removeLike(boardId, userId);
                    boardDAO.updateLikeCount(boardId);
                }
                // 싫어요 추가
                boardDAO.addDislike(boardId, userId);
                result.put("action", "added");
            }
            
            // 싫어요 수 업데이트
            boardDAO.updateDislikeCount(boardId);
            
            // 업데이트된 좋아요/싫어요 수 조회
            BoardDTO board = boardDAO.getBoard(boardId);
            int likeCount = board.getBoardLikes();
            int dislikeCount = board.getBoardDislikes();
            
            result.put("success", true);
            result.put("likeCount", likeCount);
            result.put("dislikeCount", dislikeCount);
            result.put("isLiked", false);
            result.put("isDisliked", !isDisliked);
            
        } catch (Exception e) {
            System.out.println("싫어요 처리 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "싫어요 처리 중 오류가 발생했습니다.");
        }
        
        return result;
    }
    
    @RequestMapping(value = "/status", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> getLikeStatus(@RequestParam int boardId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        try {
            boolean isLiked = false;
            boolean isDisliked = false;
            
            if (loginUser != null) {
                isLiked = boardDAO.isUserLiked(boardId, loginUser.getUserId());
                isDisliked = boardDAO.isUserDisliked(boardId, loginUser.getUserId());
            }
            
            BoardDTO board = boardDAO.getBoard(boardId);
            int likeCount = board.getBoardLikes();
            int dislikeCount = board.getBoardDislikes();
            
            result.put("success", true);
            result.put("isLiked", isLiked);
            result.put("isDisliked", isDisliked);
            result.put("likeCount", likeCount);
            result.put("dislikeCount", dislikeCount);
            
        } catch (Exception e) {
            System.out.println("좋아요/싫어요 상태 조회 오류: " + e.getMessage());
            result.put("success", false);
            result.put("message", "좋아요/싫어요 상태 조회 중 오류가 발생했습니다.");
        }
        
        return result;
    }
}