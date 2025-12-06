package com.tour.project.dto;

import java.util.Date;

public class BadgeDTO {
    private int badgeId;
    private String badgeName;
    private String badgeDescription;
    private String badgeIcon;
    private String badgeType;
    private Date createdDate;
    private Date earnedDate; // user_badges 테이블의 earned_date
    
    public BadgeDTO() {}
    
    public BadgeDTO(int badgeId, String badgeName, String badgeDescription, String badgeIcon, String badgeType) {
        this.badgeId = badgeId;
        this.badgeName = badgeName;
        this.badgeDescription = badgeDescription;
        this.badgeIcon = badgeIcon;
        this.badgeType = badgeType;
    }
    
    // Getters and Setters
    public int getBadgeId() {
        return badgeId;
    }
    
    public void setBadgeId(int badgeId) {
        this.badgeId = badgeId;
    }
    
    public String getBadgeName() {
        return badgeName;
    }
    
    public void setBadgeName(String badgeName) {
        this.badgeName = badgeName;
    }
    
    public String getBadgeDescription() {
        return badgeDescription;
    }
    
    public void setBadgeDescription(String badgeDescription) {
        this.badgeDescription = badgeDescription;
    }
    
    public String getBadgeIcon() {
        return badgeIcon;
    }
    
    public void setBadgeIcon(String badgeIcon) {
        this.badgeIcon = badgeIcon;
    }
    
    public String getBadgeType() {
        return badgeType;
    }
    
    public void setBadgeType(String badgeType) {
        this.badgeType = badgeType;
    }
    
    public Date getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }
    
    public Date getEarnedDate() {
        return earnedDate;
    }
    
    public void setEarnedDate(Date earnedDate) {
        this.earnedDate = earnedDate;
    }
}