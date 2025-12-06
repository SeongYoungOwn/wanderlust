package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.TravelDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dao.FavoriteDAO;
import com.tour.project.dao.TravelJoinRequestDAO;
import com.tour.project.dao.MannerEvaluationDAO;
import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dto.TravelPlanDTO;
import com.tour.project.dto.TravelParticipantDTO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.UserMannerStatsDTO;
import com.tour.project.dto.UserTravelMbtiDTO;
import com.tour.project.service.AdvancedTravelMatchingService;
import com.tour.project.service.RecommendationFeedbackProcessor;
import com.tour.project.service.BadgeService;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/travel")
public class TravelPlanController {

    @Value("${upload.path}")
    private String uploadPath;

    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private TravelDAO travelDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private FavoriteDAO favoriteDAO;
    
    @Autowired
    private TravelJoinRequestDAO travelJoinRequestDAO;
    
    @Autowired
    private MannerEvaluationDAO mannerEvaluationDAO;
    
    @Autowired
    private TravelMbtiDAO travelMbtiDAO;
    
    @Autowired
    private AdvancedTravelMatchingService advancedMatchingService;
    
    @Autowired
    private RecommendationFeedbackProcessor feedbackProcessor;
    
    @Autowired
    private BadgeService badgeService;
    
    
    // 여행 계획 목록
    @RequestMapping(value = "/list", method = RequestMethod.GET) 
    public String list(@RequestParam(required = false) String searchType,
                      @RequestParam(required = false) String searchKeyword,
                      @RequestParam(required = false) String tags,
                      @RequestParam(required = false) String sortBy,
                      Model model, HttpSession session) {
        
        System.out.println("=== 여행 계획 목록 요청 ===");
        System.out.println("searchType: " + searchType);
        System.out.println("searchKeyword: " + searchKeyword); 
        System.out.println("tags: " + tags);
        System.out.println("sortBy: " + sortBy);
        
        try {
            // 검색 및 정렬 파라미터 구성
            Map<String, Object> params = new HashMap<>();
            
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                params.put("searchType", searchType != null ? searchType : "all");
                params.put("searchKeyword", searchKeyword.trim());
            }
            
            if (sortBy != null && !sortBy.isEmpty()) {
                params.put("sortType", sortBy);
            }
            
            List<TravelPlanDTO> travelPlans;
            
            // 모든 목록 조회 (페이징 없음)
            travelPlans = travelPlanDAO.getAllTravelPlans(params);
            
            System.out.println("=== 목록 조회 결과 ===");
            System.out.println("조회된 여행 계획 수: " + (travelPlans != null ? travelPlans.size() : 0));
            
            // 로그인한 사용자 정보
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            
            // 각 여행 계획의 참여자 수, 작성자 정보, 현재 사용자의 참여 상태 확인
            Map<String, UserMannerStatsDTO> writerMannerStats = new HashMap<>();
            Map<String, UserTravelMbtiDTO> writerMbtiStats = new HashMap<>();
            Map<String, MemberDTO> writerInfo = new HashMap<>();
            
            for (TravelPlanDTO plan : travelPlans) {
                try {
                    int participantCount = travelDAO.getParticipantCount(Long.valueOf(plan.getPlanId()));
                    plan.setParticipantCount(participantCount);
                    
                    // 작성자 정보 조회 (매너온도와 MBTI)
                    String writerId = plan.getPlanWriter();
                    if (writerId != null && !writerMannerStats.containsKey(writerId)) {
                        try {
                            // 작성자 기본 정보
                            MemberDTO writer = memberDAO.getMember(writerId);
                            if (writer != null) {
                                writerInfo.put(writerId, writer);
                            }
                            
                            // 작성자 매너온도
                            UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(writerId);
                            if (mannerStats == null) {
                                mannerStats = new UserMannerStatsDTO(writerId);
                            }
                            writerMannerStats.put(writerId, mannerStats);
                            
                            // 작성자 MBTI
                            UserTravelMbtiDTO mbtiInfo = travelMbtiDAO.getLatestUserMbti(writerId);
                            if (mbtiInfo != null) {
                                writerMbtiStats.put(writerId, mbtiInfo);
                            }
                        } catch (Exception e) {
                            System.err.println("작성자 " + writerId + " 정보 조회 실패: " + e.getMessage());
                            writerMannerStats.put(writerId, new UserMannerStatsDTO(writerId));
                        }
                    }
                    
                    if (loginUser != null) {
                        // 기존 참여 여부 (하위 호환성)
                        boolean isJoined = travelDAO.isUserJoined(Long.valueOf(plan.getPlanId()), loginUser.getUserId());
                        plan.setUserJoined(isJoined);
                        
                        // 승인된 동행자인지 확인
                        boolean isApproved = travelJoinRequestDAO.isApprovedForTravel(plan.getPlanId(), loginUser.getUserId());
                        plan.setUserApproved(isApproved);
                        
                        // 신청 대기 중인지 확인
                        boolean isPending = travelJoinRequestDAO.isAlreadyRequested(plan.getPlanId(), loginUser.getUserId()) && !isApproved;
                        plan.setUserRequestPending(isPending);
                        
                        // 찜하기 여부 확인
                        boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "TRAVEL_PLAN", plan.getPlanId());
                        plan.setFavorite(isFavorite);
                    }
                } catch (Exception participantException) {
                    // 참여자 정보 조회 실패 시 기본값 설정
                    plan.setParticipantCount(0);
                    plan.setUserJoined(false);
                    plan.setUserApproved(false);
                    plan.setUserRequestPending(false);
                }
            }
            
