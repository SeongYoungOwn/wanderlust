package com.tour.project.controller;

import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dao.MannerEvaluationDAO;
import com.tour.project.dto.MemberDTO;
import com.tour.project.dto.TravelMbtiQuestionDTO;
import com.tour.project.dto.TravelMbtiResultDTO;
import com.tour.project.dto.UserTravelMbtiDTO;
import com.tour.project.dto.MbtiMatchUserDTO;
import com.tour.project.dto.UserMannerStatsDTO;
import com.tour.project.service.MBTICompatibilityEngine;
import com.tour.project.service.ComprehensiveCompatibilityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/travel-mbti")
public class TravelMbtiController {

    @Autowired
    private TravelMbtiDAO travelMbtiDAO;
    
    @Autowired
    private MannerEvaluationDAO mannerEvaluationDAO;
    
    @Autowired
    private MBTICompatibilityEngine mbtiCompatibilityEngine;
    
    @Autowired
    private ComprehensiveCompatibilityService comprehensiveCompatibilityService;

    @GetMapping("/test")
    public String showTest(Model model, HttpSession session) {
        // 로그인 여부와 상관없이 테스트 페이지 표시
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        boolean isLoggedIn = loginUser != null;
        
        // 모든 질문 가져오기 (8개)
        List<TravelMbtiQuestionDTO> questions = travelMbtiDAO.getAllQuestions();
        
        model.addAttribute("questions", questions);
        model.addAttribute("totalQuestions", questions.size());
        model.addAttribute("isLoggedIn", isLoggedIn);
        
        if (isLoggedIn) {
            model.addAttribute("userName", loginUser.getUserName());
        }

        return "travel-mbti/test";
    }


