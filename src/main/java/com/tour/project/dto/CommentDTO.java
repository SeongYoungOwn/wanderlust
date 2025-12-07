package com.tour.project.dto;

import java.sql.Timestamp;

public class CommentDTO {
    private int commentId;
    private int boardId;
    private String commentContent;
    private String commentWriter;
    private Timestamp commentRegdate;
    
    public CommentDTO() {}
    
    public CommentDTO(int commentId, int boardId, String commentContent, String commentWriter, Timestamp commentRegdate) {
        this.commentId = commentId;
        this.boardId = boardId;
        this.commentContent = commentContent;
        this.commentWriter = commentWriter;
        this.commentRegdate = commentRegdate;
    }
    
    public int getCommentId() {
        return commentId;
    }
    
    public void setCommentId(int commentId) {
        this.commentId = commentId;
    }
    
    public int getBoardId() {
        return boardId;
    }
    
    public void setBoardId(int boardId) {
        this.boardId = boardId;
    }
    
    public String getCommentContent() {
        return commentContent;
    }
    
    public void setCommentContent(String commentContent) {
        this.commentContent = commentContent;
    }
    
    public String getCommentWriter() {
        return commentWriter;
    }
    
    public void setCommentWriter(String commentWriter) {
        this.commentWriter = commentWriter;
    }
    
    public Timestamp getCommentRegdate() {
        return commentRegdate;
    }
    
    public void setCommentRegdate(Timestamp commentRegdate) {
        this.commentRegdate = commentRegdate;
    }
    
    @Override
    public String toString() {
        return "CommentDTO{" +
                "commentId=" + commentId +
                ", boardId=" + boardId +
                ", commentWriter='" + commentWriter + '\'' +
                ", commentRegdate=" + commentRegdate +
                '}';
    }
}