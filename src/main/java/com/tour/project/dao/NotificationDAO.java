package com.tour.project.dao;

import com.tour.project.dto.NotificationDTO;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;
import java.util.List;

@Mapper
@Repository
public interface NotificationDAO {
    
    int insertNotification(NotificationDTO notification);
    
    NotificationDTO getNotificationById(Integer notificationId);
    
    List<NotificationDTO> getNotificationsByUserId(String userId);
    
    List<NotificationDTO> getUnreadNotificationsByUserId(String userId);
    
    List<NotificationDTO> getNotificationsByType(String userId, String type);
    
    int updateNotificationAsRead(Integer notificationId);
    
    int updateAllNotificationsAsRead(String userId);
    
    int deleteNotification(Integer notificationId);
    
    int deleteNotificationsByUserId(String userId);
    
    int getUnreadNotificationCount(String userId);
    
    int getNotificationCountByType(String userId, String type);
}