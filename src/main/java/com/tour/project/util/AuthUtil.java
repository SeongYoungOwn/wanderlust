package com.tour.project.util;

import com.tour.project.dto.MemberDTO;
import javax.servlet.http.HttpSession;

/**
 * 사용자 권한 체크 유틸리티 클래스
 */
public class AuthUtil {
    
    /**
     * 사용자가 로그인되어 있는지 확인
     */
    public static boolean isLoggedIn(HttpSession session) {
        return session.getAttribute("loginUser") != null;
    }
    
    /**
     * 사용자가 활성 상태인지 확인 (정지되지 않은 상태)
     */
    public static boolean isActiveUser(HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return false;
        }
        
        // account_status가 null이면 ACTIVE로 간주
        String status = loginUser.getAccountStatus();
        return status == null || "ACTIVE".equals(status);
    }
    
    /**
     * 사용자가 정지 상태인지 확인
     */
    public static boolean isSuspendedUser(HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return false;
        }
        
        return "SUSPENDED".equals(loginUser.getAccountStatus());
    }
    
    /**
     * 사용자가 관리자인지 확인
     */
    public static boolean isAdmin(HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return false;
        }
        
        // user_role이 ADMIN이거나 user_id가 admin인 경우
        return "ADMIN".equals(loginUser.getUserRole()) || "admin".equals(loginUser.getUserId());
    }
    
    /**
     * 사용자가 글쓰기 권한이 있는지 확인
     * 로그인되어 있고 정지되지 않은 사용자만 가능
     */
    public static boolean canWrite(HttpSession session) {
        return isLoggedIn(session) && isActiveUser(session);
    }
    
    /**
     * 사용자가 댓글 작성 권한이 있는지 확인
     * 로그인되어 있고 정지되지 않은 사용자만 가능
     */
    public static boolean canComment(HttpSession session) {
        return isLoggedIn(session) && isActiveUser(session);
    }
    
    /**
     * 사용자가 좋아요/싫어요 권한이 있는지 확인
     * 로그인되어 있고 정지되지 않은 사용자만 가능
     */
    public static boolean canLike(HttpSession session) {
        return isLoggedIn(session) && isActiveUser(session);
    }
    
    /**
     * 사용자가 여행계획 생성 권한이 있는지 확인
     * 로그인되어 있고 정지되지 않은 사용자만 가능
     */
    public static boolean canCreateTravelPlan(HttpSession session) {
        return isLoggedIn(session) && isActiveUser(session);
    }
    
    /**
     * 사용자가 AI 여행 플래너를 사용할 수 있는지 확인
     * 로그인되어 있고 정지되지 않은 사용자만 가능
     */
    public static boolean canUseAIPlanner(HttpSession session) {
        return isLoggedIn(session) && isActiveUser(session);
    }
    
    /**
     * 권한 체크 결과 메시지 반환
     */
    public static String getAuthMessage(HttpSession session) {
        if (!isLoggedIn(session)) {
            return "로그인이 필요한 서비스입니다.";
        }
        
        if (isSuspendedUser(session)) {
            return "정지된 계정입니다. 이 기능을 사용할 수 없습니다.";
        }
        
        return null;
    }
}