package com.tour.project.service;

import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.UserTravelMbtiDTO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.servlet.http.HttpSession;

/**
 * MBTI 시스템과 트렌드 분석 통합 서비스
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MbtiIntegrationService {
    
    private final TravelMbtiDAO travelMbtiDAO;
    
    /**
     * 사용자의 MBTI 정보 조회
     */
    public String getUserMbtiType(String userId) {
        try {
            if (userId == null || userId.isEmpty()) {
                log.warn("사용자 ID가 없어 MBTI 조회 불가");
                return null;
            }
            
            UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(userId);
            if (userMbti != null && userMbti.getMbtiType() != null) {
                log.info("사용자 MBTI 조회 성공 - 사용자: {}, MBTI: {}", userId, userMbti.getMbtiType());
                return userMbti.getMbtiType();
            }
            
            log.info("사용자의 MBTI 테스트 결과가 없음 - 사용자: {}", userId);
            return null;
            
        } catch (Exception e) {
            log.error("MBTI 조회 실패 - 사용자: {}", userId, e);
            return null;
        }
    }
    
    /**
     * 세션에서 사용자의 MBTI 정보 조회
     */
    public String getUserMbtiFromSession(HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser != null && loginUser.getUserId() != null) {
                return getUserMbtiType(loginUser.getUserId());
            }
            
            log.info("로그인하지 않은 사용자, MBTI 정보 없음");
            return null;
            
        } catch (Exception e) {
            log.error("세션에서 MBTI 조회 실패", e);
            return null;
        }
    }
    
    /**
     * MBTI 테스트 필요 여부 확인
     */
    public boolean isMbtiTestRequired(String userId) {
        String mbtiType = getUserMbtiType(userId);
        return mbtiType == null || mbtiType.isEmpty();
    }
    
    /**
     * MBTI 테스트 URL 생성
     */
    public String getMbtiTestUrl() {
        return "/travel-mbti/test";
    }
    
    /**
     * MBTI 타입별 특성 설명 조회
     */
    public String getMbtiDescription(String mbtiType) {
        if (mbtiType == null || mbtiType.length() != 4) {
            return "유효하지 않은 MBTI 타입입니다.";
        }
        
        // MBTI 타입별 여행 성향 설명
        switch (mbtiType.toUpperCase()) {
            case "ENFP":
                return "열정적이고 창의적인 탐험가. 새로운 경험과 모험을 추구하며, 자유로운 여행을 선호합니다.";
            case "ENFJ":
                return "사교적이고 배려심 많은 여행자. 현지 문화 체험과 사람들과의 교류를 중시합니다.";
            case "ENTP":
                return "독창적이고 활발한 모험가. 즉흥적인 여행과 새로운 아이디어 탐구를 좋아합니다.";
            case "ENTJ":
                return "체계적이고 목표지향적인 리더. 계획적이고 효율적인 여행을 선호합니다.";
            case "ESFP":
                return "자유롭고 즐거움을 추구하는 여행자. 감각적 경험과 즉석 모험을 즐깁니다.";
            case "ESFJ":
                return "따뜻하고 협조적인 여행자. 가족이나 친구와 함께하는 안전한 여행을 선호합니다.";
            case "ESTP":
                return "현실적이고 활동적인 모험가. 스릴 넘치는 액티비티와 실용적 여행을 추구합니다.";
            case "ESTJ":
                return "실용적이고 조직적인 계획가. 철저한 계획과 일정 관리를 통한 효율적 여행을 선호합니다.";
            case "INFP":
                return "이상주의적이고 감성적인 여행자. 의미 있는 경험과 개인적 성장을 추구합니다.";
            case "INFJ":
                return "통찰력 있고 신중한 여행자. 깊이 있는 문화 체험과 영감을 주는 장소를 선호합니다.";
            case "INTP":
                return "논리적이고 독립적인 탐구자. 지적 호기심을 자극하는 독특한 여행지를 선호합니다.";
            case "INTJ":
                return "전략적이고 독립적인 계획가. 목적 있는 여행과 효율적인 일정을 중시합니다.";
            case "ISFP":
                return "온화하고 예술적인 여행자. 자연 친화적이고 평온한 여행을 추구합니다.";
            case "ISFJ":
                return "신중하고 책임감 있는 여행자. 안전하고 편안한 전통적 여행지를 선호합니다.";
            case "ISTP":
                return "실용적이고 적응력 있는 여행자. 자유로운 탐험과 기술적 활동을 즐깁니다.";
            case "ISTJ":
                return "신뢰할 수 있고 체계적인 여행자. 계획적이고 검증된 여행지를 선호합니다.";
            default:
                return "다양한 여행 스타일을 가진 여행자입니다.";
        }
    }
    
    /**
     * MBTI 타입별 추천 여행 스타일
     */
    public String getRecommendedTravelStyle(String mbtiType) {
        if (mbtiType == null || mbtiType.length() != 4) {
            return "균형잡힌 여행";
        }
        
        char extraversion = mbtiType.charAt(0); // E/I
        char sensing = mbtiType.charAt(1);      // S/N
        char thinking = mbtiType.charAt(2);     // T/F
        char judging = mbtiType.charAt(3);      // J/P
        
        StringBuilder style = new StringBuilder();
        
        // 외향성/내향성에 따른 스타일
        if (extraversion == 'E') {
            style.append("활동적이고 사교적인 ");
        } else {
            style.append("조용하고 개인적인 ");
        }
        
        // 감각/직관에 따른 스타일
        if (sensing == 'S') {
            style.append("현실적이고 실용적인 ");
        } else {
            style.append("창의적이고 탐험적인 ");
        }
        
        // 판단/인식에 따른 스타일
        if (judging == 'J') {
            style.append("계획적 여행");
        } else {
            style.append("자유로운 여행");
        }
        
        return style.toString();
    }
    
    /**
     * MBTI별 추천 여행지 태그
     */
    public String[] getMbtiTravelTags(String mbtiType) {
        if (mbtiType == null || mbtiType.length() != 4) {
            return new String[]{"다양성", "균형", "탐험"};
        }
        
        switch (mbtiType.toUpperCase()) {
            case "ENFP":
                return new String[]{"모험", "창의성", "자유", "새로운경험", "즉흥"};
            case "ENFJ":
                return new String[]{"문화체험", "사람", "교류", "의미", "성장"};
            case "ENTP":
                return new String[]{"혁신", "도전", "변화", "아이디어", "토론"};
            case "ENTJ":
                return new String[]{"효율", "목표", "성취", "리더십", "계획"};
            case "ESFP":
                return new String[]{"즐거움", "감각", "활동", "즉석", "파티"};
            case "ESFJ":
                return new String[]{"가족", "안전", "전통", "서비스", "배려"};
            case "ESTP":
                return new String[]{"액션", "스릴", "현실", "활동", "경쟁"};
            case "ESTJ":
                return new String[]{"조직", "효율", "일정", "관리", "실용"};
            case "INFP":
                return new String[]{"의미", "감성", "개인", "성장", "이상"};
            case "INFJ":
                return new String[]{"통찰", "깊이", "영감", "조용함", "사색"};
            case "INTP":
                return new String[]{"분석", "독특함", "지식", "독립", "탐구"};
            case "INTJ":
                return new String[]{"전략", "목적", "독립", "효율", "비전"};
            case "ISFP":
                return new String[]{"자연", "평온", "예술", "개인", "조화"};
            case "ISFJ":
                return new String[]{"안전", "전통", "책임", "배려", "신중"};
            case "ISTP":
                return new String[]{"도구", "기술", "실용", "독립", "탐험"};
            case "ISTJ":
                return new String[]{"계획", "신뢰", "전통", "체계", "안정"};
            default:
                return new String[]{"다양성", "균형", "탐험"};
        }
    }
}