<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>가이드 목록 - AI 여행 동행 매칭 플랫폼</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/guide-simple.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp" />

    <!-- Page Header -->
    <div class="page-header">
        <div class="header-glow"></div>
        <div class="header-glow"></div>
        <div class="container text-center">
            <h1 class="page-title">
                <i class="bi bi-person-badge"></i> 전문 가이드
            </h1>
            <p class="page-subtitle">여행을 더욱 특별하게 만들어줄 전문 가이드를 만나보세요</p>
        </div>
    </div>

    <div class="container travel-section">
        <!-- Filter Section -->
        <div class="search-card mb-4">
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
                        <button type="submit" class="primary-button me-2">
                            <i class="bi bi-search"></i> 검색
                        </button>
                        <a href="${pageContext.request.contextPath}/guide/list" class="btn btn-outline-secondary">초기화</a>
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
                                        <c:choose>
                                            <c:when test="${not empty guide.specialtyTheme and guide.specialtyTheme != '정보 없음'}">
                                                <c:forEach items="${fn:split(guide.specialtyTheme, ',')}" var="theme">
                                                    <span class="badge bg-info me-1">${theme.trim()}</span>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">정보 없음</span>
                                            </c:otherwise>
                                        </c:choose>
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
                                        <c:set var="safeRegion" value="${empty guide.region ? '정보 없음' : guide.region}" />
                                        <c:set var="safeAddress" value="${empty guide.address ? '정보 없음' : guide.address}" />
                                        <c:set var="safePhone" value="${empty guide.phone ? '정보 없음' : guide.phone}" />
                                        <c:set var="safeSpecialtyRegion" value="${empty guide.specialtyRegion ? '정보 없음' : guide.specialtyRegion}" />
                                        <c:set var="safeSpecialtyTheme" value="${empty guide.specialtyTheme ? '정보 없음' : guide.specialtyTheme}" />
                                        <c:set var="safeSpecialtyArea" value="${empty guide.specialtyArea ? '정보 없음' : guide.specialtyArea}" />
                                        <c:set var="safeIntroduction" value="${empty guide.introduction ? '소개 내용이 없습니다.' : guide.introduction}" />
                                        <button class="primary-button w-100 mb-2"
                                                data-guide-id="${guide.guideId}"
                                                data-user-id="${guide.userId}"
                                                data-user-name="${fn:escapeXml(guide.userName)}"
                                                data-region="${fn:escapeXml(safeRegion)}"
                                                data-address="${fn:escapeXml(safeAddress)}"
                                                data-phone="${fn:escapeXml(safePhone)}"
                                                data-specialty-region="${fn:escapeXml(safeSpecialtyRegion)}"
                                                data-specialty-theme="${fn:escapeXml(safeSpecialtyTheme)}"
                                                data-specialty-area="${fn:escapeXml(safeSpecialtyArea)}"
                                                data-introduction="${fn:escapeXml(safeIntroduction)}"
                                                data-rating="${guide.rating}"
                                                data-review-count="${guide.reviewCount}"
                                                onclick="showGuideDetailFromData(this)">
                                            <i class="bi bi-info-circle"></i> 상세보기
                                        </button>
                                        <a href="${pageContext.request.contextPath}/member/profile/${guide.userId}"
                                           class="btn btn-outline-secondary w-100">
                                            <i class="bi bi-person-circle"></i> 프로필
                                        </a>

                                        <!-- 관리자 전용 삭제 버튼 -->
                                        <c:if test="${not empty sessionScope.loginUser && (sessionScope.loginUser.userRole == 'admin' || sessionScope.loginUser.userRole == 'ADMIN')}">
                                            <button onclick="deleteGuide(${guide.guideId}, '${guide.userName}')"
                                                    class="btn btn-danger w-100 mt-2">
                                                <i class="bi bi-trash"></i> 가이드 삭제
                                            </button>
                                        </c:if>
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
                                <button onclick="checkAndRegisterGuide()" class="btn btn-primary">
                                    가이드 신청하기
                                </button>
                            </c:if>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 가이드 신청 버튼 -->
        <div class="text-center mt-5 mb-4">
            <c:choose>
                <c:when test="${empty sessionScope.loginUser}">
                    <button onclick="alert('로그인이 필요한 서비스입니다.'); location.href='${pageContext.request.contextPath}/member/login'" class="primary-button">
                        <i class="bi bi-plus-circle"></i> 가이드 신청
                    </button>
                </c:when>
                <c:when test="${not empty guides}">
                    <c:set var="isAlreadyGuide" value="false" />
                    <c:forEach items="${guides}" var="guide">
                        <c:if test="${sessionScope.loginUser.userId == guide.userId}">
                            <c:set var="isAlreadyGuide" value="true" />
                        </c:if>
                    </c:forEach>
                    <c:choose>
                        <c:when test="${isAlreadyGuide}">
                            <button onclick="alert('이미 가이드로 등록되어 있습니다. 한 계정당 하나의 가이드만 등록 가능합니다.')" class="primary-button" disabled style="opacity: 0.6; cursor: not-allowed;">
                                <i class="bi bi-check-circle"></i> 이미 가이드 등록됨
                            </button>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/guide/register" class="primary-button">
                                <i class="bi bi-plus-circle"></i> 가이드 신청
                            </a>
                        </c:otherwise>
                    </c:choose>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/guide/register" class="primary-button">
                        <i class="bi bi-plus-circle"></i> 가이드 신청
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- 가이드 상세보기 모달 -->
    <div class="modal fade" id="guideDetailModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">가이드 상세 정보</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="guideDetailContent">
                    <!-- 동적으로 내용이 로드됩니다 -->
                    <div class="text-center">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">로딩중...</span>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" id="sendMessageBtn">
                        <i class="bi bi-person-circle"></i> 프로필 보기
                    </button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">닫기</button>
                </div>
            </div>
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
        var currentGuideUserId = null;

        // 가이드 등록 체크 및 등록 페이지 이동
        function checkAndRegisterGuide() {
            <c:if test="${empty sessionScope.loginUser}">
                alert('로그인이 필요한 서비스입니다.');
                location.href = '${pageContext.request.contextPath}/member/login';
                return;
            </c:if>

            // 현재 사용자가 이미 가이드인지 확인
            var isAlreadyGuide = false;
            <c:forEach items="${guides}" var="guide">
                <c:if test="${sessionScope.loginUser.userId == guide.userId}">
                    isAlreadyGuide = true;
                </c:if>
            </c:forEach>

            if (isAlreadyGuide) {
                alert('이미 가이드로 등록되어 있습니다.\n한 계정당 하나의 가이드만 등록 가능합니다.');
                return;
            }

            // 가이드 등록 페이지로 이동
            location.href = '${pageContext.request.contextPath}/guide/register';
        }

        // data- 속성에서 데이터를 읽어 showGuideDetail 호출
        function showGuideDetailFromData(button) {
            const dataset = button.dataset;
            showGuideDetail(
                parseInt(dataset.guideId),
                dataset.userId,
                dataset.userName,
                dataset.region,
                dataset.address,
                dataset.phone,
                dataset.specialtyRegion,
                dataset.specialtyTheme,
                dataset.specialtyArea,
                dataset.introduction,
                parseFloat(dataset.rating),
                parseInt(dataset.reviewCount)
            );
        }

        function showGuideDetail(guideId, userId, userName, region, address, phone, specialtyRegion, specialtyTheme, specialtyArea, introduction, rating, reviewCount) {
            console.log('=== showGuideDetail 호출 ===');
            console.log('region:', region);
            console.log('address:', address);
            console.log('phone:', phone);
            console.log('specialtyRegion:', specialtyRegion);
            console.log('specialtyTheme:', specialtyTheme);
            console.log('specialtyArea:', specialtyArea);
            console.log('introduction:', introduction);

            var modal = new bootstrap.Modal(document.getElementById('guideDetailModal'));
            modal.show();

            // userId를 전역 변수에 저장
            currentGuideUserId = userId;

            // 별점 생성
            var stars = '';
            for (var i = 0; i < 5; i++) {
                if (i < Math.floor(rating)) {
                    stars += '★';
                } else {
                    stars += '☆';
                }
            }

            // 전문 테마 배지 생성
            var themeBadges = '';
            if (specialtyTheme && specialtyTheme !== '정보 없음') {
                var themes = specialtyTheme.split(',');
                var colors = [
                    'linear-gradient(135deg, #ff6b6b, #4ecdc4)',
                    'linear-gradient(135deg, #667eea, #764ba2)',
                    'linear-gradient(135deg, #f093fb, #f5576c)',
                    'linear-gradient(135deg, #11998e, #38ef7d)'
                ];
                themes.forEach(function(theme, index) {
                    var color = colors[index % colors.length];
                    themeBadges += '<span class="badge rounded-pill px-3 py-2 fs-6 me-2" style="background: ' + color + '; color: white;">' + theme.trim() + '</span>';
                });
            } else {
                themeBadges = '<span class="text-muted">정보 없음</span>';
            }

            // 가이드 상세 정보 로드
            $('#guideDetailContent').html(`
                <div class="guide-detail-info">
                    <!-- 상단 프로필 섹션 -->
                    <div class="row mb-4">
                        <div class="col-md-3 text-center">
                            <div class="rounded-circle bg-gradient mx-auto d-flex align-items-center justify-content-center"
                                 style="width: 120px; height: 120px; font-size: 48px; background: linear-gradient(135deg, #ff6b6b, #4ecdc4);">
                                <i class="bi bi-person text-white"></i>
                            </div>
                        </div>
                        <div class="col-md-9">
                            <h3 class="mb-3 fw-bold">${userName} 가이드</h3>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="info-item p-3 rounded-3" style="background: #f8f9fa;">
                                        <small class="text-muted d-block mb-1">평점</small>
                                        <strong class="text-dark fs-6">
                                            <span class="text-warning">${stars}</span> ${rating.toFixed(1)} (리뷰 ${reviewCount}개)
                                        </strong>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="info-item p-3 rounded-3" style="background: #f8f9fa;">
                                        <small class="text-muted d-block mb-1">연락처</small>
                                        <strong class="text-dark fs-6">
                                            <i class="bi bi-telephone-fill text-primary"></i> ` + phone + `
                                        </strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 기본 정보 섹션 -->
                    <div class="mb-4">
                        <h5 class="mb-3 fw-semibold">
                            <i class="bi bi-info-circle-fill text-primary"></i> 기본 정보
                        </h5>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="info-item p-3 rounded-3" style="background: #f8f9fa;">
                                    <small class="text-muted d-block mb-1">활동 지역</small>
                                    <strong class="text-dark">
                                        <i class="bi bi-geo-alt-fill text-danger"></i> ` + region + `
                                    </strong>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-item p-3 rounded-3" style="background: #f8f9fa;">
                                    <small class="text-muted d-block mb-1">상세 주소</small>
                                    <strong class="text-dark">
                                        <i class="bi bi-map-fill text-info"></i> ` + address + `
                                    </strong>
                                </div>
                            </div>
                        </div>
                    </div>

                    <hr class="my-4">

                    <!-- 전문 분야 섹션 -->
                    <div class="mb-4">
                        <h5 class="mb-3 fw-semibold">
                            <i class="bi bi-award-fill text-primary"></i> 전문 분야
                        </h5>

                        <!-- 전문 지역 -->
                        <div class="mb-3 p-3 rounded-3" style="background: #f8f9fa;">
                            <small class="text-muted d-block mb-2"><strong>전문 지역</strong></small>
                            <p class="mb-0 text-dark">` + specialtyRegion + `</p>
                        </div>

                        <!-- 전문 테마 -->
                        <div class="mb-3">
                            <small class="text-muted d-block mb-2"><strong>전문 테마</strong></small>
                            <div class="d-flex flex-wrap gap-2">
                                ` + themeBadges + `
                            </div>
                        </div>

                        <!-- 특화 영역 -->
                        <div class="p-3 rounded-3" style="background: #f8f9fa;">
                            <small class="text-muted d-block mb-2"><strong>특화 영역</strong></small>
                            <p class="mb-0 text-dark">` + specialtyArea + `</p>
                        </div>
                    </div>

                    <hr class="my-4">

                    <!-- 자기소개 섹션 -->
                    <div class="mb-4">
                        <h5 class="mb-3 fw-semibold">
                            <i class="bi bi-person-lines-fill text-primary"></i> 자기소개
                        </h5>
                        <div class="p-3 rounded-3" style="background: #f8f9fa; border-left: 4px solid #ff6b6b;">
                            <p class="mb-0 text-secondary" style="line-height: 1.7; white-space: pre-wrap;">` + introduction + `</p>
                        </div>
                    </div>
                </div>
            `);

            // 쪽지 보내기 버튼 이벤트 설정 - 프로필로 이동
            $('#sendMessageBtn').off('click').on('click', function() {
                $('#guideDetailModal').modal('hide');
                if (currentGuideUserId) {
                    // 프로필 페이지로 이동
                    window.location.href = '${pageContext.request.contextPath}/member/profile/' + currentGuideUserId;
                }
            });
        }

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

        // 가이드 삭제 함수 (관리자 전용)
        function deleteGuide(guideId, guideName) {
            if (!confirm(guideName + ' 가이드를 정말 삭제하시겠습니까?\n\n이 작업은 되돌릴 수 없습니다.')) {
                return;
            }

            $.ajax({
                url: '${pageContext.request.contextPath}/guide/delete/' + guideId,
                type: 'POST',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload(); // 페이지 새로고침
                    } else {
                        alert(response.message);
                    }
                },
                error: function(xhr, status, error) {
                    if (xhr.status === 401) {
                        alert('로그인이 필요합니다.');
                        location.href = '${pageContext.request.contextPath}/member/login';
                    } else if (xhr.status === 403) {
                        alert('관리자만 가이드를 삭제할 수 있습니다.');
                    } else {
                        alert('가이드 삭제 중 오류가 발생했습니다.');
                    }
                }
            });
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>