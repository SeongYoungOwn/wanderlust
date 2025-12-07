package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tour.project.dao.TravelJoinRequestDAO;
import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.NotificationDAO;
import com.tour.project.dao.TravelDAO;
import com.tour.project.dto.TravelJoinRequestDTO;
import com.tour.project.dto.TravelPlanDTO;
import com.tour.project.dto.NotificationDTO;
import com.tour.project.dto.MemberDTO;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Date;

@Controller
@RequestMapping("/travel")
public class TravelJoinRequestController {
    
    @Autowired
    private TravelJoinRequestDAO travelJoinRequestDAO;
    
    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private NotificationDAO notificationDAO;
    
    @Autowired
    private TravelDAO travelDAO;
    
    // 여행 동행 신청
    @RequestMapping(value = "/request/{planId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> requestJoin(@PathVariable int planId, 
                                          @RequestParam(required = false) String requestMessage,
                                          HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 동행 참여 신청 처리 시작 ===");
            System.out.println("planId: " + planId);
            System.out.println("userId: " + loginUser.getUserId());
            System.out.println("requestMessage: " + requestMessage);
            
            // 여행 계획 존재 확인
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                result.put("success", false);
                result.put("message", "존재하지 않는 여행 계획입니다.");
                return result;
            }
            
            // 자신의 여행 계획에는 신청할 수 없음
            if (travelPlan.getPlanWriter().equals(loginUser.getUserId())) {
                result.put("success", false);
                result.put("message", "본인이 작성한 여행 계획에는 신청할 수 없습니다.");
                return result;
            }
            
            // 거절된 신청이 있으면 삭제 (재신청 허용)
            travelJoinRequestDAO.deleteRejectedRequest(planId, loginUser.getUserId());

            // 이미 신청했는지 확인 (PENDING 또는 APPROVED 상태만 체크)
            boolean alreadyRequested = travelJoinRequestDAO.isAlreadyRequested(planId, loginUser.getUserId());
            if (alreadyRequested) {
                result.put("success", false);
                result.put("message", "이미 참여 신청한 여행 계획입니다.");
                return result;
            }
            
            // 참여 신청 데이터 생성
            TravelJoinRequestDTO joinRequest = new TravelJoinRequestDTO();
            joinRequest.setTravelPlanId(planId);
            joinRequest.setRequesterId(loginUser.getUserId());
            joinRequest.setRequestMessage(requestMessage != null ? requestMessage : "동행하고 싶습니다!");
            joinRequest.setStatus("PENDING");
            
            // 참여 신청 처리
            int requestResult = travelJoinRequestDAO.insertJoinRequest(joinRequest);
            System.out.println("참여 신청 처리 결과: " + requestResult);
            
