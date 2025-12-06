package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Date;

import com.tour.project.dao.MemberDAO;
import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.BoardDAO;
import com.tour.project.dao.TravelDAO;
import com.tour.project.dao.FavoriteDAO;
import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dao.MannerEvaluationDAO;
import com.tour.project.dao.MessageDAO;
import com.tour.project.dao.PlaylistDAO;
import com.tour.project.service.BadgeService;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.TravelPlanDTO;
import com.tour.project.dto.BoardDTO;
import com.tour.project.dto.TravelParticipantDTO;
import com.tour.project.dto.FavoriteDTO;
import com.tour.project.dto.TravelJoinRequestDTO;
import com.tour.project.dto.UserTravelMbtiDTO;
import com.tour.project.dto.UserMannerStatsDTO;
import com.tour.project.dto.MannerEvaluationDTO;
import com.tour.project.dto.playlist.SavedPlaylistDTO;
import com.tour.project.dto.TravelPlanSummaryDTO;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/member")
public class MemberController {
    
    @Value("${upload.path}")
    private String uploadPath;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private BoardDAO boardDAO;
    
    @Autowired
    private TravelDAO travelDAO;
    
    @Autowired
    private FavoriteDAO favoriteDAO;
    
    @Autowired
    private com.tour.project.dao.TravelJoinRequestDAO travelJoinRequestDAO;
    
    @Autowired
    private com.tour.project.dao.NotificationDAO notificationDAO;
    
    @Autowired
    private TravelMbtiDAO travelMbtiDAO;
    
    @Autowired
    private MannerEvaluationDAO mannerEvaluationDAO;
    
    @Autowired
    private BadgeService badgeService;
    
    @Autowired
    private MessageDAO messageDAO;
    
    @Autowired
    private PlaylistDAO playlistDAO;
    
    @Autowired
    private com.tour.project.dao.AiTravelPlanDAO aiTravelPlanDAO;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired(required = false)
    private com.tour.project.service.EmailService emailService;

    @Autowired(required = false)
    private com.tour.project.dao.EmailVerificationDAO emailVerificationDAO;

    @Autowired(required = false)
    private com.tour.project.service.GuideService guideService;

    @Autowired(required = false)
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String loginForm() {
        try {
            return "member/login";
        } catch (Exception e) {
            e.printStackTrace();
            return "member/auth";  // 대체 페이지
        }
    }
    
    // Spring Security가 POST /login을 처리하므로 이 메소드는 주석 처리
    // 기존 로그인 로직은 LoginSuccessHandler로 이동됨
    /*
    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String login(@RequestParam String userId,
                       @RequestParam String userPassword,
                       @RequestParam(required = false) String returnUrl,
                       HttpSession session,
                       RedirectAttributes redirectAttributes) {
        try {
            MemberDTO member = memberDAO.getMember(userId);

            if (member != null && member.getUserPassword().equals(userPassword)) {
                // 계정 상태 확인 (정지된 계정은 로그인 차단)
                String accountStatus = member.getAccountStatus();
                if (accountStatus != null && "SUSPENDED".equals(accountStatus)) {
                    redirectAttributes.addFlashAttribute("error", "⚠️ 계정이 정지되었습니다. 관리자에게 문의해주세요. 📞 고객센터: admin@wanderlust.com");
                    if (returnUrl != null && !returnUrl.trim().isEmpty()) {
                        return "redirect:/member/login?returnUrl=" + returnUrl;
                    }
                    return "redirect:/member/login";
                }

                // 로그인 전 세션에 임시 사용자 ID가 있는지 확인하고 플레이리스트 이관
                String tempUserId = (String) session.getAttribute("userId");
                if (tempUserId != null && tempUserId.startsWith("playlist_")) {
                    try {
                        int transferredCount = playlistDAO.transferTempPlaylistsToUser(tempUserId, userId);
                        System.out.println("임시 플레이리스트 이관 완료: " + transferredCount + "개");
                        // 임시 userId 세션에서 제거
                        session.removeAttribute("userId");
                    } catch (Exception e) {
                        System.err.println("임시 플레이리스트 이관 실패: " + e.getMessage());
                    }
                }

                session.setAttribute("loginUser", member);

                // 가이드 신청 상태 조회 및 세션 저장
                try {
                    if (guideService != null) {
                        com.tour.project.vo.GuideApplicationVO guideApp = guideService.getApplicationByUserId(userId);
                        if (guideApp != null) {
                            session.setAttribute("guideApplicationStatus", guideApp.getStatus());
                        }
                    }
                } catch (Exception e) {
                    System.err.println("가이드 신청 상태 조회 실패: " + e.getMessage());
                }

                // 출석 기록 (로그인 시)
                try {
                    badgeService.recordAttendance(userId);
                } catch (Exception e) {
                    System.err.println("출석 기록 실패: " + e.getMessage());
                }

                // 배지 상태 초기화 (로그인 시)
                clearActivityBadges(session);

                // returnUrl이 있으면 해당 페이지로 리다이렉트, 없으면 홈으로
                if (returnUrl != null && !returnUrl.trim().isEmpty()) {
                    return "redirect:" + returnUrl;
                }
                return "redirect:/home";
            } else {
                redirectAttributes.addFlashAttribute("error", "아이디 또는 비밀번호가 일치하지 않습니다.");
                if (returnUrl != null && !returnUrl.trim().isEmpty()) {
                    return "redirect:/member/login?returnUrl=" + returnUrl;
                }
                return "redirect:/member/login";
            }
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "로그인 중 오류가 발생했습니다.");
            if (returnUrl != null && !returnUrl.trim().isEmpty()) {
                return "redirect:/member/login?returnUrl=" + returnUrl;
            }
            return "redirect:/member/login";
        }
    */
    
    @RequestMapping(value = "/signup", method = RequestMethod.GET)
    public String signupForm() {
        // 회원가입 페이지 요청을 로그인 페이지로 리다이렉트 (회원가입 모드)
        return "redirect:/member/login?mode=signup";
    }
    
