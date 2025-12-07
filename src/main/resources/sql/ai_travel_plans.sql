-- AI Travel Plans 테이블 생성
-- AI 플래너에서 생성한 여행 계획을 저장하는 테이블

CREATE TABLE IF NOT EXISTS ai_travel_plans (
    plan_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'AI 여행 계획 고유 식별번호',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 아이디',
    title VARCHAR(255) NOT NULL COMMENT '여행 계획 제목',
    destination VARCHAR(255) COMMENT '여행 목적지',
    start_date DATE COMMENT '여행 시작일',
    end_date DATE COMMENT '여행 종료일',
    duration INT COMMENT '여행 기간(일)',
    budget VARCHAR(100) COMMENT '예산',
    travel_style VARCHAR(100) COMMENT '여행 스타일',
    plan_content JSON COMMENT '상세 여행 계획 (JSON 형식)',
    tags JSON COMMENT '여행 태그 목록',
    is_public BOOLEAN DEFAULT FALSE COMMENT '공개 여부',
    is_template BOOLEAN DEFAULT FALSE COMMENT '템플릿 여부',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at DESC),
    INDEX idx_is_public (is_public),
    INDEX idx_is_template (is_template)
) COMMENT = 'AI 플래너 여행 계획 저장 테이블' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Plan Tags 테이블 (태그 관리용)
CREATE TABLE IF NOT EXISTS plan_tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '태그 고유 식별번호',
    tag_name VARCHAR(50) NOT NULL UNIQUE COMMENT '태그 이름',
    usage_count INT DEFAULT 0 COMMENT '사용 횟수',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    INDEX idx_tag_name (tag_name),
    INDEX idx_usage_count (usage_count DESC)
) COMMENT = '여행 계획 태그 관리 테이블' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- AI Travel Plan Tags 연결 테이블 (다대다 관계)
CREATE TABLE IF NOT EXISTS ai_travel_plan_tags (
    plan_id BIGINT NOT NULL COMMENT 'AI 여행 계획 ID',
    tag_id INT NOT NULL COMMENT '태그 ID',
    PRIMARY KEY (plan_id, tag_id),
    FOREIGN KEY (plan_id) REFERENCES ai_travel_plans(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES plan_tags(tag_id) ON DELETE CASCADE
) COMMENT = 'AI 여행 계획-태그 연결 테이블' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 샘플 태그 데이터 삽입
INSERT IGNORE INTO plan_tags (tag_name, usage_count) VALUES
('가족여행', 0),
('혼자여행', 0),
('친구여행', 0),
('커플여행', 0),
('배낭여행', 0),
('휴양', 0),
('관광', 0),
('맛집탐방', 0),
('역사탐방', 0),
('액티비티', 0),
('쇼핑', 0),
('자연', 0),
('도시여행', 0),
('해외여행', 0),
('국내여행', 0);

-- 테스트 데이터 (선택사항)
-- INSERT INTO ai_travel_plans (user_id, title, destination, start_date, end_date, duration, budget, travel_style, plan_content, tags) VALUES
-- ('123456', '제주도 3박4일 힐링 여행', '제주도', '2025-09-01', '2025-09-04', 4, '100만원', '휴양', 
--  '{"day1": "공항 도착 → 숙소 체크인 → 해변 산책", "day2": "한라산 등반 → 흑돼지 맛집", "day3": "우도 투어 → 성산일출봉", "day4": "카페 투어 → 공항"}',
--  '["휴양", "자연", "맛집탐방", "국내여행"]');