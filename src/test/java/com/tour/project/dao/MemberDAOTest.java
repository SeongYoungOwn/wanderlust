package com.tour.project.dao;

import com.tour.project.dto.MemberDTO;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;

import static org.junit.Assert.*;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {com.tour.project.Application.class})
@TestPropertySource(locations = "classpath:application-test.properties")
@Transactional
public class MemberDAOTest {
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Test
    public void testGetTime() {
        String time = memberDAO.getTime();
        assertNotNull("Time should not be null", time);
        System.out.println("Current time from database: " + time);
    }
    
    @Test
    public void testMemberCRUD() {
        MemberDTO member = new MemberDTO();
        member.setUserId("testuser");
        member.setUserPassword("testpass");
        member.setUserName("Test User");
        member.setUserEmail("test@example.com");
        member.setUserMbti("ISTJ");
        member.setUserRegdate(new Timestamp(System.currentTimeMillis()));
        
        int insertResult = memberDAO.insertMember(member);
        assertEquals("Insert should affect 1 row", 1, insertResult);
        
        MemberDTO retrievedMember = memberDAO.getMember("testuser");
        assertNotNull("Retrieved member should not be null", retrievedMember);
        assertEquals("Name should match", "Test User", retrievedMember.getUserName());
        assertEquals("Email should match", "test@example.com", retrievedMember.getUserEmail());
        assertEquals("MBTI should match", "ISTJ", retrievedMember.getUserMbti());
        
        retrievedMember.setUserName("Updated User");
        retrievedMember.setUserEmail("updated@example.com");
        retrievedMember.setUserMbti("ENFP");
        int updateResult = memberDAO.updateMember(retrievedMember);
        assertEquals("Update should affect 1 row", 1, updateResult);
        
        MemberDTO updatedMember = memberDAO.getMember("testuser");
        assertNotNull("Updated member should not be null", updatedMember);
        assertEquals("Updated name should match", "Updated User", updatedMember.getUserName());
        assertEquals("Updated email should match", "updated@example.com", updatedMember.getUserEmail());
        assertEquals("Updated MBTI should match", "ENFP", updatedMember.getUserMbti());
        
        int deleteResult = memberDAO.deleteMember("testuser");
        assertEquals("Delete should affect 1 row", 1, deleteResult);
        
        MemberDTO deletedMember = memberDAO.getMember("testuser");
        assertNull("Member should be null after deletion", deletedMember);
        
        System.out.println("Member CRUD test completed successfully");
    }
}