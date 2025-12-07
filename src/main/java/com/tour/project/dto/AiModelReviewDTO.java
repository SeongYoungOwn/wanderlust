package com.tour.project.dto;

import java.time.LocalDateTime;

public class AiModelReviewDTO {
    private Long reviewId;
    private String modelId;
    private String userId;
    private String userName; // 조인으로 가져올 사용자명
    private String userProfileImage; // 조인으로 가져올 프로필 이미지
    private Integer rating;
    private String reviewTitle;
    private String reviewContent;
    private Integer helpfulCount;
    private Boolean isRecommended;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Boolean isHelpedByCurrentUser; // 현재 사용자가 도움됨을 눌렀는지 여부
    
    // 기본 생성자
    public AiModelReviewDTO() {}
    
    // 생성자
    public AiModelReviewDTO(String modelId, String userId, Integer rating, 
                           String reviewTitle, String reviewContent, Boolean isRecommended) {
        this.modelId = modelId;
        this.userId = userId;
        this.rating = rating;
        this.reviewTitle = reviewTitle;
        this.reviewContent = reviewContent;
        this.isRecommended = isRecommended;
    }
    
    // Getter & Setter
    public Long getReviewId() {
        return reviewId;
    }
    
    public void setReviewId(Long reviewId) {
        this.reviewId = reviewId;
    }
    
    public String getModelId() {
        return modelId;
    }
    
    public void setModelId(String modelId) {
        this.modelId = modelId;
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
    
    public String getUserProfileImage() {
        return userProfileImage;
    }
    
    public void setUserProfileImage(String userProfileImage) {
        this.userProfileImage = userProfileImage;
    }
    
    public Integer getRating() {
        return rating;
    }
    
    public void setRating(Integer rating) {
        this.rating = rating;
    }
    
    public String getReviewTitle() {
        return reviewTitle;
    }
    
    public void setReviewTitle(String reviewTitle) {
        this.reviewTitle = reviewTitle;
    }
    
    public String getReviewContent() {
        return reviewContent;
    }
    
    public void setReviewContent(String reviewContent) {
        this.reviewContent = reviewContent;
    }
    
    public Integer getHelpfulCount() {
        return helpfulCount;
    }
    
    public void setHelpfulCount(Integer helpfulCount) {
        this.helpfulCount = helpfulCount;
    }
    
    public Boolean getIsRecommended() {
        return isRecommended;
    }
    
    public void setIsRecommended(Boolean isRecommended) {
        this.isRecommended = isRecommended;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public Boolean getIsHelpedByCurrentUser() {
        return isHelpedByCurrentUser;
    }
    
    public void setIsHelpedByCurrentUser(Boolean isHelpedByCurrentUser) {
        this.isHelpedByCurrentUser = isHelpedByCurrentUser;
    }
    
    @Override
    public String toString() {
        return "AiModelReviewDTO{" +
                "reviewId=" + reviewId +
                ", modelId='" + modelId + '\'' +
                ", userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", rating=" + rating +
                ", reviewTitle='" + reviewTitle + '\'' +
                ", reviewContent='" + reviewContent + '\'' +
                ", helpfulCount=" + helpfulCount +
                ", isRecommended=" + isRecommended +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                ", isHelpedByCurrentUser=" + isHelpedByCurrentUser +
                '}';
    }
}