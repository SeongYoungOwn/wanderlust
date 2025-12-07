-- 체크리스트 테이블 생성
CREATE TABLE IF NOT EXISTS travel_checklist (
    checklist_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id BIGINT NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    item_name VARCHAR(200) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_date TIMESTAMP NULL,
    item_order INT DEFAULT 0,
    INDEX idx_plan_user (plan_id, user_id),
    INDEX idx_user_plan (user_id, plan_id)
);

-- 기존 체크리스트가 없는 경우 기본 데이터 삽입용 프로시저
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS CreateDefaultChecklist(IN p_plan_id BIGINT, IN p_user_id VARCHAR(50))
BEGIN
    DECLARE checklist_count INT;

    SELECT COUNT(*) INTO checklist_count
    FROM travel_checklist
    WHERE plan_id = p_plan_id AND user_id = p_user_id;

    IF checklist_count = 0 THEN
        INSERT INTO travel_checklist (plan_id, user_id, item_name, item_order) VALUES
        (p_plan_id, p_user_id, '여권 / 신분증', 1),
        (p_plan_id, p_user_id, '항공권 / 기차표', 2),
        (p_plan_id, p_user_id, '숙소 예약 확인서', 3),
        (p_plan_id, p_user_id, '여행자 보험', 4),
        (p_plan_id, p_user_id, '현금 / 카드', 5),
        (p_plan_id, p_user_id, '충전기 / 보조배터리', 6),
        (p_plan_id, p_user_id, '세면도구', 7),
        (p_plan_id, p_user_id, '여분 옷', 8),
        (p_plan_id, p_user_id, '상비약', 9),
        (p_plan_id, p_user_id, '카메라', 10);
    END IF;
END$$
DELIMITER ;