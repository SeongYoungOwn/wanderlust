package com.tour.project.util;

import com.tour.project.dto.AiTravelPlanDTO;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 * AI 플래너의 응답에서 구조화된 여행 정보를 추출하는 유틸리티 클래스
 */
public class AiPlanParser {
    
    // 패턴 정의
    private static final Pattern TITLE_PATTERN = Pattern.compile(
        "(?:여행\\s*제목|제목|타이틀|title)\\s*[:\\-]?\\s*([^\\n]+)", 
        Pattern.CASE_INSENSITIVE
    );
    
    private static final Pattern DESTINATION_PATTERN = Pattern.compile(
        "(?:목적지|여행지|destination)\\s*[:\\-]?\\s*([^\\n,]+)", 
        Pattern.CASE_INSENSITIVE
    );
    
    private static final Pattern START_DATE_PATTERN = Pattern.compile(
        "(?:시작일|출발일|start\\s*date)\\s*[:\\-]?\\s*(\\d{4}[-\\/]\\d{1,2}[-\\/]\\d{1,2}|\\d{1,2}[-\\/]\\d{1,2}[-\\/]\\d{4})", 
        Pattern.CASE_INSENSITIVE
    );
    
    private static final Pattern END_DATE_PATTERN = Pattern.compile(
        "(?:종료일|도착일|end\\s*date)\\s*[:\\-]?\\s*(\\d{4}[-\\/]\\d{1,2}[-\\/]\\d{1,2}|\\d{1,2}[-\\/]\\d{1,2}[-\\/]\\d{4})", 
        Pattern.CASE_INSENSITIVE
    );
    
    private static final Pattern BUDGET_PATTERN = Pattern.compile(
        "(?:예산|budget)\\s*[:\\-]?\\s*([0-9,]+)\\s*(?:만?원|원|won)?", 
        Pattern.CASE_INSENSITIVE
    );
    
    private static final Pattern PARTICIPANTS_PATTERN = Pattern.compile(
        "(?:인원|참여자|participants?)\\s*[:\\-]?\\s*(\\d+)\\s*(?:명|인|people?)?", 
        Pattern.CASE_INSENSITIVE
    );
    
    private static final Pattern DURATION_PATTERN = Pattern.compile(
        "(\\d+)\\s*(?:박|일|days?)", 
        Pattern.CASE_INSENSITIVE
    );
    
    /**
     * AI 응답에서 여행 계획 정보를 추출하여 AiTravelPlanDTO에 설정
     * @param aiResponse AI가 생성한 여행 계획 텍스트
     * @param planDTO 정보를 저장할 DTO
     */
    public static void parseAndSetPlanInfo(String aiResponse, AiTravelPlanDTO planDTO) {
        if (aiResponse == null || planDTO == null) {
            return;
        }
        
        // 제목 추출
        String title = extractTitle(aiResponse);
        if (title != null && !title.trim().isEmpty()) {
            planDTO.setTitle(title.trim());
        }
        
        // 목적지 추출
        String destination = extractDestination(aiResponse);
        if (destination != null && !destination.trim().isEmpty()) {
            planDTO.setDestination(destination.trim());
        }
        
        // 시작일 추출
        Date startDate = extractStartDate(aiResponse);
        if (startDate != null) {
            planDTO.setStartDate(startDate);
        }
        
        // 종료일 추출
        Date endDate = extractEndDate(aiResponse);
        if (endDate != null) {
            planDTO.setEndDate(endDate);
        }
        
        // 기간 계산 또는 추출
        Integer duration = extractDuration(aiResponse, startDate, endDate);
        if (duration != null && duration > 0) {
            planDTO.setDuration(duration);
        }
        
        // 예산 추출
        BigDecimal budget = extractBudget(aiResponse);
        if (budget != null) {
            planDTO.setBudget(budget);
        }
        
        // 참여 인원 추출
        Integer maxParticipants = extractMaxParticipants(aiResponse);
        if (maxParticipants != null && maxParticipants > 0) {
            planDTO.setMaxParticipants(maxParticipants);
        } else {
            planDTO.setMaxParticipants(4); // 기본값
        }
    }
    
