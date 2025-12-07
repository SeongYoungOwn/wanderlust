-- Travel MBTI 시스템 스키마
-- 여행 MBTI 테스트, 결과, 사용자 기록을 관리하는 테이블들

-- 1. 여행 MBTI 질문 테이블
CREATE TABLE IF NOT EXISTS travel_mbti_questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '질문 고유 번호',
    question_text TEXT NOT NULL COMMENT '질문 내용',
    option_a VARCHAR(255) NOT NULL COMMENT '선택지 A',
    option_b VARCHAR(255) NOT NULL COMMENT '선택지 B',
    dimension VARCHAR(2) NOT NULL COMMENT 'MBTI 차원 (EI, SN, TF, JP)',
    question_order INT NOT NULL COMMENT '질문 순서',
    INDEX idx_question_order (question_order),
    INDEX idx_dimension (dimension)
) COMMENT = '여행 MBTI 테스트 질문 테이블';

-- 2. 여행 MBTI 결과 테이블
CREATE TABLE IF NOT EXISTS travel_mbti_results (
    mbti_type VARCHAR(4) PRIMARY KEY COMMENT 'MBTI 타입 (예: ENFP)',
    type_name VARCHAR(100) NOT NULL COMMENT '타입 이름',
    type_description TEXT COMMENT '타입 설명',
    travel_style TEXT COMMENT '여행 스타일',
    recommended_destinations TEXT COMMENT '추천 여행지',
    travel_tips TEXT COMMENT '여행 팁',
    best_travel_season VARCHAR(50) COMMENT '최적 여행 시기'
) COMMENT = '여행 MBTI 결과 정보 테이블';

-- 3. 사용자 여행 MBTI 기록 테이블
CREATE TABLE IF NOT EXISTS user_travel_mbti (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '기록 고유 번호',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    mbti_type VARCHAR(4) NOT NULL COMMENT '테스트 결과 MBTI 타입',
    test_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '테스트 실시 일시',
    answers TEXT COMMENT '답변 내용 (JSON 형태)',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (mbti_type) REFERENCES travel_mbti_results(mbti_type),
    INDEX idx_user_id (user_id),
    INDEX idx_mbti_type (mbti_type),
    INDEX idx_test_date (test_date)
) COMMENT = '사용자별 여행 MBTI 테스트 기록 테이블';

-- 여행 MBTI 질문 데이터 삽입 (8개 질문으로 구성)
INSERT IGNORE INTO travel_mbti_questions (question_text, option_a, option_b, dimension, question_order) VALUES

-- P vs J (계획성) - 2문항
('여행 계획을 세울 때 어떤 스타일인가요?', '미리 상세한 계획을 세우고 예약도 미리 다 해둔다', '대략적인 계획만 세우고 현지에서 즉흥적으로 결정한다', 'JP', 1),
('여행 중 예상치 못한 상황이 발생했을 때?', '원래 계획대로 진행하려고 노력한다', '새로운 기회로 받아들이고 계획을 바꾼다', 'JP', 2),

-- A vs S (모험성) - 2문항  
('여행지에서 선호하는 활동은?', '새롭고 스릴 넘치는 모험적 활동', '안전하고 편안한 휴양 활동', 'AS', 3),
('여행 중 숙박 선택 기준은?', '독특하고 특별한 경험을 할 수 있는 곳', '깨끗하고 편안하며 안전한 곳', 'AS', 4),

-- I vs G (사교성) - 2문항
('여행을 함께 하고 싶은 사람은?', '나 혼자 또는 가까운 사람 한두 명', '여러 명이 함께하는 그룹 여행', 'IG', 5),
('여행지에서 새로운 사람들과의 만남은?', '최소한의 접촉을 선호한다', '적극적으로 교류하고 친해지고 싶다', 'IG', 6),

-- L vs B (예산성향) - 2문항
('여행 예산 사용 패턴은?', '좋은 경험을 위해서는 돈을 아끼지 않는다', '합리적인 가격으로 알뜰하게 여행한다', 'LB', 7),
('여행 중 숙박과 식사 기준은?', '품질과 서비스가 좋은 고급 옵션', '가성비 좋은 실속형 옵션', 'LB', 8);

-- 여행 MBTI 결과 정보 삽입 (16가지 조합)
INSERT IGNORE INTO travel_mbti_results (mbti_type, type_name, type_description, travel_style, recommended_destinations, travel_tips, best_travel_season) VALUES

