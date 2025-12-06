package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/upload")
public class FileUploadController {
    
    @Value("${upload.path}")
    private String uploadPath;
    
    @PostMapping("/image")
    public ResponseEntity<Map<String, Object>> uploadImage(@RequestParam("file") MultipartFile file) {
        Map<String, Object> response = new HashMap<>();
        
        if (file.isEmpty()) {
            response.put("success", false);
            response.put("message", "파일이 선택되지 않았습니다.");
            return ResponseEntity.badRequest().body(response);
        }
        
        // 파일 확장자 검증
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename.substring(originalFilename.lastIndexOf(".")).toLowerCase();
        
        if (!extension.matches("\\.(jpg|jpeg|png|gif|webp)$")) {
            response.put("success", false);
            response.put("message", "이미지 파일만 업로드 가능합니다. (jpg, jpeg, png, gif, webp)");
            return ResponseEntity.badRequest().body(response);
        }
        
        // 파일 크기 검증 (10MB)
        if (file.getSize() > 10 * 1024 * 1024) {
            response.put("success", false);
            response.put("message", "파일 크기는 10MB를 초과할 수 없습니다.");
            return ResponseEntity.badRequest().body(response);
        }
        
        try {
            // 업로드 디렉토리 생성
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            
            // 고유한 파일명 생성
            String newFilename = UUID.randomUUID().toString() + extension;
            Path filePath = Paths.get(uploadPath, newFilename);
            
            // 파일 저장
            Files.copy(file.getInputStream(), filePath);
            
            response.put("success", true);
            response.put("filename", newFilename);
            response.put("url", "/uploads/" + newFilename);
            response.put("message", "파일이 성공적으로 업로드되었습니다.");
            
            System.out.println("파일 업로드 성공: " + newFilename);
            
        } catch (IOException e) {
            System.err.println("파일 업로드 실패: " + e.getMessage());
            response.put("success", false);
            response.put("message", "파일 업로드 중 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
        
        return ResponseEntity.ok(response);
    }
}