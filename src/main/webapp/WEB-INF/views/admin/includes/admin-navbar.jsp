<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Horizontal Admin Navigation Bar -->
<nav class="admin-navbar">
    <div class="navbar-brand">
        <i class="fas fa-crown" style="font-size: 1.5rem; color: #fbbf24;"></i>
        <div>
            <div class="navbar-title">Wanderlust</div>
            <div class="navbar-subtitle">관리자 대시보드</div>
        </div>
    </div>

    <div class="navbar-nav">
        <!-- 대시보드 -->
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/dashboard"
               class="nav-link ${pageContext.request.requestURI.contains('dashboard') ? 'active' : ''}">
                <i class="fas fa-home"></i>
                <span>대시보드</span>
            </a>
        </div>

        <div class="nav-divider"></div>

        <!-- 사용자 관리 -->
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/users"
               class="nav-link ${pageContext.request.requestURI.contains('/users') && !pageContext.request.requestURI.contains('guide') ? 'active' : ''}">
                <i class="fas fa-users"></i>
                <span>회원 관리</span>
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/guide/applications"
               class="nav-link ${pageContext.request.requestURI.contains('guide') ? 'active' : ''}">
                <i class="fas fa-user-check"></i>
                <span>가이드 승인</span>
                <c:if test="${pendingGuideCount > 0}">
                    <span class="badge">${pendingGuideCount}</span>
                </c:if>
            </a>
        </div>

        <div class="nav-divider"></div>

        <!-- 컨텐츠 관리 -->
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/posts"
               class="nav-link ${pageContext.request.requestURI.contains('posts') ? 'active' : ''}">
                <i class="fas fa-newspaper"></i>
                <span>게시판 관리</span>
            </a>
        </div>
        <div class="nav-item">
            <a href="${pageContext.request.contextPath}/admin/reports"
               class="nav-link ${pageContext.request.requestURI.contains('reports') ? 'active' : ''}">
                <i class="fas fa-exclamation-triangle"></i>
                <span>신고 관리</span>
                <c:if test="${pendingReportsCount > 0}">
                    <span class="badge">${pendingReportsCount}</span>
                </c:if>
            </a>
        </div>

        <div class="nav-divider"></div>

        <!-- 통계 -->
        <div class="nav-item">
            <a href="#" class="nav-link">
                <i class="fas fa-chart-line"></i>
                <span>통계 분석</span>
            </a>
        </div>
    </div>

    <div class="navbar-right">
        <a href="${pageContext.request.contextPath}/" class="nav-link">
            <i class="fas fa-arrow-left"></i>
            <span>메인 사이트</span>
        </a>
    </div>
</nav>