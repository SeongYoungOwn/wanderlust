<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>여행 계획 목록 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        /* 🎨 테마 시스템: CSS 변수 정의 */
        :root {
            /* 라이트 테마 (기본) */
            --bg-primary: #fdfbf7;
            --bg-secondary: #ffffff;
            --bg-card: #ffffff;
            --bg-header-gradient: linear-gradient(-45deg, #e0c3fc, #8ec5fc, #e0c3fc, #8ec5fc);
            
            --text-primary: #1f2937;
            --text-secondary: #6b7280;
            --text-muted: #9ca3af;
            --text-inverse: #ffffff;
            
            --border-color: #e5e7eb;
            --border-light: #f3f4f6;
            
            --accent-primary: #ff6b6b;
            --accent-secondary: #4ecdc4;
            --accent-success: #10b981;
            --accent-warning: #f59e0b;
            --accent-danger: #ef4444;
            --accent-info: #3b82f6;
            
            --shadow-light: 0 4px 15px rgba(0,0,0,0.1);
            --shadow-medium: 0 6px 20px rgba(0,0,0,0.15);
            --shadow-card: 0 6px 20px rgba(255, 107, 107, 0.08), 0 3px 6px rgba(78, 205, 196, 0.06);
        }

        /* 🌙 다크 테마 */
        [data-theme="dark"] {
            --bg-primary: #0f1419;
            --bg-secondary: #1a1f2e;
            --bg-card: #1e2532;
            --bg-header-gradient: linear-gradient(-45deg, #2d1b69, #11998e, #2d1b69, #11998e);
            
            --text-primary: #f8fafc;
            --text-secondary: #cbd5e1;
            --text-muted: #94a3b8;
            --text-inverse: #0f1419;
            
            --border-color: #374151;
            --border-light: #4b5563;
            
            --accent-primary: #8b5cf6;
            --accent-secondary: #06d6a0;
            --accent-success: #34d399;
            --accent-warning: #fbbf24;
            --accent-danger: #f87171;
            --accent-info: #60a5fa;
            
            --shadow-light: 0 4px 15px rgba(0,0,0,0.4);
            --shadow-medium: 0 6px 20px rgba(0,0,0,0.5);
            --shadow-card: 0 6px 20px rgba(139, 92, 246, 0.15), 0 3px 6px rgba(6, 214, 160, 0.1);
        }

        /* 🌐 전역 스타일 - 테마 변수 적용 */
        * {
            transition: background-color 0.3s ease, color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease;
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
        }

        /* 🎭 페이지 헤더 - 테마별 그라데이션 */
        .page-header {
            background: var(--bg-header-gradient);
            background-size: 400% 400%;
            animation: galaxyAnimate 15s ease infinite;
            color: var(--text-inverse);
            padding: 120px 0 30px 0;
            margin-top: 0;
            position: relative;
            overflow: hidden;
            min-height: 40vh;
            display: flex;
            align-items: center;
        }

        @keyframes galaxyAnimate {
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
            color: var(--text-inverse);
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
        
        /* 장식적 요소들 */
        .header-glow {
            position: absolute;
            top: 30%;
            left: 10%;
            width: 200px;
            height: 200px;
            background: radial-gradient(circle, rgba(255, 255, 255, 0.1) 0%, transparent 70%);
            border-radius: 50%;
            animation: pulse 6s ease-in-out infinite;
            z-index: 1;
        }
        
        .header-glow:nth-child(2) {
            top: 20%;
            right: 15%;
            left: auto;
            width: 150px;
            height: 150px;
            animation-delay: 3s;
        }
        
        @keyframes pulse {
            0%, 100% { 
                opacity: 0.3; 
                transform: scale(1); 
            }
            50% { 
                opacity: 0.6; 
                transform: scale(1.2); 
            }
        }


        .primary-button {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: var(--text-inverse);
            padding: 0.8rem 1.8rem;
            border: none;
            border-radius: 50px;
            font-weight: 700;
            font-size: 0.95rem;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            box-shadow: var(--shadow-light);
            position: relative;
            z-index: 10;
            pointer-events: auto;
        }

        .primary-button:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-medium);
            color: var(--text-inverse);
        }

        .secondary-button {
            background: transparent;
            color: var(--accent-primary);
            border: 2px solid var(--accent-primary);
            padding: 0.7rem 1.6rem;
            border-radius: 50px;
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
            background: var(--accent-primary);
            color: var(--text-inverse);
            transform: translateY(-2px);
        }

        /* 🎴 여행 계획 섹션 - 테마 대응 */
        .travel-section {
            padding: 3rem 0;
            background: var(--bg-primary);
        }

        .plan-card {
            background: var(--bg-card);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: var(--shadow-card);
            border: 1px solid var(--border-color);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            height: 100%;
            position: relative;
            backdrop-filter: blur(10px);
            max-width: 100%;
        }
        
        .plan-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, 
                transparent, 
                rgba(255, 107, 107, 0.1), 
                rgba(78, 205, 196, 0.1), 
                transparent);
            transition: left 0.6s ease;
            z-index: 1;
        }
        
        .plan-card:hover::before {
            left: 100%;
        }

        .plan-card:hover {
            transform: translateY(-6px) scale(1.01);
            box-shadow: 
                0 12px 40px rgba(255, 107, 107, 0.12),
                0 6px 15px rgba(78, 205, 196, 0.1);
            border-color: rgba(255, 107, 107, 0.25);
        }
        
        .card-body {
            position: relative;
            z-index: 2;
            padding: 1.5rem;
        }

        /* Override styles for different views */
        .view-list .plan-card {
            border-radius: 15px !important;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1) !important;
            border: 1px solid #e0e0e0 !important;
            background: white !important;
            transition: all 0.3s ease !important;
        }

        .view-list .plan-card::before {
            display: none !important;
        }

        .view-list .plan-card:hover {
            transform: translateY(-3px) !important;
            box-shadow: 0 6px 20px rgba(0,0,0,0.15) !important;
            border-color: #ccc !important;
        }

        .view-compact .plan-card {
            border-radius: 10px !important;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08) !important;
            border: 1px solid #e0e0e0 !important;
            background: white !important;
            transition: all 0.2s ease !important;
            margin-bottom: 0.5rem !important;
        }

        .view-compact .plan-card::before {
            display: none !important;
        }

        .view-compact .plan-card:hover {
            transform: translateY(-1px) !important;
            box-shadow: 0 3px 12px rgba(0,0,0,0.12) !important;
            background-color: #f8f9fa !important;
        }

        /* Ensure views have content and are visible */
        .view-card, .view-list, .view-compact {
            min-height: 200px;
            width: 100%;
        }

        .view-list, .view-compact {
            padding: 1rem 0;
        }

        .destination-badge {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: var(--text-inverse);
            font-size: 0.8rem;
            font-weight: 600;
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            box-shadow: var(--shadow-light);
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
        }

        .budget-info {
            color: var(--accent-primary);
            font-weight: 700;
            font-size: 1rem;
        }

        .date-range {
            color: var(--text-secondary);
            font-size: 0.9rem;
            font-weight: 500;
            background: var(--bg-secondary);
            border: 1px solid var(--border-light);
            padding: 0.4rem 0.8rem;
            border-radius: 12px;
            display: inline-block;
        }

        .writer-info {
            font-size: 0.85rem;
            color: var(--text-secondary);
            font-weight: 500;
        }
        
        .card-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.8rem;
            line-height: 1.3;
        }
        
        .card-title a {
            color: var(--text-primary);
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .card-title a:hover {
            color: var(--accent-primary);
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem 2rem;
            background: var(--bg-card);
            border-radius: 20px;
            margin: 2rem 0;
        }
        
        /* Additional card spacing adjustments */
        .view-card .row {
            margin: 0 -0.5rem;
        }
        
        .view-card [class*="col-"] {
            padding: 0 0.5rem;
        }
        
        .card-text {
            font-size: 0.85rem;
            line-height: 1.4;
            color: var(--text-secondary);
        }
        
        .small {
            font-size: 0.75rem !important;
        }

        .empty-state i {
            color: var(--text-muted);
            margin-bottom: 2rem;
        }

        .empty-state h5 {
            color: var(--text-primary);
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .empty-state p {
            color: var(--text-muted);
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
            background: var(--bg-card);
            padding: 0.8rem 1.2rem;
            margin: 0 0.2rem;
            border-radius: 12px;
            font-weight: 500;
            transition: all 0.3s ease;
            text-decoration: none;
        }

        .page-link:hover {
            background: var(--accent-primary);
            border-color: var(--accent-primary);
            color: var(--text-inverse);
            transform: translateY(-2px);
            text-decoration: none;
        }

        .page-item.active .page-link {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            border-color: var(--accent-primary);
            color: var(--text-inverse);
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
            
            .travel-section {
                padding: 2rem 0;
            }
            
            .container {
                padding: 0 15px;
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
        
        /* 🔍 검색 섹션 - 테마 대응 */
        .search-card {
            background: var(--bg-card);
            border-radius: 18px;
            padding: 2rem;
            box-shadow: var(--shadow-card);
            border: 1px solid var(--border-color);
            margin-bottom: 2rem;
            backdrop-filter: blur(10px);
        }
        
        .search-form .input-group {
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        
        .search-select {
            border: 1px solid var(--border-color);
            background: var(--bg-secondary);
            color: var(--text-primary);
            font-weight: 600;
            padding: 0.9rem 1.2rem;
            max-width: 130px;
            font-size: 0.9rem;
        }
        
        .search-input {
            border: 1px solid var(--border-color);
            padding: 0.9rem 1.5rem;
            font-size: 1rem;
            background: var(--bg-secondary);
            color: var(--text-primary);
        }
        
        .search-input:focus {
            box-shadow: none;
            border-color: var(--accent-primary);
            background: var(--bg-secondary);
            color: var(--text-primary);
        }
        
        .search-button {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            border: none;
            color: var(--text-inverse);
            padding: 0.9rem 1.8rem;
            font-weight: 700;
            transition: all 0.3s ease;
            border-radius: 15px;
            box-shadow: var(--shadow-light);
        }
        
        .search-button:hover {
            background: linear-gradient(135deg, var(--accent-secondary), var(--accent-primary));
            transform: translateY(-2px);
            color: var(--text-inverse);
            box-shadow: var(--shadow-medium);
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
            background: linear-gradient(135deg, #e3f2fd, #f3e5f5);
            border-radius: 10px;
            padding: 0.8rem 1.2rem;
            margin-bottom: 1.2rem;
            border-left: 4px solid var(--primary-color);
            font-size: 0.9rem;
        }
        
        .search-info .search-keyword {
            color: var(--primary-color);
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
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(0, 82, 212, 0.25);
        }
        
        .search-btn-inline {
            background: var(--gradient-primary);
            border: none;
            border-radius: 0 6px 6px 0;
            padding: 0.5rem 1rem;
            font-weight: 600;
        }
        
        .search-btn-inline:hover {
            background: linear-gradient(135deg, #4c63d2, #5a67f0);
            transform: none;
        }
        
        .search-card .row {
            margin: 0;
        }
        
        .search-card .col-auto,
        .search-card .col {
            padding: 0 0.25rem;
        }
        
        /* 🔄 뷰 토글 및 정렬 옵션 */
        .view-toggle-wrapper {
            display: flex;
            align-items: center;
        }
        
        .view-toggle-btn {
            border-radius: 8px;
            border-color: var(--border-color);
            color: var(--text-primary);
            background: var(--bg-card);
            transition: all 0.3s ease;
        }
        
        .view-toggle-btn:hover {
            background: linear-gradient(135deg, var(--accent-primary), var(--accent-secondary));
            color: var(--text-inverse);
            border-color: var(--accent-primary);
            box-shadow: var(--shadow-light);
        }
        
        .form-select, .form-label {
            color: var(--text-primary);
            background: var(--bg-card);
            border-color: var(--border-color);
        }
        
        .form-select:focus {
            border-color: var(--accent-primary);
            box-shadow: 0 0 0 0.2rem rgba(var(--accent-primary), 0.25);
        }
        
        .text-muted {
            color: var(--text-muted) !important;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <!-- Page Header - 멋진 그라데이션 배경 -->
        <div class="page-header">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-lg-8 col-md-12">
                        <h1 class="page-title" style="position: relative; z-index: 5;">
                            <i class="fas fa-route"></i>
                            여행의 시작, 완벽한 계획
                        </h1>
                        <p class="page-subtitle" style="position: relative; z-index: 5;">
                            함께하는 여행이 더 특별합니다.<br>
                            나만의 여행 계획을 세우고 최고의 동행을 찾아보세요.
                        </p>
                    </div>
                    <div class="col-lg-4 col-md-12 text-lg-end text-center mt-4 mt-lg-0">
                        <c:if test="${not empty sessionScope.loginUser}">
                            <div class="d-flex flex-column flex-lg-row gap-2 justify-content-lg-end justify-content-center">
                                <a href="${pageContext.request.contextPath}/travel/create" class="primary-button">
                                    <i class="fas fa-plus-circle me-2"></i>새 여행 계획
                                </a>
                                <c:if test="${!isMyPlans}">
                                    <a href="${pageContext.request.contextPath}/travel/my" class="secondary-button">
                                        <i class="fas fa-heart me-2"></i>내 계획
                                    </a>
                                </c:if>
                                <c:if test="${isMyPlans}">
                                    <a href="${pageContext.request.contextPath}/travel/list" class="secondary-button">
                                        <i class="fas fa-compass me-2"></i>전체 계획
                                    </a>
                                </c:if>
                            </div>
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
                        <form method="GET" action="${pageContext.request.contextPath}/travel/list" class="search-form">
                            <div class="row g-2 align-items-center mb-3">
                                <div class="col-auto">
                                    <label class="form-label mb-0 fw-bold text-primary">
                                        <i class="fas fa-search me-1"></i>검색
                                    </label>
                                </div>
                                <div class="col-auto">
                                    <select name="searchType" class="form-select form-select-sm search-select-inline">
                                        <option value="all" ${param.searchType == 'all' ? 'selected' : ''}>전체</option>
                                        <option value="title" ${param.searchType == 'title' ? 'selected' : ''}>제목</option>
                                        <option value="destination" ${param.searchType == 'destination' ? 'selected' : ''}>여행지</option>
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
                                            <a href="${pageContext.request.contextPath}/travel/list" 
                                               class="btn btn-outline-secondary">
                                                <i class="fas fa-times"></i>
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <button type="button" class="btn btn-outline-primary" id="filterToggle">
                                        <i class="fas fa-filter me-1"></i>필터
                                    </button>
                                </div>
                            </div>
                            
                            <!-- Filter Section -->
                            <div id="filterSection" class="mt-3" style="display: none;">
                                <div class="border rounded p-3 bg-light">
                                    <h6 class="fw-bold mb-3">🗺️ 여행 스타일 & 테마</h6>
                                    <div class="d-flex flex-wrap gap-2 mb-3">
                                        <input type="checkbox" class="btn-check" id="tag-힐링여행" name="tags" value="힐링여행" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-힐링여행">#힐링여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-감성여행" name="tags" value="감성여행" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-감성여행">#감성여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-식도락여행" name="tags" value="식도락여행" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-식도락여행">#식도락여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-액티비티" name="tags" value="액티비티" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-액티비티">#액티비티</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-뚜벅이여행" name="tags" value="뚜벅이여행" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-뚜벅이여행">#뚜벅이여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-캠핑" name="tags" value="캠핑" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-캠핑">#캠핑</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-호캉스" name="tags" value="호캉스" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-호캉스">#호캉스</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-커플여행" name="tags" value="커플여행" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-커플여행">#커플여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-우정여행" name="tags" value="우정여행" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-우정여행">#우정여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-반려동물동반" name="tags" value="반려동물동반" autocomplete="off">
                                        <label class="btn btn-outline-success btn-sm" for="tag-반려동물동반">#반려동물동반</label>
                                    </div>
                                    
                                    <h6 class="fw-bold mb-3">📍 여행지 & 지역</h6>
                                    <div class="d-flex flex-wrap gap-2 mb-3">
                                        <input type="checkbox" class="btn-check" id="tag-국내여행" name="tags" value="국내여행" autocomplete="off">
                                        <label class="btn btn-outline-primary btn-sm" for="tag-국내여행">#국내여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-해외여행" name="tags" value="해외여행" autocomplete="off">
                                        <label class="btn btn-outline-primary btn-sm" for="tag-해외여행">#해외여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-일본여행" name="tags" value="일본여행" autocomplete="off">
                                        <label class="btn btn-outline-primary btn-sm" for="tag-일본여행">#일본여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-유럽여행" name="tags" value="유럽여행" autocomplete="off">
                                        <label class="btn btn-outline-primary btn-sm" for="tag-유럽여행">#유럽여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-동남아여행" name="tags" value="동남아여행" autocomplete="off">
                                        <label class="btn btn-outline-primary btn-sm" for="tag-동남아여행">#동남아여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-미주여행" name="tags" value="미주여행" autocomplete="off">
                                        <label class="btn btn-outline-primary btn-sm" for="tag-미주여행">#미주여행</label>
                                    </div>
                                    
                                    <h6 class="fw-bold mb-3">🗓️ 기간 & 시기</h6>
                                    <div class="d-flex flex-wrap gap-2 mb-3">
                                        <input type="checkbox" class="btn-check" id="tag-당일치기" name="tags" value="당일치기" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-당일치기">#당일치기</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-1박2일" name="tags" value="1박2일" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-1박2일">#1박2일</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-2박3일" name="tags" value="2박3일" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-2박3일">#2박3일</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-장기여행" name="tags" value="장기여행" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-장기여행">#장기여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-여름휴가" name="tags" value="여름휴가" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-여름휴가">#여름휴가</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-겨울여행" name="tags" value="겨울여행" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-겨울여행">#겨울여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-봄꽃여행" name="tags" value="봄꽃여행" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-봄꽃여행">#봄꽃여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-가을단풍" name="tags" value="가을단풍" autocomplete="off">
                                        <label class="btn btn-outline-warning btn-sm" for="tag-가을단풍">#가을단풍</label>
                                    </div>
                                    
                                    <h6 class="fw-bold mb-3">👍 기타 & 추천</h6>
                                    <div class="d-flex flex-wrap gap-2 mb-3">
                                        <input type="checkbox" class="btn-check" id="tag-인생샷" name="tags" value="인생샷" autocomplete="off">
                                        <label class="btn btn-outline-info btn-sm" for="tag-인생샷">#인생샷</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-숨은명소" name="tags" value="숨은명소" autocomplete="off">
                                        <label class="btn btn-outline-info btn-sm" for="tag-숨은명소">#숨은명소</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-맛집추천" name="tags" value="맛집추천" autocomplete="off">
                                        <label class="btn btn-outline-info btn-sm" for="tag-맛집추천">#맛집추천</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-카페투어" name="tags" value="카페투어" autocomplete="off">
                                        <label class="btn btn-outline-info btn-sm" for="tag-카페투어">#카페투어</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-가성비여행" name="tags" value="가성비여행" autocomplete="off">
                                        <label class="btn btn-outline-info btn-sm" for="tag-가성비여행">#가성비여행</label>
                                        
                                        <input type="checkbox" class="btn-check" id="tag-여행꿀팁" name="tags" value="여행꿀팁" autocomplete="off">
                                        <label class="btn btn-outline-info btn-sm" for="tag-여행꿀팁">#여행꿀팁</label>
                                    </div>
                                    
                                    <div class="text-center">
                                        <button type="button" class="btn btn-primary me-2" onclick="applyFilters()">
                                            <i class="fas fa-search me-1"></i>검색
                                        </button>
                                        <button type="button" class="btn btn-outline-secondary" onclick="clearFilters()">
                                            <i class="fas fa-undo me-1"></i>초기화
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
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
        <c:if test="${not empty param.searchKeyword or not empty param.tags}">
            <div class="container">
                <div class="search-info">
                    <i class="fas fa-search me-2"></i>
                    <c:if test="${not empty param.searchKeyword}">
                        '<span class="search-keyword">${param.searchKeyword}</span>' 검색 결과 
                    </c:if>
                    <c:if test="${not empty param.tags}">
                        <c:if test="${not empty param.searchKeyword}"> + </c:if>
                        태그 필터: 
                        <c:forEach var="tag" items="${param.tags.split(',')}" varStatus="status">
                            <span class="badge bg-success me-1">#${tag}</span>
                        </c:forEach>
                    </c:if>
                    <span class="badge bg-primary ms-2">${not empty travelPlans ? travelPlans.size() : 0}건</span>
                </div>
            </div>
        </c:if>

        <!-- View Toggle and Sort Options -->
        <div class="container">
            <div class="row align-items-center mb-3">
                <div class="col-md-6">
                    <div class="view-toggle-wrapper d-flex align-items-center">
                        <button type="button" class="btn btn-outline-secondary btn-sm view-toggle-btn" onclick="toggleViewType()">
                            <i class="fas fa-th-large me-1"></i>
                            <span id="view-type-text">카드형</span>
                        </button>
                        <small class="text-muted ms-3">
                            총 <strong>${not empty travelPlans ? travelPlans.size() : 0}</strong>개의 여행 계획
                        </small>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="sort-options d-flex justify-content-end align-items-center">
                        <label class="form-label me-2 mb-0">정렬:</label>
                        <select class="form-select form-select-sm" style="width: auto;" onchange="changeSortOrder(this.value)">
                            <option value="" ${empty param.sortBy ? 'selected' : ''}>최신순</option>
                            <option value="view" ${param.sortBy == 'view' ? 'selected' : ''}>조회수순</option>
                            <option value="favorite" ${param.sortBy == 'favorite' ? 'selected' : ''}>참여자수순</option>
                            <option value="price_asc" ${param.sortBy == 'price_asc' ? 'selected' : ''}>가격 낮은순</option>
                            <option value="price_desc" ${param.sortBy == 'price_desc' ? 'selected' : ''}>가격 높은순</option>
                            <option value="manner_desc" ${param.sortBy == 'manner_desc' ? 'selected' : ''}>매너온도 높은순</option>
                            <option value="manner_asc" ${param.sortBy == 'manner_asc' ? 'selected' : ''}>매너온도 낮은순</option>
                            <option value="startdate_asc" ${param.sortBy == 'startdate_asc' ? 'selected' : ''}>출발일 빠른순</option>
                            <option value="startdate_desc" ${param.sortBy == 'startdate_desc' ? 'selected' : ''}>출발일 늦은순</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Travel Plans List -->
        <div class="container" style="margin: 2rem auto;">
            <c:choose>
                <c:when test="${empty travelPlans}">
                    <div class="text-center py-5">
                        <i class="fas fa-map fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">아직 등록된 여행 계획이 없습니다.</h5>
                        <c:if test="${not empty sessionScope.loginUser}">
                            <p class="text-muted">첫 번째 여행 계획을 만들어보세요!</p>
                            <a href="${pageContext.request.contextPath}/travel/create" class="btn btn-primary mt-3">
                                <i class="fas fa-plus-circle me-2"></i>여행 계획 만들기
                            </a>
                        </c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- Card View (Default) -->
                    <div class="view-card">
                        <div class="row">
                            <c:forEach items="${travelPlans}" var="plan">
                                <div class="col-md-4 col-lg-3 mb-3">
                                    <div class="card plan-card shadow-sm h-100" style="margin-bottom: 1rem;">
                                        <!-- Travel Image -->
                                        <c:if test="${not empty plan.planImage}">
                                            <div class="card-img-top-wrapper" style="height: 180px; overflow: hidden; border-radius: 16px 16px 0 0; position: relative;">
                                                <img src="${pageContext.request.contextPath}/uploads/${plan.planImage}" 
                                                     class="card-img-top" alt="${plan.planTitle}" 
                                                     style="width: 100%; height: 100%; object-fit: cover; transition: transform 0.3s ease;"
                                                     onmouseover="this.style.transform='scale(1.05)'" 
                                                     onmouseout="this.style.transform='scale(1)'">
                                                <div style="position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: linear-gradient(45deg, rgba(255, 107, 107, 0.1), rgba(78, 205, 196, 0.1)); opacity: 0; transition: opacity 0.3s ease;" 
                                                     onmouseover="this.style.opacity='1'" onmouseout="this.style.opacity='0'"></div>
                                            </div>
                                        </c:if>
                                        <div class="card-body">
                                            <h5 class="card-title">
                                                <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}" class="text-decoration-none" style="color: var(--text-primary);">
                                                    ${plan.planTitle}
                                                    <c:if test="${not empty plan.planImage}">
                                                        <i class="fas fa-camera text-primary ms-2" title="사진 첨부됨"></i>
                                                    </c:if>
                                                </a>
                                                <!-- 종료된 여행 표시 -->
                                                <c:if test="${plan.planStatus eq 'COMPLETED'}">
                                                    <span class="badge bg-danger ms-2">
                                                        <i class="fas fa-times-circle me-1"></i>동행 종료
                                                    </span>
                                                </c:if>
                                            </h5>
                                            <p class="mb-2">
                                                <span class="badge bg-primary destination-badge">
                                                    <i class="fas fa-map-marker-alt me-1"></i>${plan.planDestination}
                                                </span>
                                            </p>
                                            <p class="date-range mb-2">
                                                <i class="fas fa-calendar-alt me-1"></i>
                                                <fmt:formatDate value="${plan.planStartDate}" pattern="yyyy.MM.dd"/> ~ 
                                                <fmt:formatDate value="${plan.planEndDate}" pattern="yyyy.MM.dd"/>
                                            </p>
                                            <p class="text-muted small mb-2">
                                                <i class="fas fa-clock me-1"></i>등록일: 
                                                <fmt:formatDate value="${plan.planRegdate}" pattern="yyyy.MM.dd HH:mm"/>
                                            </p>
                                            <c:if test="${plan.planBudget != null && plan.planBudget > 0}">
                                                <p class="budget-info mb-2">
                                                    <i class="fas fa-won-sign me-1"></i>
                                                    <fmt:formatNumber value="${plan.planBudget}" pattern="#,###"/>원
                                                </p>
                                            </c:if>
                                            <p class="card-text" style="color: var(--text-secondary);">
                                                <c:choose>
                                                    <c:when test="${not empty plan.planContent && plan.planContent.length() > 100}">
                                                        ${plan.planContent.substring(0, 100)}...
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${plan.planContent}
                                                    </c:otherwise>
                                                </c:choose>
                                            </p>
                                            
                                            <!-- 태그 표시 -->
                                            <c:if test="${not empty plan.planTags}">
                                                <div class="mb-2">
                                                    <c:forEach var="tag" items="${plan.planTags.split(',')}" varStatus="status">
                                                        <span class="badge bg-light text-dark me-1" style="font-size: 0.7rem;">#${tag}</span>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                            
                                            <!-- 통계 정보 표시 - 컴팩트 디자인 -->
                                            <div class="mb-2 d-flex flex-wrap gap-1 justify-content-start">
                                                <span class="badge" style="
                                                    background: linear-gradient(135deg, #10b981, #059669);
                                                    color: white;
                                                    padding: 0.3rem 0.6rem;
                                                    border-radius: 12px;
                                                    font-weight: 500;
                                                    font-size: 0.7rem;
                                                    box-shadow: 0 2px 6px rgba(16, 185, 129, 0.2);
                                                ">
                                                    <i class="fas fa-users me-1" style="font-size: 0.7rem;"></i>${plan.participantCount}/${plan.maxParticipants}
                                                </span>
                                                <span class="badge" style="
                                                    background: linear-gradient(135deg, #6366f1, #4f46e5);
                                                    color: white;
                                                    padding: 0.3rem 0.6rem;
                                                    border-radius: 12px;
                                                    font-weight: 500;
                                                    font-size: 0.7rem;
                                                    box-shadow: 0 2px 6px rgba(99, 102, 241, 0.2);
                                                ">
                                                    <i class="fas fa-eye me-1" style="font-size: 0.7rem;"></i>${plan.planViewCount}
                                                </span>
                                            </div>
                                            
                                            <hr>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div class="writer-info">
                                                    <div>
                                                        <i class="fas fa-user me-1"></i>
                                                        <c:choose>
                                                            <c:when test="${not empty writerInfo[plan.planWriter].nickname}">
                                                                ${writerInfo[plan.planWriter].nickname}
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${plan.planWriter}
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${not empty writerMbtiStats[plan.planWriter]}">
                                                            <span class="badge bg-primary ms-1">${writerMbtiStats[plan.planWriter].mbtiType}</span>
                                                        </c:if>
                                                    </div>
                                                    <div class="text-muted small mt-1">
                                                        <c:if test="${not empty writerMannerStats[plan.planWriter]}">
                                                            <i class="fas fa-thermometer-half me-1" style="color: 
                                                                <c:choose>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 40.0}">red</c:when>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 37.0}">orange</c:when>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 35.0}">gold</c:when>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 32.0}">skyblue</c:when>
                                                                    <c:otherwise>mediumpurple</c:otherwise>
                                                                </c:choose>"></i>
                                                            <span style="color: 
                                                                <c:choose>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 40.0}">red</c:when>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 37.0}">orange</c:when>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 35.0}">gold</c:when>
                                                                    <c:when test="${writerMannerStats[plan.planWriter].averageMannerScore >= 32.0}">skyblue</c:when>
                                                                    <c:otherwise>mediumpurple</c:otherwise>
                                                                </c:choose>">${writerMannerStats[plan.planWriter].averageMannerScore}°C</span>
                                                            <span class="ms-2">
                                                        </c:if>
                                                        <c:if test="${not empty writerMannerStats[plan.planWriter]}">
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                </div>
                                                <div class="d-flex flex-wrap gap-2 align-items-center">
                                                    <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}" 
                                                       class="btn" style="
                                                        background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
                                                        color: white;
                                                        border: none;
                                                        padding: 0.4rem 1rem;
                                                        border-radius: 20px;
                                                        font-weight: 500;
                                                        font-size: 0.75rem;
                                                        transition: all 0.3s ease;
                                                        box-shadow: 0 2px 8px rgba(255, 107, 107, 0.2);
                                                        text-decoration: none;
                                                       "
                                                       onmouseover="this.style.transform='translateY(-1px)'; this.style.boxShadow='0 4px 12px rgba(255, 107, 107, 0.3)'" 
                                                       onmouseout="this.style.transform='translateY(0px)'; this.style.boxShadow='0 2px 8px rgba(255, 107, 107, 0.2)'">
                                                        상세보기 <i class="fas fa-arrow-right ms-1" style="font-size: 0.7rem;"></i>
                                                    </a>
                                                    <!-- 찜하기 버튼 추가 -->
                                                    <c:if test="${not empty sessionScope.loginUser && plan.planWriter ne sessionScope.loginUser.userId}">
                                                        <button class="btn btn-sm bookmark-btn"
                                                                data-type="TRAVEL_PLAN"
                                                                data-id="${plan.planId}"
                                                                data-bookmarked="${plan.favorite ? 'true' : 'false'}"
                                                                onclick="toggleBookmark(this)"
                                                                style="
                                                                    background: ${plan.favorite ? 'linear-gradient(135deg, #ef4444, #dc2626)' : 'white'};
                                                                    color: ${plan.favorite ? 'white' : '#ef4444'};
                                                                    border: ${plan.favorite ? 'none' : '1px solid #ef4444'};
                                                                    padding: 0.3rem 0.6rem;
                                                                    border-radius: 15px;
                                                                    font-size: 0.7rem;
                                                                    transition: all 0.3s ease;
                                                                ">
                                                            <i class="${plan.favorite ? 'fas' : 'far'} fa-heart"></i>
                                                        </button>
                                                    </c:if>

                                                    <!-- 상태 배지 - 세련된 디자인 -->
                                                    <c:if test="${not empty sessionScope.loginUser}">
                                                        <c:choose>
                                                            <c:when test="${plan.planWriter eq sessionScope.loginUser.userId}">
                                                                <span class="badge" style="
                                                                    background: linear-gradient(135deg, #6b7280, #4b5563);
                                                                    color: white;
                                                                    padding: 0.3rem 0.6rem;
                                                                    border-radius: 15px;
                                                                    font-weight: 500;
                                                                    font-size: 0.65rem;
                                                                ">내 계획</span>
                                                            </c:when>
                                                            <c:when test="${plan.userApproved || plan.userJoined}">
                                                                <span class="badge" style="
                                                                    background: linear-gradient(135deg, #10b981, #059669);
                                                                    color: white;
                                                                    padding: 0.3rem 0.6rem;
                                                                    border-radius: 15px;
                                                                    font-weight: 500;
                                                                    font-size: 0.65rem;
                                                                    box-shadow: 0 2px 6px rgba(16, 185, 129, 0.2);
                                                                ">
                                                                    <i class="fas fa-check-circle me-1" style="font-size: 0.6rem;"></i>참여 중
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${plan.userRequestPending}">
                                                                <span class="badge" style="
                                                                    background: linear-gradient(135deg, #f59e0b, #d97706);
                                                                    color: white;
                                                                    padding: 0.5rem 1rem;
                                                                    border-radius: 20px;
                                                                    font-weight: 600;
                                                                    font-size: 0.8rem;
                                                                    box-shadow: 0 3px 10px rgba(245, 158, 11, 0.3);
                                                                ">
                                                                    <i class="fas fa-clock me-1"></i>대기 중
                                                                </span>
                                                            </c:when>
                                                        </c:choose>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                    
                    <!-- List View -->
                    <div class="view-list" style="display: none;">
                        <c:forEach items="${travelPlans}" var="plan">
                            <div class="plan-card mb-4">
                                <div class="row align-items-center" style="padding: 1.5rem;">
                                    <c:if test="${not empty plan.planImage}">
                                        <div class="col-auto">
                                            <img src="${pageContext.request.contextPath}/uploads/${plan.planImage}" 
                                                 alt="${plan.planTitle}" 
                                                 style="width: 100px; height: 75px; object-fit: cover; border-radius: 10px;">
                                        </div>
                                    </c:if>
                                    <div class="col">
                                        <h5 class="mb-1">
                                            <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}" class="text-decoration-none" style="color: var(--text-primary);">
                                                ${plan.planTitle}
                                                <c:if test="${not empty plan.planImage}">
                                                    <i class="fas fa-camera text-primary ms-2" title="사진 첨부됨"></i>
                                                </c:if>
                                            </a>
                                            <!-- 종료된 여행 표시 -->
                                            <c:if test="${plan.planStatus eq 'COMPLETED'}">
                                                <span class="badge bg-danger ms-2">
                                                    <i class="fas fa-times-circle me-1"></i>동행 종료
                                                </span>
                                            </c:if>
                                        </h5>
                                        <div class="mb-2">
                                            <span class="badge bg-primary destination-badge me-2">
                                                <i class="fas fa-map-marker-alt me-1"></i>${plan.planDestination}
                                            </span>
                                            <span class="date-range me-3">
                                                <i class="fas fa-calendar-alt me-1"></i>
                                                <fmt:formatDate value="${plan.planStartDate}" pattern="MM.dd"/> ~ <fmt:formatDate value="${plan.planEndDate}" pattern="MM.dd"/>
                                            </span>
                                            <span class="text-muted small">
                                                <i class="fas fa-clock me-1"></i>등록: <fmt:formatDate value="${plan.planRegdate}" pattern="MM.dd HH:mm"/>
                                            </span>
                                        </div>
                                        <p class="mb-2" style="color: var(--text-secondary);">
                                            <c:choose>
                                                <c:when test="${not empty plan.planContent && plan.planContent.length() > 80}">
                                                    ${plan.planContent.substring(0, 80)}...
                                                </c:when>
                                                <c:otherwise>
                                                    ${plan.planContent}
                                                </c:otherwise>
                                            </c:choose>
                                        </p>
                                        <!-- 태그 표시 -->
                                        <c:if test="${not empty plan.planTags}">
                                            <div class="mb-0">
                                                <c:forEach var="tag" items="${plan.planTags.split(',')}" varStatus="status">
                                                    <span class="badge bg-light text-dark me-1" style="font-size: 0.6rem;">#${tag}</span>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </div>
                                    <div class="col-auto text-end">
                                        <div class="mb-2">
                                            <span class="badge bg-info">
                                                <i class="fas fa-users me-1"></i>${plan.participantCount}/${plan.maxParticipants}명
                                            </span>
                                            <!-- 찜하기 버튼 추가 -->
                                            <c:if test="${not empty sessionScope.loginUser && plan.planWriter ne sessionScope.loginUser.userId}">
                                                <button class="btn btn-sm bookmark-btn ms-2"
                                                        data-type="TRAVEL_PLAN"
                                                        data-id="${plan.planId}"
                                                        data-bookmarked="${plan.favorite ? 'true' : 'false'}"
                                                        onclick="toggleBookmark(this)"
                                                        style="
                                                            background: ${plan.favorite ? 'linear-gradient(135deg, #ef4444, #dc2626)' : 'white'};
                                                            color: ${plan.favorite ? 'white' : '#ef4444'};
                                                            border: ${plan.favorite ? 'none' : '1px solid #ef4444'};
                                                            padding: 0.4rem 0.7rem;
                                                            border-radius: 15px;
                                                            font-size: 0.8rem;
                                                            transition: all 0.3s ease;
                                                        ">
                                                    <i class="${plan.favorite ? 'fas' : 'far'} fa-heart"></i>
                                                </button>
                                            </c:if>
                                        </div>
                                        <div class="writer-info">
                                            <i class="fas fa-user me-1"></i>${plan.planWriter}
                                            <div class="text-muted small">
                                                <fmt:formatDate value="${plan.planRegdate}" pattern="MM.dd HH:mm"/>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                    
                    <!-- Compact View -->
                    <div class="view-compact" style="display: none;">
                        <c:forEach items="${travelPlans}" var="plan">
                            <div class="plan-card mb-2" style="padding: 1rem; border-radius: 10px;">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div class="d-flex align-items-center flex-grow-1">
                                        <span class="badge bg-primary destination-badge me-2">
                                            <i class="fas fa-map-marker-alt me-1"></i>${plan.planDestination}
                                        </span>
                                        <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}" class="text-decoration-none fw-bold" style="color: var(--text-primary);">
                                            ${plan.planTitle}
                                            <c:if test="${not empty plan.planImage}">
                                                <i class="fas fa-camera text-primary ms-2" title="사진 첨부됨"></i>
                                            </c:if>
                                        </a>
                                        <!-- 종료된 여행 표시 -->
                                        <c:if test="${plan.planStatus eq 'COMPLETED'}">
                                            <span class="badge bg-danger ms-2 small">
                                                <i class="fas fa-times-circle me-1"></i>종료
                                            </span>
                                        </c:if>
                                    </div>
                                    <div class="d-flex align-items-center gap-3">
                                        <span class="text-muted small">
                                            <i class="fas fa-calendar me-1"></i><fmt:formatDate value="${plan.planStartDate}" pattern="MM.dd"/>
                                        </span>
                                        <span class="text-muted small">
                                            <i class="fas fa-users me-1"></i>${plan.participantCount}/${plan.maxParticipants}명
                                        </span>
                                        <span class="text-muted small">
                                            <i class="fas fa-user me-1"></i>${plan.planWriter}
                                        </span>
                                        <!-- 찜하기 버튼 추가 -->
                                        <c:if test="${not empty sessionScope.loginUser && plan.planWriter ne sessionScope.loginUser.userId}">
                                            <button class="btn btn-sm bookmark-btn"
                                                    data-type="TRAVEL_PLAN"
                                                    data-id="${plan.planId}"
                                                    data-bookmarked="${plan.favorite ? 'true' : 'false'}"
                                                    onclick="toggleBookmark(this)"
                                                    style="
                                                        background: ${plan.favorite ? 'linear-gradient(135deg, #ef4444, #dc2626)' : 'white'};
                                                        color: ${plan.favorite ? 'white' : '#ef4444'};
                                                        border: ${plan.favorite ? 'none' : '1px solid #ef4444'};
                                                        padding: 0.2rem 0.4rem;
                                                        border-radius: 10px;
                                                        font-size: 0.65rem;
                                                        transition: all 0.3s ease;
                                                    ">
                                                <i class="${plan.favorite ? 'fas' : 'far'} fa-heart"></i>
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

        <!-- Footer -->
        <footer class="bg-dark text-white py-4" style="margin-top: 3rem;">
            <div class="container text-center">
                <p class="mb-0">&copy; 2024 AI 여행 동행 매칭 플랫폼. All rights reserved.</p>
            </div>
        </footer>
    </div>

    
    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        console.log('JavaScript 파일 로딩 시작');
        
        // 1. 전역 변수 선언
        let currentViewType = 'card';
        
        // 2. 필터 적용 함수 (즉시 전역 등록)
        window.applyFilters = function() {
            try {
                console.log('=== 필터 적용 시작 ===');
                
                // 모든 태그 체크박스 찾기
                const allTagInputs = document.querySelectorAll('input[name="tags"]');
                const checkedTags = document.querySelectorAll('input[name="tags"]:checked');
                
                console.log('전체 태그 입력 요소 수:', allTagInputs.length);
                console.log('체크된 태그 요소 수:', checkedTags.length);
                console.log('전체 태그 입력 요소들:', allTagInputs);
                console.log('체크된 태그 요소들:', checkedTags);
                
                const selectedTags = [];
                
                checkedTags.forEach(function(tag) {
                    selectedTags.push(tag.value);
                    console.log('선택된 태그:', tag.value);
                });
                
                console.log('선택된 태그 배열:', selectedTags);
                
                if (selectedTags.length === 0) {
                    alert('필터할 태그를 선택해주세요.');
                    return;
                }
            
                // Get current search parameters
                const searchType = document.querySelector('select[name="searchType"]').value;
                const searchKeyword = document.querySelector('input[name="searchKeyword"]').value;
                
                console.log('현재 검색 조건:', {searchType, searchKeyword});
                
                // Build URL with filters
                let url = '${pageContext.request.contextPath}/travel/list?';
                
                // Get current sort option
                const urlParams = new URLSearchParams(window.location.search);
                const sortBy = urlParams.get('sortBy');
                
                console.log('현재 정렬 옵션:', sortBy);
                
                if (searchKeyword && searchKeyword.trim() !== '') {
                    url += 'searchType=' + encodeURIComponent(searchType) + '&';
                    url += 'searchKeyword=' + encodeURIComponent(searchKeyword) + '&';
                }
                
                url += 'tags=' + encodeURIComponent(selectedTags.join(','));
                
                if (sortBy) {
                    url += '&sortBy=' + encodeURIComponent(sortBy);
                }
                
                console.log('생성된 URL:', url);
                console.log('=== 필터 적용 완료, 페이지 이동 ===');
                
                // Redirect with filters
                window.location.href = url;
                
            } catch (error) {
                console.error('필터 적용 중 오류 발생:', error);
                alert('필터 적용 중 오류가 발생했습니다: ' + error.message);
            }
        };
        
        // 3. 필터 클리어 함수 (즉시 전역 등록)
        window.clearFilters = function() {
            // Uncheck all checkboxes
            const allTags = document.querySelectorAll('input[name="tags"]:checked');
            allTags.forEach(function(tag) {
                tag.checked = false;
            });
            
            // Redirect to list without filters
            const searchType = document.querySelector('select[name="searchType"]').value;
            const searchKeyword = document.querySelector('input[name="searchKeyword"]').value;
            
            let url = '${pageContext.request.contextPath}/travel/list';
            const params = [];
            
            if (searchKeyword) {
                params.push('searchType=' + encodeURIComponent(searchType));
                params.push('searchKeyword=' + encodeURIComponent(searchKeyword));
            }
            
            // Keep current sort option
            const urlParams = new URLSearchParams(window.location.search);
            const sortBy = urlParams.get('sortBy');
            if (sortBy) {
                params.push('sortBy=' + encodeURIComponent(sortBy));
            }
            
            if (params.length > 0) {
                url += '?' + params.join('&');
            }
            
            window.location.href = url;
        };

        // 4. 여행 참여 함수들
        function joinTravel(planId) {
            if (!confirm('이 여행에 참여하시겠습니까?')) {
                return;
            }
            
            $.ajax({
                url: '/travel/join/' + planId,
                type: 'POST',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('참여 처리 중 오류가 발생했습니다.');
                }
            });
        }
        
        function leaveTravel(planId) {
            if (!confirm('정말로 참여를 취소하시겠습니까?')) {
                return;
            }
            
            $.ajax({
                url: '/travel/leave/' + planId,
                type: 'POST',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('참여 취소 처리 중 오류가 발생했습니다.');
                }
            });
        }
        
        // 5. 뷰 타입 전환 함수 (즉시 전역 등록)
        window.toggleViewType = function() {
            try {
                console.log('=== 뷰 타입 전환 시작 ===');
                console.log('현재 뷰 타입:', currentViewType);
                
                // 뷰 컨테이너들 찾기
                const cardView = document.querySelector('.view-card');
                const listView = document.querySelector('.view-list');
                const compactView = document.querySelector('.view-compact');
                
                console.log('찾은 뷰 컨테이너들:');
                console.log('cardView:', cardView);
                console.log('listView:', listView);
                console.log('compactView:', compactView);
                
                if (!cardView || !listView || !compactView) {
                    console.error('뷰 컨테이너를 찾을 수 없습니다!');
                    alert('뷰 전환 기능에 문제가 있습니다. 페이지를 새로고침해주세요.');
                    return;
                }
                
                // 버튼과 텍스트 요소
                const viewToggleBtn = document.querySelector('.view-toggle-btn');
                const viewTypeText = document.getElementById('view-type-text');
                const viewToggleIcon = viewToggleBtn ? viewToggleBtn.querySelector('i') : null;
                
                console.log('버튼 요소:', viewToggleBtn);
                console.log('텍스트 요소:', viewTypeText);
                
                // 현재 스타일 상태 로깅
                console.log('현재 스타일 상태:');
                console.log('cardView.style.display:', cardView.style.display);
                console.log('listView.style.display:', listView.style.display);
                console.log('compactView.style.display:', compactView.style.display);
                
                // 모든 뷰에 hidden 클래스 추가하고 active 클래스 제거
                cardView.classList.remove('view-active');
                cardView.classList.add('view-hidden');
                cardView.style.setProperty('display', 'none', 'important');
                cardView.style.setProperty('visibility', 'hidden', 'important');
                cardView.style.setProperty('opacity', '0', 'important');
                
                listView.classList.remove('view-active');
                listView.classList.add('view-hidden');
                listView.style.setProperty('display', 'none', 'important');
                listView.style.setProperty('visibility', 'hidden', 'important');
                listView.style.setProperty('opacity', '0', 'important');
                
                compactView.classList.remove('view-active');
                compactView.classList.add('view-hidden');
                compactView.style.setProperty('display', 'none', 'important');
                compactView.style.setProperty('visibility', 'hidden', 'important');
                compactView.style.setProperty('opacity', '0', 'important');
                
                console.log('모든 뷰 숨김 처리 완료');
                
                // 뷰 타입 전환
                if (currentViewType === 'card') {
                    currentViewType = 'list';
                    listView.classList.remove('view-hidden');
                    listView.classList.add('view-active');
                    listView.style.setProperty('display', 'block', 'important');
                    listView.style.setProperty('visibility', 'visible', 'important');
                    listView.style.setProperty('opacity', '1', 'important');
                    if (viewTypeText) viewTypeText.textContent = '리스트형';
                    if (viewToggleIcon) viewToggleIcon.className = 'fas fa-list me-1';
                    console.log('→ 리스트형으로 전환 완료');
                    console.log('listView 최종 스타일:', listView.style.display, listView.style.visibility, listView.style.opacity);
                } else if (currentViewType === 'list') {
                    currentViewType = 'compact';
                    compactView.classList.remove('view-hidden');
                    compactView.classList.add('view-active');
                    compactView.style.setProperty('display', 'block', 'important');
                    compactView.style.setProperty('visibility', 'visible', 'important');
                    compactView.style.setProperty('opacity', '1', 'important');
                    if (viewTypeText) viewTypeText.textContent = '간략형';
                    if (viewToggleIcon) viewToggleIcon.className = 'fas fa-bars me-1';
                    console.log('→ 간략형으로 전환 완료');
                    console.log('compactView 최종 스타일:', compactView.style.display, compactView.style.visibility, compactView.style.opacity);
                } else {
                    currentViewType = 'card';
                    cardView.classList.remove('view-hidden');
                    cardView.classList.add('view-active');
                    cardView.style.setProperty('display', 'block', 'important');
                    cardView.style.setProperty('visibility', 'visible', 'important');
                    cardView.style.setProperty('opacity', '1', 'important');
                    if (viewTypeText) viewTypeText.textContent = '카드형';
                    if (viewToggleIcon) viewToggleIcon.className = 'fas fa-th-large me-1';
                    console.log('→ 카드형으로 전환 완료');
                    console.log('cardView 최종 스타일:', cardView.style.display, cardView.style.visibility, cardView.style.opacity);
                }
                
                // 전환 후 상태 다시 로깅
                console.log('전환 후 스타일 상태:');
                console.log('cardView.style.display:', cardView.style.display);
                console.log('listView.style.display:', listView.style.display);  
                console.log('compactView.style.display:', compactView.style.display);
                console.log('현재 뷰 타입:', currentViewType);
                
                // 실제 가시성 확인
                setTimeout(() => {
                    const cardVisible = cardView.offsetHeight > 0 && cardView.offsetWidth > 0;
                    const listVisible = listView.offsetHeight > 0 && listView.offsetWidth > 0;
                    const compactVisible = compactView.offsetHeight > 0 && compactView.offsetWidth > 0;
                    
                    // 콘텐츠 존재 여부 확인
                    const cardContent = cardView.children.length;
                    const listContent = listView.children.length;
                    const compactContent = compactView.children.length;
                    
                    console.log('전환 후 가시성 체크:', {
                        currentViewType, 
                        cardVisible, 
                        listVisible, 
                        compactVisible,
                        cardContent,
                        listContent,
                        compactContent
                    });
                    
                    // 콘텐츠 존재 여부 로깅
                    console.log('각 뷰의 콘텐츠:');
                    console.log('카드뷰 콘텐츠 수:', cardContent);
                    console.log('리스트뷰 콘텐츠 수:', listContent);
                    console.log('간략뷰 콘텐츠 수:', compactContent);
                    
                    // 현재 뷰타입에 맞는 뷰가 보이지 않으면 경고
                    if (currentViewType === 'card' && !cardVisible) {
                        console.error('카드뷰가 활성화되어야 하지만 보이지 않습니다!');
                    } else if (currentViewType === 'list' && !listVisible) {
                        console.error('리스트뷰가 활성화되어야 하지만 보이지 않습니다!');
                        if (listContent === 0) {
                            console.error('리스트뷰에 콘텐츠가 없습니다!');
                        }
                    } else if (currentViewType === 'compact' && !compactVisible) {
                        console.error('간략뷰가 활성화되어야 하지만 보이지 않습니다!');
                        if (compactContent === 0) {
                            console.error('간략뷰에 콘텐츠가 없습니다!');
                        }
                    }
                }, 100);
                
                console.log('=== 뷰 타입 전환 완료 ===');
                
            } catch (error) {
                console.error('뷰 타입 전환 중 오류 발생:', error);
                alert('뷰 전환 중 오류가 발생했습니다: ' + error.message);
            }
        };
        
        // 페이지 로드 시 초기 설정
        document.addEventListener('DOMContentLoaded', function() {
            console.log('페이지 로드 완료, 초기화 시작');
            
            // 1. 뷰 타입 초기화
            const cardView = document.querySelector('.view-card');
            const listView = document.querySelector('.view-list');
            const compactView = document.querySelector('.view-compact');
            
            console.log('뷰 요소 확인:');
            console.log('cardView:', cardView);
            console.log('listView:', listView);
            console.log('compactView:', compactView);
            
            if (cardView && listView && compactView) {
                // 카드 뷰를 기본으로 설정
                cardView.classList.add('view-active');
                cardView.classList.remove('view-hidden');
                cardView.style.setProperty('display', 'block', 'important');
                cardView.style.setProperty('visibility', 'visible', 'important');
                cardView.style.setProperty('opacity', '1', 'important');
                
                // 리스트와 간략형 뷰 숨기기
                listView.classList.add('view-hidden');
                listView.classList.remove('view-active');
                listView.style.setProperty('display', 'none', 'important');
                listView.style.setProperty('visibility', 'hidden', 'important');
                listView.style.setProperty('opacity', '0', 'important');
                
                compactView.classList.add('view-hidden');
                compactView.classList.remove('view-active');
                compactView.style.setProperty('display', 'none', 'important');
                compactView.style.setProperty('visibility', 'hidden', 'important');
                compactView.style.setProperty('opacity', '0', 'important');
                
                // currentViewType 재설정
                currentViewType = 'card';
                
                console.log('초기 뷰 설정 완료 - currentViewType:', currentViewType);
                console.log('초기 스타일 확인:');
                console.log('cardView display:', cardView.style.display, 'visibility:', cardView.style.visibility);
                console.log('listView display:', listView.style.display, 'visibility:', listView.style.visibility);
                console.log('compactView display:', compactView.style.display, 'visibility:', compactView.style.visibility);
                
                // 실제 뷰가 보이는지 확인
                setTimeout(() => {
                    const cardVisible = cardView.offsetHeight > 0 && cardView.offsetWidth > 0;
                    const listVisible = listView.offsetHeight > 0 && listView.offsetWidth > 0;
                    const compactVisible = compactView.offsetHeight > 0 && compactView.offsetWidth > 0;
                    console.log('뷰 가시성 체크:', {cardVisible, listVisible, compactVisible});
                }, 100);
            } else {
                console.error('뷰 요소들을 찾을 수 없습니다 (초기화 시)');
                console.error('Missing elements:', {
                    cardView: !!cardView,
                    listView: !!listView,
                    compactView: !!compactView
                });
            }
            
            // 2. 필터 토글 기능 초기화
            const filterToggle = document.getElementById('filterToggle');
            const filterSection = document.getElementById('filterSection');
            
            console.log('=== 필터 요소들 확인 ===');
            console.log('filterToggle element:', filterToggle);
            console.log('filterToggle tagName:', filterToggle ? filterToggle.tagName : 'null');
            console.log('filterToggle id:', filterToggle ? filterToggle.id : 'null');
            console.log('filterSection element:', filterSection);
            console.log('filterSection tagName:', filterSection ? filterSection.tagName : 'null');
            console.log('filterSection id:', filterSection ? filterSection.id : 'null');
            
            if (filterToggle && filterSection) {
                console.log('필터 이벤트 리스너 등록 중...');
                
                // 기존 이벤트 리스너 제거 후 새로 등록
                filterToggle.onclick = null;
                filterToggle.addEventListener('click', function() {
                    console.log('필터 버튼 클릭됨');
                    if (filterSection.style.display === 'none' || filterSection.style.display === '') {
                        filterSection.style.display = 'block';
                        filterToggle.innerHTML = '<i class="fas fa-filter me-1"></i>필터 닫기';
                        console.log('필터 섹션 열림');
                    } else {
                        filterSection.style.display = 'none';
                        filterToggle.innerHTML = '<i class="fas fa-filter me-1"></i>필터';
                        console.log('필터 섹션 닫힘');
                    }
                });
                
                // 3. URL에서 선택된 태그 복원
                const urlParams = new URLSearchParams(window.location.search);
                const selectedTags = urlParams.get('tags');
                
                console.log('URL에서 선택된 태그:', selectedTags);
                
                if (selectedTags) {
                    const tagArray = selectedTags.split(',');
                    tagArray.forEach(function(tag) {
                        const checkbox = document.getElementById('tag-' + tag);
                        if (checkbox) {
                            checkbox.checked = true;
                            console.log('태그 체크됨:', tag);
                        }
                    });
                    
                    // Show filter section if tags are selected
                    if (tagArray.length > 0) {
                        filterSection.style.display = 'block';
                        filterToggle.innerHTML = '<i class="fas fa-filter me-1"></i>필터 닫기';
                        console.log('필터 섹션 자동 열림 (태그 선택됨)');
                    }
                }
                
                console.log('필터 초기화 완료');
            } else {
                console.error('필터 요소를 찾을 수 없습니다!');
            }
            
            console.log('모든 초기화 완료');
        });
        
        // 6. 정렬 순서 변경 함수 (즉시 전역 등록)
        window.changeSortOrder = function(sortBy) {
            try {
                console.log('=== 정렬 순서 변경 시작 ===');
                console.log('선택된 정렬:', sortBy);
                
                const urlParams = new URLSearchParams(window.location.search);
                console.log('현재 URL 파라미터:', urlParams.toString());
                
                // 기존 파라미터들 유지
                const searchType = urlParams.get('searchType');
                const searchKeyword = urlParams.get('searchKeyword');
                const tags = urlParams.get('tags');
                
                console.log('기존 파라미터들:');
                console.log('- searchType:', searchType);
                console.log('- searchKeyword:', searchKeyword);
                console.log('- tags:', tags);
                
                // 새 URL 구성
                let newUrl = '${pageContext.request.contextPath}/travel/list';
                const params = [];
                
                if (searchType && searchKeyword) {
                    params.push('searchType=' + encodeURIComponent(searchType));
                    params.push('searchKeyword=' + encodeURIComponent(searchKeyword));
                }
                if (tags) {
                    params.push('tags=' + encodeURIComponent(tags));
                }
                if (sortBy && sortBy !== '') {
                    params.push('sortBy=' + encodeURIComponent(sortBy));
                }
                
                if (params.length > 0) {
                    newUrl += '?' + params.join('&');
                }
                
                console.log('새 URL:', newUrl);
                console.log('=== 정렬 순서 변경 완료 ===');
                
                window.location.href = newUrl;
                
            } catch (error) {
                console.error('정렬 순서 변경 중 오류 발생:', error);
                alert('정렬 기능에 오류가 발생했습니다: ' + error.message);
            }
        };
        
        // 7. 찜하기 토글 함수
        window.toggleBookmark = function(button) {
            const type = button.getAttribute('data-type');
            const id = button.getAttribute('data-id');
            const isBookmarked = button.getAttribute('data-bookmarked') === 'true';

            // 로그인 체크
            if (!${not empty sessionScope.loginUser}) {
                alert('로그인이 필요한 서비스입니다.');
                window.location.href = '${pageContext.request.contextPath}/member/login';
                return;
            }

            // Ajax 요청
            $.ajax({
                url: '${pageContext.request.contextPath}/travel/favorite/toggle',
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
        };

        // 8. 모든 함수 등록 완료 로그
        console.log('=== 모든 전역 함수 등록 완료 ===');
        console.log('window.toggleViewType:', typeof window.toggleViewType);
        console.log('window.changeSortOrder:', typeof window.changeSortOrder);
        console.log('window.applyFilters:', typeof window.applyFilters);
        console.log('window.clearFilters:', typeof window.clearFilters);
        console.log('window.toggleBookmark:', typeof window.toggleBookmark);
        
        // 함수 테스트
        if (typeof window.toggleViewType !== 'function') {
            console.error('toggleViewType 함수가 정의되지 않았습니다!');
        }
        if (typeof window.changeSortOrder !== 'function') {
            console.error('changeSortOrder 함수가 정의되지 않았습니다!');
        }
        if (typeof window.applyFilters !== 'function') {
            console.error('applyFilters 함수가 정의되지 않았습니다!');
        }
        if (typeof window.clearFilters !== 'function') {
            console.error('clearFilters 함수가 정의되지 않았습니다!');
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>