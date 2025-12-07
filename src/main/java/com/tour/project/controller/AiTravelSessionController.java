package com.tour.project.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * AI 여행 계획 세션 관리 컨트롤러
 */
@RestController
@RequestMapping("/ai-travel")
public class AiTravelSessionController {
    
    /**
     * AI 추천 데이터를 세션에 저장
     */
    @PostMapping("/save-session")
    public ResponseEntity<Map<String, Object>> saveAiRecommendationToSession(
            @RequestBody Map<String, Object> aiRecommendation, 
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 세션에 AI 추천 데이터 저장
            session.setAttribute("aiRecommendation", aiRecommendation);
            
            System.out.println("=== AI 추천 데이터 세션 저장 ===");
            System.out.println("Region: " + aiRecommendation.get("region"));
            System.out.println("Period: " + aiRecommendation.get("period"));
            System.out.println("Count: " + aiRecommendation.get("count"));
            System.out.println("Content: " + aiRecommendation.get("content"));
            
            response.put("success", true);
            response.put("message", "AI 추천 데이터가 세션에 저장되었습니다.");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("AI 추천 데이터 세션 저장 오류: " + e.getMessage());
            e.printStackTrace();
            
            response.put("success", false);
            response.put("error", "세션 저장 중 오류가 발생했습니다.");
            
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 세션에서 AI 추천 데이터 조회
     */
    @GetMapping("/get-session")
    public ResponseEntity<Map<String, Object>> getAiRecommendationFromSession(HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> aiRecommendation = (Map<String, Object>) session.getAttribute("aiRecommendation");
            
            if (aiRecommendation != null) {
                response.put("success", true);
                response.put("data", aiRecommendation);
                
                System.out.println("=== AI 추천 데이터 세션 조회 ===");
                System.out.println("Data found: " + aiRecommendation);
            } else {
                response.put("success", false);
                response.put("message", "세션에 AI 추천 데이터가 없습니다.");
            }
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("AI 추천 데이터 세션 조회 오류: " + e.getMessage());
            e.printStackTrace();
            
            response.put("success", false);
            response.put("error", "세션 조회 중 오류가 발생했습니다.");
            
            return ResponseEntity.status(500).body(response);
        }
    }
    
    /**
     * 세션에서 AI 추천 데이터 삭제
     */
    @DeleteMapping("/clear-session")
    public ResponseEntity<Map<String, Object>> clearAiRecommendationFromSession(HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            session.removeAttribute("aiRecommendation");
            
            response.put("success", true);
            response.put("message", "AI 추천 데이터가 세션에서 삭제되었습니다.");
            
            System.out.println("=== AI 추천 데이터 세션 삭제 완료 ===");
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("AI 추천 데이터 세션 삭제 오류: " + e.getMessage());
            e.printStackTrace();
            
            response.put("success", false);
            response.put("error", "세션 삭제 중 오류가 발생했습니다.");
            
            return ResponseEntity.status(500).body(response);
        }
    }
}