-- J-A-I-L (계획적, 모험적, 개인적, 럭셔리)
('JAIL', '체계적 모험가', '철저한 계획 하에 고급 모험 여행을 즐기는 타입', '사전 계획된 프리미엄 모험 활동과 럭셔리 숙박의 조합', '스위스 알프스, 뉴질랜드, 몰디브 리조트', '고급 가이드 투어 예약, 프리미엄 장비 준비, 안전 보험 가입', '봄, 가을'),

-- J-A-I-B (계획적, 모험적, 개인적, 절약형)
('JAIB', '계획적 백패커', '체계적 계획으로 경제적인 모험 여행을 추구하는 타입', '철저한 사전 조사와 예산 관리로 알뜰한 모험 여행', '동남아시아, 남미, 동유럽', '저가 항공 조기 예약, 호스텔 예약, 현지 대중교통 이용', '성수기 외 시즌'),

-- J-A-G-L (계획적, 모험적, 그룹, 럭셔리)
('JAGL', '프리미엄 그룹 리더', '그룹을 이끌며 고급 모험 여행을 기획하는 타입', '그룹 모험 활동과 럭셔리 편의시설의 완벽한 균형', '아프리카 사파리, 일본 온천, 유럽 크루즈', '그룹 패키지 투어, 전용 가이드, 고급 리조트 예약', '최적 기후 시기'),

-- J-A-G-B (계획적, 모험적, 그룹, 절약형)
('JAGB', '알뜰 모험 기획자', '그룹과 함께 경제적이면서 모험적인 여행을 계획하는 타입', '그룹 할인과 공동 비용으로 모험을 추구하는 스타일', '국내 등산, 캠핑, 배낭여행', '그룹 할인 활용, 공동 구매, 캠핑/호스텔 이용', '비성수기'),

-- J-S-I-L (계획적, 안전한, 개인적, 럭셔리)  
('JSIL', '럭셔리 힐링족', '안전하고 편안한 고급 휴양을 추구하는 타입', '프리미엄 스파와 휴양지에서의 완벽한 힐링', '제주도 리조트, 발리, 하와이', '5성급 리조트 예약, 스파 패키지, 프라이빗 투어', '연중 온화한 시기'),

-- J-S-I-B (계획적, 안전한, 개인적, 절약형)
('JSIB', '신중한 힐링족', '안전하고 경제적인 개인 휴양을 즐기는 타입', '조용하고 안전한 곳에서의 경제적 힐링 여행', '국내 온천, 펜션, 도서관 여행', '사전 할인 정보 수집, 한적한 시기 예약, 대중교통 이용', '비성수기'),

-- J-S-G-L (계획적, 안전한, 그룹, 럭셔리)
('JSGL', '프리미엄 가족 여행자', '가족/그룹과 안전하고 편안한 고급 여행을 즐기는 타입', '모든 연령대가 편안한 프리미엄 가족 여행', '테마파크 리조트, 크루즈, 온천 리조트', '가족 패키지 투어, 안전 시설 확인, 편의시설 완비 숙소', '가족 휴가철'),

-- J-S-G-B (계획적, 안전한, 그룹, 절약형)
('JSGB', '알뜰 가족 여행자', '그룹과 함께 안전하고 경제적인 여행을 계획하는 타입', '가족 모두가 만족하는 알뜰하고 안전한 여행', '국내 관광지, 공원, 박물관', '그룹 할인, 가족 패키지, 무료 시설 활용', '공휴일, 방학'),

-- P-A-I-L (즉흥적, 모험적, 개인적, 럭셔리)
('PAIL', '자유로운 탐험가', '즉흥적으로 고급 모험을 즐기는 자유로운 타입', '그 순간의 영감에 따른 프리미엄 모험 여행', '파타고니아, 사하라 사막, 알래스카', '여유로운 예산 준비, 현지 프리미엄 투어, 유연한 일정', '모험 최적기'),

-- P-A-I-B (즉흥적, 모험적, 개인적, 절약형)  
('PAIB', '자유 배낭족', '즉흥적이고 모험적인 배낭여행을 즐기는 타입', '자유로운 영혼으로 떠나는 경제적 모험 여행', '인도, 중남미, 동남아시아', '최소한의 짐, 현지 교통수단, 게스트하우스 이용', '건기, 저렴한 시기'),