    @RequestMapping(value = "/signup", method = RequestMethod.POST)
    public String signup(MemberDTO member, RedirectAttributes redirectAttributes) {
        try {
            // 아이디 중복 체크
            MemberDTO existingMember = memberDAO.getMember(member.getUserId());
            if (existingMember != null) {
                redirectAttributes.addFlashAttribute("error", "이미 존재하는 아이디입니다.");
                return "redirect:/member/login?mode=signup";
            }
            
            // 이메일 중복 체크
            MemberDTO existingEmailMember = memberDAO.getMemberByEmail(member.getUserEmail());
            if (existingEmailMember != null) {
                redirectAttributes.addFlashAttribute("error", "이미 사용 중인 이메일입니다.");
                return "redirect:/member/login?mode=signup";
            }
            
            // 닉네임 중복 체크
            if (member.getNickname() != null && !member.getNickname().trim().isEmpty()) {
                boolean nicknameExists = memberDAO.isNicknameExists(member.getNickname());
                if (nicknameExists) {
                    redirectAttributes.addFlashAttribute("error", "이미 사용 중인 닉네임입니다.");
                    return "redirect:/member/login?mode=signup";
                }
            }

            // 비밀번호 암호화 (BCrypt)
            if (passwordEncoder != null) {
                String encodedPassword = passwordEncoder.encode(member.getUserPassword());
                member.setUserPassword(encodedPassword);
                System.out.println("비밀번호 암호화 완료");
            } else {
                System.err.println("PasswordEncoder가 null입니다!");
                redirectAttributes.addFlashAttribute("error", "시스템 오류가 발생했습니다. 관리자에게 문의하세요.");
                return "redirect:/member/login?mode=signup";
            }

            // 회원 정보 저장
            int result = memberDAO.insertMember(member);
            
            if (result > 0) {
                redirectAttributes.addFlashAttribute("success", "회원가입이 완료되었습니다. 로그인해 주세요.");
                return "redirect:/member/login";
            } else {
                redirectAttributes.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다.");
                return "redirect:/member/login?mode=signup";
            }
        } catch (Exception e) {
            String errorMessage = "회원가입 중 오류가 발생했습니다.";
            
            // 구체적인 오류 메시지 처리
            if (e.getMessage().contains("Duplicate entry") && e.getMessage().contains("user_email")) {
                errorMessage = "이미 사용 중인 이메일입니다.";
            } else if (e.getMessage().contains("Duplicate entry") && e.getMessage().contains("PRIMARY")) {
                errorMessage = "이미 존재하는 아이디입니다.";
            }
            
            redirectAttributes.addFlashAttribute("error", errorMessage);
            return "redirect:/member/login?mode=signup";
        }
    }
    
    /**
     * 이메일 인증번호 발송 API
     */
    @RequestMapping(value = "/api/send-verification-code", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> sendVerificationCode(@RequestParam String email, HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 이메일 형식 검증
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                result.put("success", false);
                result.put("message", "올바른 이메일 주소를 입력해주세요.");
                return result;
            }

            // 이메일 중복 체크
            MemberDTO existingMember = memberDAO.getMemberByEmail(email);
            if (existingMember != null) {
                result.put("success", false);
                result.put("message", "이미 사용 중인 이메일입니다.");
                return result;
            }

            // 서비스 null 체크
            if (emailService == null) {
                System.err.println("[ERROR] EmailService is null!");
                result.put("success", false);
                result.put("message", "이메일 서비스가 초기화되지 않았습니다.");
                return result;
            }

            if (emailVerificationDAO == null) {
                System.err.println("[ERROR] EmailVerificationDAO is null!");
                result.put("success", false);
                result.put("message", "인증 서비스가 초기화되지 않았습니다.");
                return result;
            }

            // 인증번호 생성
            String code = emailService.generateVerificationCode();
            System.out.println("[디버그] 생성된 인증번호: " + code);

            try {
                // 기존 미인증 레코드 삭제
                emailVerificationDAO.deleteUnverifiedByEmail(email);
            } catch (Exception ex) {
                System.err.println("[경고] 기존 레코드 삭제 실패 (무시): " + ex.getMessage());
            }

            try {
                // DB에 저장
                com.tour.project.dto.EmailVerificationDTO verification =
                    new com.tour.project.dto.EmailVerificationDTO(email, code);
                emailVerificationDAO.insertVerification(verification);
                System.out.println("[디버그] DB 저장 성공");
            } catch (Exception ex) {
                System.err.println("[ERROR] DB 저장 실패: " + ex.getMessage());
                ex.printStackTrace();
                // DB 저장 실패해도 이메일은 발송 시도
            }

            // 이메일 발송
            boolean sent = emailService.sendVerificationEmail(email, code);

            if (sent) {
                // 세션에 이메일 임시 저장
                session.setAttribute("pendingEmail", email);
                result.put("success", true);
                result.put("message", "인증번호가 이메일로 발송되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "이메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.");
            }

        } catch (Exception e) {
            System.err.println("[이메일 인증 오류] " + e.getClass().getName() + ": " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "오류가 발생했습니다: " + e.getMessage());
            result.put("error", e.getClass().getSimpleName());
        }

        return result;
    }

