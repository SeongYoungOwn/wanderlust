package com.tour.project.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.jdbc.core.JdbcTemplate;

import com.tour.project.dao.MannerEvaluationDAO;
import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.MannerEvaluationDTO;
import com.tour.project.dto.UserMannerStatsDTO;
import com.tour.project.dto.MemberDTO;

import javax.servlet.http.HttpSession;
import java.util.*;

@Controller
public class MannerEvaluationController {
    
    @Autowired
    private MannerEvaluationDAO mannerEvaluationDAO;
    
    @Autowired
    private MemberDAO memberDAO;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    // 여행 완료 처리 (작성자만 가능)
    @PostMapping("/travel/complete/{planId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> completeTravelPlan(
            @PathVariable int planId,
            HttpSession session) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(result);
            }
            
            String userId = loginUser.getUserId();
            
            // 여행 작성자인지 확인
            if (!mannerEvaluationDAO.isTravelAuthor(planId, userId)) {
                result.put("success", false);
                result.put("message", "여행 작성자만 동행을 종료할 수 있습니다.");
                return ResponseEntity.status(403).body(result);
            }
            
            // 이미 완료된 여행인지 확인
            if (mannerEvaluationDAO.isTravelCompleted(planId)) {
                result.put("success", false);
                result.put("message", "이미 완료된 여행입니다.");
                return ResponseEntity.badRequest().body(result);
            }
            
            // 여행 완료 처리
            int updated = mannerEvaluationDAO.completeTravelPlan(planId, userId);
            
            if (updated > 0) {
                result.put("success", true);
                result.put("message", "동행이 성공적으로 종료되었습니다. 이제 참여자들과 서로 매너 평가를 남길 수 있습니다.");
            } else {
                result.put("success", false);
                result.put("message", "동행 종료에 실패했습니다. 다시 시도해주세요.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "시스템 오류가 발생했습니다.");
        }
        
        return ResponseEntity.ok(result);
    }
    
    // 매너 평가 페이지 (완료된 여행의 참여자들만)
    @GetMapping("/manner/evaluate/{planId}")
    public String evaluatePage(@PathVariable int planId, HttpSession session, Model model) {
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            return "redirect:/member/login";
        }
        
        String userId = loginUser.getUserId();
        
        try {
            System.out.println("=== 매너 평가 페이지 접근 ===");
            System.out.println("planId: " + planId);
            System.out.println("userId: " + userId);
            
            // 여행이 완료되었는지 확인
            boolean isCompleted = mannerEvaluationDAO.isTravelCompleted(planId);
            System.out.println("여행 완료 상태: " + isCompleted);
            
            if (!isCompleted) {
                return "redirect:/travel/detail/" + planId + "?error=notCompleted";
            }
            
            // 평가 가능한 사용자 목록 조회 (아직 평가하지 않은 사용자)
            List<String> evaluatableUsers = mannerEvaluationDAO.getEvaluatableUsers(planId, userId);
            System.out.println("평가 가능한 사용자 목록: " + evaluatableUsers);
            
            // 모든 참여자 조회 (평가 완료된 사용자 포함)
            List<String> allParticipants = getAllParticipants(planId, userId);
            System.out.println("모든 참여자 목록: " + allParticipants);
            
            // 이미 평가한 사용자 조회
            List<String> evaluatedUsers = new ArrayList<>();
            for (String participantId : allParticipants) {
                if (!evaluatableUsers.contains(participantId)) {
                    evaluatedUsers.add(participantId);
                }
            }
            System.out.println("이미 평가한 사용자 목록: " + evaluatedUsers);
            
            // 모든 참여자의 사용자 정보 조회
            Map<String, MemberDTO> userMap = new HashMap<>();
            for (String evalUserId : allParticipants) {
                try {
                    MemberDTO member = memberDAO.getMember(evalUserId);
                    if (member != null) {
                        userMap.put(evalUserId, member);
                    }
                } catch (Exception e) {
                    System.err.println("사용자 정보 조회 실패 (ID: " + evalUserId + "): " + e.getMessage());
                }
            }
            
            model.addAttribute("planId", planId);
            model.addAttribute("evaluatableUsers", evaluatableUsers);
            model.addAttribute("evaluatedUsers", evaluatedUsers);
            model.addAttribute("allParticipants", allParticipants);
            model.addAttribute("userMap", userMap);
            model.addAttribute("evaluatorId", userId);
            
            return "manner/evaluate";
            
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("error", "매너 평가 페이지 로드 중 오류가 발생했습니다: " + e.getMessage());
            return "error/500";
        }
    }
    
    
    // 매너 평가 제출
    @PostMapping(value = "/manner/evaluate", consumes = "application/json", produces = "application/json")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> submitEvaluation(
            @RequestBody MannerEvaluationDTO evaluation,
            HttpSession session) {
        
        System.out.println("#### 매너 평가 컨트롤러 진입 ####");
        Map<String, Object> result = new HashMap<>();
        
        try {
            System.out.println("=== 매너 평가 제출 시작 ===");
            System.out.println("Evaluation 객체: " + (evaluation != null ? "있음" : "null"));
            
            if (evaluation == null) {
                System.out.println("Evaluation 객체가 null입니다");
                result.put("success", false);
                result.put("message", "평가 데이터가 전송되지 않았습니다.");
                return ResponseEntity.badRequest().body(result);
            }
            
            // 필수 필드 검증
            if (evaluation.getTravelPlanId() <= 0) {
                System.out.println("여행 계획 ID가 유효하지 않습니다: " + evaluation.getTravelPlanId());
                result.put("success", false);
                result.put("message", "여행 계획 ID가 유효하지 않습니다.");
                return ResponseEntity.badRequest().body(result);
            }
            
            if (evaluation.getEvaluatedId() == null || evaluation.getEvaluatedId().trim().isEmpty()) {
                System.out.println("평가 대상 ID가 유효하지 않습니다: " + evaluation.getEvaluatedId());
                result.put("success", false);
                result.put("message", "평가 대상이 지정되지 않았습니다.");
                return ResponseEntity.badRequest().body(result);
            }
            
            if (evaluation.getMannerScore() < 0 || evaluation.getMannerScore() > 1000) {
                System.out.println("매너 점수가 유효하지 않습니다: " + evaluation.getMannerScore());
                result.put("success", false);
                result.put("message", "매너 점수가 유효하지 않습니다.");
                return ResponseEntity.badRequest().body(result);
            }
            
            MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
            System.out.println("로그인 사용자: " + (loginUser != null ? loginUser.getUserId() : "null"));
            
            if (loginUser == null) {
                System.out.println("로그인 사용자 없음 - 401 반환");
                result.put("success", false);
                result.put("message", "로그인이 필요합니다.");
                return ResponseEntity.status(401).body(result);
            }
            
            String userId = loginUser.getUserId();
            evaluation.setEvaluatorId(userId);
            
            System.out.println("평가 데이터: planId=" + evaluation.getTravelPlanId() + 
                              ", evaluator=" + evaluation.getEvaluatorId() + 
                              ", evaluated=" + evaluation.getEvaluatedId() +
                              ", score=" + evaluation.getMannerScore() +
                              ", isLike=" + evaluation.getIsLike());
            
            // 평가 권한 체크
            System.out.println("평가 권한 체크 시작...");
            boolean canEvaluate = mannerEvaluationDAO.canEvaluate(
                    evaluation.getTravelPlanId(), 
                    evaluation.getEvaluatorId(), 
                    evaluation.getEvaluatedId());
            System.out.println("평가 권한 체크 결과: " + canEvaluate);
            
            if (!canEvaluate) {
                System.out.println("평가 권한 없음 - 403 반환");
                result.put("success", false);
                result.put("message", "평가 권한이 없습니다.");
                return ResponseEntity.status(403).body(result);
            }
            
            // 카테고리 기반 평가인지 확인하고 점수 계산
            if (evaluation.getEvaluationType() != null && evaluation.getEvaluationCategory() != null) {
                System.out.println("카테고리 기반 평가 처리 중...");
                int scoreChange = calculateScoreByCategory(evaluation.getEvaluationType(), evaluation.getEvaluationCategory());
                System.out.println("카테고리별 점수 변화량: " + scoreChange);
                
                // 현재 사용자의 평균 매너 점수 조회
                UserMannerStatsDTO stats = mannerEvaluationDAO.getUserMannerStats(evaluation.getEvaluatedId());
                if (stats == null) {
                    stats = new UserMannerStatsDTO(evaluation.getEvaluatedId());
                    mannerEvaluationDAO.insertUserMannerStats(stats);
                }
                
                int currentScore = (int)(stats.getAverageMannerScore() * 10);
                int newScore = Math.max(0, Math.min(1000, currentScore + scoreChange));
                
                evaluation.setMannerScore(newScore);
                System.out.println("기존 점수: " + currentScore + " → 새 점수: " + newScore);
            }

            // 기존 평가가 있는지 확인
            System.out.println("기존 평가 조회 시작...");
            MannerEvaluationDTO existingEvaluation = mannerEvaluationDAO.getEvaluationByIds(
                    evaluation.getTravelPlanId(),
                    evaluation.getEvaluatorId(),
                    evaluation.getEvaluatedId());
            System.out.println("기존 평가 조회 결과: " + (existingEvaluation != null ? "있음" : "없음"));
            
            int affected;
            if (existingEvaluation != null) {
                // 기존 평가 수정
                System.out.println("기존 평가 수정 시작...");
                evaluation.setEvaluationId(existingEvaluation.getEvaluationId());
                affected = mannerEvaluationDAO.updateEvaluation(evaluation);
                System.out.println("기존 평가 수정 결과: " + affected);
            } else {
                // 새 평가 생성
                System.out.println("새 평가 생성 시작...");
                affected = mannerEvaluationDAO.insertEvaluation(evaluation);
                System.out.println("새 평가 생성 결과: " + affected);
            }
            
            if (affected > 0) {
                // 사용자 매너 통계 재계산
                System.out.println("매너 통계 재계산 시작...");
                mannerEvaluationDAO.recalculateUserStats(evaluation.getEvaluatedId());
                System.out.println("매너 통계 재계산 완료");
                
                result.put("success", true);
                result.put("message", "매너 평가가 성공적으로 제출되었습니다.");
            } else {
                result.put("success", false);
                result.put("message", "매너 평가 제출에 실패했습니다.");
            }
            
        } catch (IllegalArgumentException e) {
            System.err.println("=== 잘못된 매개변수 예외 ===");
            System.err.println("예외 메시지: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "입력 데이터가 올바르지 않습니다: " + e.getMessage());
            return ResponseEntity.badRequest().body(result);
        } catch (Exception e) {
            System.err.println("=== 매너 평가 제출 중 예외 발생 ===");
            System.err.println("예외 타입: " + e.getClass().getSimpleName());
            System.err.println("예외 메시지: " + e.getMessage());
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "시스템 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(500).body(result);
        }
        
        return ResponseEntity.ok(result);
    }
    
    // 특정 여행의 평가 목록 조회
    @GetMapping("/manner/evaluations/{planId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getEvaluations(@PathVariable int planId) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            List<MannerEvaluationDTO> evaluations = mannerEvaluationDAO.getEvaluationsByTravelPlan(planId);
            
            result.put("success", true);
            result.put("evaluations", evaluations);
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "평가 목록 조회에 실패했습니다.");
        }
        
        return ResponseEntity.ok(result);
    }
    
    // 사용자 매너 통계 조회
    @GetMapping("/manner/stats/{userId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getUserStats(@PathVariable String userId) {
        
        Map<String, Object> result = new HashMap<>();
        
        try {
            UserMannerStatsDTO stats = mannerEvaluationDAO.getUserMannerStats(userId);
            
            if (stats == null) {
                // 통계가 없으면 기본값으로 생성
                stats = new UserMannerStatsDTO(userId);
                mannerEvaluationDAO.insertUserMannerStats(stats);
            }
            
            result.put("success", true);
            result.put("stats", stats);
            
        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "매너 통계 조회에 실패했습니다.");
        }
        
        return ResponseEntity.ok(result);
    }
    
    // API: 사용자 매너 평가 데이터 조회 (AJAX용)
    @GetMapping("/manner/api/evaluations/{userId}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> getUserEvaluationsData(@PathVariable String userId) {

        Map<String, Object> result = new HashMap<>();

        try {
            // 받은 평가 목록
            List<MannerEvaluationDTO> receivedEvaluations =
                mannerEvaluationDAO.getEvaluationsByEvaluated(userId);

            // 내가 한 평가 목록
            List<MannerEvaluationDTO> givenEvaluations =
                mannerEvaluationDAO.getEvaluationsByEvaluator(userId);

            // 매너 통계
            UserMannerStatsDTO stats = mannerEvaluationDAO.getUserMannerStats(userId);

            if (stats == null) {
                stats = new UserMannerStatsDTO(userId);
                try {
                    mannerEvaluationDAO.insertUserMannerStats(stats);
                } catch (Exception e) {
                    // 이미 존재하는 경우 무시
                }
            }

            // null 체크 및 기본값 설정
            if (receivedEvaluations == null) {
                receivedEvaluations = new ArrayList<>();
            }
            if (givenEvaluations == null) {
                givenEvaluations = new ArrayList<>();
            }

            result.put("success", true);
            result.put("receivedEvaluations", receivedEvaluations);
            result.put("givenEvaluations", givenEvaluations);
            result.put("mannerStats", stats);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("success", false);
            result.put("message", "매너 평가 데이터 조회 중 오류가 발생했습니다.");
        }

        return ResponseEntity.ok(result);
    }

    // 내가 받은 평가 목록
    @GetMapping("/manner/my-evaluations")
    public String myEvaluations(HttpSession session, Model model) {
        
        System.out.println("=== 내 매너 평가 페이지 접근 ===");
        
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            System.out.println("로그인 사용자 없음 - 로그인 페이지로 리다이렉트");
            return "redirect:/member/login";
        }
        
        String userId = loginUser.getUserId();
        System.out.println("사용자 ID: " + userId);
        
        try {
            System.out.println("내가 받은 평가 목록 조회 시작...");
            // 내가 받은 평가들
            List<MannerEvaluationDTO> receivedEvaluations = 
                mannerEvaluationDAO.getEvaluationsByEvaluated(userId);
            System.out.println("내가 받은 평가 개수: " + (receivedEvaluations != null ? receivedEvaluations.size() : "null"));
            
            System.out.println("내가 한 평가 목록 조회 시작...");
            // 내가 한 평가들
            List<MannerEvaluationDTO> givenEvaluations = 
                mannerEvaluationDAO.getEvaluationsByEvaluator(userId);
            System.out.println("내가 한 평가 개수: " + (givenEvaluations != null ? givenEvaluations.size() : "null"));
            
            System.out.println("매너 통계 조회 시작...");
            // 매너 통계
            UserMannerStatsDTO stats = mannerEvaluationDAO.getUserMannerStats(userId);
            System.out.println("매너 통계 조회 결과: " + (stats != null ? "있음" : "없음"));
            
            if (stats == null) {
                System.out.println("매너 통계가 없어서 새로 생성 중...");
                stats = new UserMannerStatsDTO(userId);
                try {
                    mannerEvaluationDAO.insertUserMannerStats(stats);
                    System.out.println("새 매너 통계 생성 완료");
                } catch (Exception insertEx) {
                    System.err.println("매너 통계 생성 실패: " + insertEx.getMessage());
                    insertEx.printStackTrace();
                }
            }
            
            // 데이터가 null인 경우 빈 리스트로 초기화
            if (receivedEvaluations == null) {
                System.out.println("받은 평가 목록이 null이므로 빈 리스트로 초기화");
                receivedEvaluations = new java.util.ArrayList<>();
            }
            if (givenEvaluations == null) {
                System.out.println("한 평가 목록이 null이므로 빈 리스트로 초기화");
                givenEvaluations = new java.util.ArrayList<>();
            }
            if (stats == null) {
                System.out.println("매너 통계가 여전히 null이므로 기본값으로 생성");
                stats = new UserMannerStatsDTO(userId);
            }
            
            model.addAttribute("receivedEvaluations", receivedEvaluations);
            model.addAttribute("givenEvaluations", givenEvaluations);
            model.addAttribute("mannerStats", stats);
            
            System.out.println("=== 매너 평가 페이지 데이터 준비 완료 ===");
            return "manner/my-evaluations";
            
        } catch (Exception e) {
            System.err.println("=== 매너 평가 페이지 오류 발생 ===");
            System.err.println("오류 타입: " + e.getClass().getSimpleName());
            System.err.println("오류 메시지: " + e.getMessage());
            e.printStackTrace();
            model.addAttribute("error", "매너 평가 조회 중 오류가 발생했습니다: " + e.getMessage());
            return "error/500";
        }
    }
    
    // Database Schema Verification Endpoint
    @GetMapping("/api/database/verify-schema")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> verifyDatabaseSchema() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 1. Check manner_evaluation table
            result.put("manner_evaluation", verifyMannerEvaluationTable());
            
            // 2. Check user_manner_stats table
            result.put("user_manner_stats", verifyUserMannerStatsTable());
            
            // 3. Check travel_plan table status columns
            result.put("travel_plan", verifyTravelPlanTable());
            
            result.put("status", "SUCCESS");
            result.put("message", "Database schema verification completed");
            
        } catch (Exception e) {
            result.put("status", "ERROR");
            result.put("message", "Error during schema verification: " + e.getMessage());
            result.put("error", e.getClass().getSimpleName());
        }
        
        return ResponseEntity.ok(result);
    }
    
    private Map<String, Object> verifyMannerEvaluationTable() {
        Map<String, Object> tableInfo = new HashMap<>();
        
        try {
            // Check if table exists
            String checkTableQuery = "SELECT COUNT(*) " +
                "FROM information_schema.tables " +
                "WHERE table_schema = DATABASE() " +
                "AND table_name = 'manner_evaluation'";
            
            Integer tableCount = jdbcTemplate.queryForObject(checkTableQuery, Integer.class);
            tableInfo.put("exists", tableCount > 0);
            
            if (tableCount > 0) {
                // Get column information
                String columnQuery = "SELECT column_name, data_type, is_nullable, column_default, extra " +
                    "FROM information_schema.columns " +
                    "WHERE table_schema = DATABASE() " +
                    "AND table_name = 'manner_evaluation' " +
                    "ORDER BY ordinal_position";
                
                List<Map<String, Object>> columns = jdbcTemplate.queryForList(columnQuery);
                tableInfo.put("columns", columns);
                
                // Check expected columns
                Set<String> expectedColumns = Set.of(
                    "evaluation_id", "travel_plan_id", "evaluator_id", "evaluated_id",
                    "manner_score", "is_like", "evaluation_comment", "created_date", "updated_date"
                );
                
                Set<String> actualColumns = new HashSet<>();
                for (Map<String, Object> column : columns) {
                    actualColumns.add((String) column.get("column_name"));
                }
                
                tableInfo.put("expected_columns", expectedColumns);
                tableInfo.put("actual_columns", actualColumns);
                tableInfo.put("missing_columns", getMissingColumns(expectedColumns, actualColumns));
                tableInfo.put("extra_columns", getExtraColumns(expectedColumns, actualColumns));
                
                // Get record count
                String countQuery = "SELECT COUNT(*) FROM manner_evaluation";
                Integer recordCount = jdbcTemplate.queryForObject(countQuery, Integer.class);
                tableInfo.put("record_count", recordCount);
            }
            
        } catch (Exception e) {
            tableInfo.put("error", e.getMessage());
        }
        
        return tableInfo;
    }
    
    private Map<String, Object> verifyUserMannerStatsTable() {
        Map<String, Object> tableInfo = new HashMap<>();
        
        try {
            // Check if table exists
            String checkTableQuery = "SELECT COUNT(*) " +
                "FROM information_schema.tables " +
                "WHERE table_schema = DATABASE() " +
                "AND table_name = 'user_manner_stats'";
            
            Integer tableCount = jdbcTemplate.queryForObject(checkTableQuery, Integer.class);
            tableInfo.put("exists", tableCount > 0);
            
            if (tableCount > 0) {
                // Get column information
                String columnQuery = "SELECT column_name, data_type, is_nullable, column_default, extra " +
                    "FROM information_schema.columns " +
                    "WHERE table_schema = DATABASE() " +
                    "AND table_name = 'user_manner_stats' " +
                    "ORDER BY ordinal_position";
                
                List<Map<String, Object>> columns = jdbcTemplate.queryForList(columnQuery);
                tableInfo.put("columns", columns);
                
                // Check expected columns
                Set<String> expectedColumns = Set.of(
                    "user_id", "total_evaluations", "average_manner_score", "total_likes", 
                    "total_dislikes", "completed_travels", "last_updated"
                );
                
                Set<String> actualColumns = new HashSet<>();
                for (Map<String, Object> column : columns) {
                    actualColumns.add((String) column.get("column_name"));
                }
                
                tableInfo.put("expected_columns", expectedColumns);
                tableInfo.put("actual_columns", actualColumns);
                tableInfo.put("missing_columns", getMissingColumns(expectedColumns, actualColumns));
                tableInfo.put("extra_columns", getExtraColumns(expectedColumns, actualColumns));
                
                // Get record count
                String countQuery = "SELECT COUNT(*) FROM user_manner_stats";
                Integer recordCount = jdbcTemplate.queryForObject(countQuery, Integer.class);
                tableInfo.put("record_count", recordCount);
            }
            
        } catch (Exception e) {
            tableInfo.put("error", e.getMessage());
        }
        
        return tableInfo;
    }
    
    private Map<String, Object> verifyTravelPlanTable() {
        Map<String, Object> tableInfo = new HashMap<>();
        
        try {
            // Check if table exists
            String checkTableQuery = "SELECT COUNT(*) " +
                "FROM information_schema.tables " +
                "WHERE table_schema = DATABASE() " +
                "AND table_name = 'travel_plan'";
            
            Integer tableCount = jdbcTemplate.queryForObject(checkTableQuery, Integer.class);
            tableInfo.put("exists", tableCount > 0);
            
            if (tableCount > 0) {
                // Get column information
                String columnQuery = "SELECT column_name, data_type, is_nullable, column_default, extra " +
                    "FROM information_schema.columns " +
                    "WHERE table_schema = DATABASE() " +
                    "AND table_name = 'travel_plan' " +
                    "ORDER BY ordinal_position";
                
                List<Map<String, Object>> columns = jdbcTemplate.queryForList(columnQuery);
                tableInfo.put("all_columns", columns.size());
                
                // Check for required status columns
                Set<String> requiredColumns = Set.of("plan_status", "completed_date");
                
                Set<String> actualColumns = new HashSet<>();
                Map<String, Object> statusColumnDetails = new HashMap<>();
                for (Map<String, Object> column : columns) {
                    String columnName = (String) column.get("column_name");
                    actualColumns.add(columnName);
                    if (requiredColumns.contains(columnName)) {
                        statusColumnDetails.put(columnName, column);
                    }
                }
                
                tableInfo.put("required_status_columns", requiredColumns);
                tableInfo.put("has_plan_status", actualColumns.contains("plan_status"));
                tableInfo.put("has_completed_date", actualColumns.contains("completed_date"));
                tableInfo.put("missing_status_columns", getMissingColumns(requiredColumns, actualColumns));
                tableInfo.put("status_column_details", statusColumnDetails);
                
                // Get record count and status distribution
                String countQuery = "SELECT COUNT(*) FROM travel_plan";
                Integer recordCount = jdbcTemplate.queryForObject(countQuery, Integer.class);
                tableInfo.put("record_count", recordCount);
                
                if (actualColumns.contains("plan_status")) {
                    String statusQuery = "SELECT plan_status, COUNT(*) as count " +
                        "FROM travel_plan " +
                        "GROUP BY plan_status";
                    List<Map<String, Object>> statusDistribution = jdbcTemplate.queryForList(statusQuery);
                    tableInfo.put("status_distribution", statusDistribution);
                }
            }
            
        } catch (Exception e) {
            tableInfo.put("error", e.getMessage());
        }
        
        return tableInfo;
    }
    
    private Set<String> getMissingColumns(Set<String> expected, Set<String> actual) {
        Set<String> missing = new HashSet<>(expected);
        missing.removeAll(actual);
        return missing;
    }
    
    private Set<String> getExtraColumns(Set<String> expected, Set<String> actual) {
        Set<String> extra = new HashSet<>(actual);
        extra.removeAll(expected);
        return extra;
    }
    
    // 모든 참여자 조회 (평가 완료 여부 상관없이)
    private List<String> getAllParticipants(int planId, String evaluatorId) {
        List<String> allParticipants = new ArrayList<>();
        
        try {
            // 승인된 참여자들 조회
            String query = "SELECT DISTINCT tjr.requester_id " +
                          "FROM travel_join_requests tjr " +
                          "WHERE tjr.travel_plan_id = ? " +
                          "  AND tjr.requester_id != ? " +
                          "  AND tjr.status = 'APPROVED' " +
                          "UNION " +
                          "SELECT plan.plan_writer " +
                          "FROM travel_plan plan " +
                          "WHERE plan.plan_id = ? " +
                          "  AND plan.plan_writer != ?";
            
            List<Map<String, Object>> results = jdbcTemplate.queryForList(query, planId, evaluatorId, planId, evaluatorId);
            
            for (Map<String, Object> row : results) {
                String userId = (String) row.get("requester_id");
                if (userId == null) {
                    userId = (String) row.get("plan_writer");
                }
                if (userId != null) {
                    allParticipants.add(userId);
                }
            }
            
        } catch (Exception e) {
            System.err.println("모든 참여자 조회 중 오류: " + e.getMessage());
            e.printStackTrace();
        }
        
        return allParticipants;
    }
    
    
    // 카테고리별 점수 변화량 계산 메서드
    private int calculateScoreByCategory(String type, String category) {
        if ("POSITIVE".equals(type)) {
            switch (category) {
                case "시간약속": return 20;
                case "친절함": return 20;
                case "빠른응답": return 15;
                case "계획력": return 20;
                case "배려심": return 25;
                case "재동행": return 30;
                default: return 15;
            }
        } else if ("NEGATIVE".equals(type)) {
            switch (category) {
                case "시간미준수": return -30;
                case "불친절": return -40;
                case "늦은응답": return -20;
                case "즉흥적": return -20;
                case "이기적": return -30;
                case "비추천": return -50;
                default: return -20;
            }
        }
        return 0;
    }
}