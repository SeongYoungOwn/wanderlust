-- 플레이리스트 테이블 생성
CREATE TABLE IF NOT EXISTS user_playlist (
    playlist_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL,
    music_origin VARCHAR(20) NOT NULL,           -- 음악 국가 (korean, foreign, mixed)
    destination_type VARCHAR(50) NOT NULL,       -- 여행지 타입
    music_genre VARCHAR(50) NOT NULL,            -- 음악 장르
    time_of_day VARCHAR(20),                     -- 시간대
    travel_style VARCHAR(20),                    -- 여행 스타일
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_PLAYLIST_USER FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 플레이리스트 음악 테이블 생성
CREATE TABLE IF NOT EXISTS playlist_songs (
    song_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    playlist_id BIGINT NOT NULL,
    song_title VARCHAR(200) NOT NULL,            -- 곡 제목
    artist VARCHAR(200) NOT NULL,                -- 아티스트
    genre VARCHAR(50) NOT NULL,                  -- 장르
    reason TEXT,                                 -- 추천 이유
    song_order INT DEFAULT 1,                    -- 곡 순서
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT FK_PLAYLIST_SONGS FOREIGN KEY (playlist_id) REFERENCES user_playlist(playlist_id) ON DELETE CASCADE
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_user_playlist_user_id ON user_playlist(user_id);
CREATE INDEX IF NOT EXISTS idx_user_playlist_created_at ON user_playlist(created_at);
CREATE INDEX IF NOT EXISTS idx_playlist_songs_playlist_id ON playlist_songs(playlist_id);