package com.tour.project.config;

import com.tour.project.dao.MemberDAO;
import com.tour.project.dao.PlaylistDAO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.service.BadgeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@Component
public class LoginSuccessHandler implements AuthenticationSuccessHandler {

    @Autowired(required = false)
    private PlaylistDAO playlistDAO;

    @Autowired(required = false)
    private BadgeService badgeService;

    @Autowired
    private MemberDAO memberDAO;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException, ServletException {

        HttpSession session = request.getSession();
        String userId = authentication.getName();

        // 사용자 정보 로드하여 세션에 저장
        try {
            MemberDTO member = memberDAO.getMember(userId);
            if (member != null) {
                session.setAttribute("loginUser", member);
            }
        } catch (Exception e) {
            System.err.println("사용자 정보 로드 실패: " + e.getMessage());
        }

        // 임시 플레이리스트 이관
        String tempUserId = (String) session.getAttribute("userId");
        if (tempUserId != null && tempUserId.startsWith("playlist_") && playlistDAO != null) {
            try {
                int transferredCount = playlistDAO.transferTempPlaylistsToUser(tempUserId, userId);
                System.out.println("임시 플레이리스트 이관 완료: " + transferredCount + "개");
                session.removeAttribute("userId");
            } catch (Exception e) {
                System.err.println("임시 플레이리스트 이관 실패: " + e.getMessage());
            }
        }

        // 출석 기록
        if (badgeService != null) {
            try {
                badgeService.recordAttendance(userId);
            } catch (Exception e) {
                System.err.println("출석 기록 실패: " + e.getMessage());
            }
        }

        // returnUrl 처리
        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl != null && !returnUrl.trim().isEmpty()) {
            response.sendRedirect(returnUrl);
        } else {
            response.sendRedirect("/home");
        }
    }
}