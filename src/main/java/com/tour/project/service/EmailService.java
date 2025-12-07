package com.tour.project.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.stereotype.Component;

import javax.mail.internet.MimeMessage;
import java.util.Random;

@Service
@Component
public class EmailService {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    /**
     * 6자리 인증번호 생성
     */
    public String generateVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999));
    }

    /**
     * 이메일로 인증번호 발송
     */
    public boolean sendVerificationEmail(String to, String code) {
        try {
            System.out.println("[EmailService] 이메일 발송 시작: " + to);
            System.out.println("[EmailService] 인증번호: " + code);

            if (mailSender == null) {
                System.err.println("[EmailService] JavaMailSender가 null입니다!");
                // 개발 환경에서는 콘솔 출력으로 대체
                System.out.println("===============================================");
                System.out.println("[개발 모드] 이메일 인증번호");
                System.out.println("이메일: " + to);
                System.out.println("인증번호: " + code);
                System.out.println("===============================================");
                return true;  // 개발 모드에서는 성공으로 처리
            }
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setFrom("gyusunsun@gmail.com");
            helper.setSubject("[AI 여행 동행] 이메일 인증번호");

            String htmlContent =
                "<div style='font-family: Arial, sans-serif; padding: 20px; background-color: #f5f5f5;'>" +
                "    <div style='max-width: 600px; margin: 0 auto; background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
                "        <h2 style='color: #ff6b6b; text-align: center;'>AI 여행 동행 매칭 플랫폼</h2>" +
                "        <hr style='border: none; border-top: 2px solid #4ecdc4; margin: 20px 0;'>" +
                "        <p style='font-size: 16px; color: #333;'>안녕하세요!</p>" +
                "        <p style='font-size: 16px; color: #333;'>회원가입을 위한 이메일 인증번호입니다.</p>" +
                "        <div style='background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%); padding: 20px; border-radius: 8px; text-align: center; margin: 30px 0;'>" +
                "            <h1 style='color: white; margin: 0; letter-spacing: 5px;'>" + code + "</h1>" +
                "        </div>" +
                "        <p style='font-size: 14px; color: #666;'>• 인증번호는 5분간 유효합니다.</p>" +
                "        <p style='font-size: 14px; color: #666;'>• 본인이 요청하지 않은 경우 이 메일을 무시하세요.</p>" +
                "        <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'>" +
                "        <p style='font-size: 12px; color: #999; text-align: center;'>© 2024 AI 여행 동행 매칭 플랫폼. All rights reserved.</p>" +
                "    </div>" +
                "</div>";

            helper.setText(htmlContent, true);

            mailSender.send(message);
            System.out.println("[이메일 발송 성공] " + to + " : " + code);
            return true;

        } catch (Exception e) {
            System.err.println("[이메일 발송 실패] " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 간단한 텍스트 이메일 발송 (백업용)
     */
    public boolean sendSimpleVerificationEmail(String to, String code) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(to);
            message.setSubject("[AI 여행 동행] 이메일 인증번호");
            message.setText("인증번호: " + code + "\n\n5분 내에 입력해주세요.");

            mailSender.send(message);
            return true;
        } catch (Exception e) {
            System.err.println("[이메일 발송 실패] " + e.getMessage());
            return false;
        }
    }
}