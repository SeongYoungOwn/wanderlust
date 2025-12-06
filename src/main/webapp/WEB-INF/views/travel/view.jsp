<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>${travel.title} - AI 여행 동행 매칭 플랫폼</title>
    <style>
        .travel-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 0;
            margin-bottom: 30px;
        }
        .info-card {
            background: white;
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .participant-card {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 10px;
            transition: all 0.3s;
        }
        .participant-card:hover {
            background: #e9ecef;
            transform: translateX(5px);
        }
        .join-button {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 1.1rem;
            font-weight: bold;
            transition: all 0.3s;
        }
        .join-button:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.4);
        }
        .leave-button {
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            font-size: 1.1rem;
            font-weight: bold;
            transition: all 0.3s;
        }
        .leave-button:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(220, 53, 69, 0.4);
        }
        .full-badge {
            background: #6c757d;
            color: white;
            padding: 10px 20px;
            border-radius: 20px;
            font-size: 1rem;
        }
        .detail-label {
            font-weight: bold;
            color: #495057;
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>
    <div class="container-fluid" style="padding-top: 100px;">

        <!-- Travel Header -->
        <div class="travel-header">
            <div class="container">
                <h1 class="display-5">${travel.title}</h1>
                <p class="lead mb-3">
                    <i class="fas fa-map-marker-alt me-2"></i>${travel.destination}
                </p>
                <p class="mb-0">
                    <i class="fas fa-user me-2"></i>작성자: ${travel.userName}
                </p>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container">
            <div class="row">
                <!-- 여행 정보 -->
                <div class="col-lg-8">
                    <div class="info-card">
                        <h3 class="mb-4"><i class="fas fa-info-circle me-2"></i>여행 정보</h3>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <p class="detail-label">여행 기간</p>
                                <p>
                                    <i class="fas fa-calendar-alt me-2"></i>
                                    <fmt:formatDate value="${travel.startDate}" pattern="yyyy년 MM월 dd일"/> ~ 
                                    <fmt:formatDate value="${travel.endDate}" pattern="yyyy년 MM월 dd일"/>
                                </p>
                            </div>
                            <div class="col-md-6">
                                <p class="detail-label">모집 인원</p>
                                <p>
                                    <i class="fas fa-users me-2"></i>
                                    ${travel.participantCount} / ${travel.maxParticipants}명
                                </p>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <p class="detail-label">여행 설명</p>
                            <p>${travel.description}</p>
                        </div>
                    </div>
                    
                    <!-- 참여자 목록 -->
                    <div class="info-card">
                        <h3 class="mb-4">
                            <i class="fas fa-users me-2"></i>참여자 목록 
                            <span class="badge bg-primary">${travel.participantCount}명</span>
                        </h3>
                        
                        <c:if test="${empty participants}">
                            <p class="text-muted">아직 참여자가 없습니다. 첫 번째 참여자가 되어보세요!</p>
                        </c:if>
                        
                        <c:forEach var="participant" items="${participants}">
                            <div class="participant-card">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <i class="fas fa-user-circle me-2"></i>
                                        <strong>${participant.userName}</strong>
                                        <c:if test="${travel.userId == participant.userId}">
                                            <span class="badge bg-warning ms-2">주최자</span>
                                        </c:if>
                                    </div>
                                    <small class="text-muted">
                                        참여일: <fmt:formatDate value="${participant.joinedDate}" pattern="yyyy.MM.dd"/>
                                    </small>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
                
                <!-- 참여 버튼 -->
                <div class="col-lg-4">
                    <div class="info-card text-center">
                        <h4 class="mb-4">여행 참여하기</h4>
                        
                        <div class="mb-4">
                            <div class="progress" style="height: 25px;">
                                <div class="progress-bar bg-success" role="progressbar" 
                                     style="width: ${(travel.participantCount / travel.maxParticipants) * 100}%">
                                    ${travel.participantCount} / ${travel.maxParticipants}
                                </div>
                            </div>
                        </div>
                        
                        <c:choose>
                            <c:when test="${empty sessionScope.loginUser}">
                                <p class="text-muted mb-3">여행에 참여하려면 로그인이 필요합니다.</p>
                                <a href="${pageContext.request.contextPath}/member/login" class="btn btn-primary">
                                    <i class="fas fa-sign-in-alt me-2"></i>로그인하기
                                </a>
                            </c:when>
                            <c:when test="${travel.userId == sessionScope.loginUser.userId}">
                                <p class="text-muted">내가 만든 여행 계획입니다.</p>
                                <a href="${pageContext.request.contextPath}/travel/edit/${travel.travelId}" 
                                   class="btn btn-warning">
                                    <i class="fas fa-edit me-2"></i>수정하기
                                </a>
                            </c:when>
                            <c:when test="${travel.participantCount >= travel.maxParticipants && !travel.joined}">
                                <span class="full-badge">
                                    <i class="fas fa-user-slash me-2"></i>모집 완료
                                </span>
                            </c:when>
                            <c:when test="${travel.joined}">
                                <p class="text-success mb-3">
                                    <i class="fas fa-check-circle me-2"></i>이미 참여한 여행입니다.
                                </p>
                                <button class="leave-button" onclick="leaveTravel(${travel.travelId})">
                                    <i class="fas fa-user-minus me-2"></i>참여 취소
                                </button>
                            </c:when>
                            <c:otherwise>
                                <p class="mb-3">이 여행에 함께 하시겠습니까?</p>
                                <button class="join-button" onclick="joinTravel(${travel.travelId})">
                                    <i class="fas fa-user-plus me-2"></i>참여하기
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    
                    <div class="info-card text-center">
                        <a href="${pageContext.request.contextPath}/travel/list" class="btn btn-outline-secondary">
                            <i class="fas fa-list me-2"></i>목록으로
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        function joinTravel(travelId) {
            if (!confirm('이 여행에 참여하시겠습니까?')) {
                return;
            }
            
            $.ajax({
                url: '${pageContext.request.contextPath}/travel/join/' + travelId,
                type: 'POST',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('참여 처리 중 오류가 발생했습니다.');
                }
            });
        }
        
        function leaveTravel(travelId) {
            if (!confirm('정말로 참여를 취소하시겠습니까?')) {
                return;
            }
            
            $.ajax({
                url: '${pageContext.request.contextPath}/travel/leave/' + travelId,
                type: 'POST',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('참여 취소 처리 중 오류가 발생했습니다.');
                }
            });
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>