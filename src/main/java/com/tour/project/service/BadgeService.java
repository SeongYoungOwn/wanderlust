package com.tour.project.service;

import com.tour.project.dao.BadgeDAO;
import com.tour.project.dao.BoardDAO;
import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.MannerEvaluationDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dao.AttendanceDAO;
import com.tour.project.dto.BadgeDTO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.UserMannerStatsDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
public class BadgeService {

    @Autowired
    private BadgeDAO badgeDAO;
    
    @Autowired
    private BoardDAO boardDAO;
    
    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private MannerEvaluationDAO mannerEvaluationDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private AttendanceDAO attendanceDAO;

    /**
     * 사용자의 활동을 체크하고 해당하는 뱃지를 자동으로 부여
     */
    @Transactional
    public void checkAndAwardBadges(String userId) {
        try {
            MemberDTO member = memberDAO.getMemberById(userId);
            if (member == null) return;

            // 1. 첫 여행 뱃지 (여행 계획 1개 이상)
            checkFirstTravelBadge(userId);

            // 2. 여행 마스터 뱃지 (완료된 여행 10회 이상)
            checkTravelMasterBadge(userId);

            // 3. 활발한 작성자 뱃지 (게시글 50개 이상)
            checkActiveWriterBadge(userId);

            // 4. 매너 천사 뱃지 (매너온도 40도 이상)
            checkMannerAngelBadge(userId);

            // 5. 얼리버드 뱃지 (가입일 기준으로 초기 가입자)
            checkEarlyBirdBadge(userId, member);
            
            // 6. 출석 관련 뱃지들
            checkAttendanceBadges(userId);
            
            // 7. 향상된 커뮤니티 뱃지들
            checkEnhancedCommunityBadges(userId);

        } catch (Exception e) {
            System.err.println("뱃지 체크 중 오류 발생: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void checkFirstTravelBadge(String userId) {
        try {
            int travelCount = travelPlanDAO.countUserTravelPlans(userId);
            if (travelCount >= 1) {
                awardBadgeIfNotExists(userId, 1); // 첫 여행 뱃지 ID: 1
            }
        } catch (Exception e) {
            System.err.println("첫 여행 뱃지 체크 오류: " + e.getMessage());
        }
    }

    private void checkTravelMasterBadge(String userId) {
        try {
            int completedTravelCount = travelPlanDAO.countUserCompletedTravels(userId);
            if (completedTravelCount >= 10) {
                awardBadgeIfNotExists(userId, 2); // 여행 마스터 뱃지 ID: 2
            }
        } catch (Exception e) {
            System.err.println("여행 마스터 뱃지 체크 오류: " + e.getMessage());
        }
    }

    private void checkActiveWriterBadge(String userId) {
        try {
            int postCount = boardDAO.countUserPosts(userId);
            if (postCount >= 50) {
                awardBadgeIfNotExists(userId, 6); // 활발한 작성자 뱃지 ID: 6
            }
        } catch (Exception e) {
            System.err.println("활발한 작성자 뱃지 체크 오류: " + e.getMessage());
        }
    }

    private void checkMannerAngelBadge(String userId) {
        try {
            UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(userId);
            if (mannerStats != null && mannerStats.getAverageMannerScore() >= 40.0) {
                awardBadgeIfNotExists(userId, 4); // 매너 천사 뱃지 ID: 4
            }
        } catch (Exception e) {
            System.err.println("매너 천사 뱃지 체크 오류: " + e.getMessage());
        }
    }

    private void checkEarlyBirdBadge(String userId, MemberDTO member) {
        try {
            // 2025년 8월 이전 가입자를 얼리버드로 간주
            if (member.getUserRegdate() != null) {
                java.sql.Timestamp earlyBirdCutoff = java.sql.Timestamp.valueOf("2025-08-01 00:00:00");
                if (member.getUserRegdate().before(earlyBirdCutoff)) {
                    awardBadgeIfNotExists(userId, 8); // 얼리버드 뱃지 ID: 8
                }
            }
        } catch (Exception e) {
            System.err.println("얼리버드 뱃지 체크 오류: " + e.getMessage());
        }
    }

    /**
     * 뱃지가 없는 경우에만 부여
     */
    private void awardBadgeIfNotExists(String userId, int badgeId) {
        try {
            if (!badgeDAO.hasUserBadge(userId, badgeId)) {
                badgeDAO.awardBadge(userId, badgeId);
                System.out.println("사용자 " + userId + "에게 뱃지 " + badgeId + " 부여됨");
            }
        } catch (Exception e) {
            System.err.println("뱃지 부여 오류 (userId: " + userId + ", badgeId: " + badgeId + "): " + e.getMessage());
        }
    }

    /**
     * 특정 뱃지를 수동으로 부여
     */
    @Transactional
    public boolean awardBadge(String userId, int badgeId) {
        try {
            if (!badgeDAO.hasUserBadge(userId, badgeId)) {
                int result = badgeDAO.awardBadge(userId, badgeId);
                return result > 0;
            }
            return false; // 이미 보유한 뱃지
        } catch (Exception e) {
            System.err.println("수동 뱃지 부여 오류: " + e.getMessage());
            return false;
        }
    }

    /**
     * 사용자의 모든 뱃지 조회
     */
    public List<BadgeDTO> getUserBadges(String userId) {
        try {
            return badgeDAO.getUserBadges(userId);
        } catch (Exception e) {
            System.err.println("사용자 뱃지 조회 오류: " + e.getMessage());
            return null;
        }
    }

    /**
     * 모든 뱃지 조회
     */
    public List<BadgeDTO> getAllBadges() {
        try {
            return badgeDAO.getAllBadges();
        } catch (Exception e) {
            System.err.println("모든 뱃지 조회 오류: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * 출석 기록
     */
    @Transactional
    public void recordAttendance(String userId) {
        try {
            java.time.LocalDate today = java.time.LocalDate.now();
            if (!attendanceDAO.hasAttendanceToday(userId, today)) {
                attendanceDAO.recordAttendance(userId, today);
                // 출석 후 출석 관련 뱃지 체크
                checkAttendanceBadges(userId);
            }
        } catch (Exception e) {
            System.err.println("출석 기록 오류: " + e.getMessage());
        }
    }
    
    /**
     * 출석 관련 뱃지 체크
     */
    private void checkAttendanceBadges(String userId) {
        try {
            // 첫 출석 뱃지 (ID: 10)
            int totalAttendance = attendanceDAO.getTotalAttendanceDays(userId);
            if (totalAttendance >= 1) {
                awardBadgeIfNotExists(userId, 13); // 첫 출석
            }
            
            // 연속 출석 뱃지들
            int consecutiveDays = attendanceDAO.getConsecutiveAttendanceDays(userId);
            if (consecutiveDays >= 7) {
                awardBadgeIfNotExists(userId, 10); // 출석왕
            }
            if (consecutiveDays >= 100) {
                awardBadgeIfNotExists(userId, 15); // 플래티넘
            }
            if (consecutiveDays >= 365) {
                awardBadgeIfNotExists(userId, 16); // 킹
            }
            
            // 월간 출석 뱃지
            java.time.LocalDate now = java.time.LocalDate.now();
            int monthlyDays = attendanceDAO.getMonthlyAttendanceDays(userId, now.getYear(), now.getMonthValue());
            if (monthlyDays >= 20) {
                awardBadgeIfNotExists(userId, 11); // 꾸준함
            }
            if (monthlyDays >= 30) {
                awardBadgeIfNotExists(userId, 14); // 월간 마스터
            }
            
            // 연간 출석 뱃지
            int yearlyDays = attendanceDAO.getYearlyAttendanceDays(userId, now.getYear());
            if (yearlyDays >= 300) {
                awardBadgeIfNotExists(userId, 12); // 전설
            }
            
        } catch (Exception e) {
            System.err.println("출석 뱃지 체크 오류: " + e.getMessage());
        }
    }
    
    /**
     * 향상된 커뮤니티 뱃지 체크
     */
    private void checkEnhancedCommunityBadges(String userId) {
        try {
            // 소통왕 뱃지 - 댓글 100개 이상 (ID: 23)
            // 실제 CommentDAO에 댓글 수 조회 메서드가 있다면 사용
            // 현재는 기본 구조만 작성
            
            // 인기왕 뱃지 - 받은 좋아요 500개 이상 (ID: 24)
            // LikeDAO나 관련 DAO에서 좋아요 수 조회
            
            // 트렌드세터 뱃지 - 게시글 조회수 누적 10만 이상 (ID: 25)
            // BoardDAO에서 사용자의 총 조회수 조회
            
            // 도우미 뱃지 - 답변 30개 이상 (ID: 26)
            // 답변 관련 로직 구현
            
        } catch (Exception e) {
            System.err.println("향상된 커뮤니티 뱃지 체크 오류: " + e.getMessage());
        }
    }
    
    /**
     * 사용자의 뱃지 진행도 조회
     */
    public Map<String, Object> getBadgeProgress(String userId) {
        Map<String, Object> progress = new HashMap<>();
        
        try {
            // 출석 진행도
            int consecutiveDays = attendanceDAO.getConsecutiveAttendanceDays(userId);
            int totalDays = attendanceDAO.getTotalAttendanceDays(userId);
            
            progress.put("consecutiveAttendance", consecutiveDays);
            progress.put("totalAttendance", totalDays);
            progress.put("nextAttendanceBadge", getNextAttendanceBadge(consecutiveDays));
            
            // 여행 진행도
            int travelCount = travelPlanDAO.countUserTravelPlans(userId);
            int completedTravels = travelPlanDAO.countUserCompletedTravels(userId);
            
            progress.put("totalTravels", travelCount);
            progress.put("completedTravels", completedTravels);
            progress.put("nextTravelBadge", getNextTravelBadge(completedTravels));
            
            // 커뮤니티 진행도
            int postCount = boardDAO.countUserPosts(userId);
            progress.put("totalPosts", postCount);
            progress.put("nextCommunityBadge", getNextCommunityBadge(postCount));
            
        } catch (Exception e) {
            System.err.println("뱃지 진행도 조회 오류: " + e.getMessage());
        }
        
        return progress;
    }
    
    private Map<String, Object> getNextAttendanceBadge(int consecutiveDays) {
        Map<String, Object> next = new HashMap<>();
        if (consecutiveDays < 7) {
            next.put("badgeName", "출석왕");
            next.put("required", 7);
            next.put("current", consecutiveDays);
            next.put("remaining", 7 - consecutiveDays);
        } else if (consecutiveDays < 100) {
            next.put("badgeName", "플래티넘");
            next.put("required", 100);
            next.put("current", consecutiveDays);
            next.put("remaining", 100 - consecutiveDays);
        } else if (consecutiveDays < 365) {
            next.put("badgeName", "킹");
            next.put("required", 365);
            next.put("current", consecutiveDays);
            next.put("remaining", 365 - consecutiveDays);
        } else {
            next.put("badgeName", "최고 등급 달성!");
            next.put("completed", true);
        }
        return next;
    }
    
    private Map<String, Object> getNextTravelBadge(int completedTravels) {
        Map<String, Object> next = new HashMap<>();
        if (completedTravels < 10) {
            next.put("badgeName", "여행 마스터");
            next.put("required", 10);
            next.put("current", completedTravels);
            next.put("remaining", 10 - completedTravels);
        } else {
            next.put("badgeName", "여행 마스터 달성!");
            next.put("completed", true);
        }
        return next;
    }
    
    private Map<String, Object> getNextCommunityBadge(int postCount) {
        Map<String, Object> next = new HashMap<>();
        if (postCount < 50) {
            next.put("badgeName", "활발한 작성자");
            next.put("required", 50);
            next.put("current", postCount);
            next.put("remaining", 50 - postCount);
        } else {
            next.put("badgeName", "활발한 작성자 달성!");
            next.put("completed", true);
        }
        return next;
    }
}