<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>찜목록 - AI 여행 동행 매칭 플랫폼</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #fdfbf7;
            color: #2d3748;
            line-height: 1.6;
            overflow-x: hidden;
            padding-top: 60px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 20px;
        }

        .page-header {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white;
            padding: 4rem 0 2rem 0;
            margin-bottom: 2rem;
            border-radius: 15px;
        }

        .message-nav {
            background: white;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .nav-tabs .nav-link {
            border: none;
            color: #6c757d;
            font-weight: 500;
            padding: 0.75rem 1.5rem;
        }

        .nav-tabs .nav-link.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 8px;
        }

        .message-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .message-row {
            padding: 1rem;
            border-bottom: 1px solid #e9ecef;
            transition: all 0.3s ease;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .message-content {
            flex: 1;
        }

        .message-actions {
            margin-left: 1rem;
            display: flex;
            gap: 0.5rem;
        }

        .btn-confirm {
            background: #28a745;
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-size: 0.875rem;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .btn-confirm:hover {
            background: #218838;
        }

        .btn-confirm:disabled {
            background: #6c757d;
            cursor: not-allowed;
        }

        .read-status {
            font-size: 0.875rem;
            padding: 0.25rem 0.5rem;
            border-radius: 4px;
            font-weight: 500;
        }

        .read-status.read {
            background: #d4edda;
            color: #155724;
        }

        .read-status.unread {
            background: #f8d7da;
            color: #721c24;
        }

        .message-row.unread {
            background: #e3f2fd;
            font-weight: 600;
        }

        .message-meta {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 0.5rem;
        }

        .sender-name {
            font-weight: 600;
            color: #495057;
        }

        .message-date {
            color: #6c757d;
            font-size: 0.9rem;
        }

        .message-title {
            font-size: 1.1rem;
            color: #2d3748;
            margin-bottom: 0.25rem;
        }

        .message-preview {
            color: #6c757d;
            font-size: 0.9rem;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .pagination-wrapper {
            margin-top: 2rem;
            display: flex;
            justify-content: center;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #6c757d;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .stats-bar {
            background: white;
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .unread-badge {
            background: #dc3545;
            color: white;
            padding: 0.25rem 0.5rem;
            border-radius: 12px;
            font-size: 0.75rem;
            margin-left: 0.5rem;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <div class="page-header">
            <div class="container text-center">
                <h1><i class="fas fa-heart me-3"></i>찜목록</h1>
                <p>내가 찜한 여행계획과 커뮤니티 글을 모아보세요!</p>
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

        <!-- Favorites Content -->
        <div class="container">
            <!-- 통계 카드 -->
            <div class="row mb-4">
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <i class="fas fa-heart text-danger fa-2x mb-2"></i>
                            <h5 class="card-title">전체 찜목록</h5>
                            <p class="card-text h3 text-primary">${totalCount}개</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <i class="fas fa-map-marked-alt text-success fa-2x mb-2"></i>
                            <h5 class="card-title">여행계획</h5>
                            <p class="card-text h3 text-success">${travelPlanCount}개</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-center">
                        <div class="card-body">
                            <i class="fas fa-comments text-info fa-2x mb-2"></i>
                            <h5 class="card-title">커뮤니티</h5>
                            <p class="card-text h3 text-info">${boardCount}개</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 탭 네비게이션 -->
            <ul class="nav nav-tabs mb-4" id="favoritesTab" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="all-tab" data-bs-toggle="tab" data-bs-target="#all-favorites" type="button" role="tab">
                        <i class="fas fa-heart me-1"></i>전체 (${totalCount})
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="travel-tab" data-bs-toggle="tab" data-bs-target="#travel-favorites" type="button" role="tab">
                        <i class="fas fa-map-marked-alt me-1"></i>여행계획 (${travelPlanCount})
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="board-tab" data-bs-toggle="tab" data-bs-target="#board-favorites" type="button" role="tab">
                        <i class="fas fa-comments me-1"></i>커뮤니티 (${boardCount})
                    </button>
                </li>
            </ul>

            <!-- 탭 콘텐츠 -->
            <div class="tab-content" id="favoritesTabContent">
                <!-- 전체 찜목록 -->
                <div class="tab-pane fade show active" id="all-favorites" role="tabpanel">
                    <c:choose>
                        <c:when test="${empty allFavorites}">
                            <div class="text-center py-5">
                                <i class="fas fa-heart fa-3x text-muted mb-3"></i>
                                <h4 class="text-muted">찜한 항목이 없습니다</h4>
                                <p class="text-muted">여행계획이나 커뮤니티 글을 찜해보세요!</p>
                                <div class="mt-3">
                                    <a href="${pageContext.request.contextPath}/travel/list" class="btn btn-primary me-2">
                                        <i class="fas fa-map-marked-alt me-1"></i>여행계획 보기
                                    </a>
                                    <a href="${pageContext.request.contextPath}/board/list" class="btn btn-info">
                                        <i class="fas fa-comments me-1"></i>커뮤니티 보기
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row">
                                <c:forEach items="${allFavorites}" var="favorite">
                                    <div class="col-md-6 mb-4">
                                        <div class="card h-100">
                                            <div class="card-body">
                                                <div class="d-flex justify-content-between align-items-start mb-2">
                                                    <c:choose>
                                                        <c:when test="${favorite.itemType == 'TRAVEL_PLAN'}">
                                                            <span class="badge bg-success">여행계획</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-info">커뮤니티</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <small class="text-muted">
                                                        <fmt:formatDate value="${favorite.createdDate}" pattern="MM/dd"/>
                                                    </small>
                                                </div>
                                                <h6 class="card-title">
                                                    <c:choose>
                                                        <c:when test="${favorite.itemType == 'TRAVEL_PLAN'}">
                                                            <c:choose>
                                                                <c:when test="${empty favorite.planTitle}">
                                                                    <span class="text-muted text-decoration-line-through">[삭제된 여행계획]</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <a href="${pageContext.request.contextPath}/travel/detail/${favorite.itemId}" class="text-decoration-none">
                                                                        ${favorite.planTitle}
                                                                    </a>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:choose>
                                                                <c:when test="${empty favorite.boardTitle}">
                                                                    <span class="text-muted text-decoration-line-through">[삭제된 게시글]</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <a href="${pageContext.request.contextPath}/board/detail/${favorite.itemId}" class="text-decoration-none">
                                                                        ${favorite.boardTitle}
                                                                    </a>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </h6>
                                                <c:if test="${favorite.itemType == 'TRAVEL_PLAN'}">
                                                    <p class="card-text small text-muted">
                                                        <i class="fas fa-map-marker-alt me-1"></i>${favorite.planDestination}
                                                        <c:if test="${not empty favorite.planStartDate}">
                                                            <br><i class="fas fa-calendar me-1"></i>
                                                            <fmt:formatDate value="${favorite.planStartDate}" pattern="yyyy.MM.dd"/> ~ 
                                                            <fmt:formatDate value="${favorite.planEndDate}" pattern="yyyy.MM.dd"/>
                                                        </c:if>
                                                    </p>
                                                </c:if>
                                                <c:if test="${favorite.itemType == 'BOARD'}">
                                                    <p class="card-text small text-muted">
                                                        <i class="fas fa-user me-1"></i>${favorite.boardWriter}
                                                        <br><i class="fas fa-calendar me-1"></i>
                                                        <fmt:formatDate value="${favorite.boardRegdate}" pattern="yyyy.MM.dd"/>
                                                    </p>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- 여행계획 찜목록 -->
                <div class="tab-pane fade" id="travel-favorites" role="tabpanel">
                    <c:choose>
                        <c:when test="${empty travelPlanFavorites}">
                            <div class="text-center py-5">
                                <i class="fas fa-map-marked-alt fa-3x text-muted mb-3"></i>
                                <h4 class="text-muted">찜한 여행계획이 없습니다</h4>
                                <p class="text-muted">마음에 드는 여행계획을 찜해보세요!</p>
                                <a href="${pageContext.request.contextPath}/travel/list" class="btn btn-primary">
                                    <i class="fas fa-map-marked-alt me-1"></i>여행계획 보기
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row">
                                <c:forEach items="${travelPlanFavorites}" var="favorite">
                                    <div class="col-md-6 mb-4">
                                        <div class="card h-100">
                                            <div class="card-body">
                                                <div class="d-flex justify-content-between align-items-start mb-2">
                                                    <span class="badge bg-success">여행계획</span>
                                                    <small class="text-muted">
                                                        <fmt:formatDate value="${favorite.createdDate}" pattern="MM/dd"/>
                                                    </small>
                                                </div>
                                                <h6 class="card-title">
                                                    <a href="${pageContext.request.contextPath}/travel/detail/${favorite.itemId}" class="text-decoration-none">
                                                        ${favorite.planTitle}
                                                    </a>
                                                </h6>
                                                <p class="card-text small text-muted">
                                                    <i class="fas fa-map-marker-alt me-1"></i>${favorite.planDestination}
                                                    <c:if test="${not empty favorite.planStartDate}">
                                                        <br><i class="fas fa-calendar me-1"></i>
                                                        <fmt:formatDate value="${favorite.planStartDate}" pattern="yyyy.MM.dd"/> ~ 
                                                        <fmt:formatDate value="${favorite.planEndDate}" pattern="yyyy.MM.dd"/>
                                                    </c:if>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- 커뮤니티 찜목록 -->
                <div class="tab-pane fade" id="board-favorites" role="tabpanel">
                    <c:choose>
                        <c:when test="${empty boardFavorites}">
                            <div class="text-center py-5">
                                <i class="fas fa-comments fa-3x text-muted mb-3"></i>
                                <h4 class="text-muted">찜한 커뮤니티 글이 없습니다</h4>
                                <p class="text-muted">관심있는 커뮤니티 글을 찜해보세요!</p>
                                <a href="${pageContext.request.contextPath}/board/list" class="btn btn-info">
                                    <i class="fas fa-comments me-1"></i>커뮤니티 보기
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="row">
                                <c:forEach items="${boardFavorites}" var="favorite">
                                    <div class="col-md-6 mb-4">
                                        <div class="card h-100">
                                            <div class="card-body">
                                                <div class="d-flex justify-content-between align-items-start mb-2">
                                                    <span class="badge bg-info">커뮤니티</span>
                                                    <small class="text-muted">
                                                        <fmt:formatDate value="${favorite.createdDate}" pattern="MM/dd"/>
                                                    </small>
                                                </div>
                                                <h6 class="card-title">
                                                    <a href="${pageContext.request.contextPath}/board/detail/${favorite.itemId}" class="text-decoration-none">
                                                        ${favorite.boardTitle}
                                                    </a>
                                                </h6>
                                                <p class="card-text small text-muted">
                                                    <i class="fas fa-user me-1"></i>${favorite.boardWriter}
                                                    <br><i class="fas fa-calendar me-1"></i>
                                                    <fmt:formatDate value="${favorite.boardRegdate}" pattern="yyyy.MM.dd"/>
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- 뒤로가기 버튼 -->
            <div class="text-center mt-4">
                <a href="${pageContext.request.contextPath}/member/mypage" class="btn btn-secondary">
                    <i class="fas fa-arrow-left me-1"></i>마이페이지로 돌아가기
                </a>
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
    <%@ include file="../common/footer.jsp" %>
</body>
</html>