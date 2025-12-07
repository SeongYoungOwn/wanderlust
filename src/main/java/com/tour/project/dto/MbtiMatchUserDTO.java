package com.tour.project.dto;

import java.sql.Timestamp;
import java.util.Map;

public class MbtiMatchUserDTO {
    private String userId;
    private String userName;
    private String mbtiType;
    private Timestamp testDate;
    private String profileImage;
    private String bio; // 간단한 소개
    private Integer age; // 나이
    private String gender; // 성별 (M/F)
    private int compatibilityPercentage; // 궁합도
    private Double mannerTemperature; // 매너온도
    
    // 추가 필드들 - 상세 점수
    private int mbtiScore;
    private int travelPlanScore;
    private int activityScore;
    private int mannerScore;
    private Map<String, Object> compatibilityDetail;
    
    public MbtiMatchUserDTO() {}
    
    public MbtiMatchUserDTO(String userId, String userName, String mbtiType, Timestamp testDate, String profileImage, String bio) {
        this.userId = userId;
        this.userName = userName;
        this.mbtiType = mbtiType;
        this.testDate = testDate;
        this.profileImage = profileImage;
        this.bio = bio;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
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
    
    public String getProfileImage() {
        return profileImage;
    }
    
    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }
    
    public String getBio() {
        return bio;
    }
    
    public void setBio(String bio) {
        this.bio = bio;
    }
    
    public Integer getAge() {
        return age;
    }
    
    public void setAge(Integer age) {
        this.age = age;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public int getCompatibilityPercentage() {
        return compatibilityPercentage;
    }
    
    public void setCompatibilityPercentage(int compatibilityPercentage) {
        this.compatibilityPercentage = compatibilityPercentage;
    }
    
    public Double getMannerTemperature() {
        return mannerTemperature;
    }
    
    public void setMannerTemperature(Double mannerTemperature) {
        this.mannerTemperature = mannerTemperature;
    }
    
    public int getMbtiScore() {
        return mbtiScore;
    }
    
    public void setMbtiScore(int mbtiScore) {
        this.mbtiScore = mbtiScore;
    }
    
    public int getTravelPlanScore() {
        return travelPlanScore;
    }
    
    public void setTravelPlanScore(int travelPlanScore) {
        this.travelPlanScore = travelPlanScore;
    }
    
    public int getActivityScore() {
        return activityScore;
    }
    
    public void setActivityScore(int activityScore) {
        this.activityScore = activityScore;
    }
    
    public int getMannerScore() {
        return mannerScore;
    }
    
    public void setMannerScore(int mannerScore) {
        this.mannerScore = mannerScore;
    }
    
    public Map<String, Object> getCompatibilityDetail() {
        return compatibilityDetail;
    }
    
    public void setCompatibilityDetail(Map<String, Object> compatibilityDetail) {
        this.compatibilityDetail = compatibilityDetail;
    }
    
    @Override
    public String toString() {
        return "MbtiMatchUserDTO{" +
                "userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", mbtiType='" + mbtiType + '\'' +
                ", testDate=" + testDate +
                ", profileImage='" + profileImage + '\'' +
                ", bio='" + bio + '\'' +
                ", compatibilityPercentage=" + compatibilityPercentage +
                ", mannerTemperature=" + mannerTemperature +
                '}';
    }
}