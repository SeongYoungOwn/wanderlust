-- AI 추천 시스템 데이터베이스 스키마
-- 작성일: 2025-08-10
-- 설명: 고도화된 AI 추천 시스템을 위한 테이블 스키마

-- 1. 사용자 선호도 테이블
CREATE TABLE IF NOT EXISTS user_preferences (
    user_id VARCHAR(50) PRIMARY KEY,
    preferred_destinations JSON,
    preferred_styles JSON,
    avg_budget_range VARCHAR(50),
    preferred_duration_days INT,
    mbti_type VARCHAR(4),
    personalized_weights JSON,
    collaborative_score DOUBLE,
    favorite_destinations JSON,
    disliked_destinations JSON,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_mbti_type (mbti_type),
    INDEX idx_last_updated (last_updated)
);

-- 2. 매칭 피드백 테이블
CREATE TABLE IF NOT EXISTS matching_feedback (
    feedback_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    plan_id BIGINT,
    matching_score DOUBLE,
    user_satisfaction INT,
    actual_participation BOOLEAN,
    click_count INT DEFAULT 0,
    view_count INT DEFAULT 0,
    view_duration_seconds BIGINT DEFAULT 0,
    applied BOOLEAN DEFAULT FALSE,
    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_plan_id (plan_id),
    INDEX idx_feedback_date (feedback_date),
    UNIQUE KEY unique_user_plan (user_id, plan_id)
);

-- 3. MBTI 궁합 캐시 테이블
CREATE TABLE IF NOT EXISTS mbti_compatibility_cache (
    mbti_1 VARCHAR(4),
    mbti_2 VARCHAR(4),
    travel_style VARCHAR(50),
    compatibility_score DOUBLE,
    synergy_description TEXT,
    recommended_destinations TEXT,
    PRIMARY KEY(mbti_1, mbti_2, travel_style),
    INDEX idx_mbti_1 (mbti_1),
    INDEX idx_mbti_2 (mbti_2)
);

-- 4. 사용자 행동 로그 테이블
CREATE TABLE IF NOT EXISTS user_behavior_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    action_type VARCHAR(50), -- CLICK_PLAN, VIEW_DETAIL, APPLY_PLAN, RATE_PLAN, PARTICIPATE
    action_value TEXT,
    action_metadata JSON,
    action_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_id VARCHAR(100),
    INDEX idx_user_action (user_id, action_type),
    INDEX idx_timestamp (action_timestamp)
);

-- 5. 추천 성과 메트릭스 테이블
CREATE TABLE IF NOT EXISTS recommendation_metrics (
    metric_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    metric_date DATE,
    total_recommendations INT,
    total_clicks INT,
    total_views INT,
    total_applications INT,
    total_participations INT,
    avg_satisfaction DOUBLE,
    ctr DOUBLE, -- Click-Through Rate
    matching_success_rate DOUBLE,
    retention_rate DOUBLE,
    diversity_index DOUBLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_date (metric_date)
);

-- 6. 사용자 여행 이력 테이블
CREATE TABLE IF NOT EXISTS user_travel_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    plan_id BIGINT,
    destination_category VARCHAR(50),
    travel_style VARCHAR(50),
    budget_range VARCHAR(50),
    duration_days INT,
    rating DOUBLE,
    participation_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_history (user_id),
    INDEX idx_destination (destination_category),
    INDEX idx_style (travel_style)
);

-- 7. 협업 필터링 유사도 캐시 테이블
CREATE TABLE IF NOT EXISTS user_similarity_cache (
    user_id_1 VARCHAR(50),
    user_id_2 VARCHAR(50),
    similarity_score DOUBLE,
    calculation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id_1, user_id_2),
    INDEX idx_similarity (similarity_score)
);

-- 8. A/B 테스트 결과 테이블
CREATE TABLE IF NOT EXISTS ab_test_results (
    test_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50),
    test_group VARCHAR(10), -- 'A' or 'B'
    test_name VARCHAR(100),
    recommendation_algorithm VARCHAR(50),
    clicked BOOLEAN DEFAULT FALSE,
    applied BOOLEAN DEFAULT FALSE,
    satisfaction_score INT,
    test_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_test_group (test_group, test_name),
    INDEX idx_user_test (user_id, test_name)
);

-- 9. 실시간 추천 캐시 테이블 (Redis 대체용)
CREATE TABLE IF NOT EXISTS recommendation_cache (
    cache_key VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(50),
    recommendation_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    INDEX idx_user_cache (user_id),
    INDEX idx_expires (expires_at)
);

