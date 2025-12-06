package com.tour.project.dto;

import java.util.Date;

public class TravelJoinRequestDTO {
    private Integer requestId;
    private Integer travelPlanId;
    private String requesterId;
    private String requestMessage;
    private Date requestDate;
    private String status; // PENDING, APPROVED, REJECTED
    private String responseMessage;
    private Date responseDate;
    private String respondedBy;
    
    // 조인을 위한 추가 필드들
    private String requesterName;
    private String requesterEmail;
    private String travelPlanTitle;
    private String travelPlanDestination;
    private Date travelPlanStartDate;
    private Date travelPlanEndDate;
    private String planWriter;
    private String planWriterName;
    
    // 매너 정보 필드들
    private Double requesterMannerScore;
    private Integer requesterTotalEvaluations;
    private Integer requesterTotalLikes;
    private Integer requesterTotalDislikes;
    private Integer requesterCompletedTravels;
    
    public TravelJoinRequestDTO() {}
    
    // Getters and Setters
    public Integer getRequestId() {
        return requestId;
    }
    
    public void setRequestId(Integer requestId) {
        this.requestId = requestId;
    }
    
    public Integer getTravelPlanId() {
        return travelPlanId;
    }
    
    public void setTravelPlanId(Integer travelPlanId) {
        this.travelPlanId = travelPlanId;
    }
    
    public String getRequesterId() {
        return requesterId;
    }
    
    public void setRequesterId(String requesterId) {
        this.requesterId = requesterId;
    }
    
    public String getRequestMessage() {
        return requestMessage;
    }
    
    public void setRequestMessage(String requestMessage) {
        this.requestMessage = requestMessage;
    }
    
    public Date getRequestDate() {
        return requestDate;
    }
    
    public void setRequestDate(Date requestDate) {
        this.requestDate = requestDate;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getResponseMessage() {
        return responseMessage;
    }
    
    public void setResponseMessage(String responseMessage) {
        this.responseMessage = responseMessage;
    }
    
    public Date getResponseDate() {
        return responseDate;
    }
    
    public void setResponseDate(Date responseDate) {
        this.responseDate = responseDate;
    }
    
    public String getRespondedBy() {
        return respondedBy;
    }
    
    public void setRespondedBy(String respondedBy) {
        this.respondedBy = respondedBy;
    }
    
    public String getRequesterName() {
        return requesterName;
    }
    
    public void setRequesterName(String requesterName) {
        this.requesterName = requesterName;
    }
    
    public String getRequesterEmail() {
        return requesterEmail;
    }
    
    public void setRequesterEmail(String requesterEmail) {
        this.requesterEmail = requesterEmail;
    }
    
    public String getTravelPlanTitle() {
        return travelPlanTitle;
    }
    
    public void setTravelPlanTitle(String travelPlanTitle) {
        this.travelPlanTitle = travelPlanTitle;
    }
    
    public String getTravelPlanDestination() {
        return travelPlanDestination;
    }
    
    public void setTravelPlanDestination(String travelPlanDestination) {
        this.travelPlanDestination = travelPlanDestination;
    }
    
    public Date getTravelPlanStartDate() {
        return travelPlanStartDate;
    }
    
    public void setTravelPlanStartDate(Date travelPlanStartDate) {
        this.travelPlanStartDate = travelPlanStartDate;
    }
    
    public Date getTravelPlanEndDate() {
        return travelPlanEndDate;
    }
    
    public void setTravelPlanEndDate(Date travelPlanEndDate) {
        this.travelPlanEndDate = travelPlanEndDate;
    }
    
    public String getPlanWriter() {
        return planWriter;
    }
    
    public void setPlanWriter(String planWriter) {
        this.planWriter = planWriter;
    }
    
    public String getPlanWriterName() {
        return planWriterName;
    }
    
    public void setPlanWriterName(String planWriterName) {
        this.planWriterName = planWriterName;
    }
    
    public Double getRequesterMannerScore() {
        return requesterMannerScore;
    }
    
    public void setRequesterMannerScore(Double requesterMannerScore) {
        this.requesterMannerScore = requesterMannerScore;
    }
    
    public Integer getRequesterTotalEvaluations() {
        return requesterTotalEvaluations;
    }
    
    public void setRequesterTotalEvaluations(Integer requesterTotalEvaluations) {
        this.requesterTotalEvaluations = requesterTotalEvaluations;
    }
    
    public Integer getRequesterTotalLikes() {
        return requesterTotalLikes;
    }
    
    public void setRequesterTotalLikes(Integer requesterTotalLikes) {
        this.requesterTotalLikes = requesterTotalLikes;
    }
    
    public Integer getRequesterTotalDislikes() {
        return requesterTotalDislikes;
    }
    
    public void setRequesterTotalDislikes(Integer requesterTotalDislikes) {
        this.requesterTotalDislikes = requesterTotalDislikes;
    }
    
    public Integer getRequesterCompletedTravels() {
        return requesterCompletedTravels;
    }
    
    public void setRequesterCompletedTravels(Integer requesterCompletedTravels) {
        this.requesterCompletedTravels = requesterCompletedTravels;
    }
    
    // 매너 온도 계산을 위한 편의 메서드들
    public String getRequesterTemperatureColor() {
        if (requesterMannerScore == null) return "#6c757d";
        if (requesterMannerScore >= 50.0) return "#28a745";
        else if (requesterMannerScore >= 40.0) return "#ffc107";
        else if (requesterMannerScore >= 30.0) return "#fd7e14";
        else return "#dc3545";
    }
    
    public String getRequesterTemperatureIcon() {
        if (requesterMannerScore == null) return "❄️";
        if (requesterMannerScore >= 50.0) return "🔥";
        else if (requesterMannerScore >= 40.0) return "😊";
        else if (requesterMannerScore >= 30.0) return "😐";
        else return "❄️";
    }
    
    public String getRequesterTemperatureLevel() {
        if (requesterMannerScore == null) return "미평가";
        if (requesterMannerScore >= 50.0) return "매너 최고";
        else if (requesterMannerScore >= 40.0) return "매너 좋음";
        else if (requesterMannerScore >= 30.0) return "매너 보통";
        else return "매너 주의";
    }
    
    public Double getRequesterLikeRatio() {
        if (requesterTotalEvaluations == null || requesterTotalEvaluations == 0) return 0.0;
        if (requesterTotalLikes == null) return 0.0;
        return (requesterTotalLikes.doubleValue() / requesterTotalEvaluations.doubleValue()) * 100.0;
    }
    
    // 여행 완료 상태 관련 필드
    private String travelPlanStatus;
    private Date travelPlanCompletedDate;
    
    public String getTravelPlanStatus() {
        return travelPlanStatus;
    }
    
    public void setTravelPlanStatus(String travelPlanStatus) {
        this.travelPlanStatus = travelPlanStatus;
    }
    
    public Date getTravelPlanCompletedDate() {
        return travelPlanCompletedDate;
    }
    
    public void setTravelPlanCompletedDate(Date travelPlanCompletedDate) {
        this.travelPlanCompletedDate = travelPlanCompletedDate;
    }
    
    // 여행 완료 여부 체크 메서드
    public boolean isTravelCompleted() {
        return "COMPLETED".equals(travelPlanStatus);
    }
    
    @Override
    public String toString() {
        return "TravelJoinRequestDTO{" +
                "requestId=" + requestId +
                ", travelPlanId=" + travelPlanId +
                ", requesterId='" + requesterId + '\'' +
                ", status='" + status + '\'' +
                ", requestDate=" + requestDate +
                '}';
    }
}