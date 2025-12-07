<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>${travelPlan.planTitle} - AI 여행 동행 매칭 플랫폼</title>
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --success-gradient: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            --card-shadow: 0 10px 40px rgba(0,0,0,0.1);
            --hover-shadow: 0 20px 60px rgba(0,0,0,0.15);
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --bg-light: #f8f9fa;
            --border-light: rgba(0,0,0,0.08);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(to bottom, #ffffff 0%, #f8f9fa 100%);
            color: var(--text-primary);
            line-height: 1.6;
            padding-top: 80px;
        }

        /* 히어로 섹션 */
        .travel-detail-hero {
            position: relative;
            height: 450px;
            background: var(--primary-gradient);
            overflow: hidden;
            margin-top: -80px;
            padding-top: 80px;
        }

        .hero-image {
            position: absolute;
            width: 100%;
            height: 100%;
            object-fit: cover;
            opacity: 0.3;
            top: 0;
        }

        .hero-content {
            position: relative;
            z-index: 2;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 3rem 0;
            color: white;
        }

        .hero-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            background: rgba(255,255,255,0.2);
            backdrop-filter: blur(10px);
            border-radius: 50px;
            margin-bottom: 1rem;
            font-size: 0.9rem;
            border: 1px solid rgba(255,255,255,0.3);
        }

        .hero-title {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 1rem;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
            animation: fadeInUp 0.6s ease-out;
        }

        .hero-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 2rem;
            margin-top: 1.5rem;
            animation: fadeInUp 0.8s ease-out;
        }

        .hero-meta-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.1rem;
        }

        /* 플로팅 정보 카드 */
        .floating-info-card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: var(--card-shadow);
            margin-top: -80px;
            position: relative;
            z-index: 10;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            animation: slideUp 0.6s ease-out;
        }

        .floating-info-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--hover-shadow);
        }

        /* 통계 카드 */
        .stat-card {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            border-radius: 15px;
            padding: 1.5rem;
            text-align: center;
            transition: transform 0.3s ease;
            cursor: pointer;
        }

        .stat-card:hover {
            transform: scale(1.05);
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .stat-label {
            color: var(--text-secondary);
            font-size: 0.9rem;
            margin-top: 0.5rem;
        }

        /* 태그 스타일 */
        .tag-modern {
            display: inline-block;
            padding: 0.6rem 1.2rem;
            background: white;
            border: 2px solid #e3e8ef;
            border-radius: 25px;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .tag-modern:hover {
            background: var(--primary-gradient);
            color: white;
            border-color: transparent;
            transform: translateY(-2px);
        }

        /* 콘텐츠 섹션 */
        .content-section {
            background: white;
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: transform 0.3s ease;
        }

        .content-section:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.12);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            position: relative;
            padding-left: 1rem;
        }

        .section-title::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 4px;
            height: 24px;
            background: var(--primary-gradient);
            border-radius: 2px;
        }

        /* 참여자 카드 */
        .participant-card {
            display: flex;
            align-items: center;
            padding: 1rem;
            background: var(--bg-light);
            border-radius: 15px;
            margin-bottom: 1rem;
            transition: all 0.3s ease;
        }

        .participant-card:hover {
            background: white;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            transform: translateX(5px);
        }

        .participant-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            background: var(--primary-gradient);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            margin-right: 1rem;
            font-size: 1.2rem;
        }

        .participant-info {
            flex: 1;
        }

        .participant-name {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }

        .participant-mbti {
            display: inline-block;
            padding: 0.2rem 0.5rem;
            background: var(--primary-gradient);
            color: white;
            border-radius: 5px;
            font-size: 0.75rem;
            margin-left: 0.5rem;
        }

        /* 매너 온도 표시 */
        .manner-temp {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
            border-radius: 20px;
            font-weight: 600;
        }

        /* 액션 버튼 */
        .action-btn-primary {
            background: var(--primary-gradient);
            color: white;
            border: none;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-size: 1.1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            width: 100%;
            justify-content: center;
        }

        .action-btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }

        .action-btn-secondary {
            background: white;
            color: var(--text-primary);
            border: 2px solid var(--border-light);
            padding: 1rem 2rem;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            flex: 1;
            justify-content: center;
        }

        .action-btn-secondary:hover {
            border-color: #667eea;
            color: #667eea;
            transform: translateY(-2px);
        }

        .action-btn-danger {
            background: linear-gradient(135deg, #f5576c 0%, #c44569 100%);
            color: white;
            border: none;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-size: 1.1rem;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            width: 100%;
            justify-content: center;
        }

        .action-btn-danger:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(245, 87, 108, 0.4);
        }

        /* 작성자 정보 카드 */
        .writer-card {
            background: linear-gradient(135deg, #667eea15 0%, #764ba215 100%);
            border-radius: 20px;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }

        .writer-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: var(--primary-gradient);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            font-weight: bold;
        }

        .writer-stats {
            display: flex;
            justify-content: space-around;
            padding-top: 1rem;
            margin-top: 1rem;
            border-top: 1px solid var(--border-light);
        }

        .writer-stat {
            text-align: center;
        }

        .writer-stat-number {
            font-size: 1.3rem;
            font-weight: bold;
            color: var(--text-primary);
        }

        .writer-stat-label {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-top: 0.25rem;
        }

        /* 애니메이션 */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .animate-fade-in {
            animation: fadeInUp 0.6s ease-out;
        }

        /* 이미지 오버레이 */
        .image-container {
            position: relative;
            overflow: hidden;
            border-radius: 15px;
            cursor: pointer;
        }

        .image-container img {
            width: 100%;
            height: auto;
            transition: transform 0.3s ease;
        }

        .image-container:hover img {
            transform: scale(1.05);
        }

        .image-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(to top, rgba(0,0,0,0.7) 0%, transparent 50%);
            opacity: 0;
            transition: opacity 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .image-container:hover .image-overlay {
            opacity: 1;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .hero-title {
                font-size: 2rem;
            }

            .hero-meta {
                gap: 1rem;
            }

            .floating-info-card {
                margin-top: -40px;
                padding: 1.5rem;
            }

            .content-section {
                padding: 1.5rem;
            }
        }

        /* 로딩 애니메이션 */
        .skeleton {
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
        }

        @keyframes loading {
            0% {
                background-position: 200% 0;
            }
            100% {
                background-position: -200% 0;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <!-- 히어로 섹션 -->
    <div class="travel-detail-hero">
        <c:if test="${not empty travelPlan.planImage}">
            <img src="${pageContext.request.contextPath}/uploads/${travelPlan.planImage}"
                 alt="여행 이미지" class="hero-image">
        </c:if>
        <div class="hero-content">
            <div class="container">
                <c:if test="${participantCount >= travelPlan.maxParticipants}">
                    <span class="hero-badge">
                        <i class="fas fa-check-circle"></i> 모집 완료
                    </span>
                </c:if>
                <c:if test="${participantCount < travelPlan.maxParticipants}">
                    <span class="hero-badge">
                        <i class="fas fa-fire"></i> 모집중
                    </span>
                </c:if>
                <h1 class="hero-title">${travelPlan.planTitle}</h1>
                <div class="hero-meta">
                    <div class="hero-meta-item">
                        <i class="fas fa-map-marker-alt"></i>
                        <span>${travelPlan.planDestination}</span>
                    </div>
                    <div class="hero-meta-item">
                        <i class="fas fa-calendar"></i>
                        <span>
                            <fmt:formatDate value="${travelPlan.planStartDate}" pattern="yyyy.MM.dd"/> ~
                            <fmt:formatDate value="${travelPlan.planEndDate}" pattern="yyyy.MM.dd"/>
                        </span>
                    </div>
                    <div class="hero-meta-item">
                        <i class="fas fa-users"></i>
                        <span>${participantCount}/${travelPlan.maxParticipants}명</span>
                    </div>
                    <c:if test="${travelPlan.planBudget != null && travelPlan.planBudget > 0}">
                        <div class="hero-meta-item">
                            <i class="fas fa-won-sign"></i>
                            <span><fmt:formatNumber value="${travelPlan.planBudget}" pattern="#,###"/>원</span>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>

    <!-- 플로팅 정보 카드 -->
    <div class="container">
        <div class="floating-info-card">
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number">
                            <c:choose>
                                <c:when test="${travelPlan.planStatus eq 'COMPLETED'}">
                                    완료
                                </c:when>
                                <c:otherwise>
                                    <c:set var="now" value="<%=new java.util.Date()%>"/>
                                    <c:set var="daysLeft" value="${(travelPlan.planStartDate.time - now.time) / (1000*60*60*24)}"/>
                                    <c:choose>
                                        <c:when test="${daysLeft > 0}">
                                            D-<fmt:formatNumber value="${daysLeft}" pattern="0"/>
                                        </c:when>
                                        <c:when test="${daysLeft == 0}">
                                            D-Day
                                        </c:when>
                                        <c:otherwise>
                                            진행중
                                        </c:otherwise>
                                    </c:choose>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="stat-label">출발까지</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number">
                            <fmt:formatNumber value="${(participantCount * 100) / travelPlan.maxParticipants}" pattern="0"/>%
                        </div>
                        <div class="stat-label">모집률</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number">${travelPlan.planViewCount}</div>
                        <div class="stat-label">조회수</div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-number">
                            <fmt:formatNumber value="${writerMannerStats.averageMannerScore}" pattern="0.0"/>°C
                        </div>
                        <div class="stat-label">작성자 매너온도</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 메인 콘텐츠 -->
    <div class="container mt-5">
        <div class="row">
            <!-- 왼쪽 콘텐츠 -->
            <div class="col-lg-8">
                <!-- 여행 스타일 태그 -->
                <c:if test="${not empty travelPlan.planTags}">
                    <div class="content-section animate-fade-in">
                        <h3 class="section-title">여행 스타일</h3>
                        <div class="d-flex flex-wrap gap-2">
                            <c:forEach var="tag" items="${travelPlan.planTags.split(',')}">
                                <span class="tag-modern">#${tag.trim()}</span>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- 여행 계획 상세 -->
                <div class="content-section animate-fade-in">
                    <h3 class="section-title">여행 계획</h3>
                    <c:if test="${not empty travelPlan.planImage && travelPlan.planImage != 'default.jpg'}">
                        <div class="image-container mb-4">
                            <img src="${pageContext.request.contextPath}/uploads/${travelPlan.planImage}"
                                 alt="여행 계획" onclick="openImageModal(this.src)">
                            <div class="image-overlay">
                                <i class="fas fa-expand-alt text-white" style="font-size: 2rem;"></i>
                            </div>
                        </div>
                    </c:if>
                    <div style="line-height: 1.8; color: var(--text-secondary); white-space: pre-wrap;"><c:choose><c:when test="${not empty travelPlan.planContent}">${travelPlan.planContent}</c:when><c:otherwise><p class="text-muted text-center">상세 내용이 없습니다.</p></c:otherwise></c:choose></div>
                </div>
            </div>

            <!-- 오른쪽 사이드바 -->
            <div class="col-lg-4">
                <!-- 작성자 정보 -->
                <div class="content-section animate-fade-in">
                    <h3 class="section-title">여행 리더</h3>
                    <div class="writer-card">
                        <div class="d-flex align-items-center mb-3">
                            <div class="writer-avatar me-3">
                                <c:choose>
                                    <c:when test="${not empty writer.nickname}">
                                        ${writer.nickname.substring(0,2).toUpperCase()}
                                    </c:when>
                                    <c:otherwise>
                                        ${writer.userName.substring(0,2).toUpperCase()}
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <div class="fw-bold">
                                    <a href="${pageContext.request.contextPath}/member/profile/${writer.userId}"
                                       class="text-decoration-none text-dark">
                                        <c:choose>
                                            <c:when test="${not empty writer.nickname}">
                                                ${writer.nickname}
                                            </c:when>
                                            <c:otherwise>
                                                ${writer.userName}
                                            </c:otherwise>
                                        </c:choose>
                                    </a>
                                </div>
                                <div class="d-flex align-items-center gap-2 mt-1">
                                    <c:if test="${not empty writerMbti}">
                                        <span class="participant-mbti">${writerMbti.mbtiType}</span>
                                    </c:if>
                                    <span class="manner-temp">
                                        <i class="fas fa-thermometer-half"></i>
                                        <fmt:formatNumber value="${writerMannerStats.averageMannerScore}" pattern="0.0"/>°C
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="writer-stats">
                            <div class="writer-stat">
                                <div class="writer-stat-number">${writerMannerStats.completedTravels}</div>
                                <div class="writer-stat-label">완료 여행</div>
                            </div>
                            <div class="writer-stat">
                                <div class="writer-stat-number text-success">${writerMannerStats.totalLikes}</div>
                                <div class="writer-stat-label">받은 좋아요</div>
                            </div>
                            <div class="writer-stat">
                                <div class="writer-stat-number" style="color: #ffc107;">
                                    <c:choose>
                                        <c:when test="${writerMannerStats.totalLikes > 0}">
                                            <fmt:formatNumber value="${(writerMannerStats.totalLikes * 100) / (writerMannerStats.totalLikes + writerMannerStats.totalDislikes)}" pattern="0"/>%
                                        </c:when>
                                        <c:otherwise>-</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="writer-stat-label">만족도</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 참여자 목록 -->
                <div class="content-section animate-fade-in">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h3 class="section-title mb-0">참여자</h3>
                        <span class="badge bg-primary px-3 py-2">${participantCount}/${travelPlan.maxParticipants}명</span>
                    </div>

                    <c:choose>
                        <c:when test="${empty participants}">
                            <p class="text-muted text-center">아직 참여한 사람이 없습니다.</p>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="participant" items="${participants}">
                                <div class="participant-card">
                                    <div class="participant-avatar">
                                        <c:choose>
                                            <c:when test="${not empty participant.nickname}">
                                                ${participant.nickname.substring(0,2).toUpperCase()}
                                            </c:when>
                                            <c:otherwise>
                                                ${participant.userName.substring(0,2).toUpperCase()}
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="participant-info">
                                        <div class="participant-name">
                                            <a href="${pageContext.request.contextPath}/member/profile/${participant.userId}"
                                               class="text-decoration-none text-dark">
                                                <c:choose>
                                                    <c:when test="${not empty participant.nickname}">
                                                        ${participant.nickname}
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${participant.userName}
                                                    </c:otherwise>
                                                </c:choose>
                                            </a>
                                            <c:if test="${not empty participantMbtiStats[participant.userId]}">
                                                <span class="participant-mbti">${participantMbtiStats[participant.userId].mbtiType}</span>
                                            </c:if>
                                        </div>
                                        <small class="text-muted">
                                            매너온도 <fmt:formatNumber value="${participantMannerStats[participant.userId].averageMannerScore}" pattern="0.0"/>°C
                                        </small>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- 액션 버튼 -->
                <c:if test="${not empty sessionScope.loginUser}">
                    <c:choose>
                        <c:when test="${sessionScope.loginUser.userId eq travelPlan.planWriter}">
                            <!-- 작성자 버튼 -->
                            <button class="action-btn-primary mb-3" onclick="location.href='${pageContext.request.contextPath}/travel/edit/${travelPlan.planId}'">
                                <i class="fas fa-edit"></i>
                                여행 계획 수정하기
                            </button>

                            <form action="${pageContext.request.contextPath}/travel/delete/${travelPlan.planId}" method="post"
                                  onsubmit="return confirm('정말 삭제하시겠습니까?');" style="margin-bottom: 1rem;">
                                <button type="submit" class="action-btn-danger">
                                    <i class="fas fa-trash"></i>
                                    여행 계획 삭제하기
                                </button>
                            </form>

                            <c:choose>
                                <c:when test="${travelPlan.planStatus eq 'COMPLETED'}">
                                    <!-- 동행 완료됨 - 매너 평가 버튼 표시 -->
                                    <div class="alert alert-success text-center mb-3">
                                        <i class="fas fa-check-circle"></i> 동행이 완료되었습니다
                                    </div>
                                    <button class="action-btn-primary mb-3" style="background: linear-gradient(135deg, #ffd89b 0%, #19547b 100%);"
                                            onclick="location.href='${pageContext.request.contextPath}/manner/evaluate/${travelPlan.planId}'">
                                        <i class="fas fa-star"></i>
                                        매너 평가하기
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <!-- 동행 진행 중 - 종료 버튼 표시 -->
                                    <button class="action-btn-primary mb-3" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);"
                                            onclick="completeTravelPlan(${travelPlan.planId})">
                                        <i class="fas fa-flag-checkered"></i>
                                        동행 종료하기
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                        <c:when test="${sessionScope.loginUser.userRole eq 'ADMIN'}">
                            <!-- 관리자 버튼 (삭제만) -->
                            <form action="${pageContext.request.contextPath}/travel/delete/${travelPlan.planId}" method="post"
                                  onsubmit="return confirm('정말 삭제하시겠습니까?');" style="margin-bottom: 1rem;">
                                <button type="submit" class="action-btn-danger">
                                    <i class="fas fa-trash"></i>
                                    여행 계획 삭제하기 (관리자)
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${userApproved || userJoined}">
                            <div class="alert alert-success text-center mb-3">
                                <i class="fas fa-check-circle"></i> 참여한 동행입니다
                            </div>

                            <!-- 참여자도 동행 완료 시 매너 평가 버튼 표시 -->
                            <c:if test="${travelPlan.planStatus eq 'COMPLETED'}">
                                <button class="action-btn-primary mb-3" style="background: linear-gradient(135deg, #ffd89b 0%, #19547b 100%);"
                                        onclick="location.href='${pageContext.request.contextPath}/manner/evaluate/${travelPlan.planId}'">
                                    <i class="fas fa-star"></i>
                                    매너 평가하기
                                </button>
                            </c:if>
                        </c:when>
                        <c:when test="${userRequestPending}">
                            <div class="alert alert-info text-center mb-3">
                                <i class="fas fa-clock"></i> 신청 대기 중입니다
                            </div>
                        </c:when>
                        <c:otherwise>
                            <button class="action-btn-primary mb-3" onclick="requestJoin(${travelPlan.planId})">
                                <i class="fas fa-user-plus"></i>
                                동행 신청하기
                            </button>
                        </c:otherwise>
                    </c:choose>

                    <!-- 공통 버튼 -->
                    <div class="d-flex gap-2 mb-3">
                        <c:if test="${sessionScope.loginUser.userId ne travelPlan.planWriter}">
                            <c:choose>
                                <c:when test="${userFavorite}">
                                    <button class="action-btn-secondary" onclick="toggleFavorite(${travelPlan.planId}, false)">
                                        <i class="fas fa-heart text-danger"></i> 찜 취소
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <button class="action-btn-secondary" onclick="toggleFavorite(${travelPlan.planId}, true)">
                                        <i class="far fa-heart"></i> 찜하기
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </c:if>
                        <button class="action-btn-secondary" onclick="shareTravel()">
                            <i class="fas fa-share-alt"></i> 공유
                        </button>
                    </div>

                    <!-- 채팅방 버튼 -->
                    <c:set var="canAccessChat" value="${travelPlan.planWriter eq sessionScope.loginUser.userId || userApproved || userJoined}" />
                    <c:if test="${canAccessChat && travelPlan.planStatus ne 'COMPLETED'}">
                        <button class="action-btn-primary" style="background: linear-gradient(135deg, #667eea 0%, #52d3aa 100%);"
                                onclick="location.href='${pageContext.request.contextPath}/chat/room/${travelPlan.planId}'">
                            <i class="fas fa-comments"></i>
                            채팅방 참여하기
                        </button>
                    </c:if>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
        // 동행 신청
        function requestJoin(planId) {
            const requestMessage = prompt('동행 신청 메시지를 입력하세요:', '안녕하세요! 함께 여행하고 싶어서 신청합니다.');

            if (requestMessage === null) {
                return;
            }

            $.ajax({
                url: '${pageContext.request.contextPath}/travel/request/' + planId,
                type: 'POST',
                data: {
                    requestMessage: requestMessage
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
                    alert('동행 신청 처리 중 오류가 발생했습니다.');
                }
            });
        }

        // 찜하기 토글
        function toggleFavorite(planId, isAdd) {
            const url = isAdd
                ? '${pageContext.request.contextPath}/travel/favorite/' + planId
                : '${pageContext.request.contextPath}/travel/unfavorite/' + planId;

            $.ajax({
                url: url,
                type: 'POST',
                success: function(response) {
                    if (response.success) {
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('찜하기 처리 중 오류가 발생했습니다.');
                }
            });
        }

        // 동행 종료
        function completeTravelPlan(planId) {
            if (!confirm('정말로 동행을 종료하시겠습니까?\n종료 후에는 참여자들끼리 매너 평가를 할 수 있습니다.')) {
                return;
            }

            $.ajax({
                url: '${pageContext.request.contextPath}/travel/complete/' + planId,
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
                    alert('동행 종료 처리 중 오류가 발생했습니다.');
                }
            });
        }

        // 공유 기능
        function shareTravel() {
            if (navigator.share) {
                navigator.share({
                    title: '${travelPlan.planTitle}',
                    text: '함께 여행 갈 사람을 찾고 있어요!',
                    url: window.location.href
                }).then(() => {
                    console.log('공유 성공');
                }).catch((error) => {
                    console.log('공유 실패', error);
                });
            } else {
                // 클립보드에 URL 복사
                navigator.clipboard.writeText(window.location.href).then(() => {
                    alert('링크가 복사되었습니다.');
                });
            }
        }

        // 이미지 모달
        function openImageModal(imageSrc) {
            const modal = document.createElement('div');
            modal.className = 'image-modal';
            modal.style.cssText = `
                position: fixed; top: 0; left: 0; width: 100vw; height: 100vh;
                background: rgba(0,0,0,0.9); z-index: 9999; display: flex;
                justify-content: center; align-items: center; cursor: pointer;
                padding: 2rem;
            `;

            const img = document.createElement('img');
            img.src = imageSrc;
            img.style.cssText = `
                max-width: 90%; max-height: 90%; object-fit: contain;
                border-radius: 12px; box-shadow: 0 8px 40px rgba(0,0,0,0.6);
            `;

            modal.appendChild(img);
            document.body.appendChild(modal);

            modal.addEventListener('click', function() {
                document.body.removeChild(modal);
            });

            // ESC 키로 닫기
            document.addEventListener('keydown', function closeOnEsc(e) {
                if (e.key === 'Escape' && document.body.contains(modal)) {
                    document.body.removeChild(modal);
                    document.removeEventListener('keydown', closeOnEsc);
                }
            });
        }

        // 스크롤 애니메이션
        document.addEventListener('DOMContentLoaded', function() {
            const observerOptions = {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            };

            const observer = new IntersectionObserver(function(entries) {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('animate-fade-in');
                    }
                });
            }, observerOptions);

            document.querySelectorAll('.content-section').forEach(el => {
                observer.observe(el);
            });
        });
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>