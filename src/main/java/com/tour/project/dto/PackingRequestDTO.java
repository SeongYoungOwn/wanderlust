package com.tour.project.dto;

import java.util.List;

public class PackingRequestDTO {
    private String userId;
    private String destination;
    private String duration;
    private String season;
    private String travelPurpose;
    private List<String> activities;
    private String transportMethod;
    private String accommodationType;
    private String companionType;
    private String packingStyle; // 미니멀, 여유있게, 만반의 준비
    private String specialRequirements;
    private String userMessage; // 자유 형식 메시지
    
    // 기본 생성자
    public PackingRequestDTO() {}
    
    // 전체 생성자
    public PackingRequestDTO(String userId, String destination, String duration, String season, 
                           String travelPurpose, List<String> activities, String transportMethod,
                           String accommodationType, String companionType, String packingStyle,
                           String specialRequirements, String userMessage) {
        this.userId = userId;
        this.destination = destination;
        this.duration = duration;
        this.season = season;
        this.travelPurpose = travelPurpose;
        this.activities = activities;
        this.transportMethod = transportMethod;
        this.accommodationType = accommodationType;
        this.companionType = companionType;
        this.packingStyle = packingStyle;
        this.specialRequirements = specialRequirements;
        this.userMessage = userMessage;
    }
    
    // Claude API를 위한 프롬프트 생성
    public String buildPrompt() {
        StringBuilder prompt = new StringBuilder();
        
        if (userMessage != null && !userMessage.trim().isEmpty()) {
            prompt.append(userMessage).append("\n\n");
        }
        
        prompt.append("다음 여행 정보를 바탕으로 완벽한 패킹 리스트를 작성해주세요:\n\n");
        
        if (destination != null) prompt.append("목적지: ").append(destination).append("\n");
        if (duration != null) prompt.append("기간: ").append(duration).append("\n");
        if (season != null) prompt.append("계절: ").append(season).append("\n");
        if (travelPurpose != null) prompt.append("여행 목적: ").append(travelPurpose).append("\n");
        if (activities != null && !activities.isEmpty()) {
            prompt.append("주요 활동: ").append(String.join(", ", activities)).append("\n");
        }
        if (transportMethod != null) prompt.append("교통수단: ").append(transportMethod).append("\n");
        if (accommodationType != null) prompt.append("숙박 타입: ").append(accommodationType).append("\n");
        if (companionType != null) prompt.append("동행자: ").append(companionType).append("\n");
        if (packingStyle != null) prompt.append("패킹 스타일: ").append(packingStyle).append("\n");
        if (specialRequirements != null) prompt.append("특별 요구사항: ").append(specialRequirements).append("\n");
        
        prompt.append("\n각 카테고리별로 정리하고, 각 아이템의 필요도(필수/권장/선택)를 표시해주세요.");
        prompt.append("\n응답은 다음 카테고리로 구분해주세요: 의류, 세면용품, 전자기기, 여행용품, 액티비티 용품, 기타");
        
        return prompt.toString();
    }
    
    // Getters and Setters
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }
    
    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }
    
    public String getSeason() { return season; }
    public void setSeason(String season) { this.season = season; }
    
    public String getTravelPurpose() { return travelPurpose; }
    public void setTravelPurpose(String travelPurpose) { this.travelPurpose = travelPurpose; }
    
    public List<String> getActivities() { return activities; }
    public void setActivities(List<String> activities) { this.activities = activities; }
    
    public String getTransportMethod() { return transportMethod; }
    public void setTransportMethod(String transportMethod) { this.transportMethod = transportMethod; }
    
    public String getAccommodationType() { return accommodationType; }
    public void setAccommodationType(String accommodationType) { this.accommodationType = accommodationType; }
    
    public String getCompanionType() { return companionType; }
    public void setCompanionType(String companionType) { this.companionType = companionType; }
    
    public String getPackingStyle() { return packingStyle; }
    public void setPackingStyle(String packingStyle) { this.packingStyle = packingStyle; }
    
    public String getSpecialRequirements() { return specialRequirements; }
    public void setSpecialRequirements(String specialRequirements) { this.specialRequirements = specialRequirements; }
    
    public String getUserMessage() { return userMessage; }
    public void setUserMessage(String userMessage) { this.userMessage = userMessage; }
}