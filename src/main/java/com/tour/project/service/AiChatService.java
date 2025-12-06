package com.tour.project.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tour.project.dto.AiChatRequestDTO;
import com.tour.project.dto.AiChatResponseDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AiChatService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;

    @Autowired
    private ApiKeyService apiKeyService;
    
    // 시스템 프롬프트 - 여행 플래너 역할 정의
    private static final String SYSTEM_PROMPT = 
        "당신은 사용자의 질문에 따라 다양한 역할을 수행하는 친절하고 유용한 AI 어시스턴트입니다. " +
        "주요 역할은 다음과 같습니다:\n" +
        "1. 여행 계획 요청 시: 한국인을 위한 전문적인 여행 플래너가 되어, 구체적이고 실용적인 여행 일정을 제공합니다. (이때, 아래에 정의된 여행 플래너의 답변 형식을 따릅니다.)\n" +
        "2. 일반적인 질문 시: 비행기 가격, 날씨, 맛집 추천 등 여행과 관련된 단순 질문이나 다른 주제의 질문에 대해서는 정확하고 간결한 정보를 제공합니다.\n" +
        "3. 신뢰를 위한 출처 명시: 모든 추천(맛집, 명소, 활동)에는 신뢰할 수 있는 출처를 반드시 명시합니다. 어디서 정보를 가져왔는지 링크를 달아주세요." +
        "4. 답변 형식:\n" +
        "   - 여행 계획 요청 시: '1. 여행 개요', '2. 상세 일정' 등 미리 정의된 6가지 항목을 반드시 포함합니다.\n" +
        "   - 그 외 질문 시: 질문에 따라 자유로운 형식으로 답변하되, 항상 명확하고 친절한 정보를 제공합니다.\n\n" +
        "모든 답변은 친근하고 열정적인 톤으로 작성하되, 정확한 정보를 제공하세요."+
        "사용자의 질문 답변을 학습하여 더 정확한 답변과 맞춤답변을 할 수 있게 학습하세요.";
    
    public AiChatService() {
        this.webClient = WebClient.builder()
            .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
            .build();
        this.objectMapper = new ObjectMapper();
    }
    
    public AiChatResponseDTO generateTravelPlan(AiChatRequestDTO request) {
        try {
            String userPrompt = request.buildPrompt();
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "claude-sonnet-4-20250514");
            requestBody.put("max_tokens", 2000);
            requestBody.put("temperature", 0.7);
            requestBody.put("system", SYSTEM_PROMPT);
            
            // 메시지 구성
            Map<String, String> userMessage = new HashMap<>();
            userMessage.put("role", "user");
            userMessage.put("content", userPrompt);
            
            requestBody.put("messages", List.of(userMessage));
            
            String jsonBody = objectMapper.writeValueAsString(requestBody);
            
            // API 키 동적 조회
            String apiKey = apiKeyService.getApiKey();
            String apiUrl = apiKeyService.getApiUrl();

            // API 키 확인
            if (apiKey == null || apiKey.isEmpty() || !apiKeyService.isApiKeyConfigured()) {
                return new AiChatResponseDTO("AI 기능이 비활성화되어 있습니다. 관리자에게 문의하세요.", true);
            }

            // 디버그 로그
            System.out.println("API URL: " + apiUrl);
            System.out.println("API Key: " + apiKeyService.getMaskedApiKey());
            System.out.println("Request Body: " + jsonBody);
            
            // API 호출 with retry logic for 529 errors
            String response = null;
            int maxRetries = 3;
            int retryCount = 0;
            long waitTime = 2000; // Start with 2 seconds
            
            while (retryCount < maxRetries) {
                try {
                    response = webClient.post()
                        .uri(apiUrl)
                        .header("x-api-key", apiKey)
                        .header("anthropic-version", "2023-06-01")
                        .header("content-type", "application/json")
                        .bodyValue(jsonBody)
                        .retrieve()
                        .onStatus(status -> status.value() == 529, 
                            clientResponse -> {
                                System.out.println("Received 529 error - Service overloaded");
                                return Mono.error(new RuntimeException("529_OVERLOAD"));
                            })
                        .onStatus(status -> !status.is2xxSuccessful(), 
                            clientResponse -> clientResponse.bodyToMono(String.class)
                                .map(body -> new RuntimeException("API Error: " + clientResponse.statusCode() + " - " + body)))
                        .bodyToMono(String.class)
                        .block();
                    break; // Success, exit retry loop
                } catch (Exception e) {
                    // Check for 529 error in exception message or class name
                    String errorMessage = e.getMessage() != null ? e.getMessage() : "";
                    String exceptionName = e.getClass().getName();
                    
                    if (errorMessage.contains("529") || exceptionName.contains("UnknownHttpStatusCodeException")) {
                        // Additional check for Unknown status code [529]
                        if (errorMessage.contains("Unknown status code [529]") || errorMessage.contains("529_OVERLOAD")) {
                            retryCount++;
                            if (retryCount < maxRetries) {
                                System.out.println("API overloaded (529). Retrying in " + waitTime + "ms... (Attempt " + (retryCount + 1) + "/" + maxRetries + ")");
                                try {
                                    Thread.sleep(waitTime);
                                } catch (InterruptedException ie) {
                                    Thread.currentThread().interrupt();
                                }
                                waitTime *= 2; // Exponential backoff
                            } else {
                                System.err.println("Max retries exceeded for 529 error");
                                // Provide fallback template response for Tokyo
                                if (userPrompt.contains("도쿄") || userPrompt.contains("일본")) {
                                    return getFallbackTokyoPlan();
                                }
                                return new AiChatResponseDTO("죄송합니다. 현재 AI 서비스가 과부하 상태입니다. 잠시 후 다시 시도해 주세요.", true);
                            }
                        } else {
                            throw new RuntimeException(e); // Re-throw if not a 529 error
                        }
                    } else {
                        throw new RuntimeException(e); // Re-throw if not a 529 error
                    }
                }
            }
            
            if (response == null) {
                return new AiChatResponseDTO("API 응답을 받지 못했습니다. 잠시 후 다시 시도해 주세요.", true);
            }
            
            // 응답 파싱
            JsonNode jsonResponse = objectMapper.readTree(response);
            String content = jsonResponse.path("content").get(0).path("text").asText();
            
            // AI 생성 정보 면책 고지사항 추가
            StringBuilder finalResponse = new StringBuilder(content);
            finalResponse.append("\n\n");
            finalResponse.append("---\n");
            finalResponse.append("<small style='color: #666; font-size: 0.8em;'>");
            finalResponse.append("본 내용은 AI를 통해 생성된 요약 정보로, 사용자의 편의를 돕기 위해 제공됩니다. ");
            finalResponse.append("다만, 현지 사정으로 인해 운영시간이나 요금 등은 실시간으로 변경될 수 있으니, 방문 전 공식 채널을 통해 최신 정보를 확인하시는 것을 권장합니다. ");
            finalResponse.append("AI가 생성한 정보이므로, 참고용으로 활용하시고 중요한 내용은 공식 홈페이지 등에서 반드시 직접 확인해주세요.");
            finalResponse.append("</small>");
            
            return new AiChatResponseDTO(finalResponse.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            return new AiChatResponseDTO("여행 계획 생성 중 오류가 발생했습니다: " + e.getMessage(), true);
        }
    }
    
    private AiChatResponseDTO getFallbackTokyoPlan() {
        String fallbackPlan = "## 🗾 도쿄 3박 4일 추천 여행 일정\n\n" +
            "### 1. 여행 개요\n" +
            "- **목적지**: 일본 도쿄\n" +
            "- **여행 기간**: 3박 4일\n" +
            "- **예상 예산**: 1인당 약 100-150만원 (항공료 제외)\n" +
            "- **추천 시기**: 봄(3-5월), 가을(9-11월)\n\n" +
            "### 2. 상세 일정\n\n" +
            "#### Day 1: 도쿄 도착 & 시부야/하라주쿠\n" +
            "- **오전**: 나리타/하네다 공항 도착, 호텔 체크인\n" +
            "- **오후**: 시부야 스크램블 교차로, 하치코 동상\n" +
            "- **저녁**: 하라주쿠 타케시타 거리, 오모테산도 쇼핑\n" +
            "- **식사**: 이치란 라멘 (시부야점)\n\n" +
            "#### Day 2: 아사쿠사 & 스카이트리\n" +
            "- **오전**: 센소지 사원, 나카미세 거리\n" +
            "- **오후**: 도쿄 스카이트리 전망대\n" +
            "- **저녁**: 우에노 아메요코 시장\n" +
            "- **식사**: 스시 다이 (츠키지 시장)\n\n" +
            "#### Day 3: 신주쿠 & 롯폰기\n" +
            "- **오전**: 신주쿠 교엔 국립정원\n" +
            "- **오후**: 도쿄 도청 전망대 (무료)\n" +
            "- **저녁**: 롯폰기 힐즈, 모리 미술관\n" +
            "- **식사**: 카부키초 이자카야\n\n" +
            "#### Day 4: 출국\n" +
            "- **오전**: 호텔 체크아웃, 기념품 쇼핑\n" +
            "- **오후**: 공항 이동 및 출국\n\n" +
            "### 3. 숙박 추천\n" +
            "- **신주쿠**: 교통이 편리하고 쇼핑/식사 옵션 다양\n" +
            "- **시부야**: 젊고 활기찬 분위기\n" +
            "- **아사쿠사**: 전통적인 분위기, 상대적으로 저렴\n\n" +
            "### 4. 교통 팁\n" +
            "- **도쿄 메트로 패스**: 24/48/72시간권 구매 추천\n" +
            "- **Suica/Pasmo 카드**: 교통카드 필수\n" +
            "- **JR 패스**: 7일 이상 체류 시 고려\n\n" +
            "### 5. 맛집 추천\n" +
            "- 🍜 **이치란 라멘**: 돈코츠 라멘 전문점\n" +
            "- 🍣 **스시잔마이**: 24시간 스시 체인\n" +
            "- 🍛 **코코이치방야**: 일본 카레 전문점\n" +
            "- 🍱 **요시노야**: 규동 체인점\n\n" +
            "### 6. 추가 팁\n" +
            "- 무료 WiFi: 세븐일레븐, 스타벅스 등에서 이용 가능\n" +
            "- 환전: 공항보다 시내 환전소가 유리\n" +
            "- 언어: 구글 번역 앱 오프라인 다운로드 추천\n" +
            "- 예약: 인기 레스토랑은 사전 예약 필수\n\n" +
            "---\n" +
            "<small style='color: #666; font-size: 0.8em;'>⚠️ 현재 AI 서비스 과부하로 인해 미리 준비된 템플릿을 제공합니다. " +
            "더 자세하고 맞춤형 계획을 원하시면 잠시 후 다시 시도해 주세요.</small>";
            
        return new AiChatResponseDTO(fallbackPlan);
    }
}