package com.tour.project.dto;

import java.sql.Timestamp;

public class EmailVerificationDTO {
    private int verificationId;
    private String email;
    private String verificationCode;
    private Timestamp createdAt;
    private Timestamp expiresAt;
    private boolean isVerified;
    private int attemptCount;

    // Default constructor
    public EmailVerificationDTO() {}

    // Constructor with email and code
    public EmailVerificationDTO(String email, String verificationCode) {
        this.email = email;
        this.verificationCode = verificationCode;
        this.isVerified = false;
        this.attemptCount = 0;
    }

    // Getters and Setters
    public int getVerificationId() {
        return verificationId;
    }

    public void setVerificationId(int verificationId) {
        this.verificationId = verificationId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getVerificationCode() {
        return verificationCode;
    }

    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean verified) {
        isVerified = verified;
    }

    public int getAttemptCount() {
        return attemptCount;
    }

    public void setAttemptCount(int attemptCount) {
        this.attemptCount = attemptCount;
    }
}