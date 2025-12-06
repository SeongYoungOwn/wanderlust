<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${user.userName} 프로필</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --secondary-gradient: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
            --bg-main: #f8f9fa;
            --text-primary: #2d3748;
            --text-secondary: #718096;
            --text-muted: #9ca3af;
            --accent-color: #667eea;
            --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.06);
            --shadow-md: 0 8px 25px rgba(0, 0, 0, 0.08);
            --border-radius: 15px;
        }

        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: var(--bg-main);
            padding-top: 60px;
        }

        .profile-container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .profile-header {
            background: var(--primary-gradient);
            border-radius: 20px;
            padding: 3rem 2rem;
            margin-bottom: 2rem;
            color: white;
            box-shadow: var(--shadow-md);
        }

        .profile-avatar {
            width: 120px;
            height: 120px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            font-weight: bold;
            color: var(--accent-color);
            margin: 0 auto 1.5rem;
        }

        .profile-name {
            font-size: 2rem;
            font-weight: 700;
            text-align: center;
            margin-bottom: 0.5rem;
        }

        .profile-info {
            text-align: center;
            opacity: 0.95;
            margin-bottom: 0.3rem;
        }

        .profile-badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 0.3rem 1rem;
            border-radius: 20px;
            font-size: 0.9rem;
            margin: 0.5rem 0.3rem;
        }

        .profile-stats {
            display: flex;
            justify-content: center;
            gap: 3rem;
            margin-top: 2rem;
        }

        .stat-box {
            text-align: center;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
        }

        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
        }

        .content-section {
            background: white;
            border-radius: var(--border-radius);
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow-sm);
        }

        .section-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #e2e8f0;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
            color: var(--text-secondary);
        }

        .info-item i {
            color: var(--accent-color);
            width: 20px;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }

        .btn-primary-custom {
            background: var(--primary-gradient);
            color: white;
            border: none;
            padding: 0.8rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
            color: white;
        }

        .btn-secondary-custom {
            background: white;
            color: var(--text-primary);
            border: 2px solid #e2e8f0;
            padding: 0.8rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s;
        }

        .btn-secondary-custom:hover {
            background: #f8f9fa;
            border-color: var(--text-secondary);
        }

        .activity-item {
            padding: 1rem;
            background: var(--secondary-gradient);
            border-radius: 10px;
            margin-bottom: 1rem;
            border-left: 3px solid var(--accent-color);
        }

        .activity-date {
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        .guide-badge {
            background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
            color: white;
            padding: 0.5rem 1rem;
            border-radius: 10px;
            display: inline-block;
            font-weight: 600;
            margin-bottom: 1rem;
        }

        .warning-banner {
            background: #fef3c7;
            color: #92400e;
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .warning-banner i {
            color: #f59e0b;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp" />

    <div class="profile-container">
        <!-- 프로필 헤더 -->
        <div class="profile-header">
            <div class="profile-avatar">
                ${user.userName.substring(0, 1)}
            </div>
            <h1 class="profile-name">${user.userName}</h1>

            <!-- 사용자 역할 표시 -->
            <div class="text-center">
                <c:if test="${user.role == 'admin'}">
                    <span class="profile-badge">
                        <i class="bi bi-shield-check me-1"></i>관리자
                    </span>
                </c:if>

                <c:if test="${isGuide}">
                    <span class="profile-badge">
                        <i class="bi bi-award me-1"></i>인증 가이드
                    </span>
                </c:if>

                <span class="profile-badge">
                    <i class="bi bi-person-check me-1"></i>일반 회원
                </span>
            </div>

            <p class="profile-info">
                <i class="bi bi-envelope me-1"></i>${user.userEmail}
            </p>

            <p class="profile-info">
                <i class="bi bi-calendar me-1"></i>가입일: <fmt:formatDate value="${user.joinDate}" pattern="yyyy년 MM월 dd일"/>
            </p>

            <!-- 프로필 통계 -->
            <div class="profile-stats">
                <div class="stat-box">
                    <div class="stat-number">${postCount > 0 ? postCount : 0}</div>
                    <div class="stat-label">작성 게시글</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">${reviewCount > 0 ? reviewCount : 0}</div>
                    <div class="stat-label">작성 리뷰</div>
                </div>
                <c:if test="${isGuide}">
                    <div class="stat-box">
                        <div class="stat-number">${tourCount > 0 ? tourCount : 0}</div>
                        <div class="stat-label">진행 투어</div>
                    </div>
                </c:if>
            </div>

            <!-- 내 프로필인 경우에만 수정 버튼 표시 -->
            <c:if test="${sessionScope.loginUser.userId == user.userId}">
                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/member/mypage" class="btn-primary-custom">
                        <i class="bi bi-pencil-square me-2"></i>프로필 편집
                    </a>
                    <c:if test="${!isGuide}">
                        <a href="${pageContext.request.contextPath}/guide/register" class="btn-secondary-custom">
                            <i class="bi bi-award me-2"></i>가이드 신청
                        </a>
                    </c:if>
                </div>
            </c:if>

            <!-- 다른 사용자 프로필인 경우 -->
            <c:if test="${sessionScope.loginUser.userId != user.userId}">
                <div class="action-buttons">
                    <button onclick="sendMessage(${user.userId})" class="btn-primary-custom">
                        <i class="bi bi-envelope me-2"></i>쪽지 보내기
                    </button>
                    <c:if test="${isGuide}">
                        <a href="${pageContext.request.contextPath}/guide/profile/${guideInfo.guideId}" class="btn-secondary-custom">
                            <i class="bi bi-person-badge me-2"></i>가이드 프로필
                        </a>
                    </c:if>
                </div>
            </c:if>
        </div>

        <!-- 가이드 정보 섹션 (가이드인 경우에만) -->
        <c:if test="${isGuide && not empty guideInfo}">
            <div class="content-section">
                <div class="guide-badge">
                    <i class="bi bi-award me-2"></i>인증된 가이드
                </div>
                <h3 class="section-title">가이드 정보</h3>

                <div class="info-item">
                    <i class="bi bi-geo-alt"></i>
                    <span>활동 지역: ${guideInfo.region}</span>
                </div>

                <div class="info-item">
                    <i class="bi bi-tags"></i>
                    <span>전문 분야: ${guideInfo.specialtyTheme}</span>
                </div>

                <div class="info-item">
                    <i class="bi bi-star-fill"></i>
                    <span>평점: ${guideInfo.rating > 0 ? guideInfo.rating : '아직 평가 없음'}</span>
                </div>

                <div class="info-item">
                    <i class="bi bi-chat-left-text"></i>
                    <span>리뷰: ${guideInfo.reviewCount}개</span>
                </div>

                <c:if test="${sessionScope.loginUser.userId != user.userId}">
                    <div class="mt-3">
                        <a href="${pageContext.request.contextPath}/guide/profile/${guideInfo.guideId}" class="btn-primary-custom">
                            가이드 상세 프로필 보기
                        </a>
                    </div>
                </c:if>
            </div>
        </c:if>

        <!-- 기본 정보 섹션 -->
        <div class="content-section">
            <h3 class="section-title">기본 정보</h3>

            <div class="info-item">
                <i class="bi bi-person"></i>
                <span>이름: ${user.userName}</span>
            </div>

            <div class="info-item">
                <i class="bi bi-envelope"></i>
                <span>이메일: ${user.userEmail}</span>
            </div>

            <div class="info-item">
                <i class="bi bi-telephone"></i>
                <span>연락처: ${not empty user.phone ? user.phone : '비공개'}</span>
            </div>

            <div class="info-item">
                <i class="bi bi-calendar-check"></i>
                <span>가입일: <fmt:formatDate value="${user.joinDate}" pattern="yyyy년 MM월 dd일"/></span>
            </div>
        </div>

        <!-- 최근 활동 섹션 -->
        <div class="content-section">
            <h3 class="section-title">최근 활동</h3>

            <c:choose>
                <c:when test="${not empty activities}">
                    <c:forEach items="${activities}" var="activity">
                        <div class="activity-item">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <strong>${activity.title}</strong>
                                    <p class="mb-0 mt-1">${activity.content}</p>
                                </div>
                                <span class="activity-date">
                                    <fmt:formatDate value="${activity.createdDate}" pattern="yyyy.MM.dd"/>
                                </span>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p class="text-muted text-center py-3">최근 활동 내역이 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 내 프로필이고 가이드 신청 중인 경우 -->
        <c:if test="${sessionScope.loginUser.userId == user.userId && pendingGuideApplication}">
            <div class="warning-banner">
                <i class="bi bi-clock-history"></i>
                <span>가이드 신청이 검토 중입니다. 승인까지 1-2일이 소요될 수 있습니다.</span>
            </div>
        </c:if>
    </div>

    <!-- 쪽지 보내기 모달 -->
    <div class="modal fade" id="messageModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">쪽지 보내기</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="messageForm">
                        <input type="hidden" id="userId" name="userId" value="${user.userId}">
                        <div class="form-group mb-3">
                            <label for="messageTitle" class="form-label">제목</label>
                            <input type="text" class="form-control" id="messageTitle" name="title" required>
                        </div>
                        <div class="form-group">
                            <label for="messageContent" class="form-label">내용</label>
                            <textarea class="form-control" id="messageContent" name="content" rows="5" required></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-primary" onclick="submitMessage()">보내기</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function sendMessage(userId) {
            // 로그인 체크
            <c:if test="${empty sessionScope.loginUser}">
                alert('로그인이 필요한 서비스입니다.');
                location.href = '${pageContext.request.contextPath}/member/login';
                return;
            </c:if>

            // 자기 자신에게는 쪽지를 보낼 수 없음
            if (userId == ${sessionScope.loginUser.userId}) {
                alert('자기 자신에게는 쪽지를 보낼 수 없습니다.');
                return;
            }

            // 모달 열기
            $('#userId').val(userId);
            var messageModal = new bootstrap.Modal(document.getElementById('messageModal'));
            messageModal.show();
        }

        function submitMessage() {
            var formData = {
                receiverId: $('#userId').val(),
                messageTitle: $('#messageTitle').val(),
                messageContent: $('#messageContent').val()
            };

            $.ajax({
                url: '${pageContext.request.contextPath}/message/send',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(formData),
                success: function(response) {
                    alert('쪽지를 성공적으로 전송했습니다.');
                    $('#messageModal').modal('hide');
                    $('#messageForm')[0].reset();
                },
                error: function(xhr, status, error) {
                    if (xhr.status === 404) {
                        alert('쪽지 기능은 아직 구현 중입니다.');
                    } else {
                        alert('쪽지 전송에 실패했습니다. 다시 시도해주세요.');
                    }
                }
            });
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>