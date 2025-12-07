package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.ui.Model;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.core.io.Resource;
import org.springframework.core.io.FileSystemResource;

import org.springframework.beans.factory.annotation.Value;
import com.tour.project.config.WebSocketEventListener;

import com.tour.project.dao.TravelDAO;
import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.ChatMessageDAO;
import com.tour.project.dto.ChatMessageDTO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.TravelPlanDTO;
import com.tour.project.dto.TravelParticipantDTO;

import javax.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.HashSet;
import java.util.concurrent.ConcurrentHashMap;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.ArrayList;
import java.util.Collections;

@Controller
@RequestMapping("/chat")
public class ChatController {

    @Autowired(required = false)
    private SimpMessageSendingOperations messagingTemplate;
    
    @Autowired(required = false)
    private TravelDAO travelDAO;
    
    @Autowired(required = false)
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired(required = false)
    private ChatMessageDAO chatMessageDAO;
    
    @Value("${upload.path:E:/tour-project/uploads/}")
    private String uploadPath;

    /**
     * 채팅방 목록 조회 (사용자가 참여 중인 여행 계획)
     */
    @GetMapping("/rooms")
    public String chatRoomList(HttpSession session, Model model) {
        System.out.println("=== 채팅방 목록 조회 ===");

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            System.out.println("로그인되지 않은 사용자");
            return "redirect:/member/login";
        }

        try {
            String userId = loginUser.getUserId();
            System.out.println("사용자 ID: " + userId);

            // 사용자가 참여 중인 여행 계획(채팅방) 목록 조회
            List<TravelPlanDTO> chatRooms = travelPlanDAO.getMyParticipatingTravelPlans(userId);
            System.out.println("조회된 채팅방 개수: " + (chatRooms != null ? chatRooms.size() : 0));

            // 각 채팅방의 최근 메시지 조회
            if (chatRooms != null && !chatRooms.isEmpty()) {
                for (TravelPlanDTO room : chatRooms) {
                    try {
                        List<ChatMessageDTO> recentMessages = chatMessageDAO.getLatestMessages(room.getPlanId(), 1);
                        if (recentMessages != null && !recentMessages.isEmpty()) {
                            room.setLastMessage(recentMessages.get(0).getContent());
                            java.time.LocalDateTime lastMsgTime = recentMessages.get(0).getTimestamp();
                            if (lastMsgTime != null) {
                                room.setLastMessageTime(java.sql.Timestamp.valueOf(lastMsgTime));
                            }
                        }
                    } catch (Exception e) {
                        System.err.println("채팅방 " + room.getPlanId() + "의 최근 메시지 조회 오류: " + e.getMessage());
                    }
                }
            }

            model.addAttribute("chatRooms", chatRooms);
            model.addAttribute("loginUser", loginUser);

            System.out.println("채팅방 목록 조회 성공");
            return "chat/rooms";

        } catch (Exception e) {
            System.err.println("채팅방 목록 조회 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "채팅방 목록을 불러오는 중 오류가 발생했습니다.");
            return "chat/rooms";
        }
    }

    // 간단한 채팅방 직접 테스트 (복구된 상태)
    @GetMapping("/basic/{travelPlanId}")
    public String basicChatRoom(@PathVariable int travelPlanId, HttpSession session, Model model) {
        System.out.println("=== 기본 채팅방 접근 ===");
        System.out.println("travelPlanId: " + travelPlanId);
        
        // 테스트 사용자 생성
        MemberDTO loginUser = new MemberDTO();
        loginUser.setUserId("testUser");
        loginUser.setUserName("테스트사용자");
        session.setAttribute("loginUser", loginUser);
        
        // 테스트 여행 계획 생성
        TravelPlanDTO travelPlan = new TravelPlanDTO();
        travelPlan.setPlanId(travelPlanId);
        travelPlan.setPlanTitle("채팅방 #" + travelPlanId);
        travelPlan.setPlanDestination("여행지");
        travelPlan.setPlanWriter("admin");
        travelPlan.setPlanContent("채팅방입니다.");
        
        model.addAttribute("travelPlan", travelPlan);
        model.addAttribute("currentUser", loginUser);
        
        System.out.println("기본 채팅방 성공");
        return "chat/basicChatRoom";
    }
    
    // 최소한의 채팅방 (HTML 직접 응답으로 테스트)
    @GetMapping("/minimal/{travelPlanId}")
    @ResponseBody
    public String minimalChatRoom(@PathVariable int travelPlanId) {
        System.out.println("=== 최소한 채팅방 접근 (HTML 직접 응답) ===");
        
        String html = "<!DOCTYPE html>\n" +
                "<html>\n" +
                "<head>\n" +
                "    <meta charset='UTF-8'>\n" +
                "    <title>채팅방 " + travelPlanId + "</title>\n" +
                "    <script src='https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js'></script>\n" +
                "    <script src='https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js'></script>\n" +
                "    <style>\n" +
                "        body { font-family: Arial; margin: 20px; }\n" +
                "        #messages { height: 300px; border: 1px solid #ccc; overflow-y: auto; padding: 10px; margin: 10px 0; }\n" +
                "        #messageInput { width: 70%; padding: 10px; }\n" +
                "        button { padding: 10px 15px; background: #007bff; color: white; border: none; cursor: pointer; }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <h1>채팅방 #" + travelPlanId + "</h1>\n" +
                "    <p>사용자: user" + travelPlanId + "</p>\n" +
                "    \n" +
                "    <div id='messages'></div>\n" +
                "    \n" +
                "    <input type='text' id='messageInput' placeholder='메시지 입력...'>\n" +
                "    <button onclick='sendMessage()'>전송</button>\n" +
                "    \n" +
                "    <script>\n" +
                "        let stompClient = null;\n" +
                "        const travelPlanId = " + travelPlanId + ";\n" +
                "        const currentUserId = 'user" + travelPlanId + "';\n" +
                "        \n" +
                "        window.onload = function() {\n" +
                "            console.log('채팅방 로드 완료');\n" +
                "            document.getElementById('messageInput').addEventListener('keypress', function(e) {\n" +
                "                if (e.key === 'Enter') sendMessage();\n" +
                "            });\n" +
                "            connect();\n" +
                "        };\n" +
                "        \n" +
                "        function connect() {\n" +
                "            try {\n" +
                "                const socket = new SockJS('/ws');\n" +
                "                stompClient = Stomp.over(socket);\n" +
                "                stompClient.connect({}, function(frame) {\n" +
                "                    console.log('WebSocket 연결 성공:', frame);\n" +
                "                    stompClient.subscribe('/topic/chat/' + travelPlanId, function(message) {\n" +
                "                        const chatMessage = JSON.parse(message.body);\n" +
                "                        showMessage(chatMessage);\n" +
                "                    });\n" +
                "                    stompClient.send('/app/chat/' + travelPlanId + '/addUser', {}, JSON.stringify({\n" +
                "                        senderId: currentUserId,\n" +
                "                        senderName: currentUserId,\n" +
                "                        type: 'JOIN',\n" +
                "                        content: currentUserId + '님이 입장했습니다.'\n" +
                "                    }));\n" +
                "                }, function(error) {\n" +
                "                    console.error('연결 오류:', error);\n" +
                "                });\n" +
                "            } catch (error) {\n" +
                "                console.error('연결 시도 오류:', error);\n" +
                "            }\n" +
                "        }\n" +
                "        \n" +
                "        function sendMessage() {\n" +
                "            const input = document.getElementById('messageInput');\n" +
                "            const message = input.value.trim();\n" +
                "            if (message && stompClient) {\n" +
                "                stompClient.send('/app/chat/' + travelPlanId, {}, JSON.stringify({\n" +
                "                    senderId: currentUserId,\n" +
                "                    senderName: currentUserId,\n" +
                "                    content: message,\n" +
                "                    type: 'CHAT'\n" +
                "                }));\n" +
                "                input.value = '';\n" +
                "            }\n" +
                "        }\n" +
                "        \n" +
                "        function showMessage(message) {\n" +
                "            const messagesDiv = document.getElementById('messages');\n" +
                "            const messageDiv = document.createElement('div');\n" +
                "            messageDiv.textContent = message.senderName + ': ' + message.content;\n" +
                "            messagesDiv.appendChild(messageDiv);\n" +
                "            messagesDiv.scrollTop = messagesDiv.scrollHeight;\n" +
                "        }\n" +
                "    </script>\n" +
                "</body>\n" +
                "</html>";
        
        System.out.println("HTML 직접 응답 완료");
        return html;
    }


    /**
     * 내 채팅방 목록 페이지
     * 사용자가 참여 중인 모든 채팅방을 조회하여 표시
     * @since 2025.11.18
     */
    @GetMapping("/my-rooms")
    public String myChatRooms(HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        System.out.println("=== 내 채팅방 목록 페이지 접근 ===");

        MemberDTO currentUser = (MemberDTO) session.getAttribute("loginUser");

        if (currentUser == null) {
            System.out.println("로그인 사용자 없음 - 로그인 페이지로 리다이렉트");
            redirectAttributes.addFlashAttribute("error", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }

        System.out.println("로그인 사용자: " + currentUser.getUserId());

        try {
            // 사용자가 참여 중인 여행 계획 목록 조회
            List<TravelParticipantDTO> myTravels = travelDAO.getJoinedTravelsByUserId(currentUser.getUserId());
            System.out.println("조회된 여행 수: " + (myTravels != null ? myTravels.size() : "null"));

            // 각 여행 계획의 최신 메시지와 정보 조회
            List<Map<String, Object>> chatRoomList = new ArrayList<>();
            for (TravelParticipantDTO travel : myTravels) {
                Map<String, Object> roomInfo = new HashMap<>();
                roomInfo.put("travelId", travel.getTravelId());
                roomInfo.put("travelTitle", travel.getTravelTitle());
                roomInfo.put("destination", travel.getDestination());
                roomInfo.put("startDate", travel.getStartDate());
                roomInfo.put("endDate", travel.getEndDate());
                roomInfo.put("planWriter", travel.getPlanWriter());
                roomInfo.put("planWriterName", travel.getPlanWriterName());

                // 최신 메시지 조회
                List<ChatMessageDTO> recentMessages = chatMessageDAO.getRecentMessages(travel.getTravelId().intValue(), 1, 0);
                if (!recentMessages.isEmpty()) {
                    ChatMessageDTO lastMessage = recentMessages.get(0);
                    roomInfo.put("lastMessage", lastMessage.getContent());
                    roomInfo.put("lastMessageTime", lastMessage.getTimestamp());
                    roomInfo.put("lastSenderName", lastMessage.getSenderName());
                } else {
                    roomInfo.put("lastMessage", "아직 메시지가 없습니다.");
                    roomInfo.put("lastMessageTime", null);
                    roomInfo.put("lastSenderName", null);
                }

                // 참여자 수 조회
                int participantCount = travelDAO.getParticipantCount(travel.getTravelId());
                roomInfo.put("participantCount", participantCount);

                // 온라인 사용자 수 조회
                Set<String> onlineUsers = WebSocketEventListener.getChatRoomUsers().get(travel.getTravelId().intValue());
                roomInfo.put("onlineCount", onlineUsers != null ? onlineUsers.size() : 0);

                // 동행장 여부 확인
                roomInfo.put("isHost", currentUser.getUserId().equals(travel.getPlanWriter()));

                chatRoomList.add(roomInfo);
            }

            model.addAttribute("chatRooms", chatRoomList);
            model.addAttribute("currentUser", currentUser);

            return "chat/my-rooms";

        } catch (Exception e) {
            System.out.println("=== 내 채팅방 목록 조회 오류 ===");
            System.out.println("오류 메시지: " + e.getMessage());
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "채팅방 목록을 불러오는데 실패했습니다.");
            return "redirect:/home";
        }
    }

