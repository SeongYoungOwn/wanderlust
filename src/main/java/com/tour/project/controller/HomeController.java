package com.tour.project.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.beans.factory.annotation.Autowired;
import org.apache.ibatis.session.SqlSession;

@Controller
public class HomeController {
    
    @Autowired
    private SqlSession sqlSession;
    
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String index(Model model) {
        addStatisticsToModel(model);
        return "home";
    }
    
    @RequestMapping(value = "/home", method = RequestMethod.GET)
    public String home(Model model) {
        addStatisticsToModel(model);
        return "home";
    }
    
    private void addStatisticsToModel(Model model) {
        try {
            // 활성 사용자 수 (전체 등록 사용자)
            Integer activeUserCount = sqlSession.selectOne("StatisticsMapper.getActiveUserCount");
            
            // 등록된 여행계획 수
            Integer travelPlanCount = sqlSession.selectOne("StatisticsMapper.getTravelPlanCount");
            
            // 커뮤니티 게시글 수
            Integer communityPostCount = sqlSession.selectOne("StatisticsMapper.getCommunityPostCount");
            
            // 매칭된 사용자 수 (동행 신청된 수)
            Integer matchedUserCount = sqlSession.selectOne("StatisticsMapper.getMatchedUserCount");
            
            // 모델에 추가 (null인 경우 기본값 사용)
            model.addAttribute("activeUserCount", activeUserCount != null ? activeUserCount : 128);
            model.addAttribute("travelPlanCount", travelPlanCount != null ? travelPlanCount : 245);
            model.addAttribute("communityPostCount", communityPostCount != null ? communityPostCount : 392);
            model.addAttribute("matchedUserCount", matchedUserCount != null ? matchedUserCount : 87);
            
        } catch (Exception e) {
            // 기본값 설정 (데이터베이스 오류 시)
            model.addAttribute("activeUserCount", 128);
            model.addAttribute("travelPlanCount", 245);
            model.addAttribute("communityPostCount", 392);
            model.addAttribute("matchedUserCount", 87);
        }
    }
    
    @RequestMapping(value = "/jsp", method = RequestMethod.GET)
    public String jsp() {
        return "home";
    }
    
    @RequestMapping(value = "/admin-test", method = RequestMethod.GET)
    public String adminTest() {
        return "admin/dashboard";
    }
    
}