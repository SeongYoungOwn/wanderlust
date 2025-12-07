<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Admin Navigation Bar -->
<nav class="admin-nav">
    <div class="admin-nav-container">
        <!-- Brand -->
        <div class="admin-nav-brand">
            <div class="admin-nav-logo">
                <i class="fas fa-crown"></i>
            </div>
            <div class="admin-nav-title">
                <h1>Wanderlust Admin</h1>
                <span>관리자 대시보드</span>
            </div>
        </div>

        <!-- Mobile Toggle -->
        <button class="admin-nav-mobile-toggle" id="adminNavToggle">
            <i class="fas fa-bars"></i>
        </button>

        <!-- Menu -->
        <nav class="admin-nav-menu" id="adminNavMenu">
            <div class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/dashboard"
                   class="admin-nav-link ${pageContext.request.requestURI.contains('dashboard') ? 'active' : ''}">
                    <i class="fas fa-home admin-nav-icon"></i>
                    <span>대시보드</span>
                </a>
            </div>

            <div class="admin-nav-separator"></div>

            <div class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/users"
                   class="admin-nav-link ${pageContext.request.requestURI.contains('/users') && !pageContext.request.requestURI.contains('guide') ? 'active' : ''}">
                    <i class="fas fa-users admin-nav-icon"></i>
                    <span>회원 관리</span>
                </a>
            </div>

            <div class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/guide/applications"
                   class="admin-nav-link ${pageContext.request.requestURI.contains('guide/applications') ? 'active' : ''}">
                    <i class="fas fa-user-check admin-nav-icon"></i>
                    <span>가이드 승인</span>
                    <c:if test="${pendingGuideCount > 0}">
                        <span class="admin-nav-badge">${pendingGuideCount}</span>
                    </c:if>
                </a>
            </div>

            <div class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/guide/history"
                   class="admin-nav-link ${pageContext.request.requestURI.contains('guide/history') ? 'active' : ''}">
                    <i class="fas fa-history admin-nav-icon"></i>
                    <span>가이드 신청 내역</span>
                </a>
            </div>

            <div class="admin-nav-separator"></div>

            <div class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/posts"
                   class="admin-nav-link ${pageContext.request.requestURI.contains('posts') ? 'active' : ''}">
                    <i class="fas fa-newspaper admin-nav-icon"></i>
                    <span>게시판 관리</span>
                </a>
            </div>

            <div class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/reports"
                   class="admin-nav-link ${pageContext.request.requestURI.contains('reports') ? 'active' : ''}">
                    <i class="fas fa-exclamation-triangle admin-nav-icon"></i>
                    <span>신고 관리</span>
                    <c:if test="${pendingReportsCount > 0}">
                        <span class="admin-nav-badge">${pendingReportsCount}</span>
                    </c:if>
                </a>
            </div>

            <div class="admin-nav-separator"></div>

            <div class="admin-nav-item">
                <a href="${pageContext.request.contextPath}/admin/api-settings"
                   class="admin-nav-link ${pageContext.request.requestURI.contains('api-settings') ? 'active' : ''}">
                    <i class="fas fa-key admin-nav-icon"></i>
                    <span>API 설정</span>
                </a>
            </div>

        </nav>

        <!-- Actions -->
        <div class="admin-nav-actions">
            <!-- Admin User Info -->
            <div class="admin-nav-user">
                <div class="admin-nav-avatar">
                    <i class="fas fa-user"></i>
                </div>
                <div class="admin-nav-user-info">
                    <div class="admin-nav-username">관리자</div>
                    <div class="admin-nav-role">Super Admin</div>
                </div>
            </div>

            <!-- Back to Main Site -->
            <a href="${pageContext.request.contextPath}/" class="admin-nav-btn admin-nav-btn-secondary">
                <i class="fas fa-arrow-left"></i>
                <span>메인 사이트</span>
            </a>
        </div>
    </div>
</nav>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const toggle = document.getElementById('adminNavToggle');
    const menu = document.getElementById('adminNavMenu');

    if (toggle && menu) {
        toggle.addEventListener('click', function() {
            menu.classList.toggle('show');
            const icon = this.querySelector('i');
            if (icon.classList.contains('fa-bars')) {
                icon.classList.remove('fa-bars');
                icon.classList.add('fa-times');
            } else {
                icon.classList.remove('fa-times');
                icon.classList.add('fa-bars');
            }
        });
    }
});
</script>