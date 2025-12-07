package com.tour.project.controller;

import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.MemberDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;
import java.util.List;

@Controller
@RequestMapping("/ai")
public class AiModelController {
    
    @Autowired
    private MemberDAO memberDAO;
    
    // AI Model 페이지 표시
    @GetMapping("/model")
    public String showModelPage(Model model, HttpSession session) {
        try {
            // 활성 사용자 수 조회
            int activeMemberCount = memberDAO.getActiveMemberCount();
            
            // 최근 가입한 사용자들 조회 (최대 3명)
            List<MemberDTO> recentMembers = memberDAO.getRecentMembersWithProfile(3);
            
            // 활성 사용자 수를 포맷팅 (천 단위 구분)
            String formattedCount;
            if (activeMemberCount >= 1000) {
                formattedCount = String.format("%.1fK+", activeMemberCount / 1000.0);
            } else {
                formattedCount = activeMemberCount + "+";
            }
            
            model.addAttribute("activeMemberCount", formattedCount);
            model.addAttribute("recentMembers", recentMembers);
            
        } catch (Exception e) {
            // 에러 발생 시 기본값 사용
            model.addAttribute("activeMemberCount", "5K+");
            model.addAttribute("recentMembers", null);
            e.printStackTrace();
        }
        
        return "ai/model";
    }
    
    // AI 지도 페이지 표시
    @GetMapping("/map")
    public String showMapPage(Model model, HttpSession session) {
        return "ai/map";
    }
}