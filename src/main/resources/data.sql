-- 테스트 회원 데이터 삽입
-- 비밀번호는 BCrypt로 암호화됨
-- testuser1, testuser2 비밀번호: password
-- admin 비밀번호: admin
-- 123456 비밀번호: 123456
INSERT IGNORE INTO member (user_id, user_password, user_name, user_email, user_role, account_status, nickname, manner_temperature) VALUES
('testuser1', '$2a$10$N9qo8uLOickgx2ZMRZoMye/IKbV0JZpqpvWRd2p5/rD0YzCy.qjKa', '테스트사용자1', 'test1@example.com', 'USER', 'ACTIVE', '테스트1', 36.5),
('testuser2', '$2a$10$N9qo8uLOickgx2ZMRZoMye/IKbV0JZpqpvWRd2p5/rD0YzCy.qjKa', '테스트사용자2', 'test2@example.com', 'USER', 'ACTIVE', '테스트2', 36.5),
('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8.jOCH.yBKCsYTbHMe', '관리자', 'admin@example.com', 'ADMIN', 'ACTIVE', '관리자', 36.5),
('123456', '$2a$10$5Z9p3zstXEgKLLh0ujGbVup4pN7UHH3FfQbV.lGBqQKZvZ3m0pv0S', '관리자2', 'admin2@example.com', 'ADMIN', 'ACTIVE', '관리자2', 36.5);

-- 테스트 여행 계획 데이터 삽입
INSERT IGNORE INTO travel_plan (plan_title, plan_destination, plan_start_date, plan_end_date, plan_budget, plan_content, plan_writer) VALUES
('제주도 힐링 여행', '제주도', '2025-09-01', '2025-09-03', 500000, '제주도에서 힐링하는 2박 3일 여행', 'testuser1'),
('부산 바다 여행', '부산', '2025-08-15', '2025-08-17', 300000, '부산 해변과 맛집 투어', 'testuser2'),
('서울 문화 탐방', '서울', '2025-10-10', '2025-10-12', 400000, '서울의 문화유산과 현대문화 체험', 'admin'),
('강릉 커피 여행', '강릉', '2025-11-05', '2025-11-07', 350000, '강릉 커피거리와 바다 여행', 'testuser1');

