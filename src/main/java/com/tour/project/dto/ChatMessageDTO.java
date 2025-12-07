package com.tour.project.dto;

import java.time.LocalDateTime;

public class ChatMessageDTO {
    private Long messageId;
    private int travelPlanId;
    private String senderId;
    private String senderName;
    private String content;
    private LocalDateTime timestamp;
    private MessageType type;
    
    // 파일 관련 필드
    private String fileName;
    private String filePath;
    private String fileSize;
    private String originalFilename;
    private String fileType;
    private Long fileSizeBytes;
    
    public enum MessageType {
        CHAT,
        JOIN,
        LEAVE,
        FILE,
        IMAGE
    }
    
    public ChatMessageDTO() {}
    
    public ChatMessageDTO(MessageType type, String content, String senderId, String senderName, int travelPlanId) {
        this.type = type;
        this.content = content;
        this.senderId = senderId;
        this.senderName = senderName;
        this.travelPlanId = travelPlanId;
        this.timestamp = LocalDateTime.now();
    }
    
    // Getters and Setters
    public Long getMessageId() {
        return messageId;
    }
    
    public void setMessageId(Long messageId) {
        this.messageId = messageId;
    }
    
    public int getTravelPlanId() {
        return travelPlanId;
    }
    
    public void setTravelPlanId(int travelPlanId) {
        this.travelPlanId = travelPlanId;
    }
    
    public String getSenderId() {
        return senderId;
    }
    
    public void setSenderId(String senderId) {
        this.senderId = senderId;
    }
    
    public String getSenderName() {
        return senderName;
    }
    
    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public LocalDateTime getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
    
    public MessageType getType() {
        return type;
    }
    
    public void setType(MessageType type) {
        this.type = type;
    }
    
    // 파일 관련 getter/setter
    public String getFileName() {
        return fileName;
    }
    
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
    
    public String getFilePath() {
        return filePath;
    }
    
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
    
    public String getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(String fileSize) {
        this.fileSize = fileSize;
    }
    
    public String getOriginalFilename() {
        return originalFilename;
    }
    
    public void setOriginalFilename(String originalFilename) {
        this.originalFilename = originalFilename;
    }
    
    public String getFileType() {
        return fileType;
    }
    
    public void setFileType(String fileType) {
        this.fileType = fileType;
    }
    
    public Long getFileSizeBytes() {
        return fileSizeBytes;
    }
    
    public void setFileSizeBytes(Long fileSizeBytes) {
        this.fileSizeBytes = fileSizeBytes;
    }
}