    // 채팅방 입장 페이지 (HTML 채팅방 UI)
    @GetMapping("/room/{travelPlanId}")
    @ResponseBody
    public String chatRoom(@PathVariable int travelPlanId, HttpSession session) {
        System.out.println("=== 메인 채팅방 접근 ===");
        System.out.println("travelPlanId: " + travelPlanId);
        
        try {
            // 세션에서 사용자 정보 가져오기
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                loginUser = new MemberDTO();
                loginUser.setUserId("user" + travelPlanId);
                loginUser.setUserName("사용자" + travelPlanId);
                session.setAttribute("loginUser", loginUser);
                System.out.println("새로운 사용자 생성: " + loginUser.getUserId());
            } else {
                System.out.println("기존 사용자: " + loginUser.getUserId());
            }
            
            // 여행 계획 정보 가져오기 (실제 여행 제목 표시용)
            String planTitle = "여행 계획 #" + travelPlanId;
            String destination = "미정";
            try {
                if (travelPlanDAO != null) {
                    TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(travelPlanId);
                    if (travelPlan != null) {
                        planTitle = travelPlan.getPlanTitle();
                        destination = travelPlan.getPlanDestination();
                        System.out.println("실제 여행 계획 정보 조회 성공: " + planTitle + " | " + destination);
                    } else {
                        System.out.println("여행 계획을 찾을 수 없습니다. ID: " + travelPlanId);
                    }
                } else {
                    System.err.println("TravelPlanDAO가 null입니다.");
                }
                System.out.println("채팅방 제목: " + planTitle + " | 목적지: " + destination);
            } catch (Exception e) {
                System.err.println("여행 계획 정보 조회 실패: " + e.getMessage());
                e.printStackTrace();
                // 기본값 사용
            }
            
            System.out.println("generateBeautifulChatRoom 호출 시작...");
            String html = generateBeautifulChatRoom(travelPlanId, loginUser.getUserId(), loginUser.getUserName(), planTitle, destination);
            
            System.out.println("채팅방 HTML 생성 완료, 길이: " + (html != null ? html.length() : "null"));
            return html;
            
        } catch (Exception e) {
            System.err.println("채팅방 접근 중 예외 발생:");
            e.printStackTrace();
            return "<html><body><h1>오류 발생</h1><p>" + e.getMessage() + "</p><pre>" + java.util.Arrays.toString(e.getStackTrace()) + "</pre></body></html>";
        }
    }
    
    // 채팅방 HTML 생성 메서드 (백업 파일 기반)
    private String generateChatRoomHTML(int travelPlanId, String userId, String userName, String roomTitle) {
        return "<!DOCTYPE html>\n" +
                "<html lang='ko'>\n" +
                "<head>\n" +
                "    <meta charset='UTF-8'>\n" +
                "    <title>" + roomTitle + "</title>\n" +
                "    <script src='https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js'></script>\\n" +
                "    <script src='https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js'></script>\\n" +
                "    <style>\\n" +
                "        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }\\n" +
                "        .chat-container { display: flex; max-width: 1200px; margin: 0 auto; gap: 20px; }\\n" +
                "        .chat-section { \\n" +
                "            flex: 1; \\n" +
                "            background: white; \\n" +
                "            padding: 20px; \\n" +
                "            border-radius: 10px; \\n" +
                "            box-shadow: 0 2px 10px rgba(0,0,0,0.1); \\n" +
                "        }\\n" +
                "        .participants { \\n" +
                "            width: 250px; \\n" +
                "            background: white; \\n" +
                "            padding: 15px; \\n" +
                "            border-radius: 10px; \\n" +
                "            box-shadow: 0 2px 10px rgba(0,0,0,0.1); \\n" +
                "            height: fit-content;\\n" +
                "        }\\n" +
                "        .header { \\n" +
                "            background: #4a90e2; \\n" +
                "            color: white; \\n" +
                "            padding: 15px; \\n" +
                "            border-radius: 10px; \\n" +
                "            margin-bottom: 20px; \\n" +
                "            text-align: center;\\n" +
                "        }\\n" +
                "        #messages { \\n" +
                "            height: 400px; \\n" +
                "            border: 1px solid #ddd; \\n" +
                "            border-radius: 10px; \\n" +
                "            overflow-y: auto; \\n" +
                "            padding: 15px; \\n" +
                "            margin-bottom: 15px; \\n" +
                "            background: #fafafa;\\n" +
                "        }\\n" +
                "        .message { \\n" +
                "            margin-bottom: 10px; \\n" +
                "            padding: 8px 12px; \\n" +
                "            background: #e9ecef; \\n" +
                "            border-radius: 15px; \\n" +
                "            max-width: 70%; \\n" +
                "        }\\n" +
                "        .message.own { \\n" +
                "            background: #4a90e2; \\n" +
                "            color: white; \\n" +
                "            margin-left: auto; \\n" +
                "        }\\n" +
                "        .system-message { \\n" +
                "            text-align: center; \\n" +
                "            color: #888; \\n" +
                "            font-style: italic; \\n" +
                "            margin: 10px 0; \\n" +
                "        }\\n" +
                "        .chat-input { display: flex; gap: 10px; }\\n" +
                "        .chat-input input { \\n" +
                "            flex: 1; \\n" +
                "            padding: 12px; \\n" +
                "            border: 1px solid #ddd; \\n" +
                "            border-radius: 20px; \\n" +
                "            outline: none; \\n" +
                "            font-size: 14px;\\n" +
                "        }\\n" +
                "        .chat-input button { \\n" +
                "            padding: 12px 20px; \\n" +
                "            background: #4a90e2; \\n" +
                "            color: white; \\n" +
                "            border: none; \\n" +
                "            border-radius: 20px; \\n" +
                "            cursor: pointer; \\n" +
                "            font-size: 14px;\\n" +
                "        }\\n" +
                "        .chat-input button:hover { background: #357abd; }\\n" +
                "        .participants h4 { margin-top: 0; color: #4a90e2; }\\n" +
                "        .participant { \\n" +
                "            padding: 8px 0; \\n" +
                "            color: #666; \\n" +
                "            border-bottom: 1px solid #eee; \\n" +
                "        }\\n" +
                "        .participant:last-child { border-bottom: none; }\\n" +
                "        .status { color: #28a745; font-weight: bold; margin-bottom: 15px; }\\n" +
                "        .error { color: #dc3545; font-weight: bold; margin-bottom: 15px; }\\n" +
                "    </style>\\n" +
                "</head>\\n" +
                "<body>\\n" +
                "    <div class='header'>\\n" +
                "        <h2>" + roomTitle + "</h2>\\n" +
                "        <p>사용자: " + userId + " (" + userName + ")</p>\\n" +
                "    </div>\\n" +
                "    \\n" +
                "    <div class='chat-container'>\\n" +
                "        <div class='chat-section'>\\n" +
                "            <div class='status' id='connectionStatus'>연결 중...</div>\\n" +
                "            \\n" +
                "            <div id='messages'>\\n" +
                "                <div class='system-message'>채팅방에 입장했습니다. 메시지를 입력해보세요!</div>\\n" +
                "            </div>\\n" +
                "            \\n" +
                "            <div class='chat-input'>\\n" +
                "                <input type='text' id='messageInput' placeholder='메세지를 입력하세여....' maxlength='500'>\\n" +
                "                <button onclick='sendMessage()'>전송</button>\\n" +
                "            </div>\\n" +
                "        </div>\\n" +
                "        \\n" +
                "        <div class='participants'>\\n" +
                "            <h4>참여자 (<span id='participantCount'>0</span>명)</h4>\\n" +
                "            <div id='participantsList'>\\n" +
                "                <div class='participant'>" + userId + " (나)</div>\\n" +
                "            </div>\\n" +
                "        </div>\\n" +
                "    </div>\\n" +
                "\\n" +
                "    <script>\\n" +
                "        let stompClient = null;\\n" +
                "        const travelPlanId = " + travelPlanId + ";\\n" +
                "        const currentUserId = '" + userId + "';\\n" +
                "        const currentUserName = '" + userName + "';\\n" +
                "        let isConnected = false;\\n" +
                "        \\n" +
                "        window.onload = function() {\\n" +
                "            console.log('채팅방 로드 완료');\\n" +
                "            \\n" +
                "            // Enter 키 이벤트\\n" +
                "            document.getElementById('messageInput').addEventListener('keypress', function(e) {\\n" +
                "                if (e.key === 'Enter') sendMessage();\\n" +
                "            });\\n" +
                "            \\n" +
                "            // 채팅 히스토리 로드\\n" +
                "            loadChatHistory();\\n" +
                "            \\n" +
                "            // WebSocket 연결\\n" +
                "            connect();\\n" +
                "        };\\n" +
                "        \\n" +
                "        // 채팅 히스토리 로드\\n" +
                "        function loadChatHistory() {\\n" +
                "            fetch('/chat/messages/' + travelPlanId + '?limit=50&offset=0')\\n" +
                "                .then(response => response.json())\\n" +
                "                .then(data => {\\n" +
                "                    if (data.success && data.messages) {\\n" +
                "                        document.getElementById('messages').innerHTML = '';\\n" +
                "                        data.messages.forEach(message => {\\n" +
                "                            displayMessage(message);\\n" +
                "                        });\\n" +
                "                    }\\n" +
                "                })\\n" +
                "                .catch(error => console.error('히스토리 로드 실패:', error));\\n" +
                "        }\\n" +
                "        \\n" +
                "        function connect() {\\n" +
                "            if (isConnected) return;\\n" +
                "            \\n" +
                "            try {\\n" +
                "                document.getElementById('connectionStatus').textContent = '연결 중...';\\n" +
                "                \\n" +
                "                const socket = new SockJS('/ws');\\n" +
                "                stompClient = Stomp.over(socket);\\n" +
                "\\n" +
                "                stompClient.connect({}, function(frame) {\\n" +
                "                    console.log('WebSocket 연결 성공:', frame);\\n" +
                "                    isConnected = true;\\n" +
                "                    document.getElementById('connectionStatus').textContent = '✅ 연결됨';\\n" +
                "                    document.getElementById('connectionStatus').className = 'status';\\n" +
                "\\n" +
                "                    // 채팅방 메시지 구독\\n" +
                "                    stompClient.subscribe('/topic/chat/' + travelPlanId, function(message) {\\n" +
                "                        const chatMessage = JSON.parse(message.body);\\n" +
                "                        displayMessage(chatMessage);\\n" +
                "                    });\\n" +
                "                    \\n" +
                "                    // 참여자 상태 구독\\n" +
                "                    stompClient.subscribe('/topic/participants/' + travelPlanId, function(message) {\\n" +
                "                        const participantData = JSON.parse(message.body);\\n" +
                "                        updateParticipants(participantData);\\n" +
                "                    });\\n" +
                "\\n" +
                "                    // 사용자 입장 알림\\n" +
                "                    stompClient.send('/app/chat/' + travelPlanId + '/addUser', {}, JSON.stringify({\\n" +
                "                        senderId: currentUserId,\\n" +
                "                        senderName: currentUserName,\\n" +
                "                        type: 'JOIN',\\n" +
                "                        content: currentUserName + '님이 입장했습니다.'\\n" +
                "                    }));\\n" +
                "\\n" +
                "                }, function(error) {\\n" +
                "                    console.error('연결 오류:', error);\\n" +
                "                    isConnected = false;\\n" +
                "                    document.getElementById('connectionStatus').textContent = '❌ 연결 실패';\\n" +
                "                    document.getElementById('connectionStatus').className = 'error';\\n" +
                "                });\\n" +
                "\\n" +
                "            } catch (error) {\\n" +
                "                console.error('연결 시도 오류:', error);\\n" +
                "                document.getElementById('connectionStatus').textContent = '❌ 연결 오류';\\n" +
                "                document.getElementById('connectionStatus').className = 'error';\\n" +
                "            }\\n" +
                "        }\\n" +
                "        \\n" +
                "        function sendMessage() {\\n" +
                "            const input = document.getElementById('messageInput');\\n" +
                "            const message = input.value.trim();\\n" +
                "\\n" +
                "            if (message && stompClient && isConnected) {\\n" +
                "                stompClient.send('/app/chat/' + travelPlanId, {}, JSON.stringify({\\n" +
                "                    senderId: currentUserId,\\n" +
                "                    senderName: currentUserName,\\n" +
                "                    content: message,\\n" +
                "                    type: 'CHAT'\\n" +
                "                }));\\n" +
                "                input.value = '';\\n" +
                "            }\\n" +
                "        }\\n" +
                "        \\n" +
                "        function displayMessage(message) {\\n" +
                "            const messagesDiv = document.getElementById('messages');\\n" +
                "            const messageDiv = document.createElement('div');\\n" +
                "            \\n" +
                "            if (message.type === 'JOIN' || message.type === 'LEAVE') {\\n" +
                "                messageDiv.className = 'system-message';\\n" +
                "                messageDiv.textContent = message.content;\\n" +
                "            } else {\\n" +
                "                messageDiv.className = 'message' + (message.senderId === currentUserId ? ' own' : '');\\n" +
                "                messageDiv.innerHTML = \\n" +
                "                    '<div><strong>' + message.senderName + ':</strong> ' + message.content + '</div>' +\\n" +
                "                    '<small style=\"display: block; margin-top: 3px; opacity: 0.7; font-size: 11px;\">' +\\n" +
                "                        formatTime(message.timestamp) + '</small>';\\n" +
                "            }\\n" +
                "            \\n" +
                "            messagesDiv.appendChild(messageDiv);\\n" +
                "            messagesDiv.scrollTop = messagesDiv.scrollHeight;\\n" +
                "        }\\n" +
                "        \\n" +
                "        // 참여자 목록 업데이트\\n" +
                "        function updateParticipants(data) {\\n" +
                "            const participantsList = document.getElementById('participantsList');\\n" +
                "            const participantCount = document.getElementById('participantCount');\\n" +
                "            \\n" +
                "            participantsList.innerHTML = '';\\n" +
                "            \\n" +
                "            if (data.participants && data.participants.length > 0) {\\n" +
                "                data.participants.forEach(userId => {\\n" +
                "                    const div = document.createElement('div');\\n" +
                "                    div.className = 'participant';\\n" +
                "                    div.innerHTML = userId + (userId === currentUserId ? ' (나)' : '');\\n" +
                "                    participantsList.appendChild(div);\\n" +
                "                });\\n" +
                "                participantCount.textContent = data.participants.length;\\n" +
                "            } else {\\n" +
                "                participantCount.textContent = '0';\\n" +
                "            }\\n" +
                "        }\\n" +
                "        \\n" +
                "        // 시간 포맷팅\\n" +
                "        function formatTime(timestamp) {\\n" +
                "            if (!timestamp) return '';\\n" +
                "            const date = new Date(timestamp);\\n" +
                "            return date.toLocaleTimeString('ko-KR', { \\n" +
                "                hour: '2-digit', \\n" +
                "                minute: '2-digit' \\n" +
                "            });\\n" +
                "        }\\n" +
                "\\n" +
                "        // 페이지 나가기 전 정리\\n" +
                "        window.onbeforeunload = function() {\\n" +
                "            if (stompClient && isConnected) {\\n" +
                "                stompClient.send('/app/chat/' + travelPlanId + '/removeUser', {}, JSON.stringify({\\n" +
                "                    senderId: currentUserId,\\n" +
                "                    senderName: currentUserName,\\n" +
                "                    type: 'LEAVE',\\n" +
                "                    content: currentUserName + '님이 나갔습니다.'\\n" +
                "                }));\\n" +
                "                stompClient.disconnect();\\n" +
                "            }\\n" +
                "        };\\n" +
                "    </script>\\n" +
                "</body>\\n" +
                "</html>";
    }
    
    // 백업 파일 기반 아름다운 채팅방 HTML 생성
    private String generateBeautifulChatRoom(int travelPlanId, String userId, String userName, String planTitle, String destination) {
        try {
            System.out.println("generateBeautifulChatRoom 메서드 진입");
            System.out.println("매개변수: travelPlanId=" + travelPlanId + ", userId=" + userId + ", userName=" + userName + ", planTitle=" + planTitle + ", destination=" + destination);
            
            // 완전한 채팅방 HTML 생성
            String html = "<!DOCTYPE html>\n" +
                "<html lang=\"ko\">\n" +
                "<head>\n" +
                "    <meta charset=\"UTF-8\">\n" +
                "    <title>" + planTitle + " - 채팅방</title>\n" +
                "    <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css\">\n" +
                "    <script src=\"https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js\"></script>\n" +
                "    <script src=\"https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js\"></script>\n" +
                "    <style>\n" +
                "        :root {\n" +
                "            --primary-color: #0052D4;\n" +
                "            --secondary-color: #4364F7;\n" +
                "            --accent-color: #FF8C00;\n" +
                "            --text-dark: #1A202C;\n" +
                "            --gradient-primary: linear-gradient(135deg, var(--primary-color), var(--secondary-color));\n" +
                "            --gradient-accent: linear-gradient(135deg, var(--accent-color), #FF6B6B);\n" +
                "        }\n" +
                "        * {\n" +
                "            margin: 0;\n" +
                "            padding: 0;\n" +
                "            box-sizing: border-box;\n" +
                "        }\n" +
                "        body {\n" +
                "            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;\n" +
                "            background: #fdfbf7;\n" +
                "            color: #2d3748;\n" +
                "            margin: 0;\n" +
                "            padding: 0;\n" +
                "        }\n" +
                "        /* 공통 헤더 스타일 */\n" +
                "        header {\n" +
                "            background: rgba(253, 251, 247, 0.95);\n" +
                "            backdrop-filter: blur(15px);\n" +
                "            padding: 1rem 0;\n" +
                "            position: fixed;\n" +
                "            width: 100%;\n" +
                "            top: 0;\n" +
                "            z-index: 1000;\n" +
                "            transition: all 0.3s ease;\n" +
                "            border-bottom: 1px solid rgba(255, 107, 107, 0.1);\n" +
                "        }\n" +
                "        nav {\n" +
                "            display: flex;\n" +
                "            justify-content: space-between;\n" +
                "            align-items: center;\n" +
                "            max-width: 1200px;\n" +
                "            margin: 0 auto;\n" +
                "            padding: 0 20px;\n" +
                "        }\n" +
                "        .logo {\n" +
                "            font-size: 2rem;\n" +
                "            font-weight: 800;\n" +
                "            background: linear-gradient(135deg, #ff6b6b, #ffd93d);\n" +
                "            -webkit-background-clip: text;\n" +
                "            -webkit-text-fill-color: transparent;\n" +
                "            background-clip: text;\n" +
                "            letter-spacing: -0.02em;\n" +
                "            text-decoration: none;\n" +
                "        }\n" +
                "        .nav-links {\n" +
                "            display: flex;\n" +
                "            list-style: none;\n" +
                "            gap: 2rem;\n" +
                "            margin: 0;\n" +
                "            padding: 0;\n" +
                "        }\n" +
                "        .nav-links a {\n" +
                "            text-decoration: none;\n" +
                "            color: #2d3748;\n" +
                "            font-weight: 500;\n" +
                "            font-size: 0.95rem;\n" +
                "            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);\n" +
                "            position: relative;\n" +
                "            padding: 0.75rem 1rem;\n" +
                "            border-radius: 12px;\n" +
                "            backdrop-filter: blur(10px);\n" +
                "        }\n" +
                "        .nav-links a:hover {\n" +
                "            color: #667eea;\n" +
                "            background: rgba(102, 126, 234, 0.08);\n" +
                "            transform: translateY(-1px);\n" +
                "        }\n" +
                "        .nav-links a::before {\n" +
                "            content: '';\n" +
                "            position: absolute;\n" +
                "            bottom: 0;\n" +
                "            left: 50%;\n" +
                "            width: 0;\n" +
                "            height: 2px;\n" +
                "            background: linear-gradient(90deg, #667eea, #764ba2);\n" +
                "            transition: all 0.3s ease;\n" +
                "            transform: translateX(-50%);\n" +
                "            border-radius: 2px;\n" +
                "        }\n" +
                "        .nav-links a:hover::before {\n" +
                "            width: 80%;\n" +
                "        }\n" +
                "        .nav-links a.active {\n" +
                "            color: #ff6b6b;\n" +
                "            background: linear-gradient(135deg, rgba(255, 107, 107, 0.15), rgba(78, 205, 196, 0.15));\n" +
                "            font-weight: 600;\n" +
                "        }\n" +
                "        .nav-links a.active::before {\n" +
                "            width: 80%;\n" +
                "            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);\n" +
                "        }\n" +
                "        .nav-actions {\n" +
                "            display: flex;\n" +
                "            gap: 1rem;\n" +
                "            align-items: center;\n" +
                "        }\n" +
                "        .user-toggle {\n" +
                "            background: transparent;\n" +
                "            color: #4a5568;\n" +
                "            border: 2px solid rgba(255, 107, 107, 0.3);\n" +
                "            padding: 0.7rem 1.5rem;\n" +
                "            border-radius: 25px;\n" +
                "            cursor: pointer;\n" +
                "            font-weight: 500;\n" +
                "            transition: all 0.3s ease;\n" +
                "            text-decoration: none;\n" +
                "            display: inline-block;\n" +
                "        }\n" +
                "        .user-toggle:hover {\n" +
                "            background: #ff6b6b;\n" +
                "            color: white;\n" +
                "            transform: translateY(-2px);\n" +
                "        }\n" +
                "        .user-menu {\n" +
                "            position: relative;\n" +
                "            display: inline-block;\n" +
                "        }\n" +
                "        .user-dropdown {\n" +
                "            position: absolute;\n" +
                "            top: 100%;\n" +
                "            right: 0;\n" +
                "            background: white;\n" +
                "            border-radius: 15px;\n" +
                "            box-shadow: 0 15px 40px rgba(0,0,0,0.15);\n" +
                "            border: 1px solid rgba(255, 107, 107, 0.1);\n" +
                "            min-width: 200px;\n" +
                "            opacity: 0;\n" +
                "            visibility: hidden;\n" +
                "            transform: translateY(-10px);\n" +
                "            transition: all 0.3s ease;\n" +
                "            margin-top: 0.5rem;\n" +
                "        }\n" +
                "        .user-menu:hover .user-dropdown {\n" +
                "            opacity: 1;\n" +
                "            visibility: visible;\n" +
                "            transform: translateY(0);\n" +
                "        }\n" +
                "        .user-dropdown a {\n" +
                "            display: block;\n" +
                "            padding: 0.75rem 1.5rem;\n" +
                "            color: #4a5568;\n" +
                "            text-decoration: none;\n" +
                "            font-weight: 500;\n" +
                "            transition: all 0.3s ease;\n" +
                "            border-bottom: 1px solid rgba(255, 107, 107, 0.1);\n" +
                "        }\n" +
                "        .user-dropdown a:last-child {\n" +
                "            border-bottom: none;\n" +
                "        }\n" +
                "        .user-dropdown a:hover {\n" +
                "            background: linear-gradient(135deg, rgba(255, 107, 107, 0.1), rgba(255, 217, 61, 0.1));\n" +
                "            color: #ff6b6b;\n" +
                "            transform: translateX(5px);\n" +
                "        }\n" +
                "        .hamburger {\n" +
                "            display: none;\n" +
                "            flex-direction: column;\n" +
                "            cursor: pointer;\n" +
                "            padding: 0.5rem;\n" +
                "        }\n" +
                "        .hamburger span {\n" +
                "            width: 25px;\n" +
                "            height: 3px;\n" +
                "            background: #ff6b6b;\n" +
                "            margin: 3px 0;\n" +
                "            transition: 0.3s;\n" +
                "            border-radius: 2px;\n" +
                "        }\n" +
                "        .chat-body {\n" +
                "            margin-top: 100px;\n" +
                "        }\n" +
                "        .main-content {\n" +
                "            padding: 20px;\n" +
                "        }\n" +
                "        .chat-container {\n" +
                "            max-width: 1200px;\n" +
                "            margin: 2rem auto;\n" +
                "            display: flex;\n" +
                "            gap: 20px;\n" +
                "            padding: 0 20px;\n" +
                "        }\n" +
                "        .chat-main {\n" +
                "            flex: 1;\n" +
                "        }\n" +
                "        .participants-sidebar {\n" +
                "            width: 280px;\n" +
                "            background: white;\n" +
                "            border-radius: 20px;\n" +
                "            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);\n" +
                "            padding: 20px;\n" +
                "            height: calc(100vh - 200px);\n" +
                "            margin-top: 100px;\n" +
                "            position: sticky;\n" +
                "            top: 120px;\n" +
                "            display: flex;\n" +
                "            flex-direction: column;\n" +
                "        }\n" +
                "        .participants-list {\n" +
                "            flex: 1;\n" +
                "            overflow-y: auto;\n" +
                "            padding-right: 8px;\n" +
                "            margin-right: -8px;\n" +
                "        }\n" +
                "        .participants-list::-webkit-scrollbar {\n" +
                "            width: 6px;\n" +
                "        }\n" +
                "        .participants-list::-webkit-scrollbar-track {\n" +
                "            background: #f1f5f9;\n" +
                "            border-radius: 10px;\n" +
                "        }\n" +
                "        .participants-list::-webkit-scrollbar-thumb {\n" +
                "            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));\n" +
                "            border-radius: 10px;\n" +
                "        }\n" +
                "        .participants-list::-webkit-scrollbar-thumb:hover {\n" +
                "            background: var(--accent-color);\n" +
                "        }\n" +
                "        .back-button {\n" +
                "            margin-bottom: 30px;\n" +
                "        }\n" +
                "        .back-button a {\n" +
                "            display: inline-flex;\n" +
                "            align-items: center;\n" +
                "            gap: 8px;\n" +
                "            background: var(--gradient-accent);\n" +
                "            color: white;\n" +
                "            padding: 12px 24px;\n" +
                "            text-decoration: none;\n" +
                "            border-radius: 25px;\n" +
                "            font-weight: 600;\n" +
                "            box-shadow: 0 4px 15px rgba(255, 140, 0, 0.3);\n" +
                "        }\n" +
                "        .chat-header {\n" +
                "            background: var(--gradient-primary);\n" +
                "            color: white;\n" +
                "            padding: 30px;\n" +
                "            border-radius: 20px 20px 0 0;\n" +
                "            text-align: center;\n" +
                "            box-shadow: 0 4px 20px rgba(0, 82, 212, 0.2);\n" +
                "        }\n" +
                "        .chat-header h3 {\n" +
                "            font-size: 1.8rem;\n" +
                "            margin: 0;\n" +
                "        }\n" +
                "        .connection-status {\n" +
                "            text-align: center;\n" +
                "            padding: 10px;\n" +
                "            border-radius: 10px;\n" +
                "            margin: 10px 0;\n" +
                "            font-weight: 600;\n" +
                "        }\n" +
                "        .connection-status.connecting {\n" +
                "            background: #fef3c7;\n" +
                "            color: #92400e;\n" +
                "        }\n" +
                "        .connection-status.connected {\n" +
                "            background: #d1fae5;\n" +
                "            color: #047857;\n" +
                "        }\n" +
                "        .connection-status.error {\n" +
                "            background: #fee2e2;\n" +
                "            color: #dc2626;\n" +
                "        }\n" +
                "        .chat-messages {\n" +
                "            height: 500px;\n" +
                "            overflow-y: auto;\n" +
                "            border: 1px solid #e2e8f0;\n" +
                "            border-top: none;\n" +
                "            padding: 20px;\n" +
                "            background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);\n" +
                "            border-radius: 0 0 20px 20px;\n" +
                "        }\n" +
                "        .message {\n" +
                "            margin-bottom: 15px;\n" +
                "            padding: 12px 18px;\n" +
                "            border-radius: 18px;\n" +
                "            max-width: 75%;\n" +
                "        }\n" +
                "        .message.own {\n" +
                "            background: var(--gradient-primary);\n" +
                "            color: white;\n" +
                "            margin-left: auto;\n" +
                "            text-align: right;\n" +
                "        }\n" +
                "        .message.other {\n" +
                "            background: white;\n" +
                "            border: 2px solid #e2e8f0;\n" +
                "            color: var(--text-dark);\n" +
                "        }\n" +
                "        .message.system {\n" +
                "            background: #f1f5f9;\n" +
                "            text-align: center;\n" +
                "            margin: 10px auto;\n" +
                "            font-style: italic;\n" +
                "            color: #718096;\n" +
                "            border-radius: 25px;\n" +
                "            max-width: 60%;\n" +
                "        }\n" +
                "        .message-info {\n" +
                "            font-size: 0.7rem;\n" +
                "            opacity: 0.7;\n" +
                "            margin-top: 8px;\n" +
                "            font-weight: 400;\n" +
                "            letter-spacing: 0.3px;\n" +
                "        }\n" +
                "        .message.own .message-info {\n" +
                "            color: rgba(255, 255, 255, 0.7);\n" +
                "            text-align: right;\n" +
                "        }\n" +
                "        .message.other .message-info {\n" +
                "            color: #a0aec0;\n" +
                "            text-align: left;\n" +
                "        }\n" +
                "        .message-time {\n" +
                "            display: block;\n" +
                "            font-size: 0.65rem;\n" +
                "            opacity: 0.6;\n" +
                "            margin-top: 4px;\n" +
                "        }\n" +
                "        .chat-input-container {\n" +
                "            margin-top: 20px;\n" +
                "            padding: 20px;\n" +
                "            background: white;\n" +
                "            border-radius: 20px;\n" +
                "            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);\n" +
                "        }\n" +
                "        .chat-input {\n" +
                "            display: flex;\n" +
                "            gap: 15px;\n" +
                "        }\n" +
                "        .chat-input input {\n" +
                "            flex: 1;\n" +
                "            padding: 15px 20px;\n" +
                "            border: 2px solid #e2e8f0;\n" +
                "            border-radius: 25px;\n" +
                "            font-size: 1rem;\n" +
                "            background: #f8fafc;\n" +
                "        }\n" +
                "        .chat-input input:focus {\n" +
                "            outline: none;\n" +
                "            border-color: var(--primary-color);\n" +
                "            background: white;\n" +
                "        }\n" +
                "        .chat-input button {\n" +
                "            padding: 15px 25px;\n" +
                "            background: var(--gradient-accent);\n" +
                "            color: white;\n" +
                "            border: none;\n" +
                "            border-radius: 25px;\n" +
                "            font-weight: 600;\n" +
                "            cursor: pointer;\n" +
                "        }\n" +
                "        .participants-header {\n" +
                "            text-align: center;\n" +
                "            border-bottom: 2px solid #e2e8f0;\n" +
                "            padding-bottom: 15px;\n" +
                "            margin-bottom: 20px;\n" +
                "        }\n" +
                "        .participants-header h4 {\n" +
                "            margin: 0;\n" +
                "            color: var(--text-dark);\n" +
                "            font-size: 1.2rem;\n" +
                "            font-weight: 700;\n" +
                "        }\n" +
                "        .participant-item {\n" +
                "            display: flex;\n" +
                "            align-items: center;\n" +
                "            padding: 12px;\n" +
                "            margin-bottom: 8px;\n" +
                "            border-radius: 12px;\n" +
                "            background: #f8fafc;\n" +
                "            transition: all 0.3s ease;\n" +
                "        }\n" +
                "        .participant-item:hover {\n" +
                "            background: #edf2f7;\n" +
                "            transform: translateY(-1px);\n" +
                "        }\n" +
                "        .status-indicator {\n" +
                "            width: 12px;\n" +
                "            height: 12px;\n" +
                "            border-radius: 50%;\n" +
                "            margin-right: 12px;\n" +
                "            background: #10b981;\n" +
                "        }\n" +
                "        .participant-info {\n" +
                "            flex: 1;\n" +
                "        }\n" +
                "        .participant-name {\n" +
                "            font-weight: 600;\n" +
                "            color: var(--text-dark);\n" +
                "            margin-bottom: 2px;\n" +
                "        }\n" +
                "        .participant-status {\n" +
                "            font-size: 0.8rem;\n" +
                "            color: #6c757d;\n" +
                "        }\n" +
                "        .file-upload-section {\n" +
                "            display: flex;\n" +
                "            align-items: center;\n" +
                "            gap: 10px;\n" +
                "            margin-top: 10px;\n" +
                "        }\n" +
                "        .file-upload-button {\n" +
                "            padding: 8px 12px;\n" +
                "            background: #4a90e2;\n" +
                "            color: white;\n" +
                "            border: none;\n" +
                "            border-radius: 15px;\n" +
                "            font-size: 0.9rem;\n" +
                "            cursor: pointer;\n" +
                "            transition: all 0.3s ease;\n" +
                "        }\n" +
                "        .file-upload-button:hover {\n" +
                "            background: #357abd;\n" +
                "            transform: translateY(-1px);\n" +
                "        }\n" +
                "        #fileInput {\n" +
                "            display: none;\n" +
                "        }\n" +
                "        .file-preview {\n" +
                "            max-width: 100%;\n" +
                "            margin: 10px 0;\n" +
                "            padding: 10px;\n" +
                "            border: 1px solid #ddd;\n" +
                "            border-radius: 10px;\n" +
                "            background: #f9f9f9;\n" +
                "        }\n" +
                "        .file-message {\n" +
                "            display: flex;\n" +
                "            align-items: center;\n" +
                "            gap: 10px;\n" +
                "            padding: 10px;\n" +
                "            border: 1px solid #ddd;\n" +
                "            border-radius: 10px;\n" +
                "            background: #f8f9fa;\n" +
                "        }\n" +
                "        .file-icon {\n" +
                "            width: 24px;\n" +
                "            height: 24px;\n" +
                "            background: #4a90e2;\n" +
                "            border-radius: 4px;\n" +
                "            display: flex;\n" +
                "            align-items: center;\n" +
                "            justify-content: center;\n" +
                "            color: white;\n" +
                "            font-size: 12px;\n" +
                "        }\n" +
                "        .file-info {\n" +
                "            flex: 1;\n" +
                "        }\n" +
                "        .file-name {\n" +
                "            font-weight: 600;\n" +
                "            color: #333;\n" +
                "        }\n" +
                "        .file-size {\n" +
                "            font-size: 0.8rem;\n" +
                "            color: #666;\n" +
                "        }\n" +
                "        .uploaded-image {\n" +
                "            max-width: 300px;\n" +
                "            max-height: 200px;\n" +
                "            border-radius: 10px;\n" +
                "            box-shadow: 0 2px 8px rgba(0,0,0,0.1);\n" +
                "            cursor: pointer;\n" +
                "        }\n" +
                "        .upload-progress {\n" +
                "            width: 100%;\n" +
                "            height: 4px;\n" +
                "            background: #f0f0f0;\n" +
                "            border-radius: 2px;\n" +
                "            overflow: hidden;\n" +
                "            margin-top: 5px;\n" +
                "        }\n" +
                "        .upload-progress-bar {\n" +
                "            height: 100%;\n" +
                "            background: var(--gradient-primary);\n" +
                "            transition: width 0.3s ease;\n" +
                "        }\n" +
                "    </style>\n" +
                "</head>\n" +
                "<body>\n" +
                "    <!-- 공통 헤더 -->\n" +
                "    <header>\n" +
                "        <nav>\n" +
                "            <a href=\"/home\" class=\"logo\">Wanderlust</a>\n" +
                "            \n" +
                "            <ul class=\"nav-links\">\n" +
                "                <li><a href=\"/travel/list\" data-page=\"travel\"><i class=\"fas fa-map-marked-alt me-1\"></i>여행 계획</a></li>\n" +
                "                <li><a href=\"/board/list\" data-page=\"board\"><i class=\"fas fa-comments me-1\"></i>커뮤니티</a></li>\n" +
                "                <li><a href=\"/travel-mbti/test\" data-page=\"travel-mbti\"><i class=\"fas fa-user-tag me-1\"></i>여행 MBTI</a></li>\n" +
                "                <li><a href=\"/ai/model\" data-page=\"ai-model\"><i class=\"fas fa-brain me-1\"></i>AI 모델</a></li>\n" +
                "                <li><a href=\"/notice/list\" data-page=\"notice\"><i class=\"fas fa-bullhorn me-1\"></i>공지사항</a></li>\n" +
                "            </ul>\n" +
                "            \n" +
                "            <div class=\"nav-actions\">\n" +
                "                <div class=\"user-menu\">\n" +
                "                    <a href=\"#\" class=\"user-toggle\">\n" +
                "                        <i class=\"fas fa-user me-1\"></i>" + userName + "님\n" +
                "                    </a>\n" +
                "                    <div class=\"user-dropdown\">\n" +
                "                        <a href=\"/member/mypage\">\n" +
                "                            <i class=\"fas fa-user-circle me-2\"></i>마이페이지\n" +
                "                        </a>\n" +
                "                        <a href=\"/manner/my-evaluations\">\n" +
                "                            <i class=\"fas fa-star me-2\"></i>내 매너 평가\n" +
                "                        </a>\n" +
                "                        <a href=\"/travel-mbti/history\">\n" +
                "                            <i class=\"fas fa-user-tag me-2\"></i>여행 MBTI 기록\n" +
                "                        </a>\n" +
                "                        <a href=\"/travel/create\">\n" +
                "                            <i class=\"fas fa-plus-circle me-2\"></i>여행 계획 만들기\n" +
                "                        </a>\n" +
                "                        <a href=\"/board/create\">\n" +
                "                            <i class=\"fas fa-pen me-2\"></i>글쓰기\n" +
                "                        </a>\n" +
                "                        <a href=\"/member/logout\">\n" +
                "                            <i class=\"fas fa-sign-out-alt me-2\"></i>로그아웃\n" +
                "                        </a>\n" +
                "                    </div>\n" +
                "                </div>\n" +
                "                <div class=\"hamburger\">\n" +
                "                    <span></span>\n" +
                "                    <span></span>\n" +
                "                    <span></span>\n" +
                "                </div>\n" +
                "            </div>\n" +
                "        </nav>\n" +
                "    </header>\n" +
                "    \n" +
                "    <div class=\"chat-body\">\n" +
                "    <div class=\"chat-container\">\n" +
                "        <div class=\"chat-main\">\n" +
                "            <div class=\"back-button\">\n" +
                "                <a href=\"javascript:history.back()\">← 뒤로 가기</a>\n" +
                "            </div>\n" +
                "            \n" +
                "            <div class=\"chat-header\">\n" +
                "                <h3>🗺️ " + planTitle + "</h3>\n" +
                "                <small>📍 목적지: " + destination + " | 👤 " + userName + "님</small>\n" +
                "            </div>\n" +
                "            \n" +
                "            <div class=\"connection-status connecting\" id=\"connectionStatus\">연결 중...</div>\n" +
                "            \n" +
                "            <div class=\"chat-messages\" id=\"messages\">\n" +
                "                <div class=\"message system\">\n" +
                "                    채팅방에 입장했습니다. 메시지를 입력해보세요!\n" +
                "                </div>\n" +
                "            </div>\n" +
                "            \n" +
                "            <div class=\"chat-input-container\">\n" +
                "                <div class=\"chat-input\">\n" +
                "                    <input type=\"text\" id=\"messageInput\" placeholder=\"메세지를 입력하세여....\" maxlength=\"500\">\n" +
                "                    <button onclick=\"sendMessage()\">전송</button>\n" +
                "                </div>\n" +
                "                <div class=\"file-upload-section\">\n" +
                "                    <input type=\"file\" id=\"fileInput\" accept=\"image/*,.pdf,.doc,.docx,.txt,.xlsx,.ppt,.pptx\" multiple>\n" +
                "                    <button class=\"file-upload-button\" onclick=\"document.getElementById('fileInput').click()\">📎 파일 업로드</button>\n" +
                "                    <div id=\"filePreview\"></div>\n" +
                "                </div>\n" +
                "            </div>\n" +
                "        </div>\n" +
                "        \n" +
                "        <div class=\"participants-sidebar\">\n" +
                "            <div class=\"participants-header\">\n" +
                "                <h4>👥 참여자 목록 <span id=\"participantCount\">(1)</span></h4>\n" +
                "            </div>\n" +
                "            <div class=\"participants-list\">\n" +
                "                <div id=\"participantsList\">\n" +
                "                    <div class=\"participant-item\">\n" +
                "                        <div class=\"status-indicator\"></div>\n" +
                "                        <div class=\"participant-name\">" + userId + " (나)</div>\n" +
                "                    </div>\n" +
                "                </div>\n" +
                "            </div>\n" +
                "        </div>\n" +
                "    </div>\n" +
                "\n" +
                "    <script>\n" +
                "        let stompClient = null;\n" +
                "        const travelPlanId = " + travelPlanId + ";\n" +
                "        const currentUserId = '" + userId + "';\n" +
                "        const currentUserName = '" + userName + "';\n" +
                "        let isConnected = false;\n" +
                "        let isLoadingHistory = false;\n" +
                "\n" +
                "        window.onload = function() {\n" +
                "            console.log('채팅방 로드 완료');\n" +
                "            \n" +
                "            document.getElementById('messageInput').addEventListener('keypress', function(e) {\n" +
                "                if (e.key === 'Enter') sendMessage();\n" +
                "            });\n" +
                "            \n" +
                "            // 파일 입력 이벤트 리스너\n" +
                "            document.getElementById('fileInput').addEventListener('change', function(e) {\n" +
                "                const files = e.target.files;\n" +
                "                if (files.length > 0) {\n" +
                "                    for (let file of files) {\n" +
                "                        uploadFile(file);\n" +
                "                    }\n" +
                "                    e.target.value = ''; // 같은 파일 재선택 가능하도록\n" +
                "                }\n" +
                "            });\n" +
                "            \n" +
                "            // 참가자 목록 로드\n" +
                "            loadParticipants();\n" +
                "            \n" +
                "            // WebSocket 연결\n" +
                "            connect();\n" +
                "        };\n" +
                "\n" +
                "        function connect() {\n" +
                "            if (isConnected) return;\n" +
                "            \n" +
                "            try {\n" +
                "                updateConnectionStatus('connecting', '연결 중...');\n" +
                "                \n" +
                "                const socket = new SockJS('/ws');\n" +
                "                stompClient = Stomp.over(socket);\n" +
                "\n" +
                "                stompClient.connect({}, function(frame) {\n" +
                "                    console.log('WebSocket 연결 성공:', frame);\n" +
                "                    isConnected = true;\n" +
                "                    updateConnectionStatus('connected', '✅ 연결됨 - 실시간 채팅 준비완료');\n" +
                "\n" +
                "                    stompClient.subscribe('/topic/chat/' + travelPlanId, function(message) {\n" +
                "                        const chatMessage = JSON.parse(message.body);\n" +
                "                        displayMessage(chatMessage);\n" +
                "                    });\n" +
                "\n" +
                "                    stompClient.send('/app/chat/' + travelPlanId + '/addUser', {}, JSON.stringify({\n" +
                "                        senderId: currentUserId,\n" +
                "                        senderName: currentUserName,\n" +
                "                        type: 'JOIN',\n" +
                "                        content: currentUserName + '님이 입장했습니다.'\n" +
                "                    }));\n" +
                "                    \n" +
                "                    // 연결 완료 후 채팅 히스토리 및 참가자 목록 다시 로드\n" +
                "                    loadChatHistory();\n" +
                "                    loadParticipants();\n" +
                "\n" +
                "                }, function(error) {\n" +
                "                    console.error('연결 오류:', error);\n" +
                "                    isConnected = false;\n" +
                "                    updateConnectionStatus('error', '❌ 연결 실패');\n" +
                "                });\n" +
                "\n" +
                "            } catch (error) {\n" +
                "                console.error('연결 시도 오류:', error);\n" +
                "                updateConnectionStatus('error', '❌ 연결 오류');\n" +
                "            }\n" +
                "        }\n" +
                "\n" +
                "        function updateConnectionStatus(status, message) {\n" +
                "            const statusElement = document.getElementById('connectionStatus');\n" +
                "            statusElement.className = 'connection-status ' + status;\n" +
                "            statusElement.textContent = message;\n" +
                "        }\n" +
                "\n" +
                "        function sendMessage() {\n" +
                "            const input = document.getElementById('messageInput');\n" +
                "            const message = input.value.trim();\n" +
                "\n" +
                "            if (message && stompClient && isConnected) {\n" +
                "                stompClient.send('/app/chat/' + travelPlanId, {}, JSON.stringify({\n" +
                "                    senderId: currentUserId,\n" +
                "                    senderName: currentUserName,\n" +
                "                    content: message,\n" +
                "                    type: 'CHAT'\n" +
                "                }));\n" +
                "                input.value = '';\n" +
                "            }\n" +
                "        }\n" +
                "\n" +
                "        function displayMessage(message) {\n" +
                "            const messagesDiv = document.getElementById('messages');\n" +
                "            const messageDiv = document.createElement('div');\n" +
                "            \n" +
                "            if (message.type === 'JOIN' || message.type === 'LEAVE') {\n" +
                "                messageDiv.className = 'message system';\n" +
                "                messageDiv.textContent = message.content;\n" +
                "            } else if (message.type === 'FILE' || message.type === 'IMAGE') {\n" +
                "                messageDiv.className = 'message ' + (message.senderId === currentUserId ? 'own' : 'other');\n" +
                "                let content = '';\n" +
                "                if (message.senderId !== currentUserId) {\n" +
                "                    content += '<strong>' + message.senderName + ':</strong><br>';\n" +
                "                }\n" +
                "                \n" +
                "                // 파일명 null 방지\n" +
                "                var displayName = message.originalFilename || message.fileName || '파일';\n" +
                "                // filePath가 /uploads/로 시작하면 그대로, 아니면 /chat/file/ 붙임\n" +
                "                var filePath = message.filePath || '';\n" +
                "                var imgSrc = filePath.startsWith('/uploads/') ? filePath : '/chat/file/' + filePath;\n" +
                "                \n" +
                "                // 파일 타입에 따라 다른 표시\n" +
                "                if (message.fileType && message.fileType.startsWith('image/')) {\n" +
                "                    // 이미지 파일\n" +
                "                    content += '<div class=\"file-message\">';\n" +
                "                    content += '<img src=\"' + imgSrc + '\" class=\"uploaded-image\" onclick=\"window.open(this.src)\" alt=\"' + displayName + '\">';\n" +
                "                    content += '<div class=\"file-info\">';\n" +
                "                    content += '<div class=\"file-name\">' + displayName + '</div>';\n" +
                "                    content += '<div class=\"file-size\">' + formatFileSize(message.fileSizeBytes) + '</div>';\n" +
                "                    content += '</div>';\n" +
                "                    content += '</div>';\n" +
                "                } else {\n" +
                "                    // 일반 파일\n" +
                "                    content += '<div class=\"file-message\" onclick=\"downloadFile(\\'' + filePath + '\\', \\'' + displayName + '\\')\">';\n" +
                "                    content += '<div class=\"file-icon\">' + getFileIcon(message.fileType) + '</div>';\n" +
                "                    content += '<div class=\"file-info\">';\n" +
                "                    content += '<div class=\"file-name\">' + displayName + '</div>';\n" +
                "                    content += '<div class=\"file-size\">' + formatFileSize(message.fileSizeBytes) + ' • 클릭하여 다운로드</div>';\n" +
                "                    content += '</div>';\n" +
                "                    content += '</div>';\n" +
                "                }\n" +
                "                \n" +
                "                // 파일 메시지에도 시간 정보 추가\n" +
                "                if (message.timestamp) {\n" +
                "                    content += '<div class=\"message-info\">';\n" +
                "                    content += '<span class=\"message-time\">' + formatDateTime(message.timestamp) + '</span>';\n" +
                "                    content += '</div>';\n" +
                "                }\n" +
                "                \n" +
                "                messageDiv.innerHTML = content;\n" +
                "            } else {\n" +
                "                messageDiv.className = 'message ' + (message.senderId === currentUserId ? 'own' : 'other');\n" +
                "                let content = '';\n" +
                "                if (message.senderId !== currentUserId) {\n" +
                "                    content += '<strong>' + message.senderName + ':</strong><br>';\n" +
                "                }\n" +
                "                content += message.content;\n" +
                "                \n" +
                "                // 시간 정보 추가\n" +
                "                if (message.timestamp) {\n" +
                "                    content += '<div class=\"message-info\">';\n" +
                "                    content += '<span class=\"message-time\">' + formatDateTime(message.timestamp) + '</span>';\n" +
                "                    content += '</div>';\n" +
                "                }\n" +
                "                \n" +
                "                messageDiv.innerHTML = content;\n" +
                "            }\n" +
                "            \n" +
                "            messagesDiv.appendChild(messageDiv);\n" +
                "            messagesDiv.scrollTop = messagesDiv.scrollHeight;\n" +
                "        }\n" +
                "\n" +
                "        // 파일 업로드 함수\n" +
                "        function uploadFile(file) {\n" +
                "            // 파일 크기 제한 (10MB)\n" +
                "            if (file.size > 10 * 1024 * 1024) {\n" +
                "                alert('파일 크기는 10MB 이하만 업로드 가능합니다.');\n" +
                "                return;\n" +
                "            }\n" +
                "\n" +
                "            const formData = new FormData();\n" +
                "            formData.append('file', file);\n" +
                "            formData.append('travelPlanId', travelPlanId);\n" +
                "\n" +
                "            // 진행률 표시를 위한 요소 생성\n" +
                "            const progressDiv = document.createElement('div');\n" +
                "            progressDiv.className = 'upload-progress';\n" +
                "            progressDiv.innerHTML = '<div class=\"upload-progress-bar\" style=\"width: 0%\"></div>';\n" +
                "            \n" +
                "            const previewDiv = document.createElement('div');\n" +
                "            previewDiv.className = 'file-preview';\n" +
                "            previewDiv.innerHTML = '<div>📤 ' + file.name + ' 업로드 중...</div>';\n" +
                "            previewDiv.appendChild(progressDiv);\n" +
                "            \n" +
                "            document.getElementById('filePreview').appendChild(previewDiv);\n" +
                "\n" +
                "            fetch('/chat/upload', {\n" +
                "                method: 'POST',\n" +
                "                body: formData\n" +
                "            })\n" +
                "            .then(response => response.json())\n" +
                "            .then(data => {\n" +
                "                document.getElementById('filePreview').removeChild(previewDiv);\n" +
                "                \n" +
                "                if (data.success) {\n" +
                "                    // 파일 메시지 전송\n" +
                "                    const fileMessage = {\n" +
                "                        senderId: currentUserId,\n" +
                "                        senderName: currentUserName,\n" +
                "                        content: data.originalFilename,\n" +
                "                        type: 'FILE',\n" +
                "                        filePath: data.filePath,\n" +
                "                        originalFilename: data.originalFilename,\n" +
                "                        fileSizeBytes: file.size,\n" +
                "                        fileType: file.type,\n" +
                "                        timestamp: new Date().toISOString()\n" +
                "                    };\n" +
                "                    \n" +
                "                    if (stompClient && isConnected) {\n" +
                "                        stompClient.send('/app/chat/' + travelPlanId, {}, JSON.stringify(fileMessage));\n" +
                "                    }\n" +
                "                } else {\n" +
                "                    alert('파일 업로드 실패: ' + data.message);\n" +
                "                }\n" +
                "            })\n" +
                "            .catch(error => {\n" +
                "                console.error('업로드 오류:', error);\n" +
                "                document.getElementById('filePreview').removeChild(previewDiv);\n" +
                "                alert('파일 업로드 중 오류가 발생했습니다.');\n" +
                "            });\n" +
                "        }\n" +
                "\n" +
                "        // 파일 크기 포맷팅\n" +
                "        function formatFileSize(bytes) {\n" +
                "            if (!bytes || bytes === 0) return '0 Bytes';\n" +
                "            const k = 1024;\n" +
                "            const sizes = ['Bytes', 'KB', 'MB', 'GB'];\n" +
                "            const i = Math.floor(Math.log(bytes) / Math.log(k));\n" +
                "            return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];\n" +
                "        }\n" +
                "\n" +
                "        // 날짜/시간 포맷팅 (가독성 있게)\n" +
                "        function formatDateTime(timestamp) {\n" +
                "            if (!timestamp) return '';\n" +
                "            \n" +
                "            const date = new Date(timestamp);\n" +
                "            const now = new Date();\n" +
                "            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());\n" +
                "            const messageDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());\n" +
                "            \n" +
                "            const timeDiff = today.getTime() - messageDate.getTime();\n" +
                "            const daysDiff = Math.floor(timeDiff / (1000 * 60 * 60 * 24));\n" +
                "            \n" +
                "            const timeString = date.toLocaleTimeString('ko-KR', { \n" +
                "                hour: '2-digit', \n" +
                "                minute: '2-digit',\n" +
                "                hour12: true\n" +
                "            });\n" +
                "            \n" +
                "            if (daysDiff === 0) {\n" +
                "                return timeString; // 오늘: 시간만 표시\n" +
                "            } else if (daysDiff === 1) {\n" +
                "                return '어제 ' + timeString;\n" +
                "            } else if (daysDiff < 7) {\n" +
                "                const dayNames = ['일', '월', '화', '수', '목', '금', '토'];\n" +
                "                return dayNames[date.getDay()] + '요일 ' + timeString;\n" +
                "            } else {\n" +
                "                return date.toLocaleDateString('ko-KR', { \n" +
                "                    month: 'short', \n" +
                "                    day: 'numeric' \n" +
                "                }) + ' ' + timeString;\n" +
                "            }\n" +
                "        }\n" +
                "\n" +
                "        // 파일 아이콘 가져오기\n" +
                "        function getFileIcon(fileType) {\n" +
                "            if (!fileType || typeof fileType !== 'string') return '📎';\n" +
                "            if (fileType.startsWith('image/')) return '🖼️';\n" +
                "            if (fileType === 'application/pdf') return '📄';\n" +
                "            if (fileType.includes('document') || fileType.includes('word')) return '📝';\n" +
                "            if (fileType.includes('spreadsheet') || fileType.includes('excel')) return '📊';\n" +
                "            if (fileType.includes('presentation') || fileType.includes('powerpoint')) return '📋';\n" +
                "            return '📎';\n" +
                "        }\n" +
                "\n" +
                "        // 파일 다운로드\n" +
                "        function downloadFile(filePath, originalFilename) {\n" +
                "            const link = document.createElement('a');\n" +
                "            link.href = '/chat/download/' + filePath;\n" +
                "            link.download = originalFilename;\n" +
                "            document.body.appendChild(link);\n" +
                "            link.click();\n" +
                "            document.body.removeChild(link);\n" +
                "        }\n" +
                "\n" +
                "        // 채팅 히스토리 로드\n" +
                "        function loadChatHistory() {\n" +
                "            if (isLoadingHistory) {\n" +
                "                console.log('이미 히스토리를 로딩 중입니다.');\n" +
                "                return;\n" +
                "            }\n" +
                "            \n" +
                "            isLoadingHistory = true;\n" +
                "            console.log('채팅 히스토리 로딩 시작...');\n" +
                "            \n" +
                "            fetch('/chat/messages/' + travelPlanId + '?limit=50&offset=0')\n" +
                "                .then(response => {\n" +
                "                    if (!response.ok) {\n" +
                "                        throw new Error('HTTP ' + response.status);\n" +
                "                    }\n" +
                "                    return response.json();\n" +
                "                })\n" +
                "                .then(data => {\n" +
                "                    console.log('히스토리 응답:', data);\n" +
                "                    if (data.success && data.messages && data.messages.length > 0) {\n" +
                "                        const messagesDiv = document.getElementById('messages');\n" +
                "                        // 기존 내용 완전히 클리어\n" +
                "                        messagesDiv.innerHTML = '';\n" +
                "                        \n" +
                "                        data.messages.forEach(message => {\n" +
                "                            displayMessage(message);\n" +
                "                        });\n" +
                "                        \n" +
                "                        console.log('히스토리 로드 완료: ' + data.messages.length + '개 메시지');\n" +
                "                    } else {\n" +
                "                        console.log('로드할 히스토리가 없습니다.');\n" +
                "                        const messagesDiv = document.getElementById('messages');\n" +
                "                        messagesDiv.innerHTML = '<div class=\"system-message\">아직 메시지가 없습니다. 첫 메시지를 보내보세요!</div>';\n" +
                "                    }\n" +
                "                })\n" +
                "                .catch(error => {\n" +
                "                    console.error('히스토리 로드 실패:', error);\n" +
                "                    const messagesDiv = document.getElementById('messages');\n" +
                "                    messagesDiv.innerHTML = '<div class=\"system-message\">채팅 내역을 불러오는 중 오류가 발생했습니다.</div>';\n" +
                "                })\n" +
                "                .finally(() => {\n" +
                "                    isLoadingHistory = false;\n" +
                "                });\n" +
                "        }\n" +
                "        \n" +
                "        // 참가자 목록 로드\n" +
                "        function loadParticipants() {\n" +
                "            console.log('참가자 목록 로딩 시작...');\n" +
                "            fetch('/chat/participants/' + travelPlanId)\n" +
                "                .then(response => {\n" +
                "                    if (!response.ok) {\n" +
                "                        throw new Error('HTTP ' + response.status);\n" +
                "                    }\n" +
                "                    return response.json();\n" +
                "                })\n" +
                "                .then(data => {\n" +
                "                    console.log('참가자 목록 응답:', data);\n" +
                "                    if (data.success && data.participants) {\n" +
                "                        updateParticipantsList(data.participants, data.onlineCount, data.totalCount);\n" +
                "                    } else {\n" +
                "                        console.log('참가자 목록을 불러올 수 없습니다.');\n" +
                "                    }\n" +
                "                })\n" +
                "                .catch(error => {\n" +
                "                    console.error('참가자 목록 로드 실패:', error);\n" +
                "                });\n" +
                "        }\n" +
                "        \n" +
                "        // 참가자 목록 업데이트\n" +
                "        function updateParticipantsList(participants, onlineCount, totalCount) {\n" +
                "            const participantsList = document.getElementById('participantsList');\n" +
                "            const participantCount = document.getElementById('participantCount');\n" +
                "            \n" +
                "            if (!participantsList || !participantCount) {\n" +
                "                console.error('참가자 목록 요소를 찾을 수 없습니다.');\n" +
                "                return;\n" +
                "            }\n" +
                "            \n" +
                "            // 참가자 수 업데이트\n" +
                "            participantCount.textContent = '(' + totalCount + ')';\n" +
                "            \n" +
                "            // 참가자 목록 업데이트\n" +
                "            participantsList.innerHTML = '';\n" +
                "            \n" +
                "            participants.forEach(participant => {\n" +
                "                const participantDiv = document.createElement('div');\n" +
                "                participantDiv.className = 'participant-item';\n" +
                "                \n" +
                "                const statusColor = participant.isOnline ? '#28a745' : '#6c757d';\n" +
                "                const statusText = participant.isOnline ? '온라인' : '오프라인';\n" +
                "                const displayName = participant.nickname || participant.userName;\n" +
                "                const isCurrentUser = participant.userId === currentUserId;\n" +
                "                \n" +
                "                participantDiv.innerHTML = \n" +
                "                    '<div class=\"status-indicator\" style=\"background-color: ' + statusColor + ';\"></div>' +\n" +
                "                    '<div class=\"participant-info\">' +\n" +
                "                        '<div class=\"participant-name\">' + displayName + (isCurrentUser ? ' (나)' : '') + '</div>' +\n" +
                "                        '<div class=\"participant-status\">' + statusText + '</div>' +\n" +
                "                    '</div>';\n" +
                "                \n" +
                "                participantsList.appendChild(participantDiv);\n" +
                "            });\n" +
                "        }\n" +
                "    </script>\n" +
                "    </div> <!-- chat-body 끝 -->\n" +
                "</body>\n" +
                "</html>";
            
            System.out.println("완전한 채팅방 HTML 생성 성공, 길이: " + html.length());
            return html;
            
        } catch (Exception e) {
            System.err.println("generateBeautifulChatRoom에서 예외 발생:");
            e.printStackTrace();
            return "<html><body><h1>HTML 생성 오류</h1><p>" + e.getMessage() + "</p></body></html>";
        }
    }
    
    // JSP 렌더링 테스트용 별도 엔드포인트
    @GetMapping("/room/{travelPlanId}/view")
    public String chatRoomView(@PathVariable int travelPlanId, HttpSession session, Model model, RedirectAttributes redirectAttributes) {
        System.out.println("=== 채팅방 입장 ===");
        System.out.println("여행 계획 ID: " + travelPlanId);

        // 로그인 체크
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("로그인되지 않은 사용자");
            redirectAttributes.addFlashAttribute("error", "로그인이 필요합니다.");
            return "redirect:/member/login";
        }

        try {
            // DAO null 체크
            if (travelPlanDAO == null) {
                System.err.println("TravelPlanDAO가 주입되지 않았습니다.");
                redirectAttributes.addFlashAttribute("error", "시스템 오류가 발생했습니다.");
                return "redirect:/chat/rooms";
            }

            // 여행 계획 정보 조회
            TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(travelPlanId);
            if (travelPlan == null) {
                System.err.println("존재하지 않는 여행 계획: " + travelPlanId);
                redirectAttributes.addFlashAttribute("error", "존재하지 않는 채팅방입니다.");
                return "redirect:/chat/rooms";
            }

            System.out.println("여행 계획: " + travelPlan.getPlanTitle());
            System.out.println("사용자: " + loginUser.getUserId());

            model.addAttribute("travelPlan", travelPlan);
            model.addAttribute("currentUser", loginUser);

            System.out.println("채팅방 렌더링 성공");
            return "chat/basicChatRoom";

        } catch (Exception e) {
            System.err.println("채팅방 로딩 중 오류: " + e.getMessage());
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("error", "채팅방을 불러오는 중 오류가 발생했습니다.");
            return "redirect:/chat/rooms";
        }
    }
    

    // 메시지 전송
    @MessageMapping("/chat/{travelPlanId}")
    public void sendMessage(@DestinationVariable int travelPlanId, 
                           @Payload ChatMessageDTO chatMessage,
                           SimpMessageHeaderAccessor headerAccessor) {
        try {
            // 현재 시간 설정
            chatMessage.setTimestamp(LocalDateTime.now());
            chatMessage.setTravelPlanId(travelPlanId);
            
            // 여행 계획 존재 여부 확인 후 메시지 저장
            if (chatMessageDAO != null && travelPlanDAO != null) {
                try {
                    // 여행 계획 존재 여부 확인
                    TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(travelPlanId);
                    if (travelPlan == null) {
                        System.err.println("존재하지 않는 여행 계획에 메시지 전송 시도: " + travelPlanId);
                        return; // 메시지 전송 중단
                    }
                    
                    // 발신자 이름 설정
                    if (chatMessage.getSenderName() == null || chatMessage.getSenderName().isEmpty()) {
                        chatMessage.setSenderName(chatMessage.getSenderId());
                    }
                    
                    System.out.println("=== 메시지 저장 시작 ===");
                    System.out.println("발신자: " + chatMessage.getSenderId() + " (" + chatMessage.getSenderName() + ")");
                    System.out.println("내용: " + chatMessage.getContent());
                    System.out.println("타입: " + chatMessage.getType());
                    System.out.println("여행 계획 ID: " + chatMessage.getTravelPlanId());
                    System.out.println("시간: " + chatMessage.getTimestamp());
                    
                    // 파일 메시지인 경우 파일 정보 저장
                    if (chatMessage.getType() == ChatMessageDTO.MessageType.FILE) {
                        System.out.println("파일 메시지 저장 - 파일명: " + chatMessage.getOriginalFilename() + 
                                         ", 파일 크기: " + chatMessage.getFileSizeBytes() + " bytes");
                    }
                    
                    int result = chatMessageDAO.insertChatMessage(chatMessage);
                    System.out.println("DB 저장 결과: " + result);
                    if (result > 0) {
                        System.out.println("메시지 저장 완료: " + chatMessage.getContent() + 
                                         (chatMessage.getType() == ChatMessageDTO.MessageType.FILE ? " (파일)" : ""));
                    } else {
                        System.err.println("메시지 저장 실패 - 결과값이 0입니다.");
                    }
                } catch (Exception e) {
                    System.err.println("메시지 저장 실패: " + e.getMessage());
                    e.printStackTrace();
                    // 저장 실패해도 실시간 전송은 계속
                }
            }
            
            // 해당 채팅방의 모든 참여자에게 메시지 전송
            messagingTemplate.convertAndSend("/topic/chat/" + travelPlanId, chatMessage);
            
        } catch (Exception e) {
            System.err.println("메시지 전송 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // 파일 업로드 처리
    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadFile(@RequestParam("file") MultipartFile file,
                                                         @RequestParam("travelPlanId") int travelPlanId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (file.isEmpty()) {
                response.put("success", false);
                response.put("message", "파일이 비어있습니다.");
                return ResponseEntity.badRequest().body(response);
            }
            
            // 업로드 디렉토리 생성
            String chatUploadPath = uploadPath + "chat/";
            File uploadDir = new File(chatUploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // 고유 파일명 생성
            String originalFilename = file.getOriginalFilename();
            String fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
            String uniqueFilename = UUID.randomUUID().toString() + fileExtension;
            
            // 파일 저장
            Path filePath = Paths.get(chatUploadPath + uniqueFilename);
            Files.write(filePath, file.getBytes());
            
            response.put("success", true);
            response.put("filePath", uniqueFilename);
            response.put("originalFilename", originalFilename);
            
            return ResponseEntity.ok(response);
            
        } catch (IOException e) {
            System.err.println("파일 업로드 실패: " + e.getMessage());
            response.put("success", false);
            response.put("message", "파일 업로드 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    
    // 파일 다운로드 처리
    @GetMapping("/download/{fileName}")
    public ResponseEntity<Resource> downloadFile(@PathVariable String fileName) {
        try {
            String chatUploadPath = uploadPath + "chat/";
            Path filePath = Paths.get(chatUploadPath + fileName);
            Resource resource = new FileSystemResource(filePath);
            
            if (!resource.exists()) {
                return ResponseEntity.notFound().build();
            }
            
            // 원본 파일명 찾기 (실제로는 DB에서 조회해야 함)
            String originalFileName = fileName;
            
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + originalFileName + "\"")
                    .body(resource);
                    
        } catch (Exception e) {
            System.err.println("파일 다운로드 실패: " + e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
    
    // 이미지 파일 서빙
    @GetMapping("/file/{fileName}")
    public ResponseEntity<Resource> serveFile(@PathVariable String fileName) {
        try {
            String chatUploadPath = uploadPath + "chat/";
            Path filePath = Paths.get(chatUploadPath + fileName);
            Resource resource = new FileSystemResource(filePath);
            
            if (!resource.exists()) {
                return ResponseEntity.notFound().build();
            }
            
            // 파일 확장자로 MIME 타입 결정
            String contentType = "application/octet-stream";
            String fileExtension = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            
            switch (fileExtension) {
                case "jpg":
                case "jpeg":
                    contentType = "image/jpeg";
                    break;
                case "png":
                    contentType = "image/png";
                    break;
                case "gif":
                    contentType = "image/gif";
                    break;
                case "pdf":
                    contentType = "application/pdf";
                    break;
            }
            
            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .body(resource);
                    
        } catch (Exception e) {
            System.err.println("파일 서빙 실패: " + e.getMessage());
            return ResponseEntity.internalServerError().build();
        }
    }
    
    // 사용자 입장 처리
    @MessageMapping("/chat/{travelPlanId}/addUser")
    public void addUser(@DestinationVariable int travelPlanId,
                       @Payload ChatMessageDTO chatMessage,
                       SimpMessageHeaderAccessor headerAccessor) {
        try {
            // 여행 계획 존재 여부 확인
            if (travelPlanDAO != null) {
                TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(travelPlanId);
                if (travelPlan == null) {
                    System.err.println("존재하지 않는 여행 계획에 입장 시도: " + travelPlanId);
                    return; // 입장 처리 중단
                }
            }
            
            String userId = chatMessage.getSenderId();
            
            // 세션에 사용자 정보 저장
            headerAccessor.getSessionAttributes().put("username", userId);
            headerAccessor.getSessionAttributes().put("travelPlanId", travelPlanId);
            
            // 채팅방에 사용자 추가 (WebSocketEventListener의 공유 맵 사용)
            WebSocketEventListener.getChatRoomUsers().computeIfAbsent(travelPlanId, k -> ConcurrentHashMap.newKeySet()).add(userId);
            
            chatMessage.setType(ChatMessageDTO.MessageType.JOIN);
            chatMessage.setTimestamp(LocalDateTime.now());
            chatMessage.setTravelPlanId(travelPlanId);
            
            // 시스템 메시지도 DB에 저장
            if (chatMessageDAO != null) {
                try {
                    chatMessage.setSenderName(chatMessage.getSenderId());
                    chatMessageDAO.insertChatMessage(chatMessage);
                } catch (Exception e) {
                    System.err.println("입장 메시지 저장 실패: " + e.getMessage());
                }
            }
            
            // 입장 메시지 전송
            messagingTemplate.convertAndSend("/topic/chat/" + travelPlanId, chatMessage);
            
            // 참여자 목록 업데이트 전송
            broadcastParticipantUpdate(travelPlanId);
            
        } catch (Exception e) {
            System.err.println("사용자 입장 처리 중 오류 발생: " + e.getMessage());
        }
    }
    
    // 사용자 퇴장 처리
    @MessageMapping("/chat/{travelPlanId}/removeUser") 
    public void removeUser(@DestinationVariable int travelPlanId,
                          @Payload ChatMessageDTO chatMessage) {
        try {
            // 여행 계획 존재 여부 확인
            if (travelPlanDAO != null) {
                TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(travelPlanId);
                if (travelPlan == null) {
                    System.err.println("존재하지 않는 여행 계획에서 퇴장 시도: " + travelPlanId);
                    return; // 퇴장 처리 중단
                }
            }
            
            String userId = chatMessage.getSenderId();
            
            // 채팅방에서 사용자 제거 (WebSocketEventListener의 공유 맵 사용)
            Set<String> roomUsers = WebSocketEventListener.getChatRoomUsers().get(travelPlanId);
            if (roomUsers != null) {
                roomUsers.remove(userId);
                if (roomUsers.isEmpty()) {
                    WebSocketEventListener.getChatRoomUsers().remove(travelPlanId);
                }
            }
            
            chatMessage.setType(ChatMessageDTO.MessageType.LEAVE);
            chatMessage.setTimestamp(LocalDateTime.now());
            chatMessage.setTravelPlanId(travelPlanId);
            
            // 시스템 메시지도 DB에 저장
            if (chatMessageDAO != null) {
                try {
                    chatMessage.setSenderName(chatMessage.getSenderId());
                    chatMessageDAO.insertChatMessage(chatMessage);
                } catch (Exception e) {
                    System.err.println("퇴장 메시지 저장 실패: " + e.getMessage());
                }
            }
            
            // 퇴장 메시지 전송
            messagingTemplate.convertAndSend("/topic/chat/" + travelPlanId, chatMessage);
            
            // 참여자 목록 업데이트 전송
            broadcastParticipantUpdate(travelPlanId);
            
        } catch (Exception e) {
            System.err.println("사용자 퇴장 처리 중 오류 발생: " + e.getMessage());
        }
    }
    
    // 참여자 목록 업데이트 브로드캐스트
    private void broadcastParticipantUpdate(int travelPlanId) {
        try {
            Set<String> participants = WebSocketEventListener.getChatRoomUsers().get(travelPlanId);
            if (participants == null) {
                participants = ConcurrentHashMap.newKeySet();
            }
            
            Map<String, Object> participantUpdate = new HashMap<>();
            participantUpdate.put("participants", new ArrayList<>(participants)); // Set을 ArrayList로 변환
            participantUpdate.put("count", participants.size());
            
            System.out.println("참여자 목록 브로드캐스트: " + participants.size() + "명 - " + participants);
            messagingTemplate.convertAndSend("/topic/participants/" + travelPlanId, participantUpdate);
            
        } catch (Exception e) {
            System.err.println("참여자 목록 업데이트 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // 채팅 히스토리 조회 API
    @GetMapping("/messages/{travelPlanId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getChatMessages(
            @PathVariable int travelPlanId,
            @RequestParam(defaultValue = "30") int limit,
            @RequestParam(defaultValue = "0") int offset) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            System.out.println("=== 채팅 히스토리 조회 ===");
            System.out.println("travelPlanId: " + travelPlanId + ", limit: " + limit + ", offset: " + offset);
            
            if (chatMessageDAO == null) {
                System.out.println("chatMessageDAO is null - 빈 응답 반환");
                response.put("success", true);
                response.put("messages", new ArrayList<>());
                response.put("totalCount", 0);
                response.put("hasMore", false);
                return ResponseEntity.ok(response);
            }
            
            // 여행 계획 존재 여부 확인 (없으면 테스트용으로 처리)
            if (travelPlanDAO != null) {
                TravelPlanDTO travelPlan = travelPlanDAO.getTravelPlan(travelPlanId);
                if (travelPlan == null) {
                    System.out.println("존재하지 않는 여행 계획의 메시지 조회, 테스트용으로 처리: " + travelPlanId);
                }
            }
            
            // 메시지 조회 (시간순 정렬은 SQL에서 처리됨)
            List<ChatMessageDTO> messages = chatMessageDAO.getRecentMessages(travelPlanId, limit, offset);
            
            // 전체 메시지 개수
            int totalCount = chatMessageDAO.getMessageCount(travelPlanId);
            
            response.put("success", true);
            response.put("messages", messages);
            response.put("totalCount", totalCount);
            response.put("hasMore", (offset + limit) < totalCount);
            
            System.out.println("히스토리 조회 성공: " + messages.size() + "개 메시지, 전체: " + totalCount + "개");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("채팅 히스토리 조회 실패: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "채팅 내역을 불러올 수 없습니다.");
            response.put("messages", new ArrayList<>());
            response.put("totalCount", 0);
            response.put("hasMore", false);
            return ResponseEntity.ok(response);
        }
    }
    
    // 최근 N개 메시지 조회 (초기 로딩용)
    @GetMapping("/latest/{travelPlanId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getLatestMessages(
            @PathVariable int travelPlanId,
            @RequestParam(defaultValue = "50") int limit) {
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            System.out.println("=== 최근 메시지 조회 ===");
            System.out.println("travelPlanId: " + travelPlanId + ", limit: " + limit);
            
            if (chatMessageDAO == null) {
                response.put("success", true);
                response.put("messages", new ArrayList<>());
                return ResponseEntity.ok(response);
            }
            
            List<ChatMessageDTO> messages = chatMessageDAO.getLatestMessages(travelPlanId, limit);
            
            response.put("success", true);
            response.put("messages", messages);
            
            System.out.println("최근 메시지 조회 성공: " + messages.size() + "개");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("최근 메시지 조회 실패: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "최근 메시지를 불러올 수 없습니다.");
            response.put("messages", new ArrayList<>());
            return ResponseEntity.ok(response);
        }
    }
    
    // 여행 계획 참가자 목록 조회 API
    @GetMapping("/participants/{travelPlanId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getTravelParticipants(@PathVariable int travelPlanId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            System.out.println("여행 계획 참가자 목록 조회: " + travelPlanId);
            
            if (travelDAO == null) {
                response.put("success", false);
                response.put("message", "데이터베이스 연결 오류");
                response.put("participants", new ArrayList<>());
                return ResponseEntity.internalServerError().body(response);
            }
            
            // 현재 사용자 정보 가져오기
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            
            // 여행 계획 참가자 목록 조회
            List<TravelParticipantDTO> participants = travelDAO.getParticipantsByTravelId((long) travelPlanId);
            System.out.println("===== 참여자 목록 디버그 =====");
            System.out.println("Travel Plan ID: " + travelPlanId);
            System.out.println("DB에서 조회된 참가자 수: " + participants.size());

            // 각 참여자 정보 출력
            for (TravelParticipantDTO participant : participants) {
                System.out.println("- UserId: " + participant.getUserId() +
                                 ", UserName: " + participant.getUserName() +
                                 ", Status: " + participant.getStatus() +
                                 ", JoinedDate: " + participant.getJoinedDate());
            }
            System.out.println("===========================");
            
            // 현재 사용자가 참가자 목록에 없는 경우, 임시로 추가 (테스트용)
            boolean currentUserExists = false;
            if (loginUser != null) {
                for (TravelParticipantDTO participant : participants) {
                    if (loginUser.getUserId().equals(participant.getUserId())) {
                        currentUserExists = true;
                        break;
                    }
                }
                
                if (!currentUserExists) {
                    // 현재 사용자를 임시 참가자로 추가
                    TravelParticipantDTO tempParticipant = new TravelParticipantDTO();
                    tempParticipant.setUserId(loginUser.getUserId());
                    tempParticipant.setUserName(loginUser.getUserName());
                    tempParticipant.setNickname(loginUser.getNickname());
                    tempParticipant.setStatus("JOINED");
                    tempParticipant.setJoinedDate(new java.util.Date());
                    participants.add(tempParticipant);
                    System.out.println("현재 사용자 임시 추가: " + loginUser.getUserId());
                }
            }
            
            // 현재 채팅방에 접속 중인 사용자 목록 가져오기
            Set<String> onlineUsers = WebSocketEventListener.getChatRoomUsers().get(travelPlanId);
            if (onlineUsers == null) {
                onlineUsers = new HashSet<>();
            }
            
            // 참가자 정보를 Map 형태로 변환하여 온라인/오프라인 상태 추가
            List<Map<String, Object>> participantList = new ArrayList<>();
            for (TravelParticipantDTO participant : participants) {
                Map<String, Object> participantData = new HashMap<>();
                participantData.put("userId", participant.getUserId());
                participantData.put("userName", participant.getUserName() != null ? participant.getUserName() : participant.getUserId());
                participantData.put("nickname", participant.getNickname());
                participantData.put("status", participant.getStatus());
                participantData.put("joinedDate", participant.getJoinedDate());
                participantData.put("isOnline", onlineUsers.contains(participant.getUserId()));
                // 동행장 여부 표시
                participantData.put("isHost", "HOST".equals(participant.getStatus()));
                participantList.add(participantData);
            }
            
            response.put("success", true);
            response.put("participants", participantList);
            response.put("totalCount", participants.size());
            response.put("onlineCount", onlineUsers.size());
            
            System.out.println("참가자 목록 조회 성공: " + participants.size() + "명 (온라인: " + onlineUsers.size() + "명)");
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            System.err.println("참가자 목록 조회 실패: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "참가자 목록을 불러올 수 없습니다.");
            response.put("participants", new ArrayList<>());
            return ResponseEntity.internalServerError().body(response);
        }
    }
    
    
    
}