package com.tour.project.controller;

import javax.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.NoHandlerFoundException;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalErrorController {
    
    @ExceptionHandler(NoHandlerFoundException.class)
    public Object handleNotFound(NoHandlerFoundException ex, HttpServletRequest request, Model model) {
        String requestURI = request.getRequestURI();
        
        // API 요청인 경우 JSON 에러 응답 반환
        if (requestURI.startsWith("/api/") || requestURI.startsWith("/ai-travel/")) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Endpoint not found: " + requestURI);
            errorResponse.put("status", 404);
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponse);
        }
        
        // 지도 페이지 요청인 경우 로그만 출력하고 에러를 다시 던짐
        if (requestURI.startsWith("/map/")) {
            System.err.println("Map URL not found: " + requestURI);
            ex.printStackTrace();
            // 에러를 다시 던져서 다른 핸들러가 처리할 수 있도록 함
            throw new RuntimeException("Map page not found: " + requestURI, ex);
        }
        
        // 쪽지 관련 URL이면 쪽지 함으로 리다이렉트
        if (requestURI.startsWith("/message/")) {
            return "redirect:/message/inbox";
        }
        
        // 프로필 관련 URL 에러 로깅
        if (requestURI.startsWith("/member/profile/")) {
            System.err.println("Profile URL not found: " + requestURI);
            ex.printStackTrace();
        }
        
        // 기타 404 에러는 홈으로 리다이렉트
        return "redirect:/home";
    }
    
    @ExceptionHandler(Exception.class)
    public Object handleGenericError(Exception ex, HttpServletRequest request, Model model) {
        String requestURI = request.getRequestURI();
        
        // API 요청인 경우 JSON 에러 응답 반환
        if (requestURI.startsWith("/api/") || requestURI.startsWith("/ai-travel/")) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", "Internal server error: " + ex.getMessage());
            errorResponse.put("status", 500);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
        
        // 프로필 관련 에러 로깅
        if (requestURI.startsWith("/member/profile/")) {
            System.err.println("Profile error for URL: " + requestURI);
            System.err.println("Error: " + ex.getMessage());
            ex.printStackTrace();
        }
        
        // 지도 페이지 관련 에러 로깅
        if (requestURI.startsWith("/map/")) {
            System.err.println("Map page error for URL: " + requestURI);
            System.err.println("Error: " + ex.getMessage());
            ex.printStackTrace();
        }
        
        // 일반적인 에러도 홈으로 리다이렉트
        return "redirect:/home";
    }
}