-- ============================================================
-- Wanderlust Database Schema
-- 여행 동행 매칭 플랫폼 전체 데이터베이스 스키마
-- ============================================================
-- Database: MariaDB 11.4.5
-- Character Set: utf8mb4
-- Collation: utf8mb4_unicode_ci
-- ============================================================

-- 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS wanderlust
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE wanderlust;

-- ============================================================
-- 1. 회원 관리 (Member Management)
-- ============================================================

-- 1.1 회원 테이블
CREATE TABLE IF NOT EXISTS member (
    user_id VARCHAR(50) PRIMARY KEY COMMENT '사용자 ID (PK)',
    user_password VARCHAR(255) NOT NULL COMMENT '비밀번호 (암호화)',
    user_name VARCHAR(100) NOT NULL COMMENT '사용자 이름',
    user_email VARCHAR(255) NOT NULL UNIQUE COMMENT '이메일 (고유)',
    user_mbti VARCHAR(4) COMMENT 'MBTI 유형',
    nickname VARCHAR(50) UNIQUE COMMENT '닉네임 (고유)',
    gender VARCHAR(10) COMMENT '성별',
    age INT COMMENT '나이',
    manner_temperature DECIMAL(4,1) DEFAULT 36.5 COMMENT '매너 온도',
    profile_image VARCHAR(500) COMMENT '프로필 이미지 경로',
    bio TEXT COMMENT '자기소개',
    user_regdate DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '가입일',
    user_role VARCHAR(20) DEFAULT 'USER' COMMENT '권한 (USER/ADMIN)',
    account_status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '계정 상태 (ACTIVE/SUSPENDED/DELETED)'
) COMMENT '회원 정보';

-- 1.2 이메일 인증 테이블
CREATE TABLE IF NOT EXISTS email_verification (
    verification_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '인증 ID',
    email VARCHAR(255) NOT NULL COMMENT '이메일',
    verification_code VARCHAR(10) NOT NULL COMMENT '인증 코드',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성 시간',
    expires_at DATETIME NOT NULL COMMENT '만료 시간',
    is_verified BOOLEAN DEFAULT FALSE COMMENT '인증 완료 여부',
    attempt_count INT DEFAULT 0 COMMENT '시도 횟수',
    INDEX idx_email (email),
    INDEX idx_expires (expires_at)
) COMMENT '이메일 인증';

-- ============================================================
-- 2. 여행 계획 (Travel Plan)
-- ============================================================

-- 2.1 여행 계획 테이블 (메인)
CREATE TABLE IF NOT EXISTS travel_plan (
    plan_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '여행 계획 ID',
    plan_title VARCHAR(200) NOT NULL COMMENT '제목',
    plan_destination VARCHAR(200) NOT NULL COMMENT '목적지',
    plan_start_date DATE COMMENT '시작일',
    plan_end_date DATE COMMENT '종료일',
    plan_budget INT COMMENT '예산',
    max_participants INT DEFAULT 4 COMMENT '최대 참가자 수',
    plan_content TEXT COMMENT '상세 내용',
    plan_writer VARCHAR(50) NOT NULL COMMENT '작성자 ID',
    plan_tags VARCHAR(500) COMMENT '태그 (콤마 구분)',
    plan_image VARCHAR(500) COMMENT '대표 이미지',
    plan_views INT DEFAULT 0 COMMENT '조회수',
    plan_status VARCHAR(20) DEFAULT 'RECRUITING' COMMENT '상태 (RECRUITING/CONFIRMED/COMPLETED/CANCELLED)',
    completed_date DATETIME COMMENT '완료일',
    plan_regdate DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '작성일',
    FOREIGN KEY (plan_writer) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_destination (plan_destination),
    INDEX idx_writer (plan_writer),
    INDEX idx_status (plan_status)
) COMMENT '여행 계획';

-- 2.2 여행 참가자 테이블
CREATE TABLE IF NOT EXISTS travel_participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '참가자 ID',
    travel_plan_id INT NOT NULL COMMENT '여행 계획 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '참가자 ID',
    joined_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '참가일',
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '상태 (ACTIVE/WITHDRAWN)',
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_participant (travel_plan_id, user_id)
) COMMENT '여행 참가자';

-- 2.3 여행 동행 신청 테이블
CREATE TABLE IF NOT EXISTS travel_join_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '신청 ID',
    travel_plan_id INT NOT NULL COMMENT '여행 계획 ID',
    requester_id VARCHAR(50) NOT NULL COMMENT '신청자 ID',
    request_message TEXT COMMENT '신청 메시지',
    request_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '신청일',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT '상태 (PENDING/APPROVED/REJECTED)',
    response_message TEXT COMMENT '응답 메시지',
    response_date DATETIME COMMENT '응답일',
    responded_by VARCHAR(50) COMMENT '응답자 ID',
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (requester_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_plan (travel_plan_id),
    INDEX idx_requester (requester_id),
    INDEX idx_status (status)
) COMMENT '여행 동행 신청';

