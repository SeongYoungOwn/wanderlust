package com.tour.project.config;

import org.springframework.security.authentication.*;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;

@Component
public class LoginFailureHandler implements AuthenticationFailureHandler {

    @Override
    public void onAuthenticationFailure(HttpServletRequest request,
                                        HttpServletResponse response,
                                        AuthenticationException exception) throws IOException, ServletException {

        String errorMessage;

        if (exception instanceof BadCredentialsException) {
            errorMessage = "아이디 또는 비밀번호가 일치하지 않습니다.";
        } else if (exception instanceof UsernameNotFoundException) {
            errorMessage = "존재하지 않는 아이디입니다.";
        } else if (exception instanceof AccountExpiredException) {
            errorMessage = "만료된 계정입니다. 관리자에게 문의하세요.";
        } else if (exception instanceof CredentialsExpiredException) {
            errorMessage = "비밀번호가 만료되었습니다. 비밀번호를 재설정해주세요.";
        } else if (exception instanceof DisabledException) {
            errorMessage = "비활성화된 계정입니다. 관리자에게 문의하세요.";
        } else if (exception instanceof LockedException) {
            errorMessage = "잠긴 계정입니다. 관리자에게 문의하세요.";
        } else {
            errorMessage = "로그인에 실패했습니다. 다시 시도해주세요.";
        }

        // 에러 메시지를 URL 인코딩하여 전달
        String encodedMessage = URLEncoder.encode(errorMessage, "UTF-8");
        response.sendRedirect("/member/login?error=" + encodedMessage);
    }
}
