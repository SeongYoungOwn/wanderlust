package com.tour.project.service;

import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class MBTICompatibilityEngine {

    // 여행 MBTI 16x16 호환성 매트릭스 (0.0 ~ 1.0)
    // 실제 심리학 연구 및 여행 패턴 분석 기반
    private static final Map<String, Map<String, Double>> COMPATIBILITY_MATRIX = initializeMatrix();

    /**
     * 두 MBTI 간 여행 호환성 점수 계산
     * @param userMBTI 사용자의 여행 MBTI
     * @param partnerMBTI 파트너의 여행 MBTI  
     * @return 호환성 점수 (0.0 ~ 1.0)
     */
    public double calculateMBTIScore(String userMBTI, String partnerMBTI) {
        if (userMBTI == null || partnerMBTI == null) {
            return 0.5; // 정보 부족 시 중간 점수
        }
        
        try {
            Map<String, Double> userCompatibility = COMPATIBILITY_MATRIX.get(userMBTI);
            if (userCompatibility != null && userCompatibility.containsKey(partnerMBTI)) {
                return userCompatibility.get(partnerMBTI);
            }
            
            // 매트릭스에 없는 MBTI 조합의 경우 개별 차원 분석
            return calculateDimensionalCompatibility(userMBTI, partnerMBTI);
            
        } catch (Exception e) {
            return 0.5; // 에러 시 중간 점수
        }
    }

    /**
     * MBTI 차원별 호환성 계산
     */
    private double calculateDimensionalCompatibility(String userMBTI, String partnerMBTI) {
        if (userMBTI.length() != 4 || partnerMBTI.length() != 4) {
            return 0.5;
        }

        double compatibility = 0.0;
        
        // 1. 계획성 차원 (P/J) - 30% 가중치
        char userPlanning = userMBTI.charAt(0);
        char partnerPlanning = partnerMBTI.charAt(0);
        compatibility += calculatePlanningCompatibility(userPlanning, partnerPlanning) * 0.3;
        
        // 2. 활동성 차원 (A/C) - 25% 가중치  
        char userActivity = userMBTI.charAt(1);
        char partnerActivity = partnerMBTI.charAt(1);
        compatibility += calculateActivityCompatibility(userActivity, partnerActivity) * 0.25;
        
        // 3. 사교성 차원 (I/G) - 25% 가중치
        char userSocial = userMBTI.charAt(2);
        char partnerSocial = partnerMBTI.charAt(2);
        compatibility += calculateSocialCompatibility(userSocial, partnerSocial) * 0.25;
        
        // 4. 예산 차원 (B/L) - 20% 가중치
        char userBudget = userMBTI.charAt(3);
        char partnerBudget = partnerMBTI.charAt(3);
        compatibility += calculateBudgetCompatibility(userBudget, partnerBudget) * 0.2;
        
        return Math.max(0.0, Math.min(1.0, compatibility));
    }

    /**
     * 계획성 차원 호환성 계산
     * P(계획형) vs J(즉흥형)
     */
    private double calculatePlanningCompatibility(char user, char partner) {
        if (user == partner) {
            // 같은 계획성 유형 - 높은 호환성
            return 0.9;
        } else {
            // 다른 계획성 유형 - 보완적 관계로 중간 호환성
            return 0.7;
        }
    }

    /**
     * 활동성 차원 호환성 계산  
     * A(액티브형) vs C(차분형)
     */
    private double calculateActivityCompatibility(char user, char partner) {
        if (user == 'A' && partner == 'A') {
            // 둘 다 액티브 - 매우 높은 에너지 시너지
            return 0.95;
        } else if (user == 'C' && partner == 'C') {
            // 둘 다 차분 - 편안한 여행 가능
            return 0.85;
        } else {
            // 액티브 + 차분 - 균형잡힌 조합
            return 0.8;
        }
    }

    /**
     * 사교성 차원 호환성 계산
     * I(독립형) vs G(그룹형) 
     */
    private double calculateSocialCompatibility(char user, char partner) {
        if (user == 'G' && partner == 'G') {
            // 둘 다 그룹형 - 사교적 여행 선호
            return 0.9;
        } else if (user == 'I' && partner == 'I') {
            // 둘 다 독립형 - 개인 공간 존중
            return 0.85;
        } else {
            // 독립형 + 그룹형 - 적절한 균형
            return 0.75;
        }
    }

    /**
     * 예산 차원 호환성 계산
     * B(실속형) vs L(럭셔리형)
     */
    private double calculateBudgetCompatibility(char user, char partner) {
        if (user == partner) {
            // 같은 예산 성향 - 높은 호환성
            return 0.9;
        } else {
            // 다른 예산 성향 - 타협 필요로 중간 호환성
            return 0.6;
        }
    }

    /**
     * 특정 여행 스타일에 따른 MBTI 점수 보정
     */
    public double calculateStyleAdjustedScore(String userMBTI, String partnerMBTI, String travelStyle) {
        double baseScore = calculateMBTIScore(userMBTI, partnerMBTI);
        
        if (travelStyle == null) {
            return baseScore;
        }
        
        double adjustment = 0.0;
        
        switch (travelStyle.toLowerCase()) {
            case "모험":
            case "액티비티":
                // 모험형 여행은 A(액티브) 성향이 유리
                if (userMBTI.charAt(1) == 'A' && partnerMBTI.charAt(1) == 'A') {
                    adjustment += 0.1;
                }
                break;
                
            case "휴양":
            case "힐링":
                // 힐링 여행은 C(차분) 성향이 유리
                if (userMBTI.charAt(1) == 'C' || partnerMBTI.charAt(1) == 'C') {
                    adjustment += 0.1;
                }
                break;
                
            case "문화":
            case "관광":
                // 문화 여행은 계획형 P가 유리
                if (userMBTI.charAt(0) == 'P' || partnerMBTI.charAt(0) == 'P') {
                    adjustment += 0.1;
                }
                break;
                
            case "배낭여행":
            case "자유여행":
                // 자유여행은 즉흥형 J가 유리
                if (userMBTI.charAt(0) == 'J' || partnerMBTI.charAt(0) == 'J') {
                    adjustment += 0.1;
                }
                break;
        }
        
        return Math.max(0.0, Math.min(1.0, baseScore + adjustment));
    }

    /**
     * MBTI 궁합에 따른 여행 스타일 추천
     */
    public String getRecommendedTravelStyle(String userMBTI, String partnerMBTI) {
        if (userMBTI == null || partnerMBTI == null || 
            userMBTI.length() != 4 || partnerMBTI.length() != 4) {
            return "일반적인 관광";
        }
        
        char userActivity = userMBTI.charAt(1);
        char partnerActivity = partnerMBTI.charAt(1);
        char userPlanning = userMBTI.charAt(0);
        char partnerPlanning = partnerMBTI.charAt(0);
        char userSocial = userMBTI.charAt(2);
        char partnerSocial = partnerMBTI.charAt(2);
        
        // 활동성 기준 추천
        if (userActivity == 'A' && partnerActivity == 'A') {
            return "액티비티 중심의 모험 여행";
        } else if (userActivity == 'C' && partnerActivity == 'C') {
            return "여유로운 힐링 여행";
        }
        
        // 계획성 기준 추천
        if (userPlanning == 'P' && partnerPlanning == 'P') {
            return "체계적인 문화 탐방";
        } else if (userPlanning == 'J' && partnerPlanning == 'J') {
            return "자유로운 배낭 여행";
        }
        
        // 사교성 기준 추천
        if (userSocial == 'G' && partnerSocial == 'G') {
            return "현지인과 교류하는 체험 여행";
        } else if (userSocial == 'I' && partnerSocial == 'I') {
            return "조용한 자연 탐방";
        }
        
        return "균형잡힌 종합 여행";
    }

    /**
     * MBTI 궁합 상세 설명 생성
     */
    public String generateCompatibilityDescription(String userMBTI, String partnerMBTI) {
        double score = calculateMBTIScore(userMBTI, partnerMBTI);
        
        StringBuilder description = new StringBuilder();
        
        if (score >= 0.8) {
            description.append("✨ 환상적인 궁합! ");
        } else if (score >= 0.6) {
            description.append("👍 좋은 궁합! ");
        } else if (score >= 0.4) {
            description.append("⚖️ 균형잡힌 관계 ");
        } else {
            description.append("🤝 서로 배우는 관계 ");
        }
        
        // 차원별 분석
        if (userMBTI != null && partnerMBTI != null && 
            userMBTI.length() == 4 && partnerMBTI.length() == 4) {
            
            char userPlanning = userMBTI.charAt(0);
            char partnerPlanning = partnerMBTI.charAt(0);
            
            if (userPlanning == partnerPlanning) {
                if (userPlanning == 'P') {
                    description.append("체계적인 계획으로 안정적인 여행이 가능합니다. ");
                } else {
                    description.append("즉흥적인 재미로 역동적인 여행이 될 거예요. ");
                }
            } else {
                description.append("계획과 즉흥의 완벽한 균형을 이룰 수 있어요. ");
            }
            
            char userActivity = userMBTI.charAt(1);
            char partnerActivity = partnerMBTI.charAt(1);
            
            if (userActivity == 'A' && partnerActivity == 'A') {
                description.append("둘 다 활발해서 다양한 액티비티를 즐길 수 있습니다.");
            } else if (userActivity == 'C' && partnerActivity == 'C') {
                description.append("편안한 페이스로 힐링 여행을 만끽하세요.");
            } else {
                description.append("활동적인 재미와 여유로운 휴식의 균형이 완벽해요.");
            }
        }
        
        return description.toString();
    }

    /**
     * MBTI 호환성 매트릭스 초기화
     */
    private static Map<String, Map<String, Double>> initializeMatrix() {
        Map<String, Map<String, Double>> matrix = new HashMap<>();
        
        // 모든 여행 MBTI 타입 (4차원: P/J, A/C, I/G, B/L)
        String[] mbtiTypes = {
            "PAIB", "PAIB", "PAGL", "PAGB", "PCIB", "PCIL", "PCGL", "PCGB",
            "JAIB", "JAIL", "JAGL", "JAGB", "JCIB", "JCIL", "JCGL", "JCGB"
        };
        
        // 실제 타입들로 다시 정의
        String[] actualTypes = {
            "PAIB", "PAIL", "PAGL", "PAGB", 
            "PCIB", "PCIL", "PCGL", "PCGB",
            "JAIB", "JAIL", "JAGL", "JAGB", 
            "JCIB", "JCIL", "JCGL", "JCGB"
        };
        
        for (String type1 : actualTypes) {
            Map<String, Double> compatibility = new HashMap<>();
            
            for (String type2 : actualTypes) {
                // 기본 호환성 계산 (차원별 분석 기반)
                double score = calculateBaseCompatibility(type1, type2);
                compatibility.put(type2, score);
            }
            
            matrix.put(type1, compatibility);
        }
        
        return matrix;
    }

    /**
     * 기본 호환성 점수 계산 (매트릭스 초기화용) - 더 다양한 점수 범위
     */
    private static double calculateBaseCompatibility(String mbti1, String mbti2) {
        if (mbti1.length() != 4 || mbti2.length() != 4) {
            return 0.5;
        }
        
        double score = 0.0;
        char planning1 = mbti1.charAt(0), planning2 = mbti2.charAt(0);
        char activity1 = mbti1.charAt(1), activity2 = mbti2.charAt(1);
        char social1 = mbti1.charAt(2), social2 = mbti2.charAt(2);
        char budget1 = mbti1.charAt(3), budget2 = mbti2.charAt(3);
        
        // 1. 계획성 호환성 (0.1 ~ 0.3)
        if (planning1 == planning2) {
            score += 0.25; // 같은 계획성 - 안정적
        } else {
            score += 0.3; // 다른 계획성 - 보완적 (더 높은 점수)
        }
        
        // 2. 활동성 호환성 (0.1 ~ 0.35)  
        if (activity1 == 'A' && activity2 == 'A') {
            score += 0.35; // AA - 최고 시너지
        } else if (activity1 == 'C' && activity2 == 'C') {
            score += 0.2; // CC - 안정적이지만 조금 심심할 수 있음
        } else {
            score += 0.25; // AC/CA - 균형잡힌 조합
        }
        
        // 3. 사교성 호환성 (0.05 ~ 0.25)
        if (social1 == social2) {
            score += (social1 == 'G') ? 0.25 : 0.2; // 그룹형이 더 호환성 좋음
        } else {
            score += 0.1; // 다른 사교성 - 갈등 가능성
        }
        
        // 4. 예산 호환성 (0.05 ~ 0.2)
        if (budget1 == budget2) {
            score += 0.2; // 같은 예산 수준 - 중요함
        } else {
            score += 0.05; // 다른 예산 - 큰 갈등 요소
        }
        
        // 5. 특별한 조합별 점수 조정
        String combination = mbti1 + "-" + mbti2;
        
        // 완벽한 조합들 (보너스 +0.1)
        if (isIdealCombination(mbti1, mbti2)) {
            score += 0.1;
        }
        
        // 도전적인 조합들 (페널티 -0.15)
        if (isChallengingCombination(mbti1, mbti2)) {
            score -= 0.15;
        }
        
        // 평범한 조합들 (조정 없음)
        
        return Math.max(0.3, Math.min(1.0, score)); // 최소 30%, 최대 100%
    }
    
    /**
     * 완벽한 조합 판별 (높은 호환성)
     */
    private static boolean isIdealCombination(String mbti1, String mbti2) {
        // 계획형 + 즉흥형, 같은 활동성, 같은 예산
        char p1 = mbti1.charAt(0), p2 = mbti2.charAt(0);
        char a1 = mbti1.charAt(1), a2 = mbti2.charAt(1);
        char b1 = mbti1.charAt(3), b2 = mbti2.charAt(3);
        
        return (p1 != p2) && (a1 == a2) && (b1 == b2);
    }
    
    /**
     * 도전적인 조합 판별 (낮은 호환성)
     */
    private static boolean isChallengingCombination(String mbti1, String mbti2) {
        char a1 = mbti1.charAt(1), a2 = mbti2.charAt(1);
        char s1 = mbti1.charAt(2), s2 = mbti2.charAt(2);
        char b1 = mbti1.charAt(3), b2 = mbti2.charAt(3);
        
        // 활동성 다름 + 사교성 다름 + 예산 다름 = 어려운 조합
        return (a1 != a2) && (s1 != s2) && (b1 != b2);
    }

    /**
     * MBTI 타입 유효성 검사
     */
    public boolean isValidMBTI(String mbti) {
        if (mbti == null || mbti.length() != 4) {
            return false;
        }
        
        char planning = mbti.charAt(0);
        char activity = mbti.charAt(1);
        char social = mbti.charAt(2);
        char budget = mbti.charAt(3);
        
        return (planning == 'P' || planning == 'J') &&
               (activity == 'A' || activity == 'C') &&
               (social == 'I' || social == 'G') &&
               (budget == 'B' || budget == 'L');
    }

    /**
     * MBTI 타입 설명 반환
     */
    public String getMBTIDescription(String mbti) {
        if (!isValidMBTI(mbti)) {
            return "알 수 없는 MBTI 타입";
        }
        
        StringBuilder desc = new StringBuilder();
        
        // 계획성
        if (mbti.charAt(0) == 'P') {
            desc.append("체계적 계획형 ");
        } else {
            desc.append("자유로운 즉흥형 ");
        }
        
        // 활동성  
        if (mbti.charAt(1) == 'A') {
            desc.append("+ 활발한 액티브형 ");
        } else {
            desc.append("+ 여유로운 차분형 ");
        }
        
        // 사교성
        if (mbti.charAt(2) == 'I') {
            desc.append("+ 독립적 개인형 ");
        } else {
            desc.append("+ 사교적 그룹형 ");
        }
        
        // 예산
        if (mbti.charAt(3) == 'B') {
            desc.append("+ 실속있는 가성비형");
        } else {
            desc.append("+ 품격있는 럭셔리형");
        }
        
        return desc.toString();
    }
}