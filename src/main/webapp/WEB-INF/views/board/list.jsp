<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>커뮤니티 게시판 - AI 여행 동행 매칭 플랫폼</title>
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
        
        /* Category Tabs */
        .category-tabs {
            background: var(--bg-secondary);
            padding: 0;
            margin: -18px 0 0 0;
            border-radius: 20px 20px 0 0;
            box-shadow: 0 -5px 15px rgba(0,0,0,0.1);
        }
        
        .category-nav {
            display: flex;
            justify-content: center;
            border-bottom: 1px solid var(--border-color);
        }
        
        .category-tab {
            padding: 18px 25px;
            background: none;
            border: none;
            color: var(--text-secondary);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            border-bottom: 3px solid transparent;
            text-decoration: none;
            font-size: 0.95rem;
        }
        
        .category-tab:hover {
            color: var(--accent-primary);
            background: var(--bg-secondary);
        }
        
        .category-tab.active {
            color: var(--accent-primary);
            border-bottom-color: var(--accent-primary);
            background: var(--bg-secondary);
        }
        

        .page-title {
            font-size: 2.8rem;
            font-weight: 800;
            color: white;
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
            margin: 0 auto;
            line-height: 1.6;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }

        .primary-button {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
            padding: 1rem 2rem;
            border: none;
            border-radius: 30px;
            font-weight: 700;
            font-size: 0.95rem;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            box-shadow: 0 6px 25px rgba(255, 107, 107, 0.3);
            position: relative;
            z-index: 10;
            pointer-events: auto;
        }

        .primary-button:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 40px rgba(78, 205, 196, 0.4);
            color: white;
        }

        .secondary-button {
            background: transparent;
            color: #4ecdc4;
            border: 2px solid #4ecdc4;
            padding: 0.9rem 1.8rem;
            border-radius: 30px;
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            position: relative;
            z-index: 10;
            pointer-events: auto;
        }

        .secondary-button:hover {
            background: #4ecdc4;
            color: white;
            transform: translateY(-2px);
        }

        /* Board Section */
        .board-section {
            padding: 3rem 0 2rem 0;
        }

        /* Board Card Styles */
        .board-card {
            background: var(--bg-card);
            border-radius: 25px;
            overflow: hidden;
            box-shadow: 0 25px 80px rgba(0,0,0,0.15);
            border: 1px solid rgba(255, 107, 107, 0.1);
            transition: all 0.4s ease;
            height: 100%;
            position: relative;
        }
        
        .board-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 107, 107, 0.1), transparent);
            transition: left 0.5s ease;
        }
        
        .board-card:hover::before {
            left: 100%;
        }

        .board-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 35px 100px rgba(255, 107, 107, 0.2);
            border-color: rgba(255, 107, 107, 0.3);
        }

        .category-badge {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4) !important;
            color: white;
            font-size: 0.8rem;
            font-weight: 600;
            padding: 0.4rem 0.8rem;
            border-radius: 15px;
        }

        /* Board Table (for List View) */
        .board-table {
            background: var(--bg-card);
            border-radius: 25px;
            overflow: hidden;
            box-shadow: 0 25px 80px rgba(0,0,0,0.15);
            border: 1px solid rgba(255, 107, 107, 0.1);
            position: relative;
        }
        
        .board-table::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 107, 107, 0.1), transparent);
            transition: left 0.5s ease;
        }
        
        .board-table:hover::before {
            left: 100%;
        }

        .table th {
            background: var(--bg-header-gradient);
            border: none;
            font-weight: 700;
            color: var(--text-primary);
            padding: 1.2rem 1.2rem;
            font-size: 0.95rem;
        }

        .table td {
            border: none;
            border-bottom: 1px solid var(--border-color);
            vertical-align: middle;
            padding: 1.2rem 1.2rem;
            color: var(--text-primary);
        }

        .board-title {
            color: var(--text-primary);
            text-decoration: none;
            transition: all 0.3s ease;
            font-weight: 600;
            font-size: 1.05rem;
        }

        .board-title:hover {
            color: var(--accent-secondary);
            text-decoration: none;
            transform: translateY(-2px);
        }

        .board-meta {
            font-size: 0.9rem;
            color: var(--text-secondary);
        }

        .board-content-preview {
            color: var(--text-secondary);
            font-size: 0.9rem;
            margin-top: 0.5rem;
            line-height: 1.5;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 5rem 2rem;
            background: var(--bg-card);
            border-radius: 25px;
            margin: 2rem 0;
            box-shadow: 0 25px 80px var(--shadow-lg);
            border: 1px solid var(--border-color);
        }

        .empty-state i {
            color: var(--text-secondary);
            margin-bottom: 2rem;
        }

        .empty-state h5 {
            color: var(--text-primary);
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .empty-state p {
            color: var(--text-secondary);
            margin-bottom: 2rem;
        }

        /* Pagination */
        .pagination {
            margin-top: 3rem;
            justify-content: center !important;
        }

        .page-link {
            color: var(--text-primary);
            border: 1px solid var(--border-color);
            padding: 0.8rem 1.2rem;
            margin: 0 0.2rem;
            border-radius: 12px;
            font-weight: 500;
            transition: all 0.3s ease;
            background: var(--bg-card);
        }

        .page-link:hover {
            background: var(--accent-primary);
            border-color: var(--accent-primary);
            color: white;
            transform: translateY(-2px);
        }

        .page-item.active .page-link {
            background: var(--bg-header-gradient);
            border-color: var(--accent-primary);
            color: white;
        }

        .page-item.disabled .page-link {
            color: var(--text-muted);
            background: var(--bg-secondary);
        }

        /* Alert Messages */
        .alert {
            border-radius: 15px;
            border: none;
        }

        .alert-success {
            background: linear-gradient(135deg, #d4edda, #c3e6cb);
            color: #155724;
        }

        .alert-danger {
            background: linear-gradient(135deg, #f8d7da, #f5c6cb);
            color: #721c24;
        }

        /* Badge */
        .badge.bg-primary {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4) !important;
            font-weight: 600;
            border-radius: 15px;
        }

        /* Icons */
        .fas {
            margin-right: 0.3rem;
        }

        /* Search Section */
        .search-card {
            background: var(--bg-card);
            border-radius: 18px;
            padding: 1.5rem 1.8rem;
            box-shadow: 0 12px 35px rgba(0,0,0,0.08);
            border: 1px solid rgba(255, 107, 107, 0.12);
            margin-bottom: 1.8rem;
        }
        
        .search-form .input-group {
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        
        .search-select {
            border: none;
            background: #f8f9fa;
            color: #495057;
            font-weight: 600;
            padding: 0.9rem 1.2rem;
            max-width: 130px;
            font-size: 0.9rem;
        }
        
        .search-input {
            border: none;
            padding: 0.9rem 1.5rem;
            font-size: 1rem;
            background: white;
        }
        
        .search-input:focus {
            box-shadow: none;
            border: none;
            background: white;
        }
        
        .search-button {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            border: none;
            color: white;
            padding: 0.9rem 1.8rem;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .search-button:hover {
            background: linear-gradient(135deg, #ff5252, #4ecdc4);
            transform: translateY(-2px);
            color: white;
        }
        
        .search-reset {
            background: #6c757d;
            border: none;
            color: white;
            padding: 0.9rem 1.2rem;
            transition: all 0.3s ease;
        }
        
        .search-reset:hover {
            background: #545b62;
            color: white;
        }
        
        .search-info {
            background: linear-gradient(135deg, #ffebee, #e0f7fa);
            border-radius: 10px;
            padding: 0.8rem 1.2rem;
            margin-bottom: 1.2rem;
            border-left: 4px solid #ff6b6b;
            font-size: 0.9rem;
        }
        
        .search-info .search-keyword {
            color: #ff6b6b;
            font-weight: 700;
        }
        
        /* Inline Search Styles */
        .search-select-inline {
            min-width: 90px;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            font-size: 0.9rem;
        }
        
        .search-input-inline {
            border: 1px solid #dee2e6;
            font-size: 0.95rem;
            border-radius: 6px 0 0 6px;
        }
        
        .search-input-inline:focus {
            border-color: #ff6b6b;
            box-shadow: 0 0 0 0.2rem rgba(255, 107, 107, 0.25);
        }
        
        .search-btn-inline {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            border: none;
            border-radius: 0 6px 6px 0;
            padding: 0.5rem 1rem;
            font-weight: 600;
        }
        
        .search-btn-inline:hover {
            background: linear-gradient(135deg, #ff5252, #4ecdc4);
            transform: none;
        }
        
        .search-card .row {
            margin: 0;
        }
        
        .search-card .col-auto,
        .search-card .col {
            padding: 0 0.25rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .page-header {
                padding: 120px 0 40px 0;
            }
            
            .page-title {
                font-size: 1.5rem;
            }
            
            .page-subtitle {
                font-size: 0.9rem;
            }
            
            .table {
                font-size: 0.9rem;
            }
            
            .board-title {
                font-size: 1rem;
            }
            
            .primary-button, .secondary-button {
                padding: 0.7rem 1.4rem;
                font-size: 0.9rem;
            }
            
            .search-card {
                padding: 1.2rem 1rem;
            }
            
            .search-select {
                max-width: 100px;
                font-size: 0.8rem;
            }
            
            /* Mobile inline search adjustments */
            .search-select-inline {
                min-width: 70px;
                font-size: 0.8rem;
            }
            
            .search-input-inline {
                font-size: 0.9rem;
            }
            
            .search-btn-inline {
                padding: 0.4rem 0.8rem;
            }
        }
        
        /* View Toggle Styles */
        .view-toggle-wrapper {
            display: flex;
            align-items: center;
        }
        
        .view-toggle-btn {
            border-radius: 8px;
            transition: all 0.3s ease;
        }
        
        .view-toggle-btn:hover {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
            border-color: #ff6b6b;
        }
        
        /* List View Styles */
        .board-list-view {
            background: var(--bg-card);
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 15px;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 107, 107, 0.1);
        }
        
        .board-list-view:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(255, 107, 107, 0.15);
        }
        
        .board-list-item {
            padding: 1.2rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .board-list-item .board-thumbnail {
            width: 80px;
            height: 60px;
            border-radius: 8px;
            object-fit: cover;
            flex-shrink: 0;
        }
        
        .board-list-content {
            flex: 1;
            min-width: 0;
        }
        
        .board-list-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #2d3748;
            text-decoration: none;
            margin-bottom: 0.3rem;
            display: block;
        }
        
        .board-list-title:hover {
            color: #ff6b6b;
        }
        
        .board-list-preview {
            color: var(--text-secondary);
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        .board-list-meta {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.8rem;
            color: #a0aec0;
        }
        
        .board-list-stats {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            font-size: 0.85rem;
            color: #718096;
        }
        
        /* Compact View Styles */
        .board-compact-view {
            background: var(--bg-card);
            border-radius: 8px;
            margin-bottom: 8px;
            border: 1px solid rgba(255, 107, 107, 0.1);
            transition: all 0.2s ease;
        }
        
        .board-compact-view:hover {
            border-color: #ff6b6b;
            box-shadow: 0 2px 8px rgba(255, 107, 107, 0.1);
        }
        
        .board-compact-item {
            padding: 0.8rem 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .board-compact-left {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            flex: 1;
            min-width: 0;
        }
        
        .board-compact-title {
            font-size: 0.95rem;
            font-weight: 600;
            color: #2d3748;
            text-decoration: none;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        
        .board-compact-title:hover {
            color: #ff6b6b;
        }
        
        .board-compact-right {
            display: flex;
            align-items: center;
            gap: 1rem;
            font-size: 0.8rem;
            color: #a0aec0;
            flex-shrink: 0;
        }
        
        /* Hidden classes for view switching */
        .view-card { display: block; }
        .view-list { display: none; }
        .view-compact { display: none; }
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
                            <i class="fas fa-comments me-3"></i>
                            소통하는 여행, 함께하는 이야기
                        </h1>
                        <p class="page-subtitle">
                            여행자들과 경험을 나누고, 새로운 인연을 만들어보세요. 당신의 여행 이야기가 누군가에게 영감이 됩니다.
                        </p>
                    </div>
                    <div class="col-md-4 text-md-end mt-3 mt-md-0">
                        <c:if test="${not empty sessionScope.loginUser}">
                            <a href="${pageContext.request.contextPath}/board/create" class="primary-button">
                                <i class="fas fa-pen me-2"></i>글쓰기
                            </a>
                            <c:if test="${!isMyBoards}">
                                <a href="${pageContext.request.contextPath}/board/my" class="secondary-button ms-2">
                                    <i class="fas fa-user me-2"></i>내 글
                                </a>
                            </c:if>
                            <c:if test="${isMyBoards}">
                                <a href="${pageContext.request.contextPath}/board/list" class="secondary-button ms-2">
                                    <i class="fas fa-list me-2"></i>전체 글
                                </a>
                            </c:if>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
        

        <!-- Search Section -->
        <div class="container mt-4">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="search-card">
                        <form method="GET" action="${pageContext.request.contextPath}/board/list" class="search-form">
                            <input type="hidden" name="category" value="${param.category}">
                            <div class="row g-2 align-items-center">
                                <div class="col-auto">
                                    <label class="form-label mb-0 fw-bold text-primary">
                                        <i class="fas fa-search me-1"></i>검색
                                    </label>
                                </div>
                                <div class="col-auto">
                                    <select name="searchType" class="form-select form-select-sm search-select-inline">
                                        <option value="all" ${param.searchType == 'all' ? 'selected' : ''}>전체</option>
                                        <option value="title" ${param.searchType == 'title' ? 'selected' : ''}>제목</option>
                                        <option value="content" ${param.searchType == 'content' ? 'selected' : ''}>내용</option>
                                        <option value="writer" ${param.searchType == 'writer' ? 'selected' : ''}>작성자</option>
                                    </select>
                                </div>
                                <div class="col">
                                    <div class="input-group">
                                        <input type="text" name="searchKeyword" class="form-control search-input-inline" 
                                               placeholder="검색어를 입력하세요" value="${param.searchKeyword}">
                                        <button type="submit" class="btn btn-primary search-btn-inline">
                                            <i class="fas fa-search"></i>
                                        </button>
                                        <c:if test="${not empty param.searchKeyword}">
                                            <a href="${pageContext.request.contextPath}/board/list${not empty param.category ? '?category=' : ''}${param.category}" 
                                               class="btn btn-outline-secondary">
                                                <i class="fas fa-times"></i>
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    <!-- Category Tabs -->
        <div class="container">
            <div class="category-tabs">
                <div class="category-nav">
                    <a href="${pageContext.request.contextPath}/board/list" class="category-tab ${empty param.category ? 'active' : ''}">전체</a>
                    <a href="${pageContext.request.contextPath}/board/list?category=여행 후기" class="category-tab ${param.category == '여행 후기' ? 'active' : ''}">여행 후기</a>
                    <a href="${pageContext.request.contextPath}/board/list?category=여행 팁" class="category-tab ${param.category == '여행 팁' ? 'active' : ''}">여행 팁</a>
                    <a href="${pageContext.request.contextPath}/board/list?category=QnA" class="category-tab ${param.category == 'QnA' ? 'active' : ''}">QnA</a>
                    <a href="${pageContext.request.contextPath}/board/list?category=자유" class="category-tab ${param.category == '자유' ? 'active' : ''}">자유</a>
                </div>
            </div>
        </div>
        <!-- Messages -->
        <c:if test="${not empty success}">
            <div class="container mt-3">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i>${success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="container mt-3">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </div>
        </c:if>

        <!-- Search Results Info -->
        <c:if test="${not empty param.searchKeyword}">
            <div class="container">
                <div class="search-info">
                    <i class="fas fa-search me-2"></i>
                    '<span class="search-keyword">${param.searchKeyword}</span>' 검색 결과 
                    <span class="badge bg-primary ms-2">${not empty boards ? boards.size() : 0}건</span>
                </div>
            </div>
        </c:if>
        
        <!-- View Toggle -->
        <div class="container">
            <div class="row align-items-center mb-3">
                <div class="col">
                    <div class="view-toggle-wrapper">
                        <button type="button" class="btn btn-outline-secondary btn-sm view-toggle-btn" onclick="toggleViewType()">
                            <i class="fas fa-th-large me-1"></i>
                            <span id="view-type-text">카드형</span>
                        </button>
                        <small class="text-muted ms-2">
                            <c:choose>
                                <c:when test="${pageInfo != null}">
                                    총 <strong>${pageInfo.total}</strong>개의 게시글 
                                    (현재 페이지: <strong>${pageInfo.pageNum}</strong>/${pageInfo.pages})
                                </c:when>
                                <c:otherwise>
                                    총 <strong>${not empty boards ? boards.size() : 0}</strong>개의 게시글
                                </c:otherwise>
                            </c:choose>
                        </small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Board List -->
        <div class="container board-section">
            <c:choose>
                <c:when test="${empty boards}">
                    <div class="empty-state">
                        <i class="fas fa-comments fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">등록된 게시글이 없습니다.</h5>
                        <c:if test="${not empty sessionScope.loginUser}">
                            <p class="text-muted">첫 번째 게시글을 작성해보세요!</p>
                            <a href="${pageContext.request.contextPath}/board/create" class="primary-button">
                                <i class="fas fa-pen me-2"></i>글쓰기
                            </a>
                        </c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Card View (Default) -->
                    <div class="view-card">
                        <div class="row">
                            <c:forEach items="${boards}" var="board" varStatus="status">
                                <div class="col-md-4 col-lg-3 mb-4">
                                    <div class="card board-card shadow-sm h-100">
                                        <!-- Board Image -->
                                        <c:if test="${not empty board.boardImage}">
                                            <div class="card-img-top-wrapper" style="height: 200px; overflow: hidden; border-radius: 25px 25px 0 0;">
                                                <img src="${pageContext.request.contextPath}/uploads/${board.boardImage}" 
                                                     class="card-img-top" alt="${board.boardTitle}" 
                                                     style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s ease;"
                                                     onmouseover="this.style.transform='scale(1.05)'" 
                                                     onmouseout="this.style.transform='scale(1)'">
                                            </div>
                                        </c:if>
                                        <div class="card-body" style="padding: 1.3rem;">
                                            <h5 class="card-title">
                                                <a href="${pageContext.request.contextPath}/board/detail/${board.boardId}" class="text-decoration-none" style="color: var(--text-primary);">
                                                    ${board.boardTitle}
                                                </a>
                                            </h5>
                                            <p class="mb-2">
                                                <c:if test="${not empty board.boardCategory}">
                                                    <span class="badge bg-primary category-badge">
                                                        <i class="fas fa-tag me-1"></i>${board.boardCategory}
                                                    </span>
                                                </c:if>
                                                <c:if test="${commentCounts[board.boardId] > 0}">
                                                    <span class="badge bg-success ms-2">
                                                        <i class="fas fa-comments me-1"></i>${commentCounts[board.boardId]}
                                                    </span>
                                                </c:if>
                                            </p>
                                            <c:if test="${not empty board.boardContent}">
                                                <p class="card-text" style="color: var(--text-secondary);">
                                                    <c:choose>
                                                        <c:when test="${board.boardContent.length() > 100}">
                                                            ${board.boardContent.substring(0, 100)}...
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${board.boardContent}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </c:if>
                                            
                                            <!-- 통계 정보 -->
                                            <div class="mb-2">
                                                <span class="badge bg-info me-2">
                                                    <i class="fas fa-eye me-1"></i>조회 ${board.boardViews}
                                                </span>
                                                <span class="badge bg-danger">
                                                    <i class="fas fa-heart me-1"></i>좋아요 ${board.boardLikes}
                                                </span>
                                            </div>
                                            
                                            <hr>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <span class="writer-info">
                                                    <i class="fas fa-user me-1"></i>
                                                    <a href="${pageContext.request.contextPath}/member/profile/${board.boardWriter}" class="text-decoration-none text-primary">
                                                        ${board.boardWriter}
                                                    </a>
                                                </span>
                                                <div class="text-end d-flex align-items-center gap-2">
                                                    <!-- 찜하기 버튼 추가 -->
                                                    <c:if test="${not empty sessionScope.loginUser && board.boardWriter ne sessionScope.loginUser.userId}">
                                                        <button class="btn btn-sm bookmark-btn"
                                                                data-type="BOARD"
                                                                data-id="${board.boardId}"
                                                                data-bookmarked="${board.favorite ? 'true' : 'false'}"
                                                                onclick="toggleBookmark(this)"
                                                                style="
                                                                    background: ${board.favorite ? 'linear-gradient(135deg, #ef4444, #dc2626)' : 'white'};
                                                                    color: ${board.favorite ? 'white' : '#ef4444'};
                                                                    border: ${board.favorite ? 'none' : '1px solid #ef4444'};
                                                                    padding: 0.25rem 0.5rem;
                                                                    border-radius: 12px;
                                                                    font-size: 0.65rem;
                                                                    transition: all 0.3s ease;
                                                                ">
                                                            <i class="${board.favorite ? 'fas' : 'far'} fa-heart"></i>
                                                        </button>
                                                    </c:if>
                                                    <small class="text-muted">
                                                        <i class="fas fa-calendar me-1"></i>
                                                        <fmt:formatDate value="${board.boardRegdate}" pattern="yyyy.MM.dd"/>
                                                    </small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    
                    <!-- List View -->
                    <div class="view-list">
                        <c:forEach items="${boards}" var="board" varStatus="status">
                            <div class="board-list-view">
                                <div class="board-list-item">
                                    <c:if test="${not empty board.boardImage}">
                                        <img src="${pageContext.request.contextPath}/uploads/${board.boardImage}" 
                                             alt="게시글 이미지" class="board-thumbnail">
                                    </c:if>
                                    <div class="board-list-content">
                                        <a href="${pageContext.request.contextPath}/board/detail/${board.boardId}" class="board-list-title">
                                            <c:if test="${not empty board.boardCategory}">
                                                <span class="badge" style="background: linear-gradient(135deg, #ff6b6b, #4ecdc4); color: white; font-size: 0.75rem; margin-right: 8px;">${board.boardCategory}</span>
                                            </c:if>
                                            ${board.boardTitle}
                                            <c:if test="${commentCounts[board.boardId] > 0}">
                                                <span class="badge bg-primary ms-2">${commentCounts[board.boardId]}</span>
                                            </c:if>
                                        </a>
                                        <c:if test="${not empty board.boardContent}">
                                            <div class="board-list-preview">
                                                <c:choose>
                                                    <c:when test="${board.boardContent.length() > 80}">
                                                        ${board.boardContent.substring(0, 80)}...
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${board.boardContent}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:if>
                                        <div class="board-list-meta">
                                            <span><i class="fas fa-user me-1"></i>
                                                <a href="${pageContext.request.contextPath}/member/profile/${board.boardWriter}" class="text-decoration-none text-primary">
                                                    ${board.boardWriter}
                                                </a>
                                            </span>
                                            <span><i class="fas fa-calendar me-1"></i><fmt:formatDate value="${board.boardRegdate}" pattern="MM.dd"/></span>
                                        </div>
                                    </div>
                                    <div class="board-list-stats">
                                        <span><i class="fas fa-eye me-1"></i>${board.boardViews}</span>
                                        <span><i class="fas fa-heart me-1"></i>${board.boardLikes}</span>
                                        <!-- 찜하기 버튼 추가 -->
                                        <c:if test="${not empty sessionScope.loginUser && board.boardWriter ne sessionScope.loginUser.userId}">
                                            <button class="btn btn-sm bookmark-btn"
                                                    data-type="BOARD"
                                                    data-id="${board.boardId}"
                                                    data-bookmarked="${board.favorite ? 'true' : 'false'}"
                                                    onclick="toggleBookmark(this)"
                                                    style="
                                                        background: ${board.favorite ? 'linear-gradient(135deg, #ef4444, #dc2626)' : 'white'};
                                                        color: ${board.favorite ? 'white' : '#ef4444'};
                                                        border: ${board.favorite ? 'none' : '1px solid #ef4444'};
                                                        padding: 0.25rem 0.5rem;
                                                        border-radius: 10px;
                                                        font-size: 0.75rem;
                                                        transition: all 0.3s ease;
                                                    ">
                                                <i class="${board.favorite ? 'fas' : 'far'} fa-heart"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <!-- Compact View -->
                    <div class="view-compact">
                        <c:forEach items="${boards}" var="board" varStatus="status">
                            <div class="board-compact-view">
                                <div class="board-compact-item">
                                    <div class="board-compact-left">
                                        <c:if test="${not empty board.boardCategory}">
                                            <span class="badge" style="background: linear-gradient(135deg, #ff6b6b, #4ecdc4); color: white; font-size: 0.7rem;">${board.boardCategory}</span>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}/board/detail/${board.boardId}" class="board-compact-title">
                                            ${board.boardTitle}
                                            <c:if test="${commentCounts[board.boardId] > 0}">
                                                <span class="badge bg-primary ms-1" style="font-size: 0.65rem;">${commentCounts[board.boardId]}</span>
                                            </c:if>
                                        </a>
                                    </div>
                                    <div class="board-compact-right">
                                        <span>
                                            <a href="${pageContext.request.contextPath}/member/profile/${board.boardWriter}" class="text-decoration-none text-primary">
                                                ${board.boardWriter}
                                            </a>
                                        </span>
                                        <span><fmt:formatDate value="${board.boardRegdate}" pattern="MM.dd"/></span>
                                        <span><i class="fas fa-eye me-1"></i>${board.boardViews}</span>
                                        <!-- 찜하기 버튼 추가 -->
                                        <c:if test="${not empty sessionScope.loginUser && board.boardWriter ne sessionScope.loginUser.userId}">
                                            <button class="btn btn-sm bookmark-btn"
                                                    data-type="BOARD"
                                                    data-id="${board.boardId}"
                                                    data-bookmarked="${board.favorite ? 'true' : 'false'}"
                                                    onclick="toggleBookmark(this)"
                                                    style="
                                                        background: ${board.favorite ? 'linear-gradient(135deg, #ef4444, #dc2626)' : 'white'};
                                                        color: ${board.favorite ? 'white' : '#ef4444'};
                                                        border: ${board.favorite ? 'none' : '1px solid #ef4444'};
                                                        padding: 0.2rem 0.4rem;
                                                        border-radius: 8px;
                                                        font-size: 0.65rem;
                                                        transition: all 0.3s ease;
                                                    ">
                                                <i class="${board.favorite ? 'fas' : 'far'} fa-heart"></i>
                                            </button>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Pagination -->
                </c:otherwise>
            </c:choose>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>
    
    
    <!-- jQuery 추가 -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
        let currentViewType = 'card';

        // 찜하기 토글 함수
        function toggleBookmark(button) {
            const type = button.getAttribute('data-type');
            const id = button.getAttribute('data-id');
            const isBookmarked = button.getAttribute('data-bookmarked') === 'true';

            // 로그인 체크 (서버사이드 값 사용)
            <c:if test="${empty sessionScope.loginUser}">
                alert('로그인이 필요한 서비스입니다.');
                window.location.href = '${pageContext.request.contextPath}/member/login';
                return;
            </c:if>

            // Ajax 요청
            $.ajax({
                url: '${pageContext.request.contextPath}/board/favorite/toggle',
                type: 'POST',
                data: {
                    targetType: type,
                    targetId: id
                },
                success: function(response) {
                    if (response.success) {
                        // 버튼 상태 업데이트
                        const newBookmarked = !isBookmarked;
                        button.setAttribute('data-bookmarked', newBookmarked ? 'true' : 'false');

                        // 아이콘 변경
                        const icon = button.querySelector('i');
                        if (newBookmarked) {
                            icon.className = 'fas fa-heart';
                            button.style.background = 'linear-gradient(135deg, #ef4444, #dc2626)';
                            button.style.color = 'white';
                            button.style.border = 'none';
                        } else {
                            icon.className = 'far fa-heart';
                            button.style.background = 'white';
                            button.style.color = '#ef4444';
                            button.style.border = '1px solid #ef4444';
                        }
                    } else {
                        alert(response.message || '찜하기 처리에 실패했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('찜하기 처리 오류:', xhr, status, error);
                    console.error('응답 텍스트:', xhr.responseText);
                    alert('찜하기 처리 중 오류가 발생했습니다.\n상태: ' + xhr.status + '\n메시지: ' + xhr.responseText);
                }
            });
        }

        function toggleViewType() {
            console.log('toggleViewType() 호출됨, 현재 타입:', currentViewType);
            
            const viewToggleBtn = document.querySelector('.view-toggle-btn');
            const viewTypeText = document.getElementById('view-type-text');
            const viewToggleIcon = viewToggleBtn.querySelector('i');
            
            const cardView = document.querySelector('.view-card');
            const listView = document.querySelector('.view-list');
            const compactView = document.querySelector('.view-compact');
            
            console.log('뷰 요소들:', {
                cardView: cardView ? '존재' : 'null',
                listView: listView ? '존재' : 'null', 
                compactView: compactView ? '존재' : 'null'
            });
            
            // Hide all views with opacity
            cardView.style.setProperty('display', 'none', 'important');
            cardView.style.setProperty('visibility', 'hidden', 'important');
            cardView.style.setProperty('opacity', '0', 'important');
            
            listView.style.setProperty('display', 'none', 'important');
            listView.style.setProperty('visibility', 'hidden', 'important');
            listView.style.setProperty('opacity', '0', 'important');
            
            compactView.style.setProperty('display', 'none', 'important');
            compactView.style.setProperty('visibility', 'hidden', 'important');
            compactView.style.setProperty('opacity', '0', 'important');
            
            // Cycle through view types: card -> list -> compact -> card
            if (currentViewType === 'card') {
                currentViewType = 'list';
                listView.style.setProperty('display', 'block', 'important');
                listView.style.setProperty('visibility', 'visible', 'important');
                listView.style.setProperty('opacity', '1', 'important');
                viewTypeText.textContent = '리스트형';
                viewToggleIcon.className = 'fas fa-list me-1';
                console.log('카드형 → 리스트형 전환 완료');
            } else if (currentViewType === 'list') {
                currentViewType = 'compact';
                compactView.style.setProperty('display', 'block', 'important');
                compactView.style.setProperty('visibility', 'visible', 'important');
                compactView.style.setProperty('opacity', '1', 'important');
                viewTypeText.textContent = '간략형';
                viewToggleIcon.className = 'fas fa-bars me-1';
                console.log('리스트형 → 간략형 전환 완료');
            } else {
                currentViewType = 'card';
                cardView.style.setProperty('display', 'block', 'important');
                cardView.style.setProperty('visibility', 'visible', 'important');
                cardView.style.setProperty('opacity', '1', 'important');
                viewTypeText.textContent = '카드형';
                viewToggleIcon.className = 'fas fa-th-large me-1';
                console.log('간략형 → 카드형 전환 완료');
            }
            
            console.log('뷰 전환 후 상태:', {
                cardView: cardView.style.opacity,
                listView: listView.style.opacity,
                compactView: compactView.style.opacity
            });
        }
        
        // Register function globally
        window.toggleViewType = toggleViewType;
    </script>
</body>
</html>