-- 채팅 메시지 테이블 생성
CREATE TABLE IF NOT EXISTS chat_messages (
    message_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    travel_plan_id INT NOT NULL COMMENT '여행 계획 ID',
    sender_id VARCHAR(50) NOT NULL COMMENT '발신자 ID',
    sender_name VARCHAR(100) NOT NULL COMMENT '발신자 이름',
    message_content TEXT NOT NULL COMMENT '메시지 내용',
    message_type VARCHAR(20) DEFAULT 'CHAT' COMMENT '메시지 타입 (CHAT, JOIN, LEAVE)',
    sent_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '전송 시간',
    CONSTRAINT FK_CHAT_TRAVEL_PLAN FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    CONSTRAINT FK_CHAT_SENDER FOREIGN KEY (sender_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 채팅 메시지 인덱스 생성
CREATE INDEX IF NOT EXISTS IDX_CHAT_TRAVEL_PLAN ON chat_messages(travel_plan_id);
CREATE INDEX IF NOT EXISTS IDX_CHAT_SENDER ON chat_messages(sender_id);
CREATE INDEX IF NOT EXISTS IDX_CHAT_SENT_TIME ON chat_messages(sent_time);

-- 여행 참여자 테이블 생성 (채팅 기능을 위해 필요)
CREATE TABLE IF NOT EXISTS travel_participants (
    participant_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    travel_plan_id BIGINT NOT NULL COMMENT '여행 계획 ID',
    user_id VARCHAR(50) NOT NULL,
    joined_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    CONSTRAINT FK_PARTICIPANT_PLAN FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    CONSTRAINT FK_USER_ID_PARTICIPANT FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    CONSTRAINT UK_TRAVEL_USER UNIQUE KEY (travel_plan_id, user_id)
);

-- 샘플 채팅 메시지 삽입
INSERT IGNORE INTO chat_messages (travel_plan_id, sender_id, sender_name, message_content, message_type) VALUES
(1, 'testuser1', '테스트사용자1', '안녕하세요! 제주도 여행 기대됩니다.', 'CHAT'),
(1, 'testuser2', '테스트사용자2', '저도 함께 참여하고 싶어요!', 'CHAT'),
(1, 'admin', '관리자', '모두 환영합니다. 즐거운 여행 되세요!', 'CHAT');

-- 가이드 신청 샘플 데이터 (승인됨)
INSERT IGNORE INTO guide_applications (user_id, region, address, phone, specialty_region, specialty_theme, specialty_area, introduction, greeting_message, status) VALUES
('testuser1', '서울', '서울시 강남구', '010-1234-5678', '서울/경기', '문화/역사', '고궁 투어', '서울의 역사와 문화를 깊이 있게 안내해드립니다. 10년 경력의 전문 가이드입니다.', '안녕하세요! 서울 문화 가이드 테스트사용자1입니다.', 'approved'),
('testuser2', '부산', '부산시 해운대구', '010-2345-6789', '부산/경남', '자연/바다', '해양 투어', '부산의 아름다운 바다와 해양 문화를 소개합니다. 바다를 사랑하는 가이드입니다.', '부산의 바다로 여러분을 초대합니다!', 'approved');

-- 승인된 가이드 데이터
INSERT IGNORE INTO guides (member_id, specialties, available_areas, introduction, languages, hourly_rate, guide_status, rating) VALUES
('testuser1', '서울/경기, 문화/역사, 고궁 투어', '서울', '서울의 역사와 문화를 깊이 있게 안내해드립니다. 10년 경력의 전문 가이드입니다.', 'Korean', 50000, 'ACTIVE', 4.8),
('testuser2', '부산/경남, 자연/바다, 해양 투어', '부산', '부산의 아름다운 바다와 해양 문화를 소개합니다. 바다를 사랑하는 가이드입니다.', 'Korean', 50000, 'ACTIVE', 4.5);

/*
-- ========================================
-- MBTI 데이터는 travel_mbti_schema.sql에 포함되어 있어 주석 처리
-- ========================================

-- MBTI 테스트 질문 데이터 삽입
INSERT IGNORE INTO mbti_questions (question_text, option_a, option_b, dimension, question_order) VALUES

-- E vs I (외향성 vs 내향성) - 4문항
('여행지에서 새로운 사람들과의 만남에 대해 어떻게 생각하시나요?', '현지인이나 다른 여행자들과 적극적으로 대화하고 친해지고 싶다', '필요할 때만 최소한의 대화를 하고, 혼자만의 시간을 더 선호한다', 'EI', 1),
('여행 계획을 세울 때 정보 수집은 어떻게 하시나요?', '여러 사람들에게 추천을 받고, 여행 커뮤니티나 SNS에서 활발히 정보를 구한다', '혼자서 차근차근 리서치하며, 신뢰할 만한 가이드북이나 공식 사이트를 참고한다', 'EI', 2),
('여행 중 저녁 시간을 보내는 방식은?', '현지 사람들과 어울리거나 다른 여행자들과 함께 시간을 보낸다', '호텔이나 숙소에서 조용히 하루를 정리하며 개인 시간을 갖는다', 'EI', 3),
('여행에서 에너지를 얻는 순간은?', '새로운 사람들과 대화하고 다양한 활동에 참여할 때', '혼자서 경치를 감상하거나 조용한 곳에서 사색할 때', 'EI', 4),

-- S vs N (감각 vs 직관) - 4문항
('여행지 선택 기준은 무엇인가요?', '유명한 관광지, 맛집, 실제 경험할 수 있는 구체적인 활동이 많은 곳', '독특한 문화나 숨겨진 의미, 영감을 줄 수 있는 특별한 분위기의 곳', 'SN', 5),
('여행 중 사진 촬영 스타일은?', '랜드마크, 음식, 경험한 순간들을 생생하게 기록하는 것을 좋아한다', '분위기나 느낌을 담은 예술적인 사진, 숨겨진 디테일을 포착하는 것을 선호한다', 'SN', 6),
('여행 중 기념품을 고를 때 중요한 것은?', '실용적이고 품질이 좋은 현지 특산품이나 공예품', '특별한 의미나 스토리가 있는 독특하고 상징적인 물건', 'SN', 7),
('여행지에서 가장 기억에 남는 경험은?', '맛있는 현지 음식, 아름다운 풍경, 재미있었던 액티비티', '현지 문화를 이해하게 된 순간, 예상치 못한 발견이나 깨달음', 'SN', 8),

-- T vs F (사고 vs 감정) - 4문항
('여행 일정을 짤 때 가장 중요하게 생각하는 것은?', '효율적인 동선, 비용 대비 효과, 시간 배분의 합리성', '함께 가는 사람들의 취향, 분위기, 모두가 즐거울 수 있는지', 'TF', 9),
('여행 중 예상치 못한 문제가 생겼을 때 대처 방식은?', '객관적으로 상황을 분석하고, 가장 논리적이고 효율적인 해결책을 찾는다', '일행의 기분을 먼저 살피고, 모두가 스트레스받지 않는 방향으로 해결한다', 'TF', 10),
('여행지에서 현지인과 갈등 상황이 생겼을 때?', '사실과 규칙에 근거해서 논리적으로 설명하고 해결하려 한다', '상대방의 입장을 이해하려 노력하고 감정적 상처가 없도록 조심스럽게 접근한다', 'TF', 11),
('여행 예산을 관리할 때 우선순위는?', '계획한 예산 내에서 가장 효율적으로 경험을 극대화한다', '일행이 원하는 것이 있다면 예산을 조금 초과하더라도 배려한다', 'TF', 12),

-- J vs P (판단 vs 인식) - 4문항
('여행 계획 수립 스타일은?', '출발 전에 상세한 일정표를 만들고, 예약할 것들은 미리 다 해둔다', '대략적인 틀만 정하고, 현지에서 상황에 따라 유연하게 결정한다', 'JP', 13),
('여행 중 시간 관리는?', '정해진 일정에 맞춰 움직이고, 시간을 효율적으로 활용하려 한다', '그때그때 기분과 상황에 따라 자유롭게 시간을 보낸다', 'JP', 14),
('여행 중 계획에 없던 흥미로운 장소를 발견했을 때?', '다음 여행 때 가기로 하고, 기존 계획을 우선 실행한다', '계획을 바꿔서라도 당장 그 장소를 탐험해본다', 'JP', 15),
('여행 준비물 챙기는 스타일은?', '체크리스트를 만들어서 빠뜨리는 것 없이 미리미리 준비한다', '여행 직전에 필요한 것들을 대충 챙기고, 부족한 건 현지에서 구입한다', 'JP', 16);

-- MBTI 결과 정보 삽입
INSERT IGNORE INTO mbti_results (mbti_type, type_name, type_description, travel_style, recommended_destinations, travel_tips, compatible_types) VALUES

('ESTJ', '체계적 여행 리더', '완벽한 계획과 효율적인 일정 관리로 그룹 여행의 리더 역할을 자연스럽게 맡는 타입', '철저한 사전 계획, 예산 관리, 일정 준수를 중시하며 안전하고 알찬 여행을 추구', '패키지투어, 역사 문화 탐방지, 잘 알려진 관광 도시', '상세한 여행 계획서 작성, 비상 계획 준비, 그룹 내 역할 분담', 'ISFP,INFP'),
('ESTP', '모험 추구 여행자', '즉흥적이고 활동적이며 스릴 넘치는 경험을 추구하는 타입', '순간의 재미와 모험을 중시하며 예측 불가능한 상황도 즐기는 자유로운 여행 스타일', '익스트림 스포츠 가능 지역, 축제 도시, 나이트라이프 활발한 곳', '유연한 일정 유지, 현지 액티비티 적극 참여, 안전 장비 준비', 'ISFJ,INFJ'),
('ESFJ', '배려심 많은 여행 동반자', '일행의 만족도를 최우선으로 생각하며 따뜻하고 배려 깊은 여행을 만드는 타입', '모든 구성원이 편안하고 즐거울 수 있도록 세심하게 배려하는 조화로운 여행 스타일', '가족 여행지, 온천 휴양지, 현지 홈스테이', '모든 구성원 의견 수렴, 편의시설 확인, 현지 예절 숙지', 'ISTP,INTP'),
('ESFP', '자유로운 여행 즐기미', '순간의 재미를 추구하고 사람들과의 만남을 소중히 여기는 타입', '자유롭고 즐거운 분위기를 만들며 즉흥적인 재미를 추구하는 활기찬 여행 스타일', '배낭여행지, 페스티벌 개최지, 해변 휴양지', '여유로운 일정 구성, 현지인과 교류 기회 마련, 재미있는 추억 만들기', 'ISTJ,INTJ'),

('ENTJ', '전략적 여행 기획자', '목표 지향적이고 효율성을 극대화하며 성취감을 추구하는 타입', '명확한 목표를 설정하고 최대한의 성과를 얻기 위한 전략적 여행 스타일', '비즈니스 허브 도시, 컨퍼런스 개최지, 도전적 목표가 있는 여행지', '구체적 목표 설정, 네트워킹 기회 활용, 성과 측정 가능한 활동', 'ISFP,INFP'),
('ENTP', '창의적 여행 탐험가', '새로운 아이디어와 독특한 경험을 추구하며 예측 불가능한 여행을 즐기는 타입', '창의적이고 혁신적인 경험을 통해 새로운 관점을 얻는 탐험적 여행 스타일', '오프로드 여행지, 창의적 워크숍 개최지, 예술 도시', '독특한 경험 추구, 현지 창작 활동 참여, 새로운 관점 탐구', 'ISFJ,INFJ'),
('ENFJ', '의미 있는 여행 가이드', '다른 사람과 함께 성장하고 문화적 이해를 추구하는 타입', '의미 있는 경험과 성장을 통해 타인에게도 긍정적 영향을 주는 교육적 여행 스타일', '봉사활동 가능 지역, 문화 교류 프로그램, 교육적 투어', '의미 있는 활동 계획, 현지 사회공헌 활동, 문화적 이해 증진', 'ISTP,INTP'),
('ENFP', '영감 가득한 여행 몽상가', '감성적 경험과 즉흥적 발견을 통해 영감을 얻는 타입', '감정적 교감과 영감을 통해 내적 성장을 추구하는 감성적 여행 스타일', '예술 도시, 영성 수양지, 자연과 하나되는 여행지', '감성적 경험 추구, 예술 활동 참여, 내적 성찰 시간 확보', 'ISTJ,INTJ'),

('ISTJ', '신중한 여행 계획자', '철저한 사전 준비와 안전한 여행을 추구하는 신중한 타입', '검증된 정보와 안전을 바탕으로 한 체계적이고 신중한 여행 스타일', '가이드북 추천 코스, 역사 유적지, 안전한 관광지', '철저한 사전 조사, 안전 계획 수립, 검증된 정보 활용', 'ESFP,ENFP'),
('ISTP', '실용적 여행 장인', '혼자만의 여행을 통해 실질적 경험과 기술적 관심사를 추구하는 타입', '실용적이고 기능적인 경험을 통해 개인적 만족을 추구하는 독립적 여행 스타일', '솔로 여행지, 기술 체험 가능 지역, 자연 서바이벌 환경', '개인 시간 확보, 실용적 활동 참여, 기술적 도전 추구', 'ESFJ,ENFJ'),
('ISFJ', '따뜻한 여행 보호자', '안전과 편안함을 추구하며 가족 중심의 전통적 관광을 선호하는 타입', '모든 구성원의 안전과 편안함을 최우선으로 하는 보호적 여행 스타일', '가족 여행지, 안전한 리조트, 전통 문화 체험지', '안전 확보 최우선, 편의시설 체크, 가족 친화적 환경 선택', 'ESTP,ENTP'),
('ISFP', '감성적 여행 예술가', '아름다움과 개인적 의미를 추구하며 조용한 힐링을 선호하는 타입', '개인적 가치와 미적 경험을 통해 내면의 평화를 찾는 예술적 여행 스타일', '예술 도시, 자연 경관 명소, 조용한 힐링 여행지', '개인적 의미 추구, 미적 경험 중시, 조용한 환경 선택', 'ESTJ,ENTJ'),

('INTJ', '독립적 여행 전략가', '철저한 개인 연구와 깊이 있는 탐구를 통한 효율적 계획을 추구하는 타입', '개인적 관심사를 바탕으로 한 전략적이고 독립적인 지적 여행 스타일', '박물관 투어, 역사 연구 여행지, 개인 맞춤 여행', '개인 연구 기반 계획, 지적 호기심 충족, 독립적 탐구 활동', 'ESFP,ENFP'),
('INTP', '탐구적 여행 분석가', '지적 호기심과 이론적 관심을 바탕으로 독특한 관점을 추구하는 타입', '분석적 사고와 이론적 탐구를 통해 새로운 지식을 얻는 학구적 여행 스타일', '과학 박물관, 철학적 의미 있는 장소, 연구 중심 여행지', '지적 탐구 활동, 이론적 관심사 추구, 분석적 관찰', 'ESFJ,ENFJ'),
('INFJ', '성찰적 여행 몽상가', '내적 성장과 의미 있는 경험을 통한 영적 여행을 추구하는 타입', '깊은 성찰과 영적 경험을 통해 인생의 의미를 탐구하는 내적 여행 스타일', '명상 여행지, 성지 순례지, 자아 발견 여행지', '내적 성찰 시간 확보, 영적 경험 추구, 의미 있는 만남', 'ESTP,ENTP'),
('INFP', '진정성 있는 여행 탐험가', '개인적 가치와 진정한 경험을 통한 감정적 연결을 추구하는 타입', '개인적 가치와 신념을 바탕으로 한 진정성 있는 대안적 여행 스타일', '대안 관광지, 로컬 체험 가능 지역, 자연과 하나되는 여행지', '개인적 가치 추구, 진정한 현지 경험, 자연과의 교감', 'ESTJ,ENTJ');
*/

-- 쪽지(메시지) 테이블 생성
CREATE TABLE IF NOT EXISTS messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id VARCHAR(50) NOT NULL,
    receiver_id VARCHAR(50) NOT NULL,
    message_title VARCHAR(200) NOT NULL,
    message_content TEXT NOT NULL,
    sent_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_date DATETIME DEFAULT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sender_deleted BOOLEAN DEFAULT FALSE,
    receiver_deleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_receiver_id (receiver_id),
    INDEX idx_sender_id (sender_id),
    INDEX idx_is_read (is_read),
    INDEX idx_sent_date (sent_date)
);