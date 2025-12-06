package com.tour.project.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.filter.CharacterEncodingFilter;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.charset.StandardCharsets;
import java.util.List;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Value("${upload.path}")
    private String uploadPath;
    
    @Bean
    public CharacterEncodingFilter characterEncodingFilter() {
        CharacterEncodingFilter filter = new CharacterEncodingFilter();
        filter.setEncoding("UTF-8");
        filter.setForceEncoding(true);
        return filter;
    }
    
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 업로드된 파일에 대한 정적 리소스 매핑
        String normalizedPath = uploadPath;
        if (!normalizedPath.endsWith("/")) {
            normalizedPath += "/";
        }

        // 경로 형식 변환
        normalizedPath = normalizedPath.replace("\\", "/");

        // file: 프로토콜 설정
        String fileUrl;
        if (normalizedPath.startsWith("/")) {
            // 절대 경로인 경우 (Linux: /app/uploads/)
            fileUrl = "file:" + normalizedPath;
        } else {
            // 상대 경로인 경우 (Windows: uploads/) -> 절대 경로로 변환
            java.io.File uploadDir = new java.io.File(normalizedPath);
            String absolutePath = uploadDir.getAbsolutePath().replace("\\", "/");
            if (!absolutePath.endsWith("/")) {
                absolutePath += "/";
            }
            fileUrl = "file:///" + absolutePath;
            System.out.println("=== 업로드 경로 매핑 ===");
            System.out.println("설정된 경로: " + uploadPath);
            System.out.println("절대 경로: " + absolutePath);
            System.out.println("파일 URL: " + fileUrl);
        }

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(fileUrl)
                .setCachePeriod(3600)  // 1시간 캐시
                .resourceChain(true);

        // 기본 정적 리소스 매핑 (WAR 배포용)
        registry.addResourceHandler("/resources/**")
                .addResourceLocations("/resources/", "classpath:/static/", "classpath:/public/")
                .setCachePeriod(3600)
                .resourceChain(true);
    }
    
    // Message converter configuration moved to JacksonConfig.java to avoid conflicts
}