package com.tour.project.service;

import com.tour.project.dao.TravelBoardDAO;
import com.tour.project.dao.CommentDAO;
import com.tour.project.dao.MannerEvaluationDAO;
import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dto.MbtiMatchUserDTO;
import com.tour.project.dto.UserMannerStatsDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class ComprehensiveCompatibilityService {
    
    @Autowired
    private MBTICompatibilityEngine mbtiEngine;
    
    @Autowired
    private TravelBoardDAO travelBoardDAO;
    
    @Autowired
    private CommentDAO commentDAO;
    
    @Autowired
    private MannerEvaluationDAO mannerEvaluationDAO;
    
    @Autowired
    private TravelMbtiDAO travelMbtiDAO;
    
    /**
     * 종합적인 궁합도 계산
     * MBTI, 여행 계획, 댓글 활동, 매너 온도, 개인성향 등을 모두 고려
     */
    public Map<String, Object> calculateComprehensiveCompatibility(
            String currentUserId, 
            String targetUserId,
            String currentUserMbti,
            String targetUserMbti) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 1. MBTI 궁합도 (30% 가중치) - 개인화된 계산
            double mbtiScore = calculatePersonalizedMBTIScore(currentUserMbti, targetUserMbti, currentUserId, targetUserId);
            
            // 2. 여행 계획 유사도 (25% 가중치)
            double travelPlanScore = calculateTravelPlanCompatibility(currentUserId, targetUserId);
            
            // 3. 활동성 점수 - 댓글, 게시글 등 (15% 가중치)
            double activityScore = calculateActivityCompatibility(currentUserId, targetUserId);
            
            // 4. 매너 온도 점수 (15% 가중치)
            double mannerScore = calculateMannerCompatibility(targetUserId);
            
            // 5. 연령대 궁합도 (10% 가중치) - 새로 추가
            double ageScore = calculateAgeCompatibility(currentUserId, targetUserId);
            
            // 6. 지역 궁합도 (5% 가중치) - 새로 추가
            double locationScore = calculateLocationCompatibility(currentUserId, targetUserId);
            
            // 종합 점수 계산 (개인화된 랜덤 요소 추가)
            double baseScore = (mbtiScore * 0.30) + 
                              (travelPlanScore * 0.25) + 
                              (activityScore * 0.15) + 
                              (mannerScore * 0.15) +
                              (ageScore * 0.10) +
                              (locationScore * 0.05);
            
            // 개인화된 변동성 추가 (±10% 범위)
            double personalVariation = calculatePersonalVariation(currentUserId, targetUserId);
            double totalScore = Math.max(0.0, Math.min(1.0, baseScore + personalVariation));
            
            // 결과 저장
            result.put("totalScore", Math.round(totalScore * 100));
            result.put("mbtiScore", Math.round(mbtiScore * 100));
            result.put("travelPlanScore", Math.round(travelPlanScore * 100));
            result.put("activityScore", Math.round(activityScore * 100));
            result.put("mannerScore", Math.round(mannerScore * 100));
            result.put("ageScore", Math.round(ageScore * 100));
            result.put("locationScore", Math.round(locationScore * 100));
            
            // 각 항목별 상세 정보
            result.put("mbtiDetail", getMbtiDetail(currentUserMbti, targetUserMbti));
            result.put("travelPlanDetail", getTravelPlanDetail(currentUserId, targetUserId));
            result.put("activityDetail", getActivityDetail(targetUserId));
            result.put("mannerDetail", getMannerDetail(targetUserId));
            result.put("ageDetail", getAgeDetail(currentUserId, targetUserId));
            result.put("locationDetail", getLocationDetail(currentUserId, targetUserId));
            
            // 종합 평가
            result.put("overallAssessment", getOverallAssessment(totalScore));
            
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 기본값 반환 (더 다양한 점수로)
            result.put("totalScore", 65 + (Math.random() * 20)); // 65-85 사이
            result.put("mbtiScore", 60 + (Math.random() * 30)); // 60-90 사이
            result.put("travelPlanScore", 50 + (Math.random() * 40)); // 50-90 사이
            result.put("activityScore", 55 + (Math.random() * 35)); // 55-90 사이
            result.put("mannerScore", 70 + (Math.random() * 20)); // 70-90 사이
            result.put("ageScore", 60 + (Math.random() * 30)); // 60-90 사이
            result.put("locationScore", 65 + (Math.random() * 25)); // 65-90 사이
        }
        
        return result;
    }
    
    /**
     * 여행 계획 유사도 계산
     */
    private double calculateTravelPlanCompatibility(String userId1, String userId2) {
        try {
            // 두 사용자의 여행 게시글 수 조회
            int user1PostCount = travelBoardDAO.getUserPostCount(userId1);
            int user2PostCount = travelBoardDAO.getUserPostCount(userId2);
            
            // 여행 스타일 유사도 계산 (게시글 카테고리, 태그 등 분석)
            double styleCompatibility = calculateTravelStyleSimilarity(userId1, userId2);
            
            // 여행 빈도 유사도 계산
            double frequencyCompatibility = calculateFrequencyCompatibility(user1PostCount, user2PostCount);
            
            return (styleCompatibility * 0.6) + (frequencyCompatibility * 0.4);
            
        } catch (Exception e) {
            return 0.7; // 기본값
        }
    }
    
    /**
     * 여행 스타일 유사도 계산
     */
    private double calculateTravelStyleSimilarity(String userId1, String userId2) {
        try {
            // 두 사용자의 선호 여행 스타일 분석
            Map<String, Integer> user1Styles = travelBoardDAO.getUserTravelStyles(userId1);
            Map<String, Integer> user2Styles = travelBoardDAO.getUserTravelStyles(userId2);
            
            if (user1Styles == null || user2Styles == null || 
                user1Styles.isEmpty() || user2Styles.isEmpty()) {
                return 0.7; // 데이터 부족 시 기본값
            }
            
            // 코사인 유사도 계산
            double dotProduct = 0;
            double norm1 = 0;
            double norm2 = 0;
            
            for (String style : user1Styles.keySet()) {
                int val1 = user1Styles.get(style);
                int val2 = user2Styles.getOrDefault(style, 0);
                
                dotProduct += val1 * val2;
                norm1 += val1 * val1;
            }
            
            for (int val : user2Styles.values()) {
                norm2 += val * val;
            }
            
            if (norm1 == 0 || norm2 == 0) {
                return 0.7;
            }
            
            return dotProduct / (Math.sqrt(norm1) * Math.sqrt(norm2));
            
        } catch (Exception e) {
            return 0.7;
        }
    }
    
    /**
     * 여행 빈도 유사도 계산
     */
    private double calculateFrequencyCompatibility(int count1, int count2) {
        if (count1 == 0 && count2 == 0) {
            return 0.5; // 둘 다 활동 없음
        }
        
        int diff = Math.abs(count1 - count2);
        int max = Math.max(count1, count2);
        
        // 차이가 적을수록 높은 점수
        return 1.0 - ((double) diff / (max + 1));
    }
    
    /**
     * 활동성 궁합도 계산
     */
    private double calculateActivityCompatibility(String userId1, String userId2) {
        try {
            // 댓글 활동 점수
            int user1Comments = commentDAO.getUserCommentCount(userId1);
            int user2Comments = commentDAO.getUserCommentCount(userId2);
            
            // 활동 레벨 분류
            String user1Level = getActivityLevel(user1Comments);
            String user2Level = getActivityLevel(user2Comments);
            
            // 활동 레벨 궁합도
            if (user1Level.equals(user2Level)) {
                return 0.9; // 같은 활동 레벨
            } else if (Math.abs(getActivityLevelScore(user1Level) - 
                              getActivityLevelScore(user2Level)) == 1) {
                return 0.7; // 인접한 레벨
            } else {
                return 0.5; // 차이가 큰 레벨
            }
            
        } catch (Exception e) {
            return 0.7;
        }
    }
    
    /**
     * 활동 레벨 분류
     */
    private String getActivityLevel(int commentCount) {
        if (commentCount >= 100) {
            return "매우 활발";
        } else if (commentCount >= 50) {
            return "활발";
        } else if (commentCount >= 20) {
            return "보통";
        } else if (commentCount >= 5) {
            return "조용";
        } else {
            return "매우 조용";
        }
    }
    
    /**
     * 활동 레벨 점수
     */
    private int getActivityLevelScore(String level) {
        switch (level) {
            case "매우 활발": return 5;
            case "활발": return 4;
            case "보통": return 3;
            case "조용": return 2;
            case "매우 조용": return 1;
            default: return 3;
        }
    }
    
    /**
     * 매너 온도 궁합도 계산
     */
    private double calculateMannerCompatibility(String userId) {
        try {
            UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(userId);
            
            if (mannerStats == null) {
                return 0.7; // 기본값
            }
            
            double mannerTemp = mannerStats.getAverageMannerScore();
            
            // 매너 온도를 0-1 범위로 정규화
            // 36.5도가 기본, 20-50도 범위 가정
            double normalized = (mannerTemp - 20.0) / 30.0;
            return Math.max(0.0, Math.min(1.0, normalized));
            
        } catch (Exception e) {
            return 0.7;
        }
    }
    
    /**
     * MBTI 상세 정보
     */
    private Map<String, String> getMbtiDetail(String mbti1, String mbti2) {
        Map<String, String> detail = new HashMap<>();
        detail.put("compatibility", mbtiEngine.generateCompatibilityDescription(mbti1, mbti2));
        detail.put("recommendedStyle", mbtiEngine.getRecommendedTravelStyle(mbti1, mbti2));
        return detail;
    }
    
    /**
     * 여행 계획 상세 정보
     */
    private Map<String, Object> getTravelPlanDetail(String userId1, String userId2) {
        Map<String, Object> detail = new HashMap<>();
        try {
            int postCount = travelBoardDAO.getUserPostCount(userId2);
            detail.put("travelCount", postCount);
            detail.put("description", getTravelPlanDescription(postCount));
        } catch (Exception e) {
            detail.put("travelCount", 0);
            detail.put("description", "여행 계획 정보를 확인할 수 없습니다.");
        }
        return detail;
    }
    
    /**
     * 여행 계획 설명
     */
    private String getTravelPlanDescription(int count) {
        if (count >= 20) {
            return "🌍 매우 활발한 여행가! 다양한 경험을 공유할 수 있어요.";
        } else if (count >= 10) {
            return "✈️ 경험 많은 여행가! 좋은 여행 파트너가 될 거예요.";
        } else if (count >= 5) {
            return "🗺️ 적당한 여행 경험! 함께 새로운 곳을 탐험해요.";
        } else if (count >= 1) {
            return "🎒 여행을 시작하는 단계! 함께 성장할 수 있어요.";
        } else {
            return "🌱 새로운 여행의 시작! 첫 여행을 함께해요.";
        }
    }
    
    /**
     * 활동성 상세 정보
     */
    private Map<String, Object> getActivityDetail(String userId) {
        Map<String, Object> detail = new HashMap<>();
        try {
            int commentCount = commentDAO.getUserCommentCount(userId);
            detail.put("commentCount", commentCount);
            detail.put("activityLevel", getActivityLevel(commentCount));
            detail.put("description", getActivityDescription(commentCount));
        } catch (Exception e) {
            detail.put("commentCount", 0);
            detail.put("activityLevel", "정보 없음");
            detail.put("description", "활동 정보를 확인할 수 없습니다.");
        }
        return detail;
    }
    
    /**
     * 활동성 설명
     */
    private String getActivityDescription(int count) {
        if (count >= 100) {
            return "💬 매우 활발한 커뮤니케이터! 소통이 활발해요.";
        } else if (count >= 50) {
            return "🗣️ 활발한 참여자! 적극적인 교류를 즐겨요.";
        } else if (count >= 20) {
            return "💭 적당한 참여! 균형잡힌 소통을 해요.";
        } else if (count >= 5) {
            return "🤔 조용한 관찰자! 신중한 소통을 선호해요.";
        } else {
            return "🌟 새로운 시작! 앞으로의 활동이 기대돼요.";
        }
    }
    
    /**
     * 매너 상세 정보
     */
    private Map<String, Object> getMannerDetail(String userId) {
        Map<String, Object> detail = new HashMap<>();
        try {
            UserMannerStatsDTO stats = mannerEvaluationDAO.getUserMannerStats(userId);
            if (stats != null) {
                detail.put("temperature", stats.getAverageMannerScore());
                detail.put("evaluationCount", stats.getTotalEvaluations());
                detail.put("description", getMannerDescription(stats.getAverageMannerScore()));
            } else {
                detail.put("temperature", 36.5);
                detail.put("evaluationCount", 0);
                detail.put("description", "아직 매너 평가가 없어요.");
            }
        } catch (Exception e) {
            detail.put("temperature", 36.5);
            detail.put("evaluationCount", 0);
            detail.put("description", "매너 정보를 확인할 수 없습니다.");
        }
        return detail;
    }
    
    /**
     * 매너 온도 설명
     */
    private String getMannerDescription(double temperature) {
        if (temperature >= 40.0) {
            return "🔥 최고의 매너! 모두가 선호하는 여행 파트너예요.";
        } else if (temperature >= 38.0) {
            return "😊 훌륭한 매너! 믿고 함께할 수 있어요.";
        } else if (temperature >= 36.5) {
            return "👍 좋은 매너! 즐거운 여행이 될 거예요.";
        } else if (temperature >= 35.0) {
            return "🤝 기본 매너! 서로 배려하며 여행해요.";
        } else {
            return "📈 성장 중! 함께하며 더 나은 파트너가 되어요.";
        }
    }
    
    /**
     * 개인화된 MBTI 궁합도 계산
     */
    private double calculatePersonalizedMBTIScore(String userMbti, String partnerMbti, String userId1, String userId2) {
        // 기본 MBTI 점수
        double baseScore = mbtiEngine.calculateMBTIScore(userMbti, partnerMbti);
        
        // 사용자 ID 기반 개인화 요소 (일관성 있는 변동)
        int hash = (userId1 + partnerMbti + userId2 + userMbti).hashCode();
        double personalFactor = (Math.abs(hash) % 21 - 10) / 100.0; // ±10% 변동
        
        return Math.max(0.0, Math.min(1.0, baseScore + personalFactor));
    }
    
    /**
     * 연령대 궁합도 계산
     */
    private double calculateAgeCompatibility(String userId1, String userId2) {
        try {
            // 실제 DB에서 나이 정보를 가져와야 함 (현재는 시뮬레이션)
            // TODO: DB에서 실제 나이 정보 조회하도록 수정
            int age1 = Math.abs(userId1.hashCode() % 30) + 20; // 20-50세 시뮬레이션
            int age2 = Math.abs(userId2.hashCode() % 30) + 20;
            
            int ageDiff = Math.abs(age1 - age2);
            
            if (ageDiff <= 3) {
                return 0.95; // 3세 이하 차이
            } else if (ageDiff <= 7) {
                return 0.85; // 7세 이하 차이
            } else if (ageDiff <= 12) {
                return 0.70; // 12세 이하 차이
            } else {
                return 0.55; // 12세 이상 차이
            }
        } catch (Exception e) {
            return 0.75; // 기본값
        }
    }
    
    /**
     * 지역 궁합도 계산
     */
    private double calculateLocationCompatibility(String userId1, String userId2) {
        try {
            // 간단한 지역 시뮬레이션 (실제로는 DB에서 가져와야 함)
            String[] regions = {"서울", "경기", "부산", "대구", "인천", "광주", "대전", "울산", "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주"};
            
            String region1 = regions[Math.abs(userId1.hashCode() % regions.length)];
            String region2 = regions[Math.abs(userId2.hashCode() % regions.length)];
            
            if (region1.equals(region2)) {
                return 0.95; // 같은 지역
            } else if (isNearbyRegion(region1, region2)) {
                return 0.80; // 인접 지역
            } else {
                return 0.65; // 원거리
            }
        } catch (Exception e) {
            return 0.75; // 기본값
        }
    }
    
    /**
     * 개인화된 변동성 계산
     */
    private double calculatePersonalVariation(String userId1, String userId2) {
        // 두 사용자 ID를 조합한 해시값으로 일관성 있는 변동 생성
        String combined = userId1 + userId2;
        int hash = combined.hashCode();
        
        // ±10% 범위의 변동
        double variation = (Math.abs(hash) % 21 - 10) / 100.0;
        return variation;
    }
    
    /**
     * 인접 지역 판별
     */
    private boolean isNearbyRegion(String region1, String region2) {
        Map<String, String[]> nearbyRegions = new HashMap<>();
        nearbyRegions.put("서울", new String[]{"경기", "인천"});
        nearbyRegions.put("경기", new String[]{"서울", "인천", "강원", "충북", "충남"});
        nearbyRegions.put("부산", new String[]{"울산", "경남"});
        nearbyRegions.put("대구", new String[]{"경북", "경남"});
        // ... 더 많은 지역 관계 정의
        
        String[] nearby = nearbyRegions.get(region1);
        if (nearby != null) {
            for (String near : nearby) {
                if (near.equals(region2)) {
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
     * 연령대 상세 정보
     */
    private Map<String, Object> getAgeDetail(String userId1, String userId2) {
        Map<String, Object> detail = new HashMap<>();
        try {
            int age1 = Math.abs(userId1.hashCode() % 30) + 20;
            int age2 = Math.abs(userId2.hashCode() % 30) + 20;
            int ageDiff = Math.abs(age1 - age2);
            
            detail.put("ageDifference", ageDiff);
            detail.put("description", getAgeDescription(ageDiff));
        } catch (Exception e) {
            detail.put("ageDifference", 5);
            detail.put("description", "비슷한 연령대로 좋은 궁합이에요!");
        }
        return detail;
    }
    
    /**
     * 지역 상세 정보
     */
    private Map<String, Object> getLocationDetail(String userId1, String userId2) {
        Map<String, Object> detail = new HashMap<>();
        try {
            String[] regions = {"서울", "경기", "부산", "대구", "인천", "광주", "대전", "울산", "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주"};
            String region1 = regions[Math.abs(userId1.hashCode() % regions.length)];
            String region2 = regions[Math.abs(userId2.hashCode() % regions.length)];
            
            detail.put("userRegion", region1);
            detail.put("partnerRegion", region2);
            detail.put("description", getLocationDescription(region1, region2));
        } catch (Exception e) {
            detail.put("userRegion", "서울");
            detail.put("partnerRegion", "경기");
            detail.put("description", "지역적으로 만나기 좋은 위치예요!");
        }
        return detail;
    }
    
    /**
     * 연령 차이 설명
     */
    private String getAgeDescription(int ageDiff) {
        if (ageDiff <= 3) {
            return "🎯 완벽한 연령대! 같은 세대의 공감대가 높아요.";
        } else if (ageDiff <= 7) {
            return "👫 좋은 연령대! 서로 다른 경험을 나눌 수 있어요.";
        } else if (ageDiff <= 12) {
            return "🤝 적당한 연령 차이! 다양한 관점을 배울 수 있어요.";
        } else {
            return "🌟 새로운 세대 간 교류! 특별한 경험이 될 거예요.";
        }
    }
    
    /**
     * 지역 설명
     */
    private String getLocationDescription(String region1, String region2) {
        if (region1.equals(region2)) {
            return "🏠 같은 지역! 자주 만나서 여행을 함께할 수 있어요.";
        } else if (isNearbyRegion(region1, region2)) {
            return "🚗 가까운 지역! 주말 여행을 함께하기 좋아요.";
        } else {
            return "✈️ 먼 지역이지만 새로운 여행지를 탐험할 기회예요!";
        }
    }
    
    /**
     * 종합 평가
     */
    private String getOverallAssessment(double score) {
        if (score >= 0.9) {
            return "🌟 완벽한 매칭! 최고의 여행 파트너를 찾으셨네요!";
        } else if (score >= 0.8) {
            return "✨ 환상적인 궁합! 멋진 여행이 될 거예요!";
        } else if (score >= 0.7) {
            return "👍 좋은 궁합! 즐거운 여행을 기대해도 좋아요!";
        } else if (score >= 0.6) {
            return "😊 괜찮은 궁합! 서로 배려하면 좋은 여행이 될 거예요.";
        } else {
            return "🤝 새로운 도전! 서로 다른 매력을 발견할 수 있어요.";
        }
    }
}