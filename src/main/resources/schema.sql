
-- member 테이블: 플랫폼 사용자 정보를 관리하는 회원 테이블
-- 사용자의 기본 정보를 저장하여 여행 매칭 서비스 제공
CREATE TABLE IF NOT EXISTS member (
    user_id VARCHAR(50) PRIMARY KEY COMMENT '사용자 고유 아이디 (로그인용)',
    user_password VARCHAR(255) NOT NULL COMMENT '암호화된 사용자 비밀번호',
    user_name VARCHAR(50) NOT NULL COMMENT '사용자 실명',
    user_email VARCHAR(100) UNIQUE NOT NULL COMMENT '사용자 이메일 주소 (중복 불가)',
    user_mbti VARCHAR(50) COMMENT '사용자 MBTI 유형',
    nickname VARCHAR(50) COMMENT '사용자 닉네임',
    gender VARCHAR(10) COMMENT '성별',
    age INT COMMENT '나이',
    manner_temperature DECIMAL(4,2) DEFAULT 36.5 COMMENT '매너 온도',
    profile_image VARCHAR(255) COMMENT '프로필 이미지 경로',
    bio TEXT COMMENT '자기소개',
    user_role VARCHAR(20) DEFAULT 'USER' COMMENT '사용자 역할 (USER: 일반사용자, ADMIN: 관리자)',
    account_status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '계정 상태 (ACTIVE: 활성, SUSPENDED: 정지)',
    user_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '회원 가입일시'
) COMMENT = '회원 정보 테이블 - 사용자 기본 정보 관리';

-- travel_plan 테이블: 사용자가 작성한 여행 계획 정보를 저장하는 테이블
-- 여행 목적지, 일정, 예산 등을 기록하여 동반자 매칭 및 여행 계획 공유 기능 제공
CREATE TABLE IF NOT EXISTS travel_plan (
    plan_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '여행 계획 고유 식별번호',
    plan_title VARCHAR(255) NOT NULL COMMENT '여행 계획 제목',
    plan_destination VARCHAR(255) NOT NULL COMMENT '여행 목적지',
    plan_start_date DATE NOT NULL COMMENT '여행 시작일',
    plan_end_date DATE NOT NULL COMMENT '여행 종료일',
    plan_budget INT COMMENT '여행 예산 (단위: 원)',
    plan_content TEXT COMMENT '여행 계획 상세 내용',
    plan_writer VARCHAR(50) NOT NULL COMMENT '여행 계획 작성자 (회원 아이디)',
    plan_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '여행 계획 작성일시',
    FOREIGN KEY (plan_writer) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT = '여행 계획 테이블 - 사용자별 여행 일정 및 예산 관리';

-- board 테이블: 커뮤니티 게시판 글을 저장하는 테이블
-- 여행 정보 공유, 동반자 모집, 여행 후기 등 다양한 게시글 관리
CREATE TABLE IF NOT EXISTS board (
    board_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '게시글 고유 식별번호',
    board_title VARCHAR(255) NOT NULL COMMENT '게시글 제목',
    board_content TEXT NOT NULL COMMENT '게시글 본문 내용',
    board_writer VARCHAR(50) NOT NULL COMMENT '게시글 작성자 (회원 아이디)',
    board_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '게시글 작성일시',
    FOREIGN KEY (board_writer) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT = '커뮤니티 게시판 테이블 - 여행 정보 공유 및 동반자 모집 게시글 관리';

-- comments 테이블: 게시글에 달린 댓글을 저장하는 테이블
-- 게시글에 대한 사용자 반응, 질문, 추가 정보 등을 관리하여 활발한 커뮤니티 소통 지원
CREATE TABLE IF NOT EXISTS comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '댓글 고유 식별번호',
    board_id INT NOT NULL COMMENT '댓글이 달린 게시글 번호 (게시판 테이블 참조)',
    comment_content VARCHAR(1000) NOT NULL COMMENT '댓글 내용',
    comment_writer VARCHAR(50) NOT NULL COMMENT '댓글 작성자 (회원 아이디)',
    comment_regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '댓글 작성일시',
    FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE,
    FOREIGN KEY (comment_writer) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT = '게시글 댓글 테이블 - 커뮤니티 소통 및 상호작용 관리';

-- travel_participants 테이블: 여행 계획에 참여한 사용자 정보를 저장하는 테이블
-- 여행 계획별 참여자 관리 및 참여 상태 추적을 위한 테이블
CREATE TABLE IF NOT EXISTS travel_participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '참여자 고유 식별번호',
    travel_plan_id INT NOT NULL COMMENT '참여한 여행 계획 번호 (여행 계획 테이블 참조)',
    user_id VARCHAR(50) NOT NULL COMMENT '참여한 사용자 아이디 (회원 테이블 참조)',
    joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '참여 신청일시',
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '참여 상태 (ACTIVE: 활성, CANCELLED: 취소)',
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_participation (travel_plan_id, user_id)
) COMMENT = '여행 계획 참여자 테이블 - 여행별 참여 사용자 관리';

-- favorites 테이블: 사용자가 찜한 여행계획 및 커뮤니티 게시글을 저장하는 테이블
-- 통합된 찜하기 기능을 제공하여 사용자별 관심 콘텐츠 관리
CREATE TABLE IF NOT EXISTS favorites (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '찜하기 고유 식별번호',
    user_id VARCHAR(50) NOT NULL COMMENT '찜한 사용자 아이디 (회원 테이블 참조)',
    item_type VARCHAR(20) NOT NULL COMMENT '찜한 항목 유형 (TRAVEL_PLAN: 여행계획, BOARD: 커뮤니티 게시글)',
    item_id INT NOT NULL COMMENT '찜한 항목의 고유 번호 (여행계획 ID 또는 게시글 ID)',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '찜하기 등록일시',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, item_type, item_id)
) COMMENT = '찜하기 테이블 - 사용자별 관심 여행계획 및 커뮤니티 게시글 관리';


