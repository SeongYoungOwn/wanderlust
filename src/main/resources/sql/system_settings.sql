-- =====================================================
-- System Settings 테이블
-- Claude API 키 및 기타 시스템 설정 저장용
-- =====================================================

CREATE TABLE IF NOT EXISTS system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE COMMENT '설정 키 (예: CLAUDE_API_KEY)',
    setting_value TEXT COMMENT '설정 값 (암호화된 값)',
    setting_description VARCHAR(500) COMMENT '설정 설명',
    is_encrypted BOOLEAN DEFAULT FALSE COMMENT '암호화 여부',
    is_active BOOLEAN DEFAULT TRUE COMMENT '활성화 여부',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '생성일시',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
    updated_by VARCHAR(50) COMMENT '수정한 관리자 ID',

    INDEX idx_setting_key (setting_key),
    INDEX idx_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='시스템 설정 테이블';

-- 초기 데이터 (Claude API 키 설정 항목)
INSERT INTO system_settings (setting_key, setting_value, setting_description, is_encrypted, is_active)
VALUES ('CLAUDE_API_KEY', NULL, 'Claude AI API 키', TRUE, FALSE)
ON DUPLICATE KEY UPDATE setting_description = VALUES(setting_description);

-- API URL 설정 (선택사항)
INSERT INTO system_settings (setting_key, setting_value, setting_description, is_encrypted, is_active)
VALUES ('CLAUDE_API_URL', 'https://api.anthropic.com/v1/messages', 'Claude API URL', FALSE, TRUE)
ON DUPLICATE KEY UPDATE setting_description = VALUES(setting_description);
