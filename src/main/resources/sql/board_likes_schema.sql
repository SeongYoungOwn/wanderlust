-- 게시판 좋아요/싫어요 기능을 위한 테이블 생성
-- 작성일: 2025-10-21
-- 목적: 좋아요/싫어요 중복 방지 및 사용자별 상태 관리

-- 1. BOARD 테이블에 필요한 컬럼 추가
ALTER TABLE board
ADD COLUMN IF NOT EXISTS board_category VARCHAR(50) DEFAULT 'GENERAL' COMMENT '게시글 카테고리',
ADD COLUMN IF NOT EXISTS board_image VARCHAR(500) COMMENT '게시글 이미지 경로',
ADD COLUMN IF NOT EXISTS board_views INT DEFAULT 0 COMMENT '조회수',
ADD COLUMN IF NOT EXISTS board_likes INT DEFAULT 0 COMMENT '좋아요 수',
ADD COLUMN IF NOT EXISTS board_dislikes INT DEFAULT 0 COMMENT '싫어요 수';

-- 2. 좋아요 테이블 생성
CREATE TABLE IF NOT EXISTS board_likes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '좋아요 ID',
    board_id INT NOT NULL COMMENT '게시글 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '좋아요 등록일',

    -- 중복 방지: 한 사용자는 한 게시글에 하나의 좋아요만 가능
    UNIQUE KEY unique_board_like (board_id, user_id),

    -- 외래키 제약조건
    FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,

    -- 인덱스 (성능 향상)
    INDEX idx_board_likes_board_id (board_id),
    INDEX idx_board_likes_user_id (user_id)
) COMMENT='게시글 좋아요 테이블';

-- 3. 싫어요 테이블 생성
CREATE TABLE IF NOT EXISTS board_dislikes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '싫어요 ID',
    board_id INT NOT NULL COMMENT '게시글 ID',
    user_id VARCHAR(50) NOT NULL COMMENT '사용자 ID',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '싫어요 등록일',

    -- 중복 방지: 한 사용자는 한 게시글에 하나의 싫어요만 가능
    UNIQUE KEY unique_board_dislike (board_id, user_id),

    -- 외래키 제약조건
    FOREIGN KEY (board_id) REFERENCES board(board_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE,

    -- 인덱스 (성능 향상)
    INDEX idx_board_dislikes_board_id (board_id),
    INDEX idx_board_dislikes_user_id (user_id)
) COMMENT='게시글 싫어요 테이블';

-- 4. 기존 데이터 마이그레이션 (필요시)
-- 기존에 board 테이블에 좋아요/싫어요 데이터가 있다면 유지
-- 신규 설치라면 이 부분은 실행하지 않아도 됨
