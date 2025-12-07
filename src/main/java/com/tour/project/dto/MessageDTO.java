package com.tour.project.dto;

import java.time.LocalDateTime;

public class MessageDTO {
    private int messageId;
    private String senderId;
    private String senderName;
    private String receiverId;
    private String receiverName;
    private String messageTitle;
    private String messageContent;
    private LocalDateTime sentDate;
    private LocalDateTime readDate;
    private boolean isRead;
    private boolean senderDeleted;
    private boolean receiverDeleted;

    // 기본 생성자
    public MessageDTO() {}

    // 전체 생성자
    public MessageDTO(int messageId, String senderId, String senderName, String receiverId, 
                     String receiverName, String messageTitle, String messageContent, 
                     LocalDateTime sentDate, LocalDateTime readDate, boolean isRead, 
                     boolean senderDeleted, boolean receiverDeleted) {
        this.messageId = messageId;
        this.senderId = senderId;
        this.senderName = senderName;
        this.receiverId = receiverId;
        this.receiverName = receiverName;
        this.messageTitle = messageTitle;
        this.messageContent = messageContent;
        this.sentDate = sentDate;
        this.readDate = readDate;
        this.isRead = isRead;
        this.senderDeleted = senderDeleted;
        this.receiverDeleted = receiverDeleted;
    }

    // Getter & Setter
    public int getMessageId() {
        return messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
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

    public String getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(String receiverId) {
        this.receiverId = receiverId;
    }

    public String getReceiverName() {
        return receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public String getMessageTitle() {
        return messageTitle;
    }

    public void setMessageTitle(String messageTitle) {
        this.messageTitle = messageTitle;
    }

    public String getMessageContent() {
        return messageContent;
    }

    public void setMessageContent(String messageContent) {
        this.messageContent = messageContent;
    }

    public LocalDateTime getSentDate() {
        return sentDate;
    }

    public void setSentDate(LocalDateTime sentDate) {
        this.sentDate = sentDate;
    }

    public LocalDateTime getReadDate() {
        return readDate;
    }

    public void setReadDate(LocalDateTime readDate) {
        this.readDate = readDate;
    }

    public boolean isRead() {
        return isRead;
    }

    public void setRead(boolean read) {
        isRead = read;
    }

    public boolean isSenderDeleted() {
        return senderDeleted;
    }

    public void setSenderDeleted(boolean senderDeleted) {
        this.senderDeleted = senderDeleted;
    }

    public boolean isReceiverDeleted() {
        return receiverDeleted;
    }

    public void setReceiverDeleted(boolean receiverDeleted) {
        this.receiverDeleted = receiverDeleted;
    }

    @Override
    public String toString() {
        return "MessageDTO{" +
                "messageId=" + messageId +
                ", senderId='" + senderId + '\'' +
                ", senderName='" + senderName + '\'' +
                ", receiverId='" + receiverId + '\'' +
                ", receiverName='" + receiverName + '\'' +
                ", messageTitle='" + messageTitle + '\'' +
                ", messageContent='" + messageContent + '\'' +
                ", sentDate=" + sentDate +
                ", readDate=" + readDate +
                ", isRead=" + isRead +
                ", senderDeleted=" + senderDeleted +
                ", receiverDeleted=" + receiverDeleted +
                '}';
    }
}