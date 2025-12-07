<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>${profileUser.userName}님의 프로필 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        :root {
            --header-height: 60px;
            --primary: #5B8DEE;
            --primary-light: #9DBFF9;
            --primary-dark: #4C7FDD;
            --success: #39DA8A;
            --danger: #FF5B5C;
            --warning: #FDAC41;
            --info: #00CFDD;
            --dark: #2C3E50;
            --gray: #6C757D;
            --light-gray: #F7F8FA;
            --border-color: #E8E8E8;
            --text-primary: #2C3E50;
            --text-secondary: #6C757D;
            --text-muted: #9CA3AF;
            --card-shadow: 0 2px 8px rgba(0,0,0,0.08);
            --card-hover-shadow: 0 4px 16px rgba(0,0,0,0.12);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background-color: #F5F7FA;
            color: var(--text-primary);
            line-height: 1.6;
            padding-top: var(--header-height);
        }

        /* Container */
        .profile-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 2rem;
        }

        /* Profile Header */
        .profile-header {
            background: white;
            border-radius: 12px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            box-shadow: var(--card-shadow);
        }

        .profile-header-content {
            display: flex;
            align-items: center;
            gap: 2.5rem;
        }

        .profile-avatar-wrapper {
            flex-shrink: 0;
        }

        .profile-avatar {
            width: 150px;
            height: 150px;
            border-radius: 50%;
            overflow: hidden;
            border: 4px solid white;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .profile-info {
            flex: 1;
        }

        .profile-name-section {
            margin-bottom: 1rem;
        }

        .profile-name {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.25rem;
        }

        .profile-nickname {
            font-size: 1.125rem;
            color: var(--text-secondary);
            font-weight: 400;
        }

        .profile-bio {
            font-size: 1rem;
            color: var(--text-secondary);
            margin-bottom: 1.5rem;
            line-height: 1.7;
        }

        .profile-actions {
            display: flex;
            gap: 1rem;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-1px);
        }

        .btn-outline {
            background: white;
            color: var(--text-secondary);
            border: 1.5px solid var(--border-color);
        }

        .btn-outline:hover {
            background: var(--light-gray);
            border-color: var(--primary);
            color: var(--primary);
        }

        /* Stats Section */
        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 1.75rem;
            box-shadow: var(--card-shadow);
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }

        .stat-card:hover {
            box-shadow: var(--card-hover-shadow);
            transform: translateY(-2px);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            flex-shrink: 0;
        }

        .stat-icon.travel {
            background: rgba(91, 141, 238, 0.1);
            color: var(--primary);
        }

        .stat-icon.complete {
            background: rgba(57, 218, 138, 0.1);
            color: var(--success);
        }

        .stat-icon.posts {
            background: rgba(253, 172, 65, 0.1);
            color: var(--warning);
        }

        .stat-icon.comments {
            background: rgba(255, 91, 92, 0.1);
            color: var(--danger);
        }

        .stat-info {
            flex: 1;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-primary);
            line-height: 1;
            margin-bottom: 0.25rem;
        }

        .stat-label {
            font-size: 0.875rem;
            color: var(--text-secondary);
            font-weight: 500;
        }

        /* Main Grid */
        .main-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        @media (max-width: 992px) {
            .main-grid {
                grid-template-columns: 1fr;
            }
        }

        /* Content Cards */
        .content-card {
            background: white;
            border-radius: 12px;
            box-shadow: var(--card-shadow);
            overflow: hidden;
            transition: all 0.2s ease;
        }

        .content-card:hover {
            box-shadow: var(--card-hover-shadow);
        }

        .card-header {
            padding: 1.5rem;
            background: var(--light-gray);
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .card-header-icon {
            font-size: 1.25rem;
            color: var(--primary);
        }

        .card-title {
            font-size: 1.125rem;
            font-weight: 600;
            color: var(--text-primary);
        }

        .card-body {
            padding: 1.5rem;
        }

        /* Special Cards */
        .manner-card {
            text-align: center;
            padding: 2rem 1.5rem;
        }

        .manner-temperature {
            font-size: 3.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--danger) 0%, var(--warning) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
        }

        .manner-label {
            font-size: 1rem;
            color: var(--text-secondary);
        }

        /* MBTI Card */
        .mbti-card {
            text-align: center;
            padding: 2rem 1.5rem;
        }

        .mbti-type {
            font-size: 3rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0.5rem;
        }

        .mbti-name {
            font-size: 1.125rem;
            color: var(--text-primary);
            font-weight: 500;
        }

        /* Badge Display */
        .badge-list {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
        }

        .badge-item {
            padding: 0.5rem 1rem;
            background: var(--light-gray);
            border-radius: 20px;
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--text-primary);
            border: 1px solid var(--border-color);
            transition: all 0.2s ease;
        }

        .badge-item:hover {
            background: var(--primary);
            color: white;
            border-color: var(--primary);
            transform: scale(1.05);
        }

        /* Progress Bars */
        .progress-list {
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
        }

        .progress-item {
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }

        .progress-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .progress-label {
            font-size: 0.9rem;
            font-weight: 500;
            color: var(--text-primary);
        }

        .progress-percent {
            font-size: 0.875rem;
            font-weight: 600;
            color: var(--primary);
        }

        .progress-bar {
            height: 8px;
            background: var(--border-color);
            border-radius: 4px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--primary) 0%, var(--primary-light) 100%);
            border-radius: 4px;
            transition: width 1s ease;
        }

        /* Activity Lists */
        .activity-list {
            list-style: none;
            display: flex;
            flex-direction: column;
        }

        .activity-item {
            padding: 1rem 0;
            border-bottom: 1px solid var(--border-color);
            transition: all 0.2s ease;
        }

        .activity-item:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .activity-item:hover {
            padding-left: 0.5rem;
        }

        .activity-link {
            display: flex;
            justify-content: space-between;
            align-items: center;
            text-decoration: none;
            color: inherit;
        }

        .activity-title {
            font-size: 0.95rem;
            font-weight: 500;
            color: var(--text-primary);
            flex: 1;
            margin-right: 1rem;
        }

        .activity-item:hover .activity-title {
            color: var(--primary);
        }

        .activity-date {
            font-size: 0.875rem;
            color: var(--text-muted);
            white-space: nowrap;
        }

        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 3rem 1.5rem;
        }

        .empty-icon {
            font-size: 3rem;
            color: var(--border-color);
            margin-bottom: 1rem;
        }

        .empty-message {
            font-size: 1rem;
            color: var(--text-muted);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .profile-container {
                padding: 1rem;
            }

            .profile-header-content {
                flex-direction: column;
                text-align: center;
            }

            .profile-info {
                text-align: center;
            }

            .profile-actions {
                justify-content: center;
            }

            .stats-section {
                grid-template-columns: repeat(2, 1fr);
                gap: 1rem;
            }

            .stat-card {
                flex-direction: column;
                text-align: center;
            }

            .profile-avatar {
                width: 120px;
                height: 120px;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="profile-container">
        <!-- Profile Header -->
        <div class="profile-header">
            <div class="profile-header-content">
                <div class="profile-avatar-wrapper">
                    <div class="profile-avatar">
                        <img src="<c:choose><c:when test='${not empty profileUser.profileImage}'>/uploads/profile/${profileUser.profileImage}</c:when><c:otherwise>https://via.placeholder.com/150</c:otherwise></c:choose>"
                             alt="${profileUser.userName}">
                    </div>
                </div>

                <div class="profile-info">
                    <div class="profile-name-section">
                        <h1 class="profile-name">${profileUser.userName}</h1>
                        <c:if test="${not empty profileUser.nickname}">
                            <p class="profile-nickname">@${profileUser.nickname}</p>
                        </c:if>
                    </div>

                    <p class="profile-bio">
                        ${profileUser.bio != null ? profileUser.bio : '안녕하세요! 여행을 사랑하는 사람입니다.'}
                    </p>

                    <div class="profile-actions">
                        <c:if test="${not isOwnProfile}">
                            <button class="btn btn-primary" onclick="window.location.href='${pageContext.request.contextPath}/message/compose?to=${profileUser.userId}'">
                                <i class="fas fa-envelope"></i>
                                <span>쪽지 보내기</span>
                            </button>
                        </c:if>
                        <button class="btn btn-outline" onclick="history.back()">
                            <i class="fas fa-arrow-left"></i>
                            <span>뒤로 가기</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Statistics Section -->
        <div class="stats-section">
            <div class="stat-card">
                <div class="stat-icon travel">
                    <i class="fas fa-suitcase"></i>
                </div>
                <div class="stat-info">
                    <div class="stat-value">${totalTravelPlans}</div>
                    <div class="stat-label">등록한 여행</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon complete">
                    <i class="fas fa-check-circle"></i>
                </div>
                <div class="stat-info">
                    <div class="stat-value">${completedTravels}</div>
                    <div class="stat-label">완료한 여행</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon posts">
                    <i class="fas fa-edit"></i>
                </div>
                <div class="stat-info">
                    <div class="stat-value">${totalPosts}</div>
                    <div class="stat-label">작성한 게시글</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon comments">
                    <i class="fas fa-comments"></i>
                </div>
                <div class="stat-info">
                    <div class="stat-value">${totalComments}</div>
                    <div class="stat-label">작성한 댓글</div>
                </div>
            </div>
        </div>

        <!-- Main Grid -->
        <div class="main-grid">
            <!-- Manner Temperature -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-thermometer-half card-header-icon"></i>
                    <h2 class="card-title">매너 온도</h2>
                </div>
                <div class="card-body manner-card">
                    <div class="manner-temperature">${mannerStats.averageMannerScore}°C</div>
                    <p class="manner-label">총 ${mannerStats.totalEvaluations}회 평가 받음</p>
                </div>
            </div>

            <!-- Travel MBTI -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-user-tag card-header-icon"></i>
                    <h2 class="card-title">여행 MBTI</h2>
                </div>
                <div class="card-body mbti-card">
                    <c:choose>
                        <c:when test="${not empty mbtiResult}">
                            <div class="mbti-type">${mbtiResult.mbtiType}</div>
                            <p class="mbti-name">${mbtiResult.typeName}</p>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-user-tag empty-icon"></i>
                                <p class="empty-message">아직 테스트를 진행하지 않았습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Badges -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-award card-header-icon"></i>
                    <h2 class="card-title">획득한 뱃지</h2>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty badges}">
                            <div class="badge-list">
                                <c:forEach var="badge" items="${badges}">
                                    <span class="badge-item">${badge.badgeName}</span>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-award empty-icon"></i>
                                <p class="empty-message">아직 획득한 뱃지가 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Badge Progress -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-chart-line card-header-icon"></i>
                    <h2 class="card-title">뱃지 진행도</h2>
                </div>
                <div class="card-body">
                    <div class="progress-list">
                        <div class="progress-item">
                            <div class="progress-header">
                                <span class="progress-label">🏆 여행 마스터</span>
                                <span class="progress-percent">75%</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: 75%"></div>
                            </div>
                        </div>
                        <div class="progress-item">
                            <div class="progress-header">
                                <span class="progress-label">🦋 소셜 버터플라이</span>
                                <span class="progress-percent">45%</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: 45%"></div>
                            </div>
                        </div>
                        <div class="progress-item">
                            <div class="progress-header">
                                <span class="progress-label">✍️ 리뷰 전문가</span>
                                <span class="progress-percent">30%</span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: 30%"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Activity Section -->
        <div class="main-grid">
            <!-- Recent Travel Plans -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-route card-header-icon"></i>
                    <h2 class="card-title">최근 등록한 여행</h2>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty recentTravelPlans}">
                            <ul class="activity-list">
                                <c:forEach var="plan" items="${recentTravelPlans}">
                                    <li class="activity-item">
                                        <a href="${pageContext.request.contextPath}/travel/detail/${plan.planId}" class="activity-link">
                                            <span class="activity-title">${plan.planTitle}</span>
                                            <span class="activity-date">
                                                <fmt:formatDate value="${plan.planRegdate}" pattern="yyyy.MM.dd"/>
                                            </span>
                                        </a>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-route empty-icon"></i>
                                <p class="empty-message">등록한 여행 계획이 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Recent Posts -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-comment-dots card-header-icon"></i>
                    <h2 class="card-title">최근 작성한 글</h2>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty recentPosts}">
                            <ul class="activity-list">
                                <c:forEach var="post" items="${recentPosts}">
                                    <li class="activity-item">
                                        <a href="${pageContext.request.contextPath}/board/detail/${post.boardId}" class="activity-link">
                                            <span class="activity-title">${post.boardTitle}</span>
                                            <span class="activity-date">
                                                <fmt:formatDate value="${post.boardRegdate}" pattern="yyyy.MM.dd"/>
                                            </span>
                                        </a>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-comment-dots empty-icon"></i>
                                <p class="empty-message">작성한 게시글이 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Report History and Reviews Section -->
        <div class="main-grid">
            <!-- Report History -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-exclamation-triangle card-header-icon"></i>
                    <h2 class="card-title">신고 이력</h2>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty reportHistory}">
                            <ul class="activity-list">
                                <c:forEach var="report" items="${reportHistory}">
                                    <li class="activity-item">
                                        <div class="activity-link">
                                            <div>
                                                <span class="activity-title">${report.reportReason}</span>
                                                <div style="font-size: 0.875rem; color: var(--text-muted); margin-top: 0.25rem;">
                                                    ${report.reportContent}
                                                </div>
                                            </div>
                                            <span class="activity-date">
                                                <fmt:formatDate value="${report.reportDate}" pattern="yyyy.MM.dd"/>
                                            </span>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-shield-alt empty-icon"></i>
                                <p class="empty-message">신고 이력이 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- User Reviews / Manner Evaluations -->
            <div class="content-card">
                <div class="card-header">
                    <i class="fas fa-star card-header-icon"></i>
                    <h2 class="card-title">받은 평가</h2>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty mannerEvaluations}">
                            <ul class="activity-list">
                                <c:forEach var="eval" items="${mannerEvaluations}">
                                    <li class="activity-item">
                                        <div class="activity-link">
                                            <div style="flex: 1;">
                                                <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                                                    <span style="font-weight: 600; color: var(--text-primary);">익명의 동행자</span>
                                                    <span style="font-size: 0.875rem; color: var(--text-muted);">from</span>
                                                    <span style="font-weight: 600; color: ${eval.mannerScore >= 37 ? 'var(--success)' : 'var(--danger)'};">
                                                        ${eval.mannerScore}°C
                                                    </span>
                                                </div>
                                                <c:if test="${not empty eval.evaluationComment}">
                                                    <p style="font-size: 0.95rem; color: var(--text-secondary); margin: 0;">
                                                        ${eval.evaluationComment}
                                                    </p>
                                                </c:if>
                                                <c:if test="${eval.isLike}">
                                                    <span style="display: inline-block; margin-top: 0.5rem; padding: 0.25rem 0.5rem; background: var(--success); color: white; border-radius: 4px; font-size: 0.75rem;">
                                                        <i class="fas fa-thumbs-up"></i> 추천
                                                    </span>
                                                </c:if>
                                                <c:if test="${not eval.isLike}">
                                                    <span style="display: inline-block; margin-top: 0.5rem; padding: 0.25rem 0.5rem; background: var(--danger); color: white; border-radius: 4px; font-size: 0.75rem;">
                                                        <i class="fas fa-thumbs-down"></i> 비추천
                                                    </span>
                                                </c:if>
                                            </div>
                                            <span class="activity-date">
                                                <fmt:formatDate value="${eval.createdDate}" pattern="yyyy.MM.dd HH:mm"/>
                                            </span>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:when test="${not empty userReviews}">
                            <ul class="activity-list">
                                <c:forEach var="review" items="${userReviews}">
                                    <li class="activity-item">
                                        <div class="activity-link">
                                            <div style="flex: 1;">
                                                <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                                                    <span style="font-weight: 600; color: var(--text-primary);">${review.reviewerName}</span>
                                                    <div style="color: var(--warning);">
                                                        <c:forEach begin="1" end="5" var="star">
                                                            <c:choose>
                                                                <c:when test="${star <= review.rating}">
                                                                    <i class="fas fa-star"></i>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <i class="far fa-star"></i>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                    </div>
                                                </div>
                                                <p style="font-size: 0.95rem; color: var(--text-secondary); margin: 0;">
                                                    ${review.reviewContent}
                                                </p>
                                            </div>
                                            <span class="activity-date">
                                                <fmt:formatDate value="${review.reviewDate}" pattern="yyyy.MM.dd"/>
                                            </span>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-star empty-icon"></i>
                                <p class="empty-message">받은 평가가 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Animate progress bars on page load
        window.addEventListener('load', function() {
            const progressFills = document.querySelectorAll('.progress-fill');
            progressFills.forEach(fill => {
                const width = fill.style.width;
                fill.style.width = '0';
                setTimeout(() => {
                    fill.style.width = width;
                }, 100);
            });

            // Animate stat values
            const statValues = document.querySelectorAll('.stat-value');
            statValues.forEach(stat => {
                const finalValue = parseInt(stat.textContent);
                let currentValue = 0;
                const increment = Math.ceil(finalValue / 20);
                const timer = setInterval(() => {
                    currentValue += increment;
                    if (currentValue >= finalValue) {
                        currentValue = finalValue;
                        clearInterval(timer);
                    }
                    stat.textContent = currentValue;
                }, 50);
            });
        });
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>