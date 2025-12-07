<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>사용자 관리 - 관리자 대시보드</title>
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

        /* Enhanced Table Styling */
        .users-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
        }

        .users-table th {
            background: rgba(102, 126, 234, 0.1);
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: var(--text-primary);
            border-bottom: 2px solid rgba(102, 126, 234, 0.3);
            white-space: nowrap;
        }

        .users-table td {
            padding: 1rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            vertical-align: middle;
        }

        .users-table tbody tr:hover {
            background: rgba(102, 126, 234, 0.05);
            transition: background 0.3s ease;
        }

        /* User Info Cell */
        .user-main-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s ease;
        }

        .user-main-info:hover {
            transform: translateX(5px);
        }

        .user-main-info:hover .user-avatar {
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
            transform: scale(1.05);
        }

        .user-main-info:hover .user-name {
            color: #667eea;
        }

        .user-avatar {
            width: 45px;
            height: 45px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.2rem;
            color: white;
            flex-shrink: 0;
            transition: all 0.3s ease;
        }

        .user-text-info {
            display: flex;
            flex-direction: column;
            gap: 0.25rem;
        }

        .user-name {
            font-weight: 600;
            color: var(--text-primary);
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

        .user-id {
            color: #000000;
            font-size: 0.85rem;
        }

        /* Nickname Link */
        a[href*="/profile/view/"]:not(.user-main-info) {
            transition: all 0.2s ease;
            position: relative;
        }

        a[href*="/profile/view/"]:not(.user-main-info):hover {
            color: #667eea !important;
        }

        a[href*="/profile/view/"]:not(.user-main-info):hover::after {
            content: '';
            position: absolute;
            bottom: -2px;
            left: 0;
            width: 100%;
            height: 2px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .user-email {
            color: #000000;
            font-size: 0.85rem;
        }

        /* Statistics Badges */
        .stat-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            margin-right: 0.5rem;
            margin-bottom: 0.3rem;
        }

        .stat-posts {
            background: rgba(46, 213, 115, 0.15);
            color: #2ed573;
        }

        .stat-reports {
            background: rgba(255, 99, 72, 0.15);
            color: #ff6348;
        }

        .stat-comments {
            background: rgba(52, 152, 219, 0.15);
            color: #3498db;
        }

        /* Status Badges */
        .status-badge {
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
            display: inline-block;
        }

        .status-active {
            background: rgba(46, 213, 115, 0.15);
            color: #2ed573;
        }

        .status-suspended {
            background: rgba(255, 71, 87, 0.15);
            color: #ff4757;
        }

        /* Role Badge */
        .role-badge {
            padding: 0.4rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
            display: inline-block;
        }

        .role-admin {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .role-user {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text-primary);
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .btn-sm {
            padding: 0.4rem 0.8rem;
            font-size: 0.85rem;
            border-radius: 6px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-info {
            background: rgba(52, 152, 219, 0.2);
            color: #3498db;
        }

        .btn-info:hover {
            background: rgba(52, 152, 219, 0.3);
        }

        .btn-warning {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
        }

        .btn-warning:hover {
            background: rgba(255, 193, 7, 0.3);
        }

        .btn-success {
            background: rgba(46, 213, 115, 0.2);
            color: #2ed573;
        }

        .btn-success:hover {
            background: rgba(46, 213, 115, 0.3);
        }

        .btn-danger {
            background: rgba(255, 71, 87, 0.2);
            color: #ff4757;
        }

        .btn-danger:hover {
            background: rgba(255, 71, 87, 0.3);
        }

        /* Manner Temperature */
        .manner-temp {
            display: inline-flex;
            align-items: center;
            padding: 0.3rem 0.6rem;
            border-radius: 15px;
            font-size: 0.85rem;
            font-weight: 500;
        }

        .manner-good {
            background: rgba(46, 213, 115, 0.15);
            color: #2ed573;
        }

        .manner-normal {
            background: rgba(255, 193, 7, 0.15);
            color: #ffc107;
        }

        .manner-bad {
            background: rgba(255, 71, 87, 0.15);
            color: #ff4757;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem;
            color: rgba(255, 255, 255, 0.5);
        }

        .empty-state i {
            font-size: 3rem;
            opacity: 0.3;
            margin-bottom: 1rem;
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
                    <h1 class="dashboard-title">
                        <i class="fas fa-users" style="margin-right: 0.75rem; opacity: 0.9;"></i>
                        사용자 관리
                    </h1>
                    <p class="dashboard-subtitle">
                        <i class="fas fa-user-cog" style="margin-right: 0.5rem; opacity: 0.8;"></i>
                        전체 사용자를 조회하고 관리할 수 있습니다
                    </p>
                </div>

                <!-- Search and Filters -->
                <div class="content-grid">
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-search"></i>
                                검색 및 필터
                            </h3>
                        </div>
                        <div class="content-card-body">
                            <form class="search-form" method="GET" style="display: flex; gap: 1rem; align-items: end; flex-wrap: wrap;">
                                <div class="form-group">
                                    <label class="form-label">검색</label>
                                    <input type="text" class="form-control" name="search" value="${search}"
                                           placeholder="ID, 이름, 닉네임, 이메일 검색">
                                </div>
                                <div class="form-group" style="flex: 0 0 150px;">
                                    <label class="form-label">정렬 기준</label>
                                    <select class="form-control" name="orderBy">
                                        <option value="user_regdate" ${orderBy == 'user_regdate' ? 'selected' : ''}>가입일</option>
                                        <option value="manner_temperature" ${orderBy == 'manner_temperature' ? 'selected' : ''}>매너온도</option>
                                        <option value="user_id" ${orderBy == 'user_id' ? 'selected' : ''}>사용자ID</option>
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
                                <div class="form-group" style="flex: 0 0 150px;">
                                    <label class="form-label">상태 필터</label>
                                    <select class="form-control" name="statusFilter">
                                        <option value="">전체</option>
                                        <option value="ACTIVE" ${statusFilter == 'ACTIVE' ? 'selected' : ''}>정상</option>
                                        <option value="SUSPENDED" ${statusFilter == 'SUSPENDED' ? 'selected' : ''}>정지</option>
                                    </select>
                                </div>
                                <div style="flex: 0 0 auto;">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-search me-1"></i> 검색
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Users Table -->
                <div class="content-grid">
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-users"></i>
                                사용자 목록 (총 ${totalUsers}명)
                            </h3>
                        </div>
                        <div class="content-card-body" style="max-height: none; overflow-x: auto;">
                            <!-- 디버깅: users 리스트 크기: ${fn:length(users)} -->
                            <c:choose>
                                <c:when test="${not empty users}">
                                    <table class="users-table">
                                        <thead>
                                            <tr>
                                                <th style="min-width: 250px;">사용자 정보</th>
                                                <th>닉네임</th>
                                                <th>이메일</th>
                                                <th>활동 통계</th>
                                                <th>매너온도</th>
                                                <th>가입일</th>
                                                <th>상태</th>
                                                <th>권한</th>
                                                <th style="min-width: 200px;">관리</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="user" items="${users}">
                                                <tr data-user-id="${user.userId}">
                                                    <!-- User Info -->
                                                    <td>
                                                        <a href="${pageContext.request.contextPath}/profile/view/${user.userId}"
                                                           class="user-main-info"
                                                           style="text-decoration: none; color: inherit; cursor: pointer;">
                                                            <div class="user-avatar">
                                                                ${fn:substring(user.nickname != null ? user.nickname : user.userName, 0, 1)}
                                                            </div>
                                                            <div class="user-text-info">
                                                                <div class="user-name">${user.userName}</div>
                                                                <div class="user-id">ID: ${user.userId}</div>
                                                            </div>
                                                        </a>
                                                    </td>

                                                    <!-- Nickname -->
                                                    <td>
                                                        <c:if test="${not empty user.nickname}">
                                                            <a href="${pageContext.request.contextPath}/profile/view/${user.userId}"
                                                               style="color: var(--text-primary); text-decoration: none;">
                                                                ${user.nickname}
                                                            </a>
                                                        </c:if>
                                                        <c:if test="${empty user.nickname}">
                                                            <span style="color: rgba(255,255,255,0.3);">-</span>
                                                        </c:if>
                                                    </td>

                                                    <!-- Email -->
                                                    <td>
                                                        <div class="user-email">${user.userEmail}</div>
                                                    </td>

                                                    <!-- Activity Stats -->
                                                    <td>
                                                        <div style="display: flex; flex-wrap: wrap; gap: 0.3rem;">
                                                            <span class="stat-badge stat-posts">
                                                                <i class="fas fa-pen"></i>
                                                                게시글 ${user.postCount != null ? user.postCount : 0}
                                                            </span>
                                                            <span class="stat-badge stat-comments">
                                                                <i class="fas fa-comment"></i>
                                                                댓글 ${user.commentCount != null ? user.commentCount : 0}
                                                            </span>
                                                            <c:if test="${user.reportedCount != null && user.reportedCount > 0}">
                                                                <span class="stat-badge stat-reports">
                                                                    <i class="fas fa-exclamation-triangle"></i>
                                                                    신고 ${user.reportedCount}
                                                                </span>
                                                            </c:if>
                                                        </div>
                                                    </td>

                                                    <!-- Manner Temperature -->
                                                    <td>
                                                        <div class="manner-temp ${user.mannerTemperature >= 40 ? 'manner-good' : (user.mannerTemperature >= 30 ? 'manner-normal' : 'manner-bad')}">
                                                            <i class="fas fa-thermometer-half"></i>
                                                            <fmt:formatNumber value="${user.mannerTemperature}" pattern="#.#"/>°C
                                                        </div>
                                                    </td>

                                                    <!-- Registration Date -->
                                                    <td>
                                                        <fmt:formatDate value="${user.userRegdate}" pattern="yyyy-MM-dd"/>
                                                    </td>

                                                    <!-- Account Status -->
                                                    <td>
                                                        <span class="status-badge ${user.accountStatus == 'SUSPENDED' ? 'status-suspended' : 'status-active'}">
                                                            <c:choose>
                                                                <c:when test="${user.accountStatus == 'SUSPENDED'}">
                                                                    <i class="fas fa-ban"></i> 정지
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="fas fa-check-circle"></i> 정상
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>

                                                    <!-- Role -->
                                                    <td>
                                                        <span class="role-badge ${user.userRole == 'ADMIN' ? 'role-admin' : 'role-user'}">
                                                            <c:choose>
                                                                <c:when test="${user.userRole == 'ADMIN'}">
                                                                    <i class="fas fa-crown"></i> 관리자
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="fas fa-user"></i> 일반
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </td>

                                                    <!-- Actions -->
                                                    <td>
                                                        <div class="action-buttons">
<!-- Account Status Toggle -->
                                                            <c:choose>
                                                                <c:when test="${user.accountStatus == 'SUSPENDED'}">
                                                                    <button class="btn btn-success btn-sm" onclick="activateUser('${user.userId}')">
                                                                        <i class="fas fa-check"></i> 복구
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:if test="${user.userId != 'admin' && user.userId != sessionScope.loginUser.userId}">
                                                                        <button class="btn btn-warning btn-sm" onclick="suspendUser('${user.userId}')">
                                                                            <i class="fas fa-pause"></i> 정지
                                                                        </button>
                                                                    </c:if>
                                                                </c:otherwise>
                                                            </c:choose>

                                                            <!-- Delete -->
                                                            <c:if test="${user.userId != 'admin' && user.userId != sessionScope.loginUser.userId}">
                                                                <button class="btn btn-danger btn-sm" onclick="deleteUser('${user.userId}', '${user.nickname != null ? user.nickname : user.userName}')">
                                                                    <i class="fas fa-trash"></i> 삭제
                                                                </button>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fas fa-users"></i>
                                        <h3>사용자가 없습니다</h3>
                                        <p>검색 조건을 변경해보세요</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Pagination -->
                <c:if test="${totalPages > 1}">
                    <div class="pagination-section">
                        <div class="pagination-info">
                            총 ${totalUsers}명 중 ${(currentPage-1)*20 + 1} - ${currentPage*20 > totalUsers ? totalUsers : currentPage*20}명 표시
                        </div>

                        <div class="pagination">
                            <c:if test="${currentPage > 1}">
                                <a href="?page=${currentPage-1}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}&statusFilter=${statusFilter}"
                                   class="page-link">
                                    <i class="fas fa-chevron-left"></i>
                                </a>
                            </c:if>

                            <c:forEach begin="${currentPage > 3 ? currentPage - 2 : 1}"
                                       end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}"
                                       var="page">
                                <a href="?page=${page}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}&statusFilter=${statusFilter}"
                                   class="page-link ${page == currentPage ? 'active' : ''}">
                                    ${page}
                                </a>
                            </c:forEach>

                            <c:if test="${currentPage < totalPages}">
                                <a href="?page=${currentPage+1}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}&statusFilter=${statusFilter}"
                                   class="page-link">
                                    <i class="fas fa-chevron-right"></i>
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:if>

            </main>
        </div>
    </div>

    <%@ include file="../common/footer.jsp" %>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // View user detail
        function viewUserDetail(userId) {
            window.location.href = '${pageContext.request.contextPath}/admin/users/' + userId;
        }

        // Suspend user
        function suspendUser(userId) {
            if (confirm('이 사용자를 정지하시겠습니까?')) {
                updateUserStatus(userId, 'SUSPENDED');
            }
        }

        // Activate user
        function activateUser(userId) {
            if (confirm('이 사용자의 정지를 해제하시겠습니까?')) {
                updateUserStatus(userId, 'ACTIVE');
            }
        }

        // Update user status
        function updateUserStatus(userId, status) {
            fetch('${pageContext.request.contextPath}/admin/users/' + userId + '/status', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'status=' + status
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    location.reload();
                } else {
                    alert('오류: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('요청 처리 중 오류가 발생했습니다.');
            });
        }

        // Delete user
        function deleteUser(userId, userNickname) {
            if (confirm('사용자 "' + userNickname + '"를 완전히 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없으며, 해당 사용자의 모든 데이터가 영구적으로 삭제됩니다.')) {
                if (confirm('정말로 삭제하시겠습니까? 한번 더 확인합니다.')) {
                    fetch('${pageContext.request.contextPath}/admin/users/' + userId + '/delete', {
                        method: 'POST'
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            alert(data.message);
                            location.reload();
                        } else {
                            alert('오류: ' + data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        alert('요청 처리 중 오류가 발생했습니다.');
                    });
                }
            }
        }
    </script>
</body>
</html>