-- 2.4 TRAVEL 테이블 (레거시 호환)
CREATE TABLE IF NOT EXISTS TRAVEL (
    TRAVEL_ID INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID VARCHAR(50),
    TRAVEL_TITLE VARCHAR(200),
    TRAVEL_DESTINATION VARCHAR(200),
    TRAVEL_CONTENT TEXT,
    TRAVEL_START_DATE DATE,
    TRAVEL_END_DATE DATE,
    MAX_PARTICIPANTS INT DEFAULT 4,
    PARTICIPANT_COUNT INT DEFAULT 0,
    TRAVEL_STATUS VARCHAR(20) DEFAULT 'RECRUITING',
    CREATED_DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (USER_ID) REFERENCES member(user_id) ON DELETE SET NULL
) COMMENT '여행 (레거시)';

-- ============================================================
-- 3. AI 여행 계획 (AI Travel Plan)
-- ============================================================

-- 3.1 AI 여행 계획 테이블
CREATE TABLE IF NOT EXISTS ai_travel_plans (
    plan_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'AI 계획 ID',
    user_id VARCHAR(50) COMMENT '사용자 ID',
    title VARCHAR(200) NOT NULL COMMENT '제목',
    destination VARCHAR(200) COMMENT '목적지',
    start_date DATE COMMENT '시작일',
    end_date DATE COMMENT '종료일',
    duration INT COMMENT '기간 (일)',
    budget VARCHAR(50) COMMENT '예산',
    max_participants INT COMMENT '최대 참가자 수',
    travel_style VARCHAR(100) COMMENT '여행 스타일',
    plan_content TEXT COMMENT 'AI 생성 계획 내용 (JSON/TEXT)',
    is_template BOOLEAN DEFAULT FALSE COMMENT '템플릿 여부',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE SET NULL,
    INDEX idx_user (user_id)
) COMMENT 'AI 여행 계획';

-- 3.2 계획 태그 테이블
CREATE TABLE IF NOT EXISTS plan_tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '태그 ID',
    plan_id BIGINT NOT NULL COMMENT '계획 ID',
    tag_name VARCHAR(50) NOT NULL COMMENT '태그명',
    FOREIGN KEY (plan_id) REFERENCES ai_travel_plans(plan_id) ON DELETE CASCADE,
    INDEX idx_plan (plan_id),
    INDEX idx_tag (tag_name)
) COMMENT '계획 태그';

-- 3.3 AI 여행 계획 태그 연결 테이블
CREATE TABLE IF NOT EXISTS ai_travel_plan_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    plan_id BIGINT NOT NULL,
    tag_id INT NOT NULL,
    FOREIGN KEY (plan_id) REFERENCES ai_travel_plans(plan_id) ON DELETE CASCADE,
    UNIQUE KEY unique_plan_tag (plan_id, tag_id)
) COMMENT 'AI 계획-태그 연결';

-- ============================================================
-- 4. 커뮤니티 (Community)
-- ============================================================

-- 4.1 게시판 테이블
CREATE TABLE IF NOT EXISTS board (
    board_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '게시글 ID',
    board_title VARCHAR(200) NOT NULL COMMENT '제목',
    board_category VARCHAR(50) COMMENT '카테고리',
    board_content TEXT COMMENT '내용',
    board_image VARCHAR(500) COMMENT '이미지 경로',
    board_writer VARCHAR(50) NOT NULL COMMENT '작성자 ID',
    board_regdate DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '작성일',
    board_views INT DEFAULT 0 COMMENT '조회수',
    board_likes INT DEFAULT 0 COMMENT '좋아요 수',
    board_dislikes INT DEFAULT 0 COMMENT '싫어요 수',
    FOREIGN KEY (board_writer) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_category (board_category),
    INDEX idx_writer (board_writer),
    INDEX idx_regdate (board_regdate)
) COMMENT '게시판';

-- 4.2 댓글 테이블
CREATE TABLE IF NOT EXISTS comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '댓글 ID',
    board_id INT NOT NULL COMMENT '게시글 ID',
    comment_content TEXT NOT NULL COMMENT '내용',
    comment_writer VARCHAR(50) NOT NULL COMMENT '작성자 ID',
    comment_regdate DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '작성일',
    FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE,
    FOREIGN KEY (comment_writer) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_board (board_id)
) COMMENT '댓글';

-- 4.3 게시글 좋아요 테이블
CREATE TABLE IF NOT EXISTS board_likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    board_id INT NOT NULL COMMENT '게시글 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_like (board_id, user_id)
) COMMENT '게시글 좋아요';

