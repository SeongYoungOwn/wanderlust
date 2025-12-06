<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>여행 MBTI 기록 - Wanderlust</title>
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

        .history-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
            padding: 40px;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            border-radius: 20px;
            box-shadow: 0 8px 25px rgba(74, 144, 226, 0.3);
        }

        .page-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 15px;
        }

        .page-subtitle {
            font-size: 1.2rem;
            opacity: 0.9;
        }

        .history-stats {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }

        .stat-item {
            text-align: center;
            padding: 20px;
            background: linear-gradient(135deg, rgba(74, 144, 226, 0.1), rgba(125, 180, 108, 0.1));
            border-radius: 12px;
        }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-color);
            margin-bottom: 5px;
        }

        .stat-label {
            color: #6c757d;
            font-weight: 500;
        }

        .history-list {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .history-item {
            display: flex;
            align-items: center;
            padding: 25px 30px;
            border-bottom: 1px solid #e9ecef;
            transition: all 0.3s ease;
            position: relative;
        }

        .history-item:last-child {
            border-bottom: none;
        }

        .history-item:hover {
            background: linear-gradient(135deg, rgba(74, 144, 226, 0.05), rgba(125, 180, 108, 0.05));
            transform: translateX(5px);
        }

        .mbti-badge {
            background: linear-gradient(45deg, var(--primary-color), var(--secondary-color));
            color: white;
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 700;
            margin-right: 25px;
            box-shadow: 0 4px 15px rgba(74, 144, 226, 0.3);
        }

        .history-info {
            flex: 1;
        }

        .type-name {
            font-size: 1.3rem;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 8px;
        }

        .test-date {
            color: #6c757d;
            font-size: 0.95rem;
            margin-bottom: 5px;
        }

        .history-actions {
            display: flex;
            gap: 10px;
        }

        .action-btn {
            padding: 8px 16px;
            border: none;
            border-radius: 20px;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }

        .btn-view {
            background: var(--primary-color);
            color: white;
        }

        .btn-view:hover {
            background: #357abd;
            color: white;
            transform: translateY(-2px);
        }

        .empty-state {
            text-align: center;
            padding: 60px 40px;
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }

        .empty-icon {
            font-size: 4rem;
            color: #dee2e6;
            margin-bottom: 20px;
        }

        .empty-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: #6c757d;
            margin-bottom: 15px;
        }

        .empty-text {
            color: #6c757d;
            margin-bottom: 30px;
        }

        .btn-primary-custom {
            background: linear-gradient(45deg, var(--primary-color), var(--secondary-color));
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }

        .btn-primary-custom:hover {
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(74, 144, 226, 0.4);
        }

        @media (max-width: 768px) {
            .history-container {
                padding: 10px;
            }
            
            .page-header {
                padding: 20px;
            }
            
            .page-title {
                font-size: 2rem;
            }
            
            .history-item {
                flex-direction: column;
                text-align: center;
                padding: 20px;
            }
            
            .mbti-badge {
                margin-right: 0;
                margin-bottom: 15px;
            }
            
            .history-actions {
                margin-top: 15px;
                justify-content: center;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/header.jsp" />

    <div class="history-container">
        <!-- 페이지 헤더 -->
        <div class="page-header">
            <h1 class="page-title">📊 여행 MBTI 기록</h1>
            <p class="page-subtitle">${not empty nickname ? nickname : userName}님의 여행 성향 변화를 확인해보세요</p>
        </div>

        <c:choose>
            <c:when test="${not empty history}">
                <!-- 통계 정보 -->
                <div class="history-stats">
                    <h4 class="mb-4">
                        <i class="fas fa-chart-bar me-2"></i>테스트 통계
                    </h4>
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-number">${history.size()}</div>
                            <div class="stat-label">총 테스트 횟수</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">${history[0].mbtiType}</div>
                            <div class="stat-label">최근 결과</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-number">
                                <fmt:formatDate value="${history[0].testDate}" pattern="MM.dd" />
                            </div>
                            <div class="stat-label">마지막 테스트</div>
                        </div>
                    </div>
                </div>

                <!-- 기록 목록 -->
                <div class="history-list">
                    <c:forEach var="record" items="${history}" varStatus="status">
                        <div class="history-item">
                            <div class="mbti-badge">
                                ${record.mbtiType}
                            </div>
                            <div class="history-info">
                                <div class="type-name">
                                    <c:choose>
                                        <c:when test="${record.mbtiType == 'PAIL'}">계획적인 혼자만의 모험가</c:when>
                                        <c:when test="${record.mbtiType == 'PAIB'}">알뜰한 계획형 모험가</c:when>
                                        <c:when test="${record.mbtiType == 'PAGL'}">프리미엄 단체 모험가</c:when>
                                        <c:when test="${record.mbtiType == 'PAGB'}">효율적인 그룹 탐험가</c:when>
                                        <c:when test="${record.mbtiType == 'PSIL'}">신중한 혼자만의 럭셔리 여행자</c:when>
                                        <c:when test="${record.mbtiType == 'PSIB'}">실속형 안전 여행자</c:when>
                                        <c:when test="${record.mbtiType == 'PSGL'}">편안한 그룹 휴양가</c:when>
                                        <c:when test="${record.mbtiType == 'PSGB'}">가성비 단체 관광객</c:when>
                                        <c:when test="${record.mbtiType == 'JAIL'}">자유로운 혼자만의 특별한 경험가</c:when>
                                        <c:when test="${record.mbtiType == 'JAIB'}">즉흥적인 배낭여행자</c:when>
                                        <c:when test="${record.mbtiType == 'JAGL'}">즉흥적인 그룹 모험가</c:when>
                                        <c:when test="${record.mbtiType == 'JAGB'}">자유로운 그룹 백패커</c:when>
                                        <c:when test="${record.mbtiType == 'JSIL'}">계획 없는 혼자만의 힐링 여행자</c:when>
                                        <c:when test="${record.mbtiType == 'JSIB'}">자유로운 실속 여행자</c:when>
                                        <c:when test="${record.mbtiType == 'JSGL'}">여유로운 그룹 휴양객</c:when>
                                        <c:when test="${record.mbtiType == 'JSGB'}">편안한 가성비 여행자</c:when>
                                        <c:otherwise>${record.mbtiType} 여행자</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="test-date">
                                    <i class="far fa-calendar-alt me-1"></i>
                                    <fmt:formatDate value="${record.testDate}" pattern="yyyy년 MM월 dd일 HH:mm" />
                                </div>
                                <c:if test="${status.index == 0}">
                                    <span class="badge bg-primary">최신</span>
                                </c:if>
                            </div>
                            <div class="history-actions">
                                <a href="${pageContext.request.contextPath}/travel-mbti/result/${record.mbtiType}" 
                                   class="action-btn btn-view">
                                    <i class="fas fa-eye me-1"></i>결과 보기
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <!-- 빈 상태 -->
                <div class="empty-state">
                    <div class="empty-icon">
                        <i class="fas fa-clipboard-list"></i>
                    </div>
                    <h3 class="empty-title">아직 테스트 기록이 없습니다</h3>
                    <p class="empty-text">
                        여행 MBTI 테스트를 통해 당신만의 여행 스타일을 발견해보세요!
                    </p>
                    <a href="${pageContext.request.contextPath}/travel-mbti/test" class="btn-primary-custom">
                        <i class="fas fa-play me-2"></i>첫 테스트 시작하기
                    </a>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- 하단 액션 -->
        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/travel-mbti/test" class="btn-primary-custom">
                <i class="fas fa-plus me-2"></i>새 테스트 하기
            </a>
        </div>
    </div>

    <jsp:include page="../common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>