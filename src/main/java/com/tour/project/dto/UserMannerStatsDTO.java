package com.tour.project.dto;

import java.util.Date;

public class UserMannerStatsDTO {
    private String userId;
    private int totalEvaluations;
    private double averageMannerScore;
    private int totalLikes;
    private int totalDislikes;
    private int completedTravels;
    private Date lastUpdated;
    
    // 추가 계산 필드
    private String nickname;
    private String profileImage;
    
    public UserMannerStatsDTO() {}
    
    public UserMannerStatsDTO(String userId) {
        this.userId = userId;
        this.totalEvaluations = 0;
        this.averageMannerScore = 36.5; // 기본값 36.5도
        this.totalLikes = 0;
        this.totalDislikes = 0;
        this.completedTravels = 0;
    }
    
    // Getters and Setters
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public int getTotalEvaluations() {
        return totalEvaluations;
    }
    
    public void setTotalEvaluations(int totalEvaluations) {
        this.totalEvaluations = totalEvaluations;
    }
    
    public double getAverageMannerScore() {
        return averageMannerScore;
    }
    
    public void setAverageMannerScore(double averageMannerScore) {
        this.averageMannerScore = averageMannerScore;
    }
    
    public int getTotalLikes() {
        return totalLikes;
    }
    
    public void setTotalLikes(int totalLikes) {
        this.totalLikes = totalLikes;
    }
    
    public int getTotalDislikes() {
        return totalDislikes;
    }
    
    public void setTotalDislikes(int totalDislikes) {
        this.totalDislikes = totalDislikes;
    }
    
    public int getCompletedTravels() {
        return completedTravels;
    }
    
    public void setCompletedTravels(int completedTravels) {
        this.completedTravels = completedTravels;
    }
    
    public Date getLastUpdated() {
        return lastUpdated;
    }
    
    public void setLastUpdated(Date lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
    
    public String getNickname() {
        return nickname;
    }
    
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getProfileImage() {
        return profileImage;
    }
    
    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }
    
    // 계산된 속성들
    public String getTemperatureLevel() {
        if (averageMannerScore >= 40.0) return "정말 좋은 동행자";
        else if (averageMannerScore >= 37.0) return "좋은 동행자";
        else if (averageMannerScore >= 35.0) return "평범한 동행자";
        else if (averageMannerScore >= 32.0) return "아쉬운 동행자";
        else return "매너가 필요한 동행자";
    }
    
    public String getTemperatureColor() {
        if (averageMannerScore >= 40.0) return "#ff4444";      // 빨간색
        else if (averageMannerScore >= 37.0) return "#ff8800"; // 주황색
        else if (averageMannerScore >= 35.0) return "#ffcc00"; // 노란색
        else if (averageMannerScore >= 32.0) return "#4488ff"; // 파란색
        else return "#8844ff";                                 // 보라색
    }
    
    public String getTemperatureIcon() {
        if (averageMannerScore >= 40.0) return "🔥";
        else if (averageMannerScore >= 37.0) return "🌡️";
        else if (averageMannerScore >= 35.0) return "😊";
        else if (averageMannerScore >= 32.0) return "❄️";
        else return "🧊";
    }
    
    public double getLikeRatio() {
        int total = totalLikes + totalDislikes;
        return total > 0 ? (double) totalLikes / total * 100 : 0.0;
    }
    
    public String getBadgeLevel() {
        if (completedTravels >= 50 && averageMannerScore >= 39.0) return "🥇 골드";
        else if (completedTravels >= 20 && averageMannerScore >= 37.5) return "🥈 실버";
        else if (completedTravels >= 5 && averageMannerScore >= 36.0) return "🥉 브론즈";
        else return "🌱 새싹";
    }
}