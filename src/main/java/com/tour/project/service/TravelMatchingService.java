package com.tour.project.service;

import com.tour.project.dao.MbtiCompatibilityDAO;
import com.tour.project.dao.TravelMbtiDAO;
import com.tour.project.dao.TravelPlanDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TravelMatchingService {
    
    @Autowired
    private TravelMbtiDAO travelMbtiDAO;
    
    @Autowired
    private MbtiCompatibilityDAO mbtiCompatibilityDAO;
    
    @Autowired
    private TravelPlanDAO travelPlanDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    public AiChatResponseDTO findTravelMatches(MemberDTO loginUser, String userMessage) {
        try {
            // 로그인하지 않은 경우
            if (loginUser == null) {
                return new AiChatResponseDTO("여행 매칭 서비스를 이용하려면 로그인이 필요합니다. 😊", false);
            }
            
            // 1. 키워드 기반 매칭 시도 (우선순위)
            List<TravelPlanDTO> keywordMatchingPlans = findPlansByKeywords(userMessage);
            if (!keywordMatchingPlans.isEmpty()) {
                return generateKeywordMatchingResponse(userMessage, keywordMatchingPlans, loginUser);
            }
            
            // 2. 키워드 매칭 결과가 없으면 MBTI 기반 매칭 실행
            UserTravelMbtiDTO userMbti = travelMbtiDAO.getLatestUserMbti(loginUser.getUserId());
            if (userMbti == null) {
                return new AiChatResponseDTO(
                    "여행 매칭을 위해서는 먼저 MBTI 테스트를 완료해주세요! 🧠\n\n" +
                    "마이페이지 → MBTI 테스트에서 여행 성향을 확인해보세요.\n" +
                    "테스트 완료 후 다시 매칭을 요청해주시면, 최적의 여행 파트너를 찾아드릴게요! ✨", 
                    false
                );
            }
            
            // 3. 호환되는 MBTI 타입 찾기
            MbtiCompatibilityDTO compatibility = mbtiCompatibilityDAO.getBestMatch(userMbti.getMbtiType());
            if (compatibility == null) {
                return new AiChatResponseDTO("현재 매칭 데이터를 준비중입니다. 잠시 후 다시 시도해주세요.", false);
            }
            
            // 4. 호환 MBTI를 가진 사용자들의 여행계획 찾기
            String compatibleMbti = compatibility.getMbtiType2();
            List<TravelPlanDTO> mbtiMatchingPlans = findPlansByCompatibleMbti(compatibleMbti);
            
            // 5. MBTI 기반 AI 응답 생성
            return generateMbtiMatchingResponse(userMbti.getMbtiType(), compatibility, mbtiMatchingPlans);
            
        } catch (Exception e) {
            e.printStackTrace();
            return new AiChatResponseDTO("매칭 과정에서 오류가 발생했습니다. 다시 시도해주세요.", true);
        }
    }
    
    private List<TravelPlanDTO> findPlansByCompatibleMbti(String compatibleMbti) {
        // 호환 MBTI를 가진 모든 사용자 조회
        List<MemberDTO> compatibleUsers = memberDAO.getMembersByMbti(compatibleMbti);
        
        // 해당 사용자들의 여행계획 조회 (최대 5개)
        return compatibleUsers.stream()
            .flatMap(user -> travelPlanDAO.getTravelPlansByWriter(user.getUserId()).stream())
            .filter(plan -> "ACTIVE".equals(plan.getPlanStatus())) // 활성 상태인 계획만
            .limit(5)
            .collect(Collectors.toList());
    }
    
    // 키워드 기반 여행계획 검색
    private List<TravelPlanDTO> findPlansByKeywords(String userMessage) {
        if (userMessage == null) return List.of();
        
        String lowerMessage = userMessage.toLowerCase();
        
        // 키워드 추출
        String budgetKeyword = extractBudgetKeyword(lowerMessage);
        String durationKeyword = extractDurationKeyword(lowerMessage);
        String styleKeyword = extractStyleKeyword(lowerMessage);
        String destinationKeyword = extractDestinationKeyword(lowerMessage);
        
        // 키워드가 하나도 없으면 빈 리스트 반환
        if (budgetKeyword.isEmpty() && durationKeyword.isEmpty() && 
            styleKeyword.isEmpty() && destinationKeyword.isEmpty()) {
            return List.of();
        }
        
        // 모든 여행계획 조회 후 키워드 매칭
        List<TravelPlanDTO> allPlans = travelPlanDAO.getAllTravelPlans();
        
        return allPlans.stream()
            .filter(plan -> "ACTIVE".equals(plan.getPlanStatus()))
            .filter(plan -> matchesKeywords(plan, budgetKeyword, durationKeyword, styleKeyword, destinationKeyword))
            .limit(5)
            .collect(Collectors.toList());
    }
    
    // 예산 키워드 추출
    private String extractBudgetKeyword(String message) {
        if (message.contains("가성비") || message.contains("저렴") || message.contains("싸게") || message.contains("절약")) {
            return "가성비";
        }
        if (message.contains("럭셔리") || message.contains("고급") || message.contains("프리미엄") || message.contains("비싸")) {
            return "럭셔리";
        }
        return "";
    }
    
    // 기간 키워드 추출
    private String extractDurationKeyword(String message) {
        if (message.contains("3박4일") || message.contains("4일") || message.contains("짧게")) {
            return "3박4일";
        }
        if (message.contains("5박") || message.contains("6박") || message.contains("1주")) {
            return "5박이상";
        }
        if (message.contains("2박3일") || message.contains("3일")) {
            return "2박3일";
        }
        return "";
    }
    
    // 여행 스타일 키워드 추출
    private String extractStyleKeyword(String message) {
        if (message.contains("배낭") || message.contains("백패킹") || message.contains("자유")) {
            return "배낭여행";
        }
        if (message.contains("휴양") || message.contains("힐링") || message.contains("휴식")) {
            return "휴양";
        }
        if (message.contains("모험") || message.contains("액티비티") || message.contains("체험")) {
            return "모험";
        }
        if (message.contains("문화") || message.contains("역사") || message.contains("관광")) {
            return "문화";
        }
        return "";
    }
    
    // 목적지 키워드 추출
    private String extractDestinationKeyword(String message) {
        if (message.contains("일본") || message.contains("도쿄") || message.contains("오사카") || message.contains("교토")) {
            return "일본";
        }
        if (message.contains("동남아") || message.contains("태국") || message.contains("베트남") || message.contains("방콕")) {
            return "동남아";
        }
        if (message.contains("유럽") || message.contains("프랑스") || message.contains("독일") || message.contains("이탈리아")) {
            return "유럽";
        }
        if (message.contains("국내") || message.contains("제주") || message.contains("부산") || message.contains("서울")) {
            return "국내";
        }
        return "";
    }
    
    // 키워드 매칭 검증
    private boolean matchesKeywords(TravelPlanDTO plan, String budget, String duration, String style, String destination) {
        String planContent = (plan.getPlanTitle() + " " + plan.getPlanContent() + " " + plan.getPlanTags()).toLowerCase();
        
        // 예산 매칭
        if (!budget.isEmpty()) {
            if (budget.equals("가성비")) {
                if (!planContent.contains("가성비") && !planContent.contains("저렴") && 
                    !planContent.contains("절약") && plan.getPlanBudget() > 1000000) {
                    return false;
                }
            } else if (budget.equals("럭셔리")) {
                if (!planContent.contains("럭셔리") && !planContent.contains("프리미엄") && 
                    plan.getPlanBudget() < 800000) {
                    return false;
                }
            }
        }
        
        // 기간 매칭
        if (!duration.isEmpty()) {
            if (duration.equals("3박4일")) {
                long days = java.time.temporal.ChronoUnit.DAYS.between(
                    plan.getPlanStartDate().toLocalDate(), 
                    plan.getPlanEndDate().toLocalDate()) + 1;
                if (days < 3 || days > 5) return false;
            }
        }
        
        // 스타일 매칭
        if (!style.isEmpty()) {
            if (style.equals("배낭여행") && !planContent.contains("배낭") && !planContent.contains("자유")) return false;
            if (style.equals("휴양") && !planContent.contains("휴양") && !planContent.contains("힐링")) return false;
            if (style.equals("모험") && !planContent.contains("모험") && !planContent.contains("액티비티")) return false;
            if (style.equals("문화") && !planContent.contains("문화") && !planContent.contains("관광")) return false;
        }
        
        // 목적지 매칭 - 정확한 매칭만 허용
        if (!destination.isEmpty()) {
            if (destination.equals("일본") && !planContent.contains("일본") && !planContent.contains("도쿄") && 
                !planContent.contains("오사카") && !planContent.contains("교토")) return false;
            if (destination.equals("동남아") && !planContent.contains("베트남") && !planContent.contains("태국") && 
                !planContent.contains("방콕") && !planContent.contains("동남아")) return false;
            if (destination.equals("유럽") && !planContent.contains("유럽") && !planContent.contains("프랑스") && 
                !planContent.contains("독일") && !planContent.contains("이탈리아") && !planContent.contains("스페인") && 
                !planContent.contains("영국") && !planContent.contains("네덜란드")) return false;
            if (destination.equals("국내") && !planContent.contains("제주") && !planContent.contains("부산") && 
                !planContent.contains("서울") && !planContent.contains("국내") && !planContent.contains("한국")) return false;
        }
        
        return true;
    }
    
    // 키워드 기반 매칭 응답 생성
    private AiChatResponseDTO generateKeywordMatchingResponse(String userMessage, List<TravelPlanDTO> matchingPlans, MemberDTO loginUser) {
        StringBuilder response = new StringBuilder();
        
        response.append("🔍 **키워드 기반 여행 매칭 결과**\n\n");
        response.append("✨ **요청 내용**: \"").append(userMessage).append("\"\n\n");
        
        if (matchingPlans.isEmpty()) {
            // 목적지 키워드 추출해서 맞춤 메시지 제공
            String extractedDestination = extractDestinationKeyword(userMessage.toLowerCase());
            if (!extractedDestination.isEmpty()) {
                response.append("😅 아직 ").append(getDestinationDisplayName(extractedDestination)).append(" 여행계획을 올린 사람이 없네요!\n\n");
                response.append("🎯 **제안**: 직접 ").append(getDestinationDisplayName(extractedDestination)).append(" 여행계획을 올려서 다른 여행자들과 매칭되어 보시는 것은 어떨까요?\n");
                response.append("📝 여행계획 작성하기 → <a href='/travel/create' target='_blank'>**계획 만들기**</a>\n\n");
                response.append("또는 MBTI 기반 매칭을 통해 비슷한 여행 성향의 사람들을 찾아보세요! 🚀");
            } else {
                response.append("😅 요청하신 조건에 맞는 여행계획을 찾지 못했습니다.\n");
                response.append("다른 키워드로 다시 검색해보시거나, MBTI 기반 매칭을 시도해보세요! 🚀");
            }
        } else {
            response.append("🎉 **요청하신 조건에 맞는 여행계획을 찾았어요!**\n\n");
            
            for (int i = 0; i < matchingPlans.size(); i++) {
                TravelPlanDTO plan = matchingPlans.get(i);
                MemberDTO planWriter = memberDAO.getMemberById(plan.getPlanWriter());
                
                response.append("**").append(i + 1).append(". ").append(plan.getPlanTitle()).append("**\n");
                response.append("👤 작성자: ").append(planWriter.getUserName()).append("\n");
                response.append("📍 여행지: ").append(plan.getPlanDestination()).append("\n");
                response.append("💰 예산: ").append(String.format("%,d", plan.getPlanBudget())).append("원\n");
                response.append("📅 일정: ").append(plan.getPlanStartDate()).append(" ~ ").append(plan.getPlanEndDate()).append("\n");
                
                if (plan.getPlanTags() != null && !plan.getPlanTags().isEmpty()) {
                    response.append("🏷️ 태그: ").append(plan.getPlanTags()).append("\n");
                }
                
                // 여행계획 상세보기 링크
                response.append("🔍 <a href='/travel/detail/").append(plan.getPlanId()).append("' class='travel-detail-link' target='_blank'>**상세보기 →**</a>\n\n");
                response.append("---\n");
            }
            
            response.append("\n💡 **매칭 팁**: 위 여행계획들은 요청하신 키워드에 맞춰 선별된 결과입니다!\n");
            response.append("🤝 마음에 드는 계획이 있다면 동행 신청을 해보세요! ✈️");
        }
        
        // AI 생성 정보 면책 고지사항 추가
        response.append("\n\n");
        response.append("---\n");
        response.append("<small style='color: #666; font-size: 0.8em;'>");
        response.append("본 내용은 AI를 통해 생성된 요약 정보로, 사용자의 편의를 돕기 위해 제공됩니다. ");
        response.append("다만, 현지 사정으로 인해 운영시간이나 요금 등은 실시간으로 변경될 수 있으니, 방문 전 공식 채널을 통해 최신 정보를 확인하시는 것을 권장합니다. ");
        response.append("AI가 생성한 정보이므로, 참고용으로 활용하시고 중요한 내용은 공식 홈페이지 등에서 반드시 직접 확인해주세요.");
        response.append("</small>");
        
        return new AiChatResponseDTO(response.toString());
    }
    
    // MBTI 기반 매칭 응답 생성 (기존 메서드 이름 변경)
    private AiChatResponseDTO generateMbtiMatchingResponse(String userMbti, MbtiCompatibilityDTO compatibility, List<TravelPlanDTO> matchingPlans) {
        StringBuilder response = new StringBuilder();
        
        // MBTI 분석 결과 표시
        TravelMbtiResultDTO userMbtiInfo = travelMbtiDAO.getResultByType(userMbti);
        TravelMbtiResultDTO compatibleMbtiInfo = travelMbtiDAO.getResultByType(compatibility.getMbtiType2());
        
        response.append("🧠 **MBTI 매칭 분석 결과**\n\n");
        response.append("✨ **당신의 여행 MBTI**: ").append(userMbti).append(" - ").append(userMbtiInfo.getTypeName()).append("\n");
        response.append("🎯 **최적 매칭 MBTI**: ").append(compatibility.getMbtiType2()).append(" - ").append(compatibleMbtiInfo.getTypeName()).append("\n");
        response.append("💖 **호환성 점수**: ").append(compatibility.getCompatibilityScore()).append("%\n\n");
        
        response.append("🔗 **매칭 이유**: ").append(compatibility.getSynergyDescription()).append("\n");
        response.append("🌍 **추천 여행지**: ").append(compatibility.getRecommendedDestinations()).append("\n\n");
        
        // 매칭된 여행계획 표시
        if (matchingPlans.isEmpty()) {
            response.append("😅 현재 호환되는 MBTI(").append(compatibility.getMbtiType2()).append(") 사용자들의 활성 여행계획이 없습니다.\n");
            response.append("조금 후에 다시 확인해보시거나, 직접 여행계획을 올려서 다른 사용자들과 매칭되어 보세요! 🚀");
        } else {
            response.append("🎉 **당신과 잘 맞는 여행 파트너들을 찾았어요!**\n\n");
            
            for (int i = 0; i < matchingPlans.size(); i++) {
                TravelPlanDTO plan = matchingPlans.get(i);
                MemberDTO planWriter = memberDAO.getMemberById(plan.getPlanWriter());
                
                response.append("**").append(i + 1).append(". ").append(plan.getPlanTitle()).append("**\n");
                response.append("👤 작성자: ").append(planWriter.getUserName()).append(" (").append(compatibility.getMbtiType2()).append(" 타입)\n");
                response.append("📍 여행지: ").append(plan.getPlanDestination()).append("\n");
                response.append("💰 예산: ").append(String.format("%,d", plan.getPlanBudget())).append("원\n");
                response.append("📅 일정: ").append(plan.getPlanStartDate()).append(" ~ ").append(plan.getPlanEndDate()).append("\n");
                
                if (plan.getPlanTags() != null && !plan.getPlanTags().isEmpty()) {
                    response.append("🏷️ 태그: ").append(plan.getPlanTags()).append("\n");
                }
                
                // 여행계획 상세보기 링크
                response.append("🔍 <a href='/travel/detail/").append(plan.getPlanId()).append("' class='travel-detail-link' target='_blank'>**상세보기 →**</a>\n\n");
                
                response.append("---\n");
            }
            
            response.append("\n💡 **매칭 팁**: 위 여행계획들을 자세히 보시고, 마음에 드는 계획이 있다면 동행 신청을 해보세요!\n");
            response.append("🤝 ").append(userMbti).append(" 타입인 당신과 ").append(compatibility.getMbtiType2()).append(" 타입의 파트너는 ").append(compatibility.getTravelStyleBalance()).append(" 조합으로 환상적인 여행을 만들어낼 수 있을 거예요! ✈️");
        }
        
        // 상세한 매칭 이유 코멘트 추가
        response.append("\n\n");
        response.append("📝 **왜 이런 매칭을 추천했나요?**\n\n");
        response.append(generateDetailedMatchingReason(userMbti, compatibility.getMbtiType2()));
        
        // AI 생성 정보 면책 고지사항 추가
        response.append("\n\n");
        response.append("---\n");
        response.append("<small style='color: #666; font-size: 0.8em;'>");
        response.append("본 내용은 AI를 통해 생성된 요약 정보로, 사용자의 편의를 돕기 위해 제공됩니다. ");
        response.append("다만, 현지 사정으로 인해 운영시간이나 요금 등은 실시간으로 변경될 수 있으니, 방문 전 공식 채널을 통해 최신 정보를 확인하시는 것을 권장합니다. ");
        response.append("AI가 생성한 정보이므로, 참고용으로 활용하시고 중요한 내용은 공식 홈페이지 등에서 반드시 직접 확인해주세요.");
        response.append("</small>");
        
        return new AiChatResponseDTO(response.toString());
    }
    
    // 상세한 매칭 이유 생성 메서드
    private String generateDetailedMatchingReason(String userMbti, String matchMbti) {
        StringBuilder reason = new StringBuilder();
        
        // 각 MBTI 타입별 특성 분석
        char userPlanning = userMbti.charAt(0);  // P or J
        char userActivity = userMbti.charAt(1);  // A or C
        char userIntrovert = userMbti.charAt(2); // I or G
        char userBudget = userMbti.charAt(3);    // B or L
        
        char matchPlanning = matchMbti.charAt(0);
        char matchActivity = matchMbti.charAt(1);
        char matchIntrovert = matchMbti.charAt(2);
        char matchBudget = matchMbti.charAt(3);
        
        // 계획성 측면
        if (userPlanning == 'P' && matchPlanning == 'J') {
            reason.append("🗓️ **계획성 균형**: 당신의 자유로운 여행 스타일과 파트너의 체계적인 계획이 만나 완벽한 균형을 이룹니다. ");
            reason.append("당신은 즉흥적인 재미를 더하고, 파트너는 안정적인 일정을 잡아줄 거예요.\n\n");
        } else if (userPlanning == 'J' && matchPlanning == 'P') {
            reason.append("🗓️ **계획성 균형**: 당신의 체계적인 계획과 파트너의 유연한 대처가 조화를 이룹니다. ");
            reason.append("예상치 못한 상황에서도 즐거운 여행이 될 거예요.\n\n");
        } else if (userPlanning == matchPlanning) {
            reason.append("🗓️ **계획성 일치**: 비슷한 여행 준비 스타일로 서로 편안하게 여행을 준비할 수 있어요. ");
            reason.append("계획 단계부터 스트레스 없이 즐거운 여행이 될 거예요.\n\n");
        }
        
        // 활동성 측면
        if (userActivity == 'A' && matchActivity == 'C') {
            reason.append("⚡ **활동성 보완**: 당신의 활발한 에너지와 파트너의 여유로운 스타일이 서로를 보완합니다. ");
            reason.append("액티비티와 휴식의 완벽한 밸런스를 경험하세요.\n\n");
        } else if (userActivity == 'C' && matchActivity == 'A') {
            reason.append("⚡ **활동성 보완**: 당신의 편안한 여행 스타일에 파트너가 활력을 더해줄 거예요. ");
            reason.append("새로운 경험과 편안한 휴식을 모두 즐길 수 있습니다.\n\n");
        } else if (userActivity == 'A' && matchActivity == 'A') {
            reason.append("⚡ **활동성 시너지**: 둘 다 활발한 성향으로 다양한 액티비티를 함께 즐길 수 있어요. ");
            reason.append("에너지 넘치는 모험적인 여행이 될 거예요.\n\n");
        } else {
            reason.append("⚡ **활동성 조화**: 둘 다 여유로운 성향으로 편안하고 힐링되는 여행을 즐길 수 있어요. ");
            reason.append("서로의 페이스를 존중하며 스트레스 없는 여행이 가능합니다.\n\n");
        }
        
        // 사교성 측면
        if (userIntrovert == 'I' && matchIntrovert == 'G') {
            reason.append("👥 **사교성 균형**: 개인 시간을 중시하는 당신과 그룹 활동을 좋아하는 파트너가 균형을 이룹니다. ");
            reason.append("새로운 사람들과의 만남도 부담 없이 즐길 수 있어요.\n\n");
        } else if (userIntrovert == 'G' && matchIntrovert == 'I') {
            reason.append("👥 **사교성 균형**: 사교적인 당신과 독립적인 파트너가 서로를 보완합니다. ");
            reason.append("때로는 함께, 때로는 각자의 시간을 가지며 여행할 수 있어요.\n\n");
        } else if (userIntrovert == 'I' && matchIntrovert == 'I') {
            reason.append("👥 **사교성 일치**: 둘 다 독립적인 성향으로 서로의 공간을 존중하며 편안한 여행이 가능해요. ");
            reason.append("조용하고 깊이 있는 여행을 즐길 수 있습니다.\n\n");
        } else {
            reason.append("👥 **사교성 시너지**: 둘 다 사교적인 성향으로 현지인들과 교류하며 풍성한 여행이 될 거예요. ");
            reason.append("함께 새로운 친구들을 만들고 다양한 경험을 공유할 수 있습니다.\n\n");
        }
        
        // 예산 스타일
        if (userBudget == 'B' && matchBudget == 'L') {
            reason.append("💰 **예산 균형**: 가성비를 중시하는 당신과 편안함을 추구하는 파트너가 적절한 타협점을 찾을 수 있어요. ");
            reason.append("합리적이면서도 만족스러운 여행이 될 거예요.\n");
        } else if (userBudget == 'L' && matchBudget == 'B') {
            reason.append("💰 **예산 균형**: 럭셔리를 즐기는 당신과 실속 있는 파트너가 균형을 맞춰요. ");
            reason.append("특별한 경험과 알뜰한 선택을 모두 경험할 수 있습니다.\n");
        } else if (userBudget == 'B' && matchBudget == 'B') {
            reason.append("💰 **예산 일치**: 둘 다 가성비를 중시해 예산 걱정 없이 알찬 여행을 즐길 수 있어요. ");
            reason.append("현지 맛집과 숨은 명소들을 함께 발견하는 재미가 있을 거예요.\n");
        } else {
            reason.append("💰 **예산 시너지**: 둘 다 여유로운 예산으로 품격 있는 여행을 즐길 수 있어요. ");
            reason.append("특별한 경험과 프리미엄 서비스를 함께 만끽하세요.\n");
        }
        
        // 종합 코멘트
        reason.append("\n🌟 **종합 평가**: ");
        reason.append(userMbti).append(" 타입과 ").append(matchMbti).append(" 타입은 ");
        
        // 보완적 관계인지 유사한 관계인지 판단
        int differences = 0;
        if (userPlanning != matchPlanning) differences++;
        if (userActivity != matchActivity) differences++;
        if (userIntrovert != matchIntrovert) differences++;
        if (userBudget != matchBudget) differences++;
        
        if (differences >= 3) {
            reason.append("서로 다른 매력으로 완벽하게 보완하는 관계입니다. ");
            reason.append("각자의 강점을 살려 더욱 풍성한 여행 경험을 만들어낼 수 있어요!");
        } else if (differences >= 1) {
            reason.append("적절한 공통점과 차이점을 가진 이상적인 여행 파트너입니다. ");
            reason.append("서로를 이해하면서도 새로운 시각을 제공할 수 있는 관계예요!");
        } else {
            reason.append("매우 유사한 여행 스타일로 편안하고 조화로운 여행이 가능합니다. ");
            reason.append("서로를 깊이 이해하며 스트레스 없는 여행을 즐길 수 있어요!");
        }
        
        return reason.toString();
    }
    
    // 목적지 키워드를 사용자 친화적인 이름으로 변환
    private String getDestinationDisplayName(String destination) {
        switch (destination) {
            case "일본": return "일본";
            case "동남아": return "동남아시아";
            case "유럽": return "유럽";
            case "국내": return "국내";
            default: return destination;
        }
    }
}