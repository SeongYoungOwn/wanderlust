package com.tour.project.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tour.project.dao.GuideDAO;
import com.tour.project.vo.GuideVO;
import com.tour.project.vo.GuideApplicationVO;

@Service
public class GuideService {

    @Autowired
    private GuideDAO guideDAO;

    // 가이드 신청 등록
    public int insertGuideApplication(GuideApplicationVO application) {
        return guideDAO.insertGuideApplication(application);
    }

    // 사용자의 가이드 신청 상태 확인
    public GuideApplicationVO getApplicationByUserId(String userId) {
        return guideDAO.getApplicationByUserId(userId);
    }

    // 대기 중인 가이드 신청 목록 조회
    public List<GuideApplicationVO> getPendingApplications() {
        return guideDAO.getPendingApplications();
    }

    // 가이드 신청 승인
    @Transactional
    public int approveApplication(int applicationId, String adminId, String adminComment) {
        // 1. 신청 정보 조회
        GuideApplicationVO app = guideDAO.getApplicationById(applicationId);
        if (app == null) {
            System.err.println("신청 정보를 찾을 수 없습니다. applicationId: " + applicationId);
            return 0;
        }

        // 2. guides 테이블에 삽입 (이미 존재하면 0을 반환)
        int insertResult = guideDAO.insertGuide(app);
        System.out.println("=== 가이드 승인 프로세스 ===");
        System.out.println("가이드 등록 시도 결과: " + insertResult + " (userId: " + app.getUserId() + ")");

        if (insertResult > 0) {
            System.out.println("✅ 새로운 가이드가 등록되었습니다.");
        } else {
            System.out.println("⚠️ 이미 가이드로 등록되어 있거나 등록에 실패했습니다.");
        }

        // 3. 신청 상태 업데이트 (중복 등록 방지로 insertResult가 0이어도 승인은 계속 진행)
        int updateResult = guideDAO.updateApplicationStatus(applicationId, "approved", adminId, adminComment);
        System.out.println("신청 상태 업데이트 결과: " + updateResult);

        if (updateResult > 0) {
            System.out.println("✅ 가이드 신청이 승인되었습니다.");
        } else {
            System.err.println("❌ 신청 상태 업데이트에 실패했습니다.");
        }
        System.out.println("=========================");

        return updateResult;
    }

    // 가이드 신청 거절
    public int rejectApplication(int applicationId, String adminId, String adminComment) {
        return guideDAO.rejectApplication(applicationId, adminId, adminComment);
    }

    // 가이드 목록 조회
    public List<GuideVO> getGuideList(String region, String theme, Double minRating) {
        return guideDAO.getGuideList(region, theme, minRating);
    }

    // 가이드 상세 정보 조회
    public GuideVO getGuideById(int guideId) {
        return guideDAO.getGuideById(guideId);
    }

    // 사용자 ID로 가이드 정보 조회
    public GuideVO getGuideByUserId(String userId) {
        return guideDAO.getGuideByUserId(userId);
    }

    // 승인된 가이드 수 조회
    public int getApprovedGuideCount() {
        return guideDAO.getApprovedGuideCount();
    }

    // 이번 달 신청 수 조회
    public int getMonthlyApplicationCount() {
        return guideDAO.getMonthlyApplicationCount();
    }

    // 전체 신청 수 조회
    public int getTotalApplicationCount() {
        return guideDAO.getTotalApplicationCount();
    }

    // 승인된 신청 수 조회
    public int getApprovedApplicationCount() {
        return guideDAO.getApprovedApplicationCount();
    }

    // 모든 가이드 신청 조회 (페이징, 상태 필터)
    public List<GuideApplicationVO> getAllApplications(String status, int offset, int size, String orderBy, String orderDirection) {
        return guideDAO.getAllApplications(status, offset, size, orderBy, orderDirection);
    }

    // 가이드 신청 검색 (페이징, 상태 필터)
    public List<GuideApplicationVO> searchApplications(String search, String status, int offset, int size, String orderBy, String orderDirection) {
        return guideDAO.searchApplications(search, status, offset, size, orderBy, orderDirection);
    }

    // 상태별 신청 수 조회
    public int getTotalApplicationCountByStatus(String status) {
        return guideDAO.getTotalApplicationCountByStatus(status);
    }

    // 검색 결과 신청 수 조회
    public int getSearchApplicationCount(String search, String status) {
        return guideDAO.getSearchApplicationCount(search, status);
    }

    // 특정 상태의 신청 수 조회
    public int getApplicationCountByStatus(String status) {
        return guideDAO.getApplicationCountByStatus(status);
    }

    // 가이드 삭제
    @Transactional
    public int deleteGuide(int guideId) {
        // 1. 가이드 정보 조회
        GuideVO guide = guideDAO.getGuideById(guideId);
        if (guide == null) {
            System.err.println("가이드를 찾을 수 없습니다. guideId: " + guideId);
            return 0;
        }

        String userId = guide.getUserId();
        System.out.println("=== 가이드 삭제 프로세스 ===");
        System.out.println("삭제할 가이드 ID: " + guideId);
        System.out.println("사용자 ID: " + userId);

        // 2. guides 테이블에서 삭제
        int deleteResult = guideDAO.deleteGuide(guideId);
        System.out.println("guides 테이블 삭제 결과: " + deleteResult);

        // 3. guide_applications 테이블의 상태를 'deleted'로 변경 (재신청 가능하도록)
        if (deleteResult > 0 && userId != null) {
            GuideApplicationVO application = guideDAO.getApplicationByUserId(userId);
            if (application != null && "approved".equals(application.getStatus())) {
                // approved 상태를 rejected로 변경하여 재신청 가능하게 함
                int updateResult = guideDAO.updateApplicationStatus(
                    application.getApplicationId(),
                    "rejected",
                    "system",
                    "가이드가 삭제되어 자동으로 거절 처리되었습니다."
                );
                System.out.println("guide_applications 상태 업데이트 결과: " + updateResult);
            }
        }

        System.out.println("✅ 가이드 삭제 완료");
        System.out.println("============================");
        return deleteResult;
    }
}