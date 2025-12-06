package com.tour.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import com.tour.project.dto.CommentDTO;
import java.util.List;

@Mapper
@Repository
public interface CommentDAO {
    
    int insertComment(CommentDTO comment);
    
    CommentDTO getComment(int commentId);
    
    int updateComment(CommentDTO comment);
    
    int deleteComment(int commentId);
    
    List<CommentDTO> getCommentsByBoardId(int boardId);
    
    int getCommentCountByBoardId(int boardId);
    
    List<CommentDTO> getCommentsByWriter(String commentWriter);
    
    // 프로필용 메소드
    int countUserComments(String userId);
    
    // 매칭 시스템용 메소드
    int getUserCommentCount(String userId);
}