-- P-A-G-L (즉흥적, 모험적, 그룹, 럭셔리)
('PAGL', '즉흥 파티족', '그룹과 함께 즉흥적이고 화려한 모험을 즐기는 타입', '친구들과의 스릴 넘치는 프리미엄 파티 여행', '이비사, 미코노스, 라스베가스', '그룹 빌라, 프리미엄 클럽, 럭셔리 액티비티', '파티 시즌'),

-- P-A-G-B (즉흥적, 모험적, 그룹, 절약형)
('PAGB', '자유로운 무리', '그룹과 함께 즉흥적이고 경제적인 모험을 즐기는 타입', '친구들과의 자유롭고 알뜰한 모험 여행', '배낭여행, 캠핑, 페스티벌', '그룹 텐트, 공동 취사, 히치하이킹', '축제 시기'),

-- P-S-I-L (즉흥적, 안전한, 개인적, 럭셔리)
('PSIL', '여유로운 힐러', '즉흥적이면서도 안전하고 편안한 고급 휴양을 즐기는 타입', '그때그때 기분에 따른 프리미엄 힐링 여행', '온천 리조트, 스파, 부티크 호텔', '당일 예약 가능한 고급 숙소, 스파 패키지', '휴양 최적기'),

-- P-S-I-B (즉흥적, 안전한, 개인적, 절약형)
('PSIB', '소박한 여행자', '즉흥적이지만 안전하고 경제적인 개인 여행을 선호하는 타입', '혼자만의 소소하고 평범한 힐링 여행', '근교 여행, 카페 투어, 서점 여행', '당일치기, 대중교통, 저렴한 카페', '평일, 한적한 시기'),

-- P-S-G-L (즉흥적, 안전한, 그룹, 럭셔리)  
('PSGL', '사교적 힐러', '그룹과 즉흥적이면서 편안한 고급 휴양을 즐기는 타입', '친구들과의 편안하고 여유로운 프리미엄 여행', '풀빌라, 리조트, 고급 펜션', '그룹 풀빌라, 바비큐 파티, 럭셔리 편의시설', '휴가철'),

-- P-S-G-B (즉흥적, 안전한, 그룹, 절약형)
('PSGB', '소박한 동반자', '그룹과 함께 즉흥적이고 편안하며 경제적인 여행을 즐기는 타입', '친구들과의 소박하고 편안한 여행', '펜션, 글램핑, 근교 여행', '그룹 펜션, 공동 취사, 무료 체험', '비성수기 주말');

-- 매너 평가 테이블 생성
CREATE TABLE IF NOT EXISTS manner_evaluations (
    evaluation_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '평가 고유 번호',
    evaluator_id VARCHAR(50) NOT NULL COMMENT '평가자 ID',
    target_id VARCHAR(50) NOT NULL COMMENT '피평가자 ID', 
    travel_plan_id INT COMMENT '관련 여행 계획 ID',
    manner_score DECIMAL(3,1) NOT NULL COMMENT '매너 점수 (0.0-10.0)',
    evaluation_comment TEXT COMMENT '평가 코멘트',
    evaluation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '평가 일시',
    FOREIGN KEY (evaluator_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (target_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE SET NULL,
    INDEX idx_target_id (target_id),
    INDEX idx_evaluator_id (evaluator_id),
    INDEX idx_evaluation_date (evaluation_date),
    UNIQUE KEY unique_evaluation (evaluator_id, target_id, travel_plan_id)
) COMMENT = '사용자 매너 평가 테이블';

-- 기본 매너 평가 데이터 삽입 (test11 사용자용)
INSERT IGNORE INTO member (user_id, user_password, user_name, user_email) VALUES
('test11', 'test123', 'test11', 'test11@example.com');

-- test11 사용자의 MBTI 테스트 결과 삽입
INSERT IGNORE INTO user_travel_mbti (user_id, mbti_type, answers) VALUES
('test11', 'PAIB', '{"q1":"B","q2":"B","q3":"A","q4":"A","q5":"A","q6":"A","q7":"B","q8":"B"}');

-- test11 사용자의 매너 평가 삽입
INSERT IGNORE INTO manner_evaluations (evaluator_id, target_id, manner_score, evaluation_comment) VALUES
('testuser1', 'test11', 8.5, '매우 친절하고 시간약속을 잘 지켜요'),
('testuser2', 'test11', 9.0, '여행 매너가 정말 좋아요!'),
('admin', 'test11', 8.0, '배려심이 많고 좋은 여행 동반자');