-- 4.4 게시글 싫어요 테이블
CREATE TABLE IF NOT EXISTS board_dislikes (
    dislike_id INT AUTO_INCREMENT PRIMARY KEY,
    board_id INT NOT NULL COMMENT '게시글 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_dislike (board_id, user_id)
) COMMENT '게시글 싫어요';

-- ============================================================
-- 5. 찜하기/즐겨찾기 (Favorites)
-- ============================================================

-- 5.1 찜하기 테이블
CREATE TABLE IF NOT EXISTS favorites (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '찜 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    item_type VARCHAR(20) NOT NULL COMMENT '항목 유형 (TRAVEL_PLAN/BOARD)',
    item_id INT NOT NULL COMMENT '항목 ID',
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorite (user_id, item_type, item_id),
    INDEX idx_item (item_type, item_id)
) COMMENT '찜하기';

-- ============================================================
-- 6. 채팅 (Chat)
-- ============================================================

-- 6.1 채팅 메시지 테이블
CREATE TABLE IF NOT EXISTS chat_messages (
    message_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '메시지 ID',
    travel_plan_id INT NOT NULL COMMENT '여행 계획 ID',
    sender_id VARCHAR(50) NOT NULL COMMENT '발신자 ID',
    sender_name VARCHAR(100) COMMENT '발신자 이름',
    message_content TEXT COMMENT '메시지 내용',
    message_type VARCHAR(20) DEFAULT 'TEXT' COMMENT '메시지 유형 (TEXT/IMAGE/FILE/ENTER/LEAVE)',
    sent_time DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '발송 시간',
    file_name VARCHAR(255) COMMENT '파일명',
    file_path VARCHAR(500) COMMENT '파일 경로',
    file_size VARCHAR(50) COMMENT '파일 크기',
    original_filename VARCHAR(255) COMMENT '원본 파일명',
    file_type VARCHAR(100) COMMENT '파일 MIME 타입',
    file_size_bytes BIGINT COMMENT '파일 크기 (바이트)',
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE,
    FOREIGN KEY (sender_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_plan (travel_plan_id),
    INDEX idx_time (sent_time)
) COMMENT '채팅 메시지';

-- ============================================================
-- 7. 쪽지 (Messages)
-- ============================================================

-- 7.1 쪽지 테이블
CREATE TABLE IF NOT EXISTS messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '쪽지 ID',
    sender_id VARCHAR(50) NOT NULL COMMENT '발신자 ID',
    receiver_id VARCHAR(50) NOT NULL COMMENT '수신자 ID',
    message_title VARCHAR(200) NOT NULL COMMENT '제목',
    message_content TEXT COMMENT '내용',
    sent_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '발송일',
    read_date DATETIME COMMENT '읽은 날짜',
    is_read BOOLEAN DEFAULT FALSE COMMENT '읽음 여부',
    sender_deleted BOOLEAN DEFAULT FALSE COMMENT '발신자 삭제 여부',
    receiver_deleted BOOLEAN DEFAULT FALSE COMMENT '수신자 삭제 여부',
    FOREIGN KEY (sender_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_sender (sender_id),
    INDEX idx_receiver (receiver_id)
) COMMENT '쪽지';

-- ============================================================
-- 8. 알림 (Notifications)
-- ============================================================

-- 8.1 알림 테이블
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '알림 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '수신자 ID',
    type VARCHAR(50) NOT NULL COMMENT '알림 유형 (JOIN_REQUEST/JOIN_APPROVED/JOIN_REJECTED/CHAT/SYSTEM)',
    title VARCHAR(200) COMMENT '제목',
    message TEXT COMMENT '내용',
    related_id INT COMMENT '관련 항목 ID',
    is_read BOOLEAN DEFAULT FALSE COMMENT '읽음 여부',
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read)
) COMMENT '알림';

-- ============================================================
-- 9. 매너 평가 (Manner Evaluation)
-- ============================================================

