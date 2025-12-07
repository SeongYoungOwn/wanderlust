package com.tour.project.dto;

import java.util.Date;

public class AiChatResponseDTO {
    private String message;      // AI 응답 메시지
    private Date timestamp;      // 응답 시간
    private boolean success;     // 성공 여부
    private String error;        // 에러 메시지
    
    // 기본 생성자
    public AiChatResponseDTO() {
        this.timestamp = new Date();
        this.success = true;
    }
    
    // 성공 응답 생성자
    public AiChatResponseDTO(String message) {
        this.message = message;
        this.timestamp = new Date();
        this.success = true;
    }
    
    // 에러 응답 생성자
    public AiChatResponseDTO(String error, boolean isError) {
        this.error = error;
        this.timestamp = new Date();
        this.success = false;
    }
    
    // Getters and Setters
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public Date getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }
    
    public boolean isSuccess() {
        return success;
    }
    
    public void setSuccess(boolean success) {
        this.success = success;
    }
    
    public String getError() {
        return error;
    }
    
    public void setError(String error) {
        this.error = error;
    }
}