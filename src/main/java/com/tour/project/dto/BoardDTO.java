package com.tour.project.dto;

import java.sql.Timestamp;

public class BoardDTO {
    private int boardId;
    private String boardTitle;
    private String boardCategory;
    private String boardContent;
    private String boardImage;
    private String boardWriter;
    private Timestamp boardRegdate;
    private int boardViews;
    private int boardLikes;
    private int boardDislikes;
    private boolean favorite;
    private String writerName;
    private int commentCount;
    
    public BoardDTO() {}
    
    public BoardDTO(int boardId, String boardTitle, String boardContent, String boardWriter, Timestamp boardRegdate) {
        this.boardId = boardId;
        this.boardTitle = boardTitle;
        this.boardContent = boardContent;
        this.boardWriter = boardWriter;
        this.boardRegdate = boardRegdate;
        this.boardViews = 0;
        this.boardLikes = 0;
        this.boardDislikes = 0;
    }
    
    public int getBoardId() {
        return boardId;
    }
    
    public void setBoardId(int boardId) {
        this.boardId = boardId;
    }
    
    public String getBoardTitle() {
        return boardTitle;
    }
    
    public void setBoardTitle(String boardTitle) {
        this.boardTitle = boardTitle;
    }
    
    public String getBoardContent() {
        return boardContent;
    }
    
    public void setBoardContent(String boardContent) {
        this.boardContent = boardContent;
    }
    
    public String getBoardCategory() {
        return boardCategory;
    }
    
    public void setBoardCategory(String boardCategory) {
        this.boardCategory = boardCategory;
    }
    
    public String getBoardImage() {
        return boardImage;
    }
    
    public void setBoardImage(String boardImage) {
        this.boardImage = boardImage;
    }
    
    public String getBoardWriter() {
        return boardWriter;
    }
    
    public void setBoardWriter(String boardWriter) {
        this.boardWriter = boardWriter;
    }
    
    public Timestamp getBoardRegdate() {
        return boardRegdate;
    }
    
    public void setBoardRegdate(Timestamp boardRegdate) {
        this.boardRegdate = boardRegdate;
    }
    
    public int getBoardViews() {
        return boardViews;
    }
    
    public void setBoardViews(int boardViews) {
        this.boardViews = boardViews;
    }
    
    public int getBoardLikes() {
        return boardLikes;
    }
    
    public void setBoardLikes(int boardLikes) {
        this.boardLikes = boardLikes;
    }
    
    public int getBoardDislikes() {
        return boardDislikes;
    }
    
    public void setBoardDislikes(int boardDislikes) {
        this.boardDislikes = boardDislikes;
    }
    
    public boolean isFavorite() {
        return favorite;
    }
    
    public void setFavorite(boolean favorite) {
        this.favorite = favorite;
    }

    public String getWriterName() {
        return writerName;
    }

    public void setWriterName(String writerName) {
        this.writerName = writerName;
    }

    public int getCommentCount() {
        return commentCount;
    }

    public void setCommentCount(int commentCount) {
        this.commentCount = commentCount;
    }
    
    @Override
    public String toString() {
        return "BoardDTO{" +
                "boardId=" + boardId +
                ", boardTitle='" + boardTitle + '\'' +
                ", boardWriter='" + boardWriter + '\'' +
                ", boardRegdate=" + boardRegdate +
                '}';
    }
}