package com.tour.project.controller;

import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.SystemSettingDTO;
import com.tour.project.service.ApiKeyService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * 관리자 API 설정 컨트롤러
 * - Claude API 키 관리 페이지
 * - API 키 저장/삭제/테스트
 */
@Slf4j
@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminApiSettingsController {

    private final ApiKeyService apiKeyService;

    /**
     * API 설정 페이지
     */
    @GetMapping("/api-settings")
    public String apiSettingsPage(Model model, HttpSession session) {
        // 관리자 확인
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
            return "redirect:/member/login";
        }

        // API 키 정보 조회
        SystemSettingDTO apiKeyInfo = apiKeyService.getApiKeyInfo();
        boolean isConfigured = apiKeyService.isApiKeyConfigured();
        boolean isActive = apiKeyService.isApiKeyActive();
        String maskedKey = apiKeyService.getMaskedApiKey();
        String apiUrl = apiKeyService.getApiUrl();

        model.addAttribute("apiKeyInfo", apiKeyInfo);
        model.addAttribute("isConfigured", isConfigured);
        model.addAttribute("isActive", isActive);
        model.addAttribute("maskedKey", maskedKey);
        model.addAttribute("apiUrl", apiUrl);

        return "admin/api-settings";
    }

    /**
     * API 키 저장
     */
    @PostMapping("/api-settings/save")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> saveApiKey(
            @RequestParam("apiKey") String apiKey,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // API 키 형식 검증
            if (!apiKeyService.isValidApiKeyFormat(apiKey)) {
                response.put("success", false);
                response.put("message", "올바른 Claude API 키 형식이 아닙니다. (sk-ant-api... 형식)");
                return ResponseEntity.badRequest().body(response);
            }

            // 저장
            boolean result = apiKeyService.saveApiKey(apiKey, loginUser.getUserId());

            if (result) {
                log.info("API 키 저장 성공 - 관리자: {}", loginUser.getUserId());
                response.put("success", true);
                response.put("message", "API 키가 성공적으로 저장되었습니다.");
                response.put("maskedKey", apiKeyService.getMaskedApiKey());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "API 키 저장에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }

        } catch (Exception e) {
            log.error("API 키 저장 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * API 키 삭제
     */
    @PostMapping("/api-settings/delete")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteApiKey(HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 삭제
            boolean result = apiKeyService.deleteApiKey(loginUser.getUserId());

            if (result) {
                log.info("API 키 삭제 성공 - 관리자: {}", loginUser.getUserId());
                response.put("success", true);
                response.put("message", "API 키가 삭제되었습니다. AI 기능이 비활성화됩니다.");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "API 키 삭제에 실패했습니다.");
                return ResponseEntity.internalServerError().body(response);
            }

        } catch (Exception e) {
            log.error("API 키 삭제 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * API 키 테스트 (형식 검증)
     */
    @PostMapping("/api-settings/test")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> testApiKey(
            @RequestParam("apiKey") String apiKey,
            HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            // 형식 검증
            boolean isValid = apiKeyService.isValidApiKeyFormat(apiKey);

            if (isValid) {
                response.put("success", true);
                response.put("message", "API 키 형식이 올바릅니다.");
                response.put("maskedKey", apiKeyService.maskApiKey(apiKey));
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "올바른 Claude API 키 형식이 아닙니다.");
                return ResponseEntity.badRequest().body(response);
            }

        } catch (Exception e) {
            log.error("API 키 테스트 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    /**
     * API 상태 조회 (AJAX용)
     */
    @GetMapping("/api-settings/status")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getApiStatus(HttpSession session) {

        Map<String, Object> response = new HashMap<>();

        try {
            // 관리자 확인
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null || !"ADMIN".equals(loginUser.getUserRole())) {
                response.put("success", false);
                response.put("message", "관리자 권한이 필요합니다.");
                return ResponseEntity.status(403).body(response);
            }

            response.put("success", true);
            response.put("isConfigured", apiKeyService.isApiKeyConfigured());
            response.put("isActive", apiKeyService.isApiKeyActive());
            response.put("maskedKey", apiKeyService.getMaskedApiKey());
            response.put("apiUrl", apiKeyService.getApiUrl());

            SystemSettingDTO info = apiKeyService.getApiKeyInfo();
            if (info != null) {
                response.put("updatedAt", info.getUpdatedAt());
                response.put("updatedBy", info.getUpdatedBy());
            }

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            log.error("API 상태 조회 중 오류", e);
            response.put("success", false);
            response.put("message", "서버 오류가 발생했습니다.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
}