-- 9.1 매너 평가 테이블
CREATE TABLE IF NOT EXISTS manner_evaluation (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '평가 ID',
    evaluator_id VARCHAR(50) NOT NULL COMMENT '평가자 ID',
    evaluated_id VARCHAR(50) NOT NULL COMMENT '평가 대상 ID',
    travel_plan_id INT COMMENT '여행 계획 ID',
    score DECIMAL(3,1) NOT NULL COMMENT '점수 (0-5)',
    comment TEXT COMMENT '코멘트',
    evaluation_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '평가일',
    is_like BOOLEAN COMMENT '좋아요 여부',
    FOREIGN KEY (evaluator_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (evaluated_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE SET NULL,
    INDEX idx_evaluated (evaluated_id)
) COMMENT '매너 평가';

-- 9.2 사용자 매너 통계 테이블
CREATE TABLE IF NOT EXISTS user_manner_stats (
    stats_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '통계 ID',
    user_id VARCHAR(50) NOT NULL UNIQUE COMMENT '사용자 ID',
    average_manner_score DECIMAL(4,2) DEFAULT 36.5 COMMENT '평균 매너 점수',
    total_evaluations INT DEFAULT 0 COMMENT '총 평가 수',
    total_likes INT DEFAULT 0 COMMENT '총 좋아요',
    total_dislikes INT DEFAULT 0 COMMENT '총 싫어요',
    completed_travels INT DEFAULT 0 COMMENT '완료된 여행 수',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '업데이트 시간',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT '사용자 매너 통계';

-- ============================================================
-- 10. 여행 MBTI (Travel MBTI)
-- ============================================================

-- 10.1 여행 MBTI 질문 테이블
CREATE TABLE IF NOT EXISTS travel_mbti_questions (
    question_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '질문 ID',
    question_text TEXT NOT NULL COMMENT '질문 내용',
    option_a TEXT NOT NULL COMMENT '선택지 A',
    option_b TEXT NOT NULL COMMENT '선택지 B',
    dimension VARCHAR(2) NOT NULL COMMENT '차원 (EI/SN/TF/JP)',
    is_active BOOLEAN DEFAULT TRUE COMMENT '활성화 여부'
) COMMENT '여행 MBTI 질문';

-- 10.2 여행 MBTI 결과 설명 테이블
CREATE TABLE IF NOT EXISTS travel_mbti_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '결과 ID',
    mbti_type VARCHAR(4) NOT NULL UNIQUE COMMENT 'MBTI 유형',
    title VARCHAR(100) NOT NULL COMMENT '결과 제목',
    description TEXT NOT NULL COMMENT '설명',
    travel_style TEXT COMMENT '여행 스타일',
    recommended_destinations TEXT COMMENT '추천 여행지'
) COMMENT '여행 MBTI 결과 설명';

-- 10.3 사용자 여행 MBTI 테이블
CREATE TABLE IF NOT EXISTS user_travel_mbti (
    id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    mbti_type VARCHAR(4) NOT NULL COMMENT 'MBTI 유형',
    answers TEXT COMMENT '답변 (JSON)',
    test_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '테스트 일시',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
) COMMENT '사용자 여행 MBTI';

-- ============================================================
-- 11. 가이드 (Guide)
-- ============================================================

-- 11.1 가이드 신청 테이블
CREATE TABLE IF NOT EXISTS guide_applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '신청 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    region VARCHAR(100) COMMENT '지역',
    address TEXT COMMENT '주소',
    phone VARCHAR(20) COMMENT '연락처',
    specialty_region VARCHAR(200) COMMENT '전문 지역',
    specialty_theme VARCHAR(200) COMMENT '전문 테마',
    specialty_area VARCHAR(200) COMMENT '전문 분야',
    introduction TEXT COMMENT '자기소개',
    greeting_message TEXT COMMENT '인사말',
    status VARCHAR(20) DEFAULT 'pending' COMMENT '상태 (pending/approved/rejected)',
    admin_comment TEXT COMMENT '관리자 코멘트',
    applied_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '신청일',
    reviewed_date DATETIME COMMENT '검토일',
    reviewed_by VARCHAR(50) COMMENT '검토자 ID',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_status (status)
) COMMENT '가이드 신청';

-- 11.2 가이드 테이블
CREATE TABLE IF NOT EXISTS guides (
    guide_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '가이드 ID',
    user_id VARCHAR(50) COMMENT '사용자 ID (레거시)',
    member_id VARCHAR(50) NOT NULL COMMENT '회원 ID',
    region VARCHAR(100) COMMENT '지역',
    address TEXT COMMENT '주소',
    phone VARCHAR(20) COMMENT '연락처',
    specialty_region VARCHAR(200) COMMENT '전문 지역',
    specialty_theme VARCHAR(200) COMMENT '전문 테마',
    specialty_area VARCHAR(200) COMMENT '전문 분야',
    introduction TEXT COMMENT '자기소개',
    rating DECIMAL(3,2) DEFAULT 0.00 COMMENT '평점',
    status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '상태',
    guide_status VARCHAR(20) DEFAULT 'ACTIVE' COMMENT '가이드 상태',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    FOREIGN KEY (member_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_member (member_id),
    INDEX idx_status (guide_status)
) COMMENT '가이드';

-- ============================================================
-- 12. 플레이리스트 (Playlist)
-- ============================================================

-- 12.1 사용자 플레이리스트 테이블
CREATE TABLE IF NOT EXISTS user_playlist (
    playlist_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '플레이리스트 ID',
    user_id VARCHAR(100) NOT NULL COMMENT '사용자 ID (또는 세션 ID)',
    playlist_name VARCHAR(200) NOT NULL COMMENT '플레이리스트 이름',
    destination VARCHAR(200) COMMENT '여행지',
    mood VARCHAR(100) COMMENT '분위기',
    total_songs INT DEFAULT 0 COMMENT '총 곡 수',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    INDEX idx_user (user_id)
) COMMENT '사용자 플레이리스트';

-- 12.2 플레이리스트 곡 테이블
CREATE TABLE IF NOT EXISTS playlist_songs (
    song_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '곡 ID',
    playlist_id INT NOT NULL COMMENT '플레이리스트 ID',
    song_title VARCHAR(300) NOT NULL COMMENT '곡 제목',
    artist VARCHAR(200) COMMENT '아티스트',
    album VARCHAR(200) COMMENT '앨범',
    genre VARCHAR(100) COMMENT '장르',
    mood VARCHAR(100) COMMENT '분위기',
    reason TEXT COMMENT '추천 이유',
    song_order INT DEFAULT 0 COMMENT '순서',
    FOREIGN KEY (playlist_id) REFERENCES user_playlist(playlist_id) ON DELETE CASCADE,
    INDEX idx_playlist (playlist_id)
) COMMENT '플레이리스트 곡';

-- ============================================================
-- 13. 여행 체크리스트/리마인더 (Checklist/Reminder)
-- ============================================================

-- 13.1 여행 체크리스트 테이블
CREATE TABLE IF NOT EXISTS travel_checklist (
    checklist_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '체크리스트 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    travel_plan_id INT COMMENT '여행 계획 ID',
    item_name VARCHAR(200) NOT NULL COMMENT '항목명',
    category VARCHAR(50) COMMENT '카테고리',
    is_checked BOOLEAN DEFAULT FALSE COMMENT '체크 여부',
    priority INT DEFAULT 0 COMMENT '우선순위',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE SET NULL,
    INDEX idx_user (user_id)
) COMMENT '여행 체크리스트';

-- 13.2 여행 리마인더 테이블
CREATE TABLE IF NOT EXISTS travel_reminder (
    reminder_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '리마인더 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    travel_plan_id INT COMMENT '여행 계획 ID',
    reminder_title VARCHAR(200) NOT NULL COMMENT '제목',
    reminder_content TEXT COMMENT '내용',
    reminder_date DATETIME NOT NULL COMMENT '리마인더 날짜',
    is_sent BOOLEAN DEFAULT FALSE COMMENT '발송 여부',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE SET NULL,
    INDEX idx_user (user_id)
) COMMENT '여행 리마인더';

-- ============================================================
-- 14. 사용자 활동 로그 (Activity Log)
-- ============================================================

-- 14.1 사용자 활동 로그 테이블
CREATE TABLE IF NOT EXISTS user_activity_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '로그 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    activity_type VARCHAR(50) NOT NULL COMMENT '활동 유형',
    activity_description TEXT COMMENT '활동 설명',
    related_id INT COMMENT '관련 ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_type (activity_type)
) COMMENT '사용자 활동 로그';

-- ============================================================
-- 15. 신고/리뷰 (Reports/Reviews)
-- ============================================================

-- 15.1 신고 테이블
CREATE TABLE IF NOT EXISTS reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '신고 ID',
    reporter_id VARCHAR(50) NOT NULL COMMENT '신고자 ID',
    reported_user_id VARCHAR(50) COMMENT '신고 대상 사용자 ID',
    report_type VARCHAR(50) NOT NULL COMMENT '신고 유형 (USER/POST/COMMENT)',
    target_id INT COMMENT '대상 ID',
    reason VARCHAR(200) NOT NULL COMMENT '신고 사유',
    description TEXT COMMENT '상세 설명',
    status VARCHAR(20) DEFAULT 'PENDING' COMMENT '처리 상태 (PENDING/RESOLVED/DISMISSED)',
    admin_comment TEXT COMMENT '관리자 코멘트',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    resolved_at DATETIME COMMENT '처리일',
    FOREIGN KEY (reporter_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reported_user_id) REFERENCES member(user_id) ON DELETE SET NULL,
    INDEX idx_status (status)
) COMMENT '신고';

