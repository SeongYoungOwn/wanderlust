package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/api/ai")
public class ClaudeAIController {
    
    @Value("${claude.api.key:}")
    private String apiKey;
    
    @Value("${claude.api.url:https://api.anthropic.com/v1/messages}")
    private String apiUrl;
    
    @PostMapping("/recommend")
    @ResponseBody
    public Map<String, Object> getTravelRecommendation(
            @RequestParam String region,
            @RequestParam String period,
            @RequestParam String count,
            @RequestParam(required = false, defaultValue = "상관없음") String budget) {
        
        System.out.println("=== AI 추천 요청 받음 ===");
        System.out.println("region: " + region);
        System.out.println("period: " + period);
        System.out.println("count: " + count);
        System.out.println("budget: " + budget);
        
        Map<String, Object> response = new HashMap<>();
        
        try {
            String prompt = String.format(
                "다음 조건에 맞는 한국 여행 계획을 상세하게 작성해주세요:\n" +
                "- 여행 지역: %s\n" +
                "- 여행 기간: %s\n" +
                "- 동행 인원: %s\n" +
                "- 예산: %s\n\n" +
                "다음 형식으로 작성해주세요:\n\n" +
                "🎯 **여행 개요**\n" +
                "- 추천 테마: (자연/문화/미식/액티비티 등)\n" +
                "- 예상 총 비용: (1인 기준)\n" +
                "- 최적 여행 시기: \n\n" +
                "📅 **일차별 상세 일정**\n\n" +
                "**1일차**\n" +
                "🌅 **오전 (9:00-12:00)**\n" +
                "- 구체적인 장소명과 활동 내용\n" +
                "- 예상 소요시간과 비용\n\n" +
                "🍽️ **점심 (12:00-14:00)**\n" +
                "- 추천 맛집과 대표 메뉴\n" +
                "- 예상 비용\n\n" +
                "☀️ **오후 (14:00-18:00)**\n" +
                "- 오후 활동 및 관광지\n" +
                "- 예상 소요시간과 비용\n\n" +
                "🌆 **저녁 (18:00-21:00)**\n" +
                "- 저녁 식사 및 야간 활동\n" +
                "- 예상 비용\n\n" +
                "🏨 **숙박**\n" +
                "- 추천 숙소 유형과 위치\n" +
                "- 예상 비용\n\n" +
                "(여행 기간에 맞게 2일차, 3일차... 계속 작성)\n\n" +
                "💡 **여행 팁**\n" +
                "- 교통 정보 및 이동 방법\n" +
                "- 현지 특산품 및 쇼핑 정보\n" +
                "- 주의사항 및 준비물\n\n" +
                "💰 **예상 총 비용 (1인 기준)**\n" +
                "- 교통비: \n" +
                "- 숙박비: \n" +
                "- 식비: \n" +
                "- 관광/체험비: \n" +
                "- 기타: \n" +
                "- **총합: **\n\n" +
                "각 항목은 구체적이고 실용적인 정보를 포함해주세요. " +
                "특히 제시된 예산 범위 내에서 여행할 수 있는 현실적인 계획을 세워주세요.",
                region, period, count, budget
            );
            
            String aiResponse = callClaudeAPI(prompt);
            System.out.println("Claude API 응답 길이: " + (aiResponse != null ? aiResponse.length() : 0));
            
            response.put("success", true);
            response.put("recommendation", aiResponse);
            System.out.println("응답 전송 중: " + response.get("success"));
            
        } catch (Exception e) {
            System.err.println("AI 추천 생성 중 오류: " + e.getMessage());
            e.printStackTrace();
            response.put("success", false);
            response.put("message", "AI 추천 생성 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    private String callClaudeAPI(String prompt) throws Exception {
        // Claude API 키가 없으면 더미 응답 반환
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return generateDummyRecommendation(prompt);
        }
        
        RestTemplate restTemplate = new RestTemplate();
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.set("x-api-key", apiKey);
        headers.set("anthropic-version", "2023-06-01");
        
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "claude-sonnet-4-20250514");
        requestBody.put("max_tokens", 3000);
        requestBody.put("temperature", 0.7);
        
        Map<String, String> message = new HashMap<>();
        message.put("role", "user");
        message.put("content", prompt);
        requestBody.put("messages", List.of(message));
        
        HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
        
        try {
            ResponseEntity<Map> response = restTemplate.exchange(
                apiUrl,
                HttpMethod.POST,
                request,
                Map.class
            );
            
            Map<String, Object> responseBody = response.getBody();
            if (responseBody != null && responseBody.containsKey("content")) {
                List<Map<String, Object>> content = (List<Map<String, Object>>) responseBody.get("content");
                if (!content.isEmpty()) {
                    return (String) content.get(0).get("text");
                }
            }
            
            throw new Exception("Claude API로부터 올바른 응답을 받지 못했습니다.");
            
        } catch (Exception e) {
            throw new Exception("Claude API 호출 중 오류 발생: " + e.getMessage());
        }
    }
    
    private String generateDummyRecommendation(String prompt) {
        return "🎯 **여행 개요**\n" +
               "- 추천 테마: 자연과 문화가 어우러진 힐링 여행\n" +
               "- 예상 총 비용: 1인당 약 25만원\n" +
               "- 최적 여행 시기: 봄, 가을\n\n" +
               "📅 **일차별 상세 일정**\n\n" +
               "**1일차**\n" +
               "🌅 **오전 (9:00-12:00)**\n" +
               "- 주요 관광명소 방문\n" +
               "- 예상 소요시간: 3시간, 입장료: 5,000원\n\n" +
               "🍽️ **점심 (12:00-14:00)**\n" +
               "- 현지 맛집에서 특색 요리 체험\n" +
               "- 예상 비용: 15,000원\n\n" +
               "☀️ **오후 (14:00-18:00)**\n" +
               "- 문화체험 및 쇼핑\n" +
               "- 예상 소요시간: 4시간, 비용: 30,000원\n\n" +
               "🌆 **저녁 (18:00-21:00)**\n" +
               "- 저녁 식사 및 야경 감상\n" +
               "- 예상 비용: 20,000원\n\n" +
               "🏨 **숙박**\n" +
               "- 시내 중심가 호텔 또는 게스트하우스\n" +
               "- 예상 비용: 80,000원\n\n" +
               "💡 **여행 팁**\n" +
               "- 대중교통 이용 시 교통카드 구매 권장\n" +
               "- 현지 특산품: 지역 특색 기념품\n" +
               "- 날씨 변화에 대비한 옷차림 준비\n\n" +
               "💰 **예상 총 비용 (1인 기준)**\n" +
               "- 교통비: 50,000원\n" +
               "- 숙박비: 80,000원\n" +
               "- 식비: 50,000원\n" +
               "- 관광/체험비: 50,000원\n" +
               "- 기타: 20,000원\n" +
               "- **총합: 250,000원**\n\n" +
               "※ 실제 Claude API 키가 설정되지 않아 더미 응답을 제공하고 있습니다.";
    }
}