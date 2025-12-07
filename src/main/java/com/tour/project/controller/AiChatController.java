package com.tour.project.controller;

import com.tour.project.dto.AiChatRequestDTO;
import com.tour.project.dto.AiChatResponseDTO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.TravelPlanDTO;
import com.tour.project.service.AiChatService;
import com.tour.project.service.TravelMatchingService;
import com.tour.project.service.AdvancedTravelMatchingService;
import com.tour.project.service.RecommendationFeedbackProcessor;
import com.tour.project.util.AuthUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Controller
@RequestMapping("/ai")
public class AiChatController {
    
    @Autowired
    private AiChatService aiChatService;
    
    @Autowired
    private TravelMatchingService travelMatchingService;
    
    @Autowired
    private AdvancedTravelMatchingService advancedMatchingService;
    
    @Autowired
    private RecommendationFeedbackProcessor feedbackProcessor;
    
    // AI 채팅 페이지 표시
    @GetMapping("/chat")
    public String showChatPage(Model model, HttpSession session) {
        // 로그인 검사 (옵션으로 변경)
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        // 세션에서 채팅 기록 가져오기
        List<ChatMessage> chatHistory = (List<ChatMessage>) session.getAttribute("chatHistory");
        if (chatHistory == null) {
            chatHistory = new ArrayList<>();
            session.setAttribute("chatHistory", chatHistory);
        }
        
        model.addAttribute("chatHistory", chatHistory);
        model.addAttribute("loginUser", loginUser);
        model.addAttribute("isLoggedIn", loginUser != null);
        return "ai/chat";
    }
    
    // AI 채팅 요청 처리 (여행계획 생성 + MBTI 매칭)
    @PostMapping("/generate-plan")
    @ResponseBody
    public AiChatResponseDTO generateTravelPlan(@RequestBody AiChatRequestDTO request, HttpSession session) {
        // 로그인 사용자 정보 가져오기 (옵션)
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        // 사용자 메시지를 채팅 기록에 추가
        List<ChatMessage> chatHistory = (List<ChatMessage>) session.getAttribute("chatHistory");
        if (chatHistory == null) {
            chatHistory = new ArrayList<>();
        }
        
        // 사용자 메시지 저장
        String userMessage = request.getUserMessage() != null ? request.getUserMessage() : request.buildPrompt();
        ChatMessage userChatMessage = new ChatMessage("user", userMessage);
        chatHistory.add(userChatMessage);
        
        // 여행 매칭 요청인지 확인
        AiChatResponseDTO response;
        if (isMatchingRequest(userMessage) && loginUser != null) {
            // 매칭 서비스는 로그인이 필요
            response = travelMatchingService.findTravelMatches(loginUser, userMessage);
        } else if (isMatchingRequest(userMessage) && loginUser == null) {
            // 로그인 없이 매칭 요청 시
            response = new AiChatResponseDTO();
            response.setSuccess(false);
            response.setMessage("여행 매칭 서비스는 로그인이 필요합니다. 일반 여행 계획 생성은 로그인 없이도 이용 가능합니다.");
        } else {
            // 일반 여행 계획 생성 (로그인 불필요)
            response = aiChatService.generateTravelPlan(request);
        }
        
        // AI 응답을 채팅 기록에 추가
        if (response.isSuccess()) {
            ChatMessage aiMessage = new ChatMessage("ai", response.getMessage());
            chatHistory.add(aiMessage);
        }
        
        session.setAttribute("chatHistory", chatHistory);
        
        return response;
    }
    
    // 여행 매칭 요청인지 판단하는 헬퍼 메서드
    private boolean isMatchingRequest(String message) {
        if (message == null) return false;
        
        String lowerMessage = message.toLowerCase();
        return lowerMessage.contains("매칭") || 
               lowerMessage.contains("파트너") || 
               lowerMessage.contains("동행") ||
               lowerMessage.contains("같이") ||
               lowerMessage.contains("함께") ||
               lowerMessage.contains("찾아줘") ||
               (lowerMessage.contains("여행") && (lowerMessage.contains("추천") || lowerMessage.contains("찾아")));
    }
    
