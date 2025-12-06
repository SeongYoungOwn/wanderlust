<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${result.typeName} - 여행 MBTI 결과</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4A90E2;
            --secondary-color: #7DB46C;
            --accent-color: #FF8C42;
            --bg-color: #FEFEFE;
            --card-bg: #F8F9FA;
        }

        body {
            background: linear-gradient(135deg, var(--bg-color) 0%, var(--card-bg) 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            padding-top: 80px;
        }

        .result-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }

        .result-header {
            text-align: center;
            margin-bottom: 40px;
            padding: 50px 40px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            border-radius: 20px;
            box-shadow: 0 8px 25px rgba(74, 144, 226, 0.3);
            position: relative;
            overflow: hidden;
        }

        .result-header::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: shimmer 3s ease-in-out infinite;
        }

        @keyframes shimmer {
            0%, 100% { transform: scale(1) rotate(0deg); opacity: 0.3; }
            50% { transform: scale(1.1) rotate(180deg); opacity: 0.1; }
        }

        .mbti-type {
            font-size: 4rem;
            font-weight: 800;
            margin-bottom: 15px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
            position: relative;
            z-index: 1;
        }

        .type-name {
            font-size: 2.2rem;
            font-weight: 600;
            margin-bottom: 20px;
            position: relative;
            z-index: 1;
        }

        .type-description {
            font-size: 1.3rem;
            opacity: 0.95;
            line-height: 1.6;
            position: relative;
            z-index: 1;
        }

        .result-section {
            background: white;
            border-radius: 15px;
            padding: 35px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            animation: fadeInUp 0.6s ease;
            border-left: 5px solid var(--primary-color);
        }

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

        /* 매칭 사용자 스타일 */
        .matching-users-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
            margin: 20px 0;
        }

        .user-card {
            background: linear-gradient(135deg, #f8f9ff, #f0f4ff);
            border: 2px solid #e3f2fd;
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            cursor: pointer;
        }

        .user-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4), transparent);
            transition: left 0.5s ease;
        }

        .user-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,123,255,0.15);
            border-color: #2196f3;
        }

        .user-card:hover::before {
            left: 100%;
        }

        .user-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: white;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .user-info .user-name {
            font-weight: 600;
            font-size: 1rem;
            color: #2c3e50;
            margin-bottom: 5px;
        }

        .user-info .user-mbti {
            font-size: 0.9rem;
            color: #7b68ee;
            font-weight: 500;
            background: rgba(123, 104, 238, 0.1);
            padding: 3px 8px;
            border-radius: 12px;
            display: inline-block;
            margin-bottom: 5px;
        }

        .user-info .user-details {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-bottom: 8px;
            flex-wrap: wrap;
        }
        .user-info .user-age,
        .user-info .user-gender {
            font-size: 0.75rem;
            padding: 2px 6px;
            border-radius: 10px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 3px;
        }
        .user-info .user-age {
            background: linear-gradient(135deg, rgba(255, 193, 7, 0.15), rgba(255, 152, 0, 0.15));
            color: #f57c00;
            border: 1px solid rgba(255, 193, 7, 0.3);
        }
        .user-info .user-gender {
            background: linear-gradient(135deg, rgba(156, 39, 176, 0.15), rgba(233, 30, 99, 0.15));
            color: #8e24aa;
            border: 1px solid rgba(156, 39, 176, 0.3);
        }
        .user-info .user-age i,
        .user-info .user-gender i {
            font-size: 0.7rem;
        }
        .user-info .user-date {
            font-size: 0.8rem;
            color: #999;
        }

        .profile-hint {
            position: absolute;
            bottom: 10px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(33, 150, 243, 0.9);
            color: white;
            padding: 5px 10px;
            border-radius: 12px;
            font-size: 0.8rem;
            opacity: 0;
            transition: opacity 0.3s ease;
            pointer-events: none;
        }

        .user-card:hover .profile-hint {
            opacity: 1;
        }

        .no-users-message {
            text-align: center;
            padding: 40px 20px;
            color: #666;
            background: rgba(245, 245, 245, 0.5);
            border-radius: 15px;
            border: 2px dashed #ddd;
        }

        .no-users-message i {
            font-size: 2rem;
            color: #ccc;
            margin-bottom: 15px;
        }

        .no-users-message p {
            margin: 5px 0;
            font-size: 1rem;
        }

        .section-title {
            color: var(--primary-color);
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
        }

        .section-title i {
            margin-right: 12px;
            font-size: 1.4rem;
        }

        .travel-style {
            font-size: 1.15rem;
            line-height: 1.8;
            color: #2c3e50;
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            padding: 25px;
            border-radius: 12px;
            border-left: 4px solid var(--secondary-color);
        }

        .destinations-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 25px;
        }

        .destination-card {
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            padding: 25px 20px;
            border-radius: 15px;
            text-align: center;
            border: 2px solid transparent;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .destination-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, var(--primary-color), var(--secondary-color));
        }

        .destination-card:hover {
            border-color: var(--primary-color);
            transform: translateY(-8px);
            box-shadow: 0 8px 25px rgba(74, 144, 226, 0.3);
        }

        .destination-card i {
            font-size: 2.5rem;
            color: var(--primary-color);
            margin-bottom: 12px;
        }

        .destination-name {
            font-weight: 600;
            color: #2c3e50;
            font-size: 1.1rem;
        }

        .tips-list {
            list-style: none;
            padding: 0;
            margin-top: 20px;
        }

        .tips-list li {
            background: linear-gradient(135deg, rgba(74, 144, 226, 0.05), rgba(125, 180, 108, 0.05));
            padding: 18px 20px;
            margin-bottom: 12px;
            border-radius: 12px;
            border-left: 4px solid var(--accent-color);
            font-size: 1.1rem;
            transition: all 0.3s ease;
            position: relative;
        }

        .tips-list li:hover {
            background: linear-gradient(135deg, rgba(74, 144, 226, 0.1), rgba(125, 180, 108, 0.1));
            transform: translateX(8px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .season-badge {
            display: inline-block;
            background: linear-gradient(45deg, var(--secondary-color), #9BC53D);
            color: white;
            padding: 12px 25px;
            border-radius: 25px;
            font-weight: 600;
            font-size: 1.1rem;
            margin-top: 15px;
        }

        .action-buttons {
            text-align: center;
            margin-top: 40px;
            padding: 40px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .btn-custom {
            padding: 12px 30px;
            margin: 10px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 1rem;
        }

        .btn-primary-custom {
            background: linear-gradient(45deg, var(--primary-color), var(--secondary-color));
            color: white;
        }

        .btn-primary-custom:hover {
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(74, 144, 226, 0.4);
        }

        .btn-secondary-custom {
            background: #6c757d;
            color: white;
        }

        .btn-secondary-custom:hover {
            color: white;
            background: #545b62;
            transform: translateY(-2px);
        }

        .btn-accent-custom {
            background: linear-gradient(45deg, var(--accent-color), #FF6B35);
            color: white;
        }

        .btn-accent-custom:hover {
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(255, 140, 66, 0.4);
        }

        .share-buttons {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e9ecef;
        }

        .share-btn {
            background: #4267B2;
            color: white;
            padding: 10px 20px;
            margin: 5px;
            border: none;
            border-radius: 20px;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }

        .share-btn.twitter {
            background: #1DA1F2;
        }

        .share-btn.kakao {
            background: #FEE500;
            color: #3C1E1E;
        }

        .share-btn.link {
            background: #28a745;
        }

        .share-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        }

        .login-notice {
            background: linear-gradient(135deg, #e3f2fd, #f3e5f5);
            border: 1px solid #2196f3;
            color: #1565c0;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
            text-align: center;
        }

        /* 궁합도 점수 스타일 */
        .compatibility-section {
            background: linear-gradient(135deg, #fff5f5, #ffe8e8);
            border: 2px solid #ff69b4;
            border-radius: 20px;
            padding: 30px;
            margin: 20px 0;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .compatibility-section::before {
            content: '💕';
            position: absolute;
            top: 15px;
            right: 20px;
            font-size: 2rem;
            opacity: 0.3;
        }

        .compatibility-score {
            font-size: 4rem;
            font-weight: 900;
            background: linear-gradient(45deg, #ff69b4, #ff1493);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin: 15px 0;
            text-shadow: 2px 2px 4px rgba(255, 105, 180, 0.3);
        }

        .compatibility-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #d1477a;
            margin-bottom: 10px;
        }

        .compatibility-description {
            font-size: 1.1rem;
            color: #666;
            line-height: 1.6;
            margin: 20px 0;
        }

        .recommended-style {
            background: linear-gradient(45deg, #ffd700, #ffed4e);
            color: #8b6914;
            padding: 15px 25px;
            border-radius: 25px;
            font-weight: 600;
            margin-top: 15px;
            display: inline-block;
            font-size: 1.1rem;
        }

        /* 궁합도 바 애니메이션 */
        .compatibility-bar {
            background: #f0f0f0;
            border-radius: 25px;
            height: 20px;
            margin: 20px 0;
            overflow: hidden;
            position: relative;
        }

        .compatibility-fill {
            height: 100%;
            background: linear-gradient(90deg, #ff69b4, #ff1493, #ff69b4);
            border-radius: 25px;
            transition: width 2s ease-in-out;
            position: relative;
            box-shadow: 0 0 10px rgba(255, 105, 180, 0.5);
        }

        .compatibility-fill::after {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.6), transparent);
            animation: shimmer 2s infinite;
        }

        @keyframes shimmer {
            0% { left: -100%; }
            100% { left: 100%; }
        }

        @media (max-width: 768px) {
            .result-container {
                padding: 10px;
            }
            
            .result-header {
                padding: 30px 20px;
            }
            
            .mbti-type {
                font-size: 3rem;
            }
            
            .type-name {
                font-size: 1.8rem;
            }
            
            .result-section {
                padding: 25px 20px;
            }
            
            .destinations-grid {
                grid-template-columns: 1fr;
            }
            
            .btn-custom {
                display: block;
                margin: 10px auto;
                width: 80%;
                max-width: 300px;
            }
            
            .matching-users-grid {
                grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
                gap: 12px;
            }
            
            .user-card {
                padding: 15px 10px;
            }
            
            .user-info .user-details {
                gap: 5px;
                margin-bottom: 6px;
            }
            
            .user-info .user-age,
            .user-info .user-gender {
                font-size: 0.7rem;
                padding: 1px 5px;
            }
            
            .user-info .user-age i,
            .user-info .user-gender i {
                font-size: 0.65rem;
            }
        }
    </style>

    <!-- 영수증 티켓 스타일 추가 -->
    <jsp:include page="result_ticket_style.jsp" />
</head>
<body>
    <jsp:include page="../common/header.jsp" />

    <div class="result-container">

        <!-- 영수증.html 완벽한 복사 헤더 섹션 -->
        <div class="receipt-container">
            <jsp:include page="result_ticket_html.jsp" />
        </div>

        <!-- 로그인 안내 (비로그인 사용자) -->
        <c:if test="${!isLoggedIn}">
            <div class="login-notice">
                <i class="fas fa-info-circle me-2"></i>
                <strong>로그인하시면 이 결과를 저장하고 언제든 다시 확인할 수 있습니다!</strong>
                <div class="mt-3">
                    <a href="${pageContext.request.contextPath}/member/login" class="btn btn-primary">
                        <i class="fas fa-sign-in-alt me-2"></i>로그인하기
                    </a>
                </div>
            </div>
        </c:if>
        
        <!-- 로그인 사용자 저장 옵션 -->
        <c:if test="${isLoggedIn}">
            <div class="alert alert-success" id="save-option" style="display: none;">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <i class="fas fa-save me-2"></i>
                        <strong>이 결과를 마이페이지에 저장하시겠습니까?</strong>
                    </div>
                    <div>
                        <button class="btn btn-success btn-sm me-2" onclick="saveResult()">
                            <i class="fas fa-check me-1"></i>저장
                        </button>
                        <button class="btn btn-outline-secondary btn-sm" onclick="skipSave()">
                            건너뛰기
                        </button>
                    </div>
                </div>
            </div>
            <div class="alert alert-info" id="save-success" style="display: none;">
                <i class="fas fa-check-circle me-2"></i>
                결과가 마이페이지에 저장되었습니다!
            </div>
        </c:if>

        <!-- 여행 스타일 -->
        <div class="result-section">
            <h3 class="section-title">
                <i class="fas fa-route"></i>당신의 여행 스타일
            </h3>
            <div class="travel-style">
                ${result.travelStyle}
            </div>
        </div>
        
        <!-- 최적의 매칭 MBTI -->
        <div class="result-section" style="background: linear-gradient(135deg, #ffeaa7, #fdcb6e); border-left-color: var(--accent-color);">
            <h3 class="section-title" style="color: #d63031;">
                <i class="fas fa-heart"></i>최고의 여행 파트너
            </h3>
            <div style="text-align: center; padding: 20px;">
                <div style="background: linear-gradient(135deg, #fff5f5, #ffe0e0); padding: 20px; border-radius: 15px; margin-bottom: 20px;">
                    <div style="font-size: 1rem; color: #636e72; margin-bottom: 10px;">
                        <strong>${mbtiType}</strong> (${result.typeName}) →
                    </div>
                    <div style="font-size: 2rem; font-weight: bold; color: #d63031; margin-bottom: 10px;">
                        ${matchingMbti}
                    </div>
                    <div style="font-size: 1.1rem; color: #2d3436;">
                        (${matchingTypeName}) 추천
                    </div>
                </div>
                <!-- 궁합도 점수 섹션 -->
                <div class="compatibility-section">
                    <div class="compatibility-title">
                        <i class="fas fa-heart"></i> 여행 궁합도
                    </div>
                    <div class="compatibility-score" id="compatibility-score">
                        <c:choose>
                            <c:when test="${not empty compatibilityPercentage}">
                                0%
                            </c:when>
                            <c:otherwise>
                                0%
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="compatibility-bar">
                        <div class="compatibility-fill" style="width: 0%" data-width="${not empty compatibilityPercentage ? compatibilityPercentage : 85}%"></div>
                    </div>
                    <div class="compatibility-description">
                        <c:choose>
                            <c:when test="${not empty compatibilityDescription}">
                                ${compatibilityDescription}
                            </c:when>
                            <c:otherwise>
                                ✨ 환상적인 궁합! 서로 다른 성향이 완벽한 균형을 이룹니다.
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="recommended-style">
                        <i class="fas fa-route"></i> 추천 여행 스타일: 
                        <c:choose>
                            <c:when test="${not empty recommendedTravelStyle}">
                                ${recommendedTravelStyle}
                            </c:when>
                            <c:otherwise>
                                균형잡힌 종합 여행
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                
                <div style="font-size: 1.1rem; color: #2d3436; line-height: 1.8;">
                    최고의 여행 케미를 만들어낼 조합이에요!
                </div>
                <div style="margin-top: 15px; padding: 20px; background: rgba(255,255,255,0.9); border-radius: 10px; text-align: left;">
                    <h5 style="color: #e17055; margin-bottom: 10px;">
                        <i class="fas fa-puzzle-piece"></i> 왜 이 조합이 완벽한가요?
                    </h5>
                    <p style="font-size: 1rem; color: #2d3436; line-height: 1.8; margin: 0;">
                        ${matchingDescription}
                    </p>
                </div>
                <div style="margin-top: 20px; padding: 15px; background: rgba(255,255,255,0.8); border-radius: 10px;">
                    <i class="fas fa-info-circle" style="color: #74b9ff;"></i>
                    <span style="font-size: 0.9rem; color: #2d3436;">
                        여행 MBTI는 여행 스타일의 호환성을 재미있게 알아보는 도구예요.<br>
                        실제 여행 파트너는 서로의 이해와 배려가 가장 중요합니다!
                    </span>
                </div>
            </div>
        </div>

        <!-- 매칭 사용자 목록 섹션 -->
        <div class="result-section">
            <h3 class="section-title">
                <i class="fas fa-users"></i>${matchingTypeName} 사용자들
            </h3>
            <div style="margin-bottom: 15px; color: #666; font-size: 0.95rem;">
                <i class="fas fa-info-circle"></i> ${matchingMbti} 타입을 가진 실제 사용자들입니다
            </div>
            
            <c:choose>
                <c:when test="${not empty matchingUsers}">
                    <div class="matching-users-grid">
                        <c:forEach var="user" items="${matchingUsers}" varStatus="status">
                            <c:if test="${status.index < 6}"> <!-- 최대 6명만 표시 -->
                                <div class="user-card" data-user-id="${user.userId}" onclick="goToProfile('${user.userId}')">
                                    <div class="user-avatar">
                                        <i class="fas fa-user"></i>
                                    </div>
                                    <div class="user-info">
                                        <div class="user-name">${user.userName != null ? user.userName : user.userId}</div>
                                        <div class="user-mbti">${user.mbtiType}</div>
                                        <!-- 나이 및 성별 정보 -->
                                        <div class="user-details">
                                            <c:if test="${not empty user.age}">
                                                <span class="user-age">
                                                    <i class="fas fa-birthday-cake"></i> ${user.age}세
                                                </span>
                                            </c:if>
                                            <c:if test="${not empty user.gender}">
                                                <span class="user-gender">
                                                    <c:choose>
                                                        <c:when test="${user.gender == 'M'}">
                                                            <i class="fas fa-mars"></i> 남성
                                                        </c:when>
                                                        <c:when test="${user.gender == 'F'}">
                                                            <i class="fas fa-venus"></i> 여성
                                                        </c:when>
                                                    </c:choose>
                                                </span>
                                            </c:if>
                                        </div>
                                        <div class="user-date">
                                            <fmt:formatDate value="${user.testDate}" pattern="MM/dd" />
                                        </div>
                                    </div>
                                    <div class="profile-hint">
                                        <i class="fas fa-eye"></i> 프로필 보기
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                    
                    <c:if test="${fn:length(matchingUsers) > 6}">
                        <div style="text-align: center; margin-top: 15px; color: #666;">
                            <i class="fas fa-plus-circle"></i> 외 ${fn:length(matchingUsers) - 6}명
                        </div>
                    </c:if>
                </c:when>
                <c:otherwise>
                    <div class="no-users-message">
                        <i class="fas fa-search"></i>
                        <p>아직 ${matchingMbti} 타입의 사용자가 없습니다</p>
                        <p style="font-size: 0.9rem; color: #666;">다른 사용자들이 테스트를 완료하면 여기에 표시됩니다!</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 추천 여행지 -->
        <div class="result-section">
            <h3 class="section-title">
                <i class="fas fa-map-marked-alt"></i>추천 여행지
            </h3>
            <div class="destinations-grid">
                <c:forEach var="destination" items="${destinations}">
                    <div class="destination-card">
                        <i class="fas fa-map-marker-alt"></i>
                        <div class="destination-name">${destination.trim()}</div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- 여행 팁 -->
        <div class="result-section">
            <h3 class="section-title">
                <i class="fas fa-lightbulb"></i>여행 팁
            </h3>
            <ul class="tips-list">
                <c:forEach var="tip" items="${tips}">
                    <li>
                        <i class="fas fa-check-circle me-2" style="color: var(--secondary-color);"></i>
                        ${tip.trim()}
                    </li>
                </c:forEach>
            </ul>
        </div>

        <!-- 추천 여행 시기 -->
        <div class="result-section">
            <h3 class="section-title">
                <i class="fas fa-calendar-alt"></i>추천 여행 시기
            </h3>
            <div>
                <span class="season-badge">
                    <i class="fas fa-leaf me-2"></i>${result.bestTravelSeason}
                </span>
            </div>
        </div>

        <!-- 액션 버튼 -->
        <div class="action-buttons">
            <h4 class="mb-4">다음 단계</h4>
            
            <!-- 로그인 상태에 따른 버튼 표시 -->
            <c:choose>
                <c:when test="${isLoggedIn}">
                    <!-- 로그인된 사용자 -->
                    <a href="${pageContext.request.contextPath}/travel/list" class="btn-custom btn-primary-custom">
                        <i class="fas fa-plane me-2"></i>여행 계획 보러가기
                    </a>
                    
                    <a href="${pageContext.request.contextPath}/board/list" class="btn-custom btn-secondary-custom">
                        <i class="fas fa-users me-2"></i>커뮤니티 둘러보기
                    </a>
                    
                    <a href="${pageContext.request.contextPath}/travel-mbti/history" class="btn-custom btn-secondary-custom">
                        <i class="fas fa-history me-2"></i>테스트 기록 보기
                    </a>
                </c:when>
                <c:otherwise>
                    <!-- 로그인하지 않은 사용자 -->
                    <a href="${pageContext.request.contextPath}/member/login" class="btn-custom btn-primary-custom">
                        <i class="fas fa-sign-in-alt me-2"></i>로그인하고 결과 저장하기
                    </a>
                    
                    <a href="${pageContext.request.contextPath}/travel/list" class="btn-custom btn-secondary-custom">
                        <i class="fas fa-plane me-2"></i>여행 계획 둘러보기
                    </a>
                </c:otherwise>
            </c:choose>
            
            <a href="${pageContext.request.contextPath}/travel-mbti/test" class="btn-custom btn-accent-custom">
                <i class="fas fa-redo-alt me-2"></i>다시 테스트하기
            </a>

            <!-- 공유 버튼 -->
            <div class="share-buttons">
                <h5 class="mb-3">결과 공유하기</h5>
                
                <button class="share-btn" onclick="shareToFacebook()">
                    <i class="fab fa-facebook-f me-2"></i>Facebook
                </button>
                
                <button class="share-btn twitter" onclick="shareToTwitter()">
                    <i class="fab fa-twitter me-2"></i>Twitter
                </button>
                
                <button class="share-btn kakao" onclick="shareToKakao()">
                    <i class="fas fa-comment me-2"></i>KakaoTalk
                </button>
                
                <button class="share-btn link" onclick="copyToClipboard()">
                    <i class="fas fa-link me-2"></i>링크 복사
                </button>
            </div>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // JSP EL 변수를 JavaScript 변수로 먼저 할당
        const mbtiType = '${mbtiType}';
        const typeName = '${result.typeName}';

        function shareToFacebook() {
            const url = encodeURIComponent(window.location.href);
            const text = encodeURIComponent('나의 여행 MBTI는 ' + mbtiType + ' - ' + typeName + '입니다! 🧳✈️');
            window.open('https://www.facebook.com/sharer/sharer.php?u=' + url + '&quote=' + text, '_blank', 'width=600,height=400');
        }

        function shareToTwitter() {
            const url = encodeURIComponent(window.location.href);
            const text = encodeURIComponent('나의 여행 MBTI는 ' + mbtiType + ' - ' + typeName + '입니다! 당신의 여행 스타일은? 🧳✈️');
            window.open('https://twitter.com/intent/tweet?url=' + url + '&text=' + text, '_blank', 'width=600,height=400');
        }

        function shareToKakao() {
            alert('카카오톡 공유 기능은 추후 구현 예정입니다.');
        }

        function copyToClipboard() {
            const url = window.location.href;
            navigator.clipboard.writeText(url).then(function() {
                // 성공 알림을 더 예쁘게 표시
                const btn = event.target.closest('.share-btn');
                const originalText = btn.innerHTML;
                btn.innerHTML = '<i class="fas fa-check me-2"></i>복사됨!';
                btn.style.background = '#28a745';
                
                setTimeout(() => {
                    btn.innerHTML = originalText;
                    btn.style.background = '#28a745';
                }, 2000);
            }, function(err) {
                console.error('링크 복사 실패: ', err);
                // 대체 방법
                const textArea = document.createElement('textarea');
                textArea.value = url;
                document.body.appendChild(textArea);
                textArea.select();
                document.execCommand('copy');
                document.body.removeChild(textArea);
                alert('링크가 클립보드에 복사되었습니다!');
            });
        }

        // 페이지 로드 시 애니메이션 효과
        window.addEventListener('load', function() {
            const sections = document.querySelectorAll('.result-section');
            sections.forEach((section, index) => {
                section.style.animationDelay = (index * 0.1) + 's';
            });
            
            // 궁합도 바 애니메이션과 퍼센트 카운팅
            const compatibilityFill = document.querySelector('.compatibility-fill');
            const scoreElement = document.querySelector('#compatibility-score');
            
            if (compatibilityFill && scoreElement) {
                const targetWidth = compatibilityFill.getAttribute('data-width');
                const targetPercent = parseInt(targetWidth) || 85;
                
                // 1초 후 애니메이션 시작
                setTimeout(() => {
                    // 진행바 애니메이션
                    compatibilityFill.style.width = targetWidth || '85%';
                    
                    // 숫자 카운팅 애니메이션
                    let currentPercent = 0;
                    const countDuration = 2000; // 2초간 카운팅
                    const countIncrement = targetPercent / (countDuration / 16); // 60fps 기준
                    
                    const countAnimation = () => {
                        if (currentPercent < targetPercent) {
                            currentPercent += countIncrement;
                            scoreElement.textContent = Math.round(Math.min(currentPercent, targetPercent)) + '%';
                            requestAnimationFrame(countAnimation);
                        } else {
                            scoreElement.textContent = targetPercent + '%';
                        }
                    };
                    
                    countAnimation();
                }, 500); // 0.5초 후에 시작
            }
            
            // 로그인 사용자에게 저장 옵션 표시
            <c:if test="${isLoggedIn}">
                setTimeout(() => {
                    document.getElementById('save-option').style.display = 'block';
                }, 2000);
            </c:if>
        });
        
        function saveResult() {
            fetch('${pageContext.request.contextPath}/travel-mbti/save-result', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    mbtiType: '${mbtiType}'
                })
            })
            .then(response => response.json())
            .then(data => {
                document.getElementById('save-option').style.display = 'none';
                if (data.success) {
                    document.getElementById('save-success').style.display = 'block';
                    setTimeout(() => {
                        document.getElementById('save-success').style.display = 'none';
                    }, 5000);
                } else {
                    alert(data.message || '저장 중 오류가 발생했습니다.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('저장 중 오류가 발생했습니다.');
            });
        }
        
        function skipSave() {
            document.getElementById('save-option').style.display = 'none';
        }
        
        // 사용자 프로필로 이동
        function goToProfile(userId) {
            window.location.href = '${pageContext.request.contextPath}/member/profile/' + userId;
        }
        
        // 사용자 카드 호버 효과
        document.addEventListener('DOMContentLoaded', function() {
            const userCards = document.querySelectorAll('.user-card');
            
            userCards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-8px) scale(1.02)';
                });
                
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(-5px) scale(1)';
                });
            });
        });
    </script>
</body>
</html>yId('save-success').style.display = 'block';
                    setTimeout(() => {
                        document.getElementById('save-success').style.display = 'none';
                    }, 5000);
                } else {
                    alert(data.message || '저장 중 오류가 발생했습니다.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('저장 중 오류가 발생했습니다.');
            });
        }
        
        function skipSave() {
            document.getElementById('save-option').style.display = 'none';
        }
        
        // 사용자 프로필로 이동
        function goToProfile(userId) {
            window.location.href = '${pageContext.request.contextPath}/member/profile/' + userId;
        }
        
        // 사용자 카드 호버 효과
        document.addEventListener('DOMContentLoaded', function() {
            const userCards = document.querySelectorAll('.user-card');
            
            userCards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-8px) scale(1.02)';
                });
                
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(-5px) scale(1)';
                });
            });
        });
    </script>
</body>
</html>