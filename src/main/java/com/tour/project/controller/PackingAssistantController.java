package com.tour.project.controller;

import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.PackingRequestDTO;
import com.tour.project.dto.PackingRecommendationDTO;
import com.tour.project.service.PackingRecommendationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/api/packing")
public class PackingAssistantController {

    @Autowired
    private PackingRecommendationService packingService;

    /**
     * AI 패킹 추천 요청 처리
     */
    @PostMapping("/recommend")
    @ResponseBody
    public Map<String, Object> getPackingRecommendation(@RequestBody PackingRequestDTO request, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            String userId = loginUser != null ? loginUser.getUserId() : null;
            
            // 사용자 ID 설정 (로그인 시에만)
            if (userId != null) {
                request.setUserId(userId);
            }
            
            // AI 패킹 추천 생성
            PackingRecommendationDTO recommendation = packingService.generatePackingRecommendation(request);
            
            response.put("success", true);
            response.put("recommendation", recommendation);
            response.put("conversationId", recommendation.getConversationId());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "패킹 추천 생성 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * 실시간 AI 대화 처리
     */
    @PostMapping("/chat")
    @ResponseBody
    public Map<String, Object> chatWithAI(@RequestBody Map<String, String> chatRequest, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            String userId = loginUser != null ? loginUser.getUserId() : null;
            
            String userMessage = chatRequest.get("message");
            String conversationId = chatRequest.get("conversationId");
            
            // AI와 대화하여 응답 생성
            Map<String, Object> chatResponse = packingService.chatWithAI(userMessage, conversationId, userId);
            
            response.put("success", true);
            response.put("aiMessage", chatResponse.get("aiMessage"));
            response.put("conversationComplete", chatResponse.get("conversationComplete"));
            response.put("packingList", chatResponse.get("packingList"));
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "AI 대화 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * 체크리스트 상태 업데이트
     */
    @PutMapping("/checklist")
    @ResponseBody
    public Map<String, Object> updateChecklist(@RequestBody Map<String, Object> updateRequest, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            
            String conversationId = (String) updateRequest.get("conversationId");
            String itemName = (String) updateRequest.get("itemName");
            boolean isChecked = (Boolean) updateRequest.get("isChecked");
            
            // 체크리스트 상태 업데이트
            packingService.updateChecklistItem(conversationId, loginUser.getUserId(), itemName, isChecked);
            
            response.put("success", true);
            response.put("message", "체크리스트가 업데이트되었습니다.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "체크리스트 업데이트 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * 체크리스트 조회
     */
    @GetMapping("/checklist/{conversationId}")
    @ResponseBody
    public Map<String, Object> getChecklist(@PathVariable String conversationId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            String userId = loginUser != null ? loginUser.getUserId() : null;
            
            // 체크리스트 조회
            List<Map<String, Object>> checklist = packingService.getChecklist(conversationId, userId);
            
            response.put("success", true);
            response.put("checklist", checklist);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "체크리스트 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * PDF 내보내기
     */
    @GetMapping("/export/{conversationId}")
    @ResponseBody
    public Map<String, Object> exportToPDF(@PathVariable String conversationId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            String userId = loginUser != null ? loginUser.getUserId() : null;
            
            // PDF 생성 및 다운로드 URL 반환
            String downloadUrl = packingService.generatePDF(conversationId, userId);
            
            response.put("success", true);
            response.put("downloadUrl", downloadUrl);
            response.put("message", "PDF가 생성되었습니다.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "PDF 생성 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }

    /**
     * 대화 기록 초기화
     */
    @DeleteMapping("/conversation/{conversationId}")
    @ResponseBody
    public Map<String, Object> clearConversation(@PathVariable String conversationId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            String userId = loginUser != null ? loginUser.getUserId() : null;
            
            // 대화 기록 삭제
            packingService.clearConversation(conversationId, userId);
            
            response.put("success", true);
            response.put("message", "대화 기록이 삭제되었습니다.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "대화 기록 삭제 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
}