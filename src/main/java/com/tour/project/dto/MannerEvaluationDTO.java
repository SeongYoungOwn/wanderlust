package com.tour.project.dto;

import java.util.Date;

public class MannerEvaluationDTO {
    private int evaluationId;
    private int travelPlanId;
    private String evaluatorId;
    private String evaluatedId;
    private int mannerScore;  // 365 = 36.5도
    private Boolean isLike;   // true: 좋아요, false: 싫어요, null: 평가안함
    private String evaluationComment;
    private Date createdDate;
    private Date updatedDate;
    
    // 새로운 카테고리 평가 필드
    private String evaluationType; // POSITIVE, NEGATIVE
    private String evaluationCategory;
    
    // 추가 정보 (조인용)
    private String evaluatedNickname;
    private String evaluatedProfileImage;
    private String evaluatorNickname;
    private String evaluatorProfileImage;
    private String travelPlanTitle;
    
    public MannerEvaluationDTO() {}
    
    public MannerEvaluationDTO(int travelPlanId, String evaluatorId, String evaluatedId) {
        this.travelPlanId = travelPlanId;
        this.evaluatorId = evaluatorId;
        this.evaluatedId = evaluatedId;
        this.mannerScore = 365; // 기본값 36.5도
    }
    
    // Getters and Setters
    public int getEvaluationId() {
        return evaluationId;
    }
    
    public void setEvaluationId(int evaluationId) {
        this.evaluationId = evaluationId;
    }
    
    public int getTravelPlanId() {
        return travelPlanId;
    }
    
    public void setTravelPlanId(int travelPlanId) {
        this.travelPlanId = travelPlanId;
    }
    
    public String getEvaluatorId() {
        return evaluatorId;
    }
    
    public void setEvaluatorId(String evaluatorId) {
        this.evaluatorId = evaluatorId;
    }
    
    public String getEvaluatedId() {
        return evaluatedId;
    }
    
    public void setEvaluatedId(String evaluatedId) {
        this.evaluatedId = evaluatedId;
    }
    
    public int getMannerScore() {
        return mannerScore;
    }
    
    public void setMannerScore(int mannerScore) {
        this.mannerScore = mannerScore;
    }
    
    public double getMannerTemperature() {
        return mannerScore / 10.0;
    }
    
    public void setMannerTemperature(double temperature) {
        this.mannerScore = (int) (temperature * 10);
    }
    
    public Boolean getIsLike() {
        return isLike;
    }
    
    public void setIsLike(Boolean isLike) {
        this.isLike = isLike;
    }
    
    public String getEvaluationComment() {
        return evaluationComment;
    }
    
    public void setEvaluationComment(String evaluationComment) {
        this.evaluationComment = evaluationComment;
    }
    
    public Date getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }
    
    public Date getUpdatedDate() {
        return updatedDate;
    }
    
    public void setUpdatedDate(Date updatedDate) {
        this.updatedDate = updatedDate;
    }
    
    public String getEvaluatedNickname() {
        return evaluatedNickname;
    }
    
    public void setEvaluatedNickname(String evaluatedNickname) {
        this.evaluatedNickname = evaluatedNickname;
    }
    
    public String getEvaluatedProfileImage() {
        return evaluatedProfileImage;
    }
    
    public void setEvaluatedProfileImage(String evaluatedProfileImage) {
        this.evaluatedProfileImage = evaluatedProfileImage;
    }
    
    public String getEvaluatorNickname() {
        return evaluatorNickname;
    }
    
    public void setEvaluatorNickname(String evaluatorNickname) {
        this.evaluatorNickname = evaluatorNickname;
    }
    
    public String getEvaluatorProfileImage() {
        return evaluatorProfileImage;
    }
    
    public void setEvaluatorProfileImage(String evaluatorProfileImage) {
        this.evaluatorProfileImage = evaluatorProfileImage;
    }
    
    public String getTravelPlanTitle() {
        return travelPlanTitle;
    }
    
    public void setTravelPlanTitle(String travelPlanTitle) {
        this.travelPlanTitle = travelPlanTitle;
    }
    
    public String getTemperatureLevel() {
        double temp = getMannerTemperature();
        if (temp >= 40.0) return "정말 좋은 동행자";
        else if (temp >= 37.0) return "좋은 동행자";
        else if (temp >= 35.0) return "평범한 동행자";
        else if (temp >= 32.0) return "아쉬운 동행자";
        else return "매너가 필요한 동행자";
    }
    
    public String getTemperatureColor() {
        double temp = getMannerTemperature();
        if (temp >= 40.0) return "#ff4444";      // 빨간색
        else if (temp >= 37.0) return "#ff8800"; // 주황색
        else if (temp >= 35.0) return "#ffcc00"; // 노란색
        else if (temp >= 32.0) return "#4488ff"; // 파란색
        else return "#8844ff";                   // 보라색
    }
    
    // 새로운 카테고리 평가 필드 Getters and Setters
    public String getEvaluationType() {
        return evaluationType;
    }
    
    public void setEvaluationType(String evaluationType) {
        this.evaluationType = evaluationType;
    }
    
    public String getEvaluationCategory() {
        return evaluationCategory;
    }
    
    public void setEvaluationCategory(String evaluationCategory) {
        this.evaluationCategory = evaluationCategory;
    }
}