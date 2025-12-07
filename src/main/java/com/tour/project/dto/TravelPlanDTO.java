package com.tour.project.dto;

import java.sql.Date;
import java.sql.Timestamp;

public class TravelPlanDTO {
    private int planId;
    private String planTitle;
    private String planDestination;
    private Date planStartDate;
    private Date planEndDate;
    private Integer planBudget;
    private String planContent;
    private String planImage;
    private String planWriter;
    private Timestamp planRegdate;
    private int participantCount;
    private int maxParticipants;
    private boolean userJoined;
    private boolean userApproved;
    private boolean userRequestPending;
    private boolean favorite;
    private String planTags;
    private int planViewCount;
    private int favoriteCount;
    private String planStatus;
    private Timestamp completedDate;
    private int daysUntil; // D-Day 계산용 필드 추가
    private String writerName;
    private String writerMbti;
    private Double mannerTemperature;

    // 채팅방 목록용 필드
    private String lastMessage;
    private Timestamp lastMessageTime;

    public TravelPlanDTO() {}
    
    public TravelPlanDTO(int planId, String planTitle, String planDestination, Date planStartDate, 
                        Date planEndDate, Integer planBudget, String planContent, String planWriter, 
                        Timestamp planRegdate) {
        this.planId = planId;
        this.planTitle = planTitle;
        this.planDestination = planDestination;
        this.planStartDate = planStartDate;
        this.planEndDate = planEndDate;
        this.planBudget = planBudget;
        this.planContent = planContent;
        this.planWriter = planWriter;
        this.planRegdate = planRegdate;
    }
    
    public int getPlanId() {
        return planId;
    }
    
    public void setPlanId(int planId) {
        this.planId = planId;
    }
    
    public String getPlanTitle() {
        return planTitle;
    }
    
    public void setPlanTitle(String planTitle) {
        this.planTitle = planTitle;
    }
    
    public String getPlanDestination() {
        return planDestination;
    }
    
    public void setPlanDestination(String planDestination) {
        this.planDestination = planDestination;
    }
    
    public Date getPlanStartDate() {
        return planStartDate;
    }
    
    public void setPlanStartDate(Date planStartDate) {
        this.planStartDate = planStartDate;
    }
    
    public Date getPlanEndDate() {
        return planEndDate;
    }
    
    public void setPlanEndDate(Date planEndDate) {
        this.planEndDate = planEndDate;
    }
    
    public Integer getPlanBudget() {
        return planBudget;
    }
    
    public void setPlanBudget(Integer planBudget) {
        this.planBudget = planBudget;
    }
    
    public String getPlanContent() {
        return planContent;
    }
    
    public void setPlanContent(String planContent) {
        this.planContent = planContent;
    }
    
    public String getPlanImage() {
        return planImage;
    }
    
    public void setPlanImage(String planImage) {
        this.planImage = planImage;
    }
    
    public String getPlanWriter() {
        return planWriter;
    }
    
    public void setPlanWriter(String planWriter) {
        this.planWriter = planWriter;
    }
    
    public Timestamp getPlanRegdate() {
        return planRegdate;
    }
    
    public void setPlanRegdate(Timestamp planRegdate) {
        this.planRegdate = planRegdate;
    }
    
    public java.time.LocalDateTime getPlanCreatedDate() {
        return planRegdate != null ? planRegdate.toLocalDateTime() : null;
    }
    
    public int getParticipantCount() {
        return participantCount;
    }
    
    public void setParticipantCount(int participantCount) {
        this.participantCount = participantCount;
    }
    
    public int getMaxParticipants() {
        return maxParticipants;
    }
    
    public void setMaxParticipants(int maxParticipants) {
        this.maxParticipants = maxParticipants;
    }
    
    public boolean isUserJoined() {
        return userJoined;
    }
    
    public void setUserJoined(boolean userJoined) {
        this.userJoined = userJoined;
    }
    
    public boolean isFavorite() {
        return favorite;
    }
    
    public void setFavorite(boolean favorite) {
        this.favorite = favorite;
    }
    
    public boolean isUserApproved() {
        return userApproved;
    }
    
    public void setUserApproved(boolean userApproved) {
        this.userApproved = userApproved;
    }
    
    public boolean isUserRequestPending() {
        return userRequestPending;
    }
    
    public void setUserRequestPending(boolean userRequestPending) {
        this.userRequestPending = userRequestPending;
    }
    
    public String getPlanTags() {
        return planTags;
    }
    
    public void setPlanTags(String planTags) {
        this.planTags = planTags;
    }
    
    public int getPlanViewCount() {
        return planViewCount;
    }
    
    public void setPlanViewCount(int planViewCount) {
        this.planViewCount = planViewCount;
    }
    
    public int getFavoriteCount() {
        return favoriteCount;
    }
    
    public void setFavoriteCount(int favoriteCount) {
        this.favoriteCount = favoriteCount;
    }
    
    public String getPlanStatus() {
        return planStatus;
    }
    
    public void setPlanStatus(String planStatus) {
        this.planStatus = planStatus;
    }
    
    public Timestamp getCompletedDate() {
        return completedDate;
    }
    
    public void setCompletedDate(Timestamp completedDate) {
        this.completedDate = completedDate;
    }

    public int getDaysUntil() {
        return daysUntil;
    }

    public void setDaysUntil(int daysUntil) {
        this.daysUntil = daysUntil;
    }

    public String getWriterName() {
        return writerName;
    }

    public void setWriterName(String writerName) {
        this.writerName = writerName;
    }

    public String getWriterMbti() {
        return writerMbti;
    }

    public void setWriterMbti(String writerMbti) {
        this.writerMbti = writerMbti;
    }

    public Double getMannerTemperature() {
        return mannerTemperature;
    }

    public void setMannerTemperature(Double mannerTemperature) {
        this.mannerTemperature = mannerTemperature;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(String lastMessage) {
        this.lastMessage = lastMessage;
    }

    public Timestamp getLastMessageTime() {
        return lastMessageTime;
    }

    public void setLastMessageTime(Timestamp lastMessageTime) {
        this.lastMessageTime = lastMessageTime;
    }

    @Override
    public String toString() {
        return "TravelPlanDTO{" +
                "planId=" + planId +
                ", planTitle='" + planTitle + '\'' +
                ", planDestination='" + planDestination + '\'' +
                ", planStartDate=" + planStartDate +
                ", planEndDate=" + planEndDate +
                ", planBudget=" + planBudget +
                ", planWriter='" + planWriter + '\'' +
                ", planRegdate=" + planRegdate +
                '}';
    }
}