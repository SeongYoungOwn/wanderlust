package com.tour.project.dto;

import java.util.Date;

public class TravelParticipantDTO {
    private Long participantId;
    private Long travelId;
    private String userId;
    private Date joinedDate;
    private String status;
    
    // 조인을 위한 추가 필드
    private String userName;
    private String nickname;
    private String travelTitle;
    private String destination;
    private Date startDate;
    private Date endDate;
    private Long budget;
    private String content;
    private String planWriter;
    private Integer maxPeople;
    private Date planRegdate;
    private String planWriterName;
    
    public TravelParticipantDTO() {}
    
    public Long getParticipantId() {
        return participantId;
    }
    
    public void setParticipantId(Long participantId) {
        this.participantId = participantId;
    }
    
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
    
    public Date getJoinedDate() {
        return joinedDate;
    }
    
    public void setJoinedDate(Date joinedDate) {
        this.joinedDate = joinedDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public String getNickname() {
        return nickname;
    }
    
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getTravelTitle() {
        return travelTitle;
    }
    
    public void setTravelTitle(String travelTitle) {
        this.travelTitle = travelTitle;
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
    
    public Long getBudget() {
        return budget;
    }
    
    public void setBudget(Long budget) {
        this.budget = budget;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getPlanWriter() {
        return planWriter;
    }
    
    public void setPlanWriter(String planWriter) {
        this.planWriter = planWriter;
    }
    
    public Integer getMaxPeople() {
        return maxPeople;
    }
    
    public void setMaxPeople(Integer maxPeople) {
        this.maxPeople = maxPeople;
    }
    
    public Date getPlanRegdate() {
        return planRegdate;
    }
    
    public void setPlanRegdate(Date planRegdate) {
        this.planRegdate = planRegdate;
    }
    
    public String getPlanWriterName() {
        return planWriterName;
    }
    
    public void setPlanWriterName(String planWriterName) {
        this.planWriterName = planWriterName;
    }
}