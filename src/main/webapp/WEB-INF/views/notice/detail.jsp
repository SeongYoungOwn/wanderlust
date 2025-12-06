<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>${notice.noticeTitle} - 공지사항</title>
    <style>
        /* Plan2.html Design Variables */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            overflow-x: hidden;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* Page Header */
        .page-header {
            background: linear-gradient(-45deg, #e0c3fc, #8ec5fc, #e0c3fc, #8ec5fc);
            background-size: 400% 400%;
            animation: gradientAnimation 15s ease infinite;
            color: white;
            padding: 120px 0 30px 0;
            margin-top: 0;
            position: relative;
            overflow: hidden;
            min-height: 35vh;
            display: flex;
            align-items: center;
        }

        @keyframes gradientAnimation {
            0% {
                background-position: 0% 50%;
            }
            50% {
                background-position: 100% 50%;
            }
            100% {
                background-position: 0% 50%;
            }
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1rem;
            line-height: 1.2;
            z-index: 10;
            position: relative;
            text-shadow: 0 4px 20px rgba(0,0,0,0.3);
            letter-spacing: -0.5px;
        }

        .page-subtitle {
            font-size: 1.1rem;
            color: rgba(255, 255, 255, 0.95);
            font-weight: 300;
            z-index: 10;
            position: relative;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }

        /* Main Content */
        .main-content {
            background: var(--bg-secondary);
            margin: 0;
            border-radius: 20px 20px 0 0;
            box-shadow: 0 -5px 15px rgba(0,0,0,0.1);
            min-height: 70vh;
            padding: 2rem 0;
        }

        .content-section {
            background: var(--bg-card);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .content-header {
            background: linear-gradient(135deg, #f8f9fa, #ffffff);
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .important-badge {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
            padding: 0.5rem 1.5rem;
            border-radius: 2rem;
            font-size: 0.9rem;
            display: inline-block;
            margin-bottom: 1.5rem;
            font-weight: 600;
        }

        .notice-meta {
            background: linear-gradient(135deg, #f8f9fa, #ffffff);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border: 1px solid #e2e8f0;
        }

        .notice-meta .meta-item {
            margin-bottom: 0.5rem;
        }

        .notice-meta .meta-item:last-child {
            margin-bottom: 0;
        }

        .notice-meta strong {
            color: #667eea;
            font-weight: 600;
        }

        .notice-content {
            background-color: white;
            border-radius: 12px;
            padding: 2.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            white-space: pre-wrap;
            word-wrap: break-word;
            line-height: 1.8;
            font-size: 1.05rem;
            color: var(--text-primary);
        }

        .admin-section {
            background: var(--bg-card);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-bottom: 2rem;
        }

        .admin-section .content-header {
            background: linear-gradient(135deg, #fff5f5, #ffffff);
        }

        .admin-section .content-header h6 {
            color: #667eea;
            margin: 0;
            font-weight: 600;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
            color: white;
        }

        .btn-outline-primary {
            color: #667eea;
            border-color: #667eea;
            border-radius: 10px;
            padding: 0.75rem 1.5rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-outline-primary:hover {
            background: #667eea;
            border-color: #667eea;
            color: white;
            transform: translateY(-2px);
        }

        .btn-outline-secondary {
            color: #6c757d;
            border-color: #6c757d;
            border-radius: 10px;
            padding: 0.75rem 1.5rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-outline-secondary:hover {
            background: #6c757d;
            border-color: #6c757d;
            color: white;
            transform: translateY(-2px);
        }

        .btn-outline-danger {
            color: #dc3545;
            border-color: #dc3545;
            border-radius: 10px;
            padding: 0.75rem 1.5rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-outline-danger:hover {
            background: #dc3545;
            border-color: #dc3545;
            color: white;
            transform: translateY(-2px);
        }

        .btn-light {
            background: rgba(255, 255, 255, 0.9);
            border: none;
            color: #667eea;
            font-weight: 600;
            border-radius: 10px;
            padding: 0.5rem 1rem;
        }

        .btn-light:hover {
            background: white;
            color: #667eea;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <a href="${pageContext.request.contextPath}/notice/list" class="btn btn-light btn-sm">
                        <i class="fas fa-arrow-left me-1"></i>목록으로
                    </a>
                </div>
                <h1 class="page-title">
                    <i class="fas fa-bullhorn me-3"></i>
                    ${notice.noticeTitle}
                </h1>
                <p class="page-subtitle">
                    공지사항 상세 내용
                </p>
            </div>
        </div>

        <!-- Messages -->
        <c:if test="${not empty success}">
            <div class="container">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i>${success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="container">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </div>
        </c:if>

        <!-- Main Content -->
        <div class="main-content">
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-10">
                        <!-- Important Badge -->
                        <c:if test="${notice.important}">
                            <div class="important-badge">
                                <i class="fas fa-star me-1"></i>중요 공지사항
                            </div>
                        </c:if>

                        <!-- Notice Meta Info -->
                        <div class="content-section">
                            <div class="content-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-info-circle me-2"></i>공지사항 정보
                                </h5>
                            </div>
                            <div class="p-3">
                                <div class="notice-meta">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="meta-item">
                                                <strong><i class="fas fa-user me-2"></i>작성자:</strong>
                                                <c:choose>
                                                    <c:when test="${not empty notice.writerName}">
                                                        ${notice.writerName} (${notice.noticeWriter})
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${notice.noticeWriter}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="meta-item">
                                                <strong><i class="fas fa-calendar me-2"></i>등록일:</strong>
                                                <fmt:formatDate value="${notice.noticeRegdate}" pattern="yyyy년 MM월 dd일 HH:mm"/>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="meta-item">
                                                <strong><i class="fas fa-eye me-2"></i>조회수:</strong>
                                                ${notice.noticeViews}회
                                            </div>
                                            <div class="meta-item">
                                                <strong><i class="fas fa-hashtag me-2"></i>번호:</strong>
                                                ${notice.noticeId}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Notice Content -->
                        <div class="content-section">
                            <div class="content-header">
                                <h5 class="mb-0">
                                    <i class="fas fa-file-alt me-2"></i>공지 내용
                                </h5>
                            </div>
                            <div class="p-3">
                                <div class="notice-content">
                                    ${notice.noticeContent}
                                </div>
                            </div>
                        </div>

                        <!-- Admin Actions -->
                        <c:if test="${isAdmin}">
                            <div class="admin-section">
                                <div class="content-header">
                                    <h6><i class="fas fa-cog me-2"></i>관리자 메뉴</h6>
                                </div>
                                <div class="p-3">
                                    <div class="d-flex gap-2">
                                        <a href="${pageContext.request.contextPath}/notice/edit/${notice.noticeId}"
                                           class="btn btn-outline-primary">
                                            <i class="fas fa-edit me-1"></i>수정하기
                                        </a>
                                        <button type="button" class="btn btn-outline-danger"
                                                onclick="deleteNotice(${notice.noticeId})">
                                            <i class="fas fa-trash me-1"></i>삭제하기
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Navigation -->
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <a href="${pageContext.request.contextPath}/notice/list" class="btn btn-outline-secondary">
                                <i class="fas fa-list me-1"></i>목록으로 돌아가기
                            </a>
                            <c:if test="${isAdmin}">
                                <a href="${pageContext.request.contextPath}/notice/create" class="btn btn-primary">
                                    <i class="fas fa-plus me-1"></i>새 공지사항 작성
                                </a>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function deleteNotice(noticeId) {
            if (confirm('정말로 이 공지사항을 삭제하시겠습니까?\n삭제된 공지사항은 복구할 수 없습니다.')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/notice/delete/' + noticeId;
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>
