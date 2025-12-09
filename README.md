# Wanderlust (웹)

> AI 기반 여행 동행 매칭 플랫폼 - 백엔드 서버 + 웹 프론트엔드

Wanderlust는 Claude AI를 활용하여 여행자들을 지능적으로 매칭하고, MBTI 기반 호환성 분석, AI 여행 계획 생성, 실시간 채팅 등 다양한 기능을 제공하는 종합 여행 플랫폼입니다.

[![Java](https://img.shields.io/badge/Java-17-orange?logo=openjdk)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7.15-brightgreen?logo=springboot)](https://spring.io/projects/spring-boot)
[![MariaDB](https://img.shields.io/badge/MariaDB-11.4.5-blue?logo=mariadb)](https://mariadb.org/)
[![Docker](https://img.shields.io/badge/Docker-enabled-2496ED?logo=docker)](https://www.docker.com/)
[![GitLab CI/CD](https://img.shields.io/badge/GitLab-CI%2FCD-FC6D26?logo=gitlab)](https://about.gitlab.com/)

---

## 관련 프로젝트

| 프로젝트 | 설명 | 기술 스택 |
|---------|------|-----------|
| **Wanderlust (웹)** - 현재 저장소 | 백엔드 서버 + 웹 프론트엔드 | Spring Boot, JSP, MariaDB |
| **[Wanderlust Mobile (앱)](https://github.com/SeongYoungOwn/wanderlust_app)** | 모바일 앱 클라이언트 | Flutter, Dart |

---

## 주요 기능

### 🤖 AI 통합 기능
- **AI 채팅**: Claude API 기반 실시간 여행 상담 및 추천
- **AI 여행 계획**: 사용자 선호도 기반 맞춤형 여행 일정 자동 생성
- **스마트 패킹**: 목적지, 날씨, 여행 스타일에 따른 짐 목록 추천
- **여행 플레이리스트**: AI가 추천하는 여행지별 음악 큐레이션

### 👥 여행 매칭
- **MBTI 호환성 분석**: 16가지 성격 유형 기반 여행 동행자 매칭
- **다차원 매칭 알고리즘**: 여행 스타일, 선호도, 일정을 종합 분석
- **협업 필터링**: 유사 사용자 패턴 기반 추천 시스템
- **실시간 매너 평가**: 여행 후 상호 평가로 신뢰도 구축

### 🌐 소셜 & 커뮤니티
- **게시판**: 여행 후기, 팁, Q&A 공유
- **실시간 채팅**: WebSocket 기반 즉시 메시징
- **가이드 시스템**: 현지 가이드 매칭 및 예약
- **알림**: 매칭, 메시지, 일정 변경 실시간 알림

### 📊 트렌드 & 분석
- **여행 트렌드**: SNS 데이터 기반 인기 목적지 분석
- **개인화 추천**: 사용자 행동 학습 기반 여행지 제안
- **계절별 예측**: 시즌별 여행 트렌드 예측 및 추천

### 🔒 보안 & 관리
- **Spring Security**: 인증 및 권한 관리
- **관리자 대시보드**: 사용자, 콘텐츠, 신고 관리
- **비속어 필터링**: 커뮤니티 건전성 유지
- **신고 시스템**: 부적절한 콘텐츠 및 사용자 관리

---

## 🛠️ 기술 스택

### Backend
- **Framework**: Spring Boot 2.7.15
- **Language**: Java 17
- **ORM**: MyBatis 2.3.1
- **Security**: Spring Security
- **WebSocket**: STOMP

### Frontend
- **Template Engine**: JSP + JSTL
- **UI Framework**: Bootstrap, jQuery

### Database
- **RDBMS**: MariaDB 11.4.5
- **Connection Pool**: HikariCP

### AI & External APIs
- **AI**: Claude API (Anthropic)
- **Email**: Gmail SMTP

### DevOps
- **Build**: Maven 3.9+
- **Container**: Docker + Docker Compose
- **CI/CD**: GitLab CI/CD
- **Reverse Proxy**: Traefik (Let's Encrypt SSL)
- **Monitoring**: GlitchTip (optional)

---

## 🚀 빠른 시작

### 사전 요구사항

- Java 17 이상
- Maven 3.6 이상
- MariaDB 10.5 이상
- Docker & Docker Compose (운영 배포 시)

### 로컬 개발 환경 설정

#### 1. 저장소 클론

```bash
git clone https://gitlab.ibetter.kr/wanderlust/wanderlust_new.git
cd wanderlust_new
```

#### 2. 데이터베이스 설정

```bash
# MariaDB 접속
mysql -u root -p

# 데이터베이스 생성
CREATE DATABASE IF NOT EXISTS wanderlust CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 사용자 권한 설정
GRANT ALL PRIVILEGES ON wanderlust.* TO 'wanderlust'@'%';
FLUSH PRIVILEGES;
```

#### 3. 환경 변수 설정 (선택사항)

```bash
# Claude API 키 (AI 기능 사용 시 필수)
export CLAUDE_API_KEY=sk-ant-api03-your-api-key-here
```

#### 4. 애플리케이션 실행

```bash
# 개발 모드 실행 (기본 dev 프로파일)
mvn spring-boot:run

# 또는 특정 프로파일 지정
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

#### 5. 브라우저에서 접속

```
http://localhost:8080
```

---

## 📁 프로젝트 구조

```
wanderlust_new/
├── src/main/
│   ├── java/com/tour/project/
│   │   ├── Application.java              # Spring Boot 메인 클래스
│   │   ├── client/                       # 외부 API 클라이언트
│   │   │   └── ClaudeApiClient.java      # Claude API 통합
│   │   ├── config/                       # Spring 설정
│   │   │   ├── SecurityConfig.java       # Spring Security
│   │   │   ├── WebSocketConfig.java      # WebSocket 설정
│   │   │   └── DatabaseInitializer.java  # DB 초기화
│   │   ├── controller/                   # HTTP 요청 처리
│   │   │   ├── AiChatController.java     # AI 채팅
│   │   │   ├── AiTravelPlanController.java # AI 여행 계획
│   │   │   ├── TravelPlanController.java # 여행 매칭
│   │   │   └── ...
│   │   ├── service/                      # 비즈니스 로직
│   │   │   ├── ClaudeAnalysisService.java # Claude AI 분석
│   │   │   ├── TravelMatchingService.java # 매칭 알고리즘
│   │   │   ├── MBTICompatibilityEngine.java # MBTI 호환성
│   │   │   └── ...
│   │   ├── dao/                          # MyBatis 매퍼 인터페이스
│   │   ├── dto/                          # 데이터 전송 객체
│   │   ├── vo/                           # Value Object
│   │   └── util/                         # 유틸리티
│   ├── resources/
│   │   ├── application.properties        # 공통 설정
│   │   ├── application-dev.properties    # 개발 환경 (외부 DB)
│   │   ├── application-test.properties   # 테스트 환경 (내부 IP)
│   │   ├── application-prod.properties   # 운영 환경 (Docker)
│   │   └── com/tour/project/mapper/      # MyBatis XML 매퍼
│   └── webapp/
│       └── WEB-INF/views/                # JSP 뷰 파일
├── .gitlab-ci.yml                        # GitLab CI/CD 파이프라인
├── Dockerfile                            # Docker 이미지 빌드
├── docker-compose.yml                    # Docker Compose 설정
└── pom.xml                               # Maven 의존성
```

---

## 🔧 개발 가이드

### 환경별 실행

#### 개발 환경 (기본 - 외부 DB)
```bash
# 원격 데이터베이스 연결 (211.178.142.239)
mvn spring-boot:run

# Hot Reload 활성화
mvn spring-boot:run -Dspring-boot.run.fork=false
```

#### 테스트 환경 (내부 네트워크)
```bash
# 서버 내부 IP로 직접 연결 (100.75.197.18)
mvn spring-boot:run -Dspring-boot.run.profiles=test
```

#### 운영 환경 (Docker)
```bash
# Docker Compose로 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f wanderlust-app

# 컨테이너 중지
docker-compose down
```

### 데이터베이스 연결 정보

| 환경 | Host | Port | Database | User | 프로파일 |
|------|------|------|----------|------|---------|
| **개발** (기본) | 211.178.142.239 | 3306 | wanderlust | wanderlust | `dev` |
| **테스트** (내부) | 100.75.197.18 | 3306 | wanderlust | wanderlust | `test` |
| **운영** (Docker) | mariadb-11.4.5 | 3306 | wanderlust | wanderlust | `prod` |

### 빌드

```bash
# 전체 빌드 (테스트 포함)
mvn clean package

# 테스트 스킵
mvn clean package -DskipTests

# WAR 파일 위치
target/tour-project.war
```

### 테스트

```bash
# 모든 테스트 실행
mvn test

# 특정 테스트 클래스
mvn test -Dtest=BoardDAOTest

# 특정 테스트 메서드
mvn test -Dtest=MemberDAOTest#testFindById
```

---

## 🐳 Docker 배포

### 로컬 Docker 실행

```bash
# 1. 환경 변수 설정 (.env 파일 생성)
cat > .env << EOF
DB_USERNAME=wanderlust
DB_PASSWORD=your-password
CLAUDE_API_KEY=sk-ant-api03-your-key
EOF

# 2. Docker Compose 실행
docker-compose up -d

# 3. 헬스체크
curl http://localhost:8080/actuator/health
```

### 프로덕션 배포 (GitLab CI/CD)

```bash
# main 브랜치에 push하면 자동 배포
git add .
git commit -m "feat: 새로운 기능 추가"
git push origin main

# 배포 진행 상황 확인
# GitLab → CI/CD → Pipelines

# 배포 완료 확인 (약 5-7분 소요)
curl https://wanderlust.ibetter.kr/actuator/health
```

**배포 프로세스**:
1. **Build Stage**: Maven 빌드 및 WAR 파일 생성
2. **Deploy Stage**: Docker 이미지 빌드 및 컨테이너 배포
3. **Health Check**: 서비스 정상 작동 확인

---

## 📖 API 문서

### 주요 엔드포인트

#### 웹 페이지
- `GET /` - 메인 페이지
- `GET /board/list` - 게시판 목록
- `GET /travel/list` - 여행 계획 목록
- `GET /ai/chat` - AI 채팅
- `GET /admin` - 관리자 페이지

#### API
- `POST /api/ai/chat` - AI 채팅 메시지 전송
- `POST /api/ai/travel-plan` - AI 여행 계획 생성
- `GET /api/travel/match` - 여행 매칭 추천
- `POST /api/travel/join` - 여행 참가 신청
- `GET /actuator/health` - 헬스체크

#### WebSocket
- `ws://localhost:8080/ws/chat` - 실시간 채팅

---

## 🤝 기여하기

### 브랜치 전략

- `main` - 프로덕션 브랜치 (자동 배포)
- `develop` - 개발 브랜치
- `feature/*` - 기능 개발 브랜치

### 커밋 메시지 규칙

**중요**: 모든 커밋 메시지는 **한글**로 작성합니다.

```bash
# 형식
<타입>: <제목>

# 타입
- feat: 새로운 기능 추가
- fix: 버그 수정
- docs: 문서 수정
- style: 코드 포맷팅
- refactor: 코드 리팩토링
- test: 테스트 추가/수정
- chore: 빌드, 설정 변경

# 예시
git commit -m "feat: MBTI 기반 여행 매칭 알고리즘 추가"
git commit -m "fix: 로그인 시 세션 타임아웃 문제 해결"
git commit -m "docs: API 문서 업데이트"
```

### 개발 워크플로우

```bash
# 1. 기능 브랜치 생성
git checkout -b feature/새로운-기능

# 2. 개발 및 테스트
mvn spring-boot:run
mvn test

# 3. 커밋 및 푸시
git add .
git commit -m "feat: 새로운 기능 추가"
git push origin feature/새로운-기능

# 4. GitLab에서 Pull Request 생성
```

---

## 📚 추가 문서

- [프로젝트 상세 가이드](CLAUDE.md)
- [로컬 개발 시작하기](문서/시작%20가이드라인.md)
- [서버 초기 설정](../Obsidian/지식노트/1_Projects/2025-10_wanderlust/wanderlust_new/서버_초기_설정.md)
- [GitLab CI/CD 설정](../Obsidian/지식노트/1_Projects/2025-10_wanderlust/wanderlust_new/GitLab_CI_CD_설정.md)
- [배포 프로세스](../Obsidian/지식노트/1_Projects/2025-10_wanderlust/wanderlust_new/배포_프로세스.md)

---

## 🔐 보안

- API 키 및 비밀번호는 절대 Git에 커밋하지 마세요
- `.env` 파일은 `.gitignore`에 포함되어 있습니다
- 운영 환경의 민감 정보는 환경 변수로 관리됩니다

---

## 📞 문의

- **프로젝트 관리자**: [GitLab Issues](https://gitlab.ibetter.kr/wanderlust/wanderlust_new/-/issues)
- **웹사이트**: https://wanderlust.ibetter.kr

---

## 📝 라이선스

이 프로젝트는 비공개 프로젝트입니다.

---

**Made with ❤️ by Wanderlust Team**

*최종 업데이트: 2025-10-29*
