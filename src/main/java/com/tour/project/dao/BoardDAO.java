package com.tour.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import com.tour.project.dto.BoardDTO;
import java.util.List;

@Mapper
@Repository
public interface BoardDAO {
    
    int insertBoard(BoardDTO board);
    
    BoardDTO getBoard(int boardId);
    
    int updateBoard(BoardDTO board);
    
    int deleteBoard(int boardId);
    
    List<BoardDTO> getAllBoards();
    
    List<BoardDTO> getAllBoards(java.util.Map<String, Object> params);
    
    List<BoardDTO> getBoardsByCategory(String category);
    
    List<BoardDTO> getBoardsByWriter(String boardWriter);
    
    int increaseViews(int boardId);
    
    int addLike(@Param("boardId") int boardId, @Param("userId") String userId);
    
    int removeLike(@Param("boardId") int boardId, @Param("userId") String userId);
    
    int updateLikeCount(int boardId);
    
    boolean isUserLiked(@Param("boardId") int boardId, @Param("userId") String userId);
    
    // 싫어요 관련 메서드들
    int addDislike(@Param("boardId") int boardId, @Param("userId") String userId);
    
    int removeDislike(@Param("boardId") int boardId, @Param("userId") String userId);
    
    int updateDislikeCount(int boardId);
    
    boolean isUserDisliked(@Param("boardId") int boardId, @Param("userId") String userId);
    
    // 검색 관련 메서드들
    List<BoardDTO> searchBoardsByTitle(String keyword);
    
    List<BoardDTO> searchBoardsByContent(String keyword);
    
    List<BoardDTO> searchBoardsByWriter(String keyword);
    
    List<BoardDTO> searchBoardsByTitleOrContent(String keyword);
    
    // 페이징 관련 메서드들
    List<BoardDTO> getBoardsWithPaging(java.util.Map<String, Object> params);
    
    int getTotalBoardCount();
    
    List<BoardDTO> searchBoardsWithPaging(java.util.Map<String, Object> params);
    
    int getSearchBoardCount(java.util.Map<String, Object> params);
    
    // 프로필용 메소드들
    List<BoardDTO> selectUserPosts(java.util.Map<String, Object> params);

    int countUserPosts(String userId);

    // 인기 게시글 조회
    List<BoardDTO> getPopularBoards(@Param("limit") int limit);
}