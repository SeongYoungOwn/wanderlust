<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>공지사항 - AI 여행 동행 매칭 플랫폼</title>
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
            min-height: 40vh;
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
            font-size: 2.8rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            line-height: 1.2;
            z-index: 10;
            position: relative;
            text-shadow: 0 4px 20px rgba(0,0,0,0.3);
            letter-spacing: -0.5px;
        }
        
        .page-title i {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            filter: drop-shadow(0 2px 4px rgba(255, 255, 255, 0.3));
            margin-right: 1rem;
        }
        
        .page-subtitle {
            font-size: 1.2rem;
            color: rgba(255, 255, 255, 0.95);
            font-weight: 300;
            z-index: 10;
            position: relative;
            max-width: 700px;
            margin: 0 auto 2rem;
            line-height: 1.6;
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
        
        .important-notice {
            background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%);
            border: none;
            border-left: 4px solid #e17055;
        }
        
        .notice-row:hover {
            background-color: var(--bg-secondary);
            cursor: pointer;
        }
        
        .badge-important {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
        }
        
        .search-section {
            background: var(--bg-card);
            padding: 2rem;
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            margin-bottom: 2rem;
        }
        
        .content-section {
            background: var(--bg-card);
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            overflow: hidden;
        }
        
        .content-header {
            background: linear-gradient(135deg, #f8f9fa, #ffffff);
            padding: 1.5rem 2rem;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .btn-outline-primary {
            color: #667eea;
            border-color: #667eea;
            border-radius: 10px;
            padding: 0.5rem 1rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-outline-primary:hover {
            background: #667eea;
            border-color: #667eea;
            transform: translateY(-2px);
        }
        
        .btn-outline-secondary {
            color: #6c757d;
            border-color: #6c757d;
            border-radius: 10px;
            padding: 0.5rem 1rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-outline-secondary:hover {
            background: #6c757d;
            border-color: #6c757d;
            transform: translateY(-2px);
        }
        
        .form-control {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .pagination .page-link {
            color: #667eea;
            border: none;
            padding: 0.75rem 1rem;
            margin: 0 0.25rem;
            border-radius: 10px;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .pagination .page-link:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }
        
        .pagination .page-item.active .page-link {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>
        
        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h1 class="page-title">
                            <i class="fas fa-bullhorn me-3"></i>
                            중요한 소식, 함께하는 정보
                        </h1>
                        <p class="page-subtitle">
                            여행 커뮤니티의 새로운 소식과 업데이트를 확인하세요. 모든 여행자를 위한 필수 공지사항입니다.
                        </p>
                    </div>
                    <div class="col-md-4 text-md-end mt-3 mt-md-0">
                        <c:if test="${sessionScope.loginUser.userId == 'admin' || sessionScope.loginUser.userRole == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/notice/create" class="btn btn-primary">
                                <i class="fas fa-plus me-1"></i>공지사항 작성
                            </a>
                        </c:if>
                    </div>
                </div>
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
                <div class="row">
                    <div class="col-12">
                        <!-- Search and Actions -->
                        <div class="search-section">
                            <div class="row align-items-center">
                                <div class="col-md-8">
                                    <form method="get" action="${pageContext.request.contextPath}/notice/list" class="d-flex">
                                        <input type="text" class="form-control me-2" name="search" 
                                               value="${search}" placeholder="제목 또는 내용으로 검색...">
                                        <button type="submit" class="btn btn-outline-primary">
                                            <i class="fas fa-search"></i>
                                        </button>
                                        <c:if test="${not empty search}">
                                            <a href="${pageContext.request.contextPath}/notice/list" class="btn btn-outline-secondary ms-2">
                                                <i class="fas fa-times"></i>
                                            </a>
                                        </c:if>
                                    </form>
                                </div>
                                <div class="col-md-4 text-end">
                                </div>
                            </div>
                        </div>

                        <!-- Notice List -->
                        <div class="content-section">
                            <div class="content-header">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">
                                        <i class="fas fa-list me-2"></i>
                                        공지사항 목록
                                        <span class="badge bg-primary">${totalCount}개</span>
                                    </h5>
                                    <c:if test="${not empty search}">
                                        <small class="text-muted">
                                            '<strong>${search}</strong>' 검색 결과
                                        </small>
                                    </c:if>
                                </div>
                            </div>
                            <div class="p-0">
                            <c:choose>
                                <c:when test="${empty noticeList}">
                                    <div class="text-center py-5">
                                        <i class="fas fa-bullhorn fa-4x text-muted mb-3"></i>
                                        <h5 class="text-muted">
                                            <c:choose>
                                                <c:when test="${not empty search}">검색 결과가 없습니다</c:when>
                                                <c:otherwise>등록된 공지사항이 없습니다</c:otherwise>
                                            </c:choose>
                                        </h5>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-hover mb-0">
                                            <thead class="table-light">
                                                <tr>
                                                    <th width="8%">번호</th>
                                                    <th>제목</th>
                                                    <th width="12%">작성자</th>
                                                    <th width="12%">등록일</th>
                                                    <th width="8%">조회수</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="notice" items="${noticeList}">
                                                    <tr class="notice-row ${notice.important ? 'important-notice' : ''}" 
                                                        onclick="location.href='${pageContext.request.contextPath}/notice/detail/${notice.noticeId}'">
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${notice.important}">
                                                                    <span class="badge badge-important">
                                                                        <i class="fas fa-star me-1"></i>중요
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${notice.noticeId}
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="text-start" style="color: var(--text-primary);">
                                                            <strong>${notice.noticeTitle}</strong>
                                                            <c:if test="${notice.important}">
                                                                <i class="fas fa-star text-warning ms-1"></i>
                                                            </c:if>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${not empty notice.writerName}">
                                                                    ${notice.writerName}
                                                                </c:when>
                                                                <c:otherwise>
                                                                    ${notice.noticeWriter}
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${notice.noticeRegdate}" pattern="MM-dd"/>
                                                        </td>
                                                        <td>
                                                            <i class="fas fa-eye me-1 text-muted"></i>${notice.noticeViews}
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            </div>
                        </div>

                    <!-- Pagination -->
                    <c:if test="${totalPages > 1}">
                        <nav aria-label="공지사항 페이지 네비게이션" class="mt-4">
                            <ul class="pagination justify-content-center">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=1<c:if test='${not empty search}'>&search=${search}</c:if>">
                                        <i class="fas fa-angle-double-left"></i>
                                    </a>
                                </li>
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage - 1}<c:if test='${not empty search}'>&search=${search}</c:if>">
                                        <i class="fas fa-angle-left"></i>
                                    </a>
                                </li>
                                
                                <c:set var="startPage" value="${currentPage - 2 > 0 ? currentPage - 2 : 1}" />
                                <c:set var="endPage" value="${startPage + 4 <= totalPages ? startPage + 4 : totalPages}" />
                                
                                <c:forEach var="i" begin="${startPage}" end="${endPage}">
                                    <li class="page-item ${i == currentPage ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}<c:if test='${not empty search}'>&search=${search}</c:if>">${i}</a>
                                    </li>
                                </c:forEach>
                                
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage + 1}<c:if test='${not empty search}'>&search=${search}</c:if>">
                                        <i class="fas fa-angle-right"></i>
                                    </a>
                                </li>
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${totalPages}<c:if test='${not empty search}'>&search=${search}</c:if>">
                                        <i class="fas fa-angle-double-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>
                    </div>
                </div>
            </div>
        </div>
        
        <%@ include file="../common/footer.jsp" %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>