-- 15.2 리뷰 테이블
CREATE TABLE IF NOT EXISTS reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '리뷰 ID',
    reviewer_id VARCHAR(50) NOT NULL COMMENT '리뷰어 ID',
    target_type VARCHAR(20) NOT NULL COMMENT '대상 유형 (GUIDE/TRAVEL)',
    target_id INT NOT NULL COMMENT '대상 ID',
    rating INT NOT NULL COMMENT '평점 (1-5)',
    content TEXT COMMENT '리뷰 내용',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '생성일',
    FOREIGN KEY (reviewer_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_target (target_type, target_id)
) COMMENT '리뷰';

-- ============================================================
-- 16. 배지 (Badges)
-- ============================================================

-- 16.1 배지 테이블
CREATE TABLE IF NOT EXISTS badges (
    badge_id INT AUTO_INCREMENT PRIMARY KEY COMMENT '배지 ID',
    badge_name VARCHAR(100) NOT NULL COMMENT '배지 이름',
    badge_description TEXT COMMENT '배지 설명',
    badge_icon VARCHAR(200) COMMENT '배지 아이콘',
    badge_criteria TEXT COMMENT '획득 조건'
) COMMENT '배지';

-- 16.2 사용자 배지 테이블
CREATE TABLE IF NOT EXISTS user_badges (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    badge_id INT NOT NULL COMMENT '배지 ID',
    earned_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '획득일',
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (badge_id) REFERENCES badges(badge_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_badge (user_id, badge_id)
) COMMENT '사용자 배지';

-- ============================================================
-- 17. AI 추천 시스템 (AI Recommendation)
-- ============================================================

-- 17.1 사용자 선호도 테이블
CREATE TABLE IF NOT EXISTS user_preferences (
    preference_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    preference_type VARCHAR(50) NOT NULL COMMENT '선호 유형',
    preference_value VARCHAR(200) COMMENT '선호 값',
    weight DECIMAL(3,2) DEFAULT 1.0 COMMENT '가중치',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id)
) COMMENT '사용자 선호도';

