-- 소셜 트렌드 분석 모델을 위한 데이터베이스 테이블 생성
-- Created: 2025-08-16

-- 1. 소셜 미디어 포스트 데이터
CREATE TABLE social_posts (
    post_id VARCHAR(100) PRIMARY KEY,
    platform ENUM('instagram', 'twitter', 'tiktok', 'youtube', 'blog') NOT NULL,
    content TEXT,
    hashtags JSON,
    location_tags JSON,
    author_id VARCHAR(100),
    post_date DATETIME NOT NULL,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    share_count INT DEFAULT 0,
    sentiment_score DECIMAL(3,2), -- -1.0 ~ 1.0
    processed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_platform_date (platform, post_date),
    INDEX idx_location (location_tags),
    INDEX idx_sentiment (sentiment_score),
    INDEX idx_processed (processed_at)
);

-- 2. 트렌드 키워드 추출 결과
CREATE TABLE trend_keywords (
    keyword_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(100) NOT NULL,
    category ENUM('destination', 'activity', 'food', 'accommodation', 'transport') NOT NULL,
    mention_count INT DEFAULT 0,
    sentiment_avg DECIMAL(3,2),
    trend_score DECIMAL(5,2),
    date_recorded DATE NOT NULL,
    growth_rate DECIMAL(5,2), -- 전일 대비 증가율
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_keyword_date (keyword, date_recorded),
    INDEX idx_trend_score (trend_score DESC),
    INDEX idx_category_date (category, date_recorded),
    INDEX idx_growth_rate (growth_rate DESC)
);

-- 3. 지역별 트렌드 데이터
CREATE TABLE location_trends (
    trend_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(200) NOT NULL,
    country VARCHAR(100) DEFAULT '대한민국',
    region VARCHAR(100),
    latitude DECIMAL(10,8), -- 위도
    longitude DECIMAL(11,8), -- 경도
    mention_count INT DEFAULT 0,
    unique_users INT DEFAULT 0,
    sentiment_avg DECIMAL(3,2),
    trend_score DECIMAL(5,2),
    viral_score DECIMAL(5,2), -- 바이럴 지수
    date_recorded DATE NOT NULL,
    seasonality_factor DECIMAL(3,2), -- 계절성 지수
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_trend_score (trend_score DESC),
    INDEX idx_viral_score (viral_score DESC),
    INDEX idx_location_date (location_name, date_recorded),
    INDEX idx_coordinates (latitude, longitude)
);

-- 4. 사용자 여행 선호도 프로필
CREATE TABLE user_travel_profiles (
    user_id VARCHAR(50) PRIMARY KEY,
    preferred_destinations JSON, -- 선호 여행지 유형
    travel_style ENUM('luxury', 'budget', 'adventure', 'relaxation', 'cultural') DEFAULT 'relaxation',
    preferred_activities JSON,
    social_influence_score DECIMAL(3,2) DEFAULT 0.5, -- 소셜 영향력 점수
    trend_sensitivity DECIMAL(3,2) DEFAULT 0.5, -- 트렌드 민감도 (0-1)
    age_group ENUM('10s', '20s', '30s', '40s', '50s', '60s+'),
    gender ENUM('M', 'F', 'Other'),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_travel_style (travel_style),
    INDEX idx_age_gender (age_group, gender)
);

