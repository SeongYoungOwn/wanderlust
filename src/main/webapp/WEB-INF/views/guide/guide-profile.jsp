<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${guide.userName} 가이드 프로필</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/guide.css" rel="stylesheet">
    <style>
        .profile-header {
            background: var(--primary-gradient);
            color: white;
            padding: 3rem 2rem;
            border-radius: 20px;
            margin-bottom: 2rem;
            box-shadow: var(--shadow-lg);
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
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
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

        .info-section {
            background: white;
            border-radius: var(--border-radius);
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: var(--shadow-sm);
        }

        .info-title {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #e2e8f0;
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
        }

        .review-item {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .reviewer-name {
            font-weight: 600;
            color: var(--text-primary);
        }

        .review-date {
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        .review-rating {
            color: #fbbf24;
            margin-bottom: 0.5rem;
        }

        .badge-list {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
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

        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }

        .gallery-item {
            aspect-ratio: 1;
            border-radius: 10px;
            overflow: hidden;
            background: #f0f0f0;
            cursor: pointer;
            transition: var(--transition);
        }

        .gallery-item:hover {
            transform: scale(1.05);
            box-shadow: var(--shadow-md);
        }

        .gallery-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        /* 쪽지 모달 스타일 */
        .modal-content {
            border-radius: 15px;
            border: none;
        }

        .modal-header {
            background: var(--secondary-gradient);
            border-radius: 15px 15px 0 0;
            border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        }

        .modal-title {
            color: var(--text-primary);
            font-weight: 700;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp" />

    <div class="guide-container">
        <!-- 프로필 헤더 -->
        <div class="profile-header">
            <div class="profile-avatar">
                ${guide.userName.substring(0, 1)}
            </div>
            <h1 class="text-center mb-2">${guide.userName} 가이드</h1>
            <p class="text-center mb-1">
                <i class="bi bi-geo-alt-fill me-1"></i>${guide.region}
            </p>
            <div class="text-center">
                <span class="rating-stars">
                    <c:forEach begin="1" end="5" var="star">
                        <c:choose>
                            <c:when test="${star <= guide.rating}">
                                <i class="bi bi-star-fill"></i>
                            </c:when>
                            <c:when test="${star - 0.5 <= guide.rating}">
                                <i class="bi bi-star-half"></i>
                            </c:when>
                            <c:otherwise>
                                <i class="bi bi-star"></i>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                </span>
                <span class="ms-2">${guide.rating}</span>
            </div>

            <div class="profile-stats">
                <div class="stat-box">
                    <div class="stat-number">${guide.reviewCount > 0 ? guide.reviewCount : 0}</div>
                    <div class="stat-label">리뷰</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">
                        <fmt:formatDate value="${guide.createdDate}" pattern="yyyy"/>
                    </div>
                    <div class="stat-label">가이드 시작</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">
                        <c:choose>
                            <c:when test="${guide.status eq 'active'}">활동중</c:when>
                            <c:when test="${guide.status eq 'inactive'}">휴면</c:when>
                            <c:otherwise>${guide.status}</c:otherwise>
                        </c:choose>
                    </div>
                    <div class="stat-label">상태</div>
                </div>
            </div>

            <div class="action-buttons">
                <button class="btn-submit" onclick="sendMessage(${guide.guideId})">
                    <i class="bi bi-envelope me-2"></i>쪽지 보내기
                </button>
                <button class="btn-cancel" onclick="bookTour(${guide.guideId})">
                    <i class="bi bi-calendar-check me-2"></i>투어 예약
                </button>
            </div>
        </div>

        <!-- 기본 정보 섹션 -->
        <div class="info-section">
            <h3 class="info-title">기본 정보</h3>

            <div class="info-item">
                <i class="bi bi-geo-alt"></i>
                <span>활동 지역: ${guide.region}</span>
            </div>

            <div class="info-item">
                <i class="bi bi-telephone"></i>
                <span>연락처: ${guide.phone}</span>
            </div>

            <div class="info-item">
                <i class="bi bi-envelope"></i>
                <span>이메일: ${guide.userEmail}</span>
            </div>

            <div class="info-item">
                <i class="bi bi-map"></i>
                <span>주소: ${guide.address}</span>
            </div>

            <div class="info-item">
                <i class="bi bi-patch-check"></i>
                <span>가이드 상태:
                    <c:choose>
                        <c:when test="${guide.status eq 'active'}">
                            <span class="badge bg-success">활동중</span>
                        </c:when>
                        <c:when test="${guide.status eq 'inactive'}">
                            <span class="badge bg-secondary">휴면</span>
                        </c:when>
                        <c:otherwise>
                            <span class="badge bg-warning">${guide.status}</span>
                        </c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>

        <!-- 전문 분야 섹션 -->
        <div class="info-section">
            <h3 class="info-title">전문 분야</h3>

            <div class="mb-3">
                <strong>전문 테마</strong>
                <div class="badge-list mt-2">
                    <c:forEach items="${fn:split(guide.specialtyTheme, ',')}" var="theme">
                        <span class="specialty-tag">${theme.trim()}</span>
                    </c:forEach>
                </div>
            </div>

            <div class="mb-3">
                <strong>전문 지역</strong>
                <p class="mt-2">${guide.specialtyRegion}</p>
            </div>

            <div>
                <strong>특화 영역</strong>
                <p class="mt-2">${guide.specialtyArea}</p>
            </div>
        </div>

        <!-- 자기소개 섹션 -->
        <div class="info-section">
            <h3 class="info-title">자기소개</h3>
            <p>${guide.introduction}</p>
        </div>

        <!-- 포트폴리오 갤러리 섹션 -->
        <div class="info-section">
            <h3 class="info-title">포트폴리오</h3>
            <div class="gallery-grid">
                <c:forEach begin="1" end="6" var="i">
                    <div class="gallery-item">
                        <img src="${pageContext.request.contextPath}/resources/images/guide-portfolio-${i}.jpg"
                             alt="포트폴리오 ${i}"
                             onerror="this.parentElement.innerHTML='<div style=\'display:flex;align-items:center;justify-content:center;height:100%;color:#999;\'>이미지 준비중</div>'">
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- 리뷰 섹션 -->
        <div class="info-section">
            <h3 class="info-title">리뷰 (${guide.reviewCount > 0 ? guide.reviewCount : 0})</h3>

            <c:choose>
                <c:when test="${not empty reviews}">
                    <c:forEach items="${reviews}" var="review">
                        <div class="review-item">
                            <div class="review-header">
                                <span class="reviewer-name">${review.userName}</span>
                                <span class="review-date">
                                    <fmt:formatDate value="${review.createdDate}" pattern="yyyy.MM.dd"/>
                                </span>
                            </div>
                            <div class="review-rating">
                                <c:forEach begin="1" end="5" var="star">
                                    <c:choose>
                                        <c:when test="${star <= review.rating}">
                                            <i class="bi bi-star-fill"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="bi bi-star"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </div>
                            <p>${review.content}</p>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p class="text-muted text-center py-3">아직 등록된 리뷰가 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>
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
                        <input type="hidden" id="guideId" name="guideId" value="${guide.guideId}">
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
                    <button type="button" class="btn-cancel" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn-submit" onclick="submitMessage()">보내기</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function sendMessage(guideId) {
            // 로그인 체크
            <c:if test="${empty sessionScope.loginUser}">
                alert('로그인이 필요한 서비스입니다.');
                location.href = '${pageContext.request.contextPath}/member/login';
                return;
            </c:if>

            // 모달 열기
            $('#guideId').val(guideId);
            var messageModal = new bootstrap.Modal(document.getElementById('messageModal'));
            messageModal.show();
        }

        function submitMessage() {
            var formData = {
                receiverId: '${guide.userId}',  // 가이드의 userId 사용
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
                    alert('쪽지 전송에 실패했습니다. 다시 시도해주세요.');
                }
            });
        }

        function bookTour(guideId) {
            // 로그인 체크
            <c:if test="${empty sessionScope.loginUser}">
                alert('로그인이 필요한 서비스입니다.');
                location.href = '${pageContext.request.contextPath}/member/login';
                return;
            </c:if>

            // 투어 예약 페이지로 이동
            location.href = '${pageContext.request.contextPath}/tour/book?guideId=' + guideId;
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>