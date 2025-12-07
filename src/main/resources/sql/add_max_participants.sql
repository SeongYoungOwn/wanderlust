-- AI Travel Plans 테이블에 max_participants 컬럼 추가
-- 참여 인원 필드를 추가하여 여행 계획 작성 시 자동 입력 지원

ALTER TABLE ai_travel_plans 
ADD COLUMN max_participants INT DEFAULT 4 COMMENT '최대 참여 인원' 
AFTER budget;

-- 기존 데이터에 기본값 설정 (4명)
UPDATE ai_travel_plans 
SET max_participants = 4 
WHERE max_participants IS NULL;