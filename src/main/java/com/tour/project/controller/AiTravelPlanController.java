package com.tour.project.controller;

import com.tour.project.dto.AiTravelPlanDTO;
import com.tour.project.dto.ApiResponse;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.SavePlanRequestDTO;
import com.tour.project.dto.TravelPlanSummaryDTO;
import com.tour.project.service.AiTravelPlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

/**
 * AI Travel Plan Controller for saving/loading travel plans
 * Operates separately from existing TravelPlanController, providing AI planner specific APIs
 */
@RestController
@RequestMapping("/api/travel-plans")
public class AiTravelPlanController {
    
    @Autowired
    private AiTravelPlanService aiTravelPlanService;
    
    /**
     * Save AI travel plan
     */
    @PostMapping("/save")
    public ResponseEntity<ApiResponse> savePlan(@RequestBody SavePlanRequestDTO request, HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).body(new ApiResponse(false, "Login required."));
            }
            
            String userId = loginUser.getUserId();
            AiTravelPlanDTO savedPlan = aiTravelPlanService.savePlan(request, userId);
            
            System.out.println("=== AI travel plan saved ===");
            System.out.println("Plan ID: " + savedPlan.getPlanId());
            System.out.println("Title: " + savedPlan.getTitle());
            System.out.println("User ID: " + userId);
            
            return ResponseEntity.ok(new ApiResponse(true, "Plan saved successfully.", savedPlan));
        } catch (Exception e) {
            System.err.println("Error saving AI travel plan: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(new ApiResponse(false, "Error occurred while saving plan: " + e.getMessage()));
        }
    }
    
    /**
     * Get my travel plan list
     */
    @GetMapping("/my-plans")
    public ResponseEntity<?> getMyPlans(HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).body(new ApiResponse(false, "Login required."));
            }
            
            String userId = loginUser.getUserId();
            List<TravelPlanSummaryDTO> plans = aiTravelPlanService.getUserPlans(userId);
            
            System.out.println("=== User plan list retrieval ===");
            System.out.println("User ID: " + userId);
            System.out.println("Plans count: " + plans.size());
            
            return ResponseEntity.ok(plans);
        } catch (Exception e) {
            System.err.println("Error retrieving plan list: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(new ApiResponse(false, "Error occurred while retrieving plans: " + e.getMessage()));
        }
    }
    
    /**
     * Get all user plans (AI 플래너 + 일반 여행 계획 통합)
     */
    @GetMapping("/all-plans")
    public ResponseEntity<?> getAllUserPlans(HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).body(new ApiResponse(false, "Login required."));
            }
            
            String userId = loginUser.getUserId();
            List<TravelPlanSummaryDTO> allPlans = aiTravelPlanService.getAllUserPlans(userId);
            
            System.out.println("=== All user plans retrieval ===");
            System.out.println("User ID: " + userId);
            System.out.println("Total plans count: " + allPlans.size());
            
            return ResponseEntity.ok(allPlans);
        } catch (Exception e) {
            System.err.println("Error retrieving all user plans: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(new ApiResponse(false, "Error occurred while retrieving plans: " + e.getMessage()));
        }
    }
    
    /**
     * Get unified plan details (supports both AI and regular plans)
     */
    @GetMapping("/detail/{planId}")
    public ResponseEntity<?> getUnifiedPlanDetail(
            @PathVariable Long planId, 
            @RequestParam String planType,
            HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).body(new ApiResponse(false, "Login required."));
            }
            
            String userId = loginUser.getUserId();
            Object plan = aiTravelPlanService.getPlanDetailUnified(planId, planType, userId);
            
            System.out.println("=== Unified plan detail retrieval ===");
            System.out.println("Plan ID: " + planId);
            System.out.println("Plan Type: " + planType);
            System.out.println("User ID: " + userId);
            
            return ResponseEntity.ok(plan);
        } catch (Exception e) {
            System.err.println("Error retrieving unified plan details: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(new ApiResponse(false, "Error occurred while retrieving plan: " + e.getMessage()));
        }
    }

    /**
     * Get travel plan details
     */
    @GetMapping("/{planId}")
    public ResponseEntity<?> getPlanDetail(@PathVariable Long planId, HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).body(new ApiResponse(false, "Login required."));
            }
            
            String userId = loginUser.getUserId();
            AiTravelPlanDTO plan = aiTravelPlanService.getPlanDetail(planId, userId);
            
            System.out.println("=== Plan detail retrieval ===");
            System.out.println("Plan ID: " + planId);
            System.out.println("User ID: " + userId);
            System.out.println("Title: " + plan.getTitle());
            
            return ResponseEntity.ok(plan);
        } catch (Exception e) {
            System.err.println("Error retrieving plan details: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(new ApiResponse(false, "Error occurred while retrieving plan: " + e.getMessage()));
        }
    }
    
    /**
     * Delete travel plan
     */
    @DeleteMapping("/{planId}")
    public ResponseEntity<ApiResponse> deletePlan(@PathVariable Long planId, HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).body(new ApiResponse(false, "Login required."));
            }
            
            String userId = loginUser.getUserId();
            aiTravelPlanService.deletePlan(planId, userId);
            
            System.out.println("=== Plan deleted successfully ===");
            System.out.println("Plan ID: " + planId);
            System.out.println("User ID: " + userId);
            
            return ResponseEntity.ok(new ApiResponse(true, "Plan deleted successfully."));
        } catch (Exception e) {
            System.err.println("Error deleting plan: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).body(new ApiResponse(false, "Error occurred while deleting plan: " + e.getMessage()));
        }
    }
    
    /**
     * Search travel plans
     */
    @GetMapping("/search")
    public ResponseEntity<List<TravelPlanSummaryDTO>> searchPlans(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) List<String> tags,
            @RequestParam(required = false) String destination,
            HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).build();
            }
            
            String userId = loginUser.getUserId();
            List<TravelPlanSummaryDTO> plans = aiTravelPlanService.searchUserPlans(userId, keyword, tags, destination);
            
            System.out.println("=== Plan search ===");
            System.out.println("Keyword: " + keyword);
            System.out.println("Tags: " + tags);
            System.out.println("Destination: " + destination);
            System.out.println("Results: " + plans.size());
            
            return ResponseEntity.ok(plans);
        } catch (Exception e) {
            System.err.println("Error searching plans: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }
    
    /**
     * Get template plan list
     */
    @GetMapping("/templates")
    public ResponseEntity<List<TravelPlanSummaryDTO>> getTemplates(@RequestParam(defaultValue = "20") int limit) {
        try {
            List<TravelPlanSummaryDTO> templates = aiTravelPlanService.getTemplateList(limit);
            
            System.out.println("=== Template list retrieval ===");
            System.out.println("Limit: " + limit);
            System.out.println("Templates count: " + templates.size());
            
            return ResponseEntity.ok(templates);
        } catch (Exception e) {
            System.err.println("Error retrieving templates: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }
    
    /**
     * Get popular tags list
     */
    @GetMapping("/popular-tags")
    public ResponseEntity<List<String>> getPopularTags(@RequestParam(defaultValue = "20") int limit) {
        try {
            List<String> tags = aiTravelPlanService.getPopularTags(limit);
            
            System.out.println("=== Popular tags retrieval ===");
            System.out.println("Tags count: " + tags.size());
            
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            System.err.println("Error retrieving popular tags: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }
    
    /**
     * Get user's frequently used tags
     */
    @GetMapping("/my-tags")
    public ResponseEntity<List<String>> getMyFrequentTags(@RequestParam(defaultValue = "10") int limit, HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return ResponseEntity.status(401).build();
            }
            
            String userId = loginUser.getUserId();
            List<String> tags = aiTravelPlanService.getUserFrequentTags(userId, limit);
            
            System.out.println("=== User tags retrieval ===");
            System.out.println("User ID: " + userId);
            System.out.println("Tags count: " + tags.size());
            
            return ResponseEntity.ok(tags);
        } catch (Exception e) {
            System.err.println("Error retrieving user tags: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }
    
}