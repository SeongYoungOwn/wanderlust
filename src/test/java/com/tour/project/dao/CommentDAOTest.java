package com.tour.project.dao;

import com.tour.project.dto.BoardDTO;
import com.tour.project.dto.CommentDTO;
import com.tour.project.dto.MemberDTO;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

import static org.junit.Assert.*;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {com.tour.project.Application.class})
@TestPropertySource(locations = "classpath:application-test.properties")
@Transactional
public class CommentDAOTest {
    
    @Autowired
    private CommentDAO commentDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private BoardDAO boardDAO;
    
    private int testBoardId;
    
    @Before
    public void setUp() {
        MemberDTO testMember = new MemberDTO();
        testMember.setUserId("testcommentuser");
        testMember.setUserPassword("testpass");
        testMember.setUserName("Test Comment User");
        testMember.setUserEmail("testcomment@example.com");
        testMember.setUserMbti("ISTJ");
        testMember.setUserRegdate(new Timestamp(System.currentTimeMillis()));
        
        memberDAO.insertMember(testMember);
        
        BoardDTO testBoard = new BoardDTO();
        testBoard.setBoardTitle("댓글 테스트용 게시글");
        testBoard.setBoardContent("This board is for comment testing");
        testBoard.setBoardWriter("testcommentuser");
        testBoard.setBoardRegdate(new Timestamp(System.currentTimeMillis()));
        
        boardDAO.insertBoard(testBoard);
        
        List<BoardDTO> boards = boardDAO.getAllBoards();
        testBoardId = boards.get(0).getBoardId();
    }
    
    @Test
    public void testCommentCRUD() {
        CommentDTO comment = new CommentDTO();
        comment.setBoardId(testBoardId);
        comment.setCommentContent("This is a test comment content");
        comment.setCommentWriter("testcommentuser");
        comment.setCommentRegdate(new Timestamp(System.currentTimeMillis()));
        
        int insertResult = commentDAO.insertComment(comment);
        assertEquals("Insert should affect 1 row", 1, insertResult);
        
        List<CommentDTO> boardComments = commentDAO.getCommentsByBoardId(testBoardId);
        assertTrue("Should have at least 1 comment", boardComments.size() >= 1);
        
        CommentDTO insertedComment = boardComments.get(0);
        int commentId = insertedComment.getCommentId();
        
        CommentDTO retrievedComment = commentDAO.getComment(commentId);
        assertNotNull("Retrieved comment should not be null", retrievedComment);
        assertEquals("Content should match", "This is a test comment content", retrievedComment.getCommentContent());
        assertEquals("Writer should match", "testcommentuser", retrievedComment.getCommentWriter());
        assertEquals("Board ID should match", testBoardId, retrievedComment.getBoardId());
        
        retrievedComment.setCommentContent("This is an updated comment content");
        int updateResult = commentDAO.updateComment(retrievedComment);
        assertEquals("Update should affect 1 row", 1, updateResult);
        
        CommentDTO updatedComment = commentDAO.getComment(commentId);
        assertNotNull("Updated comment should not be null", updatedComment);
        assertEquals("Updated content should match", "This is an updated comment content", updatedComment.getCommentContent());
        
        int deleteResult = commentDAO.deleteComment(commentId);
        assertEquals("Delete should affect 1 row", 1, deleteResult);
        
        CommentDTO deletedComment = commentDAO.getComment(commentId);
        assertNull("Comment should be null after deletion", deletedComment);
        
        System.out.println("Comment CRUD test completed successfully");
    }
    
    @Test
    public void testGetCommentsByBoardId() {
        CommentDTO comment1 = new CommentDTO();
        comment1.setBoardId(testBoardId);
        comment1.setCommentContent("First comment");
        comment1.setCommentWriter("testcommentuser");
        comment1.setCommentRegdate(new Timestamp(System.currentTimeMillis()));
        
        CommentDTO comment2 = new CommentDTO();
        comment2.setBoardId(testBoardId);
        comment2.setCommentContent("Second comment");
        comment2.setCommentWriter("testcommentuser");
        comment2.setCommentRegdate(new Timestamp(System.currentTimeMillis() + 1000));
        
        commentDAO.insertComment(comment1);
        commentDAO.insertComment(comment2);
        
        List<CommentDTO> boardComments = commentDAO.getCommentsByBoardId(testBoardId);
        assertTrue("Should have at least 2 comments", boardComments.size() >= 2);
        assertEquals("First comment should come first", "First comment", boardComments.get(0).getCommentContent());
        assertEquals("Second comment should come second", "Second comment", boardComments.get(1).getCommentContent());
        
        System.out.println("Get comments by board ID test completed successfully");
    }
}