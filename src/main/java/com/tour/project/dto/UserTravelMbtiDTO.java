package com.tour.project.dto;

import java.sql.Timestamp;

public class UserTravelMbtiDTO {
    private int id;
    private String userId;
    private String mbtiType;
    private Timestamp testDate;
    private String answers;
    
    public UserTravelMbtiDTO() {}
    
    public UserTravelMbtiDTO(int id, String userId, String mbtiType, Timestamp testDate, String answers) {
        this.id = id;
        this.userId = userId;
        this.mbtiType = mbtiType;
        this.testDate = testDate;
        this.answers = answers;
    }
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getMbtiType() {
        return mbtiType;
    }
    
    public void setMbtiType(String mbtiType) {
        this.mbtiType = mbtiType;
    }
    
    public Timestamp getTestDate() {
        return testDate;
    }
    
    public void setTestDate(Timestamp testDate) {
        this.testDate = testDate;
    }
    
    public String getAnswers() {
        return answers;
    }
    
    public void setAnswers(String answers) {
        this.answers = answers;
    }
    
    @Override
    public String toString() {
        return "UserTravelMbtiDTO{" +
                "id=" + id +
                ", userId='" + userId + '\'' +
                ", mbtiType='" + mbtiType + '\'' +
                ", testDate=" + testDate +
                ", answers='" + answers + '\'' +
                '}';
    }
}