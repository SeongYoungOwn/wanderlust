package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.tour.project.service.GuideService;
import com.tour.project.dto.MemberDTO;
import com.tour.project.vo.GuideVO;
import com.tour.project.vo.GuideApplicationVO;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/guide")
public class GuideController {

    @Autowired
    private GuideService guideService;

    // 가이드 목록 페이지
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public String list(@RequestParam(required = false) String region,
                      @RequestParam(required = false) String theme,
                      @RequestParam(required = false) String minRating,
                      Model model) {

        try {
            Double rating = null;
            if (minRating != null && !minRating.isEmpty()) {
                try {
                    rating = Double.parseDouble(minRating);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            // 가이드 목록 조회
            List<GuideVO> guides = guideService.getGuideList(region, theme, rating);

            // 디버깅 로그
            System.out.println("=== 가이드 목록 조회 결과 ===");
            System.out.println("총 가이드 수: " + (guides != null ? guides.size() : 0));
            if (guides != null) {
                for (GuideVO guide : guides) {
                    System.out.println("  - Guide ID: " + guide.getGuideId());
                    System.out.println("    User ID: " + guide.getUserId());
                    System.out.println("    Name: " + guide.getUserName());
                    System.out.println("    Region: " + guide.getRegion());
                    System.out.println("    Phone: " + guide.getPhone());
                    System.out.println("    Specialty Theme: " + guide.getSpecialtyTheme());
                    System.out.println("    Review Count: " + guide.getReviewCount());
                    System.out.println("    ---");
                }
            }

            model.addAttribute("guides", guides);
            model.addAttribute("selectedRegion", region);
            model.addAttribute("selectedTheme", theme);
            model.addAttribute("selectedRating", minRating);

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("Error: " + e.getMessage());
            model.addAttribute("error", "가이드 목록을 불러오는 중 오류가 발생했습니다: " + e.getMessage());
        }

        return "guide/guide-list"; // 수정된 가이드 목록 페이지
    }

    // 가이드 등록 페이지
    @RequestMapping(value = "/register", method = RequestMethod.GET)
    public String registerForm(HttpSession session, Model model, RedirectAttributes redirectAttributes) {

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            redirectAttributes.addFlashAttribute("message", "로그인이 필요한 서비스입니다.");
            return "redirect:/member/login";
        }

        try {
            // 실제 가이드 등록 여부 확인 (guides 테이블)
            GuideVO existingGuide = guideService.getGuideByUserId(loginUser.getUserId());

            System.out.println("=== 가이드 등록 페이지 접근 ===");
            System.out.println("사용자 ID: " + loginUser.getUserId());
            System.out.println("guides 테이블 조회 결과: " + (existingGuide != null ? "존재함" : "없음"));

            // model에 existingGuide 추가 (JSP에서 조건 체크용)
            model.addAttribute("existingGuide", existingGuide);

            if (existingGuide != null) {
                // guides 테이블에 실제로 존재하는 경우
                System.out.println("✅ 가이드로 이미 등록됨 - Guide ID: " + existingGuide.getGuideId());
                model.addAttribute("message", "이미 가이드로 등록되어 있습니다.");
                // 폼을 숨기기 위해 빈 application 객체 추가
                model.addAttribute("existingApplication", new GuideApplicationVO());
                return "guide/guide-register";
            }

            // 가이드가 없으면 신청 내역 확인 (guide_applications 테이블)
            GuideApplicationVO existingApplication = guideService.getApplicationByUserId(loginUser.getUserId());
            System.out.println("guide_applications 테이블 조회 결과: " + (existingApplication != null ? "존재함 (상태: " + existingApplication.getStatus() + ")" : "없음"));

            if (existingApplication != null) {
                model.addAttribute("existingApplication", existingApplication);

                if ("pending".equals(existingApplication.getStatus())) {
                    System.out.println("⏳ 신청 대기 중");
                    model.addAttribute("message", "이미 가이드 신청이 진행 중입니다.");
                } else if ("rejected".equals(existingApplication.getStatus())) {
                    System.out.println("❌ 신청 거절됨");
                    model.addAttribute("message", "가이드 등록이 삭제되었습니다. 다시 신청하실 수 있습니다.");
                } else if ("approved".equals(existingApplication.getStatus())) {
                    System.out.println("⚠️ approved 상태지만 guides 테이블에 없음 (삭제된 것으로 추정) - 재신청 가능");
                }
                // approved 상태지만 guides 테이블에 없는 경우 (삭제됨)
                // -> 메시지 없이 신청 폼 표시
            } else {
                System.out.println("✅ 신청 내역 없음 - 신청 가능");
            }

            System.out.println("============================");

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "guide/guide-register";
    }

    // 가이드 신청 처리
    @RequestMapping(value = "/apply", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> apply(@RequestParam String region,
                                    @RequestParam String address,
                                    @RequestParam String phone,
                                    @RequestParam String specialtyRegion,
                                    @RequestParam String specialtyTheme,
                                    @RequestParam String specialtyArea,
                                    @RequestParam String introduction,
                                    @RequestParam String greetingMessage,
                                    HttpSession session) {

        Map<String, Object> result = new HashMap<>();

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        try {
            // 기존 신청 확인
            GuideApplicationVO existing = guideService.getApplicationByUserId(loginUser.getUserId());
            if (existing != null) {
                if ("pending".equals(existing.getStatus())) {
                    result.put("success", false);
                    result.put("message", "이미 가이드 신청이 진행 중입니다.");
                    return result;
                } else if ("approved".equals(existing.getStatus())) {
                    result.put("success", false);
                    result.put("message", "이미 가이드로 등록되어 있습니다.");
                    return result;
                }
            }

            // 신청서 생성
            GuideApplicationVO application = new GuideApplicationVO();
            application.setUserId(loginUser.getUserId());
            application.setRegion(region);
            application.setAddress(address);
            application.setPhone(phone);
            application.setSpecialtyRegion(specialtyRegion);
            application.setSpecialtyTheme(specialtyTheme);
            application.setSpecialtyArea(specialtyArea);
            application.setIntroduction(introduction);
            application.setGreetingMessage(greetingMessage);

            int insertResult = guideService.insertGuideApplication(application);

            if (insertResult > 0) {
                result.put("success", true);
                result.put("message", "가이드 신청이 완료되었습니다. 관리자 승인을 기다려주세요.");
            } else {
                result.put("success", false);
                result.put("message", "신청 처리 중 오류가 발생했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return result;
    }

    // 가이드 프로필 페이지
    @RequestMapping(value = "/profile/{guideId}", method = RequestMethod.GET)
    public String profile(@PathVariable int guideId, Model model) {

        try {
            GuideVO guide = guideService.getGuideById(guideId);

            if (guide != null) {
                model.addAttribute("guide", guide);

                // TODO: 리뷰 데이터 조회 (리뷰 기능 구현 시 추가)
                // List<ReviewVO> reviews = reviewService.getReviewsByGuideId(guideId);
                // model.addAttribute("reviews", reviews);

            } else {
                model.addAttribute("error", "가이드 정보를 찾을 수 없습니다.");
                return "redirect:/guide/list";
            }

        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "가이드 정보를 불러오는 중 오류가 발생했습니다.");
            return "redirect:/guide/list";
        }

        return "guide/guide-profile";
    }

    // 가이드 상세 정보 (기존 매핑 - 호환성 유지)
    @RequestMapping(value = "/{guideId}", method = RequestMethod.GET)
    public String detail(@PathVariable int guideId, Model model) {
        return profile(guideId, model);
    }

    // 가이드 삭제 (관리자 전용)
    @RequestMapping(value = "/delete/{guideId}", method = RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> deleteGuide(@PathVariable int guideId, HttpSession session) {

        Map<String, Object> result = new HashMap<>();

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");

        // 로그인 체크
        if (loginUser == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        // 관리자 권한 체크
        if (!"admin".equalsIgnoreCase(loginUser.getUserRole())) {
            result.put("success", false);
            result.put("message", "관리자만 가이드를 삭제할 수 있습니다.");
            return result;
        }

        try {
            int deleteResult = guideService.deleteGuide(guideId);

            if (deleteResult > 0) {
                result.put("success", true);
                result.put("message", "가이드가 성공적으로 삭제되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "가이드 삭제에 실패했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "오류가 발생했습니다: " + e.getMessage());
        }

        return result;
    }
}