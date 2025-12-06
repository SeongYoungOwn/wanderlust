package com.tour.project.dto;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDateTime;
import java.util.List;

/**
 * AI Planner Travel Plan Summary Response DTO
 * Used when retrieving plan lists
 */
public class TravelPlanSummaryDTO {
    private Long planId;
    private String title;
    private String destination;
    private Date startDate;
    private Date endDate;
    private Integer duration;
    private BigDecimal budget;
    private Integer maxParticipants;
    private List<String> tags;
    private LocalDateTime createdAt;
    private String status;
    private Boolean isTemplate;
    private String memo;
    private String planType; // "AI_PLANNER" 또는 "REGULAR" 구분용
    
    public TravelPlanSummaryDTO() {}
    
    public TravelPlanSummaryDTO(Long planId, String title, String destination, Integer duration, BigDecimal budget) {
        this.planId = planId;
        this.title = title;
        this.destination = destination;
        this.duration = duration;
        this.budget = budget;
    }
    
    public Long getPlanId() {
        return planId;
    }
    
    public void setPlanId(Long planId) {
        this.planId = planId;
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
    
    public List<String> getTags() {
        return tags;
    }
    
    public void setTags(List<String> tags) {
        this.tags = tags;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Boolean getIsTemplate() {
        return isTemplate;
    }
    
    public void setIsTemplate(Boolean isTemplate) {
        this.isTemplate = isTemplate;
    }
    
    public String getMemo() {
        return memo;
    }
    
    public void setMemo(String memo) {
        this.memo = memo;
    }
    
    public String getPlanType() {
        return planType;
    }
    
    public void setPlanType(String planType) {
        this.planType = planType;
    }
    
    @Override
    public String toString() {
        return "TravelPlanSummaryDTO{" +
                "planId=" + planId +
                ", title='" + title + '\'' +
                ", destination='" + destination + '\'' +
                ", duration=" + duration +
                ", budget=" + budget +
                ", status='" + status + '\'' +
                '}';
    }
}