package com.tour.project.dto;

import java.util.Date;

public class TravelDTO {
    private Long travelId;
    private String userId;
    private String title;
    private String destination;
    private Date startDate;
    private Date endDate;
    private String description;
    private int maxParticipants;
    private int participantCount;
    private String status;
    private Date createdDate;
    
    // 조인을 위한 추가 필드
    private String userName;
    private boolean isJoined; // 현재 사용자 참여 여부
    
    public TravelDTO() {}
    
    public Long getTravelId() {
        return travelId;
    }
    
    public void setTravelId(Long travelId) {
        this.travelId = travelId;
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
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getMaxParticipants() {
        return maxParticipants;
    }
    
    public void setMaxParticipants(int maxParticipants) {
        this.maxParticipants = maxParticipants;
    }
    
    public int getParticipantCount() {
        return participantCount;
    }
    
    public void setParticipantCount(int participantCount) {
        this.participantCount = participantCount;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public Date getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public boolean isJoined() {
        return isJoined;
    }
    
    public void setJoined(boolean isJoined) {
        this.isJoined = isJoined;
    }
}