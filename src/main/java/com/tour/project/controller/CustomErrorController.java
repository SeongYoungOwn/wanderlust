package com.tour.project.controller;

import javax.servlet.http.HttpServletRequest;
import org.springframework.boot.web.servlet.error.ErrorController;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class CustomErrorController implements ErrorController {

    @RequestMapping("/error")
    public String handleError(HttpServletRequest request, Model model) {
        // 에러 상태 코드 가져오기
        Object status = request.getAttribute("javax.servlet.error.status_code");

        if (status != null) {
            Integer statusCode = Integer.valueOf(status.toString());

            // 에러 메시지 가져오기
            Throwable throwable = (Throwable) request.getAttribute("javax.servlet.error.exception");
            String errorMessage = (String) request.getAttribute("javax.servlet.error.message");

            model.addAttribute("errorCode", statusCode);
            model.addAttribute("errorMessage", errorMessage);

            // 개발 모드에서 상세 정보 표시
            if (throwable != null) {
                model.addAttribute("exception", throwable.getClass().getName());
                model.addAttribute("trace", throwable.getMessage());
            }

            // 404 에러
            if(statusCode == 404) {
                return "error/404";
            }
            // 500 에러
            else if(statusCode == 500) {
                return "error/500";
            }
        }

        return "error/error";
    }
}