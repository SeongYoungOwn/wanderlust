<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>공지사항 수정 - AI 여행 동행 매칭 플랫폼</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            padding-top: 100px;
            background-color: #f8f9fa;
        }
        
        /* Header Styles */
        header {
            background: rgba(253, 251, 247, 0.95);
            backdrop-filter: blur(15px);
            padding: 1rem 0;
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
            border-bottom: 1px solid rgba(255, 107, 107, 0.1);
        }
        
        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .logo {
            font-size: 2rem;
            font-weight: 800;
            background: linear-gradient(135deg, #ff6b6b, #ffd93d);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            letter-spacing: -0.02em;
            text-decoration: none;
        }
        
        .nav-links {
            display: flex;
            list-style: none;
            gap: 2.5rem;
            margin: 0;
            padding: 0;
        }
        
        .nav-links a {
            text-decoration: none;
            color: #4a5568;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .nav-links a:hover {
            color: #ff6b6b;
        }
        
        .user-menu {
            position: relative;
        }
        
        .user-dropdown {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 0.5rem;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            padding: 0.5rem 0;
            min-width: 200px;
            display: none;
            z-index: 100;
        }
        
        .user-menu:hover .user-dropdown {
            display: block;
        }
        
        .user-dropdown a {
            display: block;
            padding: 0.5rem 1rem;
            color: #4a5568;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        
        .user-dropdown a:hover {
            background-color: #f7fafc;
        }
        
        .user-toggle {
            padding: 0.5rem 1rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 2rem;
            text-decoration: none;
            font-weight: 500;
            transition: transform 0.3s ease;
        }
        
        .user-toggle:hover {
            transform: translateY(-2px);
            color: white;
        }
        
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        
        .form-container {
            background: white;
            border-radius: 1rem;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            padding: 2rem;
        }
        
        .important-notice {
            background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%);
            border: none;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1rem;
        }
        
        .notice-info {
            background-color: #f8f9fa;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1.5rem;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <!-- Navigation -->
        <header>
            <nav>
                <a href="${pageContext.request.contextPath}/home" class="logo">Wanderlust</a>
                
                <ul class="nav-links">
                    <li><a href="${pageContext.request.contextPath}/travel/list"><i class="fas fa-map-marked-alt me-1"></i>여행 계획</a></li>
                    <li><a href="${pageContext.request.contextPath}/board/list"><i class="fas fa-comments me-1"></i>커뮤니티</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-mbti/test"><i class="fas fa-user-tag me-1"></i>여행 MBTI</a></li>
                    <li><a href="${pageContext.request.contextPath}/ai/chat"><i class="fas fa-robot me-1"></i>AI 플래너</a></li>
                     <li><a href="${pageContext.request.contextPath}/notice/list"><i class="fas fa-bullhorn me-1"></i>공지사항</a></li>
                </ul>
                
                <div class="nav-actions">
                    <c:choose>
                        <c:when test="${not empty sessionScope.loginUser}">
                            <div class="user-menu">
                                <a href="#" class="user-toggle">
                                    <i class="fas fa-user me-1"></i>${sessionScope.loginUser.userName}님
                                </a>
                                <div class="user-dropdown">
                                    <a href="${pageContext.request.contextPath}/member/mypage">
                                        <i class="fas fa-user-circle me-2"></i>마이페이지
                                    </a>
                                    <a href="${pageContext.request.contextPath}/travel-mbti/history">
                                        <i class="fas fa-user-tag me-2"></i>여행 MBTI 기록
                                    </a>
                                    <a href="${pageContext.request.contextPath}/travel/create">
                                        <i class="fas fa-plus-circle me-2"></i>여행 계획 만들기
                                    </a>
                                    <a href="${pageContext.request.contextPath}/board/create">
                                        <i class="fas fa-pen me-2"></i>글쓰기
                                    </a>
                                    <c:if test="${sessionScope.loginUser.userId == 'admin' || sessionScope.loginUser.userRole == 'ADMIN'}">
                                        <a href="${pageContext.request.contextPath}/notice/create">
                                            <i class="fas fa-bullhorn me-2"></i>공지사항 작성
                                        </a>
                                        <a href="${pageContext.request.contextPath}/admin/dashboard">
                                            <i class="fas fa-cog me-2"></i>관리자 페이지
                                        </a>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/member/logout">
                                        <i class="fas fa-sign-out-alt me-2"></i>로그아웃
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/member/login" class="user-toggle">
                                <i class="fas fa-sign-in-alt me-1"></i>로그인
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </nav>
        </header>

        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <div class="d-flex align-items-center gap-3">
                    <a href="${pageContext.request.contextPath}/notice/detail/${notice.noticeId}" class="btn btn-light btn-sm">
                        <i class="fas fa-arrow-left me-1"></i>뒤로가기
                    </a>
                    <div>
                        <h1 class="h2 mb-1"><i class="fas fa-edit me-2"></i>공지사항 수정</h1>
                        <p class="mb-0">기존 공지사항을 수정합니다</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Messages -->
        <c:if test="${not empty error}">
            <div class="container">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </div>
        </c:if>

        <!-- Edit Form -->
        <div class="container mb-5">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="form-container">
                        <!-- Notice Info -->
                        <div class="notice-info">
                            <div class="row">
                                <div class="col-md-6">
                                    <strong>원본 등록일:</strong>
                                    <fmt:formatDate value="${notice.noticeRegdate}" pattern="yyyy년 MM월 dd일 HH:mm"/>
                                </div>
                                <div class="col-md-6">
                                    <strong>조회수:</strong> ${notice.noticeViews}회
                                </div>
                            </div>
                        </div>

                        <form method="post" action="${pageContext.request.contextPath}/notice/edit/${notice.noticeId}" onsubmit="return validateForm()">
                            <!-- Important Notice -->
                            <div class="important-notice">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" name="isImportant" id="isImportant" 
                                           value="true" ${notice.important ? 'checked' : ''}>
                                    <label class="form-check-label fw-bold" for="isImportant">
                                        <i class="fas fa-star text-warning me-1"></i>중요 공지사항으로 설정
                                        <small class="d-block text-muted mt-1">중요 공지사항은 목록 상단에 고정되어 표시됩니다.</small>
                                    </label>
                                </div>
                            </div>

                            <!-- Title -->
                            <div class="mb-4">
                                <label for="noticeTitle" class="form-label fw-bold">
                                    <i class="fas fa-heading me-1"></i>제목 <span class="text-danger">*</span>
                                </label>
                                <input type="text" class="form-control form-control-lg" id="noticeTitle" name="noticeTitle" 
                                       value="${notice.noticeTitle}" placeholder="공지사항 제목을 입력하세요" required maxlength="255">
                                <div class="form-text">
                                    <i class="fas fa-info-circle me-1"></i>명확하고 간결한 제목을 작성해주세요. (최대 255자)
                                </div>
                            </div>

                            <!-- Content -->
                            <div class="mb-4">
                                <label for="noticeContent" class="form-label fw-bold">
                                    <i class="fas fa-file-alt me-1"></i>내용 <span class="text-danger">*</span>
                                </label>
                                <textarea class="form-control" id="noticeContent" name="noticeContent" rows="15" 
                                          placeholder="공지사항 내용을 입력하세요" required>${notice.noticeContent}</textarea>
                                <div class="form-text">
                                    <i class="fas fa-info-circle me-1"></i>사용자들이 쉽게 이해할 수 있도록 자세히 작성해주세요.
                                </div>
                            </div>

                            <!-- Action Buttons -->
                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="text-muted">
                                        <i class="fas fa-user-shield me-1"></i>
                                        수정자: ${sessionScope.loginUser.userName} (${sessionScope.loginUser.userId})
                                    </span>
                                </div>
                                <div class="d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/notice/detail/${notice.noticeId}" class="btn btn-outline-secondary">
                                        <i class="fas fa-times me-1"></i>취소
                                    </a>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-save me-1"></i>수정 완료
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-white py-4">
            <div class="container text-center">
                <p class="mb-0">&copy; 2024 AI 여행 동행 매칭 플랫폼. All rights reserved.</p>
            </div>
        </footer>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function validateForm() {
            const title = document.getElementById('noticeTitle').value.trim();
            const content = document.getElementById('noticeContent').value.trim();
            
            if (title.length === 0) {
                alert('제목을 입력해주세요.');
                document.getElementById('noticeTitle').focus();
                return false;
            }
            
            if (title.length > 255) {
                alert('제목은 255자 이내로 입력해주세요.');
                document.getElementById('noticeTitle').focus();
                return false;
            }
            
            if (content.length === 0) {
                alert('내용을 입력해주세요.');
                document.getElementById('noticeContent').focus();
                return false;
            }
            
            return confirm('공지사항을 수정하시겠습니까?');
        }
        
        // 글자 수 실시간 확인
        document.getElementById('noticeTitle').addEventListener('input', function() {
            const current = this.value.length;
            const max = 255;
            if (current > max) {
                this.value = this.value.substring(0, max);
            }
        });
        
        // 자동 높이 조절
        document.getElementById('noticeContent').addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = (this.scrollHeight) + 'px';
        });
        
        // 페이지 로드 시 텍스트 영역 높이 조절
        window.addEventListener('load', function() {
            const textarea = document.getElementById('noticeContent');
            textarea.style.height = 'auto';
            textarea.style.height = (textarea.scrollHeight) + 'px';
        });
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>