-- 17.2 매칭 피드백 테이블
CREATE TABLE IF NOT EXISTS matching_feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    matched_user_id VARCHAR(50) NOT NULL,
    travel_plan_id INT,
    feedback_type VARCHAR(20) NOT NULL COMMENT '피드백 유형 (POSITIVE/NEGATIVE)',
    feedback_reason TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (matched_user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT '매칭 피드백';

-- 17.3 MBTI 호환성 캐시 테이블
CREATE TABLE IF NOT EXISTS mbti_compatibility_cache (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mbti_type_1 VARCHAR(4) NOT NULL,
    mbti_type_2 VARCHAR(4) NOT NULL,
    compatibility_score DECIMAL(5,2) NOT NULL,
    analysis_text TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_mbti_pair (mbti_type_1, mbti_type_2)
) COMMENT 'MBTI 호환성 캐시';

-- 17.4 사용자 행동 로그 테이블
CREATE TABLE IF NOT EXISTS user_behavior_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id INT,
    action_value TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_user_action (user_id, action_type)
) COMMENT '사용자 행동 로그';

-- 17.5 추천 메트릭 테이블
CREATE TABLE IF NOT EXISTS recommendation_metrics (
    metric_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    recommendation_type VARCHAR(50) NOT NULL,
    recommended_item_id INT NOT NULL,
    score DECIMAL(5,2),
    clicked BOOLEAN DEFAULT FALSE,
    converted BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    clicked_at DATETIME,
    converted_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT '추천 메트릭';

-- 17.6 사용자 여행 히스토리 테이블
CREATE TABLE IF NOT EXISTS user_travel_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    travel_plan_id INT NOT NULL,
    role VARCHAR(20) NOT NULL COMMENT '역할 (CREATOR/PARTICIPANT)',
    status VARCHAR(20) DEFAULT 'COMPLETED',
    rating DECIMAL(3,1),
    review TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    FOREIGN KEY (travel_plan_id) REFERENCES travel_plan(plan_id) ON DELETE CASCADE
) COMMENT '사용자 여행 히스토리';

-- 17.7 사용자 유사도 캐시 테이블
CREATE TABLE IF NOT EXISTS user_similarity_cache (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id_1 VARCHAR(50) NOT NULL,
    user_id_2 VARCHAR(50) NOT NULL,
    similarity_score DECIMAL(5,4) NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_user_pair (user_id_1, user_id_2)
) COMMENT '사용자 유사도 캐시';

-- 17.8 A/B 테스트 결과 테이블
CREATE TABLE IF NOT EXISTS ab_test_results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    test_name VARCHAR(100) NOT NULL,
    variant VARCHAR(20) NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    metric_name VARCHAR(50) NOT NULL,
    metric_value DECIMAL(10,4),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT 'A/B 테스트 결과';

-- 17.9 추천 캐시 테이블
CREATE TABLE IF NOT EXISTS recommendation_cache (
    cache_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    recommendation_type VARCHAR(50) NOT NULL,
    recommendations TEXT NOT NULL COMMENT 'JSON 형식',
    expires_at DATETIME NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT '추천 캐시';

-- 17.10 사용자 세그먼트 테이블
CREATE TABLE IF NOT EXISTS user_segments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    segment_name VARCHAR(50) NOT NULL,
    segment_value VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    INDEX idx_segment (segment_name)
) COMMENT '사용자 세그먼트';

-- ============================================================
-- 18. 소셜 트렌드 (Social Trend)
-- ============================================================