    // 채팅 기록 초기화
    @PostMapping("/clear")
    @ResponseBody
    public String clearChatHistory(HttpSession session) {
        // 로그인 검증 제거 (누구나 사용 가능)
        session.removeAttribute("chatHistory");
        return "success";
    }
    
    // 고도화된 AI 추천 엔드포인트
    @PostMapping("/advanced-recommendations")
    @ResponseBody
    public Map<String, Object> getAdvancedRecommendations(@RequestBody Map<String, String> request, HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        Map<String, Object> response = new HashMap<>();
        
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요한 서비스입니다.");
            return response;
        }
        
        try {
            String userMessage = request.get("message");
            Long userId = Long.parseLong(loginUser.getUserId());
            
            // 고도화된 추천 시스템 사용
            List<TravelPlanDTO> recommendations = advancedMatchingService.getPersonalizedRecommendations(
                userMessage, userId, 10
            );
            
            response.put("success", true);
            response.put("recommendations", recommendations);
            response.put("count", recommendations.size());
            response.put("algorithm", "advanced_multi_layer");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "추천 생성 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // 추천 피드백 처리 엔드포인트
    @PostMapping("/feedback")
    @ResponseBody
    public Map<String, Object> processFeedback(@RequestBody Map<String, Object> feedbackData, HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        Map<String, Object> response = new HashMap<>();
        
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요한 서비스입니다.");
            return response;
        }
        
        try {
            Long userId = Long.parseLong(loginUser.getUserId());
            Long planId = Long.parseLong(feedbackData.get("planId").toString());
            String interaction = (String) feedbackData.get("interaction");
            Integer satisfaction = feedbackData.get("satisfaction") != null ? 
                Integer.parseInt(feedbackData.get("satisfaction").toString()) : null;
            Boolean participated = feedbackData.get("participated") != null ?
                Boolean.parseBoolean(feedbackData.get("participated").toString()) : null;
            
            // 비동기로 피드백 처리
            feedbackProcessor.processFeedback(userId, planId, interaction, satisfaction, participated);
            
            response.put("success", true);
            response.put("message", "피드백이 성공적으로 처리되었습니다.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "피드백 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // 추천 클릭 추적
    @PostMapping("/track-click")
    @ResponseBody
    public Map<String, Object> trackClick(@RequestBody Map<String, Object> clickData, HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        Map<String, Object> response = new HashMap<>();
        
        if (loginUser == null) {
            response.put("success", false);
            return response;
        }
        
        try {
            Long userId = Long.parseLong(loginUser.getUserId());
            Long planId = Long.parseLong(clickData.get("planId").toString());
            
            feedbackProcessor.processFeedback(userId, planId, "CLICK", null, null);
            
            response.put("success", true);
        } catch (Exception e) {
            response.put("success", false);
        }
        
        return response;
    }
    
    // 추천 조회 추적
    @PostMapping("/track-view")
    @ResponseBody
    public Map<String, Object> trackView(@RequestBody Map<String, Object> viewData, HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        Map<String, Object> response = new HashMap<>();
        
        if (loginUser == null) {
            response.put("success", false);
            return response;
        }
        
        try {
            Long userId = Long.parseLong(loginUser.getUserId());
            Long planId = Long.parseLong(viewData.get("planId").toString());
            
            feedbackProcessor.processFeedback(userId, planId, "VIEW", null, null);
            
            response.put("success", true);
        } catch (Exception e) {
            response.put("success", false);
        }
        
        return response;
    }
    
    // 내부 클래스: 채팅 메시지
    public static class ChatMessage {
        private String role;
        private String content;
        private String timestamp;
        
        public ChatMessage(String role, String content) {
            this.role = role;
            this.content = content;
            this.timestamp = new java.util.Date().toString();
        }
        
        // Getters
        public String getRole() { return role; }
        public String getContent() { return content; }
        public String getTimestamp() { return timestamp; }
    }
}