    /**
     * 이메일 인증번호 확인 API
     */
    @RequestMapping(value = "/api/verify-code", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> verifyCode(@RequestParam String email,
                                          @RequestParam String code,
                                          HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        try {
            // 인증 정보 조회
            com.tour.project.dto.EmailVerificationDTO verification =
                emailVerificationDAO.getVerification(email, code);

            if (verification != null) {
                // 시도 횟수 체크
                if (verification.getAttemptCount() >= 5) {
                    result.put("success", false);
                    result.put("message", "인증 시도 횟수를 초과했습니다. 다시 발송해주세요.");
                    return result;
                }

                // 인증 성공
                emailVerificationDAO.updateVerificationStatus(email, code);
                session.setAttribute("emailVerified", true);
                session.setAttribute("verifiedEmail", email);

                result.put("success", true);
                result.put("message", "이메일 인증이 완료되었습니다.");
            } else {
                // 인증 실패 - 시도 횟수 증가
                emailVerificationDAO.incrementAttemptCount(email);

                result.put("success", false);
                result.put("message", "인증번호가 올바르지 않거나 만료되었습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return result;
    }

    @RequestMapping(value = "/logout", method = RequestMethod.GET)
    public String logout(HttpSession session) {
        // 세션 무효화 (자동으로 모든 배지 상태 제거됨)
        session.invalidate();
        return "redirect:/";
    }

    // 사용자 프로필 보기 - ProfileController로 리디렉션
    @RequestMapping(value = "/profile/{userId}", method = RequestMethod.GET)
    public String userProfile(@PathVariable String userId, Model model, HttpSession session) {
        // ProfileController로 리디렉션 (더 많은 정보 제공)
        return "redirect:/profile/view/" + userId;
    }

    @RequestMapping(value = "/mypage", method = RequestMethod.GET)
    public String mypage(HttpSession session, Model model) {
        MemberDTO loginUser = null;
        try {
            loginUser = (MemberDTO) session.getAttribute("loginUser");
            
            if (loginUser == null) {
                return "redirect:/member/login";
            }
            
            // 여행 계획 및 동행 신청 목록 조회
            List<TravelPlanDTO> myTravelPlans = null;
            List<TravelJoinRequestDTO> mySentRequests = null;
            List<BoardDTO> myPosts = null;
            List<TravelJoinRequestDTO> myReceivedRequests = null;
            try {
                myTravelPlans = travelPlanDAO.getTravelPlansByWriter(loginUser.getUserId());
                mySentRequests = travelJoinRequestDAO.getJoinRequestsByRequester(loginUser.getUserId());
                model.addAttribute("myTravelPlans", myTravelPlans);
                model.addAttribute("travelPlanCount", myTravelPlans != null ? myTravelPlans.size() : 0);
                model.addAttribute("mySentRequests", mySentRequests);
                model.addAttribute("sentRequestCount", mySentRequests != null ? mySentRequests.size() : 0);

                // 다가오는 여행 필터링 (10일 이내 시작하는 여행만)
                if (myTravelPlans != null || mySentRequests != null) {
                    Date now = new Date();
                    List<TravelPlanDTO> upcomingTravels = new ArrayList<>();

                    // 내가 만든 여행 중 10일 이내 (오늘 포함)
                    if (myTravelPlans != null) {
                        for (TravelPlanDTO plan : myTravelPlans) {
                            if (plan.getPlanStartDate() != null) {
                                long diff = plan.getPlanStartDate().getTime() - now.getTime();
                                long days = diff / (1000 * 60 * 60 * 24);

                                // 오늘 출발하거나 10일 이내 출발하는 여행
                                if (days >= 0 && days <= 10) {
                                    plan.setDaysUntil((int) days);
                                    upcomingTravels.add(plan);
                                    System.out.println("다가오는 여행 추가: " + plan.getPlanTitle() + ", D-" + days);
                                }
                            }
                        }
                    }

                    // 동행 신청한 여행 중 승인된 것들 추가
                    if (mySentRequests != null) {
                        for (TravelJoinRequestDTO request : mySentRequests) {
                            if ("approved".equals(request.getStatus())) {
                                // 해당 여행 계획 정보 가져오기
                                TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(request.getTravelPlanId().longValue());
                                if (plan != null && plan.getPlanStartDate() != null) {
                                    long diff = plan.getPlanStartDate().getTime() - now.getTime();
                                    long days = diff / (1000 * 60 * 60 * 24);

                                    // 오늘 출발하거나 10일 이내 출발하는 여행
                                    if (days >= 0 && days <= 10) {
                                        plan.setDaysUntil((int) days);
                                        // 중복 체크
                                        boolean exists = upcomingTravels.stream()
                                            .anyMatch(p -> p.getPlanId() == plan.getPlanId());
                                        if (!exists) {
                                            upcomingTravels.add(plan);
                                            System.out.println("동행 여행 추가: " + plan.getPlanTitle() + ", D-" + days);
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 날짜순 정렬 (가까운 여행이 먼저)
                    upcomingTravels.sort((a, b) -> a.getPlanStartDate().compareTo(b.getPlanStartDate()));
                    model.addAttribute("upcomingTravels", upcomingTravels);
                }

                // 캘린더용 참여 중인 여행 목록 (승인된 동행 신청)
                List<TravelPlanDTO> participatingTravels = new ArrayList<>();
                if (mySentRequests != null) {
                    System.out.println("[캘린더] 동행 신청 수: " + mySentRequests.size());
                    for (TravelJoinRequestDTO request : mySentRequests) {
                        String status = request.getStatus();
                        System.out.println("[캘린더] 신청 상태: " + status + ", planId: " + request.getTravelPlanId());
                        // 대소문자 무시하고 비교
                        if (status != null && status.equalsIgnoreCase("approved")) {
                            TravelPlanDTO plan = travelPlanDAO.getTravelPlanById(request.getTravelPlanId().longValue());
                            if (plan != null) {
                                // 중복 체크 (내가 만든 여행에 없는 것만 추가)
                                boolean exists = myTravelPlans != null && myTravelPlans.stream()
                                    .anyMatch(p -> p.getPlanId() == plan.getPlanId());
                                if (!exists) {
                                    participatingTravels.add(plan);
                                    System.out.println("[캘린더] 참여 여행 추가: " + plan.getPlanTitle());
                                }
                            }
                        }
                    }
                }
                System.out.println("[캘린더] 최종 참여 여행 수: " + participatingTravels.size());
                model.addAttribute("participatingTravels", participatingTravels);
            } catch (Exception ex) {
                System.err.println("여행 계획 조회 중 오류: " + ex.getMessage());
                model.addAttribute("travelPlanCount", 0);
                model.addAttribute("participatingTravels", java.util.Collections.emptyList());
            }
            
            // 게시글, 동행 수락 목록 조회
            try {
                myPosts = boardDAO.getBoardsByWriter(loginUser.getUserId());
                model.addAttribute("myPosts", myPosts);
                model.addAttribute("postCount", myPosts != null ? myPosts.size() : 0);
            } catch (Exception ex) {
                System.err.println("게시글 조회 중 오류: " + ex.getMessage());
                model.addAttribute("myPosts", java.util.Collections.emptyList());
                model.addAttribute("postCount", 0);
            }

            // 받은 동행 신청 조회 - 별도 try-catch로 분리하여 에러 격리
            try {
                myReceivedRequests = travelJoinRequestDAO.getJoinRequestsByPlanWriter(loginUser.getUserId());
                model.addAttribute("myReceivedRequests", myReceivedRequests);
                model.addAttribute("receivedRequestCount", myReceivedRequests != null ? myReceivedRequests.size() : 0);
            } catch (Exception ex) {
                System.err.println("받은 동행 신청 조회 중 오류: " + ex.getMessage());
                ex.printStackTrace();
                model.addAttribute("myReceivedRequests", java.util.Collections.emptyList());
                model.addAttribute("receivedRequestCount", 0);
            }

            // 참여중인 여행 조회 (다른 사람이 만든 여행 중 내가 참여 승인된 것)
            try {
                List<TravelParticipantDTO> joinedTravels = travelDAO.getParticipatingTravelsByUserId(loginUser.getUserId());
                model.addAttribute("joinedTravels", joinedTravels);
                model.addAttribute("joinedTravelCount", joinedTravels != null ? joinedTravels.size() : 0);
            } catch (Exception ex) {
                System.err.println("참여중인 여행 조회 중 오류: " + ex.getMessage());
                ex.printStackTrace();
                model.addAttribute("joinedTravels", java.util.Collections.emptyList());
                model.addAttribute("joinedTravelCount", 0);
            }

            // MBTI 정보 및 매너 통계 조회
            UserTravelMbtiDTO userMbti = null;
            String mbtiTypeName = null;
            UserMannerStatsDTO mannerStats = null;
            
            try {
                userMbti = travelMbtiDAO.getLatestUserMbti(loginUser.getUserId());
                if (userMbti != null && userMbti.getMbtiType() != null) {
                    mbtiTypeName = getMbtiTypeName(userMbti.getMbtiType());
                }
                
                mannerStats = mannerEvaluationDAO.getUserMannerStats(loginUser.getUserId());
                if (mannerStats == null) {
                    mannerStats = new UserMannerStatsDTO(loginUser.getUserId());
                    mannerEvaluationDAO.insertUserMannerStats(mannerStats);
                }
            } catch (Exception ex) {
                if (mannerStats == null) {
                    mannerStats = new UserMannerStatsDTO(loginUser.getUserId());
                }
            }
            
            // 찜목록 개수 및 활동별 배지 상태 조회
            Map<String, Boolean> activityBadges = new HashMap<>();
            try {
                int validTravelPlanCount = favoriteDAO.getValidTravelPlanFavoriteCount(loginUser.getUserId());
                int validBoardCount = favoriteDAO.getValidBoardFavoriteCount(loginUser.getUserId());
                int totalValidCount = validTravelPlanCount + validBoardCount;
                
                model.addAttribute("favoriteCount", totalValidCount);
                model.addAttribute("travelPlanFavoriteCount", validTravelPlanCount);
                model.addAttribute("boardFavoriteCount", validBoardCount);
                
                activityBadges = calculateActivityBadges(session, loginUser.getUserId());
            } catch (Exception ex) {
                model.addAttribute("favoriteCount", 0);
                model.addAttribute("travelPlanFavoriteCount", 0);
                model.addAttribute("boardFavoriteCount", 0);
                activityBadges.put("sentRequestBadge", false);
                activityBadges.put("receivedRequestBadge", false);
                activityBadges.put("favoriteBadge", false);
            }
            
            // 모델 속성 설정
            model.addAttribute("member", loginUser);
            model.addAttribute("userMbti", userMbti);
            model.addAttribute("mbtiTypeName", mbtiTypeName);
            model.addAttribute("mannerStats", mannerStats);
            model.addAttribute("pendingRequestCount", 0);
            model.addAttribute("activityBadges", activityBadges);
            
            // 뱃지 정보 조회
            try {
                // 보유 뱃지 조회
                List<com.tour.project.dto.BadgeDTO> userBadges = badgeService.getUserBadges(loginUser.getUserId());
                model.addAttribute("badges", userBadges);
                model.addAttribute("badgeCount", userBadges != null ? userBadges.size() : 0);
                
                // 뱃지 진행 상황 조회
                Map<String, Object> badgeProgress = badgeService.getBadgeProgress(loginUser.getUserId());
                model.addAttribute("badgeProgress", badgeProgress);
            } catch (Exception ex) {
                System.err.println("뱃지 정보 조회 중 오류: " + ex.getMessage());
                model.addAttribute("badges", java.util.Collections.emptyList());
                model.addAttribute("badgeCount", 0);
                model.addAttribute("badgeProgress", new HashMap<String, Object>());
            }
            
            // 쪽지 정보 조회
            try {
                int unreadMessageCount = messageDAO.getUnreadMessageCount(loginUser.getUserId());
                int totalReceivedCount = messageDAO.getReceivedMessageCount(loginUser.getUserId());
                int totalSentCount = messageDAO.getSentMessageCount(loginUser.getUserId());
                
                model.addAttribute("unreadMessageCount", unreadMessageCount);
                model.addAttribute("totalReceivedCount", totalReceivedCount);
                model.addAttribute("totalSentCount", totalSentCount);
            } catch (Exception ex) {
                System.err.println("쪽지 정보 조회 중 오류: " + ex.getMessage());
                model.addAttribute("unreadMessageCount", 0);
                model.addAttribute("totalReceivedCount", 0);
                model.addAttribute("totalSentCount", 0);
            }
            
            // 저장된 플레이리스트 정보 조회
            try {
                List<SavedPlaylistDTO> savedPlaylists = playlistDAO.getUserPlaylists(loginUser.getUserId());
                // 각 플레이리스트에 대해 곡 정보도 가져오기
                if (savedPlaylists != null) {
                    for (SavedPlaylistDTO playlist : savedPlaylists) {
                        List<SavedPlaylistDTO.SavedSongDTO> songs = playlistDAO.getPlaylistSongs(playlist.getPlaylistId());
                        playlist.setSongs(songs);
                    }
                }
                
                model.addAttribute("savedPlaylists", savedPlaylists);
                model.addAttribute("savedPlaylistCount", savedPlaylists != null ? savedPlaylists.size() : 0);
            } catch (Exception ex) {
                System.err.println("플레이리스트 정보 조회 중 오류: " + ex.getMessage());
                model.addAttribute("savedPlaylists", java.util.Collections.emptyList());
                model.addAttribute("savedPlaylistCount", 0);
            }
            
            // 최근 활동 타임라인 생성 (모든 활동 포함, 기간 제한 없음)
            try {
                List<Map<String, Object>> recentActivities = new ArrayList<>();

                // 1. 여행 계획 등록
                if (myTravelPlans != null) {
                    for (TravelPlanDTO plan : myTravelPlans) {
                        if (plan.getPlanRegdate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("type", "PLAN_CREATED");
                            activity.put("title", "여행 계획 등록: " + plan.getPlanTitle());
                            activity.put("date", plan.getPlanRegdate());
                            activity.put("timeAgo", getTimeAgo(plan.getPlanRegdate()));
                            activity.put("icon", "fa-map-marked-alt");
                            activity.put("color", "#56ab2f");
                            recentActivities.add(activity);
                        }
                    }
                }

                // 2. 게시글 작성
                if (myPosts != null) {
                    for (BoardDTO post : myPosts) {
                        if (post.getBoardRegdate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("type", "POST_CREATED");
                            activity.put("title", "글 작성: " + post.getBoardTitle());
                            activity.put("date", post.getBoardRegdate());
                            activity.put("timeAgo", getTimeAgo(post.getBoardRegdate()));
                            activity.put("icon", "fa-pen");
                            activity.put("color", "#6a82fb");
                            recentActivities.add(activity);
                        }
                    }
                }

                // 3. 동행 신청 보냄
                if (mySentRequests != null) {
                    for (TravelJoinRequestDTO request : mySentRequests) {
                        if (request.getRequestDate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("type", "REQUEST_SENT");
                            activity.put("title", "동행 신청: " + request.getTravelPlanTitle());
                            activity.put("date", request.getRequestDate());
                            activity.put("timeAgo", getTimeAgo(request.getRequestDate()));
                            activity.put("icon", "fa-paper-plane");
                            activity.put("color", "#00bcd4");
                            recentActivities.add(activity);
                        }
                    }
                }

                // 4. 동행 신청 받음
                if (myReceivedRequests != null) {
                    for (TravelJoinRequestDTO request : myReceivedRequests) {
                        if (request.getRequestDate() != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("type", "REQUEST_RECEIVED");
                            activity.put("title", "동행 신청 받음: " + request.getRequesterName() + "님");
                            activity.put("date", request.getRequestDate());
                            activity.put("timeAgo", getTimeAgo(request.getRequestDate()));
                            activity.put("icon", "fa-user-plus");
                            activity.put("color", "#f2994a");
                            recentActivities.add(activity);
                        }
                    }
                }

                // 5. 댄 테스트 참여
                try {
                    String recentMbtiTestSql = "SELECT test_date FROM travel_mbti_results WHERE user_id = ? ORDER BY test_date DESC LIMIT 1";
                    java.sql.Timestamp mbtiTestDate = jdbcTemplate.queryForObject(recentMbtiTestSql,
                        new Object[]{loginUser.getUserId()}, java.sql.Timestamp.class);

                    if (mbtiTestDate != null) {
                        Map<String, Object> activity = new HashMap<>();
                        activity.put("type", "MBTI_TEST");
                        activity.put("title", "여행 MBTI 테스트 완료");
                        activity.put("date", mbtiTestDate);
                        activity.put("timeAgo", getTimeAgo(mbtiTestDate));
                        activity.put("icon", "fa-user-tag");
                        activity.put("color", "#9b59b6");
                        recentActivities.add(activity);
                    }
                } catch (Exception e) {
                    // MBTI 테스트 기록이 없을 수 있음
                }

                // 6. 찜 등록
                try {
                    String favoriteSql = "SELECT created_date, plan_id FROM travel_favorites WHERE user_id = ? ORDER BY created_date DESC";
                    List<Map<String, Object>> favorites = jdbcTemplate.queryForList(favoriteSql, loginUser.getUserId());

                    for (Map<String, Object> fav : favorites) {
                        java.sql.Timestamp favDate = (java.sql.Timestamp) fav.get("created_date");
                        Integer planId = (Integer) fav.get("plan_id");

                        // 찜한 여행 제목 가져오기
                        TravelPlanDTO favPlan = travelPlanDAO.getTravelPlanById(planId.longValue());
                        if (favPlan != null) {
                            Map<String, Object> activity = new HashMap<>();
                            activity.put("type", "FAVORITE_ADDED");
                            activity.put("title", "찜 등록: " + favPlan.getPlanTitle());
                            activity.put("date", favDate);
                            activity.put("timeAgo", getTimeAgo(favDate));
                            activity.put("icon", "fa-heart");
                            activity.put("color", "#e74c3c");
                            recentActivities.add(activity);
                        }
                    }
                } catch (Exception e) {
                    // 찜 기록이 없을 수 있음
                }

                // 7. 댓글 작성
                try {
                    String commentSql = "SELECT comment_regdate, board_id, comment_content FROM board_comments WHERE user_id = ? ORDER BY comment_regdate DESC";
                    List<Map<String, Object>> comments = jdbcTemplate.queryForList(commentSql, loginUser.getUserId());

                    for (Map<String, Object> comment : comments) {
                        java.sql.Timestamp commentDate = (java.sql.Timestamp) comment.get("comment_regdate");
                        String content = (String) comment.get("comment_content");

                        Map<String, Object> activity = new HashMap<>();
                        activity.put("type", "COMMENT_CREATED");
                        activity.put("title", "댓글 작성: " + (content.length() > 30 ? content.substring(0, 30) + "..." : content));
                        activity.put("date", commentDate);
                        activity.put("timeAgo", getTimeAgo(commentDate));
                        activity.put("icon", "fa-comment");
                        activity.put("color", "#ff6347");
                        recentActivities.add(activity);
                    }
                } catch (Exception e) {
                    // 댓글 기록이 없을 수 있음
                }

                // 시간순 정렬 (최신 순)
                recentActivities.sort((a, b) -> {
                    Date dateA = (Date) a.get("date");
                    Date dateB = (Date) b.get("date");
                    return dateB.compareTo(dateA);
                });

                // 전체 타임라인 저장
                model.addAttribute("activityTimeline", new ArrayList<>(recentActivities));

                // 상위 10개만
                if (recentActivities.size() > 10) {
                    recentActivities = recentActivities.subList(0, 10);
                }

                model.addAttribute("recentActivities", recentActivities);

            } catch (Exception ex) {
                System.err.println("활동 타임라인 생성 중 오류: " + ex.getMessage());
                ex.printStackTrace();
                model.addAttribute("recentActivities", new ArrayList<>());
                model.addAttribute("activityTimeline", new ArrayList<>());
            }

            // 저장된 AI 여행 계획 정보 조회
            try {
                List<TravelPlanSummaryDTO> savedAiPlans = aiTravelPlanDAO.getUserTravelPlans(loginUser.getUserId());
                model.addAttribute("savedAiPlans", savedAiPlans);
                model.addAttribute("savedAiPlanCount", savedAiPlans != null ? savedAiPlans.size() : 0);
            } catch (Exception ex) {
                System.err.println("AI 여행 계획 정보 조회 중 오류: " + ex.getMessage());
                model.addAttribute("savedAiPlans", java.util.Collections.emptyList());
                model.addAttribute("savedAiPlanCount", 0);
            }

            return "member/mypage-full";
        } catch (Exception e) {
            System.err.println("=== MyPage 메서드 예외 발생 ===");
            System.err.println("오류 메시지: " + e.getMessage());
            System.err.println("오류 클래스: " + e.getClass().getName());
            e.printStackTrace();
            
            // 응답 안정성을 위한 최소한의 모델 설정
            try {
                if (loginUser != null) {
                    model.addAttribute("member", loginUser);
                    model.addAttribute("travelPlanCount", 0);
                    model.addAttribute("postCount", 0);
                    model.addAttribute("sentRequestCount", 0);
                    model.addAttribute("receivedRequestCount", 0);
                    model.addAttribute("favoriteCount", 0);
                    model.addAttribute("travelPlanFavoriteCount", 0);
                    model.addAttribute("boardFavoriteCount", 0);
                    model.addAttribute("pendingRequestCount", 0);
                    model.addAttribute("activityBadges", new HashMap<String, Boolean>());
                    model.addAttribute("userMbti", null);
                    model.addAttribute("mbtiTypeName", null);
                    model.addAttribute("mannerStats", new UserMannerStatsDTO(loginUser.getUserId()));
                    return "member/mypage-full";
                }
            } catch (Exception ex) {
                System.err.println("모델 설정 중 추가 오류: " + ex.getMessage());
            }
            
            return "redirect:/member/login";
        }
    }
    
    // 찜목록 페이지 (여행계획 + 커뮤니티 통합)
    @RequestMapping(value = "/favorites", method = RequestMethod.GET)
    public String favorites(HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            
            if (loginUser == null) {
                redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
                return "redirect:/member/login";
            }
            
            // 찜목록 활동 확인으로 표시
            markActivityAsSeen(session, "favorite");
            
            // 통합 찜목록 조회
            List<FavoriteDTO> allFavorites = favoriteDAO.getFavoritesByUserId(loginUser.getUserId());
            
            // 여행계획 찜목록만 조회
            List<FavoriteDTO> travelPlanFavorites = favoriteDAO.getTravelPlanFavoritesByUserId(loginUser.getUserId());
            
            // 커뮤니티 게시글 찜목록만 조회
            List<FavoriteDTO> boardFavorites = favoriteDAO.getBoardFavoritesByUserId(loginUser.getUserId());
            
            // 정확한 유효 개수 조회
            int validTravelPlanCount = favoriteDAO.getValidTravelPlanFavoriteCount(loginUser.getUserId());
            int validBoardCount = favoriteDAO.getValidBoardFavoriteCount(loginUser.getUserId());
            int totalValidCount = validTravelPlanCount + validBoardCount;
            
            model.addAttribute("allFavorites", allFavorites);
            model.addAttribute("travelPlanFavorites", travelPlanFavorites);
            model.addAttribute("boardFavorites", boardFavorites);
            model.addAttribute("totalCount", totalValidCount);
            model.addAttribute("travelPlanCount", validTravelPlanCount);
            model.addAttribute("boardCount", validBoardCount);
            
            return "member/favorites";
            
        } catch (Exception e) {
            System.err.println("=== 찜목록 조회 중 오류 발생 ===");
            System.err.println("오류 클래스: " + e.getClass().getName());
            System.err.println("오류 메시지: " + e.getMessage());
            if (e.getCause() != null) {
                System.err.println("원인: " + e.getCause().getClass().getName() + " - " + e.getCause().getMessage());
            }
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "찜목록을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/member/mypage";
        }
    }
    
    // 아이디 중복 확인 API
    @RequestMapping(value = "/check-userid", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkUserId(@RequestParam String userId) {
        Map<String, Object> response = new HashMap<>();
        try {
            boolean exists = memberDAO.isUserIdExists(userId);
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용 중인 아이디입니다." : "사용 가능한 아이디입니다.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("error", true);
            response.put("message", "아이디 중복 확인 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
    // 닉네임 중복 확인 API
    @RequestMapping(value = "/check-nickname", method = RequestMethod.GET)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkNickname(@RequestParam String nickname) {
        Map<String, Object> response = new HashMap<>();
        try {
            boolean exists = memberDAO.isNicknameExists(nickname);
            response.put("exists", exists);
            response.put("message", exists ? "이미 사용 중인 닉네임입니다." : "사용 가능한 닉네임입니다.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("error", true);
            response.put("message", "닉네임 중복 확인 중 오류가 발생했습니다.");
            return ResponseEntity.status(500).body(response);
        }
    }
    
    // 프로필 수정 페이지
    @RequestMapping(value = "/edit", method = RequestMethod.GET)
    public String editProfileForm(HttpSession session, Model model) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }
        
        model.addAttribute("member", loginUser);
        return "member/edit";
    }
    
    // 프로필 수정 처리
    @RequestMapping(value = "/edit", method = RequestMethod.POST)
    public String editProfile(@RequestParam String currentPassword,
                            @RequestParam String nickname,
                            @RequestParam String userEmail,
                            @RequestParam(required = false) String newPassword,
                            @RequestParam(required = false) String confirmPassword,
                            HttpSession session,
                            RedirectAttributes redirectAttributes) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                return "redirect:/member/login";
            }
            
            // 현재 비밀번호 확인 (BCrypt 검증)
            if (passwordEncoder == null) {
                System.err.println("PasswordEncoder가 null입니다!");
                redirectAttributes.addFlashAttribute("error", "시스템 오류가 발생했습니다. 관리자에게 문의하세요.");
                return "redirect:/member/edit";
            }

            System.out.println("=== 비밀번호 검증 디버깅 ===");
            System.out.println("입력한 비밀번호 길이: " + currentPassword.length());
            System.out.println("DB 비밀번호 시작 부분: " + loginUser.getUserPassword().substring(0, Math.min(20, loginUser.getUserPassword().length())));
            System.out.println("PasswordEncoder 타입: " + passwordEncoder.getClass().getName());
            boolean matches = passwordEncoder.matches(currentPassword, loginUser.getUserPassword());
            System.out.println("비밀번호 일치 여부: " + matches);

            if (!matches) {
                redirectAttributes.addFlashAttribute("error", "현재 비밀번호가 일치하지 않습니다.");
                return "redirect:/member/edit";
            }
            
            // 새 비밀번호 확인
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                if (!newPassword.equals(confirmPassword)) {
                    redirectAttributes.addFlashAttribute("error", "새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
                    return "redirect:/member/edit";
                }
            }
            
            // 닉네임 중복 체크 (기존과 다른 경우에만)
            if (!nickname.equals(loginUser.getNickname())) {
                boolean nicknameExists = memberDAO.isNicknameExists(nickname);
                if (nicknameExists) {
                    redirectAttributes.addFlashAttribute("error", "이미 사용 중인 닉네임입니다.");
                    return "redirect:/member/edit";
                }
            }
            
            // 이메일 중복 체크 (기존과 다른 경우에만)
            if (!userEmail.equals(loginUser.getUserEmail())) {
                MemberDTO existingEmailMember = memberDAO.getMemberByEmail(userEmail);
                if (existingEmailMember != null) {
                    redirectAttributes.addFlashAttribute("error", "이미 사용 중인 이메일입니다.");
                    return "redirect:/member/edit";
                }
            }
            
            // 업데이트할 정보 설정
            MemberDTO updateMember = new MemberDTO();
            updateMember.setUserId(loginUser.getUserId());  // 기존 아이디 유지
            updateMember.setNickname(nickname);
            updateMember.setUserEmail(userEmail);
            
            // 새 비밀번호가 입력된 경우에만 업데이트 (BCrypt 암호화)
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                updateMember.setUserPassword(passwordEncoder.encode(newPassword));
            } else {
                updateMember.setUserPassword(loginUser.getUserPassword());
            }
            
            // 기타 기존 정보 유지
            updateMember.setUserName(loginUser.getUserName());
            updateMember.setUserMbti(loginUser.getUserMbti());
            updateMember.setGender(loginUser.getGender());
            updateMember.setAge(loginUser.getAge());
            updateMember.setMannerTemperature(loginUser.getMannerTemperature());
            updateMember.setProfileImage(loginUser.getProfileImage());
            updateMember.setUserRegdate(loginUser.getUserRegdate());
            
            // 회원 정보 업데이트
            int result = memberDAO.updateMember(updateMember);
            
            if (result > 0) {
                // 세션 정보 업데이트
                session.setAttribute("loginUser", updateMember);
                redirectAttributes.addFlashAttribute("success", "프로필이 성공적으로 수정되었습니다.");
                return "redirect:/member/mypage";
            } else {
                redirectAttributes.addFlashAttribute("error", "프로필 수정 중 오류가 발생했습니다.");
                return "redirect:/member/edit";
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "프로필 수정 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/member/edit";
        }
    }
    
    // 24시간 내 활동인지 체크하는 헬퍼 메서드
    private boolean isWithin24Hours(java.util.Date date) {
        if (date == null) return false;
        
        long currentTime = System.currentTimeMillis();
        long dateTime = date.getTime();
        long diff = currentTime - dateTime;
        
        // 24시간 = 24 * 60 * 60 * 1000 = 86,400,000 밀리초
        // 미래 날짜는 제외하고 과거 24시간 내만 포함
        return diff >= 0 && diff <= 86400000L;
    }
    
    // MBTI 타입 이름 반환 헬퍼 메서드
    private String getMbtiTypeName(String mbtiType) {
        if (mbtiType == null || mbtiType.length() != 4) {
            return null;
        }
        
        Map<String, String> typeNames = new HashMap<>();
        typeNames.put("PAIB", "알뜰한 계획형 모험가");
        typeNames.put("PAGL", "럭셔리한 계획형 모험가");
        typeNames.put("PSIB", "알뜰한 계획형 안전파");
        typeNames.put("PSGL", "럭셔리한 계획형 안전파");
        typeNames.put("JAIB", "즉흥적인 배낭여행자");
        typeNames.put("JAGL", "즉흥적인 럭셔리 여행자");
        typeNames.put("JSIB", "즉흥적인 개별 여행자");
        typeNames.put("JSGL", "즉흥적인 단체 여행자");
        
        return typeNames.getOrDefault(mbtiType, "여행 탐험가");
    }
    
    // 활동별 배지 상태 계산
    private Map<String, Boolean> calculateActivityBadges(HttpSession session, String userId) {
        Map<String, Boolean> badges = new HashMap<>();
        
        try {
            // 현재 개수들 조회
            int currentSentRequestCount = 0;
            int currentReceivedRequestCount = 0;
            int currentFavoriteCount = 0;
            
            try {
                List<TravelJoinRequestDTO> sentRequests = travelJoinRequestDAO.getJoinRequestsByRequester(userId);
                currentSentRequestCount = sentRequests != null ? sentRequests.size() : 0;
            } catch (Exception e) {
                System.err.println("보낸 동행 신청 개수 조회 오류: " + e.getMessage());
            }
            
            try {
                List<TravelJoinRequestDTO> receivedRequests = travelJoinRequestDAO.getJoinRequestsByPlanWriter(userId);
                currentReceivedRequestCount = receivedRequests != null ? receivedRequests.size() : 0;
            } catch (Exception e) {
                System.err.println("받은 동행 신청 개수 조회 오류: " + e.getMessage());
            }
            
            try {
                int validTravelPlanCount = favoriteDAO.getValidTravelPlanFavoriteCount(userId);
                int validBoardCount = favoriteDAO.getValidBoardFavoriteCount(userId);
                currentFavoriteCount = validTravelPlanCount + validBoardCount;
            } catch (Exception e) {
                System.err.println("찜목록 개수 조회 오류: " + e.getMessage());
            }
            
            // 세션에서 마지막 확인한 개수들 가져오기
            Integer lastSentRequestCount = (Integer) session.getAttribute("lastSentRequestCount");
            Integer lastReceivedRequestCount = (Integer) session.getAttribute("lastReceivedRequestCount");
            Integer lastFavoriteCount = (Integer) session.getAttribute("lastFavoriteCount");
            
            // 처음 접속이거나 세션이 새로운 경우 현재 값으로 초기화
            if (lastSentRequestCount == null) {
                lastSentRequestCount = currentSentRequestCount;
                session.setAttribute("lastSentRequestCount", lastSentRequestCount);
            }
            if (lastReceivedRequestCount == null) {
                lastReceivedRequestCount = currentReceivedRequestCount;
                session.setAttribute("lastReceivedRequestCount", lastReceivedRequestCount);
            }
            if (lastFavoriteCount == null) {
                lastFavoriteCount = currentFavoriteCount;
                session.setAttribute("lastFavoriteCount", lastFavoriteCount);
            }
            
            // 개수가 증가했는지 확인하여 배지 상태 설정
            badges.put("sentRequestBadge", currentSentRequestCount > lastSentRequestCount);
            badges.put("receivedRequestBadge", currentReceivedRequestCount > lastReceivedRequestCount);
            badges.put("favoriteBadge", currentFavoriteCount > lastFavoriteCount);
            
            // 현재 개수를 세션에 저장 (다음 비교를 위해)
            session.setAttribute("currentSentRequestCount", currentSentRequestCount);
            session.setAttribute("currentReceivedRequestCount", currentReceivedRequestCount);
            session.setAttribute("currentFavoriteCount", currentFavoriteCount);
            
        } catch (Exception e) {
            System.err.println("활동 배지 계산 중 오류: " + e.getMessage());
            badges.put("sentRequestBadge", false);
            badges.put("receivedRequestBadge", false);
            badges.put("favoriteBadge", false);
        }
        
        return badges;
    }
    
    // 배지 상태 초기화 (로그인 시)
    private void clearActivityBadges(HttpSession session) {
        session.removeAttribute("lastSentRequestCount");
        session.removeAttribute("lastReceivedRequestCount");
        session.removeAttribute("lastFavoriteCount");
        session.removeAttribute("currentSentRequestCount");
        session.removeAttribute("currentReceivedRequestCount");
        session.removeAttribute("currentFavoriteCount");
    }
    
    // 특정 활동 배지 제거 (페이지 방문 시)
    private void markActivityAsSeen(HttpSession session, String activityType) {
        if ("sentRequest".equals(activityType)) {
            Integer currentCount = (Integer) session.getAttribute("currentSentRequestCount");
            if (currentCount != null) {
                session.setAttribute("lastSentRequestCount", currentCount);
            }
        } else if ("receivedRequest".equals(activityType)) {
            Integer currentCount = (Integer) session.getAttribute("currentReceivedRequestCount");
            if (currentCount != null) {
                session.setAttribute("lastReceivedRequestCount", currentCount);
            }
        } else if ("favorite".equals(activityType)) {
            Integer currentCount = (Integer) session.getAttribute("currentFavoriteCount");
            if (currentCount != null) {
                session.setAttribute("lastFavoriteCount", currentCount);
            }
        }
    }
    
    
    // 프로필 이미지 업로드
    @RequestMapping(value = "/upload-profile-image", method = RequestMethod.POST)
    @ResponseBody
    public ResponseEntity<Map<String, Object>> uploadProfileImage(
            @RequestParam("profileImage") org.springframework.web.multipart.MultipartFile file,
            HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return ResponseEntity.ok(response);
            }
            
            // 파일 검증
            if (file.isEmpty()) {
                response.put("success", false);
                response.put("message", "파일이 비어있습니다.");
                return ResponseEntity.ok(response);
            }
            
            // 파일 크기 체크 (5MB)
            if (file.getSize() > 5 * 1024 * 1024) {
                response.put("success", false);
                response.put("message", "파일 크기는 5MB 이하여야 합니다.");
                return ResponseEntity.ok(response);
            }
            
            // 파일 확장자 체크
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                response.put("success", false);
                response.put("message", "이미지 파일만 업로드 가능합니다.");
                return ResponseEntity.ok(response);
            }
            
            // 파일명 생성 (사용자 ID + 타임스탬프 + 확장자)
            String originalFileName = file.getOriginalFilename();
            String fileExtension = originalFileName.substring(originalFileName.lastIndexOf("."));
            String newFileName = loginUser.getUserId() + "_" + System.currentTimeMillis() + fileExtension;
            
            // 업로드 디렉토리 생성  
            String profileUploadPath = uploadPath + "profile/";
            java.io.File uploadDir = new java.io.File(profileUploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // 파일 저장
            java.io.File destFile = new java.io.File(profileUploadPath + newFileName);
            file.transferTo(destFile);
            
            // 데이터베이스에 프로필 이미지 정보 업데이트
            memberDAO.updateProfileImage(loginUser.getUserId(), newFileName);
            
            // 세션의 사용자 정보 업데이트
            loginUser.setProfileImage(newFileName);
            session.setAttribute("loginUser", loginUser);
            
            response.put("success", true);
            response.put("fileName", newFileName);
            response.put("message", "프로필 이미지가 성공적으로 업데이트되었습니다.");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "업로드 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
    
    /**
     * AI 저장 목록 페이지
     */
    @RequestMapping(value = "/ai-saved", method = RequestMethod.GET)
    public String aiSavedPage(HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        System.out.println("=== AI 저장 페이지 요청 시작 ===");
        
        // 로그인 상태 확인
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        System.out.println("로그인 사용자: " + (loginUser != null ? loginUser.getUserId() : "null"));
        if (loginUser == null) {
            System.out.println("로그인 사용자가 없음 - 로그인 페이지로 리디렉션");
            return "redirect:/member/login";
        }
        
        String userId = loginUser.getUserId();
        
        try {
            // 저장된 플레이리스트 조회 (실제 사용자 + 임시 사용자 모두 조회)
            List<SavedPlaylistDTO> savedPlaylists = new ArrayList<>();
            try {
                // 실제 사용자 플레이리스트 조회
                savedPlaylists = playlistDAO.getUserPlaylists(userId);
                System.out.println("사용자 " + userId + "의 저장된 플레이리스트: " + savedPlaylists.size() + "개");
                
                // 세션에 임시 사용자 ID가 있다면 해당 플레이리스트도 조회
                String tempUserId = (String) session.getAttribute("userId");
                if (tempUserId != null && tempUserId.startsWith("playlist_")) {
                    try {
                        List<SavedPlaylistDTO> tempPlaylists = playlistDAO.getUserPlaylists(tempUserId);
                        if (!tempPlaylists.isEmpty()) {
                            savedPlaylists.addAll(tempPlaylists);
                            System.out.println("임시 사용자 " + tempUserId + "의 플레이리스트: " + tempPlaylists.size() + "개 추가");
                        }
                    } catch (Exception tempE) {
                        System.err.println("임시 플레이리스트 조회 오류: " + tempE.getMessage());
                    }
                }
                
                System.out.println("총 플레이리스트 개수: " + savedPlaylists.size() + "개");
            } catch (Exception e) {
                System.err.println("저장된 플레이리스트 조회 오류: " + e.getMessage());
                savedPlaylists = new ArrayList<>();
            }
            
            // AI 여행 계획 조회
            List<TravelPlanSummaryDTO> savedAiPlans = new ArrayList<>();
            try {
                savedAiPlans = aiTravelPlanDAO.getUserTravelPlans(userId);
                System.out.println("사용자 " + userId + "의 AI 여행 계획: " + savedAiPlans.size() + "개");
            } catch (Exception e) {
                System.err.println("AI 여행 계획 조회 오류: " + e.getMessage());
                savedAiPlans = new ArrayList<>();
            }
            
            // 저장된 패킹리스트 조회 (임시로 빈 리스트 설정)
            List<Object> savedPackingLists = new ArrayList<>();
            int savedPackingCount = 0;
            // TODO: 패킹리스트 DAO가 구현되면 실제 데이터 조회
            // savedPackingLists = packingDAO.getUserPackingLists(userId);
            // savedPackingCount = savedPackingLists.size();
            
            // 개수 계산
            int savedPlaylistCount = savedPlaylists.size();
            int savedAiPlanCount = savedAiPlans.size();
            int totalCount = savedPlaylistCount + savedAiPlanCount + savedPackingCount;
            
            // 모델에 데이터 추가
            model.addAttribute("savedPlaylists", savedPlaylists);
            model.addAttribute("savedAiPlans", savedAiPlans);
            model.addAttribute("savedPackingLists", savedPackingLists);
            model.addAttribute("savedPlaylistCount", savedPlaylistCount);
            model.addAttribute("savedAiPlanCount", savedAiPlanCount);
            model.addAttribute("savedPackingCount", savedPackingCount);
            model.addAttribute("totalCount", totalCount);
            
            System.out.println("AI 저장 페이지 데이터 로드 완료 - 플레이리스트: " + savedPlaylistCount + "개, AI 계획: " + savedAiPlanCount + "개, 패킹리스트: " + savedPackingCount + "개");
            
        } catch (Exception e) {
            System.err.println("AI 저장 페이지 데이터 로드 중 전체 오류: " + e.getMessage());
            e.printStackTrace();
            
            // 오류 발생 시 빈 데이터로 설정
            model.addAttribute("savedPlaylists", new ArrayList<>());
            model.addAttribute("savedAiPlans", new ArrayList<>());
            model.addAttribute("savedPackingLists", new ArrayList<>());
            model.addAttribute("savedPlaylistCount", 0);
            model.addAttribute("savedAiPlanCount", 0);
            model.addAttribute("savedPackingCount", 0);
            model.addAttribute("totalCount", 0);
        }
        
        System.out.println("AI 저장 페이지 정상 반환 - member/ai-saved");
        return "member/ai-saved";
    }
    
    @RequestMapping(value = "/ai-plans", method = RequestMethod.GET)
    public String aiPlansPage(HttpSession session, RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("message", "로그인이 필요합니다.");
            return "redirect:/member/login";
        }
        
        return "member/ai-plans";
    }

    // 헬퍼 메서드: 특정 일자 이내인지 확인
    private boolean isWithinDays(Date date, int days) {
        if (date == null) return false;
        long diff = System.currentTimeMillis() - date.getTime();
        long daysDiff = diff / (1000 * 60 * 60 * 24);
        return daysDiff <= days;
    }

    // 헬퍼 메서드: 시간 경과 표시
    private String getTimeAgo(Date date) {
        if (date == null) return "";

        long diff = System.currentTimeMillis() - date.getTime();
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;

        if (days > 0) {
            return days + "일 전";
        } else if (hours > 0) {
            return hours + "시간 전";
        } else if (minutes > 0) {
            return minutes + "분 전";
        } else {
            return "방금 전";
        }
    }

    /**
     * 자기소개 업데이트 API
     */
    @RequestMapping(value = "/updateBio", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> updateBio(@RequestBody Map<String, String> request, HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }

            String bio = request.get("bio");

            // 자기소개 길이 제한 (500자)
            if (bio != null && bio.length() > 500) {
                response.put("success", false);
                response.put("message", "자기소개는 500자 이내로 작성해주세요.");
                return response;
            }

            // DAO를 통해 DB 업데이트
            int result = memberDAO.updateBio(loginUser.getUserId(), bio);

            if (result > 0) {
                // 세션 정보도 업데이트
                loginUser.setBio(bio);
                session.setAttribute("loginUser", loginUser);

                response.put("success", true);
                response.put("message", "자기소개가 성공적으로 저장되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "자기소개 저장에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return response;
    }

}