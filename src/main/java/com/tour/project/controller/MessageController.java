package com.tour.project.controller;

import com.tour.project.dao.MessageDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.MessageDTO;
import com.tour.project.dto.MemberDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/message")
public class MessageController {

    @Autowired
    private MessageDAO messageDAO;
    
    @Autowired
    private MemberDAO memberDAO;

    // 쪽지함 메인 페이지 (받은 쪽지함)
    @GetMapping("/inbox")
    public String inbox(Model model, HttpSession session,
                       @RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "10") int pageSize) {
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }

        // 페이징 처리
        int offset = (page - 1) * pageSize;
        Map<String, Object> params = new HashMap<>();
        params.put("userId", loginUser.getUserId());
        params.put("offset", offset);
        params.put("limit", pageSize);

        // 받은 쪽지 목록
        List<MessageDTO> receivedMessages = messageDAO.getReceivedMessages(params);
        
        // 전체 개수 (페이징용)
        int totalCount = messageDAO.getReceivedMessageCount(loginUser.getUserId());
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        
        // 읽지 않은 쪽지 개수
        int unreadCount = messageDAO.getUnreadMessageCount(loginUser.getUserId());

        model.addAttribute("messages", receivedMessages);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("unreadCount", unreadCount);
        model.addAttribute("messageType", "inbox");

        return "message/inbox";
    }

    // 보낸 쪽지함
    @GetMapping("/outbox")
    public String outbox(Model model, HttpSession session,
                        @RequestParam(defaultValue = "1") int page,
                        @RequestParam(defaultValue = "10") int pageSize) {
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }

        // 페이징 처리
        int offset = (page - 1) * pageSize;
        Map<String, Object> params = new HashMap<>();
        params.put("userId", loginUser.getUserId());
        params.put("offset", offset);
        params.put("limit", pageSize);

        // 보낸 쪽지 목록
        List<MessageDTO> sentMessages = messageDAO.getSentMessages(params);
        
        // 전체 개수 (페이징용)
        int totalCount = messageDAO.getSentMessageCount(loginUser.getUserId());
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);

        model.addAttribute("messages", sentMessages);
        model.addAttribute("currentPage", page);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("messageType", "outbox");

        return "message/outbox";
    }

    // 쪽지 상세보기
    @GetMapping("/view/{messageId}")
    public String viewMessage(@PathVariable int messageId, Model model, HttpSession session) {
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }

        MessageDTO message = messageDAO.getMessageById(messageId);
        if (message == null) {
            model.addAttribute("error", "존재하지 않는 쪽지입니다.");
            return "redirect:/message/inbox";
        }

        // 권한 확인 (본인이 보낸 쪽지이거나 받은 쪽지여야 함)
        if (!loginUser.getUserId().equals(message.getSenderId()) && 
            !loginUser.getUserId().equals(message.getReceiverId())) {
            model.addAttribute("error", "접근 권한이 없습니다.");
            return "redirect:/message/inbox";
        }

        // 받은 쪽지인 경우 읽음 처리
        if (loginUser.getUserId().equals(message.getReceiverId()) && !message.isRead()) {
            messageDAO.markAsRead(messageId);
            message.setRead(true);
        }

        model.addAttribute("message", message);
        model.addAttribute("isReceiver", loginUser.getUserId().equals(message.getReceiverId()));

        return "message/view";
    }

    // 쪽지 쓰기 폼
    @GetMapping("/compose")
    public String composeForm(@RequestParam(required = false) String receiverId,
                              @RequestParam(required = false) String to,
                              Model model, HttpSession session) {

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }

        // 'to' 파라미터가 있으면 receiverId로 사용
        if (to != null && !to.trim().isEmpty()) {
            receiverId = to;
        }

        // 수신자가 지정된 경우 해당 사용자 정보 조회
        if (receiverId != null && !receiverId.trim().isEmpty()) {
            MemberDTO receiver = memberDAO.getMemberById(receiverId);
            if (receiver != null) {
                model.addAttribute("receiverInfo", receiver);
            }
        }

        return "message/compose";
    }

    // 쪽지 전송 처리
    @PostMapping("/send")
    @ResponseBody
    public Map<String, Object> sendMessage(@RequestBody Map<String, String> requestData, HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        try {
            // 요청 데이터 추출
            String receiverId = requestData.get("receiverId");
            String receiverNickname = requestData.get("receiverNickname");
            String messageTitle = requestData.get("messageTitle") != null ? requestData.get("messageTitle") : requestData.get("title");
            String messageContent = requestData.get("messageContent") != null ? requestData.get("messageContent") : requestData.get("content");

            MemberDTO receiver = null;

            // receiverId가 있으면 ID로 조회, 없으면 닉네임으로 조회
            if (receiverId != null && !receiverId.trim().isEmpty()) {
                receiver = memberDAO.getMember(receiverId);
            } else if (receiverNickname != null && !receiverNickname.trim().isEmpty()) {
                receiver = memberDAO.getMemberByNickname(receiverNickname);
            }

            if (receiver == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 사용자입니다.");
                return response;
            }

            // 자기 자신에게 쪽지 보내기 방지
            if (loginUser.getUserId().equals(receiver.getUserId())) {
                response.put("success", false);
                response.put("message", "자기 자신에게는 쪽지를 보낼 수 없습니다.");
                return response;
            }

            // MessageDTO 생성
            MessageDTO message = new MessageDTO();
            message.setSenderId(loginUser.getUserId());
            message.setReceiverId(receiver.getUserId());
            message.setMessageTitle(messageTitle);
            message.setMessageContent(messageContent);

            int result = messageDAO.sendMessage(message);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "쪽지가 전송되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "쪽지 전송에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return response;
    }

    // 받은 쪽지 삭제
    @PostMapping("/delete/received")
    @ResponseBody
    public Map<String, Object> deleteReceivedMessage(@RequestParam int messageId, HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        try {
            Map<String, Object> params = new HashMap<>();
            params.put("messageId", messageId);
            params.put("userId", loginUser.getUserId());
            
            int result = messageDAO.deleteReceivedMessage(params);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "쪽지가 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "쪽지 삭제에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }

        return response;
    }

    // 보낸 쪽지 삭제
    @PostMapping("/delete/sent")
    @ResponseBody
    public Map<String, Object> deleteSentMessage(@RequestParam int messageId, HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        try {
            Map<String, Object> params = new HashMap<>();
            params.put("messageId", messageId);
            params.put("userId", loginUser.getUserId());
            
            int result = messageDAO.deleteSentMessage(params);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "쪽지가 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "쪽지 삭제에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다.");
        }

        return response;
    }

    // 읽지 않은 쪽지 개수 조회 (AJAX)
    @GetMapping("/unread-count")
    @ResponseBody
    public Map<String, Object> getUnreadCount(HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("count", 0);
            return response;
        }

        try {
            int unreadCount = messageDAO.getUnreadMessageCount(loginUser.getUserId());
            response.put("success", true);
            response.put("count", unreadCount);

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("count", 0);
        }

        return response;
    }
    
    // 닉네임 자동완성 검색 (AJAX)
    @GetMapping("/search-nicknames")
    @ResponseBody
    public Map<String, Object> searchNicknames(@RequestParam String query, HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("nicknames", new ArrayList<>());
            return response;
        }

        try {
            // 현재 사용자 제외하고 닉네임 검색
            List<MemberDTO> members = memberDAO.searchNicknamesByQuery(query, loginUser.getUserId());
            List<String> nicknames = new ArrayList<>();
            for (MemberDTO member : members) {
                if (member.getNickname() != null && !member.getNickname().trim().isEmpty()) {
                    nicknames.add(member.getNickname());
                }
            }
            
            response.put("success", true);
            response.put("nicknames", nicknames);

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("nicknames", new ArrayList<>());
        }

        return response;
    }
    
    // 쪽지 읽음 처리 (AJAX)
    @PostMapping("/mark-read")
    @ResponseBody
    public Map<String, Object> markMessageAsRead(@RequestBody Map<String, Integer> requestData, HttpSession session) {
        
        Map<String, Object> response = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        try {
            Integer messageId = requestData.get("messageId");
            if (messageId == null) {
                response.put("success", false);
                response.put("message", "잘못된 요청입니다.");
                return response;
            }
            
            // 메시지 존재 여부 및 권한 확인
            MessageDTO message = messageDAO.getMessageById(messageId);
            if (message == null) {
                response.put("success", false);
                response.put("message", "존재하지 않는 쪽지입니다.");
                return response;
            }
            
            // 받은 쪽지인지 확인
            if (!loginUser.getUserId().equals(message.getReceiverId())) {
                response.put("success", false);
                response.put("message", "접근 권한이 없습니다.");
                return response;
            }
            
            // 읽음 처리
            int result = messageDAO.markAsRead(messageId);
            if (result > 0) {
                response.put("success", true);
                response.put("message", "읽음 처리되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "읽음 처리에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return response;
    }
}