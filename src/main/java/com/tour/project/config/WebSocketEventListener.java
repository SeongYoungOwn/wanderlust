package com.tour.project.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import com.tour.project.dto.ChatMessageDTO;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.Map;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.ArrayList;

@Component
public class WebSocketEventListener {

    @Autowired
    private SimpMessageSendingOperations messagingTemplate;
    
    // 채팅방별 온라인 사용자 관리 (ChatController와 동일한 인스턴스 공유)
    private static final ConcurrentHashMap<Integer, Set<String>> chatRoomUsers = new ConcurrentHashMap<>();

    @EventListener
    public void handleWebSocketConnectListener(SessionConnectedEvent event) {
        System.out.println("새로운 웹소켓 연결이 수신되었습니다.");
    }

    @EventListener
    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
        
        String username = (String) headerAccessor.getSessionAttributes().get("username");
        Integer travelPlanId = (Integer) headerAccessor.getSessionAttributes().get("travelPlanId");
        
        if (username != null && travelPlanId != null) {
            System.out.println("사용자 연결 해제: " + username + " from room: " + travelPlanId);
            
            // 채팅방에서 사용자 제거
            Set<String> roomUsers = chatRoomUsers.get(travelPlanId);
            if (roomUsers != null) {
                roomUsers.remove(username);
                if (roomUsers.isEmpty()) {
                    chatRoomUsers.remove(travelPlanId);
                }
            }
            
            ChatMessageDTO chatMessage = new ChatMessageDTO();
            chatMessage.setType(ChatMessageDTO.MessageType.LEAVE);
            chatMessage.setSenderId(username);
            chatMessage.setSenderName(username);
            chatMessage.setContent(username + "님이 채팅방을 나갔습니다.");
            chatMessage.setTravelPlanId(travelPlanId);
            chatMessage.setTimestamp(LocalDateTime.now());
            
            messagingTemplate.convertAndSend("/topic/chat/" + travelPlanId, chatMessage);
            
            // 참여자 목록 업데이트 전송
            broadcastParticipantUpdate(travelPlanId);
        }
    }
    
    // 참여자 목록 업데이트 브로드캐스트
    private void broadcastParticipantUpdate(int travelPlanId) {
        try {
            Set<String> participants = chatRoomUsers.get(travelPlanId);
            if (participants == null) {
                participants = ConcurrentHashMap.newKeySet();
            }
            
            Map<String, Object> participantUpdate = new HashMap<>();
            participantUpdate.put("participants", new ArrayList<>(participants)); // Set을 ArrayList로 변환
            participantUpdate.put("count", participants.size());
            
            System.out.println("WebSocket 연결 해제 시 참여자 목록 업데이트: " + participants.size() + "명 - " + participants);
            messagingTemplate.convertAndSend("/topic/participants/" + travelPlanId, participantUpdate);
            
        } catch (Exception e) {
            System.err.println("참여자 목록 업데이트 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // ChatController에서 사용할 수 있도록 정적 메서드 제공
    public static ConcurrentHashMap<Integer, Set<String>> getChatRoomUsers() {
        return chatRoomUsers;
    }
}