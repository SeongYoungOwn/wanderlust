package com.tour.project.dto;

import java.util.Date;

public class PostDTO {
    private int postId;
    private String postTitle;
    private String postContent;
    private String postWriter;
    private Date postRegdate;
    private int postViews;
    private String postCategory;
    
    public PostDTO() {}
    
    public PostDTO(int postId, String postTitle, String postContent, String postWriter, 
                   Date postRegdate, int postViews, String postCategory) {
        this.postId = postId;
        this.postTitle = postTitle;
        this.postContent = postContent;
        this.postWriter = postWriter;
        this.postRegdate = postRegdate;
        this.postViews = postViews;
        this.postCategory = postCategory;
    }
    
    public int getPostId() {
        return postId;
    }
    
    public void setPostId(int postId) {
        this.postId = postId;
    }
    
    public String getPostTitle() {
        return postTitle;
    }
    
    public void setPostTitle(String postTitle) {
        this.postTitle = postTitle;
    }
    
    public String getPostContent() {
        return postContent;
    }
    
    public void setPostContent(String postContent) {
        this.postContent = postContent;
    }
    
    public String getPostWriter() {
        return postWriter;
    }
    
    public void setPostWriter(String postWriter) {
        this.postWriter = postWriter;
    }
    
    public Date getPostRegdate() {
        return postRegdate;
    }
    
    public void setPostRegdate(Date postRegdate) {
        this.postRegdate = postRegdate;
    }
    
    public int getPostViews() {
        return postViews;
    }
    
    public void setPostViews(int postViews) {
        this.postViews = postViews;
    }
    
    public String getPostCategory() {
        return postCategory;
    }
    
    public void setPostCategory(String postCategory) {
        this.postCategory = postCategory;
    }
    
    @Override
    public String toString() {
        return "PostDTO{" +
                "postId=" + postId +
                ", postTitle='" + postTitle + '\'' +
                ", postContent='" + postContent + '\'' +
                ", postWriter='" + postWriter + '\'' +
                ", postRegdate=" + postRegdate +
                ", postViews=" + postViews +
                ", postCategory='" + postCategory + '\'' +
                '}';
    }
}