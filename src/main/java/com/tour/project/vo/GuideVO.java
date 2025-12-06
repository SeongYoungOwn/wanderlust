package com.tour.project.vo;

import java.sql.Timestamp;

public class GuideVO {
    private int guideId;
    private String userId;
    private String region;
    private String address;
    private String phone;
    private String specialtyRegion;
    private String specialtyTheme;
    private String specialtyArea;
    private String introduction;
    private String status;
    private double rating;
    private int reviewCount;
    private Timestamp createdDate;
    private Timestamp updatedDate;

    // User 정보 조인용
    private String userName;
    private String userEmail;

    // 기본 생성자
    public GuideVO() {}

    // Getters and Setters
    public int getGuideId() {
        return guideId;
    }

    public void setGuideId(int guideId) {
        this.guideId = guideId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getSpecialtyRegion() {
        return specialtyRegion;
    }

    public void setSpecialtyRegion(String specialtyRegion) {
        this.specialtyRegion = specialtyRegion;
    }

    public String getSpecialtyTheme() {
        return specialtyTheme;
    }

    public void setSpecialtyTheme(String specialtyTheme) {
        this.specialtyTheme = specialtyTheme;
    }

    public String getSpecialtyArea() {
        return specialtyArea;
    }

    public void setSpecialtyArea(String specialtyArea) {
        this.specialtyArea = specialtyArea;
    }

    public String getIntroduction() {
        return introduction;
    }

    public void setIntroduction(String introduction) {
        this.introduction = introduction;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public int getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public Timestamp getUpdatedDate() {
        return updatedDate;
    }

    public void setUpdatedDate(Timestamp updatedDate) {
        this.updatedDate = updatedDate;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }
}