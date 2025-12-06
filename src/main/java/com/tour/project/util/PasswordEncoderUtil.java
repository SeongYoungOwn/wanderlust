package com.tour.project.util;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordEncoderUtil {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

        // 테스트용 비밀번호 암호화
        String[] passwords = {"123456", "admin", "test", "password"};

        System.out.println("=== BCrypt 암호화된 비밀번호 ===");
        for (String password : passwords) {
            String encoded = encoder.encode(password);
            System.out.println("원본: " + password);
            System.out.println("암호화: " + encoded);
            System.out.println("SQL: UPDATE member SET user_password = '" + encoded + "' WHERE user_id = 'userId';");
            System.out.println("----------------------------------------");
        }
    }
}