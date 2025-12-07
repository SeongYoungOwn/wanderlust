<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>관리자 대시보드 - AI 여행 동행 매칭 플랫폼</title>
    <!-- Pretendard Font -->
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css" />
    <!-- Admin CSS Files -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-dashboard-new.css">
</head>
<body>
    <div class="container-fluid p-0">
        <!-- Include Admin Navigation Bar -->
        <%@ include file="includes/admin-navbar-new.jsp" %>

        <div class="admin-container">
            
            <!-- Main Content -->
            <main class="admin-main">
                <div class="dashboard-header">
                    <h1 class="dashboard-title">
                        <i class="fas fa-tachometer-alt" style="margin-right: 0.75rem; opacity: 0.9;"></i>
                        관리자 대시보드
                    </h1>
                    <p class="dashboard-subtitle">
                        <i class="fas fa-chart-line" style="margin-right: 0.5rem; opacity: 0.8;"></i>
                        실시간 시스템 현황과 주요 지표를 관리하세요
                    </p>
                </div>
                
                <!-- Error Message -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger mb-4">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        ${error}
                    </div>
                </c:if>
                
                

                <!-- Stats Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon members">
                                <i class="fas fa-user-plus"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">신규 가입자</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${newMembersStats.today}</div>
                                        <div class="stat-label">오늘</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${newMembersStats.thisWeek}</div>
                                        <div class="stat-label">이번 주</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${newMembersStats.thisMonth}</div>
                                        <div class="stat-label">이번 달</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon posts">
                                <i class="fas fa-edit"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">새 게시글</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${newPostsStats.today}</div>
                                        <div class="stat-label">오늘</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${newPostsStats.thisWeek}</div>
                                        <div class="stat-label">이번 주</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${newPostsStats.thisMonth}</div>
                                        <div class="stat-label">이번 달</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users">
                                <i class="fas fa-users-cog"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">전체 사용자</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${totalStats.activeMembers}</div>
                                        <div class="stat-label">활성</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${totalStats.suspendedMembers}</div>
                                        <div class="stat-label">정지</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon reports">
                                <i class="fas fa-chart-line"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">콘텐츠 현황</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${totalStats.totalPosts}</div>
                                        <div class="stat-label">게시글</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${totalStats.totalTravelPlans}</div>
                                        <div class="stat-label">여행계획</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: linear-gradient(135deg, #06b6d4, #0891b2);">
                                <i class="fas fa-user-clock"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">활동 현황</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${enhancedStats.activeUsersLastWeek}</div>
                                        <div class="stat-label">주간 활성 사용자</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">
                                            <fmt:formatNumber value="${enhancedStats.averageMannerScore}" pattern="#.#"/>°C
                                        </div>
                                        <div class="stat-label">평균 매너온도</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">주의사항</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${enhancedStats.overdueTravelPlans}</div>
                                        <div class="stat-label">기한초과 여행</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${enhancedStats.suspendedCount}</div>
                                        <div class="stat-label">정지된 계정</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Content Grid -->
                <div class="content-grid">
                    <!-- Low Manner Users -->
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-thermometer-quarter"></i>
                                매너온도 하위 사용자
                            </h3>
                        </div>
                        <div class="content-card-body">
                            <c:choose>
                                <c:when test="${not empty lowMannerUsers}">
                                    <c:forEach var="user" items="${lowMannerUsers}">
                                        <div class="list-item">
                                            <div class="list-item-content">
                                                <div class="list-item-title">${user.nickname} (${user.user_id})</div>
                                                <div class="list-item-meta">
                                                    가입일: <fmt:formatDate value="${user.user_regdate}" pattern="yyyy-MM-dd"/>
                                                </div>
                                            </div>
                                            <div class="list-item-badge badge-warning">
                                                <c:choose>
                                                    <c:when test="${not empty user.manner_score}">
                                                        <fmt:formatNumber value="${user.manner_score}" pattern="#.#"/>°C
                                                    </c:when>
                                                    <c:otherwise>36.5°C</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fas fa-smile-beam fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p>모든 사용자의 매너온도가 양호합니다</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- Most Disliked Posts -->
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-thumbs-down"></i>
                                싫어요 많은 게시글
                            </h3>
                        </div>
                        <div class="content-card-body">
                            <c:choose>
                                <c:when test="${not empty mostDislikedPosts}">
                                    <c:forEach var="post" items="${mostDislikedPosts}">
                                        <div class="list-item">
                                            <div class="list-item-content">
                                                <div class="list-item-title">
                                                    <c:choose>
                                                        <c:when test="${fn:length(post.board_title) > 30}">
                                                            ${fn:substring(post.board_title, 0, 30)}...
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${post.board_title}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="list-item-meta">
                                                    작성자: ${post.board_writer} | 
                                                    작성일: <fmt:formatDate value="${post.board_regdate}" pattern="MM-dd"/>
                                                </div>
                                            </div>
                                            <div class="list-item-badge badge-danger">
                                                <c:choose>
                                                    <c:when test="${not empty post.board_dislikes}">
                                                        ${post.board_dislikes} 싫어요
                                                    </c:when>
                                                    <c:otherwise>0 싫어요</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="list-item-actions" style="display: flex; gap: 0.5rem; margin-left: 1rem;">
                                                <a href="${pageContext.request.contextPath}/board/detail/${post.board_id}" 
                                                   class="btn btn-sm btn-primary" 
                                                   style="font-size: 0.875rem; padding: 0.25rem 0.75rem;">
                                                    <i class="fas fa-eye"></i> 보기
                                                </a>
                                                <form action="${pageContext.request.contextPath}/board/delete/${post.board_id}" 
                                                      method="post" 
                                                      style="display: inline;"
                                                      onsubmit="return confirm('이 게시글을 삭제하시겠습니까?');">
                                                    <button type="submit" 
                                                            class="btn btn-sm btn-danger" 
                                                            style="font-size: 0.875rem; padding: 0.25rem 0.75rem;">
                                                        <i class="fas fa-trash"></i> 삭제
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fas fa-thumbs-up fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p>싫어요를 받은 게시글이 없습니다</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- 추가 관리자 도구 섹션 -->
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-map-marked-alt"></i>
                                인기 여행 목적지 (최근 30일)
                            </h3>
                        </div>
                        <div class="content-card-body">
                            <c:choose>
                                <c:when test="${not empty popularDestinations}">
                                    <c:forEach var="destination" items="${popularDestinations}" varStatus="status">
                                        <div class="list-item">
                                            <div class="list-item-content">
                                                <div class="list-item-title">
                                                    <i class="fas fa-map-pin me-2"></i>
                                                    ${destination.plan_destination}
                                                </div>
                                            </div>
                                            <div class="list-item-badge" style="background: #e0f2fe; color: #0277bd;">
                                                ${destination.count}개 여행계획
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fas fa-globe-asia fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p>최근 여행 계획이 없습니다</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    
                    <!-- 일별 가입자 현황 -->
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-calendar-alt"></i>
                                최근 7일간 신규 가입자
                            </h3>
                        </div>
                        <div class="content-card-body">
                            <c:choose>
                                <c:when test="${not empty dailyNewMembers}">
                                    <c:forEach var="daily" items="${dailyNewMembers}">
                                        <div class="list-item">
                                            <div class="list-item-content">
                                                <div class="list-item-title">
                                                    <i class="fas fa-calendar-day me-2"></i>
                                                    <fmt:formatDate value="${daily.date}" pattern="yyyy-MM-dd (E)"/>
                                                </div>
                                            </div>
                                            <div class="list-item-badge" style="background: #f3e8ff; color: #7c3aed;">
                                                ${daily.count}명 가입
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fas fa-user-plus fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p>최근 신규 가입자가 없습니다</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</body>
</html>