package com.tour.project.dto;

import java.util.Date;

public class FavoriteDTO {
    private Long favoriteId;
    private String userId;
    private String itemType; // TRAVEL_PLAN 또는 BOARD
    private Integer itemId;
    private Date createdDate;
    
    // 조인을 위한 추가 필드 (여행 계획)
    private String planTitle;
    private String planDestination;
    private Date planStartDate;
    private Date planEndDate;
    private String planWriter;
    private String planWriterName;
    
    // 조인을 위한 추가 필드 (커뮤니티 게시글)
    private String boardTitle;
    private String boardCategory;
    private String boardWriter;
    private String boardWriterName;
    private Date boardRegdate;
    
    public FavoriteDTO() {}
    
    public Long getFavoriteId() {
        return favoriteId;
    }
    
    public void setFavoriteId(Long favoriteId) {
        this.favoriteId = favoriteId;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getItemType() {
        return itemType;
    }
    
    public void setItemType(String itemType) {
        this.itemType = itemType;
    }
    
    public Integer getItemId() {
        return itemId;
    }
    
    public void setItemId(Integer itemId) {
        this.itemId = itemId;
    }
    
    public Date getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
    }
    
    public String getPlanTitle() {
        return planTitle;
    }
    
    public void setPlanTitle(String planTitle) {
        this.planTitle = planTitle;
    }
    
    public String getPlanDestination() {
        return planDestination;
    }
    
    public void setPlanDestination(String planDestination) {
        this.planDestination = planDestination;
    }
    
    public Date getPlanStartDate() {
        return planStartDate;
    }
    
    public void setPlanStartDate(Date planStartDate) {
        this.planStartDate = planStartDate;
    }
    
    public Date getPlanEndDate() {
        return planEndDate;
    }
    
    public void setPlanEndDate(Date planEndDate) {
        this.planEndDate = planEndDate;
    }
    
    public String getPlanWriter() {
        return planWriter;
    }
    
    public void setPlanWriter(String planWriter) {
        this.planWriter = planWriter;
    }
    
    public String getPlanWriterName() {
        return planWriterName;
    }
    
    public void setPlanWriterName(String planWriterName) {
        this.planWriterName = planWriterName;
    }
    
    public String getBoardTitle() {
        return boardTitle;
    }
    
    public void setBoardTitle(String boardTitle) {
        this.boardTitle = boardTitle;
    }
    
    public String getBoardCategory() {
        return boardCategory;
    }
    
    public void setBoardCategory(String boardCategory) {
        this.boardCategory = boardCategory;
    }
    
    public String getBoardWriter() {
        return boardWriter;
    }
    
    public void setBoardWriter(String boardWriter) {
        this.boardWriter = boardWriter;
    }
    
    public String getBoardWriterName() {
        return boardWriterName;
    }
    
    public void setBoardWriterName(String boardWriterName) {
        this.boardWriterName = boardWriterName;
    }
    
    public Date getBoardRegdate() {
        return boardRegdate;
    }
    
    public void setBoardRegdate(Date boardRegdate) {
        this.boardRegdate = boardRegdate;
    }
    
    // 삭제된 항목 여부 확인 메서드
    public boolean isDeleted() {
        if ("TRAVEL_PLAN".equals(itemType)) {
            return planTitle == null; // 여행계획이 삭제된 경우 planTitle이 null
        } else if ("BOARD".equals(itemType)) {
            return boardTitle == null; // 게시글이 삭제된 경우 boardTitle이 null
        }
        return false;
    }
    
    // 삭제된 항목의 표시 제목 반환
    public String getDisplayTitle() {
        if (isDeleted()) {
            if ("TRAVEL_PLAN".equals(itemType)) {
                return "[삭제된 여행계획]";
            } else if ("BOARD".equals(itemType)) {
                return "[삭제된 게시글]";
            }
        }
        
        if ("TRAVEL_PLAN".equals(itemType)) {
            return planTitle;
        } else if ("BOARD".equals(itemType)) {
            return boardTitle;
        }
        
        return "알 수 없는 항목";
    }
}