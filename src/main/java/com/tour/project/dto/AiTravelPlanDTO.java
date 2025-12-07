package com.tour.project.dto;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

/**
 * AI Travel Plan DTO for storing AI-generated travel plans
 * Separate from existing TravelPlanDTO, dedicated for AI-generated plan storage
 */
public class AiTravelPlanDTO {
    private Long planId;
    private String userId;
    private String title;
    private String destination;
    private Date startDate;
    private Date endDate;
    private Integer duration;
    private BigDecimal budget;
    private Integer maxParticipants;
    private String travelStyle;
    private String planContent; // JSON format
    private String chatSessionId; // Track which chat generated this plan
    private String memo;
    private Boolean isTemplate;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String status; // draft, completed, archived
    private List<String> tags;
    
    public AiTravelPlanDTO() {}
    
    public AiTravelPlanDTO(String userId, String title, String destination, String planContent) {
        this.userId = userId;
        this.title = title;
        this.destination = destination;
        this.planContent = planContent;
        this.isTemplate = false;
        this.status = "draft";
    }
    
    public Long getPlanId() {
        return planId;
    }
    
    public void setPlanId(Long planId) {
        this.planId = planId;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDestination() {
        return destination;
    }
    
    public void setDestination(String destination) {
        this.destination = destination;
    }
    
    public Date getStartDate() {
        return startDate;
    }
    
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }
    
    public Date getEndDate() {
        return endDate;
    }
    
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
    
    public Integer getDuration() {
        return duration;
    }
    
    public void setDuration(Integer duration) {
        this.duration = duration;
    }
    
    public BigDecimal getBudget() {
        return budget;
    }
    
    public void setBudget(BigDecimal budget) {
        this.budget = budget;
    }
    
    public Integer getMaxParticipants() {
        return maxParticipants;
    }
    
    public void setMaxParticipants(Integer maxParticipants) {
        this.maxParticipants = maxParticipants;
    }
    
    public String getTravelStyle() {
        return travelStyle;
    }
    
    public void setTravelStyle(String travelStyle) {
        this.travelStyle = travelStyle;
    }
    
    public String getPlanContent() {
        return planContent;
    }
    
    public void setPlanContent(String planContent) {
        this.planContent = planContent;
    }
    
    public String getChatSessionId() {
        return chatSessionId;
    }
    
    public void setChatSessionId(String chatSessionId) {
        this.chatSessionId = chatSessionId;
    }
    
    public String getMemo() {
        return memo;
    }
    
    public void setMemo(String memo) {
        this.memo = memo;
    }
    
    public Boolean getIsTemplate() {
        return isTemplate;
    }
    
    public void setIsTemplate(Boolean isTemplate) {
        this.isTemplate = isTemplate;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public List<String> getTags() {
        return tags;
    }
    
    public void setTags(List<String> tags) {
        this.tags = tags;
    }
    
    @Override
    public String toString() {
        return "AiTravelPlanDTO{" +
                "planId=" + planId +
                ", userId=" + userId +
                ", title='" + title + '\'' +
                ", destination='" + destination + '\'' +
                ", duration=" + duration +
                ", budget=" + budget +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}