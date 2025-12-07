-- ========================================
-- 가이드 테이블 추가 마이그레이션
-- ========================================
-- 실행일: 2025-01-XX
-- 목적: 가이드 신청 및 승인 기능을 위한 테이블 추가

-- GUIDE_APPLICATIONS 테이블 생성 (존재하지 않을 경우만)
CREATE TABLE IF NOT EXISTS guide_applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    region VARCHAR(100),
    address VARCHAR(255),
    phone VARCHAR(20),
    specialty_region VARCHAR(100),
    specialty_theme VARCHAR(100),
    specialty_area VARCHAR(100),
    introduction TEXT,
    greeting_message TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    admin_comment TEXT,
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewed_date TIMESTAMP NULL,
    reviewed_by VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_applied_date (applied_date DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- GUIDES 테이블 생성 (존재하지 않을 경우만)
CREATE TABLE IF NOT EXISTS guides (
    guide_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL UNIQUE,
    specialties TEXT,
    available_areas TEXT,
    introduction TEXT,
    languages VARCHAR(100) DEFAULT 'Korean',
    hourly_rate INT DEFAULT 50000,
    guide_status VARCHAR(20) DEFAULT 'ACTIVE',
    rating DECIMAL(3,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_member_id (member_id),
    INDEX idx_guide_status (guide_status),
    INDEX idx_rating (rating DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 샘플 가이드 데이터 삽입
INSERT IGNORE INTO guide_applications (user_id, region, address, phone, specialty_region, specialty_theme, specialty_area, introduction, greeting_message, status) VALUES
('testuser1', '서울', '서울시 강남구', '010-1234-5678', '서울/경기', '문화/역사', '고궁 투어', '서울의 역사와 문화를 깊이 있게 안내해드립니다. 10년 경력의 전문 가이드입니다.', '안녕하세요! 서울 문화 가이드 테스트사용자1입니다.', 'approved'),
('testuser2', '부산', '부산시 해운대구', '010-2345-6789', '부산/경남', '자연/바다', '해양 투어', '부산의 아름다운 바다와 해양 문화를 소개합니다. 바다를 사랑하는 가이드입니다.', '부산의 바다로 여러분을 초대합니다!', 'approved');

INSERT IGNORE INTO guides (member_id, specialties, available_areas, introduction, languages, hourly_rate, guide_status, rating) VALUES
('testuser1', '서울/경기, 문화/역사, 고궁 투어', '서울', '서울의 역사와 문화를 깊이 있게 안내해드립니다. 10년 경력의 전문 가이드입니다.', 'Korean', 50000, 'ACTIVE', 4.8),
('testuser2', '부산/경남, 자연/바다, 해양 투어', '부산', '부산의 아름다운 바다와 해양 문화를 소개합니다. 바다를 사랑하는 가이드입니다.', 'Korean', 50000, 'ACTIVE', 4.5);

-- 마이그레이션 완료
SELECT '가이드 테이블 마이그레이션이 성공적으로 완료되었습니다.' AS result;
