package com.tour.project.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * AI Planner Travel Plan Save Request DTO
 */
public class SavePlanRequestDTO {
    private String title;
    private String destination;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer duration;
    private BigDecimal budget;
    private String travelStyle;
    private String planContent; // JSON format plan content
    private List<String> tags;
    private String memo;
    private Boolean isTemplate;
    private String chatSessionId;
    
    public SavePlanRequestDTO() {}
    
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
    
    public LocalDate getStartDate() {
        return startDate;
    }
    
    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }
    
    public LocalDate getEndDate() {
        return endDate;
    }
    
    public void setEndDate(LocalDate endDate) {
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
    
    public List<String> getTags() {
        return tags;
    }
    
    public void setTags(List<String> tags) {
        this.tags = tags;
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
    
    public String getChatSessionId() {
        return chatSessionId;
    }
    
    public void setChatSessionId(String chatSessionId) {
        this.chatSessionId = chatSessionId;
    }
    
    @Override
    public String toString() {
        return "SavePlanRequestDTO{" +
                "title='" + title + '\'' +
                ", destination='" + destination + '\'' +
                ", duration=" + duration +
                ", budget=" + budget +
                ", tagsCount=" + (tags != null ? tags.size() : 0) +
                '}';
    }
}