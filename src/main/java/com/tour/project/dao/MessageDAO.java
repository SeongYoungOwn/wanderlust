package com.tour.project.dao;

import com.tour.project.dto.MessageDTO;
import java.util.List;
import java.util.Map;

public interface MessageDAO {
    
    // 쪽지 전송
    int sendMessage(MessageDTO message);
    
    // 받은 쪽지 목록 조회 (삭제되지 않은 것만)
    List<MessageDTO> getReceivedMessages(Map<String, Object> params);
    
    // 보낸 쪽지 목록 조회 (삭제되지 않은 것만)
    List<MessageDTO> getSentMessages(Map<String, Object> params);
    
    // 쪽지 상세 조회
    MessageDTO getMessageById(int messageId);
    
    // 쪽지 읽음 처리
    int markAsRead(int messageId);
    
    // 받은 쪽지 삭제 (receiver_deleted = true)
    int deleteReceivedMessage(Map<String, Object> params);
    
    // 보낸 쪽지 삭제 (sender_deleted = true)
    int deleteSentMessage(Map<String, Object> params);
    
    // 읽지 않은 쪽지 개수
    int getUnreadMessageCount(String userId);
    
    // 전체 받은 쪽지 개수
    int getReceivedMessageCount(String userId);
    
    // 전체 보낸 쪽지 개수
    int getSentMessageCount(String userId);
    
    // 쪽지 검색 (받은 쪽지)
    List<MessageDTO> searchReceivedMessages(Map<String, Object> params);
    
    // 쪽지 검색 (보낸 쪽지)
    List<MessageDTO> searchSentMessages(Map<String, Object> params);
}