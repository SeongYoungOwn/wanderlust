<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>가이드 신청 내역 - 관리자</title>
    <!-- Pretendard Font -->
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css" />
    <!-- Admin CSS Files -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-dashboard-new.css">
    <style>
        body {
            background: var(--bg-primary) !important;
            color: var(--text-primary) !important;
        }
        .admin-container {
            background: var(--bg-primary) !important;
        }
        .main-content {
            background: var(--bg-primary) !important;
        }
        .card {
            background: var(--bg-card) !important;
            color: var(--text-primary) !important;
        }

        .application-card {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
        }

        .status-pending {
            background: rgba(255, 193, 7, 0.15);
            color: #ffc107;
        }

        .status-approved {
            background: rgba(40, 167, 69, 0.15);
            color: #28a745;
        }

        .status-rejected {
            background: rgba(220, 53, 69, 0.15);
            color: #dc3545;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 150px 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }

        .detail-label {
            font-weight: 600;
            color: #000000;
        }

        .admin-comment-box {
            background: rgba(33, 150, 243, 0.1);
            padding: 16px;
            border-radius: 8px;
            margin: 16px 0;
            border-left: 4px solid #2196f3;
        }

        .filter-tabs {
            display: flex;
            gap: 8px;
            margin-bottom: 20px;
        }

        .filter-tab {
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.1);
            border: none;
            border-radius: 25px;
            color: var(--text-primary);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .filter-tab.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .filter-tab:hover {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            text-decoration: none;
        }

        .stats-summary {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-item {
            background: var(--bg-card);
            padding: 20px;
            border-radius: 12px;
            text-align: center;
        }

        .stat-number {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 5px;
            color: #000000;
        }

        .stat-label {
            color: #000000;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <!-- Include Admin Navigation Bar -->
        <%@ include file="includes/admin-navbar-new.jsp" %>

        <div class="admin-container">
            <!-- Main Content -->
            <main class="admin-main">
                <div class="dashboard-header">
                    <h1 class="dashboard-title">가이드 신청 내역</h1>
                    <p class="dashboard-subtitle">모든 가이드 신청을 조회하고 관리하세요</p>
                </div>

                <!-- Statistics Summary -->
                <div class="stats-summary">
                    <div class="stat-item">
                        <div class="stat-number">${statusCounts.pending}</div>
                        <div class="stat-label">대기 중</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${statusCounts.approved}</div>
                        <div class="stat-label">승인됨</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${statusCounts.rejected}</div>
                        <div class="stat-label">거절됨</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-number">${totalApplications}</div>
                        <div class="stat-label">전체</div>
                    </div>
                </div>

                <!-- Search and Filters -->
                <div class="content-grid">
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fa-solid fa-filter"></i>
                                필터 및 검색
                            </h3>
                        </div>
                        <div class="content-card-body">
                            <!-- Status Filter Tabs -->
                            <div class="filter-tabs">
                                <a href="?search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}"
                                   class="filter-tab ${empty status ? 'active' : ''}">전체</a>
                                <a href="?status=pending&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}"
                                   class="filter-tab ${status == 'pending' ? 'active' : ''}">대기 중</a>
                                <a href="?status=approved&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}"
                                   class="filter-tab ${status == 'approved' ? 'active' : ''}">승인됨</a>
                                <a href="?status=rejected&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}"
                                   class="filter-tab ${status == 'rejected' ? 'active' : ''}">거절됨</a>
                            </div>

                            <!-- Search Form -->
                            <form class="search-form" method="GET" style="display: flex; gap: 1rem; align-items: end; flex-wrap: wrap;">
                                <input type="hidden" name="status" value="${status}">
                                <div class="form-group">
                                    <label class="form-label">검색</label>
                                    <input type="text" class="form-control" name="search" value="${search}"
                                           placeholder="사용자명, 지역, 전문분야 검색">
                                </div>
                                <div class="form-group" style="flex: 0 0 150px;">
                                    <label class="form-label">정렬 기준</label>
                                    <select class="form-control" name="orderBy">
                                        <option value="applied_date" ${orderBy == 'applied_date' ? 'selected' : ''}>신청일</option>
                                        <option value="reviewed_date" ${orderBy == 'reviewed_date' ? 'selected' : ''}>처리일</option>
                                        <option value="status" ${orderBy == 'status' ? 'selected' : ''}>상태</option>
                                        <option value="user_name" ${orderBy == 'user_name' ? 'selected' : ''}>이름</option>
                                    </select>
                                </div>
                                <div class="form-group" style="flex: 0 0 100px;">
                                    <label class="form-label">순서</label>
                                    <select class="form-control" name="orderDirection">
                                        <option value="DESC" ${orderDirection == 'DESC' ? 'selected' : ''}>내림차순</option>
                                        <option value="ASC" ${orderDirection == 'ASC' ? 'selected' : ''}>오름차순</option>
                                    </select>
                                </div>
                                <div style="flex: 0 0 auto;">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fa-solid fa-search me-1"></i> 검색
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Applications List -->
                <div class="content-grid">
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fa-solid fa-list-check"></i>
                                가이드 신청 내역 (총 ${totalApplications}건)
                            </h3>
                        </div>
                        <div class="content-card-body" style="max-height: none;">
                            <c:choose>
                                <c:when test="${not empty applications}">
                                    <c:forEach items="${applications}" var="app">
                                        <div class="application-card">
                                            <div class="d-flex justify-content-between align-items-center mb-3">
                                                <div>
                                                    <h4 class="mb-1">${app.userName}</h4>
                                                    <small class="text-muted">
                                                        <i class="fa-regular fa-clock me-1"></i>
                                                        <fmt:formatDate value="${app.appliedDate}" pattern="yyyy-MM-dd HH:mm"/> 신청
                                                    </small>
                                                </div>
                                                <div class="d-flex gap-2 align-items-center">
                                                    <span class="status-badge status-${app.status}">
                                                        <c:choose>
                                                            <c:when test="${app.status == 'pending'}">
                                                                <i class="fa-solid fa-hourglass-half me-1"></i>승인 대기
                                                            </c:when>
                                                            <c:when test="${app.status == 'approved'}">
                                                                <i class="fa-solid fa-check me-1"></i>승인됨
                                                            </c:when>
                                                            <c:when test="${app.status == 'rejected'}">
                                                                <i class="fa-solid fa-xmark me-1"></i>거절됨
                                                            </c:when>
                                                        </c:choose>
                                                    </span>
                                                    <c:if test="${not empty app.reviewedDate}">
                                                        <small class="text-muted">
                                                            <fmt:formatDate value="${app.reviewedDate}" pattern="yyyy-MM-dd"/>
                                                        </small>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <div class="detail-grid">
                                                <span class="detail-label">사용자 ID:</span>
                                                <span>${app.userId}</span>

                                                <span class="detail-label">활동 지역:</span>
                                                <span>${app.region}</span>

                                                <span class="detail-label">상세 주소:</span>
                                                <span>${app.address}</span>

                                                <span class="detail-label">연락처:</span>
                                                <span>${app.phone}</span>

                                                <span class="detail-label">전문 지역:</span>
                                                <span>${app.specialtyRegion}</span>

                                                <span class="detail-label">전문 테마:</span>
                                                <span>${app.specialtyTheme}</span>

                                                <span class="detail-label">특화 영역:</span>
                                                <span>${app.specialtyArea}</span>

                                                <c:if test="${not empty app.reviewedBy}">
                                                    <span class="detail-label">처리자:</span>
                                                    <span>${app.reviewedBy}</span>
                                                </c:if>
                                            </div>

                                            <div class="p-3 rounded" style="background: rgba(255,255,255,0.05);">
                                                <strong><i class="fa-solid fa-user-tie me-2"></i>자기소개</strong>
                                                <p class="mt-2 mb-0">${app.introduction}</p>
                                            </div>

                                            <c:if test="${not empty app.greetingMessage}">
                                                <div class="p-3 rounded mt-3" style="background: rgba(255,255,255,0.05);">
                                                    <strong><i class="fa-solid fa-comment me-2"></i>관리자에게 보낸 인사말</strong>
                                                    <p class="mt-2 mb-0">${app.greetingMessage}</p>
                                                </div>
                                            </c:if>

                                            <c:if test="${not empty app.adminComment}">
                                                <div class="admin-comment-box">
                                                    <strong><i class="fa-solid fa-user-shield me-2"></i>관리자 코멘트</strong>
                                                    <p class="mt-2 mb-0">${app.adminComment}</p>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>

                                    <!-- Pagination -->
                                    <div class="pagination-section">
                                        <div class="pagination-info">
                                            총 ${totalApplications}건 중 ${(currentPage-1)*size + 1} - ${currentPage*size > totalApplications ? totalApplications : currentPage*size}건 표시
                                        </div>

                                        <div class="pagination">
                                            <c:if test="${currentPage > 1}">
                                                <a href="?page=${currentPage-1}&size=${size}&status=${status}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}"
                                                   class="page-link">
                                                    <i class="fas fa-chevron-left"></i>
                                                </a>
                                            </c:if>

                                            <c:forEach begin="${currentPage > 3 ? currentPage - 2 : 1}"
                                                       end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}"
                                                       var="page">
                                                <a href="?page=${page}&size=${size}&status=${status}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}"
                                                   class="page-link ${page == currentPage ? 'active' : ''}">
                                                    ${page}
                                                </a>
                                            </c:forEach>

                                            <c:if test="${currentPage < totalPages}">
                                                <a href="?page=${currentPage+1}&size=${size}&status=${status}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}"
                                                   class="page-link">
                                                    <i class="fas fa-chevron-right"></i>
                                                </a>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fa-solid fa-list-check"></i>
                                        <h3>신청 내역이 없습니다</h3>
                                        <p>검색 조건을 변경해보세요.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <%@ include file="../common/footer.jsp" %>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</body>
</html>