-- 인덱스 생성 (성능 향상을 위함)
CREATE INDEX IF NOT EXISTS idx_travel_plan_writer ON travel_plan(plan_writer);
CREATE INDEX IF NOT EXISTS idx_travel_plan_dates ON travel_plan(plan_start_date, plan_end_date);
CREATE INDEX IF NOT EXISTS idx_board_writer ON board(board_writer);
CREATE INDEX IF NOT EXISTS idx_board_regdate ON board(board_regdate DESC);
CREATE INDEX IF NOT EXISTS idx_comments_board ON comments(board_id);
CREATE INDEX IF NOT EXISTS idx_comments_writer ON comments(comment_writer);
CREATE INDEX IF NOT EXISTS idx_travel_participants_plan ON travel_participants(travel_plan_id);
CREATE INDEX IF NOT EXISTS idx_travel_participants_user ON travel_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_type_item ON favorites(item_type, item_id);

-- travel_join_requests 테이블: 동행 참여 신청 관리 테이블
-- 여행 계획 작성자가 참여 신청을 승인/거절할 수 있도록 하는 테이블
CREATE TABLE IF NOT EXISTS travel_join_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '참여 신청 고유 식별번호',
    travel_plan_id INT NOT NULL COMMENT '참여 신청한 여행 계획 번호',
    requester_id VARCHAR(50) NOT NULL COMMENT '참여 신청자 아이디',
    request_message TEXT COMMENT '참여 신청 메시지',
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '신청일시',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT '신청 상태 (PENDING: 대기중, APPROVED: 승인됨, REJECTED: 거절됨)',
    response_message TEXT COMMENT '작성자 응답 메시지',
    response_date TIMESTAMP NULL COMMENT '응답일시',
    responded_by VARCHAR(50) COMMENT '응답자 (여행 계획 작성자)',
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (requester_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (responded_by) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_request (travel_plan_id, requester_id)
) COMMENT = '동행 참여 신청 관리 테이블';

-- notifications 테이블: 알림 관리 테이블
-- 참여 신청, 승인/거절 등 다양한 알림을 관리하는 테이블
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '알림 고유 식별번호',
    user_id VARCHAR(50) NOT NULL COMMENT '알림을 받을 사용자 아이디',
    type VARCHAR(50) NOT NULL COMMENT '알림 유형 (JOIN_REQUEST: 참여신청, JOIN_APPROVED: 승인, JOIN_REJECTED: 거절)',
    title VARCHAR(255) NOT NULL COMMENT '알림 제목',
    message TEXT NOT NULL COMMENT '알림 내용',
    related_id INT COMMENT '관련 항목 ID (여행계획 ID, 신청 ID 등)',
    is_read BOOLEAN DEFAULT FALSE COMMENT '읽음 여부',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '알림 생성일시',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT = '사용자 알림 관리 테이블';

-- user_manner_stats 테이블: 사용자 매너 통계 테이블
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

-- 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_travel_join_requests_plan ON travel_join_requests(travel_plan_id);
CREATE INDEX IF NOT EXISTS idx_travel_join_requests_requester ON travel_join_requests(requester_id);
CREATE INDEX IF NOT EXISTS idx_travel_join_requests_status ON travel_join_requests(status);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_manner_score ON user_manner_stats(average_manner_score);
CREATE INDEX IF NOT EXISTS idx_last_updated ON user_manner_stats(last_updated);
