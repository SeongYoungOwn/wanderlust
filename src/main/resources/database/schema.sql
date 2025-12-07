-- Database: tour_db
-- Character Set: UTF-8


-- MEMBER 테이블
CREATE TABLE MEMBER (
    user_id VARCHAR(50) PRIMARY KEY,
    user_password VARCHAR(255) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    user_email VARCHAR(100) UNIQUE NOT NULL,
    user_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TRAVEL_PLAN 테이블
CREATE TABLE TRAVEL_PLAN (
    plan_id INT AUTO_INCREMENT PRIMARY KEY,
    plan_title VARCHAR(255) NOT NULL,
    plan_destination VARCHAR(255) NOT NULL,
    plan_start_date DATE NOT NULL,
    plan_end_date DATE NOT NULL,
    plan_budget INT,
    plan_content TEXT,
    plan_writer VARCHAR(50) NOT NULL,
    plan_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (plan_writer) REFERENCES MEMBER(user_id) ON DELETE CASCADE
);

-- BOARD 테이블
CREATE TABLE BOARD (
    board_id INT AUTO_INCREMENT PRIMARY KEY,
    board_title VARCHAR(255) NOT NULL,
    board_content TEXT NOT NULL,
    board_writer VARCHAR(50) NOT NULL,
    board_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (board_writer) REFERENCES MEMBER(user_id) ON DELETE CASCADE
);

-- COMMENTS 테이블 (COMMENT는 예약어일 수 있어 COMMENTS로 명명)
CREATE TABLE COMMENTS (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    board_id INT NOT NULL,
    comment_content VARCHAR(1000) NOT NULL,
    comment_writer VARCHAR(50) NOT NULL,
    comment_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (board_id) REFERENCES BOARD(board_id) ON DELETE CASCADE,
    FOREIGN KEY (comment_writer) REFERENCES MEMBER(user_id) ON DELETE CASCADE
);

-- 인덱스 생성 (성능 향상을 위함)
CREATE INDEX idx_travel_plan_writer ON TRAVEL_PLAN(plan_writer);
CREATE INDEX idx_travel_plan_dates ON TRAVEL_PLAN(plan_start_date, plan_end_date);
CREATE INDEX idx_board_writer ON BOARD(board_writer);
CREATE INDEX idx_board_regdate ON BOARD(board_regdate DESC);
CREATE INDEX idx_comments_board ON COMMENTS(board_id);
CREATE INDEX idx_comments_writer ON COMMENTS(comment_writer);

-- GUIDE_APPLICATIONS 테이블 (가이드 신청)
CREATE TABLE GUIDE_APPLICATIONS (
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
    FOREIGN KEY (user_id) REFERENCES MEMBER(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_applied_date (applied_date DESC)
);

-- GUIDES 테이블 (승인된 가이드)
CREATE TABLE GUIDES (
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
    FOREIGN KEY (member_id) REFERENCES MEMBER(user_id) ON DELETE CASCADE,
    INDEX idx_member_id (member_id),
    INDEX idx_guide_status (guide_status),
    INDEX idx_rating (rating DESC)
);