-- 18.1 소셜 포스트 테이블
CREATE TABLE IF NOT EXISTS social_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    platform VARCHAR(50) NOT NULL COMMENT '플랫폼',
    post_url TEXT,
    content TEXT,
    location VARCHAR(200),
    hashtags TEXT,
    engagement_count INT DEFAULT 0,
    sentiment_score DECIMAL(3,2),
    collected_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_location (location),
    INDEX idx_collected (collected_at)
) COMMENT '소셜 포스트';

-- 18.2 트렌드 키워드 테이블
CREATE TABLE IF NOT EXISTS trend_keywords (
    keyword_id INT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    frequency INT DEFAULT 0,
    growth_rate DECIMAL(5,2),
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_keyword (keyword),
    INDEX idx_category (category)
) COMMENT '트렌드 키워드';

-- 18.3 위치 트렌드 테이블
CREATE TABLE IF NOT EXISTS location_trends (
    trend_id INT AUTO_INCREMENT PRIMARY KEY,
    location_name VARCHAR(200) NOT NULL,
    country VARCHAR(100),
    trend_score DECIMAL(5,2),
    mention_count INT DEFAULT 0,
    average_sentiment DECIMAL(3,2),
    peak_season VARCHAR(50),
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_location (location_name)
) COMMENT '위치 트렌드';

-- 18.4 사용자 여행 프로필 테이블
CREATE TABLE IF NOT EXISTS user_travel_profiles (
    profile_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    travel_style VARCHAR(100),
    preferred_season VARCHAR(50),
    budget_range VARCHAR(50),
    interests TEXT,
    visited_countries TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT '사용자 여행 프로필';

-- 18.5 개인화 추천 테이블
CREATE TABLE IF NOT EXISTS personalized_recommendations (
    recommendation_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    destination VARCHAR(200) NOT NULL,
    recommendation_score DECIMAL(5,2),
    reason TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT '개인화 추천';

-- 18.6 실시간 트렌드 테이블
CREATE TABLE IF NOT EXISTS realtime_trends (
    trend_id INT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(100) NOT NULL,
    trend_type VARCHAR(50),
    score DECIMAL(5,2),
    change_rate DECIMAL(5,2),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_keyword (keyword)
) COMMENT '실시간 트렌드';

-- 18.7 트렌드 알림 테이블
CREATE TABLE IF NOT EXISTS trend_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    alert_type VARCHAR(50) NOT NULL,
    keyword VARCHAR(100),
    destination VARCHAR(200),
    threshold DECIMAL(5,2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
) COMMENT '트렌드 알림';

-- 18.8 Claude API 로그 테이블
CREATE TABLE IF NOT EXISTS claude_api_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    request_type VARCHAR(50) NOT NULL,
    input_tokens INT,
    output_tokens INT,
    request_data TEXT,
    response_data TEXT,
    status VARCHAR(20),
    error_message TEXT,
    processing_time_ms INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_type (request_type),
    INDEX idx_created (created_at)
) COMMENT 'Claude API 로그';

-- 18.9 사용자 소셜 계정 테이블
CREATE TABLE IF NOT EXISTS user_social_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    account_id VARCHAR(200),
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at DATETIME,
    is_connected BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_social (user_id, platform)
) COMMENT '사용자 소셜 계정';

-- 18.10 트렌드 예측 테이블
CREATE TABLE IF NOT EXISTS trend_predictions (
    prediction_id INT AUTO_INCREMENT PRIMARY KEY,
    destination VARCHAR(200) NOT NULL,
    predicted_trend_score DECIMAL(5,2),
    confidence_level DECIMAL(3,2),
    prediction_period VARCHAR(50),
    factors TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_destination (destination)
) COMMENT '트렌드 예측';

-- ============================================================
-- 19. 시스템 설정 (System Settings)
-- ============================================================

-- 19.1 시스템 설정 테이블
CREATE TABLE IF NOT EXISTS system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE COMMENT '설정 키',
    setting_value TEXT COMMENT '설정 값',
    setting_type VARCHAR(50) DEFAULT 'STRING' COMMENT '설정 타입',
    description TEXT COMMENT '설명',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일',
    updated_by VARCHAR(50) COMMENT '수정자'
) COMMENT '시스템 설정';

-- ============================================================
-- 초기 데이터 삽입
-- ============================================================