    /**
     * 제목 추출
     */
    private static String extractTitle(String text) {
        Matcher matcher = TITLE_PATTERN.matcher(text);
        if (matcher.find()) {
            return cleanText(matcher.group(1));
        }
        
        // 첫 번째 줄을 제목으로 사용 (패턴 매칭 실패 시)
        String[] lines = text.split("\\n");
        if (lines.length > 0 && lines[0].length() < 100) {
            return cleanText(lines[0]);
        }
        
        return null;
    }
    
    /**
     * 목적지 추출
     */
    private static String extractDestination(String text) {
        Matcher matcher = DESTINATION_PATTERN.matcher(text);
        if (matcher.find()) {
            return cleanText(matcher.group(1));
        }
        return null;
    }
    
    /**
     * 시작일 추출
     */
    private static Date extractStartDate(String text) {
        Matcher matcher = START_DATE_PATTERN.matcher(text);
        if (matcher.find()) {
            return parseDate(matcher.group(1));
        }
        return null;
    }
    
    /**
     * 종료일 추출
     */
    private static Date extractEndDate(String text) {
        Matcher matcher = END_DATE_PATTERN.matcher(text);
        if (matcher.find()) {
            return parseDate(matcher.group(1));
        }
        return null;
    }
    
    /**
     * 예산 추출 (만원 단위로 변환)
     */
    private static BigDecimal extractBudget(String text) {
        Matcher matcher = BUDGET_PATTERN.matcher(text);
        if (matcher.find()) {
            try {
                String budgetStr = matcher.group(1).replaceAll("[,\\s]", "");
                long budgetValue = Long.parseLong(budgetStr);
                
                // 만원 단위가 아닌 경우 변환
                if (budgetValue > 100000) {
                    budgetValue = budgetValue / 10000; // 원을 만원으로 변환
                }
                
                return new BigDecimal(budgetValue);
            } catch (NumberFormatException e) {
                System.err.println("Failed to parse budget: " + matcher.group(1));
            }
        }
        return null;
    }
    
    /**
     * 최대 참여 인원 추출
     */
    private static Integer extractMaxParticipants(String text) {
        Matcher matcher = PARTICIPANTS_PATTERN.matcher(text);
        if (matcher.find()) {
            try {
                return Integer.parseInt(matcher.group(1));
            } catch (NumberFormatException e) {
                System.err.println("Failed to parse participants: " + matcher.group(1));
            }
        }
        return null;
    }
    
    /**
     * 기간 추출 (시작일/종료일이 있으면 계산, 없으면 텍스트에서 추출)
     */
    private static Integer extractDuration(String text, Date startDate, Date endDate) {
        // 시작일과 종료일이 모두 있으면 계산
        if (startDate != null && endDate != null) {
            long diffInMillies = endDate.getTime() - startDate.getTime();
            long diffInDays = diffInMillies / (24 * 60 * 60 * 1000) + 1; // +1 for inclusive
            return (int) diffInDays;
        }
        
        // 텍스트에서 기간 추출
        Matcher matcher = DURATION_PATTERN.matcher(text);
        if (matcher.find()) {
            try {
                return Integer.parseInt(matcher.group(1));
            } catch (NumberFormatException e) {
                System.err.println("Failed to parse duration: " + matcher.group(1));
            }
        }
        
        return null;
    }
    
    /**
     * 날짜 문자열을 Date 객체로 변환
     */
    private static Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return null;
        }
        
        // 다양한 날짜 형식 지원
        String[] patterns = {
            "yyyy-MM-dd", "yyyy/MM/dd", "yyyy.MM.dd",
            "MM-dd-yyyy", "MM/dd/yyyy", "MM.dd.yyyy",
            "dd-MM-yyyy", "dd/MM/yyyy", "dd.MM.yyyy"
        };
        
        for (String pattern : patterns) {
            try {
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern(pattern);
                LocalDate localDate = LocalDate.parse(dateStr.trim(), formatter);
                return Date.valueOf(localDate);
            } catch (DateTimeParseException e) {
                // 다음 패턴 시도
            }
        }
        
        System.err.println("Failed to parse date: " + dateStr);
        return null;
    }
    
    /**
     * 텍스트 정리 (불필요한 문자 제거)
     */
    private static String cleanText(String text) {
        if (text == null) return null;
        
        return text.trim()
                   .replaceAll("^[\\*\\-#\\s]+", "") // 시작 부분의 마크다운 문자 제거
                   .replaceAll("[\\*\\-#]+$", "")     // 끝 부분의 마크다운 문자 제거
                   .trim();
    }
}