-- 10. 사용자 세그먼트 테이블
CREATE TABLE IF NOT EXISTS user_segments (
    segment_id INT AUTO_INCREMENT PRIMARY KEY,
    segment_name VARCHAR(100),
    segment_criteria JSON,
    user_count INT DEFAULT 0,
    avg_satisfaction DOUBLE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 초기 MBTI 호환성 데이터 삽입
INSERT IGNORE INTO mbti_compatibility_cache (mbti_1, mbti_2, travel_style, compatibility_score, synergy_description, recommended_destinations) VALUES
('PAIB', 'JCGL', '균형', 0.85, '계획형과 즉흥형의 완벽한 균형', '유럽, 일본'),
('PAIB', 'PAIB', '안정', 0.90, '체계적인 계획으로 안정적인 여행', '국내, 동남아'),
('PCGL', 'PCGL', '휴양', 0.88, '여유로운 그룹 휴양 여행', '리조트, 해변'),
('JAIB', 'JAGL', '모험', 0.82, '즉흥적인 모험 여행', '남미, 아프리카'),
('PCIB', 'JCGL', '문화', 0.80, '문화 탐방과 여유의 조화', '유럽, 중동');

-- 뷰 생성: 사용자별 추천 성과
CREATE OR REPLACE VIEW user_recommendation_performance AS
SELECT 
    mf.user_id,
    COUNT(*) as total_recommendations,
    AVG(mf.matching_score) as avg_matching_score,
    AVG(mf.user_satisfaction) as avg_satisfaction,
    SUM(CASE WHEN mf.actual_participation = 1 THEN 1 ELSE 0 END) as successful_matches,
    (SUM(mf.click_count) / NULLIF(SUM(mf.view_count), 0)) * 100 as ctr
FROM matching_feedback mf
GROUP BY mf.user_id;

-- 뷰 생성: 목적지별 인기도
CREATE OR REPLACE VIEW destination_popularity AS
SELECT 
    destination_category,
    COUNT(*) as trip_count,
    AVG(rating) as avg_rating,
    COUNT(DISTINCT user_id) as unique_travelers
FROM user_travel_history
GROUP BY destination_category
ORDER BY trip_count DESC;

/*
-- ========================================
-- 스토어드 프로시저와 이벤트는 JDBC 스크립트 실행기에서 DELIMITER를 지원하지 않아 주석 처리
-- 프로덕션 환경에서는 MySQL CLI를 통해 수동으로 생성 필요
-- ========================================

-- 스토어드 프로시저: 캐시 정리
DELIMITER $$
CREATE PROCEDURE clean_expired_cache()
BEGIN
    -- 만료된 추천 캐시 삭제
    DELETE FROM recommendation_cache
    WHERE expires_at < NOW();

    -- 30일 이상 된 행동 로그 삭제
    DELETE FROM user_behavior_log
    WHERE action_timestamp < DATE_SUB(NOW(), INTERVAL 30 DAY);

    -- 90일 이상 된 유사도 캐시 갱신
    DELETE FROM user_similarity_cache
    WHERE calculation_date < DATE_SUB(NOW(), INTERVAL 90 DAY);
END$$
DELIMITER ;

-- 스토어드 프로시저: 일일 메트릭스 계산
DELIMITER $$
CREATE PROCEDURE calculate_daily_metrics()
BEGIN
    DECLARE v_date DATE;
    DECLARE v_total_recommendations INT;
    DECLARE v_total_clicks INT;
    DECLARE v_total_views INT;
    DECLARE v_total_applications INT;
    DECLARE v_total_participations INT;
    DECLARE v_avg_satisfaction DOUBLE;
    DECLARE v_ctr DOUBLE;
    DECLARE v_success_rate DOUBLE;

    SET v_date = CURDATE() - INTERVAL 1 DAY;

    -- 메트릭스 계산
    SELECT
        COUNT(*),
        SUM(click_count),
        SUM(view_count),
        SUM(CASE WHEN applied = 1 THEN 1 ELSE 0 END),
        SUM(CASE WHEN actual_participation = 1 THEN 1 ELSE 0 END),
        AVG(user_satisfaction)
    INTO
        v_total_recommendations,
        v_total_clicks,
        v_total_views,
        v_total_applications,
        v_total_participations,
        v_avg_satisfaction
    FROM matching_feedback
    WHERE DATE(feedback_date) = v_date;

    -- CTR 계산
    SET v_ctr = IF(v_total_views > 0, v_total_clicks / v_total_views, 0);

    -- 성공률 계산
    SET v_success_rate = IF(v_total_recommendations > 0,
        v_total_participations / v_total_recommendations, 0);

    -- 메트릭스 저장
    INSERT INTO recommendation_metrics
    (metric_date, total_recommendations, total_clicks, total_views,
     total_applications, total_participations, avg_satisfaction,
     ctr, matching_success_rate)
    VALUES
    (v_date, v_total_recommendations, v_total_clicks, v_total_views,
     v_total_applications, v_total_participations, v_avg_satisfaction,
     v_ctr, v_success_rate)
    ON DUPLICATE KEY UPDATE
        total_recommendations = v_total_recommendations,
        total_clicks = v_total_clicks,
        total_views = v_total_views,
        total_applications = v_total_applications,
        total_participations = v_total_participations,
        avg_satisfaction = v_avg_satisfaction,
        ctr = v_ctr,
        matching_success_rate = v_success_rate;
END$$
DELIMITER ;

-- 이벤트 스케줄러: 매일 새벽 3시에 메트릭스 계산
CREATE EVENT IF NOT EXISTS calculate_metrics_daily
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 3 HOUR)
DO CALL calculate_daily_metrics();

-- 이벤트 스케줄러: 매일 새벽 4시에 캐시 정리
CREATE EVENT IF NOT EXISTS clean_cache_daily
ON SCHEDULE EVERY 1 DAY
STARTS (TIMESTAMP(CURRENT_DATE) + INTERVAL 1 DAY + INTERVAL 4 HOUR)
DO CALL clean_expired_cache();
*/