# Claude API 키 관리 시스템 구현 보고서

## 개요

관리자 대시보드에서 Claude API 키를 동적으로 설정/삭제할 수 있는 기능을 구현했습니다.
API 키는 AES-256으로 암호화되어 데이터베이스에 저장되며, 저장 즉시 모든 AI 기능에 적용됩니다.

---

## 생성/수정된 파일 목록

### 1. 데이터베이스 (SQL)

| 파일 | 위치 | 설명 |
|------|------|------|
| `system_settings.sql` | `src/main/resources/sql/` | 시스템 설정 테이블 DDL |

**테이블 구조:**
```sql
system_settings
├── setting_id (PK, AUTO_INCREMENT)
├── setting_key (UNIQUE) - 설정 키 (예: CLAUDE_API_KEY)
├── setting_value - 암호화된 값
├── setting_description - 설정 설명
├── is_encrypted - 암호화 여부
├── is_active - 활성화 여부
├── created_at - 생성일시
├── updated_at - 수정일시
└── updated_by - 수정한 관리자 ID
```

---

### 2. DTO (Data Transfer Object)

| 파일 | 위치 | 설명 |
|------|------|------|
| `SystemSettingDTO.java` | `src/main/java/com/tour/project/dto/` | 시스템 설정 데이터 전송 객체 |

---

### 3. DAO (Data Access Object)

| 파일 | 위치 | 설명 |
|------|------|------|
| `SystemSettingDAO.java` | `src/main/java/com/tour/project/dao/` | 시스템 설정 CRUD (MyBatis Annotation 방식) |

**주요 메서드:**
- `getSettingByKey()` - 키로 설정 조회
- `updateSettingValue()` - 설정 값 업데이트
- `deactivateSetting()` - 설정 비활성화 (삭제)
- `isSettingActive()` - 활성화 여부 확인

---

### 4. Service

| 파일 | 위치 | 설명 |
|------|------|------|
| `ApiKeyService.java` | `src/main/java/com/tour/project/service/` | API 키 관리 핵심 서비스 |

**주요 기능:**
- `getApiKey()` - API 키 조회 (캐싱 + DB)
- `saveApiKey()` - API 키 저장 (AES 암호화)
- `deleteApiKey()` - API 키 삭제
- `isApiKeyConfigured()` - 설정 여부 확인
- `getMaskedApiKey()` - 마스킹된 키 반환
- `encrypt()` / `decrypt()` - AES-256 암호화/복호화
- `refreshCache()` - 캐시 갱신

---

### 5. Controller

| 파일 | 위치 | 설명 |
|------|------|------|
| `AdminApiSettingsController.java` | `src/main/java/com/tour/project/controller/` | 관리자 API 설정 컨트롤러 |

**엔드포인트:**
| 메서드 | URL | 설명 |
|--------|-----|------|
| GET | `/admin/api-settings` | 설정 페이지 |
| POST | `/admin/api-settings/save` | API 키 저장 |
| POST | `/admin/api-settings/delete` | API 키 삭제 |
| POST | `/admin/api-settings/test` | API 키 검증 |
| GET | `/admin/api-settings/status` | 상태 조회 (AJAX) |

---

### 6. View (JSP)

| 파일 | 위치 | 설명 |
|------|------|------|
| `api-settings.jsp` | `src/main/webapp/WEB-INF/views/admin/` | API 설정 관리 페이지 |

**UI 기능:**
- API 키 상태 표시 (활성화/비활성화)
- 마스킹된 현재 키 표시
- API 키 입력 폼 (비밀번호 토글)
- 저장/삭제/검증 버튼
- AI 기능 현황 표시
- 마지막 수정 정보

---

### 7. 수정된 기존 파일

| 파일 | 위치 | 변경 내용 |
|------|------|----------|
| `admin-navbar-new.jsp` | `views/admin/includes/` | "API 설정" 메뉴 추가 |
| `ClaudeApiConfig.java` | `config/` | 동적 API 키 로딩 (ExchangeFilterFunction 적용) |
| `AiChatService.java` | `service/` | ApiKeyService 연동 |
| `PackingRecommendationService.java` | `service/` | ApiKeyService 연동 + 하드코딩된 키 제거 |

---

## 파일 구조 트리

```
src/main/
├── java/com/tour/project/
│   ├── config/
│   │   └── ClaudeApiConfig.java          [수정] 동적 API 키 로딩
│   ├── controller/
│   │   └── AdminApiSettingsController.java [신규] API 설정 컨트롤러
│   ├── dao/
│   │   └── SystemSettingDAO.java         [신규] 설정 DAO
│   ├── dto/
│   │   └── SystemSettingDTO.java         [신규] 설정 DTO
│   └── service/
│       ├── ApiKeyService.java            [신규] API 키 관리 서비스
│       ├── AiChatService.java            [수정] ApiKeyService 연동
│       └── PackingRecommendationService.java [수정] ApiKeyService 연동
│
├── resources/
│   └── sql/
│       └── system_settings.sql           [신규] DB 테이블 DDL
│
└── webapp/WEB-INF/views/admin/
    ├── api-settings.jsp                  [신규] API 설정 페이지
    └── includes/
        └── admin-navbar-new.jsp          [수정] 메뉴 추가
```

---

## 사용 방법

### 1. 데이터베이스 테이블 생성
```sql
-- MariaDB에서 실행
SOURCE src/main/resources/sql/system_settings.sql;
```

### 2. API 키 설정 절차
1. 관리자 계정으로 로그인
2. 관리자 대시보드 접속
3. 좌측 메뉴에서 "API 설정" 클릭
4. API 키 입력란에 Claude API 키 입력 (sk-ant-api03-...)
5. "저장" 버튼 클릭
6. 즉시 모든 AI 기능 활성화

### 3. API 키 삭제
1. API 설정 페이지에서 "삭제" 버튼 클릭
2. 확인 후 삭제 완료
3. 즉시 모든 AI 기능 비활성화

---

## 보안 사항

| 항목 | 구현 방법 |
|------|----------|
| **암호화** | AES-256 (ECB/PKCS5Padding) |
| **마스킹** | `sk-ant-api03-****...1234` 형태로 표시 |
| **권한** | ADMIN 권한만 접근 가능 (Spring Security) |
| **캐싱** | 1분 캐시로 DB 부하 최소화 |
| **검증** | `sk-ant-api` 또는 `sk-` 형식 검증 |

---

## 영향받는 AI 기능

| 기능 | 서비스 | 상태 |
|------|--------|------|
| AI 채팅 | AiChatService | API 키 필요 |
| AI 여행 계획 | ClaudeApiClient | API 키 필요 |
| 패킹 어시스턴트 | PackingRecommendationService | API 키 필요 |
| 여행 플레이리스트 | PlaylistService (ClaudeApiClient 사용) | API 키 필요 |
| 트렌드 분석 | ClaudeAnalysisService (ClaudeApiClient 사용) | API 키 필요 |

---

## 테스트 체크리스트

- [ ] 관리자 로그인 후 API 설정 페이지 접근
- [ ] API 키 입력 및 저장
- [ ] 저장 후 상태가 "활성화됨"으로 변경되는지 확인
- [ ] AI 채팅 기능 테스트
- [ ] API 키 삭제 후 AI 기능 비활성화 확인
- [ ] 일반 사용자로 API 설정 페이지 접근 시 리다이렉트 확인

---

## 작성일: 2025-12-02

## 작성자: Claude AI Assistant
