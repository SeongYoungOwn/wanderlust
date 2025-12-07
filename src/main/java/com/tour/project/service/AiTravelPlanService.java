package com.tour.project.service;

import com.tour.project.dao.AiTravelPlanDAO;
import com.tour.project.dao.PlanTagDAO;
import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dto.AiTravelPlanDTO;
import com.tour.project.dto.SavePlanRequestDTO;
import com.tour.project.dto.TravelPlanDTO;
import com.tour.project.dto.TravelPlanSummaryDTO;
import com.tour.project.util.AiPlanParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Date;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AI Travel Plan save/load service
 */
@Service
public class AiTravelPlanService {
    
    @Autowired
    private AiTravelPlanDAO aiTravelPlanDAO;
    
    @Autowired
    private PlanTagDAO planTagDAO;
    
    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    /**
     * Save AI travel plan with structured data extraction
     */
    @Transactional
    public AiTravelPlanDTO savePlan(SavePlanRequestDTO request, String userId) {
        try {
            // Convert SavePlanRequestDTO to AiTravelPlanDTO
            AiTravelPlanDTO travelPlan = new AiTravelPlanDTO();
            travelPlan.setUserId(userId);
            travelPlan.setTitle(request.getTitle());
            travelPlan.setDestination(request.getDestination());
            
            if (request.getStartDate() != null) {
                travelPlan.setStartDate(Date.valueOf(request.getStartDate()));
            }
            if (request.getEndDate() != null) {
                travelPlan.setEndDate(Date.valueOf(request.getEndDate()));
            }
            
            travelPlan.setDuration(request.getDuration());
            travelPlan.setBudget(request.getBudget());
            travelPlan.setTravelStyle(request.getTravelStyle());
            // JSON 형태로 plan_content 저장 (데이터베이스 JSON 타입 호환)
            String planContent = request.getPlanContent();
            if (planContent != null && !planContent.trim().isEmpty()) {
                try {
                    // 특수문자 및 JSON 호환성을 위한 정리
                    planContent = planContent.trim();
                    // 제어 문자 제거 (0x00-0x1F, 0x7F)
                    planContent = planContent.replaceAll("[\\x00-\\x1F\\x7F]", "");
                    // JSON 이스케이프 처리 - 순서 중요
                    planContent = planContent.replace("\\", "\\\\");  // 백슬래시 먼저
                    planContent = planContent.replace("\"", "\\\"");  // 따옴표
                    planContent = planContent.replace("\r\n", "\\n"); // Windows 줄바꿈
                    planContent = planContent.replace("\n", "\\n");   // Unix 줄바꿈
                    planContent = planContent.replace("\r", "\\n");   // Mac 줄바꿈
                    planContent = planContent.replace("\t", "\\t");   // 탭
                    
                    // JSON 래핑
                    String jsonContent = "{\"content\": \"" + planContent + "\"}";
                    System.out.println("=== JSON Content Debug ===");
                    System.out.println("Original length: " + request.getPlanContent().length());
                    System.out.println("Processed length: " + planContent.length());
                    System.out.println("JSON length: " + jsonContent.length());
                    System.out.println("JSON preview: " + (jsonContent.length() > 200 ? jsonContent.substring(0, 200) + "..." : jsonContent));
                    
                    travelPlan.setPlanContent(jsonContent);
                } catch (Exception e) {
                    System.err.println("Error processing plan content: " + e.getMessage());
                    e.printStackTrace();
                    // 에러 발생 시 기본 JSON 형태로 저장
                    travelPlan.setPlanContent("{\"content\": \"Content processing error\"}");
                }
            } else {
                travelPlan.setPlanContent("{\"content\": \"\"}");
            }
            travelPlan.setChatSessionId(request.getChatSessionId());
            travelPlan.setMemo(request.getMemo());
            travelPlan.setIsTemplate(request.getIsTemplate() != null ? request.getIsTemplate() : false);
            travelPlan.setStatus("draft");
            
            // AI 응답에서 구조화된 정보 추출 및 자동 설정
            if (request.getPlanContent() != null && !request.getPlanContent().trim().isEmpty()) {
                System.out.println("=== AI Plan Parser: Extracting structured data ===");
                System.out.println("Original content length: " + request.getPlanContent().length());
                
                // AiPlanParser를 사용하여 구조화된 정보 추출 및 설정
                AiPlanParser.parseAndSetPlanInfo(request.getPlanContent(), travelPlan);
                
                System.out.println("Extracted title: " + travelPlan.getTitle());
                System.out.println("Extracted destination: " + travelPlan.getDestination());
                System.out.println("Extracted budget: " + travelPlan.getBudget());
                System.out.println("Extracted max participants: " + travelPlan.getMaxParticipants());
                System.out.println("Extracted start date: " + travelPlan.getStartDate());
                System.out.println("Extracted end date: " + travelPlan.getEndDate());
                System.out.println("Extracted duration: " + travelPlan.getDuration());
            }
            
            System.out.println("=== Saving AI travel plan ===");
            System.out.println("User ID: " + userId);
            System.out.println("Title: " + request.getTitle());
            System.out.println("Destination: " + request.getDestination());
            System.out.println("Content length: " + (request.getPlanContent() != null ? request.getPlanContent().length() : 0));
            
            // Save travel plan
            int result = aiTravelPlanDAO.insertAiTravelPlan(travelPlan);
            
            if (result <= 0) {
                throw new RuntimeException("Failed to save travel plan");
            }
            
            System.out.println("Travel plan saved with ID: " + travelPlan.getPlanId());
            
            // Save tags if exists
            if (request.getTags() != null && !request.getTags().isEmpty()) {
                try {
                    int tagResult = planTagDAO.insertPlanTags(travelPlan.getPlanId(), request.getTags());
                    System.out.println("Saved " + request.getTags().size() + " tags");
                } catch (Exception e) {
                    System.err.println("Failed to save tags: " + e.getMessage());
                    // Don't fail the whole operation for tag save failure
                }
            }
            
            return travelPlan;
            
        } catch (Exception e) {
            System.err.println("Error in savePlan: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to save travel plan: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get user travel plan list
     */
    public List<TravelPlanSummaryDTO> getUserPlans(String userId) {
        try {
            System.out.println("=== Getting user plans ===");
            System.out.println("User ID: " + userId);
            
            List<TravelPlanSummaryDTO> plans = aiTravelPlanDAO.getUserTravelPlans(userId);
            
            // Load tags for each plan and set plan type
            for (TravelPlanSummaryDTO plan : plans) {
                List<String> tags = planTagDAO.getPlanTags(plan.getPlanId());
                plan.setTags(tags);
                plan.setPlanType("AI_PLANNER"); // All plans from this endpoint are AI Planner plans
            }
            
            System.out.println("Found " + plans.size() + " plans for user");
            return plans;
            
        } catch (Exception e) {
            System.err.println("Error getting user plans: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get user plans: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get travel plan details
     */
    public AiTravelPlanDTO getPlanDetail(Long planId, String userId) {
        try {
            System.out.println("=== Getting plan detail ===");
            System.out.println("Plan ID: " + planId);
            System.out.println("User ID: " + userId);
            
            // Check ownership
            if (!aiTravelPlanDAO.isOwner(planId, userId)) {
                throw new RuntimeException("Access denied: Not the plan owner");
            }
            
            AiTravelPlanDTO plan = aiTravelPlanDAO.getAiTravelPlan(planId);
            if (plan == null) {
                throw new RuntimeException("Plan not found");
            }
            
            // Load tags
            List<String> tags = planTagDAO.getPlanTags(planId);
            plan.setTags(tags);
            
            System.out.println("Found plan: " + plan.getTitle());
            return plan;
            
        } catch (Exception e) {
            System.err.println("Error getting plan detail: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get plan detail: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get plan details (supports both AI planner and regular travel plans)
     */
    public Object getPlanDetailUnified(Long planId, String planType, String userId) {
        try {
            System.out.println("=== Getting unified plan detail ===");
            System.out.println("Plan ID: " + planId);
            System.out.println("Plan Type: " + planType);
            System.out.println("User ID: " + userId);
            
            if ("AI_PLANNER".equals(planType)) {
                // AI 플래너 계획 처리
                if (!aiTravelPlanDAO.isOwner(planId, userId)) {
                    throw new RuntimeException("Access denied: Not the plan owner");
                }
                
                AiTravelPlanDTO plan = aiTravelPlanDAO.getAiTravelPlan(planId);
                if (plan == null) {
                    throw new RuntimeException("AI plan not found");
                }
                
                // Load tags
                List<String> tags = planTagDAO.getPlanTags(planId);
                plan.setTags(tags);
                
                System.out.println("Found AI plan: " + plan.getTitle());
                return plan;
                
            } else if ("REGULAR".equals(planType)) {
                // 일반 여행 계획 처리
                TravelPlanDTO regularPlan = travelPlanDAO.getTravelPlan(planId.intValue());
                if (regularPlan == null) {
                    throw new RuntimeException("Regular plan not found");
                }
                
                // 작성자 확인
                if (!userId.equals(regularPlan.getPlanWriter())) {
                    throw new RuntimeException("Access denied: Not the plan owner");
                }
                
                System.out.println("Found regular plan: " + regularPlan.getPlanTitle());
                return regularPlan;
                
            } else {
                throw new RuntimeException("Invalid plan type: " + planType);
            }
            
        } catch (Exception e) {
            System.err.println("Error getting unified plan detail: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get plan detail: " + e.getMessage(), e);
        }
    }
    
    /**
     * Delete travel plan
     */
    @Transactional
    public void deletePlan(Long planId, String userId) {
        try {
            System.out.println("=== Deleting plan ===");
            System.out.println("Plan ID: " + planId);
            System.out.println("User ID: " + userId);
            
            // Check ownership
            if (!aiTravelPlanDAO.isOwner(planId, userId)) {
                throw new RuntimeException("Access denied: Not the plan owner");
            }
            
            // Delete tags first
            planTagDAO.deletePlanTags(planId);
            
            // Delete plan
            int result = aiTravelPlanDAO.deleteAiTravelPlan(planId, userId);
            if (result <= 0) {
                throw new RuntimeException("Failed to delete travel plan");
            }
            
            System.out.println("Plan deleted successfully");
            
        } catch (Exception e) {
            System.err.println("Error deleting plan: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to delete plan: " + e.getMessage(), e);
        }
    }
    
    /**
     * Search user travel plans
     */
    public List<TravelPlanSummaryDTO> searchUserPlans(String userId, String keyword, List<String> tags, String destination) {
        try {
            System.out.println("=== Searching user plans ===");
            System.out.println("User ID: " + userId);
            System.out.println("Keyword: " + keyword);
            System.out.println("Tags: " + tags);
            System.out.println("Destination: " + destination);
            
            Map<String, Object> params = new HashMap<>();
            params.put("userId", userId);
            params.put("keyword", keyword);
            params.put("tags", tags);
            params.put("destination", destination);
            
            List<TravelPlanSummaryDTO> plans = aiTravelPlanDAO.searchUserPlans(params);
            
            // Load tags for each plan
            for (TravelPlanSummaryDTO plan : plans) {
                List<String> planTags = planTagDAO.getPlanTags(plan.getPlanId());
                plan.setTags(planTags);
            }
            
            System.out.println("Found " + plans.size() + " matching plans");
            return plans;
            
        } catch (Exception e) {
            System.err.println("Error searching plans: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to search plans: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get template plan list
     */
    public List<TravelPlanSummaryDTO> getTemplateList(int limit) {
        try {
            System.out.println("=== Getting template list ===");
            System.out.println("Limit: " + limit);
            
            Map<String, Object> params = new HashMap<>();
            params.put("limit", limit);
            List<TravelPlanSummaryDTO> templates = aiTravelPlanDAO.getTemplateList(params);
            
            // Load tags for each template
            for (TravelPlanSummaryDTO template : templates) {
                List<String> tags = planTagDAO.getPlanTags(template.getPlanId());
                template.setTags(tags);
            }
            
            System.out.println("Found " + templates.size() + " templates");
            return templates;
            
        } catch (Exception e) {
            System.err.println("Error getting templates: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get templates: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get popular tags
     */
    public List<String> getPopularTags(int limit) {
        try {
            System.out.println("=== Getting popular tags ===");
            System.out.println("Limit: " + limit);
            
            List<String> tags = planTagDAO.getPopularTags(limit);
            
            System.out.println("Found " + tags.size() + " popular tags");
            return tags;
            
        } catch (Exception e) {
            System.err.println("Error getting popular tags: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get popular tags: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get user's frequently used tags
     */
    public List<String> getUserFrequentTags(String userId, int limit) {
        try {
            System.out.println("=== Getting user frequent tags ===");
            System.out.println("User ID: " + userId);
            System.out.println("Limit: " + limit);
            
            List<String> tags = planTagDAO.getUserFrequentTags(userId, limit);
            
            System.out.println("Found " + tags.size() + " frequent tags for user");
            return tags;
            
        } catch (Exception e) {
            System.err.println("Error getting user frequent tags: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get user frequent tags: " + e.getMessage(), e);
        }
    }
    
    /**
     * Get all user plans (AI 플래너 + 일반 여행 계획 통합)
     */
    public List<TravelPlanSummaryDTO> getAllUserPlans(String userId) {
        try {
            System.out.println("=== Getting all user plans ===");
            System.out.println("User ID: " + userId);
            
            // 1. AI 플래너에서 저장된 계획들 가져오기
            List<TravelPlanSummaryDTO> aiPlans = aiTravelPlanDAO.getUserTravelPlans(userId);
            
            // AI 플래너 계획들의 태그 정보 추가
            for (TravelPlanSummaryDTO plan : aiPlans) {
                List<String> tags = planTagDAO.getPlanTags(plan.getPlanId());
                plan.setTags(tags);
                // AI 플래너 계획임을 표시
                plan.setPlanType("AI_PLANNER");
            }
            
            // 2. 일반 여행 계획들 가져오기 (TravelPlanDAO에서)
            List<TravelPlanDTO> regularPlans = travelPlanDAO.getTravelPlansByWriter(userId);
            
            // 일반 여행 계획을 TravelPlanSummaryDTO로 변환
            for (TravelPlanDTO regularPlan : regularPlans) {
                TravelPlanSummaryDTO summaryDTO = new TravelPlanSummaryDTO();
                summaryDTO.setPlanId(Long.valueOf(regularPlan.getPlanId()));
                summaryDTO.setTitle(regularPlan.getPlanTitle());
                summaryDTO.setDestination(regularPlan.getPlanDestination());
                // Integer를 BigDecimal로 변환
                if (regularPlan.getPlanBudget() != null) {
                    summaryDTO.setBudget(new BigDecimal(regularPlan.getPlanBudget()));
                }
                // Timestamp를 LocalDateTime으로 변환
                if (regularPlan.getPlanRegdate() != null) {
                    summaryDTO.setCreatedAt(regularPlan.getPlanRegdate().toLocalDateTime());
                }
                summaryDTO.setStatus("completed"); // 일반 계획은 completed로 설정
                summaryDTO.setIsTemplate(false);
                summaryDTO.setPlanType("REGULAR"); // 일반 계획임을 표시
                
                // 일반 계획의 태그 처리 (planTags 필드에서)
                if (regularPlan.getPlanTags() != null && !regularPlan.getPlanTags().isEmpty()) {
                    String[] tagsArray = regularPlan.getPlanTags().split(",");
                    List<String> tagsList = new ArrayList<>();
                    for (String tag : tagsArray) {
                        tagsList.add(tag.trim());
                    }
                    summaryDTO.setTags(tagsList);
                }
                
                aiPlans.add(summaryDTO);
            }
            
            // 3. 생성일 기준으로 정렬 (최신순)
            aiPlans.sort((a, b) -> {
                if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                if (a.getCreatedAt() == null) return 1;
                if (b.getCreatedAt() == null) return -1;
                return b.getCreatedAt().compareTo(a.getCreatedAt());
            });
            
            System.out.println("AI Plans: " + aiPlans.stream().filter(p -> "AI_PLANNER".equals(p.getPlanType())).count());
            System.out.println("Regular Plans: " + aiPlans.stream().filter(p -> "REGULAR".equals(p.getPlanType())).count());
            System.out.println("Total Plans: " + aiPlans.size());
            
            return aiPlans;
            
        } catch (Exception e) {
            System.err.println("Error getting all user plans: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to get all user plans: " + e.getMessage(), e);
        }
    }
}