            if (requestResult > 0) {
                // 여행 계획 작성자에게 알림 생성
                try {
                    NotificationDTO notification = new NotificationDTO();
                    notification.setUserId(travelPlan.getPlanWriter());
                    notification.setType("JOIN_REQUEST");
                    notification.setTitle("새로운 동행 신청");
                    notification.setMessage(loginUser.getUserName() + "님이 '" + travelPlan.getPlanTitle() + "' 여행에 동행 신청하셨습니다.");
                    notification.setRelatedId(planId);
                    notification.setIsRead(false);
                    
                    notificationDAO.insertNotification(notification);
                    System.out.println("알림 생성 완료");
                } catch (Exception notificationException) {
                    System.err.println("알림 생성 실패: " + notificationException.getMessage());
                }
                
                result.put("success", true);
                result.put("message", "동행 신청이 완료되었습니다. 작성자의 승인을 기다려주세요.");
            } else {
                result.put("success", false);
                result.put("message", "동행 신청에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("동행 신청 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "동행 신청 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 동행 신청 승인
    @RequestMapping(value = "/approve/{requestId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> approveRequest(@PathVariable int requestId,
                                             @RequestParam(required = false) String responseMessage,
                                             HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 동행 신청 승인 처리 시작 ===");
            System.out.println("requestId: " + requestId);
            System.out.println("responseMessage: " + responseMessage);
            
            // 신청 정보 조회
            TravelJoinRequestDTO joinRequest = travelJoinRequestDAO.getJoinRequestById(requestId);
            if (joinRequest == null) {
                result.put("success", false);
                result.put("message", "존재하지 않는 신청입니다.");
                return result;
            }
            
            // 여행 계획 작성자 확인
            if (!joinRequest.getPlanWriter().equals(loginUser.getUserId())) {
                result.put("success", false);
                result.put("message", "승인 권한이 없습니다.");
                return result;
            }
            
            // 이미 처리된 신청인지 확인
            if (!"PENDING".equals(joinRequest.getStatus())) {
                result.put("success", false);
                result.put("message", "이미 처리된 신청입니다.");
                return result;
            }
            
            // 신청 승인 처리
            int approveResult = travelJoinRequestDAO.updateJoinRequestStatus(requestId, "APPROVED", 
                    responseMessage != null ? responseMessage : "동행 신청이 승인되었습니다.", 
                    loginUser.getUserId());
            
            if (approveResult > 0) {
                // 승인된 사용자를 travel_participants 테이블에 추가
                try {
                    int participantResult = travelDAO.joinTravel(Long.valueOf(joinRequest.getTravelPlanId()), joinRequest.getRequesterId());
                    System.out.println("참여자 등록 결과: " + participantResult);
                } catch (Exception participantException) {
                    System.err.println("참여자 등록 실패: " + participantException.getMessage());
                    // 참여자 등록에 실패해도 승인 처리는 계속 진행
                }
                
                // 신청자에게 승인 알림 생성
                try {
                    NotificationDTO notification = new NotificationDTO();
                    notification.setUserId(joinRequest.getRequesterId());
                    notification.setType("JOIN_APPROVED");
                    notification.setTitle("동행 신청 승인");
                    notification.setMessage("'" + joinRequest.getTravelPlanTitle() + "' 여행의 동행 신청이 승인되었습니다.");
                    notification.setRelatedId(joinRequest.getTravelPlanId());
                    notification.setIsRead(false);
                    
                    notificationDAO.insertNotification(notification);
                    System.out.println("승인 알림 생성 완료");
                } catch (Exception notificationException) {
                    System.err.println("승인 알림 생성 실패: " + notificationException.getMessage());
                }
                
                result.put("success", true);
                result.put("message", "동행 신청을 승인했습니다.");
            } else {
                result.put("success", false);
                result.put("message", "승인 처리에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("승인 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "승인 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 동행 신청 거절
    @RequestMapping(value = "/reject/{requestId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> rejectRequest(@PathVariable int requestId,
                                           @RequestParam(required = false) String responseMessage,
                                           HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 동행 신청 거절 처리 시작 ===");
            System.out.println("requestId: " + requestId);
            System.out.println("responseMessage: " + responseMessage);
            
            // 신청 정보 조회
            TravelJoinRequestDTO joinRequest = travelJoinRequestDAO.getJoinRequestById(requestId);
            if (joinRequest == null) {
                result.put("success", false);
                result.put("message", "존재하지 않는 신청입니다.");
                return result;
            }
            
            // 여행 계획 작성자 확인
            if (!joinRequest.getPlanWriter().equals(loginUser.getUserId())) {
                result.put("success", false);
                result.put("message", "거절 권한이 없습니다.");
                return result;
            }
            
            // 이미 처리된 신청인지 확인
            if (!"PENDING".equals(joinRequest.getStatus())) {
                result.put("success", false);
                result.put("message", "이미 처리된 신청입니다.");
                return result;
            }
            
            // 신청 거절 처리
            int rejectResult = travelJoinRequestDAO.updateJoinRequestStatus(requestId, "REJECTED", 
                    responseMessage != null ? responseMessage : "동행 신청이 거절되었습니다.", 
                    loginUser.getUserId());
            
            if (rejectResult > 0) {
                // 신청자에게 거절 알림 생성
                try {
                    NotificationDTO notification = new NotificationDTO();
                    notification.setUserId(joinRequest.getRequesterId());
                    notification.setType("JOIN_REJECTED");
                    notification.setTitle("동행 신청 거절");
                    notification.setMessage("'" + joinRequest.getTravelPlanTitle() + "' 여행의 동행 신청이 거절되었습니다.");
                    notification.setRelatedId(joinRequest.getTravelPlanId());
                    notification.setIsRead(false);
                    
                    notificationDAO.insertNotification(notification);
                    System.out.println("거절 알림 생성 완료");
                } catch (Exception notificationException) {
                    System.err.println("거절 알림 생성 실패: " + notificationException.getMessage());
                }
                
                result.put("success", true);
                result.put("message", "동행 신청을 거절했습니다.");
            } else {
                result.put("success", false);
                result.put("message", "거절 처리에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("거절 처리 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "거절 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 내가 받은 동행 신청 목록 (여행 계획 작성자)
    @RequestMapping(value = "/requests/received", method = RequestMethod.GET)
    public String receivedRequests(HttpSession session, Model model, 
                                  RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        // 받은 동행 신청 활동 확인으로 표시
        markActivityAsSeen(session, "receivedRequest");
        
        try {
            List<TravelJoinRequestDTO> receivedRequests = 
                travelJoinRequestDAO.getJoinRequestsByPlanWriter(loginUser.getUserId());
            
            model.addAttribute("joinRequests", receivedRequests);
            model.addAttribute("requestType", "received");
            
        } catch (Exception e) {
            model.addAttribute("error", "동행 신청 목록을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            model.addAttribute("joinRequests", java.util.Collections.emptyList());
        }
        
        return "travel/joinRequests";
    }
    
    // 내가 보낸 동행 신청 목록 (신청자)
    @RequestMapping(value = "/requests/sent", method = RequestMethod.GET)
    public String sentRequests(HttpSession session, Model model,
                              RedirectAttributes redirectAttributes) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        
        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }
        
        // 보낸 동행 신청 활동 확인으로 표시
        markActivityAsSeen(session, "sentRequest");
        
        try {
            List<TravelJoinRequestDTO> sentRequests = 
                travelJoinRequestDAO.getJoinRequestsByRequester(loginUser.getUserId());
            
            model.addAttribute("joinRequests", sentRequests);
            model.addAttribute("requestType", "sent");
            
        } catch (Exception e) {
            model.addAttribute("error", "동행 신청 목록을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
            model.addAttribute("joinRequests", java.util.Collections.emptyList());
        }
        
        return "travel/joinRequests";
    }
    
    // 특정 여행 계획의 동행 신청 목록 조회 (AJAX)
    @RequestMapping(value = "/requests/{planId}", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> getJoinRequestsForPlan(@PathVariable int planId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            // 여행 계획 정보 조회
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(planId);
            if (travelPlan == null) {
                result.put("success", false);
                result.put("message", "존재하지 않는 여행 계획입니다.");
                return result;
            }
            
            // 작성자만 신청 목록 조회 가능
            if (!travelPlan.getPlanWriter().equals(loginUser.getUserId())) {
                result.put("success", false);
                result.put("message", "조회 권한이 없습니다.");
                return result;
            }
            
            List<TravelJoinRequestDTO> joinRequests = 
                travelJoinRequestDAO.getJoinRequestsByTravelPlan(planId);
            
            result.put("success", true);
            result.put("joinRequests", joinRequests);
            result.put("totalRequests", joinRequests.size());
            
        } catch (Exception e) {
            System.err.println("동행 신청 목록 조회 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "동행 신청 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // 동행 신청 취소
    @RequestMapping(value = "/request/cancel/{requestId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> cancelRequest(@PathVariable int requestId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        
        try {
            System.out.println("=== 동행 신청 취소 처리 시작 ===");
            System.out.println("requestId: " + requestId);
            System.out.println("userId: " + loginUser.getUserId());
            
            // 신청 정보 조회
            TravelJoinRequestDTO joinRequest = travelJoinRequestDAO.getJoinRequestById(requestId);
            if (joinRequest == null) {
                result.put("success", false);
                result.put("message", "존재하지 않는 신청입니다.");
                return result;
            }
            
            // 본인이 신청한 것인지 확인
            if (!joinRequest.getRequesterId().equals(loginUser.getUserId())) {
                result.put("success", false);
                result.put("message", "취소 권한이 없습니다.");
                return result;
            }
            
            // PENDING 상태의 신청만 취소 가능
            if (!"PENDING".equals(joinRequest.getStatus())) {
                result.put("success", false);
                result.put("message", "이미 처리된 신청은 취소할 수 없습니다.");
                return result;
            }
            
            // 신청 취소 (DELETE)
            int cancelResult = travelJoinRequestDAO.deleteJoinRequest(requestId);
            
            if (cancelResult > 0) {
                result.put("success", true);
                result.put("message", "동행 신청이 취소되었습니다.");
                System.out.println("동행 신청 취소 완료");
            } else {
                result.put("success", false);
                result.put("message", "취소 처리에 실패했습니다.");
            }
            
        } catch (Exception e) {
            System.err.println("동행 신청 취소 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "취소 처리 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return result;
    }
    
    // API: 받은 동행 신청 조회 (AJAX용)
    @RequestMapping(value = "/api/requests/received/{userId}", method = RequestMethod.GET)
    @ResponseBody
    public Map<String, Object> getReceivedRequestsApi(@PathVariable String userId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null || !loginUser.getUserId().equals(userId)) {
            result.put("success", false);
            result.put("message", "권한이 없습니다.");
            return result;
        }

        try {
            // 내가 받은 동행 신청 조회 (내가 작성한 여행에 대한 신청들)
            List<TravelJoinRequestDTO> receivedRequests = travelJoinRequestDAO.getJoinRequestsByPlanWriter(userId);

            result.put("success", true);
            result.put("requests", receivedRequests);

        } catch (Exception e) {
            System.err.println("받은 동행 신청 조회 중 오류: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "조회 중 오류가 발생했습니다.");
        }

        return result;
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
}