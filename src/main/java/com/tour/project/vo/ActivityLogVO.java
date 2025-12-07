package com.tour.project.vo;

import java.sql.Timestamp;

public class ActivityLogVO {
    private int logId;
    private String userId;
    private String activityType;
    private int targetId;
    private String targetTitle;
    private String targetUrl;
    private Timestamp activityDate;
    private boolean isRead;
    private String metadata;

    // 추가 필드 (조인용)
    private String userName;
    private String userImage;
    private String timeAgo; // "5분 전", "1시간 전" 등

    // Getters and Setters
    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getActivityType() {
        return activityType;
    }

    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public int getTargetId() {
        return targetId;
    }

    public void setTargetId(int targetId) {
        this.targetId = targetId;
    }

    public String getTargetTitle() {
        return targetTitle;
    }

    public void setTargetTitle(String targetTitle) {
        this.targetTitle = targetTitle;
    }

    public String getTargetUrl() {
        return targetUrl;
    }

    public void setTargetUrl(String targetUrl) {
        this.targetUrl = targetUrl;
    }

    public Timestamp getActivityDate() {
        return activityDate;
    }

    public void setActivityDate(Timestamp activityDate) {
        this.activityDate = activityDate;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public String getMetadata() {
        return metadata;
    }

    public void setMetadata(String metadata) {
        this.metadata = metadata;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserImage() {
        return userImage;
    }

    public void setUserImage(String userImage) {
        this.userImage = userImage;
    }

    public String getTimeAgo() {
        return timeAgo;
    }

    public void setTimeAgo(String timeAgo) {
        this.timeAgo = timeAgo;
    }

    // Activity Type 아이콘 반환
    public String getActivityIcon() {
        switch(activityType) {
            case "POST_CREATED": return "fa-pen";
            case "PLAN_CREATED": return "fa-map-marked-alt";
            case "REQUEST_RECEIVED": return "fa-user-plus";
            case "REQUEST_SENT": return "fa-paper-plane";
            case "FAVORITE_ADDED": return "fa-heart";
            case "MESSAGE_RECEIVED": return "fa-envelope";
            default: return "fa-bell";
        }
    }

    // Activity Type 색상 반환
    public String getActivityColor() {
        switch(activityType) {
            case "POST_CREATED": return "#6a82fb";
            case "PLAN_CREATED": return "#56ab2f";
            case "REQUEST_RECEIVED": return "#f2994a";
            case "REQUEST_SENT": return "#8e2de2";
            case "FAVORITE_ADDED": return "#ff6b6b";
            case "MESSAGE_RECEIVED": return "#30cfd0";
            default: return "#3498db";
        }
    }

    // Activity Type 한글 설명
    public String getActivityDescription() {
        switch(activityType) {
            case "POST_CREATED": return "게시글을 작성했습니다";
            case "PLAN_CREATED": return "여행 계획을 만들었습니다";
            case "REQUEST_RECEIVED": return "동행 신청을 받았습니다";
            case "REQUEST_SENT": return "동행 신청을 보냈습니다";
            case "FAVORITE_ADDED": return "찜하기를 했습니다";
            case "MESSAGE_RECEIVED": return "메시지를 받았습니다";
            default: return "활동이 있었습니다";
        }
    }
}