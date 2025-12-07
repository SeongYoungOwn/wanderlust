package com.tour.project.dto;

import java.util.List;

public class UserProfileDTO {
    private String userId;
    private String userName;
    private String userNickname;
    private String userEmail;
    private String profileImage;
    private String bio;
    private String phoneNumber;
    
    // 매너 통계
    private UserMannerStatsDTO mannerStats;
    
    // 여행 MBTI
    private TravelMbtiResultDTO travelMbti;
    
    // 뱃지 목록
    private List<BadgeDTO> badges;
    
    // 최근 여행 계획
    private List<TravelPlanDTO> recentTravelPlans;
    
    // 최근 게시글
    private List<BoardDTO> recentPosts;
    
    // 통계 정보
    private int totalTravelPlans;
    private int completedTravels;
    private int totalPosts;
    private int totalComments;
    
    public UserProfileDTO() {}
    
    // Getters and Setters
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
    
    public String getUserNickname() {
        return userNickname;
    }
    
    public void setUserNickname(String userNickname) {
        this.userNickname = userNickname;
    }
    
    public String getUserEmail() {
        return userEmail;
    }
    
    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
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
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public UserMannerStatsDTO getMannerStats() {
        return mannerStats;
    }
    
    public void setMannerStats(UserMannerStatsDTO mannerStats) {
        this.mannerStats = mannerStats;
    }
    
    public TravelMbtiResultDTO getTravelMbti() {
        return travelMbti;
    }
    
    public void setTravelMbti(TravelMbtiResultDTO travelMbti) {
        this.travelMbti = travelMbti;
    }
    
    public List<BadgeDTO> getBadges() {
        return badges;
    }
    
    public void setBadges(List<BadgeDTO> badges) {
        this.badges = badges;
    }
    
    public List<TravelPlanDTO> getRecentTravelPlans() {
        return recentTravelPlans;
    }
    
    public void setRecentTravelPlans(List<TravelPlanDTO> recentTravelPlans) {
        this.recentTravelPlans = recentTravelPlans;
    }
    
    public List<BoardDTO> getRecentPosts() {
        return recentPosts;
    }
    
    public void setRecentPosts(List<BoardDTO> recentPosts) {
        this.recentPosts = recentPosts;
    }
    
    public int getTotalTravelPlans() {
        return totalTravelPlans;
    }
    
    public void setTotalTravelPlans(int totalTravelPlans) {
        this.totalTravelPlans = totalTravelPlans;
    }
    
    public int getCompletedTravels() {
        return completedTravels;
    }
    
    public void setCompletedTravels(int completedTravels) {
        this.completedTravels = completedTravels;
    }
    
    public int getTotalPosts() {
        return totalPosts;
    }
    
    public void setTotalPosts(int totalPosts) {
        this.totalPosts = totalPosts;
    }
    
    public int getTotalComments() {
        return totalComments;
    }
    
    public void setTotalComments(int totalComments) {
        this.totalComments = totalComments;
    }
}