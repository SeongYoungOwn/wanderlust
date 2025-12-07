<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>가이드 목록</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/guide-simple.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp" />

    <!-- Header -->
    <div class="guide-header">
        <div class="container">
            <h1 class="display-4 fw-bold">전문 가이드</h1>
            <p class="lead">여행을 더욱 특별하게 만들어줄 전문 가이드를 만나보세요</p>
        </div>
    </div>

    <div class="container">
        <!-- Filter Section -->
        <div class="card mb-4">
            <div class="card-body">
                <form action="${pageContext.request.contextPath}/guide/list" method="get" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">지역</label>
                        <select name="region" class="form-select">
                            <option value="">전체 지역</option>
                            <option value="서울" <c:if test="${param.region == '서울'}">selected</c:if>>서울</option>
                            <option value="부산" <c:if test="${param.region == '부산'}">selected</c:if>>부산</option>
                            <option value="제주" <c:if test="${param.region == '제주'}">selected</c:if>>제주</option>
                            <option value="경기" <c:if test="${param.region == '경기'}">selected</c:if>>경기</option>
                            <option value="강원" <c:if test="${param.region == '강원'}">selected</c:if>>강원</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">테마</label>
                        <select name="theme" class="form-select">
                            <option value="">전체 테마</option>
                            <option value="역사" <c:if test="${param.theme == '역사'}">selected</c:if>>역사</option>
                            <option value="문화" <c:if test="${param.theme == '문화'}">selected</c:if>>문화</option>
                            <option value="자연" <c:if test="${param.theme == '자연'}">selected</c:if>>자연</option>
                            <option value="미식" <c:if test="${param.theme == '미식'}">selected</c:if>>미식</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">평점</label>
                        <select name="minRating" class="form-select">
                            <option value="">전체</option>
                            <option value="4.5" <c:if test="${param.minRating == '4.5'}">selected</c:if>>4.5점 이상</option>
                            <option value="4.0" <c:if test="${param.minRating == '4.0'}">selected</c:if>>4.0점 이상</option>
                        </select>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary me-2">
                            <i class="bi bi-search"></i> 검색
                        </button>
                        <a href="${pageContext.request.contextPath}/guide/list" class="btn btn-secondary">초기화</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Guide List -->
        <div class="row row-cols-1 row-cols-md-3 g-4">
            <c:choose>
                <c:when test="${not empty guides}">
                    <c:forEach items="${guides}" var="guide">
                        <div class="col">
                            <div class="card h-100 guide-card">
                                <div class="card-body">
                                    <!-- 프로필 헤더 -->
                                    <div class="d-flex align-items-center mb-3">
                                        <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center"
                                             style="width: 60px; height: 60px; font-size: 24px;">
                                            ${fn:substring(guide.userName, 0, 1)}
                                        </div>
                                        <div class="ms-3">
                                            <h5 class="card-title mb-0">${guide.userName}</h5>
                                            <small class="text-muted">
                                                <i class="bi bi-geo-alt-fill"></i> ${guide.region}
                                            </small>
                                        </div>
                                    </div>

                                    <!-- 평점 -->
                                    <div class="mb-2">
                                        <c:forEach begin="1" end="5" var="star">
                                            <c:choose>
                                                <c:when test="${star <= guide.rating}">
                                                    <i class="bi bi-star-fill text-warning"></i>
                                                </c:when>
                                                <c:otherwise>
                                                    <i class="bi bi-star text-warning"></i>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                        <span class="ms-2">${guide.rating}</span>
                                        <span class="text-muted">(리뷰 ${guide.reviewCount}개)</span>
                                    </div>

                                    <!-- 전문 분야 -->
                                    <div class="mb-3">
                                        <c:forEach items="${fn:split(guide.specialtyTheme, ',')}" var="theme">
                                            <span class="badge bg-info me-1">${theme.trim()}</span>
                                        </c:forEach>
                                    </div>

                                    <!-- 소개 -->
                                    <p class="card-text text-muted small">
                                        <c:choose>
                                            <c:when test="${fn:length(guide.introduction) > 100}">
                                                ${fn:substring(guide.introduction, 0, 100)}...
                                            </c:when>
                                            <c:otherwise>
                                                ${guide.introduction}
                                            </c:otherwise>
                                        </c:choose>
                                    </p>

                                    <!-- 액션 버튼 -->
                                    <div class="d-grid gap-2">
                                        <a href="${pageContext.request.contextPath}/member/profile/${guide.userId}"
                                           class="btn btn-outline-primary">
                                            <i class="bi bi-person-circle"></i> 프로필 보기
                                        </a>
                                        <button onclick="sendMessage('${guide.userId}')" class="btn btn-outline-secondary">
                                            <i class="bi bi-envelope"></i> 쪽지 보내기
                                        </button>
                                    </div>

                                    <!-- 내가 등록한 가이드 표시 -->
                                    <c:if test="${sessionScope.loginUser.userId == guide.userId}">
                                        <div class="mt-2 text-center">
                                            <span class="badge bg-success">
                                                <i class="bi bi-check-circle-fill"></i> 내가 등록한 가이드
                                            </span>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="col-12">
                        <div class="alert alert-info text-center">
                            <h4>등록된 가이드가 없습니다</h4>
                            <p>조건을 변경하여 다시 검색해보세요</p>
                            <c:if test="${not empty sessionScope.loginUser}">
                                <a href="${pageContext.request.contextPath}/guide/register" class="btn btn-primary">
                                    가이드 신청하기
                                </a>
                            </c:if>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 가이드 신청 버튼 -->
        <div class="text-center mt-5">
            <a href="${pageContext.request.contextPath}/guide/register" class="btn btn-primary btn-lg">
                <i class="bi bi-plus-circle"></i> 가이드 신청
            </a>
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
                        <input type="hidden" id="guideId" name="guideId">
                        <div class="mb-3">
                            <label for="messageTitle" class="form-label">제목</label>
                            <input type="text" class="form-control" id="messageTitle" required>
                        </div>
                        <div class="mb-3">
                            <label for="messageContent" class="form-label">내용</label>
                            <textarea class="form-control" id="messageContent" rows="5" required></textarea>
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
            <c:if test="${empty sessionScope.loginUser}">
                alert('로그인이 필요한 서비스입니다.');
                location.href = '${pageContext.request.contextPath}/member/login';
                return;
            </c:if>

            $('#guideId').val(userId);
            var messageModal = new bootstrap.Modal(document.getElementById('messageModal'));
            messageModal.show();
        }

        function submitMessage() {
            var formData = {
                receiverId: $('#guideId').val(),
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
                    alert('쪽지 전송에 실패했습니다.');
                }
            });
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>