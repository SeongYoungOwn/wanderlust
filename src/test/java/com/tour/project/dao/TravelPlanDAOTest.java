package com.tour.project.dao;

import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.TravelPlanDTO;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.List;

import static org.junit.Assert.*;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {com.tour.project.Application.class})
@TestPropertySource(locations = "classpath:application-test.properties")
@Transactional
public class TravelPlanDAOTest {
    
    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Before
    public void setUp() {
        MemberDTO testMember = new MemberDTO();
        testMember.setUserId("testplanuser");
        testMember.setUserPassword("testpass");
        testMember.setUserName("Test Plan User");
        testMember.setUserEmail("testplan@example.com");
        testMember.setUserMbti("ISTJ");
        testMember.setUserRegdate(new Timestamp(System.currentTimeMillis()));
        
        memberDAO.insertMember(testMember);
    }
    
    @Test
    public void testTravelPlanCRUD() {
        TravelPlanDTO travelPlan = new TravelPlanDTO();
        travelPlan.setPlanTitle("Test Travel Plan");
        travelPlan.setPlanDestination("Seoul");
        travelPlan.setPlanStartDate(Date.valueOf("2024-06-01"));
        travelPlan.setPlanEndDate(Date.valueOf("2024-06-05"));
        travelPlan.setPlanBudget(500000);
        travelPlan.setPlanContent("This is a test travel plan content");
        travelPlan.setPlanWriter("testplanuser");
        travelPlan.setPlanRegdate(new Timestamp(System.currentTimeMillis()));
        
        int insertResult = travelPlanDAO.insertTravelPlan(travelPlan);
        assertEquals("Insert should affect 1 row", 1, insertResult);
        
        List<TravelPlanDTO> allPlans = travelPlanDAO.getAllTravelPlans();
        assertTrue("Should have at least 1 travel plan", allPlans.size() >= 1);
        
        TravelPlanDTO insertedPlan = allPlans.get(0);
        int planId = insertedPlan.getPlanId();
        
        TravelPlanDTO retrievedPlan = travelPlanDAO.getTravelPlan(planId);
        assertNotNull("Retrieved travel plan should not be null", retrievedPlan);
        assertEquals("Title should match", "Test Travel Plan", retrievedPlan.getPlanTitle());
        assertEquals("Destination should match", "Seoul", retrievedPlan.getPlanDestination());
        assertEquals("Budget should match", Integer.valueOf(500000), retrievedPlan.getPlanBudget());
        assertEquals("Writer should match", "testplanuser", retrievedPlan.getPlanWriter());
        
        retrievedPlan.setPlanTitle("Updated Travel Plan");
        retrievedPlan.setPlanDestination("Busan");
        retrievedPlan.setPlanBudget(700000);
        int updateResult = travelPlanDAO.updateTravelPlan(retrievedPlan);
        assertEquals("Update should affect 1 row", 1, updateResult);
        
        TravelPlanDTO updatedPlan = travelPlanDAO.getTravelPlan(planId);
        assertNotNull("Updated travel plan should not be null", updatedPlan);
        assertEquals("Updated title should match", "Updated Travel Plan", updatedPlan.getPlanTitle());
        assertEquals("Updated destination should match", "Busan", updatedPlan.getPlanDestination());
        assertEquals("Updated budget should match", Integer.valueOf(700000), updatedPlan.getPlanBudget());
        
        int deleteResult = travelPlanDAO.deleteTravelPlan(planId);
        assertEquals("Delete should affect 1 row", 1, deleteResult);
        
        TravelPlanDTO deletedPlan = travelPlanDAO.getTravelPlan(planId);
        assertNull("Travel plan should be null after deletion", deletedPlan);
        
        System.out.println("Travel plan CRUD test completed successfully");
    }
    
    @Test
    public void testGetAllTravelPlans() {
        TravelPlanDTO plan1 = new TravelPlanDTO();
        plan1.setPlanTitle("Plan 1");
        plan1.setPlanDestination("Seoul");
        plan1.setPlanStartDate(Date.valueOf("2024-06-01"));
        plan1.setPlanEndDate(Date.valueOf("2024-06-05"));
        plan1.setPlanBudget(300000);
        plan1.setPlanContent("First test travel plan");
        plan1.setPlanWriter("testplanuser");
        plan1.setPlanRegdate(new Timestamp(System.currentTimeMillis()));
        
        TravelPlanDTO plan2 = new TravelPlanDTO();
        plan2.setPlanTitle("Plan 2");
        plan2.setPlanDestination("Busan");
        plan2.setPlanStartDate(Date.valueOf("2024-07-01"));
        plan2.setPlanEndDate(Date.valueOf("2024-07-03"));
        plan2.setPlanBudget(400000);
        plan2.setPlanContent("Second test travel plan");
        plan2.setPlanWriter("testplanuser");
        plan2.setPlanRegdate(new Timestamp(System.currentTimeMillis() + 1000));
        
        travelPlanDAO.insertTravelPlan(plan1);
        travelPlanDAO.insertTravelPlan(plan2);
        
        List<TravelPlanDTO> allPlans = travelPlanDAO.getAllTravelPlans();
        assertTrue("Should have at least 2 travel plans", allPlans.size() >= 2);
        assertEquals("Most recent plan should be first", "Plan 2", allPlans.get(0).getPlanTitle());
        
        System.out.println("Get all travel plans test completed successfully");
    }
}