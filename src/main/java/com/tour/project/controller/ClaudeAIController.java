package com.tour.project.controller;

import com.tour.project.service.AiProviderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * AI 여행 추천 컨트롤러
 * - AiProviderService를 사용하여 Claude/Gemini Fallback 지원
 * - /map/sido 페이지에서 호출됨
 */
@Slf4j
@Controller
@RequestMapping("/api/ai")
@RequiredArgsConstructor
public class ClaudeAIController {

    private final AiProviderService aiProviderService;

    @PostMapping("/recommend")
    @ResponseBody
    public Map<String, Object> getTravelRecommendation(
            @RequestParam String region,
            @RequestParam String period,
            @RequestParam String count,
            @RequestParam(required = false, defaultValue = "상관없음") String budget) {

        log.info("=== AI 추천 요청 받음 ===");
        log.info("region: {}, period: {}, count: {}, budget: {}", region, period, count, budget);
        log.info("Primary Provider: {}, Fallback 가능: {}",
                aiProviderService.getPrimaryProvider(),
                aiProviderService.getProviderStatus().isFallbackAvailable());

        Map<String, Object> response = new HashMap<>();

        try {
            // AI 사용 가능 여부 확인
            if (!aiProviderService.isAnyProviderAvailable()) {
                log.warn("사용 가능한 AI Provider가 없습니다. 더미 응답을 반환합니다.");
                response.put("success", true);
                response.put("recommendation", generateDummyRecommendation(region, period, count, budget));
                response.put("provider", "dummy");
                return response;
            }

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

            // AiProviderService를 통해 AI 호출 (Claude/Gemini Fallback 자동 지원)
            AiProviderService.AiResponse aiResponse = aiProviderService.queryWithSystemAndConfig(
                null,  // 시스템 프롬프트 없음
                prompt,
                3000,  // max_tokens
                0.7    // temperature
            );

            if (aiResponse.isSuccess()) {
                log.info("AI 응답 성공 - Provider: {}, 토큰: {}",
                        aiResponse.getProvider(), aiResponse.getTotalTokens());

                response.put("success", true);
                response.put("recommendation", aiResponse.getContent());
                response.put("provider", aiResponse.getProvider());
                response.put("tokens", aiResponse.getTotalTokens());
            } else {
                log.error("AI 응답 실패 - Provider: {}, 오류: {}",
                        aiResponse.getProvider(), aiResponse.getErrorMessage());

                // AI 실패 시 더미 응답 반환
                response.put("success", true);
                response.put("recommendation", generateDummyRecommendation(region, period, count, budget));
                response.put("provider", "fallback");
                response.put("originalError", aiResponse.getErrorMessage());
            }

        } catch (Exception e) {
            log.error("AI 추천 생성 중 예외 발생", e);
            response.put("success", false);
            response.put("message", "AI 추천 생성 중 오류가 발생했습니다: " + e.getMessage());
        }

        return response;
    }

    /**
     * Provider 상태 확인 API
     */
    @GetMapping("/provider-status")
    @ResponseBody
    public Map<String, Object> getProviderStatus() {
        Map<String, Object> status = new HashMap<>();
        AiProviderService.ProviderStatus providerStatus = aiProviderService.getProviderStatus();

        status.put("primaryProvider", providerStatus.getPrimaryProvider());
        status.put("claudeConfigured", providerStatus.isClaudeConfigured());
        status.put("geminiConfigured", providerStatus.isGeminiConfigured());
        status.put("fallbackAvailable", providerStatus.isFallbackAvailable());
        status.put("anyProviderAvailable", aiProviderService.isAnyProviderAvailable());

        return status;
    }

    private String generateDummyRecommendation(String region, String period, String count, String budget) {
        return "🎯 **" + region + " 여행 개요**\n" +
               "- 추천 테마: 자연과 문화가 어우러진 힐링 여행\n" +
               "- 예상 총 비용: 1인당 약 25만원\n" +
               "- 최적 여행 시기: 봄, 가을\n\n" +
               "📅 **일차별 상세 일정**\n\n" +
               "**1일차**\n" +
               "🌅 **오전 (9:00-12:00)**\n" +
               "- " + region + " 주요 관광명소 방문\n" +
               "- 예상 소요시간: 3시간, 입장료: 5,000원\n\n" +
               "🍽️ **점심 (12:00-14:00)**\n" +
               "- 현지 맛집에서 " + region + " 특색 요리 체험\n" +
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
               "- 현지 특산품: " + region + " 특색 기념품\n" +
               "- 날씨 변화에 대비한 옷차림 준비\n\n" +
               "💰 **예상 총 비용 (1인 기준)**\n" +
               "- 교통비: 50,000원\n" +
               "- 숙박비: 80,000원\n" +
               "- 식비: 50,000원\n" +
               "- 관광/체험비: 50,000원\n" +
               "- 기타: 20,000원\n" +
               "- **총합: 250,000원**\n\n" +
               "※ AI API 키가 설정되지 않아 기본 추천을 제공합니다. 관리자 설정에서 Claude 또는 Gemini API 키를 등록해주세요.";
    }
}
