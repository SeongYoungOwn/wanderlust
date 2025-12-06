package com.tour.project.dto;

import java.sql.Timestamp;

public class ReportDTO {
    private int reportId;
    private String reporterId;
    private String reportedContentType; // BOARD, PLAN
    private int reportedContentId;
    private String reportedUserId;
    private String reportCategory;
    private String reportContent;
    private String reportStatus;
    private String adminComment;
    private String processedBy;
    private Timestamp createdAt;
    private Timestamp processedAt;
    
    // 조인용 필드
    private String reporterName;
    private String reportedUserName;
    private String contentTitle;
    private String processedByName;
    private String reportReason;
    private Timestamp reportDate;
    
    // 기본 생성자
    public ReportDTO() {
    }
    
    // Getters and Setters
    public int getReportId() {
        return reportId;
    }
    
    public void setReportId(int reportId) {
        this.reportId = reportId;
    }
    
    public String getReporterId() {
        return reporterId;
    }
    
    public void setReporterId(String reporterId) {
        this.reporterId = reporterId;
    }
    
    public String getReportedContentType() {
        return reportedContentType;
    }
    
    public void setReportedContentType(String reportedContentType) {
        this.reportedContentType = reportedContentType;
    }
    
    public int getReportedContentId() {
        return reportedContentId;
    }
    
    public void setReportedContentId(int reportedContentId) {
        this.reportedContentId = reportedContentId;
    }
    
    public String getReportedUserId() {
        return reportedUserId;
    }
    
    public void setReportedUserId(String reportedUserId) {
        this.reportedUserId = reportedUserId;
    }
    
    public String getReportCategory() {
        return reportCategory;
    }
    
    public void setReportCategory(String reportCategory) {
        this.reportCategory = reportCategory;
    }
    
    public String getReportContent() {
        return reportContent;
    }
    
    public void setReportContent(String reportContent) {
        this.reportContent = reportContent;
    }
    
    public String getReportStatus() {
        return reportStatus;
    }
    
    public void setReportStatus(String reportStatus) {
        this.reportStatus = reportStatus;
    }
    
    public String getAdminComment() {
        return adminComment;
    }
    
    public void setAdminComment(String adminComment) {
        this.adminComment = adminComment;
    }
    
    public String getProcessedBy() {
        return processedBy;
    }
    
    public void setProcessedBy(String processedBy) {
        this.processedBy = processedBy;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getProcessedAt() {
        return processedAt;
    }
    
    public void setProcessedAt(Timestamp processedAt) {
        this.processedAt = processedAt;
    }
    
    public String getReporterName() {
        return reporterName;
    }
    
    public void setReporterName(String reporterName) {
        this.reporterName = reporterName;
    }
    
    public String getReportedUserName() {
        return reportedUserName;
    }
    
    public void setReportedUserName(String reportedUserName) {
        this.reportedUserName = reportedUserName;
    }
    
    public String getContentTitle() {
        return contentTitle;
    }
    
    public void setContentTitle(String contentTitle) {
        this.contentTitle = contentTitle;
    }
    
    public String getProcessedByName() {
        return processedByName;
    }
    
    public void setProcessedByName(String processedByName) {
        this.processedByName = processedByName;
    }

    public String getReportReason() {
        return reportReason;
    }

    public void setReportReason(String reportReason) {
        this.reportReason = reportReason;
    }

    public Timestamp getReportDate() {
        return reportDate;
    }

    public void setReportDate(Timestamp reportDate) {
        this.reportDate = reportDate;
    }

    // 신고 카테고리 한글 변환
    public String getCategoryKorean() {
        if (reportCategory == null) return "";
        switch (reportCategory) {
            case "SPAM": return "스팸/도배";
            case "INAPPROPRIATE": return "부적절한 내용";
            case "HARASSMENT": return "욕설/비방";
            case "COPYRIGHT": return "저작권 침해";
            case "FRAUD": return "사기/허위정보";
            case "OTHER": return "기타";
            default: return reportCategory;
        }
    }
    
    // 신고 상태 한글 변환
    public String getStatusKorean() {
        if (reportStatus == null) return "";
        switch (reportStatus) {
            case "PENDING": return "미처리";
            case "APPROVED": return "승인";
            case "REJECTED": return "기각";
            case "RESOLVED": return "처리완료";
            default: return reportStatus;
        }
    }
    
    @Override
    public String toString() {
        return "ReportDTO{" +
                "reportId=" + reportId +
                ", reporterId='" + reporterId + '\'' +
                ", reportedContentType='" + reportedContentType + '\'' +
                ", reportedContentId=" + reportedContentId +
                ", reportedUserId='" + reportedUserId + '\'' +
                ", reportCategory='" + reportCategory + '\'' +
                ", reportStatus='" + reportStatus + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}