<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>마이페이지 대시보드 - AI 여행 동행 매칭 플랫폼</title>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- FullCalendar CSS -->
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />
    <style>
        :root {
            --header-height: 60px; /* From header.jsp */
            --sidebar-width: 260px;
            --sidebar-bg: #2c3e50;
            --sidebar-text-color: #ecf0f1;
            --sidebar-active-bg: #34495e;
            --main-bg: #f5f7fa;
            --card-bg: #ffffff;
            --card-border-radius: 12px;
            --primary-accent: #3498db;
        }

        body {
            background-color: var(--main-bg);
            padding-top: var(--header-height); /* Space for fixed header */
            overflow-x: hidden;
        }

        .dashboard-wrapper {
            display: flex;
        }

        /* Sidebar Styles */
        .dashboard-sidebar {
            width: var(--sidebar-width);
            background-color: var(--sidebar-bg);
            color: var(--sidebar-text-color);
            position: fixed;
            top: var(--header-height);
            left: 0;
            height: calc(100vh - var(--header-height));
            padding-top: 40px;
            transition: transform 0.3s ease;
            z-index: 999; /* Below header */
            display: flex;
            flex-direction: column;
        }

        .sidebar-header {
            padding: 0 25px 20px 25px;
            margin-top: 20px;
            border-bottom: 1px solid #34495e;
            text-align: center;
            flex-shrink: 0;
        }

        .sidebar-header h3 {
            font-weight: 700;
            font-size: 1.5rem;
            color: white;
        }

        .sidebar-header h3 i {
            margin-right: 10px;
        }

        .sidebar-nav {
            list-style: none;
            padding: 20px 0;
            margin: 0;
            overflow-y: auto; /* Add scroll for long content */
            flex-grow: 1;
            padding-bottom: 40px;
        }

        .sidebar-nav-item {
            position: relative;
        }

        .sidebar-nav-item > a {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: var(--sidebar-text-color);
            text-decoration: none;
            font-weight: 500;
            transition: background-color 0.2s ease, color 0.2s ease;
            border-left: 4px solid transparent;
            white-space: nowrap;
            cursor: pointer;
        }

        .sidebar-nav-item > a i {
            margin-right: 15px;
            width: 20px;
            font-size: 1.1rem;
        }

        .sidebar-nav-item > a .dropdown-icon {
            margin-left: auto;
            transition: transform 0.3s ease;
        }

        .sidebar-nav-item.expanded > a .dropdown-icon {
            transform: rotate(180deg);
        }

        .sidebar-nav-item > a:hover {
            background-color: var(--sidebar-active-bg);
        }

        .sidebar-nav-item.active > a {
            background-color: var(--sidebar-active-bg);
            color: white;
            border-left-color: var(--primary-accent);
        }

        /* Dropdown submenu styles */
        .sidebar-submenu {
            list-style: none;
            padding: 0;
            margin: 0;
            background-color: rgba(0,0,0,0.1);
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease;
        }

        .sidebar-nav-item.expanded .sidebar-submenu {
            max-height: 500px;
        }

        .sidebar-submenu li a {
            display: block;
            padding: 12px 25px 12px 50px;
            color: var(--sidebar-text-color);
            text-decoration: none;
            font-size: 0.9rem;
            transition: background-color 0.2s ease;
        }

        .sidebar-submenu li a:hover {
            background-color: var(--sidebar-active-bg);
        }

        .sidebar-submenu li.active a {
            color: var(--primary-accent);
            font-weight: 600;
        }

        /* Main Content Styles */
        .dashboard-content {
            margin-left: var(--sidebar-width);
            width: calc(100% - var(--sidebar-width));
            padding: 30px;
            transition: margin-left 0.3s ease, width 0.3s ease;
        }

        .content-section {
            display: none;
        }

        .content-section.active {
            display: block;
        }

        .page-header {
            margin-bottom: 30px;
        }

        .page-header h1 {
            font-weight: 700;
        }

        /* Card Styles */
        .dashboard-card {
            background-color: var(--card-bg);
            border-radius: var(--card-border-radius);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
            border: none;
            margin-bottom: 30px;
            overflow: hidden;
            height: 100%; /* For equal height cards */
        }

        .dashboard-card .card-header {
            background-color: transparent;
            border-bottom: 1px solid #e9ecef;
            padding: 1.25rem 1.5rem;
            font-weight: 600;
            font-size: 1.1rem;
        }

        .dashboard-card .card-header i {
            margin-right: 10px;
            color: var(--primary-accent);
        }

        .dashboard-card .card-body {
            padding: 1.5rem;
        }

        .dashboard-card td, .dashboard-card th, .dashboard-card p {
            word-break: break-word;
            white-space: normal;
        }

        /* Stat Card Styles */
        .stat-card-link {
            text-decoration: none;
            color: white;
            display: block;
            height: 100%;
        }
        .stat-card {
            text-align: center;
            padding: 15px;
            border-radius: var(--card-border-radius);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            height: 100%;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }
        .stat-card i {
            font-size: 1.8rem;
            margin-bottom: 8px;
            opacity: 0.8;
        }
        .stat-card h3 {
            font-size: 2rem;
            font-weight: 700;
        }
        .stat-card p {
            margin: 0;
            font-weight: 500;
            font-size: 0.9rem;
        }
        .bg-stat-1 { background: linear-gradient(135deg, #56ab2f, #a8e063); }
        .bg-stat-2 { background: linear-gradient(135deg, #6a82fb, #fc5c7d); }
        .bg-stat-3 { background: linear-gradient(135deg, #f2994a, #f2c94c); }
        .bg-stat-4 { background: linear-gradient(135deg, #8e2de2, #4a00e0); }
        .bg-stat-5 { background: linear-gradient(135deg, #ff6b6b, #ffc371); }
        .bg-stat-6 { background: linear-gradient(135deg, #30cfd0, #330867); } /* New style for AI Saves */

        /* Profile Header in Dashboard */
        .profile-widget {
            display: flex;
            align-items: center;
        }
        .profile-widget-img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 20px;
        }
        .profile-widget-info h5 { margin: 0; font-weight: 600; }
        .profile-widget-info p { margin: 0; color: #6c757d; }

        /* Responsive Design */
        .sidebar-toggle {
            display: none;
            position: fixed;
            top: calc(var(--header-height) + 15px);
            left: 15px;
            z-index: 1001;
            background: var(--sidebar-bg);
            color: white;
            border: none;
            border-radius: 50%;
            width: 45px;
            height: 45px;
            font-size: 1.5rem;
        }

        @media (max-width: 992px) {
            .dashboard-sidebar { transform: translateX(calc(var(--sidebar-width) * -1)); }
            .dashboard-sidebar.show { transform: translateX(0); }
            .dashboard-content { margin-left: 0; width: 100%; }
            .sidebar-toggle { display: block; }
        }

        .table-dashboard { border-collapse: separate; border-spacing: 0 8px; width: 100%; }
        .table-dashboard thead th { border: none; color: #888; font-weight: 600; padding: 0 1rem; }
        .table-dashboard tbody tr { background: #f8f9fa; border-radius: 8px; transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .table-dashboard tbody tr:hover { transform: translateY(-3px); box-shadow: 0 8px 15px rgba(0,0,0,0.07); }
        .table-dashboard tbody td { padding: 1rem; vertical-align: middle; border: none; }
        .table-dashboard tbody td:first-child { border-top-left-radius: 8px; border-bottom-left-radius: 8px; }
        .table-dashboard tbody td:last-child { border-top-right-radius: 8px; border-bottom-right-radius: 8px; }

        .quick-link-card {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            text-decoration: none;
            color: #343a40;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            padding: 1.5rem;
        }
        .quick-link-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            color: var(--primary-accent);
        }
        .quick-link-card i {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            color: var(--primary-accent);
        }

        /* 활동 타임라인 스타일 */
        .timeline {
            position: relative;
            padding: 20px 0;
        }

        .timeline::before {
            content: '';
            position: absolute;
            left: 20px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #e9ecef;
        }

        .timeline-item {
            position: relative;
            padding-left: 60px;
            padding-bottom: 20px;
        }

        .timeline-icon {
            position: absolute;
            left: 10px;
            top: 0;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            z-index: 1;
        }

        .timeline-content {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            position: relative;
        }

        .timeline-time {
            color: #6c757d;
            font-size: 0.85rem;
            margin-top: 5px;
        }

        /* 여행 일정 카드 스타일 */
        .travel-schedule-card {
            border-left: 4px solid var(--primary-accent);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .travel-schedule-card:hover {
            transform: translateX(5px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .d-day {
            font-size: 1.5rem;
            font-weight: 700;
        }

        .d-day.urgent { color: #dc3545; }
        .d-day.soon { color: #ffc107; }
        .d-day.normal { color: #28a745; }

        .checklist-progress {
            height: 8px;
            background: #e9ecef;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 10px;
        }

        .checklist-progress-bar {
            height: 100%;
            background: linear-gradient(90deg, #56ab2f, #a8e063);
            transition: width 0.3s ease;
        }

        #calendar {
            max-width: 100%;
            margin: 0 auto;
        }

    </style>
</head>
<body>

<%@ include file="../common/header.jsp" %>

<c:if test="${empty sessionScope.loginUser}">
    <div class="d-flex justify-content-center align-items-center" style="height: calc(100vh - var(--header-height));">
        <div class="text-center">
            <h2>로그인이 필요합니다</h2>
            <p class="text-muted">마이페이지를 보려면 먼저 로그인해주세요.</p>
            <a href="${pageContext.request.contextPath}/member/login" class="btn btn-primary">로그인 페이지로 이동</a>
        </div>
    </div>
</c:if>

<c:if test="${not empty sessionScope.loginUser}">
    <div class="dashboard-wrapper">
        <!-- Sidebar -->
        <nav class="dashboard-sidebar">
            <div class="sidebar-header">
                <h3><i class="fas fa-user-circle"></i>My Page</h3>
            </div>
            <ul class="sidebar-nav">
                <li class="sidebar-nav-item" data-target="dashboard">
                    <a href="#"><i class="fas fa-tachometer-alt"></i> 대시보드</a>
                </li>

                <!-- 프로필 드롭다운 -->
                <li class="sidebar-nav-item dropdown">
                    <a href="#" class="dropdown-toggle">
                        <i class="fas fa-user"></i> 내 정보
                        <i class="fas fa-chevron-down dropdown-icon"></i>
                    </a>
                    <ul class="sidebar-submenu">
                        <li data-target="profile"><a href="#"><i class="fas fa-id-card"></i> 프로필</a></li>
                        <li data-target="my-badges"><a href="#"><i class="fas fa-award"></i> 나의 뱃지</a></li>
                        <li data-target="manner-evaluation"><a href="#"><i class="fas fa-star"></i> 매너 평가</a></li>
                    </ul>
                </li>

                <!-- 여행 관리 드롭다운 -->
                <li class="sidebar-nav-item dropdown">
                    <a href="#" class="dropdown-toggle">
                        <i class="fas fa-suitcase"></i> 여행 관리
                        <i class="fas fa-chevron-down dropdown-icon"></i>
                    </a>
                    <ul class="sidebar-submenu">
                        <li data-target="my-travels"><a href="#"><i class="fas fa-map-marked-alt"></i> 나의 여행</a></li>
                        <li data-target="travel-schedule"><a href="#"><i class="fas fa-calendar-alt"></i> 여행 일정</a></li>
                        <li data-target="my-requests"><a href="#"><i class="fas fa-paper-plane"></i> 보낸 신청</a></li>
                        <li data-target="my-received-requests"><a href="#"><i class="fas fa-user-check"></i> 받은 신청</a></li>
                    </ul>
                </li>

                <!-- 활동 기록 드롭다운 -->
                <li class="sidebar-nav-item dropdown">
                    <a href="#" class="dropdown-toggle">
                        <i class="fas fa-clock-rotate-left"></i> 활동 기록
                        <i class="fas fa-chevron-down dropdown-icon"></i>
                    </a>
                    <ul class="sidebar-submenu">
                        <li data-target="my-posts"><a href="#"><i class="fas fa-pencil-alt"></i> 작성한 글</a></li>
                        <li data-target="activity-timeline"><a href="#"><i class="fas fa-history"></i> 활동 타임라인</a></li>
                    </ul>
                </li>

                <!-- 저장 목록 드롭다운 -->
                <li class="sidebar-nav-item dropdown">
                    <a href="#" class="dropdown-toggle">
                        <i class="fas fa-bookmark"></i> 저장 목록
                        <i class="fas fa-chevron-down dropdown-icon"></i>
                    </a>
                    <ul class="sidebar-submenu">
                        <li><a href="${pageContext.request.contextPath}/member/favorites"><i class="fas fa-heart"></i> 전체 찜목록</a></li>
                        <li><a href="${pageContext.request.contextPath}/member/ai-saved"><i class="fas fa-robot"></i> AI 저장 목록</a></li>
                    </ul>
                </li>

                <!-- 쪽지함 -->
                <li class="sidebar-nav-item">
                    <a href="${pageContext.request.contextPath}/message/inbox"><i class="fas fa-envelope"></i> 쪽지함</a>
                </li>
            </ul>
        </nav>

        <!-- Mobile Sidebar Toggle -->
        <button class="sidebar-toggle" id="sidebar-toggle-btn">
            <i class="fas fa-bars"></i>
        </button>

        <!-- Main Content -->
        <main class="dashboard-content">
            <!-- Section: Dashboard -->
            <div id="dashboard" class="content-section">
                <div class="page-header">
                    <h1>대시보드</h1>
                    <p class="text-muted">환영합니다, ${sessionScope.loginUser.userName}님! 활동 내역을 요약해서 보여드립니다.</p>
                </div>

                <!-- Stat Cards -->
                <div class="row row-deck">
                    <div class="col-lg-2 col-md-4 mb-4">
                        <a href="#" class="stat-card-link" data-target="my-travels">
                            <div class="stat-card bg-stat-1">
                                <i class="fas fa-map-marked-alt"></i>
                                <h3>${travelPlanCount != null ? travelPlanCount : 0}</h3>
                                <p>등록한 여행</p>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-4">
                        <a href="#" class="stat-card-link" data-target="my-posts">
                            <div class="stat-card bg-stat-2">
                                <i class="fas fa-comments"></i>
                                <h3>${postCount != null ? postCount : 0}</h3>
                                <p>작성한 게시글</p>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-4">
                        <a href="#" class="stat-card-link" data-target="my-received-requests">
                            <div class="stat-card bg-stat-3">
                                <i class="fas fa-user-check"></i>
                                <h3>${receivedRequestCount != null ? receivedRequestCount : 0}</h3>
                                <p>받은 동행신청</p>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-4">
                        <a href="${pageContext.request.contextPath}/message/inbox" class="stat-card-link">
                            <div class="stat-card bg-stat-4">
                                <i class="fas fa-envelope"></i>
                                <h3>${unreadMessageCount != null ? unreadMessageCount : 0}</h3>
                                <p>안 읽은 쪽지</p>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-4">
                        <a href="${pageContext.request.contextPath}/member/favorites" class="stat-card-link">
                            <div class="stat-card bg-stat-5">
                                <i class="fas fa-heart"></i>
                                <h3>${favoriteCount != null ? favoriteCount : 0}</h3>
                                <p>전체 찜 목록</p>
                            </div>
                        </a>
                    </div>
                    <div class="col-lg-2 col-md-4 mb-4">
                        <a href="${pageContext.request.contextPath}/member/ai-saved" class="stat-card-link">
                            <div class="stat-card bg-stat-6">
                                <i class="fas fa-bookmark"></i>
                                <h3>${(savedPlaylistCount != null ? savedPlaylistCount : 0) + (savedAiPlanCount != null ? savedAiPlanCount : 0)}</h3>
                                <p>AI 저장 목록(개발중)</p>
                            </div>
                        </a>
                    </div>
                </div>

                <!-- 최근 활동 & 다가오는 여행 섹션 -->
                <div class="row mb-4">
                    <!-- 최근 활동 타임라인 -->
                    <div class="col-lg-6 mb-4">
                        <div class="dashboard-card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-history"></i>최근 활동</div>
                                <a href="#" class="btn btn-sm btn-outline-primary timeline-view-all">전체보기</a>
                            </div>
                            <div class="card-body">
                                <div class="timeline">
                                    <c:choose>
                                        <c:when test="${not empty recentActivities}">
                                            <c:forEach items="${recentActivities}" var="activity" begin="0" end="2">
                                                <div class="timeline-item">
                                                    <div class="timeline-icon" style="background: ${activity.color};">
                                                        <i class="fas ${activity.icon} text-white"></i>
                                                    </div>
                                                    <div class="timeline-content">
                                                        <strong>
                                                            <c:choose>
                                                                <c:when test="${activity.type == 'POST_CREATED'}">게시글 작성</c:when>
                                                                <c:when test="${activity.type == 'PLAN_CREATED'}">여행 계획 생성</c:when>
                                                                <c:when test="${activity.type == 'REQUEST_SENT'}">동행 신청</c:when>
                                                                <c:when test="${activity.type == 'REQUEST_RECEIVED'}">동행 신청 받음</c:when>
                                                                <c:when test="${activity.type == 'MBTI_TEST'}">MBTI 테스트</c:when>
                                                                <c:when test="${activity.type == 'FAVORITE_ADDED'}">찜하기</c:when>
                                                                <c:when test="${activity.type == 'COMMENT_CREATED'}">댓글 작성</c:when>
                                                                <c:otherwise>활동</c:otherwise>
                                                            </c:choose>
                                                        </strong>
                                                        <p class="mb-0 text-truncate">${activity.title}</p>
                                                        <div class="timeline-time">${activity.timeAgo}</div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="text-center py-4">
                                                <i class="fas fa-clock fa-3x text-muted mb-3"></i>
                                                <p class="text-muted">최근 활동이 없습니다</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 다가오는 여행 일정 -->
                    <div class="col-lg-6 mb-4">
                        <div class="dashboard-card">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-calendar-alt"></i>다가오는 여행</div>
                                <a href="#" class="btn btn-sm btn-outline-primary schedule-view-all">전체보기</a>
                            </div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty upcomingTravels}">
                                        <c:forEach items="${upcomingTravels}" var="plan" begin="0" end="2">
                                            <div class="travel-schedule-card p-3 mb-3 bg-light rounded">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div style="flex: 1;">
                                                        <h6 class="mb-1">
                                                            <i class="fas fa-map-marker-alt me-2"></i>
                                                            <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}"
                                                               class="text-decoration-none text-dark">
                                                                ${plan.planTitle}
                                                            </a>
                                                        </h6>
                                                        <small class="text-muted d-block">
                                                            <i class="fas fa-location-arrow me-1"></i>${plan.planDestination}
                                                        </small>
                                                        <small class="text-muted d-block">
                                                            <i class="fas fa-calendar me-1"></i>
                                                            <fmt:formatDate value="${plan.planStartDate}" pattern="yyyy년 MM월 dd일"/> -
                                                            <fmt:formatDate value="${plan.planEndDate}" pattern="yyyy년 MM월 dd일"/>
                                                        </small>
                                                        <c:choose>
                                                            <c:when test="${plan.planWriter eq sessionScope.loginUser.userId}">
                                                                <span class="badge bg-primary mt-1">내가 만든 여행</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-success mt-1">동행 참여 중</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="text-end">
                                                        <div class="d-day ${plan.daysUntil == 0 ? 'today' : plan.daysUntil <= 3 ? 'urgent' : plan.daysUntil <= 7 ? 'soon' : 'normal'}">
                                                            <c:choose>
                                                                <c:when test="${plan.daysUntil == 0}">
                                                                    <span class="text-danger fw-bold">오늘!</span>
                                                                </c:when>
                                                                <c:when test="${plan.daysUntil == 1}">
                                                                    <span class="text-warning fw-bold">내일!</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="fw-bold">D-${plan.daysUntil}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-4">
                                            <i class="fas fa-calendar-times fa-3x text-muted mb-3"></i>
                                            <p class="text-muted">예정된 여행이 없습니다</p>
                                            <a href="${pageContext.request.contextPath}/travel/create" class="btn btn-primary btn-sm">
                                                <i class="fas fa-plus me-2"></i>여행 계획 만들기
                                            </a>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Info and Quick Links Section -->
                <div class="row">
                    <div class="col-lg-4 col-md-12 mb-4">
                        <div class="dashboard-card">
                             <div class="card-header d-flex justify-content-between align-items-center">
                                <div><i class="fas fa-user-circle"></i>기본 정보</div>
                                <a href="${pageContext.request.contextPath}/member/edit" class="btn btn-sm btn-outline-primary"><i class="fas fa-edit me-1"></i>수정</a>
                            </div>
                            <div class="card-body">
                                <div class="profile-widget">
                                    <img src="<c:choose><c:when test='${sessionScope.loginUser.profileImage != null}'>/uploads/profile/${sessionScope.loginUser.profileImage}</c:when><c:otherwise>https://via.placeholder.com/80</c:otherwise></c:choose>"
                                         alt="프로필 사진" class="profile-widget-img">
                                    <div class="profile-widget-info">
                                        <h5>${sessionScope.loginUser.userName} (${sessionScope.loginUser.nickname != null ? sessionScope.loginUser.nickname : '미설정'})</h5>
                                        <p>${sessionScope.loginUser.userEmail}</p>
                                        <div class="mt-2">
                                            <span class="badge bg-light text-dark">🌡️ ${mannerStats.averageMannerScore}°C</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6 mb-4">
                        <div class="dashboard-card">
                            <a href="#" class="quick-link-card" data-target="manner-evaluation">
                                <i class="fas fa-star"></i>
                                <h5 class="card-title">내 매너 평가</h5>
                                <p class="card-text text-muted">다른 사용자로부터 받은 매너 평가를 확인합니다.</p>
                            </a>
                        </div>
                    </div>
                    <div class="col-lg-4 col-md-6 mb-4">
                        <div class="dashboard-card">
                            <a href="${pageContext.request.contextPath}/travel-mbti/history" class="quick-link-card">
                                <i class="fas fa-user-tag"></i>
                                <h5 class="card-title">여행 MBTI 기록</h5>
                                <p class="card-text text-muted">과거에 진행했던 MBTI 테스트 결과들을 봅니다.</p>
                            </a>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Section: Profile -->
            <div id="profile" class="content-section">
                 <div class="page-header"><h1>프로필</h1></div>
                <div class="row">
                    <div class="col-lg-6">
                        <div class="dashboard-card">
                            <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                                <span><i class="fas fa-id-card"></i>기본 정보</span>
                                <a href="${pageContext.request.contextPath}/member/edit" class="btn btn-sm btn-primary" style="background: linear-gradient(135deg, #a200ff 0%, #0026ff 100%); border: none; padding: 6px 15px; font-size: 0.875rem;">
                                    <i class="fas fa-edit"></i> 프로필 수정
                                </a>
                            </div>
                            <div class="card-body">
                                <table class="table table-borderless">
                                    <tr><th width="30%">아이디</th><td>${member.userId}</td></tr>
                                    <tr><th>이름</th><td>${member.userName}</td></tr>
                                    <tr><th>닉네임</th><td>${member.nickname != null ? member.nickname : '미설정'}</td></tr>
                                    <tr><th>이메일</th><td>${member.userEmail}</td></tr>
                                    <tr><th>가입일</th><td><fmt:formatDate value="${member.userRegdate}" pattern="yyyy년 MM월 dd일"/></td></tr>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="dashboard-card">
                            <div class="card-header"><i class="fas fa-user-tag"></i>여행 MBTI</div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty userMbti}">
                                        <div class="text-center">
                                            <span class="badge bg-primary fs-4 px-4 py-3">${userMbti.mbtiType}</span>
                                            <h5 class="fw-bold my-3 text-primary">${mbtiTypeName}</h5>
                                            <a href="${pageContext.request.contextPath}/travel-mbti/result/${userMbti.mbtiType}" class="btn btn-sm btn-outline-success me-2"><i class="fas fa-eye me-1"></i>상세 보기</a>
                                            <a href="${pageContext.request.contextPath}/travel-mbti/test" class="btn btn-sm btn-outline-primary"><i class="fas fa-redo me-1"></i>다시 테스트</a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-3">
                                            <p class="text-muted">아직 여행 MBTI 테스트를 하지 않으셨습니다.</p>
                                            <a href="${pageContext.request.contextPath}/travel-mbti/test" class="btn btn-success">테스트 시작하기</a>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- 자기소개 섹션 추가 -->
                <div class="row mt-4">
                    <div class="col-lg-12">
                        <div class="dashboard-card">
                            <div class="card-header"><i class="fas fa-edit"></i>자기소개</div>
                            <div class="card-body">
                                <form id="bioForm">
                                    <div class="mb-3">
                                        <label for="bioTextarea" class="form-label">
                                            <i class="fas fa-comment-dots me-1"></i>나를 소개해주세요 (최대 500자)
                                        </label>
                                        <textarea class="form-control" id="bioTextarea" rows="4" maxlength="500"
                                                  placeholder="여행 스타일, 관심사, 성격 등을 자유롭게 작성해주세요.">${member.bio != null ? member.bio : ''}</textarea>
                                        <div class="form-text text-end">
                                            <span id="charCount">0</span>/500
                                        </div>
                                    </div>
                                    <div class="text-center">
                                        <button type="button" class="btn btn-primary" onclick="updateBio()">
                                            <i class="fas fa-save me-2"></i>자기소개 저장
                                        </button>
                                    </div>
                                </form>
                                <c:if test="${not empty member.bio}">
                                    <hr class="my-3">
                                    <div class="alert alert-info">
                                        <i class="fas fa-info-circle me-2"></i>
                                        현재 자기소개가 프로필 페이지에 표시되고 있습니다.
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section: My Travels -->
            <div id="my-travels" class="content-section">
                <div class="page-header"><h1>나의 여행</h1></div>
                <div class="dashboard-card">
                    <div class="card-header"><i class="fas fa-map-marked-alt"></i>내가 작성한 여행 계획</div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty myTravelPlans}"><p class="text-center text-muted">작성한 여행 계획이 없습니다.</p></c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-dashboard">
                                        <thead><tr><th>여행 제목</th><th>목적지</th><th>기간</th><th>관리</th></tr></thead>
                                        <tbody>
                                            <c:forEach var="plan" items="${myTravelPlans}">
                                                <tr>
                                                    <td><strong>${plan.planTitle}</strong></td>
                                                    <td><span class="badge bg-primary">${plan.planDestination}</span></td>
                                                    <td><small><fmt:formatDate value="${plan.planStartDate}" pattern="yy.MM.dd"/> ~ <fmt:formatDate value="${plan.planEndDate}" pattern="yy.MM.dd"/></small></td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}" class="btn btn-sm btn-outline-primary">보기</a>
                                                        <a href="${pageContext.request.contextPath}/travel/edit/${plan.planId}" class="btn btn-sm btn-outline-warning">수정</a>
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

                <!-- 참여중인 여행 계획 섹션 -->
                <div class="dashboard-card mt-4">
                    <div class="card-header"><i class="fas fa-users"></i>참여중인 여행 계획</div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty joinedTravels}"><p class="text-center text-muted">참여중인 여행 계획이 없습니다.</p></c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-dashboard">
                                        <thead><tr><th>여행 제목</th><th>목적지</th><th>기간</th><th>작성자</th><th>참여일</th><th>상세</th></tr></thead>
                                        <tbody>
                                            <c:forEach var="travel" items="${joinedTravels}">
                                                <tr>
                                                    <td><strong>${travel.travelTitle}</strong></td>
                                                    <td><span class="badge bg-success">${travel.destination}</span></td>
                                                    <td><small><fmt:formatDate value="${travel.startDate}" pattern="yy.MM.dd"/> ~ <fmt:formatDate value="${travel.endDate}" pattern="yy.MM.dd"/></small></td>
                                                    <td><small>${travel.planWriterName}</small></td>
                                                    <td><small><fmt:formatDate value="${travel.joinedDate}" pattern="yy.MM.dd"/></small></td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/travel/detail/${travel.travelId}" class="btn btn-sm btn-outline-primary">보기</a>
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
            </div>

            <!-- Section: My Posts -->
            <div id="my-posts" class="content-section">
                <div class="page-header"><h1>작성한 글</h1></div>
                 <div class="dashboard-card">
                    <div class="card-header"><i class="fas fa-comments"></i>내가 작성한 커뮤니티 글</div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty myPosts}"><p class="text-center text-muted">작성한 게시글이 없습니다.</p></c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-dashboard">
                                        <thead><tr><th>제목</th><th>작성일</th><th>관리</th></tr></thead>
                                        <tbody>
                                            <c:forEach var="post" items="${myPosts}">
                                                <tr>
                                                    <td><strong>${post.boardTitle}</strong></td>
                                                    <td><small><fmt:formatDate value="${post.boardRegdate}" pattern="yyyy.MM.dd HH:mm"/></small></td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/board/detail/${post.boardId}" class="btn btn-sm btn-outline-primary">보기</a>
                                                        <a href="${pageContext.request.contextPath}/board/edit/${post.boardId}" class="btn btn-sm btn-outline-warning">수정</a>
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
            </div>

            <!-- Section: My Sent Requests -->
            <div id="my-requests" class="content-section">
                <div class="page-header"><h1>보낸 신청</h1></div>
                <div class="dashboard-card">
                    <div class="card-header"><i class="fas fa-paper-plane"></i>내가 동행 신청한 여행</div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${empty mySentRequests}"><p class="text-center text-muted">동행 신청한 여행이 없습니다.</p></c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table table-dashboard">
                                        <thead><tr><th>여행 제목</th><th>상태</th><th>관리</th></tr></thead>
                                        <tbody>
                                            <c:forEach var="request" items="${mySentRequests}">
                                                <tr>
                                                    <td><strong>${request.travelPlanTitle}</strong></td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${request.status == 'PENDING'}"><span class="badge bg-warning">대기중</span></c:when>
                                                            <c:when test="${request.status == 'APPROVED'}"><span class="badge bg-success">승인됨</span></c:when>
                                                            <c:when test="${request.status == 'REJECTED'}"><span class="badge bg-danger">거절됨</span></c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/travel/detail/${request.travelPlanId}" class="btn btn-sm btn-outline-primary me-1" title="상세보기"><i class="fas fa-eye"></i></a>
                                                        <c:if test="${request.status == 'PENDING'}">
                                                            <button class="btn btn-sm btn-outline-danger" onclick="cancelRequest(${request.requestId})" title="신청 취소"><i class="fas fa-times"></i></button>
                                                        </c:if>
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
            </div>

            <!-- Section: My Received Requests -->
            <div id="my-received-requests" class="content-section">
                <div class="page-header"><h1>받은 동행 신청</h1></div>
                <div id="received-requests-container">
                    <div class="text-center">
                        <i class="fas fa-spinner fa-spin fa-2x text-muted mb-3"></i>
                        <p>로딩 중...</p>
                    </div>
                </div>
            </div>

            <!-- Section: My Badges -->
            <div id="my-badges" class="content-section">
                <div class="page-header"><h1>나의 뱃지</h1></div>
                <div class="row">
                    <div class="col-lg-6">
                        <div class="dashboard-card">
                            <div class="card-header"><i class="fas fa-award"></i>보유 뱃지</div>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${not empty badges}">
                                        <div class="d-flex flex-wrap gap-2">
                                            <c:forEach var="badge" items="${badges}">
                                                <span class="badge bg-secondary p-2">${badge.badgeName}</span>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise><p class="text-muted">획득한 뱃지가 없습니다.</p></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="dashboard-card">
                            <div class="card-header"><i class="fas fa-chart-line"></i>뱃지 진행도</div>
                            <div class="card-body">
                                <p class="text-muted">뱃지 진행도 정보가 여기에 표시됩니다.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section: Manner Evaluation -->
            <div id="manner-evaluation" class="content-section">
                <div class="page-header">
                    <h1><i class="fas fa-star me-2"></i>내 매너 평가</h1>
                    <p class="text-muted">나의 여행 매너 점수와 동행자들의 평가를 확인하세요</p>
                </div>

                <!-- 매너온도 대시보드 -->
                <div class="row mb-4">
                    <!-- 매너온도 메인 표시 -->
                    <div class="col-md-5">
                        <div class="dashboard-card">
                            <div class="card-body text-center">
                                <h4 class="mb-3">매너온도</h4>
                                <div class="manner-temperature-display">
                                    <div class="temperature-main" id="manner-temp-value" style="font-size: 3rem; font-weight: bold; color: #fbbf24;">
                                        <i class="fas fa-spinner fa-spin"></i>
                                    </div>
                                    <div class="temperature-level mt-2" id="manner-temp-level" style="font-size: 1.2rem;">
                                        로딩중...
                                    </div>
                                </div>

                                <!-- 온도 게이지 -->
                                <div class="temperature-gauge mt-4">
                                    <div class="progress" style="height: 10px;">
                                        <div id="manner-temp-bar" class="progress-bar" role="progressbar" style="background: linear-gradient(90deg, #fbbf24, #f59e0b);">
                                        </div>
                                    </div>
                                    <div class="d-flex justify-content-between mt-2" style="font-size: 0.8rem; color: #9ca3af;">
                                        <span>20°C</span>
                                        <span>40°C</span>
                                        <span>60°C</span>
                                        <span>80°C</span>
                                        <span>100°C</span>
                                    </div>
                                </div>

                                <div class="badge bg-primary mt-3" id="manner-badge-level" style="font-size: 1rem; padding: 0.5rem 1rem;">
                                    로딩중...
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 평가 통계 -->
                    <div class="col-md-7">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <i class="fas fa-chart-bar"></i> 평가 현황
                            </div>
                            <div class="card-body">
                                <div class="row text-center">
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="stat-icon" style="font-size: 1.5rem;">📊</div>
                                        <div class="stat-number" id="total-evaluations" style="font-size: 1.8rem; font-weight: bold;">0</div>
                                        <small class="text-muted">총 평가</small>
                                    </div>
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="stat-icon" style="font-size: 1.5rem;">✈️</div>
                                        <div class="stat-number" id="completed-travels" style="font-size: 1.8rem; font-weight: bold;">0</div>
                                        <small class="text-muted">완료 여행</small>
                                    </div>
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="stat-icon" style="font-size: 1.5rem;">👍</div>
                                        <div class="stat-number text-success" id="total-likes" style="font-size: 1.8rem; font-weight: bold;">0</div>
                                        <small class="text-muted">긍정 평가</small>
                                    </div>
                                    <div class="col-6 col-md-3 mb-3">
                                        <div class="stat-icon" style="font-size: 1.5rem;">👎</div>
                                        <div class="stat-number text-warning" id="total-dislikes" style="font-size: 1.8rem; font-weight: bold;">0</div>
                                        <small class="text-muted">부정 평가</small>
                                    </div>
                                </div>

                                <!-- 긍정 평가 비율 바 -->
                                <div class="evaluation-ratio mt-3">
                                    <div class="d-flex justify-content-between mb-2">
                                        <span>긍정 평가 비율</span>
                                        <span class="font-weight-bold" id="like-ratio">0%</span>
                                    </div>
                                    <div class="progress" style="height: 8px;">
                                        <div id="like-ratio-bar" class="progress-bar bg-success" role="progressbar" style="width: 0%">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 평가 목록 -->
                <div class="row">
                    <!-- 받은 평가 -->
                    <div class="col-lg-6">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <i class="fas fa-inbox me-2"></i>받은 평가
                                <span class="badge bg-primary" id="received-count">0</span>
                            </div>
                            <div class="card-body" style="max-height: 400px; overflow-y: auto;" id="received-evaluations">
                                <div class="text-center py-4">
                                    <i class="fas fa-spinner fa-spin fa-2x text-muted"></i>
                                    <p class="text-muted mt-2">로딩중...</p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 내가 한 평가 -->
                    <div class="col-lg-6">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <i class="fas fa-paper-plane me-2"></i>내가 한 평가
                                <span class="badge bg-secondary" id="given-count">0</span>
                            </div>
                            <div class="card-body" style="max-height: 400px; overflow-y: auto;" id="given-evaluations">
                                <div class="text-center py-4">
                                    <i class="fas fa-spinner fa-spin fa-2x text-muted"></i>
                                    <p class="text-muted mt-2">로딩중...</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 상세보기 링크 -->
                <div class="text-center mt-4">
                    <a href="#" class="btn btn-primary manner-evaluation-link" data-target="manner-evaluation">
                        <i class="fas fa-external-link-alt me-2"></i>전체 매너 평가 보기
                    </a>
                </div>
            </div>

            <!-- Section: Activity Timeline (Full) -->
            <div id="activity-timeline" class="content-section">
                <div class="page-header">
                    <h1>활동 타임라인</h1>
                    <p class="text-muted">모든 활동 내역을 시간순으로 확인합니다.</p>
                </div>

                <div class="dashboard-card">
                    <div class="card-header">
                        <i class="fas fa-history"></i>전체 활동 내역
                    </div>
                    <div class="card-body">
                        <div class="timeline">
                            <c:choose>
                                <c:when test="${not empty activityTimeline}">
                                    <c:forEach items="${activityTimeline}" var="activity">
                                        <div class="timeline-item">
                                            <div class="timeline-icon" style="background: ${activity.color};">
                                                <i class="fas ${activity.icon} text-white"></i>
                                            </div>
                                            <div class="timeline-content">
                                                <strong>
                                                    <c:choose>
                                                        <c:when test="${activity.type == 'POST_CREATED'}">게시글 작성</c:when>
                                                        <c:when test="${activity.type == 'PLAN_CREATED'}">여행 계획 생성</c:when>
                                                        <c:when test="${activity.type == 'REQUEST_SENT'}">동행 신청</c:when>
                                                        <c:when test="${activity.type == 'REQUEST_RECEIVED'}">동행 신청 받음</c:when>
                                                        <c:when test="${activity.type == 'MBTI_TEST'}">MBTI 테스트</c:when>
                                                        <c:when test="${activity.type == 'FAVORITE_ADDED'}">찜하기</c:when>
                                                        <c:when test="${activity.type == 'COMMENT_CREATED'}">댓글 작성</c:when>
                                                        <c:otherwise>활동</c:otherwise>
                                                    </c:choose>
                                                </strong>
                                                <p class="mb-0">${activity.title}</p>
                                                <div class="timeline-time">${activity.timeAgo}</div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="text-center py-4">
                                        <i class="fas fa-clock fa-3x text-muted mb-3"></i>
                                        <p class="text-muted">활동 내역이 없습니다</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Section: Travel Schedule (Calendar) -->
            <div id="travel-schedule" class="content-section">
                <div class="page-header">
                    <h1>여행 일정</h1>
                    <p class="text-muted">캘린더로 여행 일정을 관리하고 체크리스트를 확인합니다.</p>
                </div>

                <div class="row">
                    <div class="col-lg-8 mb-4">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <i class="fas fa-calendar"></i>여행 캘린더
                            </div>
                            <div class="card-body">
                                <div id="calendar"></div>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4 mb-4">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <i class="fas fa-tasks"></i>체크리스트
                            </div>
                            <div class="card-body">
                                <div id="checklist-container">
                                    <c:choose>
                                        <c:when test="${not empty upcomingTravels}">
                                            <p class="text-muted">캘린더에서 여행을 클릭하면 체크리스트가 표시됩니다.</p>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="text-muted">예정된 여행이 없습니다.</p>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- FullCalendar JS -->
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/locales/ko.js'></script>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const navItems = document.querySelectorAll('.sidebar-nav-item');
            const contentSections = document.querySelectorAll('.content-section');
            const sidebar = document.querySelector('.dashboard-sidebar');
            const sidebarToggle = document.getElementById('sidebar-toggle-btn');
            const statCardLinks = document.querySelectorAll('.stat-card-link[data-target]');

            // 드롭다운 메뉴 기능
            const dropdownToggles = document.querySelectorAll('.sidebar-nav-item.dropdown > a');

            dropdownToggles.forEach(toggle => {
                toggle.addEventListener('click', function(e) {
                    e.preventDefault();
                    const parentItem = this.parentElement;

                    // 다른 드롭다운 닫기
                    document.querySelectorAll('.sidebar-nav-item.dropdown').forEach(item => {
                        if (item !== parentItem) {
                            item.classList.remove('expanded');
                        }
                    });

                    // 현재 드롭다운 토글
                    parentItem.classList.toggle('expanded');
                });
            });

            // 서브메뉴 클릭 이벤트
            const submenuItems = document.querySelectorAll('.sidebar-submenu li[data-target]');
            submenuItems.forEach(item => {
                item.addEventListener('click', function(e) {
                    e.preventDefault();
                    const targetId = this.dataset.target;

                    // 모든 서브메뉴 아이템에서 active 클래스 제거
                    document.querySelectorAll('.sidebar-submenu li').forEach(li => {
                        li.classList.remove('active');
                    });

                    // 현재 아이템에 active 클래스 추가
                    this.classList.add('active');

                    // 탭 전환
                    switchTab(targetId);
                });
            });

            // 자기소개 문자 수 카운트
            const bioTextarea = document.getElementById('bioTextarea');
            const charCount = document.getElementById('charCount');

            if (bioTextarea && charCount) {
                // 초기 문자 수 표시
                charCount.textContent = bioTextarea.value.length;

                // 입력할 때마다 문자 수 업데이트
                bioTextarea.addEventListener('input', function() {
                    charCount.textContent = this.value.length;
                });
            }

            function switchTab(targetId) {
                navItems.forEach(item => {
                    item.classList.toggle('active', item.dataset.target === targetId);
                });

                if (targetId === 'dashboard') {
                    contentSections.forEach(section => section.classList.add('active'));
                } else {
                    contentSections.forEach(section => {
                        section.classList.toggle('active', section.id === targetId);
                    });

                    // 매너 평가 섹션이 선택되면 데이터 로드
                    if (targetId === 'manner-evaluation') {
                        loadMannerEvaluationData();
                    }

                    // 받은 동행 신청 섹션이 선택되면 데이터 로드
                    if (targetId === 'my-received-requests') {
                        loadReceivedRequests();
                    }
                }
            }

            switchTab('dashboard');

            navItems.forEach(item => {
                if (item.dataset.target) {
                    item.addEventListener('click', function(e) {
                        e.preventDefault();
                        switchTab(this.dataset.target);
                        if (window.innerWidth <= 992) { sidebar.classList.remove('show'); }
                    });
                }
            });

            statCardLinks.forEach(card => {
                card.addEventListener('click', function(e) {
                    e.preventDefault();
                    switchTab(this.dataset.target);
                });
            });

            sidebarToggle.addEventListener('click', () => sidebar.classList.toggle('show'));

            // 매너 평가 보기 링크 이벤트 리스너
            const mannerEvaluationLinks = document.querySelectorAll('.manner-evaluation-link');
            mannerEvaluationLinks.forEach(link => {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    switchTab('manner-evaluation');
                });
            });

            // Quick Link Card 이벤트 리스너 (대시보드의 카드들)
            const quickLinkCards = document.querySelectorAll('.quick-link-card[data-target]');
            quickLinkCards.forEach(card => {
                card.addEventListener('click', function(e) {
                    e.preventDefault();
                    const targetId = this.dataset.target;
                    switchTab(targetId);
                });
            });

            const profileImageInput = document.getElementById('profileImageInput');
            if(profileImageInput) {
                profileImageInput.addEventListener('change', function(event) {
                    const file = event.target.files[0];
                    if (file) {
                        if (file.size > 5 * 1024 * 1024) { alert('파일 크기는 5MB 이하여야 합니다.'); return; }
                        if (!file.type.startsWith('image/')) { alert('이미지 파일만 업로드 가능합니다.'); return; }

                        const formData = new FormData();
                        formData.append('profileImage', file);

                        fetch('${pageContext.request.contextPath}/member/upload-profile-image', { method: 'POST', body: formData })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                alert('프로필 이미지가 성공적으로 업데이트되었습니다.');
                                const newImageUrl = '/uploads/profile/' + data.fileName + '?t=' + new Date().getTime();
                                document.querySelectorAll('.profile-widget-img').forEach(img => img.src = newImageUrl);
                            } else {
                                alert('업로드 실패: ' + data.message);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            alert('업로드 중 오류가 발생했습니다.');
                        });
                    }
                });
            }
            // 타임라인 및 일정 전체보기 버튼 이벤트 핸들러
            document.querySelector('.timeline-view-all')?.addEventListener('click', function(e) {
                e.preventDefault();
                switchTab('activity-timeline');
            });

            document.querySelector('.schedule-view-all')?.addEventListener('click', function(e) {
                e.preventDefault();
                switchTab('travel-schedule');
            });

            // 다양한 색상 배열 정의
            var travelColors = [
                '#FF6B6B', // 빨간색
                '#4ECDC4', // 청록색
                '#45B7D1', // 하늘색
                '#FFA07A', // 연어색
                '#98D8C8', // 민트색
                '#FFB347', // 주황색
                '#B19CD9', // 보라색
                '#87CEEB', // 스카이블루
                '#F06292', // 핑크색
                '#AED581', // 라임색
                '#FFD54F', // 노란색
                '#9575CD', // 딥퍼플
                '#4DB6AC', // 틸색
                '#FF8A65', // 딥오렌지
                '#81C784'  // 그린
            ];

            // FullCalendar 초기화 (여행 일정 탭)
            var calendarEl = document.getElementById('calendar');
            if (calendarEl) {
                var calendar = new FullCalendar.Calendar(calendarEl, {
                    locale: 'ko',
                    initialView: 'dayGridMonth',
                    headerToolbar: {
                        left: 'prev,next today',
                        center: 'title',
                        right: 'dayGridMonth,listWeek'
                    },
                    events: [
                        <c:forEach items="${myTravelPlans}" var="plan" varStatus="status">
                        {
                            id: '${plan.planId}',
                            title: '${plan.planTitle}',
                            start: '<fmt:formatDate value="${plan.planStartDate}" pattern="yyyy-MM-dd"/>',
                            end: '<fmt:formatDate value="${plan.planEndDate}" pattern="yyyy-MM-dd"/>',
                            backgroundColor: travelColors[${status.index} % travelColors.length],
                            borderColor: travelColors[${status.index} % travelColors.length],
                            textColor: '#FFFFFF',
                            extendedProps: {
                                destination: '${plan.planDestination}',
                                status: '${plan.planStatus}',
                                budget: '${plan.planBudget}',
                                isParticipating: false
                            }
                        }<c:if test="${!status.last || not empty participatingTravels}">,</c:if>
                        </c:forEach>
                        <c:forEach items="${participatingTravels}" var="plan" varStatus="status">
                        {
                            id: '${plan.planId}',
                            title: '🤝 ${plan.planTitle}',
                            start: '<fmt:formatDate value="${plan.planStartDate}" pattern="yyyy-MM-dd"/>',
                            end: '<fmt:formatDate value="${plan.planEndDate}" pattern="yyyy-MM-dd"/>',
                            backgroundColor: '#9C27B0',
                            borderColor: '#7B1FA2',
                            textColor: '#FFFFFF',
                            extendedProps: {
                                destination: '${plan.planDestination}',
                                status: '${plan.planStatus}',
                                budget: '${plan.planBudget}',
                                isParticipating: true
                            }
                        }<c:if test="${!status.last}">,</c:if>
                        </c:forEach>
                    ],
                    eventClick: function(info) {
                        // 이벤트 클릭 시 체크리스트 표시
                        var event = info.event;
                        var planId = event.id;

                        // 체크리스트 컨테이너 업데이트
                        var checklistContainer = document.getElementById('checklist-container');
                        checklistContainer.innerHTML =
                            '<div class="text-center py-2">' +
                                '<div class="spinner-border spinner-border-sm" role="status">' +
                                    '<span class="visually-hidden">로딩 중...</span>' +
                                '</div>' +
                                '<p class="mt-2">체크리스트를 불러오는 중...</p>' +
                            '</div>';

                        // 선택된 여행 정보 표시
                        var planInfoHtml =
                            '<div class="selected-plan-info mb-3 p-2 bg-light rounded">' +
                                '<h6 class="mb-1">' + event.title + '</h6>' +
                                '<small class="text-muted">' +
                                    '<i class="fas fa-map-marker-alt"></i> ' + event.extendedProps.destination +
                                '</small>' +
                            '</div>';
                        checklistContainer.innerHTML = planInfoHtml + checklistContainer.innerHTML;

                        // 체크리스트 로드
                        loadChecklistForPlan(planId);

                        return; // 아래 기존 코드는 실행하지 않음

                        // AJAX로 체크리스트 데이터 가져오기
                        fetch('${pageContext.request.contextPath}/travel/checklist/' + planId)
                            .then(response => response.json())
                            .then(data => {
                                if (data.success && data.checklist && data.checklist.length > 0) {
                                    var checklistHtml =
                                        '<div class="checklist-header mb-3">' +
                                            '<h6 class="mb-2">' + event.title + '</h6>' +
                                            '<div class="progress mb-2">' +
                                                '<div class="progress-bar bg-success" style="width: ' + data.completionRate + '%">' +
                                                    Math.round(data.completionRate) + '%' +
                                                '</div>' +
                                            '</div>' +
                                        '</div>' +
                                        '<div class="checklist-items">';

                                    data.checklist.forEach(function(item) {
                                        checklistHtml +=
                                            '<div class="checklist-item-wrapper d-flex align-items-center mb-2" data-item-id="' + item.checklistId + '">' +
                                                '<div class="form-check flex-grow-1">' +
                                                    '<input class="form-check-input checklist-item"' +
                                                           ' type="checkbox"' +
                                                           ' id="checklist-' + item.checklistId + '"' +
                                                           ' value="' + item.checklistId + '"' +
                                                           ' data-plan-id="' + planId + '"' +
                                                           (item.completed ? ' checked' : '') +
                                                           ' onchange="toggleChecklistItem(this)">' +
                                                    '<label class="form-check-label ' + (item.completed ? 'text-decoration-line-through text-muted' : '') + '"' +
                                                           ' for="checklist-' + item.checklistId + '">' +
                                                        item.itemName +
                                                    '</label>' +
                                                '</div>' +
                                                '<button class="btn btn-sm btn-link text-danger p-1"' +
                                                        ' onclick="deleteChecklistItem(' + item.checklistId + ', ' + planId + ')"' +
                                                        ' title="삭제">' +
                                                    '<i class="fas fa-trash-alt"></i>' +
                                                '</button>' +
                                            '</div>';
                                    });

                                    checklistHtml +=
                                        '</div>' +
                                        '<div class="mt-3 d-flex gap-2">' +
                                            '<button class="btn btn-sm btn-outline-primary flex-fill"' +
                                                    ' onclick="addChecklistItem(' + planId + ')">' +
                                                '<i class="fas fa-plus"></i> 항목 추가' +
                                            '</button>' +
                                            '<a href="${pageContext.request.contextPath}/travel/detail/' + planId + '"' +
                                               ' class="btn btn-sm btn-primary flex-fill">' +
                                                '<i class="fas fa-external-link-alt"></i> 상세보기' +
                                            '</a>' +
                                        '</div>';

                                    checklistContainer.innerHTML = checklistHtml;
                                } else {
                                    checklistContainer.innerHTML =
                                        '<p class="text-muted">체크리스트가 없습니다.</p>' +
                                        '<div class="mt-3">' +
                                            '<button class="btn btn-sm btn-outline-primary w-100"' +
                                                    ' onclick="addChecklistItem(' + planId + ')">' +
                                                '<i class="fas fa-plus"></i> 첫 항목 추가' +
                                            '</button>' +
                                            '<a href="${pageContext.request.contextPath}/travel/detail/' + planId + '"' +
                                               ' class="btn btn-sm btn-primary w-100 mt-2">' +
                                                '<i class="fas fa-external-link-alt"></i> 상세보기' +
                                            '</a>' +
                                        '</div>';
                                }
                            })
                            .catch(error => {
                                console.error('Error loading checklist:', error);
                                checklistContainer.innerHTML =
                                    '<p class="text-danger">체크리스트를 불러오는데 실패했습니다.</p>' +
                                    '<a href="${pageContext.request.contextPath}/travel/detail/' + planId + '"' +
                                       ' class="btn btn-sm btn-primary w-100 mt-2">' +
                                        '<i class="fas fa-external-link-alt"></i> 상세보기' +
                                    '</a>';
                            });
                    },
                    eventMouseEnter: function(info) {
                        // 호버 시 툴팁 표시
                        info.el.setAttribute('title', info.event.title + ' - ' + info.event.extendedProps.destination);
                    }
                });

                // 캘린더 렌더링
                calendar.render();
            }
        });

        // 매너 평가 데이터 로드
        function loadMannerEvaluationData() {
            const userId = '${sessionScope.loginUser.userId}';
            console.log('Loading manner evaluation data for user:', userId);

            if (!userId) {
                console.error('User ID is not available');
                showErrorState();
                return;
            }

            const apiUrl = '${pageContext.request.contextPath}/manner/api/evaluations/' + userId;
            console.log('API URL:', apiUrl);

            // 매너 평가 데이터 가져오기
            fetch(apiUrl)
                .then(response => {
                    console.log('Response status:', response.status);
                    return response.json();
                })
                .then(data => {
                    console.log('Received data:', data);
                    if (data.success && data.mannerStats) {
                        // 매너 통계 업데이트
                        const stats = data.mannerStats;

                        // 온도 값 업데이트 (null 체크 추가)
                        const tempValue = stats.averageMannerScore || 36.5;
                        document.getElementById('manner-temp-value').innerHTML = tempValue.toFixed(1) + '°C';

                        // 온도 레벨과 뱃지 레벨 계산
                        const temperatureLevel = getTemperatureLevel(tempValue);
                        const badgeLevel = getBadgeLevel(stats.completedTravels || 0, tempValue);

                        document.getElementById('manner-temp-level').textContent = temperatureLevel;
                        document.getElementById('manner-badge-level').textContent = badgeLevel;

                        // 온도 바 업데이트
                        const tempBar = document.getElementById('manner-temp-bar');
                        const tempPercentage = Math.min(100, Math.max(0, (tempValue - 30) * 10)); // 30°C~40°C를 0~100%로 매핑
                        tempBar.style.width = tempPercentage + '%';
                        tempBar.style.backgroundColor = getTemperatureColor(tempValue);

                        // 통계 업데이트
                        document.getElementById('total-evaluations').textContent = stats.totalEvaluations || 0;
                        document.getElementById('completed-travels').textContent = stats.completedTravels || 0;
                        document.getElementById('total-likes').textContent = stats.totalLikes || 0;
                        document.getElementById('total-dislikes').textContent = stats.totalDislikes || 0;

                        // 좋아요 비율 계산
                        const likeRatio = calculateLikeRatio(stats.totalLikes || 0, stats.totalDislikes || 0);
                        document.getElementById('like-ratio').textContent = likeRatio.toFixed(1) + '%';

                        // 좋아요 비율 바 업데이트
                        document.getElementById('like-ratio-bar').style.width = likeRatio + '%';

                        // 받은 평가 목록 업데이트
                        const receivedContainer = document.getElementById('received-evaluations');
                        document.getElementById('received-count').textContent = data.receivedEvaluations.length;

                        if (data.receivedEvaluations.length > 0) {
                            let receivedHtml = '';
                            data.receivedEvaluations.forEach(eval => {
                                receivedHtml += createEvaluationItem(eval, 'received');
                            });
                            receivedContainer.innerHTML = receivedHtml;
                        } else {
                            receivedContainer.innerHTML = '<p class="text-center text-muted">아직 받은 평가가 없습니다.</p>';
                        }

                        // 내가 한 평가 목록 업데이트
                        const givenContainer = document.getElementById('given-evaluations');
                        document.getElementById('given-count').textContent = data.givenEvaluations.length;

                        if (data.givenEvaluations.length > 0) {
                            let givenHtml = '';
                            data.givenEvaluations.forEach(eval => {
                                givenHtml += createEvaluationItem(eval, 'given');
                            });
                            givenContainer.innerHTML = givenHtml;
                        } else {
                            givenContainer.innerHTML = '<p class="text-center text-muted">아직 한 평가가 없습니다.</p>';
                        }
                    } else {
                        console.error('Data success is false or mannerStats is missing:', data);
                        showErrorState();
                    }
                })
                .catch(error => {
                    console.error('Error loading manner evaluations:', error);
                    showErrorState();
                });
        }

        // 오류 상태 표시 함수
        function showErrorState() {
            // 기본값 설정
            document.getElementById('manner-temp-value').innerHTML = '36.5°C';
            document.getElementById('manner-temp-level').textContent = '평범한 동행자';
            document.getElementById('manner-badge-level').textContent = '🌱 새싹';
            document.getElementById('total-evaluations').textContent = '0';
            document.getElementById('completed-travels').textContent = '0';
            document.getElementById('total-likes').textContent = '0';
            document.getElementById('total-dislikes').textContent = '0';
            document.getElementById('like-ratio').textContent = '0%';

            // 오류 메시지 표시
            document.getElementById('received-evaluations').innerHTML =
                '<p class="text-center text-danger">데이터를 불러오는데 실패했습니다.</p>';
            document.getElementById('given-evaluations').innerHTML =
                '<p class="text-center text-danger">데이터를 불러오는데 실패했습니다.</p>';
        }

        // 헬퍼 함수들 추가
        function getTemperatureLevel(score) {
            if (score >= 40.0) return "정말 좋은 동행자";
            else if (score >= 37.0) return "좋은 동행자";
            else if (score >= 35.0) return "평범한 동행자";
            else if (score >= 32.0) return "아쉬운 동행자";
            else return "매너가 필요한 동행자";
        }

        function getTemperatureColor(score) {
            if (score >= 40.0) return "#ff4444";      // 빨간색
            else if (score >= 37.0) return "#ff8800"; // 주황색
            else if (score >= 35.0) return "#ffcc00"; // 노란색
            else if (score >= 32.0) return "#4488ff"; // 파란색
            else return "#8844ff";                     // 보라색
        }

        function getBadgeLevel(completedTravels, score) {
            if (completedTravels >= 50 && score >= 39.0) return "🥇 골드";
            else if (completedTravels >= 20 && score >= 37.5) return "🥈 실버";
            else if (completedTravels >= 5 && score >= 36.0) return "🥉 브론즈";
            else return "🌱 새싹";
        }

        function calculateLikeRatio(likes, dislikes) {
            const total = likes + dislikes;
            return total > 0 ? (likes / total * 100) : 0.0;
        }

        // 평가 아이템 HTML 생성
        function createEvaluationItem(eval, type) {
            const date = new Date(eval.createdDate).toLocaleDateString('ko-KR');
            const userName = type === 'received' ? '익명의 동행자' : eval.evaluatedUserName || '익명의 동행자';

            return '<div class="border rounded p-3 mb-2">' +
                    '<div class="d-flex justify-content-between align-items-center mb-2">' +
                        '<strong>' + userName + '</strong>' +
                        '<span class="badge" style="background-color: ' + eval.temperatureColor + ';">' +
                            (eval.mannerTemperature ? eval.mannerTemperature.toFixed(1) : '36.5') + '°C' +
                        '</span>' +
                    '</div>' +
                    (eval.travelPlanTitle ? '<small class="text-muted">from ' + eval.travelPlanTitle + '</small>' : '') +
                    (eval.evaluationComment ? '<div class="mt-2"><em>"' + eval.evaluationComment + '"</em></div>' : '') +
                    '<div class="mt-2">' +
                        (eval.isLike !== null ? (eval.isLike ? '<i class="fas fa-thumbs-up text-success"></i>' : '<i class="fas fa-thumbs-down text-warning"></i>') : '') +
                        '<small class="text-muted ms-2">' + date + '</small>' +
                    '</div>' +
                '</div>';
        }

        // 체크리스트 아이템 토글
        function toggleChecklistItem(checkbox) {
            const checklistId = checkbox.value;
            const isChecked = checkbox.checked;

            $.ajax({
                url: '${pageContext.request.contextPath}/travel/checklist/toggle',
                type: 'POST',
                data: {
                    checklistId: checklistId,
                    completed: isChecked
                },
                success: function(response) {
                    if (response.success) {
                        // 레이블 스타일 업데이트
                        const label = checkbox.nextElementSibling;
                        if (isChecked) {
                            label.classList.add('text-decoration-line-through', 'text-muted');
                        } else {
                            label.classList.remove('text-decoration-line-through', 'text-muted');
                        }

                        // 진행률 업데이트
                        if (response.completionRate !== undefined) {
                            const progressBar = document.querySelector('.checklist-header .progress-bar');
                            if (progressBar) {
                                progressBar.style.width = response.completionRate + '%';
                                progressBar.textContent = Math.round(response.completionRate) + '%';
                            }
                        }
                    } else {
                        alert('체크리스트 업데이트 실패: ' + (response.message || '알 수 없는 오류'));
                        checkbox.checked = !isChecked; // 원상복구
                    }
                },
                error: function() {
                    alert('서버 오류가 발생했습니다.');
                    checkbox.checked = !isChecked; // 원상복구
                }
            });
        }

        // 체크리스트 항목 추가
        function addChecklistItem(planId) {
            const itemName = prompt('추가할 체크리스트 항목을 입력하세요:');
            if (itemName && itemName.trim()) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/travel/checklist/add',
                    type: 'POST',
                    data: {
                        planId: planId,
                        itemName: itemName.trim()
                    },
                    success: function(response) {
                        if (response.success) {
                            // 체크리스트를 다시 로드
                            loadChecklistForPlan(planId);
                        } else {
                            alert('항목 추가 실패: ' + (response.message || '알 수 없는 오류'));
                        }
                    },
                    error: function() {
                        alert('서버 오류가 발생했습니다.');
                    }
                });
            }
        }

        // 체크리스트 항목 삭제
        function deleteChecklistItem(checklistId, planId) {
            if (confirm('이 항목을 삭제하시겠습니까?')) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/travel/checklist/delete',
                    type: 'POST',
                    data: {
                        checklistId: checklistId
                    },
                    success: function(response) {
                        if (response.success) {
                            // 해당 항목을 UI에서 제거
                            $('[data-item-id="' + checklistId + '"]').fadeOut(300, function() {
                                $(this).remove();
                                // 체크리스트 다시 로드
                                loadChecklistForPlan(planId);
                            });
                        } else {
                            alert('삭제 실패: ' + (response.message || '알 수 없는 오류'));
                        }
                    },
                    error: function() {
                        alert('서버 오류가 발생했습니다.');
                    }
                });
            }
        }

        // 체크리스트 로드 함수
        function loadChecklistForPlan(planId) {
            var checklistContainer = document.getElementById('checklist-container');

            fetch('${pageContext.request.contextPath}/travel/checklist/' + planId)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.checklist) {
                        var checklistHtml =
                            '<div class="checklist-header mb-3">' +
                                '<div class="progress mb-2">' +
                                    '<div class="progress-bar bg-success" style="width: ' + (data.completionRate || 0) + '%">' +
                                        Math.round(data.completionRate || 0) + '%' +
                                    '</div>' +
                                '</div>' +
                                '<small class="text-muted">완료: ' + (data.completed || 0) + ' / ' + (data.total || 0) + '</small>' +
                            '</div>' +
                            '<div class="checklist-items">';

                        if (data.checklist.length > 0) {
                            data.checklist.forEach(function(item) {
                                checklistHtml +=
                                    '<div class="checklist-item-wrapper d-flex align-items-center mb-2" data-item-id="' + item.checklistId + '">' +
                                        '<div class="form-check flex-grow-1">' +
                                            '<input class="form-check-input checklist-item"' +
                                                   ' type="checkbox"' +
                                                   ' id="checklist-' + item.checklistId + '"' +
                                                   ' value="' + item.checklistId + '"' +
                                                   ' data-plan-id="' + planId + '"' +
                                                   (item.completed ? ' checked' : '') +
                                                   ' onchange="toggleChecklistItem(this)">' +
                                            '<label class="form-check-label ' + (item.completed ? 'text-decoration-line-through text-muted' : '') + '"' +
                                                   ' for="checklist-' + item.checklistId + '">' +
                                                item.itemName +
                                            '</label>' +
                                        '</div>' +
                                        '<button class="btn btn-sm btn-link text-danger p-1"' +
                                                ' onclick="deleteChecklistItem(' + item.checklistId + ', ' + planId + ')"' +
                                                ' title="삭제">' +
                                            '<i class="fas fa-trash-alt"></i>' +
                                        '</button>' +
                                    '</div>';
                            });
                        }

                        checklistHtml +=
                            '</div>' +
                            '<div class="mt-3">' +
                                '<button class="btn btn-sm btn-outline-primary w-100"' +
                                        ' onclick="addChecklistItem(' + planId + ')">' +
                                    '<i class="fas fa-plus"></i> 항목 추가' +
                                '</button>' +
                            '</div>';

                        checklistContainer.innerHTML = checklistHtml;
                    }
                })
                .catch(error => {
                    console.error('Error loading checklist:', error);
                });
        }

        // 받은 동행 신청 로드 함수
        function loadReceivedRequests() {
            const userId = '${sessionScope.loginUser.userId}';
            console.log('Loading received requests for user:', userId);

            fetch('${pageContext.request.contextPath}/travel/api/requests/received/' + userId)
                .then(response => response.json())
                .then(data => {
                    console.log('Received requests data:', data);
                    const container = document.getElementById('received-requests-container');

                    if (data.success && data.requests && data.requests.length > 0) {
                        let html = '';

                        data.requests.forEach(request => {
                            // 상태별 클래스
                            var borderColor = request.status === 'PENDING' ? '#ffc107' :
                                            request.status === 'APPROVED' ? '#28a745' : '#dc3545';

                            // 상태별 배지
                            var statusBadge = request.status === 'PENDING' ? '<span class="badge bg-warning fs-6"><i class="fas fa-clock me-1"></i>대기중</span>' :
                                            request.status === 'APPROVED' ? '<span class="badge bg-success fs-6"><i class="fas fa-check me-1"></i>승인됨</span>' :
                                            '<span class="badge bg-danger fs-6"><i class="fas fa-times me-1"></i>거절됨</span>';

                            html += '<div class="dashboard-card mb-4" style="border-left: 4px solid ' + borderColor + ';">' +
                                    '<div class="card-body">' +
                                        '<div class="row">' +
                                            '<div class="col-lg-8">' +
                                                // 여행 정보
                                                '<div class="p-3 mb-3" style="background-color: #e3f2fd; border-radius: 0.5rem;">' +
                                                    '<h6 class="mb-2">' +
                                                        '<a href="${pageContext.request.contextPath}/travel/detail/' + request.travelPlanId + '" ' +
                                                           'class="text-decoration-none">' +
                                                            request.travelPlanTitle +
                                                        '</a>' +
                                                    '</h6>' +
                                                    '<p class="mb-1">' +
                                                        '<i class="fas fa-location-dot me-2"></i>' +
                                                        '<strong>목적지:</strong> ' + (request.travelPlanDestination || '정보 없음') +
                                                    '</p>' +
                                                    '<p class="mb-1">' +
                                                        '<i class="fas fa-calendar me-2"></i>' +
                                                        '<strong>여행 기간:</strong> ' +
                                                        (request.travelPlanStartDate ? new Date(request.travelPlanStartDate).toLocaleDateString('ko-KR').replace(/\. /g, '.').replace(/\.$/, '') : '') +
                                                        ' ~ ' +
                                                        (request.travelPlanEndDate ? new Date(request.travelPlanEndDate).toLocaleDateString('ko-KR').replace(/\. /g, '.').replace(/\.$/, '') : '') +
                                                    '</p>' +
                                                    '<p class="mb-0">' +
                                                        '<i class="fas fa-user me-2"></i>' +
                                                        '<strong>작성자:</strong> ' + (request.planWriterName || '${sessionScope.loginUser.userName}') +
                                                    '</p>' +
                                                '</div>' +

                                                // 신청자 정보
                                                '<div class="p-3 mb-3" style="background-color: #f8f9fa; border-radius: 0.5rem;">' +
                                                    '<h6 class="mb-3"><i class="fas fa-user-circle me-2"></i>신청자 정보</h6>' +
                                                    '<div class="row">' +
                                                        '<div class="col-6">' +
                                                            '<p class="mb-1"><strong>이름:</strong> ' + (request.requesterName || request.requesterId || '정보 없음') + '</p>' +
                                                            '<p class="mb-0"><strong>이메일:</strong> ' + (request.requesterEmail || 'email@example.com') + '</p>' +
                                                        '</div>' +
                                                        '<div class="col-6 text-end">' +
                                                            '<div class="mb-2">' +
                                                                '<span class="fs-5" style="color: ' + (request.requesterTemperatureColor || '#ffc107') + ';">' +
                                                                    (request.requesterTemperatureIcon || '😐') + ' ' +
                                                                    (request.requesterMannerScore || 36.5).toFixed(1) + '°C' +
                                                                '</span>' +
                                                                '<div class="small text-muted">' + (request.requesterTemperatureLevel || '매너 보통') + '</div>' +
                                                            '</div>' +
                                                        '</div>' +
                                                    '</div>' +

                                                    // 매너 통계
                                                    '<h6 class="text-muted mb-2 mt-3"><i class="fas fa-star me-1"></i>매너 통계</h6>' +
                                                    '<div class="row g-2">' +
                                                        '<div class="col-3 text-center">' +
                                                            '<div class="p-2 bg-light rounded">' +
                                                                '<div class="fw-bold text-primary">' + (request.requesterTotalEvaluations || 0) + '</div>' +
                                                                '<div class="small text-muted">받은 평가</div>' +
                                                            '</div>' +
                                                        '</div>' +
                                                        '<div class="col-3 text-center">' +
                                                            '<div class="p-2 bg-light rounded">' +
                                                                '<div class="fw-bold text-success">' + (request.requesterTotalLikes || 0) + '</div>' +
                                                                '<div class="small text-muted">좋아요</div>' +
                                                            '</div>' +
                                                        '</div>' +
                                                        '<div class="col-3 text-center">' +
                                                            '<div class="p-2 bg-light rounded">' +
                                                                '<div class="fw-bold text-danger">' + (request.requesterTotalDislikes || 0) + '</div>' +
                                                                '<div class="small text-muted">싫어요</div>' +
                                                            '</div>' +
                                                        '</div>' +
                                                        '<div class="col-3 text-center">' +
                                                            '<div class="p-2 bg-light rounded">' +
                                                                '<div class="fw-bold text-info">' + (request.requesterCompletedTravels || 0) + '</div>' +
                                                                '<div class="small text-muted">완료한 여행</div>' +
                                                            '</div>' +
                                                        '</div>' +
                                                    '</div>' +
                                                '</div>' +

                                                // 신청 메시지
                                                '<div class="mb-3">' +
                                                    '<h6><i class="fas fa-comment-dots me-2"></i>신청 메시지</h6>' +
                                                    '<div class="border rounded p-2 bg-light">' +
                                                        (request.requestMessage || '안녕하세요! 함께 여행하고 싶어서 신청합니다.') +
                                                    '</div>' +
                                                '</div>';

                            // 응답 메시지 (승인/거절된 경우)
                            if (request.responseMessage && request.status !== 'PENDING') {
                                var bgClass = request.status === 'APPROVED' ? 'bg-success' : 'bg-danger';
                                var messageTitle = request.status === 'APPROVED' ? '승인 메시지' : '거절 메시지';

                                html += '<div class="mb-3">' +
                                        '<h6><i class="fas fa-reply me-2"></i>' + messageTitle + '</h6>' +
                                        '<div class="border rounded p-2 ' + bgClass + ' bg-opacity-10">' +
                                            request.responseMessage +
                                        '</div>' +
                                        '</div>';
                            }

                            html += '</div>' +  // col-lg-8 끝
                                    '<div class="col-lg-4">' +
                                        '<div class="text-end">' +
                                            // 상태 배지
                                            '<div class="mb-3">' + statusBadge + '</div>' +
                                            // 신청일시
                                            '<p class="text-muted small mb-3">' +
                                                '<i class="fas fa-calendar-alt me-1"></i>' +
                                                new Date(request.requestDate).toLocaleDateString('ko-KR') +
                                            '</p>';

                            // 액션 버튼 (PENDING 상태인 경우만)
                            if (request.status === 'PENDING') {
                                html += '<div class="d-grid gap-2">' +
                                        '<button class="btn btn-success" onclick="acceptRequest(' + request.requestId + ')">' +
                                            '<i class="fas fa-check me-1"></i>승인' +
                                        '</button>' +
                                        '<button class="btn btn-danger" onclick="rejectRequest(' + request.requestId + ')">' +
                                            '<i class="fas fa-times me-1"></i>거절' +
                                        '</button>' +
                                        '</div>';
                            }

                            html += '</div>' +  // text-end
                                    '</div>' +  // col-lg-4
                                    '</div>' +  // row
                                    '</div>' +  // card-body
                                    '</div>';  // dashboard-card
                        });

                        container.innerHTML = html;
                    } else {
                        container.innerHTML =
                            '<div class="empty-state text-center py-5">' +
                                '<i class="fas fa-inbox fa-3x text-muted mb-3"></i>' +
                                '<h5 class="text-muted">받은 동행 신청이 없습니다</h5>' +
                                '<p class="text-muted">다른 사용자들이 회원님의 여행 계획에 동행 신청을 하면 여기에 표시됩니다.</p>' +
                            '</div>';
                    }
                })
                .catch(error => {
                    console.error('Error loading received requests:', error);
                    document.getElementById('received-requests-container').innerHTML =
                        '<p class="text-center text-danger">데이터를 불러오는데 실패했습니다.</p>';
                });
        }

        // 동행 신청 수락 함수
        function acceptRequest(requestId) {
            const responseMessage = prompt('승인 메시지를 입력하세요 (선택사항):', '동행 신청이 승인되었습니다. 함께 즐거운 여행 하세요!');

            if (responseMessage === null) {
                return; // 취소한 경우
            }

            const url = '${pageContext.request.contextPath}/travel/approve/' + requestId;
            console.log('Approving request:', requestId, 'URL:', url, 'Message:', responseMessage);

            $.ajax({
                url: url,
                type: 'POST',
                data: {
                    responseMessage: responseMessage
                },
                success: function(response) {
                    console.log('Approve response:', response);
                    if (response.success) {
                        alert(response.message || '동행 신청이 승인되었습니다.');
                        loadReceivedRequests();
                    } else {
                        alert(response.message || '승인 처리 중 오류가 발생했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Approve error:', status, error, xhr.responseText);
                    alert('승인 처리 중 오류가 발생했습니다: ' + error);
                }
            });
        }

        // 동행 신청 거절 함수
        function rejectRequest(requestId) {
            const responseMessage = prompt('거절 메시지를 입력하세요 (선택사항):', '죄송합니다. 이번 여행에는 함께할 수 없을 것 같습니다.');

            if (responseMessage === null) {
                return; // 취소한 경우
            }

            const url = '${pageContext.request.contextPath}/travel/reject/' + requestId;
            console.log('Rejecting request:', requestId, 'URL:', url, 'Message:', responseMessage);

            $.ajax({
                url: url,
                type: 'POST',
                data: {
                    responseMessage: responseMessage
                },
                success: function(response) {
                    console.log('Reject response:', response);
                    if (response.success) {
                        alert(response.message || '동행 신청이 거절되었습니다.');
                        loadReceivedRequests();
                    } else {
                        alert(response.message || '거절 처리 중 오류가 발생했습니다.');
                    }
                },
                error: function(xhr, status, error) {
                    console.error('Reject error:', status, error, xhr.responseText);
                    alert('거절 처리 중 오류가 발생했습니다: ' + error);
                }
            });
        }

        // 동행 신청 취소 함수
        function cancelRequest(requestId) {
            if (confirm('정말로 이 동행 신청을 취소하시겠습니까?')) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/travel/request/cancel/' + requestId,
                    type: 'POST',
                    success: function(response) {
                        if (response.success) {
                            alert('동행 신청이 취소되었습니다.');
                            location.reload();
                        } else {
                            alert('신청 취소 중 오류가 발생했습니다: ' + (response.message || '알 수 없는 오류'));
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
                        console.error('Error:', error);
                    }
                });
            }
        }

        // 자기소개 업데이트 함수
        function updateBio() {
            const bioText = document.getElementById('bioTextarea').value.trim();

            fetch('${pageContext.request.contextPath}/member/updateBio', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ bio: bioText })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('자기소개가 성공적으로 저장되었습니다.');
                    location.reload(); // 페이지 새로고침
                } else {
                    alert(data.message || '자기소개 저장에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('오류가 발생했습니다.');
            });
        }
    </script>
</c:if>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>