<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>가이드 승인 관리 - 관리자</title>
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

        .application-card {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }

        .status-badge {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 500;
            background: rgba(255, 193, 7, 0.15);
            color: #ffc107;
        }

        .greeting-box {
            background: rgba(33, 150, 243, 0.1);
            padding: 16px;
            border-radius: 8px;
            margin: 16px 0;
            border-left: 4px solid #2196f3;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: 150px 1fr;
            gap: 12px;
            margin-bottom: 16px;
        }

        .detail-label {
            font-weight: 600;
            color: #000000;
        }

        .btn-approve {
            background: linear-gradient(135deg, #4caf50, #45a049);
            color: white;
            border: none;
        }

        .btn-reject {
            background: linear-gradient(135deg, #f44336, #da190b);
            color: white;
            border: none;
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
                    <h1 class="dashboard-title">가이드 승인 관리</h1>
                    <p class="dashboard-subtitle">가이드 신청을 검토하고 승인하세요</p>
                </div>

                <!-- Stats Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon members">
                                <i class="fa-solid fa-clock"></i>
                            </div>
                            <div class="stat-title">대기 중인 신청</div>
                        </div>
                        <div class="stat-values">
                            <div class="stat-value">
                                <div class="stat-number">${applications.size()}</div>
                                <div class="stat-label">건</div>
                            </div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users">
                                <i class="fa-solid fa-user-check"></i>
                            </div>
                            <div class="stat-title">승인된 가이드</div>
                        </div>
                        <div class="stat-values">
                            <div class="stat-value">
                                <div class="stat-number">${approvedGuideCount}</div>
                                <div class="stat-label">명</div>
                            </div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon posts">
                                <i class="fa-solid fa-calendar"></i>
                            </div>
                            <div class="stat-title">이번 달 신청</div>
                        </div>
                        <div class="stat-values">
                            <div class="stat-value">
                                <div class="stat-number">${monthlyApplications}</div>
                                <div class="stat-label">건</div>
                            </div>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon reports">
                                <i class="fa-solid fa-percentage"></i>
                            </div>
                            <div class="stat-title">승인율</div>
                        </div>
                        <div class="stat-values">
                            <div class="stat-value">
                                <div class="stat-number">${approvalRate}%</div>
                                <div class="stat-label">비율</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Applications Section -->
                <div class="content-grid">
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fa-solid fa-list-check"></i>
                                대기 중인 가이드 신청
                            </h3>
                        </div>
                        <div class="content-card-body" style="max-height: none;">`
                        <c:if test="${empty applications}">
                            <div class="alert alert-info">
                                <i class="fa-solid fa-info-circle me-2"></i>
                                현재 대기 중인 가이드 신청이 없습니다.
                            </div>
                        </c:if>

                        <c:forEach items="${applications}" var="app">
                            <div class="application-card" data-application-id="${app.applicationId}">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div>
                                        <h4 class="mb-1">${app.userName}</h4>
                                        <small class="text-muted">
                                            <i class="fa-regular fa-clock me-1"></i>
                                            <fmt:formatDate value="${app.appliedDate}" pattern="yyyy-MM-dd HH:mm"/> 신청
                                        </small>
                                    </div>
                                    <span class="status-badge">
                                        <i class="fa-solid fa-hourglass-half me-1"></i>
                                        승인 대기
                                    </span>
                                </div>

                                <div class="detail-grid">
                                    <span class="detail-label">활동 지역:</span>
                                    <span>${app.region}</span>

                                    <span class="detail-label">상세 주소:</span>
                                    <span>${app.address}</span>

                                    <span class="detail-label">연락처:</span>
                                    <span>${app.phone}</span>

                                    <span class="detail-label">전문 지역:</span>
                                    <span>${app.specialtyRegion}</span>

                                    <span class="detail-label">전문 테마:</span>
                                    <span>${app.specialtyTheme}</span>

                                    <span class="detail-label">특화 영역:</span>
                                    <span>${app.specialtyArea}</span>
                                </div>

                                <div class="greeting-box">
                                    <strong><i class="fa-solid fa-comment me-2"></i>관리자에게 보낸 인사말</strong>
                                    <p class="mt-2 mb-0">${app.greetingMessage}</p>
                                </div>

                                <div class="p-3 rounded" style="background: rgba(255,255,255,0.05);">
                                    <strong><i class="fa-solid fa-user-tie me-2"></i>자기소개</strong>
                                    <p class="mt-2 mb-0">${app.introduction}</p>
                                </div>

                                <div class="mt-3">
                                    <input type="text" class="form-control mb-3 admin-comment"
                                           placeholder="관리자 코멘트 입력 (선택사항)"
                                           style="background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: var(--text-primary);">

                                    <div class="d-flex gap-2">
                                        <button class="btn btn-approve approve-btn" data-id="${app.applicationId}">
                                            <i class="fa-solid fa-check me-2"></i>승인
                                        </button>
                                        <button class="btn btn-reject reject-btn" data-id="${app.applicationId}">
                                            <i class="fa-solid fa-xmark me-2"></i>거절
                                        </button>
                                        <button class="btn btn-outline-primary">
                                            <i class="fa-solid fa-eye me-2"></i>상세 보기
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <%@ include file="../common/footer.jsp" %>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function() {
            // 승인 처리
            $('.approve-btn').on('click', function() {
                var applicationId = $(this).data('id');
                var card = $(this).closest('.application-card');
                var comment = card.find('.admin-comment').val();

                if (confirm('이 가이드 신청을 승인하시겠습니까?')) {
                    $.ajax({
                        url: '${pageContext.request.contextPath}/admin/guide/approve/' + applicationId,
                        method: 'POST',
                        data: { comment: comment },
                        success: function(response) {
                            if (response.success) {
                                alert('승인이 완료되었습니다.');
                                card.fadeOut(function() {
                                    card.remove();
                                    updatePendingCount();
                                });
                            } else {
                                alert('처리 중 오류가 발생했습니다: ' + response.message);
                            }
                        },
                        error: function() {
                            alert('서버 오류가 발생했습니다.');
                        }
                    });
                }
            });

            // 거절 처리
            $('.reject-btn').on('click', function() {
                var applicationId = $(this).data('id');
                var card = $(this).closest('.application-card');
                var comment = card.find('.admin-comment').val();

                if (!comment) {
                    alert('거절 사유를 입력해주세요.');
                    return;
                }

                if (confirm('이 가이드 신청을 거절하시겠습니까?')) {
                    $.ajax({
                        url: '${pageContext.request.contextPath}/admin/guide/reject/' + applicationId,
                        method: 'POST',
                        data: { comment: comment },
                        success: function(response) {
                            if (response.success) {
                                alert('거절 처리되었습니다.');
                                card.fadeOut(function() {
                                    card.remove();
                                    updatePendingCount();
                                });
                            } else {
                                alert('처리 중 오류가 발생했습니다: ' + response.message);
                            }
                        },
                        error: function() {
                            alert('서버 오류가 발생했습니다.');
                        }
                    });
                }
            });

            function updatePendingCount() {
                var count = $('.application-card').length;
                $('.stat-value').first().text(count);

                if (count === 0) {
                    $('.card-body').html('<div class="alert alert-info"><i class="fa-solid fa-info-circle me-2"></i>현재 대기 중인 가이드 신청이 없습니다.</div>');
                }
            }
        });
    </script>
</body>
</html>