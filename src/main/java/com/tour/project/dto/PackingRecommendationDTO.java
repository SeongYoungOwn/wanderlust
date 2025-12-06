package com.tour.project.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class PackingRecommendationDTO {
    private String conversationId;
    private String userId;
    private String aiResponse;
    private Map<String, List<PackingItemDTO>> categorizedItems;
    private String destination;
    private String duration;
    private String season;
    private String travelPurpose;
    private LocalDateTime createdAt;
    private boolean isComplete;
    
    // 기본 생성자
    public PackingRecommendationDTO() {
        this.createdAt = LocalDateTime.now();
        this.isComplete = false;
    }
    
    // 전체 생성자
    public PackingRecommendationDTO(String conversationId, String userId, String aiResponse,
                                  Map<String, List<PackingItemDTO>> categorizedItems,
                                  String destination, String duration, String season,
                                  String travelPurpose, boolean isComplete) {
        this.conversationId = conversationId;
        this.userId = userId;
        this.aiResponse = aiResponse;
        this.categorizedItems = categorizedItems;
        this.destination = destination;
        this.duration = duration;
        this.season = season;
        this.travelPurpose = travelPurpose;
        this.createdAt = LocalDateTime.now();
        this.isComplete = isComplete;
    }
    
    // Getters and Setters
    public String getConversationId() { return conversationId; }
    public void setConversationId(String conversationId) { this.conversationId = conversationId; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getAiResponse() { return aiResponse; }
    public void setAiResponse(String aiResponse) { this.aiResponse = aiResponse; }
    
    public Map<String, List<PackingItemDTO>> getCategorizedItems() { return categorizedItems; }
    public void setCategorizedItems(Map<String, List<PackingItemDTO>> categorizedItems) { this.categorizedItems = categorizedItems; }
    
    public String getDestination() { return destination; }
    public void setDestination(String destination) { this.destination = destination; }
    
    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }
    
    public String getSeason() { return season; }
    public void setSeason(String season) { this.season = season; }
    
    public String getTravelPurpose() { return travelPurpose; }
    public void setTravelPurpose(String travelPurpose) { this.travelPurpose = travelPurpose; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public boolean isComplete() { return isComplete; }
    public void setComplete(boolean complete) { isComplete = complete; }
    
    // 패킹 아이템 내부 클래스
    public static class PackingItemDTO {
        private String itemName;
        private String category;
        private String necessityLevel; // 필수, 권장, 선택
        private String description;
        private boolean isChecked;
        
        public PackingItemDTO() {}
        
        public PackingItemDTO(String itemName, String category, String necessityLevel, String description) {
            this.itemName = itemName;
            this.category = category;
            this.necessityLevel = necessityLevel;
            this.description = description;
            this.isChecked = false;
        }
        
        // Getters and Setters
        public String getItemName() { return itemName; }
        public void setItemName(String itemName) { this.itemName = itemName; }
        
        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }
        
        public String getNecessityLevel() { return necessityLevel; }
        public void setNecessityLevel(String necessityLevel) { this.necessityLevel = necessityLevel; }
        
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        
        public boolean isChecked() { return isChecked; }
        public void setChecked(boolean checked) { isChecked = checked; }
    }
}