            // 모델에 데이터 추가
            model.addAttribute("travelPlans", travelPlans);
            model.addAttribute("writerInfo", writerInfo);
            model.addAttribute("writerMannerStats", writerMannerStats);
            model.addAttribute("writerMbtiStats", writerMbtiStats);
            
            // 검색 파라미터 유지
            model.addAttribute("searchType", searchType);
            model.addAttribute("searchKeyword", searchKeyword);
            model.addAttribute("sortBy", sortBy);
            
        } catch (Exception e) {
            model.addAttribute("error", "여행 계획을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            model.addAttribute("travelPlans", java.util.Collections.emptyList());
            model.addAttribute("currentPage", 1);
            model.addAttribute("totalPages", 1);
            model.addAttribute("totalCount", 0);
        }
        return "travel/list";
    }
    
    // 여행 계획 작성 폼
    @RequestMapping(value = "/create", method = RequestMethod.GET)
    public String createForm(@RequestParam(value = "from", required = false) String from,
                             HttpSession session, 
                             Model model,
                             RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        // AI 추천 데이터가 있는 경우 처리
        if ("ai".equals(from)) {
            @SuppressWarnings("unchecked")
            Map<String, Object> aiRecommendation = (Map<String, Object>) session.getAttribute("aiRecommendation");
            
            if (aiRecommendation != null) {
                model.addAttribute("aiData", aiRecommendation);
                System.out.println("AI 추천 데이터를 create 페이지로 전달: " + aiRecommendation);
            }
        }
        
        return "travel/create";
    }
    
    // 여행 계획 작성 처리
    @RequestMapping(value = "/create", method = RequestMethod.POST)
    public String create(@RequestParam(value = "planTitle", required = true) String planTitle,
                        @RequestParam(value = "planDestination", required = true) String planDestination,
                        @RequestParam(value = "planStartDate", required = true) String planStartDate,
                        @RequestParam(value = "planEndDate", required = true) String planEndDate,
                        @RequestParam(value = "planBudget", required = false) Integer planBudget,
                        @RequestParam(value = "maxParticipants", required = true) Integer maxParticipants,
                        @RequestParam(value = "planContent", required = false) String planContent,
                        @RequestParam(value = "planTags", required = false) String[] planTags,
                        @RequestParam(value = "planImage", required = false) org.springframework.web.multipart.MultipartFile imageFile,
                        HttpSession session, RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            TravelPlanDTO travelPlan = new TravelPlanDTO();
            travelPlan.setPlanTitle(planTitle);
            travelPlan.setPlanDestination(planDestination);
            travelPlan.setPlanStartDate(java.sql.Date.valueOf(planStartDate));
            travelPlan.setPlanEndDate(java.sql.Date.valueOf(planEndDate));
            travelPlan.setPlanBudget(planBudget != null ? planBudget : 0);
            travelPlan.setMaxParticipants(maxParticipants != null ? maxParticipants : 6);
            travelPlan.setPlanContent(planContent);
            travelPlan.setPlanWriter(loginUser.getUserId());
            
            // 태그 처리 - 배열을 쉼표로 구분된 문자열로 변환
            if (planTags != null && planTags.length > 0) {
                String tagsString = String.join(",", planTags);
                travelPlan.setPlanTags(tagsString);
            } else {
                travelPlan.setPlanTags(null);
            }
            
            // 이미지 업로드 처리
            if (imageFile != null && !imageFile.isEmpty()) {
                // 업로드 디렉토리 설정 (application.properties에서 주입)
                java.io.File uploadDir = new java.io.File(this.uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                String originalFilename = imageFile.getOriginalFilename();
                String extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();

                // 파일 확장자 검증
                if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)$")) {
                    redirectAttributes.addFlashAttribute("error", "이미지 파일만 업로드 가능합니다.");
                    return "redirect:/travel/create";
                }

                // 파일 크기 검증 (10MB)
                if (imageFile.getSize() > 10 * 1024 * 1024) {
                    redirectAttributes.addFlashAttribute("error", "파일 크기는 10MB를 초과할 수 없습니다.");
                    return "redirect:/travel/create";
                }

                // 고유한 파일명 생성
                String newFilename = java.util.UUID.randomUUID().toString() + extension;
                java.nio.file.Path filePath = java.nio.file.Paths.get(this.uploadPath, newFilename);
                
                // 파일 저장
                java.nio.file.Files.copy(imageFile.getInputStream(), filePath);
                travelPlan.setPlanImage(newFilename);

                System.out.println("=== 여행 이미지 업로드 성공 ===");
                System.out.println("저장 경로: " + uploadDir.getAbsolutePath());
                System.out.println("파일명: " + newFilename);
            }
            
            System.out.println("=== 여행 계획 등록 시도 ===");
            System.out.println("제목: " + travelPlan.getPlanTitle());
            System.out.println("목적지: " + travelPlan.getPlanDestination());
            System.out.println("시작일: " + travelPlan.getPlanStartDate());
            System.out.println("종료일: " + travelPlan.getPlanEndDate());
            System.out.println("예산: " + travelPlan.getPlanBudget());
            System.out.println("태그: " + travelPlan.getPlanTags());
            System.out.println("이미지: " + travelPlan.getPlanImage());
            System.out.println("작성자: " + travelPlan.getPlanWriter());
            
            int result = travelPlanDAO.insertTravelPlan(travelPlan);
            
            if (result > 0) {
                // 여행 계획 작성 성공 후 뱃지 체크
                try {
                    badgeService.checkAndAwardBadges(loginUser.getUserId());
                } catch (Exception e) {
                    System.err.println("뱃지 체크 중 오류 발생: " + e.getMessage());
                }
                
                redirectAttributes.addFlashAttribute("success", "여행 계획이 등록되었습니다.");
                return "redirect:/travel/list";
            } else {
                redirectAttributes.addFlashAttribute("error", "여행 계획 등록에 실패했습니다.");
                return "redirect:/travel/create";
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "여행 계획 등록 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/travel/create";
        }
    }
    
    // 여행 계획 상세보기
    @RequestMapping(value = "/detail/{planId}", method = RequestMethod.GET)
    public String detail(@PathVariable int planId, @RequestParam(required = false) String error, 
                        Model model, HttpSession session, RedirectAttributes redirectAttributes) {
        try {
            System.out.println("=== 여행 계획 상세보기 요청 ===");
            System.out.println("planId: " + planId);
            
            // 에러 메시지 처리
            if ("notCompleted".equals(error)) {
                model.addAttribute("error", "아직 완료되지 않은 여행입니다. 매너 평가는 여행 완료 후에 가능합니다.");
            } else if ("noEvaluatableUsers".equals(error)) {
                model.addAttribute("error", "평가할 수 있는 동행자가 없습니다.");
            }
            
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            System.out.println("조회된 여행 계획: " + (travelPlan != null ? "정상" : "null"));
            if (travelPlan != null) {
                System.out.println("여행 계획 제목: " + travelPlan.getPlanTitle());
                System.out.println("조회수: " + travelPlan.getPlanViewCount());
                System.out.println("찜한 횟수: " + travelPlan.getFavoriteCount());
            }
            
            if (travelPlan == null) {
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 여행 계획입니다.");
                return "redirect:/travel/list";
            }
            
            // 조회수 증가
            try {
                travelPlanDAO.increaseViewCount(planId);
                System.out.println("여행 계획 " + planId + " 조회수 증가");
            } catch (Exception e) {
                System.err.println("조회수 증가 실패: " + e.getMessage());
            }
            
            // 작성자 정보 추가
            MemberDTO writer = null;
            UserMannerStatsDTO writerMannerStats = null;
            UserTravelMbtiDTO writerMbti = null;
            try {
                // plan_writer가 null이 아닌지 체크
                if (travelPlan.getPlanWriter() != null && !travelPlan.getPlanWriter().trim().isEmpty()) {
                    writer = memberDAO.getMember(travelPlan.getPlanWriter());

                    // writer가 null인 경우 처리
                    if (writer == null) {
                        writer = new MemberDTO();
                        writer.setUserId(travelPlan.getPlanWriter());
                        writer.setUserName("탈퇴한 사용자");
                    }

                    // 작성자 매너 정보 조회
                    try {
                        writerMannerStats = mannerEvaluationDAO.getUserMannerStats(travelPlan.getPlanWriter());
                        if (writerMannerStats == null) {
                            writerMannerStats = new UserMannerStatsDTO(travelPlan.getPlanWriter());
                        }
                    } catch (Exception mannerException) {
                        System.err.println("작성자 매너 정보 조회 실패: " + mannerException.getMessage());
                        writerMannerStats = new UserMannerStatsDTO(travelPlan.getPlanWriter());
                    }

                    // 작성자 MBTI 정보 조회
                    try {
                        writerMbti = travelMbtiDAO.getLatestUserMbti(travelPlan.getPlanWriter());
                    } catch (Exception mbtiException) {
                        System.err.println("작성자 MBTI 정보 조회 실패: " + mbtiException.getMessage());
                        writerMbti = null;
                    }
                } else {
                    // plan_writer가 null이거나 비어있는 경우
                    writer = new MemberDTO();
                    writer.setUserId("unknown");
                    writer.setUserName("알 수 없음");
                    writerMannerStats = new UserMannerStatsDTO("unknown");
                    writerMbti = null;
                }
            } catch (Exception e) {
                System.err.println("작성자 정보 조회 중 오류 발생: " + e.getMessage());
                e.printStackTrace();
                // 작성자 정보가 없어도 상세보기는 표시
                writer = new MemberDTO();
                writer.setUserId(travelPlan.getPlanWriter() != null ? travelPlan.getPlanWriter() : "unknown");
                writer.setUserName("알 수 없음");
                writerMannerStats = new UserMannerStatsDTO(travelPlan.getPlanWriter() != null ? travelPlan.getPlanWriter() : "unknown");
                writerMbti = null;
            }
            
            // 참여자 목록 조회
            List<TravelParticipantDTO> participants = java.util.Collections.emptyList();
            int participantCount = 0;
            boolean userJoined = false;
            boolean userApproved = false;
            boolean userRequestPending = false;
            boolean userFavorite = false;
            Map<String, UserMannerStatsDTO> participantMannerStats = new HashMap<>();
            Map<String, UserTravelMbtiDTO> participantMbtiStats = new HashMap<>();
            
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            
            try {
                participants = travelDAO.getParticipantsByTravelId(Long.valueOf(planId));
                participantCount = travelDAO.getParticipantCount(Long.valueOf(planId));
                
                // 참여자들의 매너 정보와 MBTI 정보 조회
                for (TravelParticipantDTO participant : participants) {
                    try {
                        // 매너 정보 조회
                        UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(participant.getUserId());
                        if (mannerStats == null) {
                            mannerStats = new UserMannerStatsDTO(participant.getUserId());
                        }
                        participantMannerStats.put(participant.getUserId(), mannerStats);
                        
                        // MBTI 정보 조회
                        UserTravelMbtiDTO mbtiInfo = travelMbtiDAO.getLatestUserMbti(participant.getUserId());
                        if (mbtiInfo != null) {
                            participantMbtiStats.put(participant.getUserId(), mbtiInfo);
                        }
                    } catch (Exception e) {
                        System.err.println("참여자 " + participant.getUserId() + "의 정보 조회 실패: " + e.getMessage());
                        participantMannerStats.put(participant.getUserId(), new UserMannerStatsDTO(participant.getUserId()));
                    }
                }
                
                if (loginUser != null) {
                    // 기존 참여자 테이블 체크 (하위 호환성)
                    userJoined = travelDAO.isUserJoined(Long.valueOf(planId), loginUser.getUserId());
                    
                    // 승인된 동행자인지 확인
                    userApproved = travelJoinRequestDAO.isApprovedForTravel(planId, loginUser.getUserId());
                    
                    // 신청 대기 중인지 확인
                    userRequestPending = travelJoinRequestDAO.isAlreadyRequested(planId, loginUser.getUserId()) && !userApproved;
                    
                    userFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
                }
                
                System.out.println("참여자 목록 조회 완료: " + participants.size() + "명");
                System.out.println("참여자 수: " + participantCount);
                System.out.println("사용자 참여 여부 (기존): " + userJoined);
                System.out.println("사용자 승인 여부: " + userApproved);
                System.out.println("사용자 신청 대기 중: " + userRequestPending);
                System.out.println("사용자 찜하기 여부: " + userFavorite);
            } catch (Exception e) {
                System.err.println("참여자 정보 조회 중 오류: " + e.getMessage());
                e.printStackTrace();
            }
            
            model.addAttribute("travelPlan", travelPlan);
            model.addAttribute("writer", writer);
            model.addAttribute("writerMannerStats", writerMannerStats);
            model.addAttribute("writerMbti", writerMbti);
            model.addAttribute("participants", participants);
            model.addAttribute("participantMannerStats", participantMannerStats);
            model.addAttribute("participantMbtiStats", participantMbtiStats);
            model.addAttribute("participantCount", participantCount);
            model.addAttribute("userJoined", userJoined);
            model.addAttribute("userApproved", userApproved);
            model.addAttribute("userRequestPending", userRequestPending);
            model.addAttribute("userFavorite", userFavorite);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "여행 계획을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/travel/list";
        }
        
        return "travel/detail";
    }
    
    // 여행 계획 수정 폼
    @RequestMapping(value = "/edit/{planId}", method = RequestMethod.GET)
    public String editForm(@PathVariable int planId, HttpSession session, Model model,
                          RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            
            // 작성자 확인
            if (!travelPlan.getPlanWriter().equals(loginUser.getUserId())) {
                redirectAttributes.addFlashAttribute("error", "수정 권한이 없습니다.");
                return "redirect:/travel/detail/" + planId;
            }
            
            model.addAttribute("travelPlan", travelPlan);
            
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "여행 계획을 불러오는 중 오류가 발생했습니다.");
            return "redirect:/travel/list";
        }
        
        return "travel/edit";
    }
    
    // 여행 계획 수정 처리
    @RequestMapping(value = "/edit/{planId}", method = RequestMethod.POST)
    public String edit(@PathVariable int planId, 
                      @RequestParam(value = "planTitle", required = true) String planTitle,
                      @RequestParam(value = "planDestination", required = true) String planDestination,
                      @RequestParam(value = "planStartDate", required = true) String planStartDate,
                      @RequestParam(value = "planEndDate", required = true) String planEndDate,
                      @RequestParam(value = "planBudget", required = false) Integer planBudget,
                      @RequestParam(value = "maxParticipants", required = true) Integer maxParticipants,
                      @RequestParam(value = "planContent", required = false) String planContent,
                      @RequestParam(value = "planTags", required = false) String[] planTags,
                      HttpSession session, RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            // 기존 계획 확인
            TravelPlanDTO existingPlan = travelPlanDAO.getTravelPlan(planId);
            
            // 작성자 확인
            if (!existingPlan.getPlanWriter().equals(loginUser.getUserId())) {
                redirectAttributes.addFlashAttribute("error", "수정 권한이 없습니다.");
                return "redirect:/travel/detail/" + planId;
            }
            
            // TravelPlanDTO 객체 생성 및 설정
            TravelPlanDTO travelPlan = new TravelPlanDTO();
            travelPlan.setPlanId(planId);
            travelPlan.setPlanTitle(planTitle);
            travelPlan.setPlanDestination(planDestination);
            travelPlan.setPlanStartDate(java.sql.Date.valueOf(planStartDate));
            travelPlan.setPlanEndDate(java.sql.Date.valueOf(planEndDate));
            travelPlan.setPlanBudget(planBudget != null ? planBudget : 0);
            travelPlan.setMaxParticipants(maxParticipants != null ? maxParticipants : 6);
            travelPlan.setPlanContent(planContent);
            travelPlan.setPlanWriter(loginUser.getUserId());
            
            // 태그 처리 - 배열을 쉼표로 구분된 문자열로 변환
            if (planTags != null && planTags.length > 0) {
                String tagsString = String.join(",", planTags);
                travelPlan.setPlanTags(tagsString);
            } else {
                travelPlan.setPlanTags(null);
            }
            
            System.out.println("=== 여행 계획 수정 시도 ===");
            System.out.println("제목: " + travelPlan.getPlanTitle());
            System.out.println("목적지: " + travelPlan.getPlanDestination());
            System.out.println("시작일: " + travelPlan.getPlanStartDate());
            System.out.println("종료일: " + travelPlan.getPlanEndDate());
            System.out.println("예산: " + travelPlan.getPlanBudget());
            System.out.println("태그: " + travelPlan.getPlanTags());
            
            int result = travelPlanDAO.updateTravelPlan(travelPlan);
            
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "여행 계획이 수정되었습니다.");
                return "redirect:/travel/detail/" + planId;
            } else {
                redirectAttributes.addFlashAttribute("error", "여행 계획 수정에 실패했습니다.");
                return "redirect:/travel/edit/" + planId;
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "여행 계획 수정 중 오류가 발생했습니다.");
            return "redirect:/travel/edit/" + planId;
        }
    }
    
    // 여행 계획 삭제
    @RequestMapping(value = "/delete/{planId}", method = RequestMethod.POST)
    public String delete(@PathVariable int planId, HttpSession session,
                        RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }

        try {
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);

            // 작성자 또는 관리자 확인
            boolean isWriter = travelPlan.getPlanWriter().equals(loginUser.getUserId());
            boolean isAdmin = "ADMIN".equals(loginUser.getUserRole());

            if (!isWriter && !isAdmin) {
                redirectAttributes.addFlashAttribute("error", "삭제 권한이 없습니다.");
                return "redirect:/travel/detail/" + planId;
            }

            int result = travelPlanDAO.deleteTravelPlan(planId);

            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "여행 계획이 삭제되었습니다.");
                return "redirect:/travel/list";
            } else {
                redirectAttributes.addFlashAttribute("error", "여행 계획 삭제에 실패했습니다.");
                return "redirect:/travel/detail/" + planId;
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "여행 계획 삭제 중 오류가 발생했습니다.");
            return "redirect:/travel/detail/" + planId;
        }
    }
    
    // 내 여행 계획 목록
    @RequestMapping(value = "/my", method = RequestMethod.GET)
    public String myTravelPlans(HttpSession session, Model model,
                               RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        try {
            List<TravelPlanDTO> myPlans = travelPlanDAO.getTravelPlansByWriter(loginUser.getUserId());
            model.addAttribute("travelPlans", myPlans);
            model.addAttribute("isMyPlans", true);
        } catch (Exception e) {
            model.addAttribute("error", "여행 계획을 불러오는 중 오류가 발생했습니다.");
        }
        
        return "travel/list";
    }
    
    // 여행 참여하기
    @RequestMapping(value = "/join/{planId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> joinTravel(@PathVariable int planId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 여행 참여 처리 시작 ===");
            System.out.println("planId: " + planId);
            System.out.println("userId: " + loginUser.getUserId());
            
            // 여행 계획 존재 확인
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                System.out.println("여행 계획이 존재하지 않음");
                result.put("success", false);
                result.put("message", "존재하지 않는 여행 계획입니다.");
                return result;
            }
            System.out.println("여행 계획 확인 완료: " + travelPlan.getPlanTitle());
            
            // 자신의 여행 계획에는 참여할 수 없음
            if (travelPlan.getPlanWriter().equals(loginUser.getUserId())) {
                System.out.println("작성자는 본인 여행에 참여할 수 없음");
                result.put("success", false);
                result.put("message", "본인이 작성한 여행 계획에는 참여할 수 없습니다.");
                return result;
            }
            
            // 이미 참여했는지 확인
            boolean alreadyJoined = travelDAO.isUserJoined(Long.valueOf(planId), loginUser.getUserId());
            if (alreadyJoined) {
                System.out.println("이미 참여한 여행");
                result.put("success", false);
                result.put("message", "이미 참여한 여행 계획입니다.");
                return result;
            }
            
            // 여행 참여 처리
            int joinResult = travelDAO.joinTravel(Long.valueOf(planId), loginUser.getUserId());
            System.out.println("참여 처리 결과: " + joinResult);
            
            if (joinResult > 0) {
                result.put("success", true);
                result.put("message", "여행 계획에 성공적으로 참여했습니다.");
                
                // 참여자 수 업데이트된 정보 반환
                int updatedCount = travelDAO.getParticipantCount(Long.valueOf(planId));
                result.put("participantCount", updatedCount);
            } else {
                result.put("success", false);
                result.put("message", "여행 계획 참여에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("전체 참여 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "참여 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 여행 참여 취소
    @RequestMapping(value = "/leave/{planId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> leaveTravel(@PathVariable int planId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 여행 참여 취소 처리 시작 ===");
            System.out.println("planId: " + planId);
            System.out.println("userId: " + loginUser.getUserId());
            
            // 여행 계획 존재 확인
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                System.out.println("여행 계획이 존재하지 않음");
                result.put("success", false);
                result.put("message", "존재하지 않는 여행 계획입니다.");
                return result;
            }
            
            // 참여 여부 확인
            boolean isJoined = travelDAO.isUserJoined(Long.valueOf(planId), loginUser.getUserId());
            if (!isJoined) {
                System.out.println("참여하지 않은 여행");
                result.put("success", false);
                result.put("message", "참여하지 않은 여행 계획입니다.");
                return result;
            }
            
            // 여행 참여 취소 처리
            int leaveResult = travelDAO.leaveTravel(Long.valueOf(planId), loginUser.getUserId());
            System.out.println("참여 취소 처리 결과: " + leaveResult);
            
            if (leaveResult > 0) {
                result.put("success", true);
                result.put("message", "여행 계획 참여가 취소되었습니다.");
                
                // 참여자 수 업데이트된 정보 반환
                int updatedCount = travelDAO.getParticipantCount(Long.valueOf(planId));
                result.put("participantCount", updatedCount);
            } else {
                result.put("success", false);
                result.put("message", "여행 계획 참여 취소에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("참여 취소 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "참여 취소 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }

    // 찜하기 토글 (통합 API)
    @RequestMapping(value = "/favorite/toggle", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> toggleFavorite(@RequestParam String targetType,
                                              @RequestParam int targetId,
                                              HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            System.out.println("=== 여행 찜하기 토글 처리 ===");
            System.out.println("Type: " + targetType + ", ID: " + targetId);
            System.out.println("UserId: " + loginUser.getUserId());

            // 이미 찜했는지 확인
            boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), targetType, targetId);
            System.out.println("현재 찜 상태: " + isFavorite);

            if (isFavorite) {
                // 찜하기 취소
                int result_cnt = favoriteDAO.removeFavorite(loginUser.getUserId(), targetType, targetId);
                System.out.println("찜하기 취소 결과: " + result_cnt);
                if (result_cnt > 0) {
                    result.put("success", true);
                    result.put("bookmarked", false);
                    result.put("message", "찜하기가 취소되었습니다.");
                } else {
                    result.put("success", false);
                    result.put("message", "찜하기 취소에 실패했습니다.");
                }
            } else {
                // 찜하기 추가
                int result_cnt = favoriteDAO.addFavorite(loginUser.getUserId(), targetType, targetId);
                System.out.println("찜하기 추가 결과: " + result_cnt);
                if (result_cnt > 0) {
                    result.put("success", true);
                    result.put("bookmarked", true);
                    result.put("message", "찜 목록에 추가되었습니다.");
                } else {
                    result.put("success", false);
                    result.put("message", "찜하기에 실패했습니다.");
                }
            }

        } catch (Exception e) {
            System.err.println("찜하기 토글 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "처리 중 오류가 발생했습니다: " + e.getMessage());
        }

        return result;
    }

    // 여행 계획 찜하기
    @RequestMapping(value = "/favorite/{planId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> addFavorite(@PathVariable int planId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 여행 계획 찜하기 처리 시작 ===");
            System.out.println("planId: " + planId);
            System.out.println("userId: " + loginUser.getUserId());
            
            // 여행 계획 존재 확인
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                System.out.println("여행 계획이 존재하지 않음");
                result.put("success", false);
                result.put("message", "존재하지 않는 여행 계획입니다.");
                return result;
            }
            
            // 이미 찜했는지 확인
            boolean alreadyFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
            if (alreadyFavorite) {
                System.out.println("이미 찜한 여행");
                result.put("success", false);
                result.put("message", "이미 찜한 여행 계획입니다.");
                return result;
            }
            
            // 찜하기 처리
            int favoriteResult = favoriteDAO.addFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
            System.out.println("찜하기 처리 결과: " + favoriteResult);
            
            if (favoriteResult > 0) {
                result.put("success", true);
                result.put("message", "여행 계획을 찜 목록에 추가했습니다.");
                
                // 찜 개수 정보 반환
                int favoriteCount = favoriteDAO.getFavoriteCount("TRAVEL_PLAN", planId);
                result.put("favoriteCount", favoriteCount);
            } else {
                result.put("success", false);
                result.put("message", "찜하기에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("찜하기 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "찜하기 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 여행 계획 찜하기 취소
    @RequestMapping(value = "/unfavorite/{planId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> removeFavorite(@PathVariable int planId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 여행 계획 찜하기 취소 처리 시작 ===");
            System.out.println("planId: " + planId);
            System.out.println("userId: " + loginUser.getUserId());
            
            // 여행 계획 존재 확인
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                System.out.println("여행 계획이 존재하지 않음");
                result.put("success", false);
                result.put("message", "존재하지 않는 여행 계획입니다.");
                return result;
            }
            
            // 찜했는지 확인
            boolean isFavorite = favoriteDAO.isFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
            if (!isFavorite) {
                System.out.println("찜하지 않은 여행");
                result.put("success", false);
                result.put("message", "찜하지 않은 여행 계획입니다.");
                return result;
            }
            
            // 찜하기 취소 처리
            int unfavoriteResult = favoriteDAO.removeFavorite(loginUser.getUserId(), "TRAVEL_PLAN", planId);
            System.out.println("찜하기 취소 처리 결과: " + unfavoriteResult);
            
            if (unfavoriteResult > 0) {
                result.put("success", true);
                result.put("message", "찜 목록에서 제거했습니다.");
                
                // 찜 개수 정보 반환
                int favoriteCount = favoriteDAO.getFavoriteCount("TRAVEL_PLAN", planId);
                result.put("favoriteCount", favoriteCount);
            } else {
                result.put("success", false);
                result.put("message", "찜하기 취소에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("찜하기 취소 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "찜하기 취소 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 개인화된 추천 목록 조회
    @RequestMapping(value = "/recommendations", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> getRecommendations(@RequestParam(required = false) String query,
                                                  HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요한 서비스입니다.");
            return response;
        }
        
        try {
            Long userId = Long.parseLong(loginUser.getUserId());
            String searchQuery = query != null ? query : "";
            
            // 고도화된 추천 시스템 사용
            List<TravelPlanDTO> recommendations = advancedMatchingService.getPersonalizedRecommendations(
                searchQuery, userId, 20
            );
            
            // 각 추천에 대한 추가 정보 조회
            List<Map<String, Object>> enrichedRecommendations = new java.util.ArrayList<>();
            for (TravelPlanDTO plan : recommendations) {
                Map<String, Object> enrichedPlan = new HashMap<>();
                enrichedPlan.put("plan", plan);
                
                // 작성자 정보
                MemberDTO writer = null;
                try {
                    if (plan.getPlanWriter() != null && !plan.getPlanWriter().trim().isEmpty()) {
                        writer = memberDAO.getMemberById(plan.getPlanWriter());
                        if (writer == null) {
                            writer = new MemberDTO();
                            writer.setUserId(plan.getPlanWriter());
                            writer.setUserName("탈퇴한 사용자");
                        }
                    } else {
                        writer = new MemberDTO();
                        writer.setUserId("unknown");
                        writer.setUserName("알 수 없음");
                    }
                } catch (Exception writerException) {
                    System.err.println("추천 목록에서 작성자 정보 조회 실패: " + writerException.getMessage());
                    writer = new MemberDTO();
                    writer.setUserId(plan.getPlanWriter() != null ? plan.getPlanWriter() : "unknown");
                    writer.setUserName("알 수 없음");
                }
                enrichedPlan.put("writer", writer);
                
                // 참여자 수
                int participantCount = travelDAO.getParticipantCount((long) plan.getPlanId());
                enrichedPlan.put("participantCount", participantCount);
                
                // 작성자 MBTI
                UserTravelMbtiDTO writerMbti = travelMbtiDAO.getLatestUserMbti(plan.getPlanWriter());
                if (writerMbti != null) {
                    enrichedPlan.put("writerMbti", writerMbti.getMbtiType());
                }
                
                enrichedRecommendations.add(enrichedPlan);
            }
            
            response.put("success", true);
            response.put("recommendations", enrichedRecommendations);
            response.put("count", recommendations.size());
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "추천 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    // 추천 클릭 이벤트 처리
    @RequestMapping(value = "/recommendation/click", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> trackRecommendationClick(@RequestParam Long planId,
                                                       HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.put("success", false);
            return response;
        }
        
        try {
            Long userId = Long.parseLong(loginUser.getUserId());
            feedbackProcessor.processFeedback(userId, planId, "CLICK", null, null);
            response.put("success", true);
        } catch (Exception e) {
            response.put("success", false);
        }
        
        return response;
    }
    
    // 추천 만족도 평가
    @RequestMapping(value = "/recommendation/rate", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> rateRecommendation(@RequestParam Long planId,
                                                 @RequestParam Integer rating,
                                                 HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }
        
        try {
            Long userId = Long.parseLong(loginUser.getUserId());
            feedbackProcessor.processFeedback(userId, planId, "RATE", rating, null);
            response.put("success", true);
            response.put("message", "평가가 저장되었습니다.");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "평가 처리 중 오류가 발생했습니다.");
        }
        
        return response;
    }
}