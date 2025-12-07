package com.tour.project.dto;

import java.sql.Timestamp;

public class NoticeDTO {
    private Long noticeId;
    private String noticeTitle;
    private String noticeContent;
    private String noticeWriter;
    private Timestamp noticeRegdate;
    private int noticeViews;
    private boolean isImportant;
    
    // 추가 정보 (JOIN 결과용)
    private String writerName;
    
    public NoticeDTO() {}
    
    public NoticeDTO(String noticeTitle, String noticeContent, String noticeWriter) {
        this.noticeTitle = noticeTitle;
        this.noticeContent = noticeContent;
        this.noticeWriter = noticeWriter;
    }
    
    // Getters and Setters
    public Long getNoticeId() {
        return noticeId;
    }
    
    public void setNoticeId(Long noticeId) {
        this.noticeId = noticeId;
    }
    
    public String getNoticeTitle() {
        return noticeTitle;
    }
    
    public void setNoticeTitle(String noticeTitle) {
        this.noticeTitle = noticeTitle;
    }
    
    public String getNoticeContent() {
        return noticeContent;
    }
    
    public void setNoticeContent(String noticeContent) {
        this.noticeContent = noticeContent;
    }
    
    public String getNoticeWriter() {
        return noticeWriter;
    }
    
    public void setNoticeWriter(String noticeWriter) {
        this.noticeWriter = noticeWriter;
    }
    
    public Timestamp getNoticeRegdate() {
        return noticeRegdate;
    }
    
    public void setNoticeRegdate(Timestamp noticeRegdate) {
        this.noticeRegdate = noticeRegdate;
    }
    
    public int getNoticeViews() {
        return noticeViews;
    }
    
    public void setNoticeViews(int noticeViews) {
        this.noticeViews = noticeViews;
    }
    
    public boolean isImportant() {
        return isImportant;
    }
    
    public void setImportant(boolean important) {
        isImportant = important;
    }
    
    public String getWriterName() {
        return writerName;
    }
    
    public void setWriterName(String writerName) {
        this.writerName = writerName;
    }
    
    @Override
    public String toString() {
        return "NoticeDTO{" +
                "noticeId=" + noticeId +
                ", noticeTitle='" + noticeTitle + '\'' +
                ", noticeContent='" + noticeContent + '\'' +
                ", noticeWriter='" + noticeWriter + '\'' +
                ", noticeRegdate=" + noticeRegdate +
                ", noticeViews=" + noticeViews +
                ", isImportant=" + isImportant +
                ", writerName='" + writerName + '\'' +
                '}';
    }
}