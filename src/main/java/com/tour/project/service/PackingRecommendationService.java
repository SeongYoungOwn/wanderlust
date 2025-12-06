package com.tour.project.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tour.project.dto.PackingRequestDTO;
import com.tour.project.dto.PackingRecommendationDTO;
import com.tour.project.dto.PackingRecommendationDTO.PackingItemDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.ListItem;
import com.itextpdf.layout.element.Text;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.font.PdfFontFactory;
import com.itextpdf.io.font.constants.StandardFonts;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class PackingRecommendationService {

    private final WebClient webClient;
    private final ObjectMapper objectMapper;
    private final Map<String, List<Map<String, String>>> conversationHistories;
    private final Map<String, PackingRecommendationDTO> packingRecommendations;

    @Autowired
    private ApiKeyService apiKeyService;
    
    // 패킹 어시스턴트 전용 시스템 프롬프트
    private static final String PACKING_SYSTEM_PROMPT = 
        "당신은 친근하고 실용적인 여행 패킹 어시스턴트입니다. 사용자가 제공한 정보를 바탕으로 즉시 도움이 되는 패킹 리스트를 제공합니다.\n\n" +
        "대화 방식:\n" +
        "1. 사용자가 여행 정보를 제공하면, 그 정보만으로도 바로 유용한 패킹 리스트를 제공하세요.\n" +
        "2. 너무 많은 질문을 하지 마세요. 필요한 경우에만 1-2개의 간단한 추가 질문을 하세요.\n" +
        "3. 사용자가 '캐리비안베이 놀러가는데 뭐 필요해?' 같이 물으면, 워터파크에 필요한 준비물을 바로 알려주세요.\n\n" +
        "응답 예시:\n" +
        "- 사용자: '캐리비안베이 놀러갈건데 준비물이 뭐가 필요해?'\n" +
        "- AI: '캐리비안베이 재미있게 놀고 오세요! 🏊 워터파크 필수 준비물 알려드릴게요:\n\n" +
        "**수영 용품**\n" +
        "[필수] ⭐ 수영복 - 여벌 준비하면 더 좋아요\n" +
        "[필수] ⭐ 수건 - 대형 타월 2장 이상\n" +
        "[권장] 아쿠아슈즈 - 미끄럼 방지용\n\n" +
        "**방수 용품**\n" +
        "[필수] ⭐ 방수팩 - 휴대폰, 현금 보관용\n" +
        "[권장] 방수 선크림 - SPF50+ 추천\n\n" +
        "추가로 필요한 게 있으면 말씀해주세요!'\n\n" +
        "패킹 리스트 제공 방식:\n" +
        "- 사용자가 충분한 정보를 제공했다면 바로 맞춤형 패킹 리스트 제공\n" +
        "- 정보가 부족하면 간단한 추가 질문 1-2개만 (예: '당일치기인가요, 1박 2일인가요?')\n" +
        "- 카테고리별로 정리: 의류, 세면용품, 전자기기, 여행용품, 액티비티 용품, 기타\n" +
        "- 각 아이템: [필수] ⭐ 아이템명 - 간단한 설명 (필수 아이템에는 반드시 별 이모티콘 추가)\n" +
        "- [권장] 아이템명 - 간단한 설명, [선택] 아이템명 - 간단한 설명\n\n" +
        "완성된 패킹 리스트 제공 시:\n" +
        "- 충분한 정보가 모였을 때 '📋 맞춤 패킹 리스트' 또는 '✅ 준비물 체크리스트'라는 제목 사용\n" +
        "- 각 카테고리에 최소 3개 이상의 아이템 포함\n" +
        "- 전체 리스트는 500자 이상으로 상세히 작성";
    
    public PackingRecommendationService() {
        this.webClient = WebClient.builder()
            .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
            .build();
        this.objectMapper = new ObjectMapper();
        this.conversationHistories = new HashMap<>();
        this.packingRecommendations = new HashMap<>();
    }
    
    /**
     * AI 패킹 추천 생성
     */
    public PackingRecommendationDTO generatePackingRecommendation(PackingRequestDTO request) {
        try {
            String conversationId = UUID.randomUUID().toString();
            String userPrompt = request.buildPrompt();
            
            // Claude API 호출
            String aiResponse = callClaudeAPI(userPrompt, conversationId);
            
            // AI 응답에서 패킹 아이템 파싱
            Map<String, List<PackingItemDTO>> categorizedItems = parsePackingItems(aiResponse);
            
            // 패킹 추천 DTO 생성
            PackingRecommendationDTO recommendation = new PackingRecommendationDTO();
            recommendation.setConversationId(conversationId);
            recommendation.setUserId(request.getUserId());
            recommendation.setAiResponse(aiResponse);
            recommendation.setCategorizedItems(categorizedItems);
            recommendation.setDestination(request.getDestination());
            recommendation.setDuration(request.getDuration());
            recommendation.setSeason(request.getSeason());
            recommendation.setTravelPurpose(request.getTravelPurpose());
            recommendation.setComplete(true);
            
            // 메모리에 저장
            packingRecommendations.put(conversationId, recommendation);
            
            return recommendation;
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("패킹 추천 생성 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    /**
     * AI와 실시간 대화
     */
    public Map<String, Object> chatWithAI(String userMessage, String conversationId, String userId) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // 대화 기록 가져오기
            List<Map<String, String>> history = conversationHistories.getOrDefault(conversationId, new ArrayList<>());
            
            // 사용자 메시지 추가
            Map<String, String> userMsg = new HashMap<>();
            userMsg.put("role", "user");
            userMsg.put("content", userMessage);
            history.add(userMsg);
            
            // Claude API 호출 (대화 기록 포함)
            String aiResponse = callClaudeAPIWithHistory(userMessage, history);
            
            // AI 응답 추가
            Map<String, String> aiMsg = new HashMap<>();
            aiMsg.put("role", "assistant");
            aiMsg.put("content", aiResponse);
            history.add(aiMsg);
            
            // 대화 기록 저장
            conversationHistories.put(conversationId, history);
            
            // 대화 완료 여부 확인
            boolean isComplete = isConversationComplete(aiResponse);
            
            response.put("aiMessage", aiResponse);
            response.put("conversationComplete", isComplete);
            
            // 대화가 완료되면 패킹 리스트 생성
            if (isComplete) {
                Map<String, List<PackingItemDTO>> packingList = parsePackingItems(aiResponse);
                response.put("packingList", packingList);
                
                // 추천 결과 저장
                PackingRecommendationDTO recommendation = new PackingRecommendationDTO();
                recommendation.setConversationId(conversationId);
                recommendation.setUserId(userId);
                recommendation.setAiResponse(aiResponse);
                recommendation.setCategorizedItems(packingList);
                recommendation.setComplete(true);
                
                packingRecommendations.put(conversationId, recommendation);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("AI 대화 중 오류가 발생했습니다: " + e.getMessage());
        }
        
        return response;
    }
    
    /**
     * Claude API 호출 (단일 메시지)
     */
    private String callClaudeAPI(String userPrompt, String conversationId) {
        try {
            // API 키 동적 조회
            String apiKey = apiKeyService.getApiKey();
            String apiUrl = apiKeyService.getApiUrl();

            // API 키 확인
            if (apiKey == null || apiKey.isEmpty() || !apiKeyService.isApiKeyConfigured()) {
                throw new RuntimeException("AI 기능이 비활성화되어 있습니다. 관리자에게 문의하세요.");
            }

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "claude-sonnet-4-20250514");
            requestBody.put("max_tokens", 3000);
            requestBody.put("temperature", 0.7);
            requestBody.put("system", PACKING_SYSTEM_PROMPT);

            // 메시지 구성
            Map<String, String> userMessage = new HashMap<>();
            userMessage.put("role", "user");
            userMessage.put("content", userPrompt);

            requestBody.put("messages", List.of(userMessage));

            String jsonBody = objectMapper.writeValueAsString(requestBody);

            // API 호출
            String response = webClient.post()
                .uri(apiUrl)
                .header("x-api-key", apiKey)
                .header("anthropic-version", "2023-06-01")
                .header("content-type", "application/json")
                .bodyValue(jsonBody)
                .retrieve()
                .bodyToMono(String.class)
                .block();
            
            // 응답 파싱
            JsonNode jsonResponse = objectMapper.readTree(response);
            return jsonResponse.path("content").get(0).path("text").asText();
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Claude API 호출 실패: " + e.getMessage());
        }
    }
    
    /**
     * Claude API 호출 (대화 기록 포함)
     */
    private String callClaudeAPIWithHistory(String userMessage, List<Map<String, String>> history) {
        try {
            // API 키 동적 조회
            String apiKey = apiKeyService.getApiKey();
            String apiUrl = apiKeyService.getApiUrl();

            // API 키 확인
            if (apiKey == null || apiKey.isEmpty() || !apiKeyService.isApiKeyConfigured()) {
                throw new RuntimeException("AI 기능이 비활성화되어 있습니다. 관리자에게 문의하세요.");
            }

            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("model", "claude-sonnet-4-20250514");
            requestBody.put("max_tokens", 3000);
            requestBody.put("temperature", 0.7);
            requestBody.put("system", PACKING_SYSTEM_PROMPT);
            requestBody.put("messages", history);

            String jsonBody = objectMapper.writeValueAsString(requestBody);

            // API 호출
            String response = webClient.post()
                .uri(apiUrl)
                .header("x-api-key", apiKey)
                .header("anthropic-version", "2023-06-01")
                .header("content-type", "application/json")
                .bodyValue(jsonBody)
                .retrieve()
                .bodyToMono(String.class)
                .block();
            
            // 응답 파싱
            JsonNode jsonResponse = objectMapper.readTree(response);
            return jsonResponse.path("content").get(0).path("text").asText();
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Claude API 호출 실패: " + e.getMessage());
        }
    }
    
    /**
     * AI 응답에서 패킹 아이템 파싱
     */
    private Map<String, List<PackingItemDTO>> parsePackingItems(String aiResponse) {
        Map<String, List<PackingItemDTO>> categorizedItems = new HashMap<>();
        
        // 카테고리별로 초기화
        String[] categories = {"의류", "세면용품", "전자기기", "여행용품", "액티비티 용품", "기타"};
        for (String category : categories) {
            categorizedItems.put(category, new ArrayList<>());
        }
        
        try {
            // 정규 표현식으로 아이템 파싱
            Pattern categoryPattern = Pattern.compile("(?:##?\\s*)?(.+?)(?:\\s*👕|🧴|📱|✈️|🏔️|💼|:)");
            Pattern itemPattern = Pattern.compile("\\[(필수|권장|선택)\\]\\s*(?:⭐\\s*)?(.+?)\\s*-\\s*(.+?)(?:\\n|$)");
            
            String[] lines = aiResponse.split("\\n");
            String currentCategory = "기타";
            
            for (String line : lines) {
                line = line.trim();
                if (line.isEmpty()) continue;
                
                // 카테고리 감지
                for (String category : categories) {
                    if (line.contains(category)) {
                        currentCategory = category;
                        break;
                    }
                }
                
                // 아이템 파싱
                Matcher itemMatcher = itemPattern.matcher(line);
                if (itemMatcher.find()) {
                    String necessity = itemMatcher.group(1);
                    String itemName = itemMatcher.group(2).trim();
                    String description = itemMatcher.group(3).trim();
                    
                    PackingItemDTO item = new PackingItemDTO(itemName, currentCategory, necessity, description);
                    categorizedItems.get(currentCategory).add(item);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // 파싱 실패 시 기본 아이템들 추가
            addDefaultItems(categorizedItems);
        }
        
        return categorizedItems;
    }
    
    /**
     * 기본 패킹 아이템 추가 (파싱 실패 시)
     */
    private void addDefaultItems(Map<String, List<PackingItemDTO>> categorizedItems) {
        categorizedItems.get("의류").add(new PackingItemDTO("⭐ 속옷", "의류", "필수", "여행 기간+1일분"));
        categorizedItems.get("의류").add(new PackingItemDTO("⭐ 양말", "의류", "필수", "여행 기간+1일분"));
        categorizedItems.get("세면용품").add(new PackingItemDTO("⭐ 칫솔", "세면용품", "필수", "개인 위생용"));
        categorizedItems.get("세면용품").add(new PackingItemDTO("⭐ 치약", "세면용품", "필수", "여행용 소용량"));
        categorizedItems.get("전자기기").add(new PackingItemDTO("⭐ 충전기", "전자기기", "필수", "휴대폰 충전기"));
    }
    
    /**
     * 대화 완료 여부 확인
     */
    private boolean isConversationComplete(String aiResponse) {
        String response = aiResponse.toLowerCase();
        
        // 완성된 패킹 리스트의 특징적인 패턴들을 체크
        boolean hasCategories = response.contains("의류") && 
                              (response.contains("세면용품") || response.contains("전자기기"));
        
        boolean hasCompletionMarkers = response.contains("완성된 패킹 리스트") ||
                                      response.contains("여행 준비물 정리") ||
                                      response.contains("패킹 체크리스트") ||
                                      response.contains("준비물 목록을 정리");
        
        boolean hasMultipleItems = (response.contains("[필수]") || response.contains("필수:")) &&
                                  (response.contains("[권장]") || response.contains("권장:")) &&
                                  response.length() > 500; // 충분히 긴 응답인지 체크
        
        // 패킹 리스트 형식의 패턴 체크 (카테고리와 아이템이 모두 있는 경우)
        boolean hasListFormat = response.contains("##") || response.contains("**") || 
                               response.contains("###");
        
        // 최소 3개 이상의 카테고리와 완성 마커가 있어야 완료로 판단
        return hasCompletionMarkers && (hasCategories || (hasMultipleItems && hasListFormat));
    }
    
    /**
     * 체크리스트 아이템 업데이트
     */
    public void updateChecklistItem(String conversationId, String userId, String itemName, boolean isChecked) {
        PackingRecommendationDTO recommendation = packingRecommendations.get(conversationId);
        if (recommendation != null && Objects.equals(recommendation.getUserId(), userId)) {
            Map<String, List<PackingItemDTO>> items = recommendation.getCategorizedItems();
            for (List<PackingItemDTO> categoryItems : items.values()) {
                for (PackingItemDTO item : categoryItems) {
                    if (item.getItemName().equals(itemName)) {
                        item.setChecked(isChecked);
                        break;
                    }
                }
            }
        }
    }
    
    /**
     * 체크리스트 조회
     */
    public List<Map<String, Object>> getChecklist(String conversationId, String userId) {
        List<Map<String, Object>> checklist = new ArrayList<>();
        PackingRecommendationDTO recommendation = packingRecommendations.get(conversationId);
        
        if (recommendation != null) {
            Map<String, List<PackingItemDTO>> items = recommendation.getCategorizedItems();
            for (Map.Entry<String, List<PackingItemDTO>> entry : items.entrySet()) {
                for (PackingItemDTO item : entry.getValue()) {
                    Map<String, Object> checklistItem = new HashMap<>();
                    checklistItem.put("category", entry.getKey());
                    checklistItem.put("itemName", item.getItemName());
                    checklistItem.put("necessityLevel", item.getNecessityLevel());
                    checklistItem.put("description", item.getDescription());
                    checklistItem.put("isChecked", item.isChecked());
                    checklist.add(checklistItem);
                }
            }
        }
        
        return checklist;
    }
    
    /**
     * PDF 생성
     */
    public String generatePDF(String conversationId, String userId) {
        try {
            PackingRecommendationDTO recommendation = packingRecommendations.get(conversationId);
            if (recommendation == null) {
                throw new RuntimeException("패킹 리스트를 찾을 수 없습니다.");
            }
            
            // PDF 파일 경로 설정
            String fileName = "packing-list-" + conversationId + ".pdf";
            String downloadDir = "src/main/webapp/downloads/";
            File directory = new File(downloadDir);
            if (!directory.exists()) {
                directory.mkdirs();
            }
            
            String filePath = downloadDir + fileName;
            
            // PDF 문서 생성
            PdfWriter writer = new PdfWriter(filePath);
            PdfDocument pdf = new PdfDocument(writer);
            Document document = new Document(pdf);
            
            // 한글 폰트 설정 (기본 폰트 사용)
            PdfFont font = PdfFontFactory.createFont(StandardFonts.HELVETICA);
            PdfFont boldFont = PdfFontFactory.createFont(StandardFonts.HELVETICA_BOLD);
            
            // 제목 추가
            Paragraph title = new Paragraph("🎒 여행 패킹 리스트")
                .setFont(boldFont)
                .setFontSize(18)
                .setMarginBottom(20);
            document.add(title);
            
            // 여행 정보 추가
            if (recommendation.getDestination() != null) {
                document.add(new Paragraph("목적지: " + recommendation.getDestination())
                    .setFont(font).setFontSize(12));
            }
            if (recommendation.getDuration() != null) {
                document.add(new Paragraph("기간: " + recommendation.getDuration())
                    .setFont(font).setFontSize(12));
            }
            if (recommendation.getSeason() != null) {
                document.add(new Paragraph("계절: " + recommendation.getSeason())
                    .setFont(font).setFontSize(12));
            }
            if (recommendation.getTravelPurpose() != null) {
                document.add(new Paragraph("목적: " + recommendation.getTravelPurpose())
                    .setFont(font).setFontSize(12));
            }
            
            document.add(new Paragraph("\n"));
            
            // 카테고리별 패킹 리스트 추가
            Map<String, List<PackingItemDTO>> categorizedItems = recommendation.getCategorizedItems();
            for (Map.Entry<String, List<PackingItemDTO>> entry : categorizedItems.entrySet()) {
                String category = entry.getKey();
                List<PackingItemDTO> items = entry.getValue();
                
                if (items != null && !items.isEmpty()) {
                    // 카테고리 제목
                    document.add(new Paragraph(category)
                        .setFont(boldFont)
                        .setFontSize(14)
                        .setMarginTop(15)
                        .setMarginBottom(5));
                    
                    // 아이템 리스트
                    com.itextpdf.layout.element.List itemList = new com.itextpdf.layout.element.List();
                    for (PackingItemDTO item : items) {
                        String itemText = String.format("[%s] %s - %s", 
                            item.getNecessityLevel(), 
                            item.getItemName(), 
                            item.getDescription());
                        
                        ListItem listItem = new ListItem();
                        Paragraph itemParagraph = new Paragraph(itemText).setFont(font).setFontSize(10);
                        listItem.add(itemParagraph);
                        
                        // 필수 아이템은 볼드 처리
                        if ("필수".equals(item.getNecessityLevel())) {
                            listItem.setBold();
                        }
                        
                        itemList.add(listItem);
                    }
                    document.add(itemList);
                }
            }
            
            // 하단 메시지
            document.add(new Paragraph("\n즐거운 여행 되세요! 🌟")
                .setFont(font)
                .setFontSize(12)
                .setMarginTop(20));
            
            // PDF 문서 닫기
            document.close();
            
            return "/downloads/" + fileName;
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("PDF 생성 중 오류가 발생했습니다: " + e.getMessage());
        }
    }
    
    /**
     * 대화 기록 삭제
     */
    public void clearConversation(String conversationId, String userId) {
        conversationHistories.remove(conversationId);
        packingRecommendations.remove(conversationId);
    }
}