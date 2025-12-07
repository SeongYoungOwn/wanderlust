package com.tour.project.dao;

import com.tour.project.dto.BoardDTO;
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
public class BoardDAOTest {
    
    @Autowired
    private BoardDAO boardDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Before
    public void setUp() {
        MemberDTO testMember = new MemberDTO();
        testMember.setUserId("testboarduser");
        testMember.setUserPassword("testpass");
        testMember.setUserName("Test Board User");
        testMember.setUserEmail("testboard@example.com");
        testMember.setUserMbti("ISTJ");
        testMember.setUserRegdate(new Timestamp(System.currentTimeMillis()));
        
        memberDAO.insertMember(testMember);
    }
    
    @Test
    public void testBoardCRUD() {
        BoardDTO board = new BoardDTO();
        board.setBoardTitle("Test Board Title");
        board.setBoardContent("This is a test board content for testing purposes");
        board.setBoardWriter("testboarduser");
        board.setBoardRegdate(new Timestamp(System.currentTimeMillis()));
        
        int insertResult = boardDAO.insertBoard(board);
        assertEquals("Insert should affect 1 row", 1, insertResult);
        
        List<BoardDTO> allBoards = boardDAO.getAllBoards();
        assertTrue("Should have at least 1 board", allBoards.size() >= 1);
        
        BoardDTO insertedBoard = allBoards.get(0);
        int boardId = insertedBoard.getBoardId();
        
        BoardDTO retrievedBoard = boardDAO.getBoard(boardId);
        assertNotNull("Retrieved board should not be null", retrievedBoard);
        assertEquals("Title should match", "Test Board Title", retrievedBoard.getBoardTitle());
        assertEquals("Content should match", "This is a test board content for testing purposes", retrievedBoard.getBoardContent());
        assertEquals("Writer should match", "testboarduser", retrievedBoard.getBoardWriter());
        
        retrievedBoard.setBoardTitle("Updated Board Title");
        retrievedBoard.setBoardContent("This is an updated board content");
        int updateResult = boardDAO.updateBoard(retrievedBoard);
        assertEquals("Update should affect 1 row", 1, updateResult);
        
        BoardDTO updatedBoard = boardDAO.getBoard(boardId);
        assertNotNull("Updated board should not be null", updatedBoard);
        assertEquals("Updated title should match", "Updated Board Title", updatedBoard.getBoardTitle());
        assertEquals("Updated content should match", "This is an updated board content", updatedBoard.getBoardContent());
        
        int deleteResult = boardDAO.deleteBoard(boardId);
        assertEquals("Delete should affect 1 row", 1, deleteResult);
        
        BoardDTO deletedBoard = boardDAO.getBoard(boardId);
        assertNull("Board should be null after deletion", deletedBoard);
        
        System.out.println("Board CRUD test completed successfully");
    }
    
    @Test
    public void testGetAllBoards() {
        BoardDTO board1 = new BoardDTO();
        board1.setBoardTitle("First Board");
        board1.setBoardContent("Content of first board");
        board1.setBoardWriter("testboarduser");
        board1.setBoardRegdate(new Timestamp(System.currentTimeMillis()));
        
        BoardDTO board2 = new BoardDTO();
        board2.setBoardTitle("Second Board");
        board2.setBoardContent("Content of second board");
        board2.setBoardWriter("testboarduser");
        board2.setBoardRegdate(new Timestamp(System.currentTimeMillis() + 1000));
        
        boardDAO.insertBoard(board1);
        boardDAO.insertBoard(board2);
        
        List<BoardDTO> allBoards = boardDAO.getAllBoards();
        assertTrue("Should have at least 2 boards", allBoards.size() >= 2);
        assertEquals("Most recent board should be first", "Second Board", allBoards.get(0).getBoardTitle());
        
        System.out.println("Get all boards test completed successfully");
    }
}