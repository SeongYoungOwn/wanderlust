package com.tour.project.controller;

import com.tour.project.vo.TravelChecklistVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.sql.Timestamp;
import java.util.*;

@Controller
@RequestMapping("/travel/checklist")
public class ChecklistController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 초기화 시 테이블 확인 및 생성
    @javax.annotation.PostConstruct
    public void init() {
        try {
            // 테이블 존재 확인
            String checkTableSql = "CREATE TABLE IF NOT EXISTS travel_checklist (" +
                "checklist_id INT PRIMARY KEY AUTO_INCREMENT, " +
                "plan_id BIGINT NOT NULL, " +
                "user_id VARCHAR(50) NOT NULL, " +
                "item_name VARCHAR(200) NOT NULL, " +
                "is_completed BOOLEAN DEFAULT FALSE, " +
                "created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "completed_date TIMESTAMP NULL, " +
                "item_order INT DEFAULT 0, " +
                "INDEX idx_plan_user (plan_id, user_id), " +
                "INDEX idx_user_plan (user_id, plan_id))";
            jdbcTemplate.execute(checkTableSql);
        } catch (Exception e) {
            System.err.println("체크리스트 테이블 초기화 오류: " + e.getMessage());
        }
    }

    @GetMapping("/{planId}")
    @ResponseBody
    public Map<String, Object> getChecklist(@PathVariable Long planId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 로그인 사용자 정보 가져오기
            com.tour.project.dto.MemberDTO loginUser = (com.tour.project.dto.MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            String userId = loginUser.getUserId();

            // 체크리스트 조회
            String sql = "SELECT checklist_id, item_name, is_completed, created_date, item_order " +
                        "FROM travel_checklist " +
                        "WHERE plan_id = ? AND user_id = ? " +
                        "ORDER BY item_order, created_date";

            List<Map<String, Object>> checklist = jdbcTemplate.queryForList(sql, planId, userId);

            // 체크리스트가 없으면 기본 항목 생성
            if (checklist.isEmpty()) {
                String[] defaultItems = {
                    "여권 / 신분증",
                    "항공권 / 기차표",
                    "숙소 예약 확인서",
                    "여행자 보험",
                    "현금 / 카드",
                    "충전기 / 보조배터리",
                    "세면도구",
                    "여분 옷",
                    "상비약",
                    "카메라"
                };

                for (int i = 0; i < defaultItems.length; i++) {
                    String insertSql = "INSERT INTO travel_checklist (plan_id, user_id, item_name, is_completed, created_date, item_order) " +
                                      "VALUES (?, ?, ?, 0, NOW(), ?)";
                    jdbcTemplate.update(insertSql, planId, userId, defaultItems[i], i + 1);
                }

                // 다시 조회
                checklist = jdbcTemplate.queryForList(sql, planId, userId);
            }

            // 완료율 계산
            int total = checklist.size();
            int completed = 0;
            for (Map<String, Object> item : checklist) {
                if (Boolean.TRUE.equals(item.get("is_completed"))) {
                    completed++;
                }
            }
            double completionRate = total > 0 ? (completed * 100.0 / total) : 0;

            // 응답 데이터 구성
            List<Map<String, Object>> checklistData = new ArrayList<>();
            for (Map<String, Object> item : checklist) {
                Map<String, Object> checkItem = new HashMap<>();
                checkItem.put("checklistId", item.get("checklist_id"));
                checkItem.put("itemName", item.get("item_name"));
                checkItem.put("completed", Boolean.TRUE.equals(item.get("is_completed")));
                checkItem.put("itemOrder", item.get("item_order"));
                checklistData.add(checkItem);
            }

            response.put("success", true);
            response.put("checklist", checklistData);
            response.put("completionRate", completionRate);
            response.put("total", total);
            response.put("completed", completed);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "체크리스트 조회 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }

        return response;
    }

    @PostMapping("/toggle")
    @ResponseBody
    public Map<String, Object> toggleChecklistItem(@RequestParam Long checklistId,
                                                   @RequestParam boolean completed,
                                                   HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 로그인 사용자 정보 가져오기
            com.tour.project.dto.MemberDTO loginUser = (com.tour.project.dto.MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            String userId = loginUser.getUserId();

            // 체크리스트 아이템 업데이트
            String updateSql = "UPDATE travel_checklist SET is_completed = ?, completed_date = ? " +
                              "WHERE checklist_id = ? AND user_id = ?";

            Timestamp completedDate = completed ? new Timestamp(System.currentTimeMillis()) : null;
            int updated = jdbcTemplate.update(updateSql, completed, completedDate, checklistId, userId);

            if (updated > 0) {
                // 해당 plan의 전체 완료율 계산
                String planIdSql = "SELECT plan_id FROM travel_checklist WHERE checklist_id = ?";
                Long planId = jdbcTemplate.queryForObject(planIdSql, Long.class, checklistId);

                String statsSql = "SELECT COUNT(*) as total, " +
                                 "SUM(CASE WHEN is_completed = 1 THEN 1 ELSE 0 END) as completed " +
                                 "FROM travel_checklist WHERE plan_id = ? AND user_id = ?";

                Map<String, Object> stats = jdbcTemplate.queryForMap(statsSql, planId, userId);
                int total = ((Number) stats.get("total")).intValue();
                int completedCount = ((Number) stats.get("completed")).intValue();
                double completionRate = total > 0 ? (completedCount * 100.0 / total) : 0;

                response.put("success", true);
                response.put("completionRate", completionRate);
                response.put("total", total);
                response.put("completed", completedCount);
            } else {
                response.put("success", false);
                response.put("message", "체크리스트 항목을 찾을 수 없습니다.");
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "업데이트 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }

        return response;
    }

    @PostMapping("/add")
    @ResponseBody
    public Map<String, Object> addChecklistItem(@RequestParam Long planId,
                                                @RequestParam String itemName,
                                                HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 로그인 사용자 정보 가져오기
            com.tour.project.dto.MemberDTO loginUser = (com.tour.project.dto.MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            String userId = loginUser.getUserId();

            // 최대 order 값 조회
            String maxOrderSql = "SELECT COALESCE(MAX(item_order), 0) + 1 FROM travel_checklist WHERE plan_id = ? AND user_id = ?";
            int nextOrder = jdbcTemplate.queryForObject(maxOrderSql, Integer.class, planId, userId);

            // 새 항목 추가
            String insertSql = "INSERT INTO travel_checklist (plan_id, user_id, item_name, is_completed, created_date, item_order) " +
                              "VALUES (?, ?, ?, 0, NOW(), ?)";

            int inserted = jdbcTemplate.update(insertSql, planId, userId, itemName, nextOrder);

            if (inserted > 0) {
                response.put("success", true);
                response.put("message", "체크리스트 항목이 추가되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "항목 추가에 실패했습니다.");
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "추가 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }

        return response;
    }

    @PostMapping("/delete")
    @ResponseBody
    public Map<String, Object> deleteChecklistItem(@RequestParam Long checklistId, HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 로그인 사용자 정보 가져오기
            com.tour.project.dto.MemberDTO loginUser = (com.tour.project.dto.MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            String userId = loginUser.getUserId();

            // 체크리스트 항목 삭제
            String deleteSql = "DELETE FROM travel_checklist WHERE checklist_id = ? AND user_id = ?";
            int deleted = jdbcTemplate.update(deleteSql, checklistId, userId);

            if (deleted > 0) {
                response.put("success", true);
                response.put("message", "체크리스트 항목이 삭제되었습니다.");
            } else {
                response.put("success", false);
                response.put("message", "항목을 찾을 수 없습니다.");
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "삭제 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }

        return response;
    }

    @PostMapping("/reorder")
    @ResponseBody
    public Map<String, Object> reorderChecklistItems(@RequestParam Long planId,
                                                     @RequestParam String itemIds,
                                                     HttpSession session) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 로그인 사용자 정보 가져오기
            com.tour.project.dto.MemberDTO loginUser = (com.tour.project.dto.MemberDTO) session.getAttribute("loginUser");
            if (loginUser == null) {
                response.put("success", false);
                response.put("message", "로그인이 필요합니다.");
                return response;
            }
            String userId = loginUser.getUserId();

            // 순서 업데이트
            String[] ids = itemIds.split(",");
            for (int i = 0; i < ids.length; i++) {
                String updateSql = "UPDATE travel_checklist SET item_order = ? WHERE checklist_id = ? AND user_id = ? AND plan_id = ?";
                jdbcTemplate.update(updateSql, i + 1, Long.parseLong(ids[i]), userId, planId);
            }

            response.put("success", true);
            response.put("message", "순서가 업데이트되었습니다.");

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "순서 변경 중 오류가 발생했습니다: " + e.getMessage());
            e.printStackTrace();
        }

        return response;
    }
}