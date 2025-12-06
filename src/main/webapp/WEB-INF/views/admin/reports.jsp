<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>신고 관리 - AI 여행 동행 매칭 플랫폼</title>
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
        .admin-sidebar {
            background: var(--bg-secondary) !important;
        }
        .main-content {
            background: var(--bg-primary) !important;
        }
        .card {
            background: var(--bg-card) !important;
            color: var(--text-primary) !important;
        }
        .table {
            color: var(--text-primary) !important;
        }
        .table td, .table th {
            border-color: rgba(255, 107, 107, 0.1) !important;
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
                        <i class="fas fa-exclamation-triangle" style="margin-right: 0.75rem; opacity: 0.9;"></i>
                        신고 관리
                    </h1>
                    <p class="dashboard-subtitle">
                        <i class="fas fa-shield-alt" style="margin-right: 0.5rem; opacity: 0.8;"></i>
                        신고 내역을 확인하고 처리하세요
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
                            <div class="stat-icon" style="background: linear-gradient(135deg, #ff6b6b, #feca57);">
                                <i class="fas fa-exclamation-triangle"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">미처리 신고</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${pendingCount}</div>
                                        <div class="stat-label">미처리</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${todayReports}</div>
                                        <div class="stat-label">오늘</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${weeklyReports}</div>
                                        <div class="stat-label">이번 주</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: linear-gradient(135deg, #4ecdc4, #44a08d);">
                                <i class="fas fa-chart-pie"></i>
                            </div>
                            <div style="flex: 1;">
                                <div class="stat-title">신고 통계</div>
                                <div class="stat-values">
                                    <div class="stat-value">
                                        <div class="stat-number">${totalReports}</div>
                                        <div class="stat-label">전체</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${frequentUsers.size()}</div>
                                        <div class="stat-label">주의사용자</div>
                                    </div>
                                    <div class="stat-value">
                                        <div class="stat-number">${totalCount}</div>
                                        <div class="stat-label">필터 결과</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Content Grid -->
                <div class="content-grid">
                    <!-- 신고 필터 및 목록 -->
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-flag"></i>
                                신고 목록
                            </h3>
                            <!-- 필터 버튼들 -->
                            <div class="btn-group" role="group">
                                <a href="?status=" class="btn btn-sm ${status == '' ? 'btn-primary' : 'btn-outline-primary'}">전체</a>
                                <a href="?status=PENDING" class="btn btn-sm ${status == 'PENDING' ? 'btn-warning' : 'btn-outline-warning'}">미처리</a>
                                <a href="?status=APPROVED" class="btn btn-sm ${status == 'APPROVED' ? 'btn-success' : 'btn-outline-success'}">승인</a>
                                <a href="?status=REJECTED" class="btn btn-sm ${status == 'REJECTED' ? 'btn-danger' : 'btn-outline-danger'}">기각</a>
                                <a href="?status=RESOLVED" class="btn btn-sm ${status == 'RESOLVED' ? 'btn-info' : 'btn-outline-info'}">처리완료</a>
                            </div>
                        </div>
                        <div class="content-card-body">
                            <c:choose>
                                <c:when test="${not empty reportList}">
                                    <c:forEach items="${reportList}" var="report" varStatus="status">
                                        <div class="list-item" onclick="viewReportDetail(${report.reportId})" style="cursor: pointer;">
                                            <div class="list-item-content">
                                                <div class="list-item-title">
                                                    <span class="badge ${report.reportedContentType == 'BOARD' ? 'bg-primary' : 'bg-info'} me-2">
                                                        ${report.reportedContentType == 'BOARD' ? '게시판' : '여행'}
                                                    </span>
                                                    ${fn:length(report.contentTitle) > 30 ? fn:substring(report.contentTitle, 0, 30) : report.contentTitle}${fn:length(report.contentTitle) > 30 ? '...' : ''}
                                                </div>
                                                <div class="list-item-meta">
                                                    <span class="me-3">
                                                        <i class="fas fa-user me-1"></i>
                                                        신고자: ${report.reporterName}
                                                    </span>
                                                    <span class="me-3">
                                                        <i class="fas fa-user-times me-1"></i>
                                                        대상: ${report.reportedUserName}
                                                    </span>
                                                    <span>
                                                        <i class="fas fa-clock me-1"></i>
                                                        <fmt:formatDate value="${report.createdAt}" pattern="yyyy-MM-dd HH:mm"/>
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="list-item-badge">
                                                <span class="badge bg-secondary me-2">${report.categoryKorean}</span>
                                                <c:choose>
                                                    <c:when test="${report.reportStatus == 'PENDING'}">
                                                        <span class="badge bg-warning">미처리</span>
                                                    </c:when>
                                                    <c:when test="${report.reportStatus == 'APPROVED'}">
                                                        <span class="badge bg-success">승인</span>
                                                    </c:when>
                                                    <c:when test="${report.reportStatus == 'REJECTED'}">
                                                        <span class="badge bg-danger">기각</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-info">처리완료</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="empty-state">
                                        <i class="fas fa-inbox fa-3x mb-3" style="opacity: 0.3;"></i>
                                        <p>신고 내역이 없습니다</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            
                            <!-- 페이지네이션 -->
                            <c:if test="${totalPages > 1}">
                                <nav aria-label="Page navigation" class="mt-4">
                                    <ul class="pagination justify-content-center">
                                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                            <a class="page-link" href="?page=${currentPage - 1}&status=${status}">이전</a>
                                        </li>
                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="page-item ${currentPage == i ? 'active' : ''}">
                                                <a class="page-link" href="?page=${i}&status=${status}">${i}</a>
                                            </li>
                                        </c:forEach>
                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                            <a class="page-link" href="?page=${currentPage + 1}&status=${status}">다음</a>
                                        </li>
                                    </ul>
                                </nav>
                            </c:if>
                        </div>
                    </div>

                    <!-- 주의 사용자 목록 -->
                    <c:if test="${not empty frequentUsers}">
                        <div class="content-card">
                            <div class="content-card-header">
                                <h3 class="content-card-title">
                                    <i class="fas fa-user-slash"></i>
                                    신고 다수 접수 사용자
                                </h3>
                            </div>
                            <div class="content-card-body">
                                <c:forEach items="${frequentUsers}" var="user">
                                    <div class="list-item">
                                        <div class="list-item-content">
                                            <div class="list-item-title">${user.user_name}</div>
                                            <div class="list-item-meta">
                                                <span>ID: ${user.reported_user_id}</span>
                                                <span class="ms-3">
                                                    <i class="fas fa-calendar me-1"></i>
                                                    <fmt:formatDate value="${user.last_reported}" pattern="yyyy-MM-dd"/>
                                                </span>
                                            </div>
                                        </div>
                                        <div class="list-item-badge">
                                            <span class="badge bg-warning me-1">${user.report_count}건</span>
                                            <span class="badge bg-danger">${user.approved_count}승인</span>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                </div>
            </main>
        </div>
    </div>

    <!-- Report Detail Modal -->
    <div class="modal fade" id="reportDetailModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">신고 상세 내용</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="reportDetailContent">
                    <!-- AJAX로 로드 -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                    <div id="processButtons">
                        <!-- 처리 버튼들이 동적으로 추가 -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        function viewReportDetail(reportId) {
            $.ajax({
                url: '${pageContext.request.contextPath}/api/reports/' + reportId,
                type: 'GET',
                success: function(response) {
                    if (response.success) {
                        const report = response.report;
                        let html = `
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label fw-bold text-muted">신고자</label>
                                        <p class="mb-0">\${report.reporterName} (\${report.reporterId})</p>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label fw-bold text-muted">신고 대상</label>
                                        <p class="mb-0">\${report.reportedUserName} (\${report.reportedUserId})</p>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted">게시물</label>
                                <p class="mb-0">
                                    <span class="badge bg-\${report.reportedContentType == 'BOARD' ? 'primary' : 'info'} me-2">\${report.reportedContentType == 'BOARD' ? '게시판' : '여행계획'}</span>
                                    \${report.contentTitle}
                                </p>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label fw-bold text-muted">신고 사유</label>
                                        <p class="mb-0"><span class="badge bg-secondary">\${report.categoryKorean}</span></p>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <label class="form-label fw-bold text-muted">현재 상태</label>
                                        <p class="mb-0"><span class="badge bg-\${getStatusColor(report.reportStatus)}">\${report.statusKorean}</span></p>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold text-muted">상세 내용</label>
                                <div class="border rounded p-3 bg-light">
                                    \${report.reportContent}
                                </div>
                            </div>
                        `;
                        
                        if (report.adminComment) {
                            html += `
                                <div class="mb-3">
                                    <label class="form-label fw-bold text-muted">관리자 메모</label>
                                    <div class="border rounded p-3 bg-warning-subtle">
                                        \${report.adminComment}
                                    </div>
                                </div>
                            `;
                        }
                        
                        $('#reportDetailContent').html(html);
                        
                        // 처리 버튼 추가 (미처리 상태인 경우만)
                        if (report.reportStatus === 'PENDING') {
                            $('#processButtons').html(`
                                <button type="button" class="btn btn-success" onclick="processReport(\${reportId}, 'APPROVED')">
                                    <i class="fas fa-check me-1"></i>승인
                                </button>
                                <button type="button" class="btn btn-danger" onclick="processReport(\${reportId}, 'REJECTED')">
                                    <i class="fas fa-times me-1"></i>기각
                                </button>
                            `);
                        } else {
                            $('#processButtons').empty();
                        }
                        
                        $('#reportDetailModal').modal('show');
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('신고 정보를 불러오는데 실패했습니다.');
                }
            });
        }
        
        function processReport(reportId, status) {
            const adminComment = prompt('처리 메모를 입력하세요 (선택사항):');
            
            if (confirm(status === 'APPROVED' ? '이 신고를 승인하시겠습니까?' : '이 신고를 기각하시겠습니까?')) {
                $.ajax({
                    url: '${pageContext.request.contextPath}/api/reports/' + reportId + '/process',
                    type: 'POST',
                    data: {
                        status: status,
                        adminComment: adminComment || ''
                    },
                    success: function(response) {
                        if (response.success) {
                            alert(response.message);
                            $('#reportDetailModal').modal('hide');
                            location.reload();
                        } else {
                            alert(response.message);
                        }
                    },
                    error: function() {
                        alert('처리 중 오류가 발생했습니다.');
                    }
                });
            }
        }
        
        function getStatusColor(status) {
            switch(status) {
                case 'PENDING': return 'warning';
                case 'APPROVED': return 'success';
                case 'REJECTED': return 'danger';
                case 'RESOLVED': return 'info';
                default: return 'secondary';
            }
        }
    </script>
</body>
</html>