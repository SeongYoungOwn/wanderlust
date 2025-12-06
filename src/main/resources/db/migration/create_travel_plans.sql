-- AI 플래너 여행 계획 저장 기능을 위한 테이블 생성
-- travel_plans 테이블: 여행 계획 메인 정보 저장
CREATE TABLE travel_plans (
    plan_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    destination VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    duration INT,
    budget DECIMAL(10,2),
    travel_style VARCHAR(50),
    plan_content TEXT NOT NULL COMMENT 'JSON 형태로 저장된 상세 계획',
    chat_session_id VARCHAR(100) COMMENT '어떤 채팅에서 생성된 계획인지 추적',
    memo TEXT COMMENT '사용자 메모',
    is_template BOOLEAN DEFAULT FALSE COMMENT '템플릿 여부',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('draft', 'completed', 'archived') DEFAULT 'draft',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_created (user_id, created_at DESC),
    INDEX idx_destination (destination),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- plan_tags 테이블: 검색 편의를 위한 태그 시스템
CREATE TABLE plan_tags (
    tag_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    plan_id BIGINT NOT NULL,
    tag_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_id) REFERENCES travel_plans(plan_id) ON DELETE CASCADE,
    INDEX idx_plan_tag (plan_id, tag_name),
    INDEX idx_tag_name (tag_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;