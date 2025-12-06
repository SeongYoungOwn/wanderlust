<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>동행 신청 관리 - AI 여행 동행 매칭 플랫폼</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            padding-top: 100px;
            background-color: #f8f9fa;
        }
        
        /* Header Styles */
        header {
            background: rgba(253, 251, 247, 0.95);
            backdrop-filter: blur(15px);
            padding: 1rem 0;
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
            transition: all 0.3s ease;
            border-bottom: 1px solid rgba(255, 107, 107, 0.1);
        }
        
        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .logo {
            font-size: 2rem;
            font-weight: 800;
            background: linear-gradient(135deg, #ff6b6b, #ffd93d);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            letter-spacing: -0.02em;
            text-decoration: none;
        }
        
        .nav-links {
            display: flex;
            list-style: none;
            gap: 2.5rem;
            margin: 0;
            padding: 0;
        }
        
        .nav-links a {
            text-decoration: none;
            color: #4a5568;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .nav-links a:hover {
            color: #ff6b6b;
        }
        
        .user-menu {
            position: relative;
        }
        
        .user-dropdown {
            position: absolute;
            top: 100%;
            right: 0;
            background: white;
            border-radius: 0.5rem;
            box-shadow: 0 10px 40px rgba(0,0,0,0.1);
            padding: 0.5rem 0;
            min-width: 200px;
            display: none;
            z-index: 100;
        }
        
        .user-menu:hover .user-dropdown {
            display: block;
        }
        
        .user-dropdown a {
            display: block;
            padding: 0.5rem 1rem;
            color: #4a5568;
            text-decoration: none;
            transition: background-color 0.2s;
        }
        
        .user-dropdown a:hover {
            background-color: #f7fafc;
        }
        
        .user-toggle {
            padding: 0.5rem 1rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 2rem;
            text-decoration: none;
            font-weight: 500;
            transition: transform 0.3s ease;
        }
        
        .user-toggle:hover {
            transform: translateY(-2px);
            color: white;
        }
        
        .request-card {
            border-left: 4px solid #007bff;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .request-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .status-pending {
            border-left-color: #ffc107;
        }
        
        .status-approved {
            border-left-color: #28a745;
        }
        
        .status-rejected {
            border-left-color: #dc3545;
        }
        
        .requester-info {
            background-color: #f8f9fa;
            border-radius: 0.25rem;
            padding: 1rem;
            margin-bottom: 1rem;
        }
        
        .travel-info {
            background-color: #e3f2fd;
            border-radius: 0.25rem;
            padding: 1rem;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <!-- Navigation -->
        <header>
            <nav>
                <a href="${pageContext.request.contextPath}/home" class="logo">Wanderlust</a>
                
                <ul class="nav-links">
                    <li><a href="${pageContext.request.contextPath}/home"><i class="fas fa-home me-1"></i>홈</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel/list"><i class="fas fa-map-marked-alt me-1"></i>여행 계획</a></li>
                    <li><a href="${pageContext.request.contextPath}/board/list"><i class="fas fa-comments me-1"></i>커뮤니티</a></li>
                    <li><a href="${pageContext.request.contextPath}/notice/list"><i class="fas fa-bullhorn me-1"></i>공지사항</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-mbti/test"><i class="fas fa-user-tag me-1"></i>여행 MBTI</a></li>
                    <li><a href="${pageContext.request.contextPath}/ai/chat"><i class="fas fa-robot me-1"></i>AI 플래너</a></li>
                </ul>
                
                <div class="nav-actions">
                    <c:choose>
                        <c:when test="${not empty sessionScope.loginUser}">
                            <div class="user-menu">
                                <a href="#" class="user-toggle">
                                    <i class="fas fa-user me-1"></i>${not empty sessionScope.loginUser.nickname ? sessionScope.loginUser.nickname : sessionScope.loginUser.userName}님
                                </a>
                                <div class="user-dropdown">
                                    <a href="${pageContext.request.contextPath}/member/mypage">
                                        <i class="fas fa-user-circle me-2"></i>마이페이지
                                    </a>
                                    <a href="${pageContext.request.contextPath}/travel-mbti/history">
                                        <i class="fas fa-user-tag me-2"></i>여행 MBTI 기록
                                    </a>
                                    <a href="${pageContext.request.contextPath}/travel/create">
                                        <i class="fas fa-plus-circle me-2"></i>여행 계획 만들기
                                    </a>
                                    <a href="${pageContext.request.contextPath}/board/create">
                                        <i class="fas fa-pen me-2"></i>글쓰기
                                    </a>
                                    <a href="${pageContext.request.contextPath}/member/logout">
                                        <i class="fas fa-sign-out-alt me-2"></i>로그아웃
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/member/login" class="user-toggle">
                                <i class="fas fa-sign-in-alt me-1"></i>로그인
                            </a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </nav>
        </header>

        <!-- Page Header -->
        <div class="container">
            <div class="row mb-4">
                <div class="col-12">
                    <h1 class="h2 mb-3">
                        <i class="fas fa-user-check me-2"></i>
                        <c:choose>
                            <c:when test="${requestType eq 'received'}">받은 동행 신청</c:when>
                            <c:otherwise>보낸 동행 신청</c:otherwise>
                        </c:choose>
                    </h1>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/travel/requests/received" 
                           class="btn ${requestType eq 'received' ? 'btn-primary' : 'btn-outline-primary'}">
                            <i class="fas fa-inbox me-1"></i>받은 신청
                        </a>
                        <a href="${pageContext.request.contextPath}/travel/requests/sent" 
                           class="btn ${requestType eq 'sent' ? 'btn-primary' : 'btn-outline-primary'}">
                            <i class="fas fa-paper-plane me-1"></i>보낸 신청
                        </a>
                    </div>
                </div>
            </div>

            <!-- Messages -->
            <c:if test="${not empty success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i>${success}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Join Requests List -->
            <div class="row">
                <div class="col-12">
                    <c:choose>
                        <c:when test="${empty joinRequests}">
                            <div class="text-center py-5">
                                <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
                                <h5 class="text-muted">
                                    <c:choose>
                                        <c:when test="${requestType eq 'received'}">받은 동행 신청이 없습니다.</c:when>
                                        <c:otherwise>보낸 동행 신청이 없습니다.</c:otherwise>
                                    </c:choose>
                                </h5>
                                <p class="text-muted">
                                    <c:choose>
                                        <c:when test="${requestType eq 'received'}">다른 사용자들이 회원님의 여행 계획에 동행 신청을 하면 여기에 표시됩니다.</c:when>
                                        <c:otherwise>여행 계획에 동행 신청을 하면 여기에 표시됩니다.</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="request" items="${joinRequests}" varStatus="status">
                                <div class="card request-card status-${request.status.toLowerCase()} shadow-sm mb-4">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-lg-8">
                                                <!-- 여행 계획 정보 -->
                                                <div class="travel-info">
                                                    <h6 class="mb-2">
                                                        <i class="fas fa-map-marked-alt me-2"></i>
                                                        <a href="${pageContext.request.contextPath}/travel/detail/${request.travelPlanId}" 
                                                           class="text-decoration-none">
                                                            ${request.travelPlanTitle}
                                                        </a>
                                                        <c:if test="${request.travelCompleted eq true}">
                                                            <span class="badge bg-danger ms-2">
                                                                <i class="fas fa-times-circle me-1"></i>동행 종료
                                                            </span>
                                                        </c:if>
                                                    </h6>
                                                    <p class="mb-1">
                                                        <i class="fas fa-location-dot me-2"></i>
                                                        <strong>목적지:</strong> ${request.travelPlanDestination}
                                                    </p>
                                                    <p class="mb-1">
                                                        <i class="fas fa-calendar me-2"></i>
                                                        <strong>여행 기간:</strong>
                                                        <fmt:formatDate value="${request.travelPlanStartDate}" pattern="yyyy.MM.dd"/> ~ 
                                                        <fmt:formatDate value="${request.travelPlanEndDate}" pattern="yyyy.MM.dd"/>
                                                    </p>
                                                    <p class="mb-0">
                                                        <i class="fas fa-user me-2"></i>
                                                        <strong>작성자:</strong> ${request.planWriterName}
                                                    </p>
                                                </div>

                                                <!-- 신청자/신청 정보 -->
                                                <c:if test="${requestType eq 'received'}">
                                                    <div class="requester-info">
                                                        <h6 class="mb-3">
                                                            <i class="fas fa-user-circle me-2"></i>신청자 정보
                                                        </h6>
                                                        
                                                        <!-- 기본 정보 -->
                                                        <div class="row mb-3">
                                                            <div class="col-6">
                                                                <p class="mb-1">
                                                                    <strong>이름:</strong> ${request.requesterName}
                                                                </p>
                                                                <p class="mb-0">
                                                                    <strong>이메일:</strong> ${request.requesterEmail}
                                                                </p>
                                                            </div>
                                                            <div class="col-6 text-end">
                                                                <!-- 매너 온도 -->
                                                                <div class="manner-temp mb-2">
                                                                    <span class="fs-5" style="color: ${request.requesterTemperatureColor}">
                                                                        ${request.requesterTemperatureIcon} 
                                                                        <fmt:formatNumber value="${request.requesterMannerScore}" pattern="#0.0"/>°C
                                                                    </span>
                                                                    <div class="small text-muted">${request.requesterTemperatureLevel}</div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        
                                                        <!-- 매너 통계 -->
                                                        <div class="manner-stats">
                                                            <h6 class="mb-2 text-muted">
                                                                <i class="fas fa-star me-1"></i>매너 통계
                                                            </h6>
                                                            <div class="row g-2">
                                                                <div class="col-3 text-center">
                                                                    <div class="stat-card p-2 bg-light rounded">
                                                                        <div class="fw-bold text-primary">${request.requesterTotalEvaluations}</div>
                                                                        <div class="small text-muted">받은 평가</div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-3 text-center">
                                                                    <div class="stat-card p-2 bg-light rounded">
                                                                        <div class="fw-bold text-success">${request.requesterTotalLikes}</div>
                                                                        <div class="small text-muted">좋아요</div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-3 text-center">
                                                                    <div class="stat-card p-2 bg-light rounded">
                                                                        <div class="fw-bold text-danger">${request.requesterTotalDislikes}</div>
                                                                        <div class="small text-muted">싫어요</div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-3 text-center">
                                                                    <div class="stat-card p-2 bg-light rounded">
                                                                        <div class="fw-bold text-info">${request.requesterCompletedTravels}</div>
                                                                        <div class="small text-muted">완료한 여행</div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            
                                                            <!-- 좋아요 비율 -->
                                                            <c:if test="${request.requesterTotalEvaluations > 0}">
                                                                <div class="mt-2">
                                                                    <div class="progress" style="height: 6px;">
                                                                        <div class="progress-bar bg-success" 
                                                                             style="width: <fmt:formatNumber value="${request.requesterLikeRatio}" pattern="#0"/>%"
                                                                             title="좋아요 비율: <fmt:formatNumber value="${request.requesterLikeRatio}" pattern="#0.0"/>%">
                                                                        </div>
                                                                    </div>
                                                                    <div class="small text-muted text-center mt-1">
                                                                        좋아요 비율: <fmt:formatNumber value="${request.requesterLikeRatio}" pattern="#0.0"/>%
                                                                    </div>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </c:if>

                                                <!-- 신청 메시지 -->
                                                <div class="mb-3">
                                                    <h6><i class="fas fa-comment-dots me-2"></i>신청 메시지</h6>
                                                    <div class="border rounded p-2 bg-light">
                                                        ${request.requestMessage}
                                                    </div>
                                                </div>

                                                <!-- 응답 메시지 (승인/거절된 경우) -->
                                                <c:if test="${not empty request.responseMessage && request.status ne 'PENDING'}">
                                                    <div class="mb-3">
                                                        <h6>
                                                            <i class="fas fa-reply me-2"></i>
                                                            <c:choose>
                                                                <c:when test="${request.status eq 'APPROVED'}">승인 메시지</c:when>
                                                                <c:otherwise>거절 메시지</c:otherwise>
                                                            </c:choose>
                                                        </h6>
                                                        <div class="border rounded p-2 
                                                             <c:choose>
                                                                 <c:when test='${request.status eq "APPROVED"}'>bg-success bg-opacity-10</c:when>
                                                                 <c:otherwise>bg-danger bg-opacity-10</c:otherwise>
                                                             </c:choose>">
                                                            ${request.responseMessage}
                                                        </div>
                                                    </div>
                                                </c:if>
                                            </div>
                                            
                                            <div class="col-lg-4">
                                                <div class="text-end">
                                                    <!-- 상태 배지 -->
                                                    <div class="mb-3">
                                                        <c:choose>
                                                            <c:when test="${request.status eq 'PENDING'}">
                                                                <span class="badge bg-warning fs-6">
                                                                    <i class="fas fa-clock me-1"></i>대기중
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${request.status eq 'APPROVED'}">
                                                                <span class="badge bg-success fs-6">
                                                                    <i class="fas fa-check me-1"></i>승인됨
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-danger fs-6">
                                                                    <i class="fas fa-times me-1"></i>거절됨
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>

                                                    <!-- 신청일시 -->
                                                    <p class="text-muted small mb-3">
                                                        <i class="fas fa-calendar-alt me-1"></i>
                                                        <fmt:formatDate value="${request.requestDate}" pattern="yyyy.MM.dd HH:mm"/>
                                                    </p>

                                                    <!-- 응답일시 -->
                                                    <c:if test="${not empty request.responseDate}">
                                                        <p class="text-muted small mb-3">
                                                            <i class="fas fa-reply me-1"></i>
                                                            <fmt:formatDate value="${request.responseDate}" pattern="yyyy.MM.dd HH:mm"/>
                                                        </p>
                                                    </c:if>

                                                    <!-- 액션 버튼 (받은 신청이고 PENDING 상태인 경우만) -->
                                                    <c:if test="${requestType eq 'received' && request.status eq 'PENDING'}">
                                                        <div class="d-grid gap-2">
                                                            <button class="btn btn-success btn-sm" 
                                                                    onclick="approveRequest(${request.requestId})">
                                                                <i class="fas fa-check me-1"></i>승인
                                                            </button>
                                                            <button class="btn btn-danger btn-sm" 
                                                                    onclick="rejectRequest(${request.requestId})">
                                                                <i class="fas fa-times me-1"></i>거절
                                                            </button>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Back Button -->
            <div class="text-center mt-4">
                <a href="${pageContext.request.contextPath}/member/mypage" class="btn btn-outline-secondary">
                    <i class="fas fa-arrow-left me-1"></i>마이페이지로 돌아가기
                </a>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-white py-4 mt-5">
            <div class="container text-center">
                <p class="mb-0">&copy; 2024 AI 여행 동행 매칭 플랫폼. All rights reserved.</p>
            </div>
        </footer>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        function approveRequest(requestId) {
            const responseMessage = prompt('승인 메시지를 입력하세요 (선택사항):', '동행 신청이 승인되었습니다. 함께 즐거운 여행 하세요!');
            
            if (responseMessage === null) {
                return; // 취소한 경우
            }
            
            $.ajax({
                url: '${pageContext.request.contextPath}/travel/approve/' + requestId,
                type: 'POST',
                data: {
                    responseMessage: responseMessage
                },
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('승인 처리 중 오류가 발생했습니다.');
                }
            });
        }
        
        function rejectRequest(requestId) {
            const responseMessage = prompt('거절 메시지를 입력하세요 (선택사항):', '죄송합니다. 이번 여행에는 함께할 수 없을 것 같습니다.');
            
            if (responseMessage === null) {
                return; // 취소한 경우
            }
            
            $.ajax({
                url: '${pageContext.request.contextPath}/travel/reject/' + requestId,
                type: 'POST',
                data: {
                    responseMessage: responseMessage
                },
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('거절 처리 중 오류가 발생했습니다.');
                }
            });
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>