-- 활동 로그 테이블
CREATE TABLE IF NOT EXISTS user_activity_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50) NOT NULL,
    activity_type VARCHAR(50) NOT NULL, -- POST_CREATED, PLAN_CREATED, REQUEST_RECEIVED, REQUEST_SENT, FAVORITE_ADDED, MESSAGE_RECEIVED
    target_id INT,
    target_title VARCHAR(200),
    target_url VARCHAR(200),
    activity_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    metadata TEXT, -- JSON 형태로 추가 정보 저장
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, activity_date DESC)
);

-- 여행 준비 체크리스트 테이블
CREATE TABLE IF NOT EXISTS travel_checklist (
    checklist_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_date TIMESTAMP NULL,
    item_order INT DEFAULT 0,
    FOREIGN KEY (plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_plan_user (plan_id, user_id)
);

-- 여행 알림 설정 테이블
CREATE TABLE IF NOT EXISTS travel_reminder (
    reminder_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    reminder_date DATE NOT NULL,
    reminder_type VARCHAR(50) NOT NULL, -- D-30, D-7, D-3, D-1
    is_sent BOOLEAN DEFAULT FALSE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_reminder (plan_id, user_id, reminder_type)
);

-- 기본 체크리스트 템플릿
INSERT INTO travel_checklist (plan_id, user_id, item_name, item_order)
SELECT plan_id, user_id, '여권 확인', 1 FROM travel_plan WHERE NOT EXISTS (SELECT 1 FROM travel_checklist WHERE plan_id = travel_plan.plan_id AND item_name = '여권 확인');

-- 샘플 활동 로그 데이터 (선택사항)
-- INSERT INTO user_activity_log (user_id, activity_type, target_id, target_title, target_url) VALUES
-- ('user1', 'POST_CREATED', 1, '제주도 맛집 추천', '/board/detail/1'),
-- ('user1', 'PLAN_CREATED', 1, '부산 2박3일 여행', '/travel/detail/1');