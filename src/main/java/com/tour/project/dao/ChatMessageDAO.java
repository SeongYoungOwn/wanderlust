package com.tour.project.dao;

import com.tour.project.dto.ChatMessageDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface ChatMessageDAO {
    
    /**
     * 채팅 메시지 저장
     */
    int insertChatMessage(ChatMessageDTO chatMessage);
    
    /**
     * 특정 여행 계획의 모든 채팅 메시지 조회 (시간순 정렬)
     */
    List<ChatMessageDTO> getChatMessagesByTravelPlanId(@Param("travelPlanId") int travelPlanId);
    
    /**
     * 특정 여행 계획의 최근 채팅 메시지 조회 (제한된 개수)
     */
    List<ChatMessageDTO> getRecentChatMessages(@Param("travelPlanId") int travelPlanId, @Param("limit") int limit);
    
    /**
     * 채팅 메시지 삭제 (특정 여행 계획의 모든 메시지)
     */
    int deleteChatMessagesByTravelPlanId(@Param("travelPlanId") int travelPlanId);
    
    /**
     * 채팅 메시지 개수 조회
     */
    int getChatMessageCount(@Param("travelPlanId") int travelPlanId);
    
    /**
     * 페이징된 채팅 메시지 조회 (무한 스크롤용) - OFFSET 방식
     */
    List<ChatMessageDTO> getChatMessagesWithPaging(@Param("travelPlanId") int travelPlanId, 
                                                   @Param("lastMessageId") Long lastMessageId, 
                                                   @Param("pageSize") int pageSize);
    
    /**
     * 채팅방의 최근 메시지 조회 (페이징) - 최신순으로 조회
     */
    List<ChatMessageDTO> getRecentMessages(@Param("travelPlanId") int travelPlanId, 
                                           @Param("limit") int limit, 
                                           @Param("offset") int offset);
    
    /**
     * 채팅방의 전체 메시지 개수
     */
    int getMessageCount(@Param("travelPlanId") int travelPlanId);
    
    /**
     * 특정 시간 이후 메시지 조회 (실시간 동기화용)
     */
    List<ChatMessageDTO> getMessagesAfter(@Param("travelPlanId") int travelPlanId, 
                                         @Param("afterTime") LocalDateTime afterTime);
    
    /**
     * 채팅방의 최근 N개 메시지 조회 (시간순)
     */
    List<ChatMessageDTO> getLatestMessages(@Param("travelPlanId") int travelPlanId, 
                                          @Param("limit") int limit);
    
    /**
     * 특정 시간 이후의 새로운 메시지 조회 (폴링용)
     */
    List<ChatMessageDTO> getNewChatMessages(@Param("travelPlanId") int travelPlanId, 
                                           @Param("lastTimestamp") LocalDateTime lastTimestamp);
}