-- 5. 개인화 추천 결과
CREATE TABLE personalized_recommendations (
    recommendation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    location_name VARCHAR(200) NOT NULL,
    trend_score DECIMAL(5,2),
    personal_match_score DECIMAL(5,2),
    recommendation_reason TEXT,
    recommended_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    clicked BOOLEAN DEFAULT FALSE,
    rated TINYINT, -- 1-5 점수
    feedback_text TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at DATETIME,
    INDEX idx_user_score (user_id, personal_match_score DESC),
    INDEX idx_recommended_at (recommended_at DESC),
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 6. 실시간 트렌드 스냅샷
CREATE TABLE realtime_trends (
    snapshot_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    snapshot_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    top_destinations JSON, -- 상위 10개 여행지
    trending_keywords JSON, -- 급상승 키워드
    viral_content JSON, -- 바이럴 콘텐츠
    sentiment_summary JSON, -- 감정 분석 요약
    total_posts_analyzed INT DEFAULT 0,
    processing_time_ms INT,
    data_sources JSON, -- 데이터 출처 정보
    INDEX idx_snapshot_time (snapshot_time DESC)
);

-- 7. 트렌드 알림 설정
CREATE TABLE trend_alerts (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    keyword VARCHAR(100),
    location VARCHAR(200),
    threshold_score DECIMAL(5,2) DEFAULT 5.0, -- 알림 발송 임계점
    alert_type ENUM('keyword', 'location', 'sentiment_change') NOT NULL,
    notification_method ENUM('email', 'push', 'sms') DEFAULT 'push',
    is_active BOOLEAN DEFAULT TRUE,
    last_triggered DATETIME,
    trigger_count INT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_alert_type (alert_type)
);

-- 8. Claude API 요청 로그 (비용 및 성능 모니터링)
CREATE TABLE claude_api_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    request_type ENUM('trend_analysis', 'personalization', 'sentiment_analysis', 'prediction') NOT NULL,
    user_id VARCHAR(50),
    prompt_tokens INT,
    completion_tokens INT,
    total_tokens INT,
    cost_usd DECIMAL(8,4),
    response_time_ms INT,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    request_data JSON,
    response_data JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_date (user_id, created_at),
    INDEX idx_request_type (request_type),
    INDEX idx_cost (cost_usd DESC),
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE SET NULL
);

-- 9. 소셜 미디어 계정 연동 정보
CREATE TABLE user_social_accounts (
    account_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    platform ENUM('instagram', 'twitter', 'tiktok', 'youtube') NOT NULL,
    social_user_id VARCHAR(100),
    username VARCHAR(100),
    follower_count INT DEFAULT 0,
    following_count INT DEFAULT 0,
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at DATETIME,
    sync_enabled BOOLEAN DEFAULT TRUE,
    last_sync_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_platform (user_id, platform),
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_platform (platform),
    INDEX idx_sync_enabled (sync_enabled)
);

-- 10. 트렌드 예측 결과
CREATE TABLE trend_predictions (
    prediction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(100) NOT NULL,
    location_name VARCHAR(200),
    prediction_date DATE NOT NULL,
    predicted_for_date DATE NOT NULL,
    predicted_trend_score DECIMAL(5,2),
    confidence_level DECIMAL(3,2), -- 0.0 ~ 1.0
    prediction_factors JSON, -- 예측에 영향을 준 요소들
    actual_trend_score DECIMAL(5,2), -- 실제 결과 (검증용)
    accuracy_score DECIMAL(3,2), -- 예측 정확도
    model_version VARCHAR(50) DEFAULT 'claude-3-5-sonnet',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_keyword_date (keyword, prediction_date),
    INDEX idx_predicted_date (predicted_for_date),
    INDEX idx_confidence (confidence_level DESC),
    INDEX idx_accuracy (accuracy_score DESC)
);

-- 샘플 데이터 삽입 (개발/테스트용)
INSERT INTO trend_keywords (keyword, category, mention_count, sentiment_avg, trend_score, date_recorded, growth_rate) VALUES
('강릉 안목해변', 'destination', 1250, 0.87, 9.2, CURDATE(), 245.5),
('제주도 카멜리아힐', 'destination', 890, 0.92, 8.7, CURDATE(), 156.3),
('부산 감천문화마을', 'destination', 654, 0.84, 8.1, CURDATE(), 89.7),
('여수 돌산공원', 'destination', 432, 0.91, 7.8, CURDATE(), 67.2),
('경주 대릉원', 'destination', 321, 0.79, 7.2, CURDATE(), 45.1);

INSERT INTO location_trends (location_name, country, region, mention_count, unique_users, sentiment_avg, trend_score, viral_score, date_recorded, seasonality_factor) VALUES
('강릉 안목해변', '대한민국', '강원도', 1250, 890, 0.87, 9.2, 8.9, CURDATE(), 0.85),
('제주도 성산일출봉', '대한민국', '제주특별자치도', 1100, 750, 0.92, 8.8, 8.2, CURDATE(), 0.90),
('부산 해운대해수욕장', '대한민국', '부산광역시', 980, 720, 0.84, 8.5, 7.8, CURDATE(), 0.88),
('여수 오동도', '대한민국', '전라남도', 650, 480, 0.91, 8.0, 7.5, CURDATE(), 0.82),
('경주 불국사', '대한민국', '경상북도', 540, 390, 0.86, 7.7, 7.1, CURDATE(), 0.75);

-- 인덱스 최적화를 위한 추가 설정
ANALYZE TABLE social_posts, trend_keywords, location_trends, user_travel_profiles, personalized_recommendations;