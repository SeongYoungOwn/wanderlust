-- user_manner_stats 테이블 생성
-- 사용자 매너 통계를 저장하는 테이블
CREATE TABLE IF NOT EXISTS user_manner_stats (
    user_id VARCHAR(50) PRIMARY KEY COMMENT '사용자 아이디',
    average_manner_score DECIMAL(5,2) DEFAULT 36.5 COMMENT '평균 매너 점수',
    total_evaluations INT DEFAULT 0 COMMENT '총 평가 수',
    total_likes INT DEFAULT 0 COMMENT '총 좋아요 수',
    total_dislikes INT DEFAULT 0 COMMENT '총 싫어요 수',
    completed_travels INT DEFAULT 0 COMMENT '완료된 여행 수',
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '마지막 업데이트 일시',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT='사용자 매너 통계 테이블';

-- 초기 데이터 삽입 (모든 기존 사용자에 대해 기본값 설정)
INSERT INTO user_manner_stats (user_id)
SELECT user_id FROM member
WHERE user_id NOT IN (SELECT user_id FROM user_manner_stats)
ON DUPLICATE KEY UPDATE user_id = user_id;

-- 인덱스 추가
CREATE INDEX idx_manner_score ON user_manner_stats(average_manner_score);
CREATE INDEX idx_last_updated ON user_manner_stats(last_updated);