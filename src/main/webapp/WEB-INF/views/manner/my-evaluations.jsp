<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>내 매너 평가 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        body {
            padding-top: 100px;
            background-color: #fdfbf7;
        }
        
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        
        /* 매너온도 대시보드 스타일 */
        .manner-temperature-dashboard {
            margin-bottom: 2rem;
        }
        
        .temperature-main-card {
            background: white;
            border-radius: 1rem;
            padding: 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            border: 1px solid #f1f5f9;
            text-align: center;
            height: 100%;
        }
        
        .temperature-value {
            font-size: 2.5rem;
            font-weight: 700;
            display: block;
            margin-bottom: 0.5rem;
        }
        
        .temperature-level {
            font-size: 1.1rem;
            font-weight: 500;
            opacity: 0.8;
        }
        
        .temperature-gauge {
            margin: 1.5rem 0;
        }
        
        .gauge-track {
            height: 8px;
            background: #e5e7eb;
            border-radius: 4px;
            position: relative;
            overflow: hidden;
        }
        
        .gauge-fill {
            height: 100%;
            border-radius: 4px;
            transition: all 0.5s ease;
            background: linear-gradient(90deg, #fbbf24, #f59e0b);
        }
        
        .gauge-markers {
            display: flex;
            justify-content: space-between;
            margin-top: 0.5rem;
            font-size: 0.75rem;
            color: #9ca3af;
        }
        
        .user-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 2rem;
            font-size: 0.875rem;
            font-weight: 600;
        }
        
        .evaluation-stats-card {
            background: white;
            border-radius: 1rem;
            padding: 2rem;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            border: 1px solid #f1f5f9;
            height: 100%;
        }
        
        .stat-item {
            text-align: center;
            margin-bottom: 1rem;
        }
        
        .stat-icon {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }
        
        .stat-number {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
        }
        
        .ratio-bar {
            height: 6px;
            background: #e5e7eb;
            border-radius: 3px;
            overflow: hidden;
        }
        
        .ratio-fill {
            height: 100%;
            background: linear-gradient(90deg, #10b981, #059669);
            border-radius: 3px;
            transition: width 0.5s ease;
        }

        .stats-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            padding: 2rem;
            margin-bottom: 2rem;
            text-align: center;
        }
        
        .temperature-display {
            font-size: 3rem;
            font-weight: bold;
            margin: 1rem 0;
        }
        
        .badge-display {
            display: inline-block;
            font-size: 1.2rem;
            padding: 0.5rem 1rem;
            border-radius: 25px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            margin: 0.5rem;
        }
        
        .stat-item {
            text-align: center;
            padding: 1rem;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            color: #667eea;
        }
        
        .evaluation-item {
            background: white;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .evaluation-header {
            display: flex;
            justify-content: between;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .temperature-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.9rem;
            font-weight: bold;
        }
        
        .like-status {
            font-size: 1.2rem;
        }
        
        .like-status.positive {
            color: #10b981;
        }
        
        .like-status.negative {
            color: #ef4444;
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>
    <div class="container-fluid p-0">

        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <h1 class="h2 mb-3">
                    <i class="fas fa-star me-2"></i>내 매너 평가
                </h1>
                <p class="mb-0">나의 여행 매너 점수와 동행자들의 평가를 확인해보세요</p>
            </div>
        </div>

        <!-- Main Content -->
        <div class="container mb-5">
            <c:if test="${not empty error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- 매너온도 대시보드 (당근마켓 스타일) -->
            <div class="manner-temperature-dashboard">
                <div class="row">
                    <!-- 매너온도 메인 표시 -->
                    <div class="col-md-5">
                        <div class="temperature-main-card">
                            <div class="temperature-header">
                                <h4 class="mb-2" style="color: #2d3748;">매너온도</h4>
                                <div class="temperature-main" style="color: ${mannerStats.temperatureColor}">
                                    <span class="temperature-value">
                                        <fmt:formatNumber value="${mannerStats.averageMannerScore}" pattern="#0.0"/>°C
                                    </span>
                                    <span class="temperature-level">${mannerStats.temperatureLevel}</span>
                                </div>
                            </div>
                            
                            <!-- 온도 게이지 -->
                            <div class="temperature-gauge">
                                <div class="gauge-track">
                                    <div class="gauge-fill" 
                                         style="width: <fmt:formatNumber value="${mannerStats.averageMannerScore}" pattern="#0"/>%; 
                                                background-color: ${mannerStats.temperatureColor};">
                                    </div>
                                </div>
                                <div class="gauge-markers">
                                    <span class="marker" style="left: 20%; color: #718096;">20°C</span>
                                    <span class="marker" style="left: 40%; color: #718096;">40°C</span>
                                    <span class="marker" style="left: 60%; color: #718096;">60°C</span>
                                    <span class="marker" style="left: 80%; color: #718096;">80°C</span>
                                </div>
                            </div>
                            
                            <div class="badge-display mt-3">
                                <span class="user-badge">${mannerStats.badgeLevel}</span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 평가 통계 -->
                    <div class="col-md-7">
                        <div class="evaluation-stats-card">
                            <h5 class="mb-3" style="color: #2d3748;">평가 현황</h5>
                            <div class="row mb-3">
                                <div class="col-6 col-md-3">
                                    <div class="stat-item">
                                        <div class="stat-icon">📊</div>
                                        <div class="stat-number">${mannerStats.totalEvaluations}</div>
                                        <small style="color: #718096;">총 평가</small>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="stat-item">
                                        <div class="stat-icon">✈️</div>
                                        <div class="stat-number">${mannerStats.completedTravels}</div>
                                        <small style="color: #718096;">완료 여행</small>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="stat-item positive">
                                        <div class="stat-icon">👍</div>
                                        <div class="stat-number text-success">${mannerStats.totalLikes}</div>
                                        <small style="color: #718096;">긍정 평가</small>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="stat-item negative">
                                        <div class="stat-icon">👎</div>
                                        <div class="stat-number text-warning">${mannerStats.totalDislikes}</div>
                                        <small style="color: #718096;">부정 평가</small>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- 긍정 평가 비율 바 -->
                            <div class="evaluation-ratio">
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="small">긍정 평가 비율</span>
                                    <span class="small font-weight-bold">
                                        <fmt:formatNumber value="${mannerStats.likeRatio}" pattern="#0.0"/>%
                                    </span>
                                </div>
                                <div class="ratio-bar">
                                    <div class="ratio-fill" 
                                         style="width: <fmt:formatNumber value="${mannerStats.likeRatio}" pattern="#0"/>%">
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- 기존 호환성을 위한 숨겨진 정보 -->
            <div style="display: none;">
                <small class="text-muted">
                    좋아요 비율: <fmt:formatNumber value="${mannerStats.likeRatio}" pattern="#0.0"/>%
                        </small>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- 받은 평가 -->
                <div class="col-lg-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="fas fa-inbox me-2"></i>받은 평가 
                                <span class="badge bg-primary">${receivedEvaluations.size()}</span>
                            </h5>
                        </div>
                        <div class="card-body" style="max-height: 600px; overflow-y: auto;">
                            <c:choose>
                                <c:when test="${empty receivedEvaluations}">
                                    <p style="color: #718096;" class="text-center">아직 받은 평가가 없습니다.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="evaluation" items="${receivedEvaluations}">
                                        <div class="evaluation-item">
                                            <div class="evaluation-header">
                                                <div>
                                                    <strong style="color: #2d3748;">익명의 동행자</strong>
                                                    <small style="color: #718096;">from ${evaluation.travelPlanTitle}</small>
                                                </div>
                                                <div class="evaluation-badges">
                                                    <c:if test="${not empty evaluation.evaluationType && not empty evaluation.evaluationCategory}">
                                                        <span class="category-badge ${evaluation.evaluationType == 'POSITIVE' ? 'positive' : 'negative'}">
                                                            <c:choose>
                                                                <c:when test="${evaluation.evaluationType == 'POSITIVE'}">👍</c:when>
                                                                <c:otherwise>👎</c:otherwise>
                                                            </c:choose>
                                                            ${evaluation.evaluationCategory}
                                                        </span>
                                                    </c:if>
                                                    <span class="temperature-badge" style="background-color: ${evaluation.temperatureColor}">
                                                        <fmt:formatNumber value="${evaluation.mannerTemperature}" pattern="#0.0"/>°C
                                                    </span>
                                                    <c:if test="${evaluation.isLike != null}">
                                                        <span class="like-status ${evaluation.isLike ? 'positive' : 'negative'}">
                                                            <i class="fas fa-thumbs-${evaluation.isLike ? 'up' : 'down'}"></i>
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <c:if test="${not empty evaluation.evaluationComment}">
                                                <div class="evaluation-comment">
                                                    <i class="fas fa-quote-left text-muted me-1"></i>
                                                    <em style="color: #718096;">${evaluation.evaluationComment}</em>
                                                    <i class="fas fa-quote-right text-muted ms-1"></i>
                                                </div>
                                            </c:if>
                                            <small style="color: #718096;">
                                                <i class="fas fa-clock me-1"></i>
                                                <fmt:formatDate value="${evaluation.createdDate}" pattern="yyyy.MM.dd HH:mm"/>
                                            </small>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- 내가 한 평가 -->
                <div class="col-lg-6">
                    <div class="card">
                        <div class="card-header">
                            <h5 class="mb-0">
                                <i class="fas fa-paper-plane me-2"></i>내가 한 평가 
                                <span class="badge bg-secondary">${givenEvaluations.size()}</span>
                            </h5>
                        </div>
                        <div class="card-body" style="max-height: 600px; overflow-y: auto;">
                            <c:choose>
                                <c:when test="${empty givenEvaluations}">
                                    <p style="color: #718096;" class="text-center">아직 한 평가가 없습니다.</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="evaluation" items="${givenEvaluations}">
                                        <div class="evaluation-item">
                                            <div class="evaluation-header">
                                                <div>
                                                    <strong style="color: #2d3748;">${evaluation.evaluatedNickname}</strong>
                                                    <small style="color: #718096;">to ${evaluation.travelPlanTitle}</small>
                                                </div>
                                                <div>
                                                    <span class="temperature-badge" style="background-color: ${evaluation.temperatureColor}">
                                                        <fmt:formatNumber value="${evaluation.mannerTemperature}" pattern="#0.0"/>°C
                                                    </span>
                                                    <c:if test="${evaluation.isLike != null}">
                                                        <span class="like-status ${evaluation.isLike ? 'positive' : 'negative'}">
                                                            <i class="fas fa-thumbs-${evaluation.isLike ? 'up' : 'down'}"></i>
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <c:if test="${not empty evaluation.evaluationComment}">
                                                <p class="mb-1" style="color: #718096;">"${evaluation.evaluationComment}"</p>
                                            </c:if>
                                            <small style="color: #718096;">
                                                <fmt:formatDate value="${evaluation.createdDate}" pattern="yyyy.MM.dd HH:mm"/>
                                            </small>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <div class="text-center mt-4">
                <a href="${pageContext.request.contextPath}/member/mypage" class="btn btn-outline-secondary">
                    <i class="fas fa-arrow-left me-2"></i>마이페이지로 돌아가기
                </a>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-white py-4">
            <div class="container text-center">
                <p class="mb-0">&copy; 2024 AI 여행 동행 매칭 플랫폼. All rights reserved.</p>
            </div>
        </footer>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>