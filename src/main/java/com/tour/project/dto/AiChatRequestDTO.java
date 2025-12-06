package com.tour.project.dto;

public class AiChatRequestDTO {
    private String destination;      // 여행지
    private String duration;         // 여행 기간
    private String interests;        // 관심사
    private String companionType;    // 동행 유형 (혼자, 친구, 가족 등)
    private String userMessage;      // 사용자의 직접 입력 메시지
    
    // 기본 생성자
    public AiChatRequestDTO() {}
    
    // Getters and Setters
    public String getDestination() {
        return destination;
    }
    
    public void setDestination(String destination) {
        this.destination = destination;
    }
    
    public String getDuration() {
        return duration;
    }
    
    public void setDuration(String duration) {
        this.duration = duration;
    }
    
    public String getInterests() {
        return interests;
    }
    
    public void setInterests(String interests) {
        this.interests = interests;
    }
    
    public String getCompanionType() {
        return companionType;
    }
    
    public void setCompanionType(String companionType) {
        this.companionType = companionType;
    }
    
    public String getUserMessage() {
        return userMessage;
    }
    
    public void setUserMessage(String userMessage) {
        this.userMessage = userMessage;
    }
    
    // 프롬프트 생성 메서드
    public String buildPrompt() {
        if (userMessage != null && !userMessage.trim().isEmpty()) {
            return userMessage;
        }
        
        StringBuilder prompt = new StringBuilder();
        prompt.append(destination).append("로 ");
        prompt.append(duration).append(" 동안 ");
        prompt.append(companionType).append(" 여행을 갑니다. ");
        prompt.append("주요 관심사는 ").append(interests).append("입니다. ");
        prompt.append("젊은 사람들이 좋아할 만한 곳 위주로 일정을 짜주세요.");
        
        return prompt.toString();
    }
}