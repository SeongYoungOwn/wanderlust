package com.tour.project.service;

import org.springframework.stereotype.Service;
import java.util.*;
import java.util.regex.Pattern;

@Service
public class ProfanityFilterService {
    
    // 욕설 및 부적절한 표현 리스트
    private static final Set<String> PROFANITY_LIST = new HashSet<>(Arrays.asList(
        // 일반적인 욕설
        "시발", "시팔", "씨발", "씨팔", "시바", "씨바", 
        "개새끼", "개색끼", "개새키", "개색키",
        "병신", "병딱", "븅신", "븅딱",
        "새끼", "색끼", "새키", "색키",
        "지랄", "지럴", "지롤",
        "꺼져", "꺼저", "꺼졍",
        "엿먹어", "엿머거", "엿먹엇",
        "좆", "좇", "촛",
        "닥쳐", "닥쵸", "닥처",
        "미친", "미쳤", "미침",
        "바보", "멍청이", "등신",
        "죽어", "죽어라", "뒤져", "뒈져",
        "꼴값", "꼴통",
        
        // 변형된 표현들
        "ㅅㅂ", "ㅆㅂ", "ㅅㅂㄹㅁ",
        "ㅂㅅ", "ㅂㅇㅅ",
        "ㄱㅅㅋ", "ㄱㅅㄲ",
        "ㅈㄹ", "ㅈㄹㄹ",
        "ㅁㅊ", "ㅁㅊㄴ",
        
        // 특수문자로 변형된 표현
        "s!발", "시8", "시**", 
        "개*끼", "개**",
        "병*", "병**",
        "새*", "새**",
        
        // 영어 욕설
        "fuck", "shit", "damn", "bitch", "asshole",
        "stupid", "idiot", "moron",
        
        // 기타 부적절한 표현
        "똥", "오줌", "방귀",
        "죽음", "자살", "살인"
    ));
    
    // 문자 치환 매핑 (우회 표현 감지용)
    private static final Map<String, String> CHAR_SUBSTITUTIONS = new HashMap<>();
    static {
        CHAR_SUBSTITUTIONS.put("0", "o");
        CHAR_SUBSTITUTIONS.put("3", "e");
        CHAR_SUBSTITUTIONS.put("4", "a");
        CHAR_SUBSTITUTIONS.put("5", "s");
        CHAR_SUBSTITUTIONS.put("7", "t");
        CHAR_SUBSTITUTIONS.put("8", "b");
        CHAR_SUBSTITUTIONS.put("@", "a");
        CHAR_SUBSTITUTIONS.put("!", "i");
        CHAR_SUBSTITUTIONS.put("$", "s");
        CHAR_SUBSTITUTIONS.put("*", "");
        CHAR_SUBSTITUTIONS.put("-", "");
        CHAR_SUBSTITUTIONS.put("_", "");
        CHAR_SUBSTITUTIONS.put(" ", "");
    }
    
    /**
     * 텍스트에 욕설이 포함되어 있는지 검사
     * @param text 검사할 텍스트
     * @return 욕설 포함 여부
     */
    public boolean containsProfanity(String text) {
        if (text == null || text.trim().isEmpty()) {
            return false;
        }
        
        // 소문자로 변환하고 공백 제거
        String cleanText = text.toLowerCase().replaceAll("\\s+", "");
        
        // 특수문자 치환하여 우회 표현 감지
        String normalizedText = normalizeText(cleanText);
        
        // 직접 매칭 검사
        for (String profanity : PROFANITY_LIST) {
            if (cleanText.contains(profanity.toLowerCase()) || 
                normalizedText.contains(profanity.toLowerCase())) {
                return true;
            }
        }
        
        // 패턴 매칭으로 변형된 욕설 감지
        return detectPatternBasedProfanity(normalizedText);
    }
    
    /**
     * 특수문자를 일반 문자로 치환하여 정규화
     */
    private String normalizeText(String text) {
        String normalized = text;
        for (Map.Entry<String, String> entry : CHAR_SUBSTITUTIONS.entrySet()) {
            normalized = normalized.replace(entry.getKey(), entry.getValue());
        }
        return normalized;
    }
    
    /**
     * 패턴 기반 욕설 감지 (정규식 사용)
     */
    private boolean detectPatternBasedProfanity(String text) {
        // 시발류 변형
        Pattern sibalPattern = Pattern.compile("(시|씨)[8bㅂㅃ팔발바빨]*");
        if (sibalPattern.matcher(text).find()) return true;
        
        // 병신류 변형
        Pattern byeongsinPattern = Pattern.compile("(병|븅)[신딱ㅅㅄ]*");
        if (byeongsinPattern.matcher(text).find()) return true;
        
        // 개새끼류 변형
        Pattern gaesaekkiPattern = Pattern.compile("개[새색]*[끼키ㅋㅇ]*");
        if (gaesaekkiPattern.matcher(text).find()) return true;
        
        return false;
    }
    
    /**
     * 욕설을 마스킹 처리 (*로 치환)
     * @param text 원본 텍스트
     * @return 욕설이 마스킹된 텍스트
     */
    public String maskProfanity(String text) {
        if (text == null || text.trim().isEmpty()) {
            return text;
        }
        
        String result = text;
        String lowerText = text.toLowerCase();
        
        for (String profanity : PROFANITY_LIST) {
            String lowerProfanity = profanity.toLowerCase();
            if (lowerText.contains(lowerProfanity)) {
                String mask = "*".repeat(profanity.length());
                result = result.replaceAll("(?i)" + Pattern.quote(profanity), mask);
            }
        }
        
        return result;
    }
    
    /**
     * 욕설 감지 상세 정보 반환
     */
    public ProfanityCheckResult checkProfanityDetails(String text) {
        if (text == null || text.trim().isEmpty()) {
            return new ProfanityCheckResult(false, new ArrayList<>(), text);
        }
        
        List<String> detectedWords = new ArrayList<>();
        String cleanText = text.toLowerCase().replaceAll("\\s+", "");
        String normalizedText = normalizeText(cleanText);
        
        for (String profanity : PROFANITY_LIST) {
            String lowerProfanity = profanity.toLowerCase();
            if (cleanText.contains(lowerProfanity) || normalizedText.contains(lowerProfanity)) {
                detectedWords.add(profanity);
            }
        }
        
        boolean hasProfanity = !detectedWords.isEmpty() || detectPatternBasedProfanity(normalizedText);
        String maskedText = maskProfanity(text);
        
        return new ProfanityCheckResult(hasProfanity, detectedWords, maskedText);
    }
    
    /**
     * 욕설 검사 결과를 담는 내부 클래스
     */
    public static class ProfanityCheckResult {
        private final boolean hasProfanity;
        private final List<String> detectedWords;
        private final String maskedText;
        
        public ProfanityCheckResult(boolean hasProfanity, List<String> detectedWords, String maskedText) {
            this.hasProfanity = hasProfanity;
            this.detectedWords = detectedWords;
            this.maskedText = maskedText;
        }
        
        public boolean hasProfanity() { return hasProfanity; }
        public List<String> getDetectedWords() { return detectedWords; }
        public String getMaskedText() { return maskedText; }
    }
}