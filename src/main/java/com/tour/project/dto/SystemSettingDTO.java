package com.tour.project.dto;

import java.sql.Timestamp;

/**
 * 시스템 설정 DTO
 * - Claude API 키 등 시스템 설정 저장용
 */
public class SystemSettingDTO {

    private Integer settingId;
    private String settingKey;
    private String settingValue;
    private String settingDescription;
    private Boolean isEncrypted;
    private Boolean isActive;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private String updatedBy;

    public SystemSettingDTO() {}

    public SystemSettingDTO(String settingKey, String settingValue) {
        this.settingKey = settingKey;
        this.settingValue = settingValue;
    }

    // Getters and Setters
    public Integer getSettingId() {
        return settingId;
    }

    public void setSettingId(Integer settingId) {
        this.settingId = settingId;
    }

    public String getSettingKey() {
        return settingKey;
    }

    public void setSettingKey(String settingKey) {
        this.settingKey = settingKey;
    }

    public String getSettingValue() {
        return settingValue;
    }

    public void setSettingValue(String settingValue) {
        this.settingValue = settingValue;
    }

    public String getSettingDescription() {
        return settingDescription;
    }

    public void setSettingDescription(String settingDescription) {
        this.settingDescription = settingDescription;
    }

    public Boolean getIsEncrypted() {
        return isEncrypted;
    }

    public void setIsEncrypted(Boolean isEncrypted) {
        this.isEncrypted = isEncrypted;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    @Override
    public String toString() {
        return "SystemSettingDTO{" +
                "settingId=" + settingId +
                ", settingKey='" + settingKey + '\'' +
                ", isEncrypted=" + isEncrypted +
                ", isActive=" + isActive +
                ", updatedAt=" + updatedAt +
                '}';
    }
}