-- 여행 MBTI 질문 초기 데이터
INSERT INTO travel_mbti_questions (question_text, option_a, option_b, dimension) VALUES
('여행 중 새로운 사람들과 만나는 것이 좋나요?', '네, 새로운 인연을 만드는 것이 여행의 즐거움입니다', '아니요, 조용히 혼자만의 시간을 즐기고 싶어요', 'EI'),
('여행 계획을 세울 때 어떤 스타일인가요?', '철저하게 일정을 계획합니다', '즉흥적으로 그때그때 결정합니다', 'JP'),
('여행지에서 무엇에 더 끌리나요?', '유명 관광지와 명소', '숨겨진 로컬 장소', 'SN'),
('여행 중 예상치 못한 상황이 발생하면?', '당황하지 않고 논리적으로 해결합니다', '감정에 따라 유연하게 대처합니다', 'TF'),
('여행에서 가장 중요하게 생각하는 것은?', '새로운 경험과 활동', '휴식과 재충전', 'EI'),
('여행 숙소를 선택할 때 중요한 것은?', '위치와 편의시설', '분위기와 특별한 경험', 'SN'),
('여행 중 맛집을 선택할 때?', '리뷰와 평점이 좋은 곳', '현지인이 추천하는 숨은 맛집', 'TF'),
('여행 일정이 틀어졌을 때?', '원래 계획대로 조정하려 노력합니다', '새로운 계획으로 변경합니다', 'JP')
ON DUPLICATE KEY UPDATE question_text = VALUES(question_text);

-- 여행 MBTI 결과 초기 데이터
INSERT INTO travel_mbti_results (mbti_type, title, description, travel_style, recommended_destinations) VALUES
('ESTJ', '계획형 리더 여행자', '철저한 계획과 효율적인 일정 관리를 선호합니다.', '일정표 기반 여행, 그룹 리더', '도쿄, 싱가포르, 독일'),
('ISTJ', '신중한 탐험가', '안정적이고 검증된 여행 코스를 선호합니다.', '문화유산 탐방, 박물관 투어', '교토, 프라하, 로마'),
('ESFJ', '사교적인 여행 플래너', '함께하는 여행의 즐거움을 중시합니다.', '그룹 여행, 맛집 투어', '파리, 방콕, 바르셀로나'),
('ISFJ', '세심한 동행자', '편안하고 안전한 여행을 추구합니다.', '가족 여행, 힐링 여행', '스위스, 뉴질랜드, 발리'),
('ESTP', '모험을 즐기는 탐험가', '스릴과 새로운 경험을 추구합니다.', '액티비티 여행, 스포츠 여행', '호주, 두바이, 뉴욕'),
('ISTP', '자유로운 솔로 여행자', '자신만의 페이스로 여행을 즐깁니다.', '백패킹, 로드트립', '아이슬란드, 노르웨이, 몽골'),
('ESFP', '즉흥적인 파티 여행자', '축제와 이벤트를 좋아합니다.', '축제 여행, 나이트라이프', '이비자, 리우, 암스테르담'),
('ISFP', '감성적인 예술 여행자', '아름다운 풍경과 예술을 추구합니다.', '갤러리 투어, 자연 여행', '피렌체, 산토리니, 제주도'),
('ENTJ', '전략적인 글로벌 여행자', '효율적이고 목표 지향적인 여행을 합니다.', '비즈니스 트립, VIP 투어', '런던, 홍콩, 상하이'),
('INTJ', '독립적인 문화 탐구자', '깊이 있는 문화 체험을 선호합니다.', '역사 탐방, 학술 여행', '아테네, 카이로, 베이징'),
('ENTP', '창의적인 여행 해커', '틀에 박히지 않은 독특한 여행을 즐깁니다.', '언플러그드 여행, 실험적 여행', '베를린, 텔아비브, 멜버른'),
('INTP', '분석적인 여행 연구가', '깊이 있는 탐구를 통한 여행을 좋아합니다.', '테마 여행, 과학 탐방', 'MIT, CERN, NASA'),
('ENFJ', '영감을 주는 여행 가이드', '여행을 통해 사람들과 연결됩니다.', '봉사 여행, 문화 교류', '인도, 페루, 탄자니아'),
('INFJ', '의미를 추구하는 순례자', '영적 성장을 위한 여행을 추구합니다.', '명상 여행, 성지 순례', '부탄, 티베트, 산티아고'),
('ENFP', '열정적인 세계 탐험가', '새로운 문화와 사람들을 만나는 것을 좋아합니다.', '배낭여행, 워킹홀리데이', '남미, 동남아, 아프리카'),
('INFP', '낭만적인 방랑자', '감성적이고 의미 있는 여행을 추구합니다.', '문학 여행, 자연 힐링', '아일랜드, 포르투갈, 벚꽃 여행')
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- ============================================================
-- 인덱스 최적화
-- ============================================================

-- 복합 인덱스 추가 (자주 사용되는 쿼리 최적화)
CREATE INDEX IF NOT EXISTS idx_travel_plan_search ON travel_plan(plan_status, plan_start_date, plan_destination);
CREATE INDEX IF NOT EXISTS idx_board_search ON board(board_category, board_regdate);
CREATE INDEX IF NOT EXISTS idx_chat_search ON chat_messages(travel_plan_id, sent_time);

-- ============================================================
-- 스키마 버전 정보
-- ============================================================
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
('schema_version', '1.0.0', 'STRING', 'Database schema version'),
('schema_updated_at', NOW(), 'DATETIME', 'Last schema update time')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value), updated_at = NOW();
