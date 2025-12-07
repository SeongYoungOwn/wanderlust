<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>마이페이지 - AI 여행 동행 매칭 플랫폼</title>
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
            padding-top: 60px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        /* Page Header */
        .profile-header {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white;
            padding: 120px 0 30px 0;
            margin-top: 0;
            position: relative;
            overflow: hidden;
            min-height: 50vh;
            display: flex;
            align-items: center;
        }
        
        .profile-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="stars" width="20" height="20" patternUnits="userSpaceOnUse"><circle cx="10" cy="10" r="1" fill="white" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23stars)"/></svg>');
            animation: twinkle 20s ease-in-out infinite;
            z-index: 1;
        }
        
        @keyframes twinkle {
            0%, 100% { opacity: 0.5; }
            50% { opacity: 1; }
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
        
        .breadcrumb-custom {
            background: rgba(255, 255, 255, 0.1);
            padding: 0.75rem 1.5rem;
            border-radius: 50px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            display: inline-block;
            z-index: 2;
            position: relative;
        }
        
        .breadcrumb-custom a {
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s ease;
        }
        
        .breadcrumb-custom a:hover {
            color: white;
        }
        
        .breadcrumb-custom .current {
            color: white;
            font-weight: 600;
        }
        
        .profile-header .profile-img,
        .profile-header h1,
        .profile-header p {
            position: relative;
            z-index: 5;
        }
        .profile-img {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 5px solid white;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3.5rem;
            color: white;
            font-weight: 600;
            text-transform: uppercase;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        /* Main Content */
        .main-content {
            background: var(--bg-secondary);
            margin: -18px 0 0 0;
            border-radius: 20px 20px 0 0;
            box-shadow: 0 -5px 15px rgba(0,0,0,0.1);
            min-height: 70vh;
            padding: 2rem 0;
        }
        
        .info-card {
            transition: all 0.3s ease;
            border: none;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            border-radius: 15px;
            overflow: hidden;
            background: var(--bg-card);
        }
        
        .info-card .card-body {
            background: var(--bg-card);
            color: var(--text-primary);
        }
        
        .info-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.12);
        }
        
        .card-header {
            background: linear-gradient(135deg, #667eea, #764ba2) !important;
            border: none;
            padding: 1.5rem;
        }
        
        .card-header.bg-success {
            background: linear-gradient(135deg, #28a745, #20c997) !important;
        }
        
        .card-header.bg-info {
            background: linear-gradient(135deg, #17a2b8, #6f42c1) !important;
        }
        
        .card-header.bg-warning {
            background: linear-gradient(135deg, #ffc107, #fd7e14) !important;
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
        
        .btn-success {
            background: linear-gradient(135deg, #28a745, #20c997);
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(40, 167, 69, 0.3);
        }
        
        .btn-info {
            background: linear-gradient(135deg, #17a2b8, #6f42c1);
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-info:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(23, 162, 184, 0.3);
        }
        
        .btn-outline-primary, .btn-outline-success, .btn-outline-warning {
            border-radius: 8px;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-outline-primary:hover, .btn-outline-success:hover, .btn-outline-warning:hover {
            transform: translateY(-2px);
        }
        
        .badge {
            border-radius: 8px;
            padding: 0.5rem 0.75rem;
        }
        
        .table {
            border-radius: 10px;
            overflow: hidden;
        }
        
        .table th {
            background: linear-gradient(135deg, #f8f9fa, #ffffff);
            border: none;
            font-weight: 600;
            color: #2d3748;
        }
        .sidebar {
            position: fixed;
            top: 60px; /* Adjust based on header height */
            left: 0;
            width: 250px;
            height: calc(100% - 60px);
            background: #2c3e50; /* Solid dark background */
            /* backdrop-filter: blur(10px); */ /* Remove blur for solid background */
            /* -webkit-backdrop-filter: blur(10px); */
            border-right: 1px solid rgba(255, 255, 255, 0.2);
            padding: 20px;
            transform: translateX(-100%);
            transition: transform 0.3s ease-in-out;
            z-index: 1000;
            color: white;
            box-shadow: 5px 0 15px rgba(0, 0, 0, 0.3); /* Add shadow */
        }
        .sidebar h3 { /* Ensure heading is visible */
            color: #ecf0f1; /* Light color for heading */
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .sidebar.active {
            transform: translateX(0);
        }
        .sidebar-toggle {
            position: fixed;
            top: 80px; /* Increased top value */
            left: 10px;
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 5px;
            cursor: pointer;
            z-index: 9999; /* Increased z-index */
            transition: left 0.3s ease-in-out;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3); /* Added shadow */
        }
        .sidebar.active + .sidebar-toggle {
            left: 260px; /* Adjust based on sidebar width + some margin */
        }
        .main-content-wrapper {
            margin-left: 0;
            transition: margin-left 0.3s ease-in-out;
        }
        .main-content-wrapper.shifted {
            margin-left: 250px; /* Same as sidebar width */
        }
        .sidebar ul {
            list-style: none; /* Remove bullet points */
            padding: 0;
            margin-top: 20px;
        }
        .sidebar ul li {
            margin-bottom: 10px;
        }
        .sidebar ul li a {
            color: white;
            text-decoration: none;
            display: block;
            padding: 8px 10px;
            border-radius: 5px;
            transition: background-color 0.2s ease;
        }
        .sidebar ul li a:hover {
            background-color: rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body>
    <div id="sidebar" class="sidebar">
        <h3 style="display: flex; justify-content: space-between; align-items: center;">
            My Page
            <button id="sidebarCloseButton" style="background: none; border: none; color: white; font-size: 1.2em; cursor: pointer;">
                &times;
            </button>
        </h3>
        <ul>
            <li><a href="${pageContext.request.contextPath}/member/mypage">대시보드</a></li>
            <li><a href="${pageContext.request.contextPath}/member/mypage/info">내 정보</a></li>
            <li><a href="${pageContext.request.contextPath}/travel/my-plans">여행 관리</a></li>
            <li><a href="${pageContext.request.contextPath}/member/mypage/activity">활동 기록</a></li>
            <li><a href="${pageContext.request.contextPath}/board/my-posts">작성한 글</a></li>
            <li><a href="${pageContext.request.contextPath}/member/mypage/timeline">활동 타임라인</a></li>
            <li><a href="${pageContext.request.contextPath}/member/mypage/saved">저장 목록</a></li>
            <li><a href="${pageContext.request.contextPath}/message/inbox">쪽지함</a></li>
        </ul>
    </div>
    <button id="sidebarToggle" class="sidebar-toggle">☰ 메뉴</button>
    <div id="mainContentWrapper" class="main-content-wrapper">
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <!-- Page Header -->
        <div class="profile-header">
            <div class="container text-center">
                <div class="breadcrumb-custom mb-4">
                    <a href="${pageContext.request.contextPath}/home">홈</a>
                    <i class="fas fa-chevron-right mx-2"></i>
                    <span class="current">마이페이지</span>
                </div>
                <div class="row align-items-center">
                    <div class="col-md-3 text-center">
                        <div class="profile-img mx-auto">
                            <c:choose>
                                <c:when test="${not empty member.profileImage}">
                                    <img src="${member.profileImage}" alt="프로필 이미지" style="width: 100%; height: 100%; object-fit: cover; border-radius: 50%;">
                                </c:when>
                                <c:otherwise>
                                    <c:set var="initial" value="${fn:substring(member.userName, 0, 1)}" />
                                    ${initial}
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="col-md-9 text-start">
                        <h1 class="page-title"><i class="fas fa-user-circle me-3"></i>${member.userName}님의 프로필</h1>
                        <p class="page-subtitle">환영합니다! 여행 동행 매칭 플랫폼에서 새로운 여행을 시작하세요.</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="container">
            <div class="row">
                <!-- 기본 정보 카드 -->
                <div class="col-md-6 mb-4">
                    <div class="card info-card shadow">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0"><i class="fas fa-user-circle me-2"></i>기본 정보</h5>
                        </div>
                        <div class="card-body">
                            <table class="table table-borderless">
                                <tr>
                                    <th width="30%"><i class="fas fa-id-card me-2"></i>아이디</th>
                                    <td>${member.userId}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-signature me-2"></i>이름</th>
                                    <td>${member.userName}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-envelope me-2"></i>이메일</th>
                                    <td>${member.userEmail}</td>
                                </tr>
                                <tr>
                                    <th><i class="fas fa-calendar-alt me-2"></i>가입일</th>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty member.userRegdate}">
                                                <fmt:formatDate value="${member.userRegdate}" pattern="yyyy년 MM월 dd일"/>
                                            </c:when>
                                            <c:otherwise>
                                                최근 가입
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- 자기소개 카드 -->
                <div class="col-md-12 mb-4">
                    <div class="card info-card shadow">
                        <div class="card-header bg-warning text-white">
                            <h5 class="mb-0"><i class="fas fa-edit me-2"></i>자기소개</h5>
                        </div>
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
                                    <button type="button" class="btn btn-warning" onclick="updateBio()">
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

                <!-- 여행 MBTI 정보 카드 -->
                <div class="col-md-6 mb-4">
                    <div class="card info-card shadow">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0"><i class="fas fa-user-tag me-2"></i>여행 MBTI</h5>
                        </div>
                        <div class="card-body">
                            <div id="mbti-info">
                                <c:choose>
                                    <c:when test="${not empty userMbti}">
                                        <div class="text-center mb-3">
                                            <span class="badge bg-primary fs-4 px-4 py-3">${userMbti.mbtiType}</span>
                                        </div>
                                        <h5 class="fw-bold text-center mb-3 text-primary">${mbtiTypeName}</h5>
                                        <p class="text-muted text-center mb-3">
                                            <small><i class="fas fa-calendar me-1"></i>테스트 날짜: 
                                                <fmt:formatDate value="${userMbti.testDate}" pattern="yyyy년 MM월 dd일"/>
                                            </small>
                                        </p>
                                        
                                        <!-- MBTI 차원별 상세 정보 -->
                                        <div class="row mb-3" id="mbti-dimensions">
                                            <!-- JavaScript로 차원 정보 생성 -->
                                        </div>
                                        
                                        <div class="text-center mb-3">
                                            <a href="${pageContext.request.contextPath}/travel-mbti/result/${userMbti.mbtiType}" class="btn btn-sm btn-outline-success me-2">
                                                <i class="fas fa-eye me-1"></i>상세 보기
                                            </a>
                                            <a href="${pageContext.request.contextPath}/travel-mbti/test" class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-redo me-1"></i>다시 테스트
                                            </a>
                                        </div>
                                        
                                        <hr class="my-3">
                                        <div id="compatible-mbti">
                                            <h6 class="fw-bold text-center mb-3">
                                                <i class="fas fa-heart text-danger me-1"></i>최고의 여행 파트너
                                            </h6>
                                            <div id="compatibility-list" class="text-center">
                                                <div id="matching-mbti-display" class="mb-2">
                                                    <!-- JavaScript로 매칭 정보 생성 -->
                                                </div>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="text-center py-3">
                                            <i class="fas fa-user-tag fa-2x text-muted mb-3"></i>
                                            <p class="text-muted mb-3">아직 여행 MBTI 테스트를 하지 않으셨습니다.</p>
                                            <a href="${pageContext.request.contextPath}/travel-mbti/test" class="btn btn-success">
                                                <i class="fas fa-play me-2"></i>테스트 시작하기
                                            </a>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <!-- 활동 정보 -->
            <div class="row">
                <div class="col-12">
                    <div class="card shadow">
                        <div class="card-header bg-info text-white">
                            <h5 class="mb-0"><i class="fas fa-chart-line me-2"></i>나의 활동</h5>
                        </div>
                        <div class="card-body">
                            <div class="row text-center">
                                <div class="col-md-4 mb-3">
                                    <div class="p-3 bg-light rounded">
                                        <i class="fas fa-map-marked-alt fa-2x text-success mb-2"></i>
                                        <h4 class="mb-1">${travelPlanCount != null ? travelPlanCount : 0}</h4>
                                        <p class="text-muted mb-0">등록한 여행 계획</p>
                                    </div>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <div class="p-3 bg-light rounded">
                                        <i class="fas fa-users fa-2x text-warning mb-2"></i>
                                        <h4 class="mb-1">${joinedTravelCount != null ? joinedTravelCount : 0}</h4>
                                        <p class="text-muted mb-0">참여한 여행</p>
                                    </div>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <div class="p-3 bg-light rounded">
                                        <i class="fas fa-comments fa-2x text-warning mb-2"></i>
                                        <h4 class="mb-1">${postCount != null ? postCount : 0}</h4>
                                        <p class="text-muted mb-0">작성한 게시글</p>
                                    </div>
                                </div>
                            </div>
                            <div class="row text-center mt-3">
                                <div class="col-md-6 mb-3">
                                    <div class="p-3 bg-light rounded position-relative" style="cursor: pointer;" onclick="window.location.href='${pageContext.request.contextPath}/message/inbox'">
                                        <i class="fas fa-envelope fa-2x text-primary mb-2"></i>
                                        <h4 class="mb-1" id="unreadMessageCount">0</h4>
                                        <p class="text-muted mb-0">읽지 않은 쪽지</p>
                                        <div class="position-absolute top-0 end-0 m-2">
                                            <span class="badge bg-danger rounded-pill" id="unreadBadge" style="display: none;">New</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <div class="p-3 bg-light rounded" style="cursor: pointer;" onclick="window.location.href='${pageContext.request.contextPath}/message/outbox'">
                                        <i class="fas fa-paper-plane fa-2x text-secondary mb-2"></i>
                                        <h4 class="mb-1" id="sentMessageCount">0</h4>
                                        <p class="text-muted mb-0">보낸 쪽지</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- 내가 작성한 여행 계획 -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card info-card shadow">
                        <div class="card-header bg-success text-white">
                            <h4 class="mb-0"><i class="fas fa-map-marked-alt me-2"></i>내가 작성한 여행 계획</h4>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty myTravelPlans}">
                                    <div class="text-center py-4">
                                        <p class="text-muted mb-3">아직 작성한 여행 계획이 없습니다.</p>
                                        <a href="${pageContext.request.contextPath}/travel/create" class="btn btn-success">
                                            <i class="fas fa-plus-circle me-2"></i>여행 계획 만들기
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>여행 제목</th>
                                                    <th>목적지</th>
                                                    <th>여행 기간</th>
                                                    <th>예산</th>
                                                    <th>작성일</th>
                                                    <th>관리</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="plan" items="${myTravelPlans}">
                                                    <tr>
                                                        <td><strong>${plan.planTitle}</strong></td>
                                                        <td>
                                                            <span class="badge bg-primary">
                                                                <i class="fas fa-map-marker-alt me-1"></i>${plan.planDestination}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${plan.planStartDate}" pattern="yyyy.MM.dd"/> ~ 
                                                            <fmt:formatDate value="${plan.planEndDate}" pattern="yyyy.MM.dd"/>
                                                        </td>
                                                        <td>
                                                            <c:if test="${plan.planBudget != null && plan.planBudget > 0}">
                                                                <span class="text-success fw-bold">
                                                                    <fmt:formatNumber value="${plan.planBudget}" pattern="#,###"/>원
                                                                </span>
                                                            </c:if>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${plan.planRegdate}" pattern="yyyy.MM.dd"/>
                                                        </td>
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}" class="btn btn-sm btn-outline-primary me-1">
                                                                <i class="fas fa-eye me-1"></i>보기
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/travel/edit/${plan.planId}" class="btn btn-sm btn-outline-warning">
                                                                <i class="fas fa-edit me-1"></i>수정
                                                            </a>
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
            </div>

            <!-- 내가 작성한 커뮤니티 글 -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card info-card shadow">
                        <div class="card-header bg-info text-white">
                            <h4 class="mb-0"><i class="fas fa-comments me-2"></i>내가 작성한 커뮤니티 글</h4>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty myPosts}">
                                    <div class="text-center py-4">
                                        <p class="text-muted mb-3">아직 작성한 게시글이 없습니다.</p>
                                        <a href="${pageContext.request.contextPath}/board/create" class="btn btn-info">
                                            <i class="fas fa-pen me-2"></i>첫 번째 글 작성하기
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>제목</th>
                                                    <th>카테고리</th>
                                                    <th>조회수</th>
                                                    <th>좋아요</th>
                                                    <th>작성일</th>
                                                    <th>관리</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="post" items="${myPosts}">
                                                    <tr>
                                                        <td><strong>${post.boardTitle}</strong></td>
                                                        <td>
                                                            <span class="badge bg-secondary">일반</span>
                                                        </td>
                                                        <td>
                                                            <span class="text-muted">
                                                                <i class="fas fa-eye me-1"></i>${post.boardViews}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <span class="text-muted">
                                                                <i class="fas fa-heart text-danger me-1"></i>${post.boardLikes}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${post.boardRegdate}" pattern="yyyy.MM.dd"/>
                                                        </td>
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/board/detail/${post.boardId}" class="btn btn-sm btn-outline-primary me-1">
                                                                <i class="fas fa-eye me-1"></i>보기
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/board/edit/${post.boardId}" class="btn btn-sm btn-outline-warning">
                                                                <i class="fas fa-edit me-1"></i>수정
                                                            </a>
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
            </div>

            <!-- 참여한 여행 목록 -->
            <div class="row mt-4">
                <div class="col-12">
                    <div class="card info-card shadow">
                        <div class="card-header bg-warning text-white">
                            <h4 class="mb-0"><i class="fas fa-plane me-2"></i>참여한 여행 계획</h4>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${empty joinedTravels}">
                                    <div class="text-center py-4">
                                        <p class="text-muted mb-3">아직 참여한 여행이 없습니다.</p>
                                        <a href="${pageContext.request.contextPath}/travel/list" class="btn btn-primary">
                                            <i class="fas fa-search me-2"></i>여행 계획 둘러보기
                                        </a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="table-responsive">
                                        <table class="table table-hover">
                                            <thead>
                                                <tr>
                                                    <th>여행 제목</th>
                                                    <th>목적지</th>
                                                    <th>여행 기간</th>
                                                    <th>참여일</th>
                                                    <th>상세보기</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="travel" items="${joinedTravels}">
                                                    <tr>
                                                        <td>${travel.travelTitle}</td>
                                                        <td>
                                                            <span class="badge bg-primary">
                                                                <i class="fas fa-map-marker-alt me-1"></i>${travel.destination}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${travel.startDate}" pattern="yyyy.MM.dd"/> ~ 
                                                            <fmt:formatDate value="${travel.endDate}" pattern="yyyy.MM.dd"/>
                                                        </td>
                                                        <td>
                                                            <fmt:formatDate value="${travel.joinedDate}" pattern="yyyy.MM.dd"/>
                                                        </td>
                                                        <td>
                                                            <a href="${pageContext.request.contextPath}/travel/detail/${travel.travelId}" 
                                                               class="btn btn-sm btn-outline-primary">
                                                                <i class="fas fa-eye me-1"></i>보기
                                                            </a>
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
            </div>

            <!-- 액션 버튼들 -->
            <div class="row mt-4">
                <div class="col-12 text-center">
                    <button class="btn btn-primary btn-lg me-2" onclick="location.href='${pageContext.request.contextPath}/member/edit'">
                        <i class="fas fa-edit me-2"></i>프로필 수정
                    </button>
                    <button class="btn btn-success btn-lg me-2" onclick="location.href='${pageContext.request.contextPath}/travel/create'">
                        <i class="fas fa-plus-circle me-2"></i>여행 계획 만들기
                    </button>
                    <button class="btn btn-info btn-lg" onclick="location.href='${pageContext.request.contextPath}/travel/list'">
                        <i class="fas fa-search me-2"></i>동행 찾기
                    </button>
                </div>
            </div>
            </div>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>
    
    </div> <!-- Closing tag for mainContentWrapper -->
    
    <script>
        // Sidebar toggle functionality
        document.addEventListener('DOMContentLoaded', function() {
            const sidebar = document.getElementById('sidebar');
            const sidebarToggle = document.getElementById('sidebarToggle');
            const sidebarCloseButton = document.getElementById('sidebarCloseButton'); // New line
            const mainContentWrapper = document.getElementById('mainContentWrapper');

            if (sidebar && sidebarToggle && mainContentWrapper) {
                sidebarToggle.addEventListener('click', function() {
                    sidebar.classList.toggle('active');
                    mainContentWrapper.classList.toggle('shifted');
                });

                // New event listener for the close button
                if (sidebarCloseButton) {
                    sidebarCloseButton.addEventListener('click', function() {
                        sidebar.classList.remove('active');
                        mainContentWrapper.classList.remove('shifted');
                    });
                }
            }

            // 페이지 로드 시 MBTI 차원 정보 생성
            <c:if test="${not empty userMbti}">
                generateMbtiDimensions('${userMbti.mbtiType}');
                loadCompatibleMbti('${userMbti.mbtiType}');
            </c:if>
            
            // 쪽지 개수 로드
            loadMessageCounts();
        });
    </script>
        
        function generateMbtiDimensions(mbtiType) {
            const mbtiChars = mbtiType.split('');
            const dimensions = [
                { char: mbtiChars[0], name: mbtiChars[0] === 'J' ? '계획형' : '즉흥형', desc: mbtiChars[0] === 'J' ? '체계적이고 계획적인 여행을 선호' : '자유롭고 즉흥적인 여행을 선호' },
                { char: mbtiChars[1], name: mbtiChars[1] === 'A' ? '모험형' : '안전형', desc: mbtiChars[1] === 'A' ? '새로운 경험과 모험을 추구' : '안전하고 편안한 여행을 선호' },
                { char: mbtiChars[2], name: mbtiChars[2] === 'G' ? '그룹형' : '개인형', desc: mbtiChars[2] === 'G' ? '친구, 가족과 함께하는 여행 선호' : '혼자만의 여행 시간을 중시' },
                { char: mbtiChars[3], name: mbtiChars[3] === 'L' ? '럭셔리형' : '백패킹형', desc: mbtiChars[3] === 'L' ? '편안하고 럭셔리한 여행 추구' : '경제적이고 현지적인 여행 선호' }
            ];
            
            const dimensionsDiv = document.getElementById('mbti-dimensions');
            if (dimensionsDiv) {
                dimensionsDiv.innerHTML = dimensions.map(dim => `
                    <div class="col-6 mb-2">
                        <div class="card border-0 bg-light">
                            <div class="card-body p-2 text-center">
                                <div class="badge bg-secondary mb-1">${dim.char}</div>
                                <div class="fw-bold small">${dim.name}</div>
                                <div class="text-muted" style="font-size: 0.75rem;">${dim.desc}</div>
                            </div>
                        </div>
                    </div>
                `).join('');
            }
        }
        
        function loadCompatibleMbti(userMbtiType) {
            // 최적의 매칭 MBTI 계산
            const matchingMbti = calculateBestMatchingMbti(userMbtiType);
            const matchingTypeName = getMbtiTypeName(matchingMbti);
            const recommendReason = getRecommendReason(userMbtiType, matchingMbti);
            
            const matchingDiv = document.getElementById('matching-mbti-display');
            if (matchingDiv) {
                matchingDiv.innerHTML = `
                    <div class="bg-light p-3 rounded">
                        <div class="mb-2">
                            <small class="text-muted">${userMbtiType} (${getMbtiTypeName(userMbtiType)}) →</small>
                        </div>
                        <div class="h5 text-danger mb-1">
                            <strong>${matchingMbti}</strong>
                        </div>
                        <div>
                            <small class="text-success">${recommendReason}</small>
                        </div>
                    </div>
                `;
            }
        }
        
        function calculateBestMatchingMbti(mbtiType) {
            if (!mbtiType || mbtiType.length !== 4) return 'JAGL';
            
            const types = mbtiType.split('');
            const matching = [];
            
            // P/J: 반대가 잘 맞음
            matching[0] = (types[0] === 'J') ? 'P' : 'J';
            // A/S: 같은 성향
            matching[1] = types[1];
            // I/G: 같은 성향
            matching[2] = types[2];
            // L/B: 같은 성향
            matching[3] = types[3];
            
            return matching.join('');
        }
        
        function getMbtiTypeName(mbtiType) {
            const typeNames = {
                'PAIB': '알뜰한 계획형 모험가',
                'PAGL': '프리미엄 단체 모험가',
                'PAGB': '효율적인 그룹 탐험가',
                'PSIL': '신중한 혼자만의 럭셔리 여행자',
                'PSIB': '실속형 안전 여행자',
                'PSGL': '편안한 그룹 휴양가',
                'PSGB': '가성비 단체 관광객',
                'JAIL': '자유로운 혼자만의 특별한 경험가',
                'JAIB': '즉흥적인 배낭여행자',
                'JAGL': '즉흥적인 그룹 모험가',
                'JAGB': '자유로운 그룹 백패커',
                'JSIL': '계획 없는 혼자만의 힐링 여행자',
                'JSIB': '자유로운 실속 여행자',
                'JSGL': '여유로운 그룹 휴양객',
                'JSGB': '편안한 가성비 여행자',
                'PAIL': '완벽한 혼자만의 모험가'
            };
            return typeNames[mbtiType] || '추천 여행 타입';
        }
        
        function getRecommendReason(userMbti, matchingMbti) {
            const reasons = {
                'PAIB': { // 알뜰한 계획형 모험가
                    'JAIB': '즉흥성이 계획에 활력을 더해줍니다',
                    'JAGB': '그룹 여행의 재미를 발견할 수 있어요',
                    'JAGL': '새로운 럭셔리 경험을 선사해줄 파트너',
                    'JAIL': '혼자만의 시간도 소중히 여길 줄 아는 여행자'
                },
                'PAGL': { // 프리미엄 단체 모험가
                    'JAGL': '즉흥적 아이디어로 더 특별한 여행을',
                    'JAGB': '가성비 여행의 매력을 알려줄 파트너',
                    'JAIB': '개인적 경험을 통해 깊이를 더해줘요',
                    'JAIL': '혼자만의 특별함을 그룹에 녹여내는 조합'
                },
                'PAGB': { // 효율적인 그룹 탐험가
                    'JAGB': '자유로운 발상으로 경직됨을 풀어줍니다',
                    'JAGL': '럭셔리한 경험으로 여행의 품격을 높여요',
                    'JAIB': '개인적 모험심이 그룹에 활력을 선사',
                    'JAIL': '독특한 경험을 그룹과 나누는 특별한 조합'
                },
                'PSIL': { // 신중한 혼자만의 럭셔리 여행자
                    'JSIL': '같은 성향으로 편안하고 깊이 있는 여행',
                    'JSIB': '가성비 팁으로 더 알찬 럭셔리 경험',
                    'JSGL': '그룹의 즐거움을 안전하게 경험',
                    'JSGB': '경제적이면서도 품격 있는 여행 스타일'
                },
                'PSIB': { // 실속형 안전 여행자
                    'JSIB': '같은 가치관으로 알뜰하고 안전한 여행',
                    'JSIL': '럭셔리 경험으로 여행의 새로운 면 발견',
                    'JSGL': '그룹 여행의 즐거움을 안전하게 경험',
                    'JSGB': '가성비와 그룹의 장점을 모두 누리는 조합'
                },
                'PSGL': { // 편안한 그룹 휴양가
                    'JSGL': '여유로운 마음으로 함께하는 편안한 여행',
                    'JSGB': '경제적이면서도 그룹의 재미를 더하는 조합',
                    'JSIL': '개인적 럭셔리 경험을 그룹과 공유',
                    'JSIB': '실속 있는 그룹 여행의 새로운 발견'
                },
                'PSGB': { // 가성비 단체 관광객
                    'JSGB': '경제적이면서 즐거운 그룹 여행의 완벽한 조합',
                    'JSGL': '럭셔리한 경험을 가성비 있게 즐기는 방법',
                    'JSIB': '개인적 경험과 그룹의 재미를 균형 있게',
                    'JSIL': '혼자만의 시간도 소중히 여기는 균형잡힌 조합'
                },
                'JAIL': { // 자유로운 혼자만의 특별한 경험가
                    'PAGB': '체계적 계획으로 특별함을 더욱 빛나게',
                    'PAGL': '그룹의 에너지로 독특한 경험을 확장',
                    'PAIB': '계획적 접근으로 모험을 더욱 안전하게',
                    'PAIL': '같은 개인주의 성향으로 깊이 있는 동반자'
                },
                'JAIB': { // 즉흥적인 배낭여행자
                    'PAIB': '체계적 계획으로 즉흥여행을 더욱 풍성하게',
                    'PAGB': '그룹의 힘으로 백패킹의 안전성을 높여요',
                    'PAGL': '럭셔리 경험으로 배낭여행에 품격을 더하는',
                    'PAIL': '개인적 모험을 계획적으로 실현하는 조합'
                },
                'JAGL': { // 즉흥적인 그룹 모험가
                    'PAGL': '계획적 접근으로 그룹 모험을 더욱 완벽하게',
                    'PAGB': '가성비 마인드로 럭셔리를 알뜰하게 경험',
                    'PAIB': '개인적 깊이로 그룹 여행에 의미를 더하는',
                    'PAIL': '혼자만의 시간도 소중히 여기는 균형잡힌 모험가'
                },
                'JAGB': { // 자유로운 그룹 백패커
                    'PAGB': '체계적 계획으로 그룹 백패킹을 더욱 체계적으로',
                    'PAGL': '럭셔리 터치로 백패킹에 편안함을 더해요',
                    'PAIB': '개인적 모험심을 계획적으로 승화시키는',
                    'PAIL': '혼자만의 경험을 그룹과 공유하는 특별한 조합'
                },
                'JSIL': { // 계획 없는 혼자만의 힐링 여행자
                    'PSIL': '같은 혼자 여행 성향으로 깊이 있는 교감',
                    'PSGL': '그룹의 따뜻함으로 힐링 여행을 더욱 풍성하게',
                    'PSIB': '실속 있는 팁으로 럭셔리 힐링을 경제적으로',
                    'PSGB': '가성비 그룹 여행의 새로운 매력 발견'
                },
                'JSIB': { // 자유로운 실속 여행자
                    'PSIB': '같은 가치관으로 알뜰하고 자유로운 여행',
                    'PSIL': '럭셔리 경험으로 실속 여행에 품격을 더해요',
                    'PSGL': '그룹 여행으로 혼자 여행의 아쉬움을 채우는',
                    'PSGB': '가성비 그룹 여행의 완벽한 파트너'
                },
                'JSGL': { // 여유로운 그룹 휴양객
                    'PSGL': '같은 그룹 성향으로 편안하고 여유로운 여행',
                    'PSIL': '개인적 럭셔리 경험을 그룹과 나누는 조합',
                    'PSIB': '실속 있는 팁으로 그룹 여행을 더욱 알차게',
                    'PSGB': '가성비와 품격을 모두 잡는 완벽한 조합'
                },
                'JSGB': { // 편안한 가성비 여행자
                    'PSGB': '같은 가성비 마인드로 경제적이고 즐거운 여행',
                    'PSGL': '럭셔리 터치로 가성비 여행에 품격을 더해요',
                    'PSIL': '혼자만의 시간도 소중히 여기는 균형잡힌 조합',
                    'PSIB': '개인적 경험과 그룹의 재미를 모두 잡는 조합'
                },
                'PAIL': { // 완벽한 혼자만의 모험가
                    'JAIL': '같은 개인주의 성향으로 깊이 있는 모험 동반자',
                    'JAIB': '즉흥적 에너지로 계획적 모험에 활력을 더해요',
                    'JAGL': '그룹의 에너지로 개인 모험을 더욱 풍성하게',
                    'JAGB': '가성비 마인드로 럭셔리 모험을 알뜰하게'
                }
            };
            
            // 매칭되는 추천 이유가 있으면 반환, 없으면 기본값
            if (reasons[userMbti] && reasons[userMbti][matchingMbti]) {
                return reasons[userMbti][matchingMbti];
            }
            
            // 기본 추천 이유 (매칭 로직에 따라)
            const userChars = userMbti.split('');
            const matchingChars = matchingMbti.split('');
            
            if (userChars[0] !== matchingChars[0]) {
                return '계획성과 즉흥성의 완벽한 조화';
            } else if (userChars[2] !== matchingChars[2]) {
                return '개인 여행과 그룹 여행의 균형잡힌 조합';
            } else if (userChars[3] !== matchingChars[3]) {
                return '럭셔리와 가성비의 절묘한 밸런스';
            } else {
                return '비슷한 성향으로 편안한 여행 동반자';
            }
        }
        
        function getCompatibleMbtiTypes(mbtiType) {
            // 기본 추천 조합 로직 (실제로는 더 복잡한 알고리즘 사용 가능)
            const allTypes = ['PAGB', 'PAGL', 'PAIB', 'PAIL', 'PSGB', 'PSGL', 'PSIB', 'PSIL', 
                            'JAGB', 'JAGL', 'JAIB', 'JAIL', 'JSGB', 'JSGL', 'JSIB', 'JSIL'];
            
            // 같은 성향 2개 이상 일치하는 타입들을 추천
            const compatible = [];
            const userChars = mbtiType.split('');
            
            allTypes.forEach(type => {
                if (type !== mbtiType) {
                    const typeChars = type.split('');
                    let matchCount = 0;
                    for (let i = 0; i < 4; i++) {
                        if (userChars[i] === typeChars[i]) {
                            matchCount++;
                        }
                    }
                    if (matchCount >= 2) {
                        compatible.push(type);
                    }
                }
            });
            
            return compatible.slice(0, 8); // 최대 8개만 표시
        }
        
        // 쪽지 개수 로드 함수
        function loadMessageCounts() {
            // 읽지 않은 쪽지 개수 조회
            fetch('${pageContext.request.contextPath}/message/unread-count')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        const unreadCount = data.count;
                        document.getElementById('unreadMessageCount').textContent = unreadCount;
                        
                        // 읽지 않은 쪽지가 있으면 New 배지 표시
                        const badge = document.getElementById('unreadBadge');
                        if (unreadCount > 0) {
                            badge.style.display = 'block';
                            badge.textContent = unreadCount;
                        } else {
                            badge.style.display = 'none';
                        }
                    }
                })
                .catch(error => {
                    console.error('읽지 않은 쪽지 개수 조회 오류:', error);
                });
        }

        // 자기소개 문자 수 카운트
        document.addEventListener('DOMContentLoaded', function() {
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
        });

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
</body>
</html>