    @PostMapping("/submit")
    @ResponseBody
    public Map<String, Object> submitTest(@RequestBody Map<String, String> answers, HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            boolean isLoggedIn = loginUser != null;
            
            // MBTI 타입 계산 (로그인 여부와 상관없이)
            String mbtiType = calculateTravelMbtiType(answers);

            // 답변 데이터를 세션에 임시 저장 (결과 페이지에서 저장 버튼 누를 때 사용)
            if (isLoggedIn) {
                session.setAttribute("pendingMbtiAnswers", convertAnswersToJson(answers));
                session.setAttribute("pendingMbtiType", mbtiType);
            }

            response.put("success", true);
            response.put("mbtiType", mbtiType);
            response.put("isLoggedIn", isLoggedIn);
            response.put("saved", false);
            response.put("message", "결과 페이지에서 저장 버튼을 눌러 저장하세요.");
            
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "테스트 결과 계산 중 오류가 발생했습니다.");
            e.printStackTrace();
        }
        
        return response;
    }

    @GetMapping("/result/{mbtiType}")
    public String showResult(@PathVariable String mbtiType, Model model, HttpSession session) {
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            boolean isLoggedIn = loginUser != null;
            
            // 여행 MBTI 결과 정보 가져오기 (로그인 여부와 상관없이)
            TravelMbtiResultDTO result = travelMbtiDAO.getResultByType(mbtiType.toUpperCase());
            if (result == null) {
                System.out.println("Result not found for type: " + mbtiType);
                return "redirect:/travel-mbti/test";
            }

            model.addAttribute("result", result);
            model.addAttribute("mbtiType", mbtiType.toUpperCase());
            model.addAttribute("isLoggedIn", isLoggedIn);
            
            // 최적의 매칭 MBTI 계산
            String matchingMbti = calculateBestMatchingMbti(mbtiType.toUpperCase());
            String matchingDescription = getMatchingDescription(mbtiType.toUpperCase(), matchingMbti);
            
            // 매칭 MBTI의 타입 이름 가져오기
            TravelMbtiResultDTO matchingResult = travelMbtiDAO.getResultByType(matchingMbti);
            String matchingTypeName = matchingResult != null ? matchingResult.getTypeName() : "여행 파트너";
            
            // 궁합도 점수 계산 (0.0~1.0을 0~100%로 변환)
            try {
                System.err.println("=== MBTI Compatibility Debug Start ===");
                System.err.println("User MBTI: " + mbtiType.toUpperCase());
                System.err.println("Matching MBTI: " + matchingMbti);
                System.err.println("MBTICompatibilityEngine instance: " + mbtiCompatibilityEngine);
                
                double compatibilityScore = mbtiCompatibilityEngine.calculateMBTIScore(mbtiType.toUpperCase(), matchingMbti);
                int compatibilityPercentage = (int) Math.round(compatibilityScore * 100);
                
                System.err.println("Compatibility Score: " + compatibilityScore);
                System.err.println("Compatibility Percentage: " + compatibilityPercentage);
                
                // 궁합도 설명 생성
                String compatibilityDescription = mbtiCompatibilityEngine.generateCompatibilityDescription(mbtiType.toUpperCase(), matchingMbti);
                
                // 추천 여행 스타일
                String recommendedTravelStyle = mbtiCompatibilityEngine.getRecommendedTravelStyle(mbtiType.toUpperCase(), matchingMbti);
                
                System.err.println("Compatibility Description: " + compatibilityDescription);
                System.err.println("Recommended Travel Style: " + recommendedTravelStyle);
                
                model.addAttribute("compatibilityPercentage", compatibilityPercentage);
                model.addAttribute("compatibilityDescription", compatibilityDescription);
                model.addAttribute("recommendedTravelStyle", recommendedTravelStyle);
                
                System.err.println("Model attributes added successfully");
                System.err.println("===============================");
            } catch (Exception e) {
                System.err.println("=== MBTI Compatibility Error ===");
                System.err.println("Error during compatibility calculation: " + e.getMessage());
                e.printStackTrace();
                
                // 에러 시 기본값 설정
                model.addAttribute("compatibilityPercentage", 75);
                model.addAttribute("compatibilityDescription", "여행 성향이 잘 맞는 파트너입니다!");
                model.addAttribute("recommendedTravelStyle", "균형잡힌 여행");
                System.err.println("Using default compatibility values");
                System.err.println("===============================");
            }
            
            model.addAttribute("matchingMbti", matchingMbti);
            model.addAttribute("matchingTypeName", matchingTypeName);
            model.addAttribute("matchingDescription", matchingDescription);
            
            // 매칭 MBTI 타입을 가진 실제 사용자들 가져오기
            try {
                System.err.println("=== Matching Users Debug Start ===");
                System.err.println("Searching for users with MBTI type: " + matchingMbti);
                
                List<MbtiMatchUserDTO> matchingUsers = travelMbtiDAO.getUsersByMbtiType(matchingMbti);
                
                System.err.println("Found " + (matchingUsers != null ? matchingUsers.size() : 0) + " matching users");
                
                if (matchingUsers != null && !matchingUsers.isEmpty()) {
                    model.addAttribute("matchingUsers", matchingUsers);
                    System.err.println("Successfully added matchingUsers to model");
                } else {
                    model.addAttribute("matchingUsers", new ArrayList<>());
                    System.err.println("No matching users found, added empty list");
                }
                
                System.err.println("=== Matching Users Debug End ===");
                
            } catch (Exception e) {
                System.err.println("=== Matching Users Error ===");
                System.err.println("Error fetching matching users: " + e.getMessage());
                e.printStackTrace();
                model.addAttribute("matchingUsers", new ArrayList<>());
                System.err.println("Added empty list due to error");
            }

            // 추천 여행지를 배열로 변환
            if (result.getRecommendedDestinations() != null && !result.getRecommendedDestinations().trim().isEmpty()) {
                String[] destinations = result.getRecommendedDestinations().split(",");
                for (int i = 0; i < destinations.length; i++) {
                    destinations[i] = destinations[i].trim();
                }
                model.addAttribute("destinations", destinations);
            } else {
                model.addAttribute("destinations", new String[]{"전 세계 어디든"});
            }

            // 여행 팁을 배열로 변환
            if (result.getTravelTips() != null && !result.getTravelTips().trim().isEmpty()) {
                String[] tips = result.getTravelTips().split("\\n");
                for (int i = 0; i < tips.length; i++) {
                    tips[i] = tips[i].trim();
                }
                model.addAttribute("tips", tips);
            } else {
                model.addAttribute("tips", new String[]{"당신만의 특별한 여행을 즐겨보세요!"});
            }

            return "travel-mbti/result";
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Error in showResult: " + e.getMessage());
            return "redirect:/travel-mbti/test";
        }
    }
    

    @GetMapping("/history")
    public String showHistory(Model model, HttpSession session) {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }

        List<UserTravelMbtiDTO> history = travelMbtiDAO.getUserMbtiHistory(loginUser.getUserId());
        model.addAttribute("history", history);
        model.addAttribute("userName", loginUser.getUserName());

        return "travel-mbti/history";
    }

    @GetMapping("/my-result")
    @ResponseBody
    public Map<String, Object> getMyResult(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        try {
            UserTravelMbtiDTO latestResult = travelMbtiDAO.getLatestUserMbti(loginUser.getUserId());
            if (latestResult != null) {
                TravelMbtiResultDTO resultInfo = travelMbtiDAO.getResultByType(latestResult.getMbtiType());
                response.put("success", true);
                response.put("mbtiType", latestResult.getMbtiType());
                response.put("typeName", resultInfo.getTypeName());
                response.put("testDate", latestResult.getTestDate());
            } else {
                response.put("success", false);
                response.put("message", "테스트 기록이 없습니다.");
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "결과 조회 중 오류가 발생했습니다.");
        }
        
        return response;
    }
    
    @PostMapping("/save-result")
    @ResponseBody
    public Map<String, Object> saveResult(@RequestBody Map<String, String> request, HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.put("success", false);
            response.put("message", "로그인이 필요합니다.");
            return response;
        }

        try {
            String mbtiType = request.get("mbtiType");

            // 세션에서 임시 저장된 답변 가져오기
            String answers = (String) session.getAttribute("pendingMbtiAnswers");
            if (answers == null) {
                answers = "{}"; // 답변이 없으면 기본값
            }

            UserTravelMbtiDTO userMbti = new UserTravelMbtiDTO();
            userMbti.setUserId(loginUser.getUserId());
            userMbti.setMbtiType(mbtiType);
            userMbti.setAnswers(answers);

            travelMbtiDAO.insertUserMbti(userMbti);

            // 저장 후 세션에서 임시 데이터 제거
            session.removeAttribute("pendingMbtiAnswers");
            session.removeAttribute("pendingMbtiType");

            response.put("success", true);
            response.put("message", "결과가 저장되었습니다.");
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "저장 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }

        return response;
    }
    
    @GetMapping("/matching")
    public String showMatching(Model model, HttpSession session) {
        // 매칭 페이지 기본 화면만 표시
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser != null) {
            model.addAttribute("userName", loginUser.getUserName());
        }
        return "travel-mbti/matching";
    }
    
    @GetMapping("/matching/data")
    @ResponseBody
    public Map<String, Object> getMatchingData(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            System.err.println("=== 매칭 데이터 요청 시작 ===");
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                System.err.println("로그인 사용자가 없음");
                response.put("success", false);
                response.put("error", "로그인이 필요합니다.");
                return response;
            }
            System.err.println("로그인 사용자 ID: " + loginUser.getUserId());
            
            // 사용자의 최신 MBTI 결과 확인
            UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(loginUser.getUserId());
            if (userMbti == null) {
                System.err.println("사용자의 MBTI 테스트 결과가 없음");
                response.put("success", false);
                response.put("needTest", true);
                response.put("message", "먼저 MBTI 테스트를 진행해주세요.");
                return response;
            }
            
            String myMbtiType = userMbti.getMbtiType();
            System.err.println("사용자 MBTI 타입: " + myMbtiType);
            
            // 최적의 매칭 MBTI 계산
            String matchingMbti = calculateBestMatchingMbti(myMbtiType);
            System.err.println("매칭 MBTI 타입: " + matchingMbti);
            
            // 매칭 MBTI 타입을 가진 사용자들 조회
            List<MbtiMatchUserDTO> matchingUsers = travelMbtiDAO.getUsersByMbtiType(matchingMbti);
            System.err.println("매칭된 사용자 수: " + (matchingUsers != null ? matchingUsers.size() : 0));
            
            // 각 사용자의 종합 궁합도 계산 (MBTI + 여행 계획 + 댓글 + 매너온도)
            for (MbtiMatchUserDTO user : matchingUsers) {
                try {
                    System.err.println("=== 사용자 궁합도 계산 시작: " + user.getUserId() + " ===");
                    
                    // 종합 궁합도 계산
                    Map<String, Object> compatibilityResult = 
                        comprehensiveCompatibilityService.calculateComprehensiveCompatibility(
                            loginUser.getUserId(), 
                            user.getUserId(),
                            myMbtiType,
                            matchingMbti
                        );
                    
                    System.err.println("종합 궁합도 계산 결과: " + compatibilityResult);
                    
                    // 종합 점수 설정
                    int totalScore = (int) compatibilityResult.get("totalScore");
                    user.setCompatibilityPercentage(totalScore);
                    
                    System.err.println("설정된 궁합도: " + totalScore + "%");
                    
                    // 각 항목별 점수 저장 (추가 정보)
                    user.setMbtiScore((int) compatibilityResult.get("mbtiScore"));
                    user.setTravelPlanScore((int) compatibilityResult.get("travelPlanScore"));
                    user.setActivityScore((int) compatibilityResult.get("activityScore"));
                    user.setMannerScore((int) compatibilityResult.get("mannerScore"));
                    
                    // 매너온도 조회
                    UserMannerStatsDTO mannerStats = mannerEvaluationDAO.getUserMannerStats(user.getUserId());
                    if (mannerStats != null) {
                        user.setMannerTemperature(mannerStats.getAverageMannerScore());
                        System.err.println("매너온도 설정 (DB): " + mannerStats.getAverageMannerScore() + "°C");
                    } else {
                        user.setMannerTemperature(36.5); // 기본 매너온도
                        System.err.println("매너온도 설정 (기본값): 36.5°C");
                    }
                    
                    // 추가 상세 정보 저장
                    user.setCompatibilityDetail(compatibilityResult);
                    
                    System.err.println("최종 사용자 데이터: " + user.toString());
                    System.err.println("=== 사용자 궁합도 계산 완료 ===");
                    
                } catch (Exception e) {
                    System.err.println("=== 궁합도 계산 에러: " + user.getUserId() + " ===");
                    e.printStackTrace();
                    // 에러 시 기본 MBTI 궁합도만 사용
                    try {
                        double compatibilityScore = mbtiCompatibilityEngine.calculateMBTIScore(myMbtiType, matchingMbti);
                        int compatibilityPercentage = (int) Math.round(compatibilityScore * 100);
                        user.setCompatibilityPercentage(compatibilityPercentage);
                        System.err.println("MBTI 엔진 궁합도 계산 성공: " + compatibilityPercentage + "%");
                    } catch (Exception mbtiError) {
                        System.err.println("MBTI 엔진 에러, 기본값 사용: " + mbtiError.getMessage());
                        user.setCompatibilityPercentage(75); // 완전 기본값
                    }
                    user.setMannerTemperature(36.5); // 기본 매너온도
                    
                    System.err.println("에러 시 기본값 설정 - 궁합도: " + user.getCompatibilityPercentage() + "%, 매너온도: 36.5°C");
                    System.err.println("=== 에러 처리 완료 ===");
                }
                
                // 최종 검증 - null이나 0인 경우 기본값 설정
                if (user.getCompatibilityPercentage() <= 0) {
                    user.setCompatibilityPercentage(75);
                    System.err.println("궁합도 값이 유효하지 않아 기본값 75%로 설정");
                }
                if (user.getMannerTemperature() == null || user.getMannerTemperature() <= 0) {
                    user.setMannerTemperature(36.5);
                    System.err.println("매너온도 값이 유효하지 않아 기본값 36.5°C로 설정");
                }
            }
            
            // 내 MBTI 정보
            TravelMbtiResultDTO myMbtiResult = travelMbtiDAO.getResultByType(myMbtiType);
            TravelMbtiResultDTO matchingMbtiResult = travelMbtiDAO.getResultByType(matchingMbti);
            
            System.err.println("내 MBTI 결과: " + (myMbtiResult != null ? myMbtiResult.getTypeName() : "null"));
            System.err.println("매칭 MBTI 결과: " + (matchingMbtiResult != null ? matchingMbtiResult.getTypeName() : "null"));
            
            // 매칭된 사용자들의 정보 로그
            if (matchingUsers != null) {
                for (int i = 0; i < Math.min(matchingUsers.size(), 3); i++) {
                    MbtiMatchUserDTO user = matchingUsers.get(i);
                    System.err.println("사용자 " + (i+1) + " - ID: " + user.getUserId() + 
                                     ", 이름: " + user.getUserName() + 
                                     ", 궁합도: " + user.getCompatibilityPercentage() + "%");
                }
            }
            
            response.put("success", true);
            response.put("myMbtiType", myMbtiType);
            response.put("myMbtiResult", myMbtiResult);
            response.put("matchingMbti", matchingMbti);
            response.put("matchingMbtiResult", matchingMbtiResult);
            response.put("matchingUsers", matchingUsers);
            response.put("userName", loginUser.getUserName());
            
            System.err.println("=== 최종 응답 데이터 확인 ===");
            System.err.println("응답에 포함된 매칭 사용자 수: " + (matchingUsers != null ? matchingUsers.size() : 0));
            if (matchingUsers != null && !matchingUsers.isEmpty()) {
                for (int i = 0; i < Math.min(matchingUsers.size(), 3); i++) {
                    MbtiMatchUserDTO user = matchingUsers.get(i);
                    System.err.println("사용자 " + (i+1) + " 최종 데이터:");
                    System.err.println("  - ID: " + user.getUserId());
                    System.err.println("  - 이름: " + user.getUserName());
                    System.err.println("  - 궁합도: " + user.getCompatibilityPercentage() + "%");
                    System.err.println("  - 매너온도: " + user.getMannerTemperature() + "°C");
                }
            }
            System.err.println("=== 매칭 데이터 응답 생성 완료 ===");
            return response;
            
        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("error", "매칭 중 오류가 발생했습니다.");
            return response;
        }
    }

    // 여행 MBTI 타입 계산 메서드
    private String calculateTravelMbtiType(Map<String, String> answers) {
        Map<String, Integer> scores = new HashMap<>();
        scores.put("P", 0); // 즉흥적
        scores.put("J", 0); // 계획적
        scores.put("A", 0); // 모험적
        scores.put("S", 0); // 안전한
        scores.put("I", 0); // 개인적
        scores.put("G", 0); // 그룹
        scores.put("L", 0); // 럭셔리
        scores.put("B", 0); // 절약형

        // 각 질문별 답변에 따라 점수 계산
        for (Map.Entry<String, String> entry : answers.entrySet()) {
            int questionNum = Integer.parseInt(entry.getKey().replace("q", ""));
            String answer = entry.getValue();

            if (questionNum == 1 || questionNum == 5) { // P-J (계획성)
                if ("A".equals(answer)) {
                    scores.put("J", scores.get("J") + 1);  // A답변이 계획적
                } else {
                    scores.put("P", scores.get("P") + 1);  // B답변이 즉흥적
                }
            } else if (questionNum == 2 || questionNum == 6) { // A-S (모험성)
                if ("A".equals(answer)) {
                    scores.put("A", scores.get("A") + 1);
                } else {
                    scores.put("S", scores.get("S") + 1);
                }
            } else if (questionNum == 3 || questionNum == 7) { // I-G (개인/그룹)
                if ("A".equals(answer)) {
                    scores.put("I", scores.get("I") + 1);
                } else {
                    scores.put("G", scores.get("G") + 1);
                }
            } else if (questionNum == 4 || questionNum == 8) { // L-B (럭셔리/절약)
                if ("A".equals(answer)) {
                    scores.put("L", scores.get("L") + 1);
                } else {
                    scores.put("B", scores.get("B") + 1);
                }
            }
        }

        // 여행 MBTI 타입 결정
        StringBuilder mbtiType = new StringBuilder();
        mbtiType.append(scores.get("J") > scores.get("P") ? "J" : "P");  // J가 많으면 계획형, P가 많으면 즉흥형
        mbtiType.append(scores.get("A") > scores.get("S") ? "A" : "S");
        mbtiType.append(scores.get("I") > scores.get("G") ? "I" : "G");
        mbtiType.append(scores.get("L") > scores.get("B") ? "L" : "B");

        return mbtiType.toString();
    }

    // 답변을 JSON 문자열로 변환
    private String convertAnswersToJson(Map<String, String> answers) {
        StringBuilder json = new StringBuilder();
        json.append("{");
        boolean first = true;
        for (Map.Entry<String, String> entry : answers.entrySet()) {
            if (!first) {
                json.append(",");
            }
            json.append("\"").append(entry.getKey()).append("\":\"").append(entry.getValue()).append("\"");
            first = false;
        }
        json.append("}");
        return json.toString();
    }
    
    // 최적의 매칭 MBTI 계산 - 더 다양한 궁합도를 위한 개선된 로직
    private String calculateBestMatchingMbti(String mbtiType) {
        if (mbtiType == null || mbtiType.length() != 4) {
            return "JAGL"; // 기본값
        }
        
        // 특정 MBTI 타입별로 최적의 매칭 파트너를 정의 (실제 여행 패턴 분석 기반)
        Map<String, String> optimalMatches = new HashMap<>();
        
        // 계획형 모험가들
        optimalMatches.put("PAIB", "JAGL"); // 계획형 + 즉흥형, 예산차이로 균형
        optimalMatches.put("PAIL", "PSGB"); // 같은 계획형, 다른 예산
        optimalMatches.put("PAGL", "JSIB"); // 모험성향 + 안전함의 조화
        optimalMatches.put("PAGB", "JAIL"); // 예산성향 차이로 새로운 경험
        
        // 계획형 안전한 여행자들  
        optimalMatches.put("PSIB", "JAGL"); // 차분함 + 활발함의 균형
        optimalMatches.put("PSIL", "PAGB"); // 럭셔리 + 백패킹의 조화
        optimalMatches.put("PSGL", "JAIL"); // 그룹형 + 개인형의 균형
        optimalMatches.put("PSGB", "JAIB"); // 즉흥형 모험가와의 역동적 조화
        
        // 즉흥형 모험가들
        optimalMatches.put("JAIB", "PSGL"); // 즉흥 + 계획의 완벽한 조화  
        optimalMatches.put("JAIL", "PSIB"); // 개인성향 + 예산 차이의 묘미
        optimalMatches.put("JAGL", "PAIB"); // 그룹 + 개인의 균형
        optimalMatches.put("JAGB", "PSIL"); // 백패킹 + 럭셔리의 새로운 경험
        
        // 즉흥형 안전한 여행자들
        optimalMatches.put("JSIB", "PAGL"); // 차분함 + 활발함의 조화
        optimalMatches.put("JSIL", "PAGB"); // 개인형 + 그룹형의 균형
        optimalMatches.put("JSGL", "PSIB"); // 즉흥 + 계획의 안정적 조화
        optimalMatches.put("JSGB", "PSGL"); // 계획형과의 안정적 조화
        
        // 정의된 매칭이 있으면 사용, 없으면 기본 로직 적용
        if (optimalMatches.containsKey(mbtiType)) {
            return optimalMatches.get(mbtiType);
        }
        
        // 기본 로직 (폴백)
        char[] types = mbtiType.toCharArray();
        char[] matching = new char[4];
        
        // 기본 매칭 로직
        matching[0] = (types[0] == 'J') ? 'P' : 'J'; // 계획성은 보완
        matching[1] = (types[1] == 'A') ? 'S' : 'A'; // 활동성도 보완 관계로 변경
        matching[2] = types[2]; // 사교성은 같은 성향
        matching[3] = (types[3] == 'L') ? 'B' : 'L'; // 예산도 보완 관계로 변경
        
        return new String(matching);
    }
    
    // 매칭 설명 생성
    private String getMatchingDescription(String myType, String matchType) {
        StringBuilder desc = new StringBuilder();
        
        // 각 차원별 매칭 분석
        char[] my = myType.toCharArray();
        char[] match = matchType.toCharArray();
        
        // P/J 차원 설명
        if (my[0] != match[0]) {
            if (my[0] == 'J') {
                desc.append("당신의 계획적인 성향과 상대방의 자유로운 성향이 만나 균형잡힌 여행을 만들어요. ");
                desc.append("당신이 일정을 짜고, 파트너가 즉흥적인 재미를 더해줄 거예요. ");
            } else {
                desc.append("당신의 자유로운 성향을 상대방의 계획적인 면이 안정적으로 받쳐줄 거예요. ");
                desc.append("파트너가 기본 틀을 잡아주고, 당신이 특별한 순간을 만들어요. ");
            }
        } else {
            if (my[0] == 'J') {
                desc.append("둘 다 계획적이어서 체계적이고 안정적인 여행을 할 수 있어요. ");
            } else {
                desc.append("둘 다 자유로운 영혼이라 예상치 못한 모험을 함께 즐길 수 있어요. ");
            }
        }
        
        // A/S 차원 설명
        if (my[1] == 'A') {
            desc.append("모험을 사랑하는 당신에게는 같은 수준의 스릴을 즐기는 파트너가 필요해요. ");
        } else {
            desc.append("안전을 중시하는 당신에게는 비슷한 성향의 파트너가 편안해요. ");
        }
        
        // I/G 차원 설명
        if (my[2] == 'I') {
            desc.append("혼자 여행을 선호하지만, 가끔은 마음 맞는 한 명과 함께하는 것도 좋아요. ");
        } else {
            desc.append("그룹 여행을 즐기는 당신과 비슷한 사교적 성향의 파트너가 잘 맞아요. ");
        }
        
        // L/B 차원 설명
        if (my[3] == 'L') {
            desc.append("럭셔리를 추구하는 당신과 비슷한 여행 예산 수준의 파트너가 이상적이에요.");
        } else {
            desc.append("실속 있는 여행을 선호하는 당신과 비슷한 가치관의 파트너가 완벽해요.");
        }
        
        return desc.toString();
    }
}