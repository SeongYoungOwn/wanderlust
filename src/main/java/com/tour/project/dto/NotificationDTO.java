package com.tour.project.dto;

import java.util.Date;

public class NotificationDTO {
    private Integer notificationId;
    private String userId;
    private String type; // JOIN_REQUEST, JOIN_APPROVED, JOIN_REJECTED
    private String title;
    private String message;
    private Integer relatedId;
    private Boolean isRead;
    private Date createdDate;
    
    // 조인을 위한 추가 필드들
    private String travelPlanTitle;
    private String requesterName;
    private String planWriterName;
    
    public NotificationDTO() {}
    
    // Getters and Setters
    public Integer getNotificationId() {
        return notificationId;
    }
    
    public void setNotificationId(Integer notificationId) {
        this.notificationId = notificationId;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public Integer getRelatedId() {
        return relatedId;
    }
    
    public void setRelatedId(Integer relatedId) {
        this.relatedId = relatedId;
    }
    
    public Boolean getIsRead() {
        return isRead;
    }
    
    public void setIsRead(Boolean isRead) {
        this.isRead = isRead;
    }
    
    public Date getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }
    
    public String getTravelPlanTitle() {
        return travelPlanTitle;
    }
    
    public void setTravelPlanTitle(String travelPlanTitle) {
        this.travelPlanTitle = travelPlanTitle;
    }
    
    public String getRequesterName() {
        return requesterName;
    }
    
    public void setRequesterName(String requesterName) {
        this.requesterName = requesterName;
    }
    
    public String getPlanWriterName() {
        return planWriterName;
    }
    
    public void setPlanWriterName(String planWriterName) {
        this.planWriterName = planWriterName;
    }
    
    @Override
    public String toString() {
        return "NotificationDTO{" +
                "notificationId=" + notificationId +
                ", userId='" + userId + '\'' +
                ", type='" + type + '\'' +
                ", title='" + title + '\'' +
                ", isRead=" + isRead +
                ", createdDate=" + createdDate +
                '}';
    }
}