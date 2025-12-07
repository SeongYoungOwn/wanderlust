-- 이메일 인증 테이블 생성
CREATE TABLE IF NOT EXISTS email_verification (
    verification_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    verification_code VARCHAR(6) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    attempt_count INT DEFAULT 0,
    INDEX idx_email_code (email, verification_code),
    INDEX idx_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5분 이상 지난 미인증 레코드 자동 삭제 (선택사항)
-- 이벤트 스케줄러 활성화 필요: SET GLOBAL event_scheduler = ON;
DELIMITER $$
CREATE EVENT IF NOT EXISTS delete_expired_verifications
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    DELETE FROM email_verification
    WHERE expires_at < NOW() AND is_verified = FALSE;
END$$
DELIMITER ;