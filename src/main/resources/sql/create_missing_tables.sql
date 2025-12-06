-- ========================================
-- 프로필 페이지를 위한 필수 테이블 생성 스크립트
-- ========================================

-- 1. 매너 평가 테이블 (단수형으로 수정)
CREATE TABLE IF NOT EXISTS manner_evaluation (
    evaluation_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '평가 고유 번호',
    travel_plan_id INT COMMENT '관련 여행 계획 ID',
    evaluator_id VARCHAR(50) NOT NULL COMMENT '평가자 ID',
    evaluated_id VARCHAR(50) NOT NULL COMMENT '피평가자 ID',
    manner_score DECIMAL(4,2) NOT NULL COMMENT '매너 점수',
    evaluation_type VARCHAR(20) COMMENT '평가 유형',
    evaluation_category VARCHAR(50) COMMENT '평가 카테고리',
    is_like BOOLEAN DEFAULT FALSE COMMENT '좋아요 여부',
    evaluation_comment TEXT COMMENT '평가 코멘트',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '평가 일시',
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
    FOREIGN KEY (evaluator_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (evaluated_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    INDEX idx_evaluated_id (evaluated_id),
    INDEX idx_evaluator_id (evaluator_id),
    INDEX idx_travel_plan_id (travel_plan_id),
    INDEX idx_created_date (created_date)
) COMMENT = '사용자 매너 평가 테이블';

-- 2. 뱃지 테이블
CREATE TABLE IF NOT EXISTS badges (
    badge_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '뱃지 고유 번호',
    badge_name VARCHAR(100) NOT NULL COMMENT '뱃지 이름',
    badge_description TEXT COMMENT '뱃지 설명',
    badge_icon VARCHAR(255) COMMENT '뱃지 아이콘 경로',
    badge_type VARCHAR(50) COMMENT '뱃지 타입',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성 일시',
    INDEX idx_badge_type (badge_type)
) COMMENT = '뱃지 정보 테이블';

-- 3. 사용자 뱃지 테이블
CREATE TABLE IF NOT EXISTS user_badges (
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    badge_id INT NOT NULL COMMENT '뱃지 ID',
    earned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '획득 일시',
    PRIMARY KEY (user_id, badge_id),
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badges(badge_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_badge_id (badge_id),
    INDEX idx_earned_date (earned_date)
) COMMENT = '사용자별 뱃지 획득 테이블';

-- 4. 여행 MBTI 결과 테이블
CREATE TABLE IF NOT EXISTS travel_mbti_results (
    mbti_type VARCHAR(4) PRIMARY KEY COMMENT 'MBTI 타입 (예: ENFP)',
    type_name VARCHAR(100) NOT NULL COMMENT '타입 이름',
    type_description TEXT COMMENT '타입 설명',
    travel_style TEXT COMMENT '여행 스타일',
    recommended_destinations TEXT COMMENT '추천 여행지',
    travel_tips TEXT COMMENT '여행 팁',
    best_travel_season VARCHAR(50) COMMENT '최적 여행 시기'
) COMMENT = '여행 MBTI 결과 정보 테이블';

-- 5. 사용자 여행 MBTI 기록 테이블
CREATE TABLE IF NOT EXISTS user_travel_mbti (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '기록 고유 번호',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    mbti_type VARCHAR(4) NOT NULL COMMENT '테스트 결과 MBTI 타입',
    test_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '테스트 실시 일시',
    answers TEXT COMMENT '답변 내용 (JSON 형태)',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_mbti_type (mbti_type),
    INDEX idx_test_date (test_date)
) COMMENT = '사용자별 여행 MBTI 테스트 기록 테이블';

-- 6. 리뷰 테이블
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '리뷰 고유 번호',
    reviewer_id VARCHAR(50) NOT NULL COMMENT '리뷰 작성자 ID',
    reviewed_user_id VARCHAR(50) NOT NULL COMMENT '리뷰 대상 사용자 ID',
    travel_plan_id INT COMMENT '관련 여행 계획 ID',
    rating INT NOT NULL COMMENT '평점 (1-5)',
    review_content TEXT COMMENT '리뷰 내용',
    review_type VARCHAR(20) COMMENT '리뷰 타입',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '작성 일시',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정 일시',
    FOREIGN KEY (reviewer_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewed_user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    INDEX idx_reviewed_user_id (reviewed_user_id),
    INDEX idx_reviewer_id (reviewer_id),
    INDEX idx_travel_plan_id (travel_plan_id),
    INDEX idx_created_at (created_at)
) COMMENT = '사용자 리뷰 테이블';

-- 7. 신고 테이블
CREATE TABLE IF NOT EXISTS reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '신고 고유 번호',
    reporter_id VARCHAR(50) NOT NULL COMMENT '신고자 ID',
    reported_content_type VARCHAR(20) NOT NULL COMMENT '신고 대상 타입 (BOARD, PLAN, USER)',
    reported_content_id INT COMMENT '신고 대상 ID',
    reported_user_id VARCHAR(50) COMMENT '신고 당한 사용자 ID',
    report_category VARCHAR(50) NOT NULL COMMENT '신고 카테고리',
    report_content TEXT COMMENT '신고 내용',
    report_status VARCHAR(20) DEFAULT 'PENDING' COMMENT '처리 상태 (PENDING, APPROVED, REJECTED)',
    admin_comment TEXT COMMENT '관리자 코멘트',
    processed_by VARCHAR(50) COMMENT '처리자 ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '신고 일시',
    processed_at TIMESTAMP NULL COMMENT '처리 일시',
    FOREIGN KEY (reporter_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reported_user_id) REFERENCES member(user_id) ON DELETE SET NULL,
    INDEX idx_reporter_id (reporter_id),
    INDEX idx_reported_user_id (reported_user_id),
    INDEX idx_report_status (report_status),
    INDEX idx_created_at (created_at)
) COMMENT = '신고 관리 테이블';

-- 기본 뱃지 데이터 삽입
INSERT IGNORE INTO badges (badge_name, badge_description, badge_icon, badge_type) VALUES
('첫 여행', '첫 여행을 완료했습니다', 'badge_first_travel.png', 'MILESTONE'),
('여행 마스터', '10번의 여행을 완료했습니다', 'badge_travel_master.png', 'MILESTONE'),
('친절왕', '매너 평가 평균 9.0 이상', 'badge_kind.png', 'MANNER'),
('인기왕', '받은 좋아요 100개 이상', 'badge_popular.png', 'SOCIAL'),
('활동왕', '게시글 50개 이상 작성', 'badge_active.png', 'ACTIVITY');

-- 여행 MBTI 기본 결과 데이터 삽입 (간략 버전)
INSERT IGNORE INTO travel_mbti_results (mbti_type, type_name, type_description, travel_style, recommended_destinations, travel_tips, best_travel_season) VALUES
('PAIB', '자유 배낭족', '즉흥적이고 모험적인 배낭여행을 즐기는 타입', '자유로운 영혼으로 떠나는 경제적 모험 여행', '동남아시아, 중남미, 인도', '최소한의 짐, 현지 교통수단, 게스트하우스 이용', '건기'),
('JAIL', '체계적 모험가', '철저한 계획 하에 고급 모험 여행을 즐기는 타입', '사전 계획된 프리미엄 모험 활동', '스위스 알프스, 뉴질랜드', '고급 가이드 투어 예약', '봄, 가을'),
('JSIL', '럭셔리 힐링족', '안전하고 편안한 고급 휴양을 추구하는 타입', '프리미엄 스파와 휴양지에서의 힐링', '제주도, 발리, 하와이', '5성급 리조트 예약', '연중');
