<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>매너 평가 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        body {
            padding-top: 100px;
            background-color: #fdfbf7;
        }
        
        /* 카테고리 평가 스타일 */
        .evaluation-type-btn {
            border: 2px solid #e2e8f0;
            background: white;
            padding: 1rem;
            border-radius: 0.5rem;
            transition: all 0.3s ease;
            cursor: pointer;
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.5rem;
            color: #2d3748;
        }
        
        .evaluation-type-btn:hover {
            border-color: #cbd5e0;
            background: #f7fafc;
        }
        
        .evaluation-type-btn.selected {
            border-color: #ff6b6b;
            background: #fef7f7;
            color: #ff6b6b;
        }
        
        .evaluation-type-btn .icon {
            font-size: 2rem;
        }
        
        .evaluation-type-btn .text {
            font-weight: 600;
            font-size: 1rem;
        }
        
        .evaluation-type-btn small {
            color: #718096;
            font-size: 0.875rem;
        }
        
        .category-btn {
            border: 1px solid #e2e8f0;
            background: white;
            padding: 0.75rem;
            border-radius: 0.375rem;
            transition: all 0.3s ease;
            cursor: pointer;
            text-align: left;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            min-height: 60px;
            color: #2d3748;
        }
        
        .category-btn:hover {
            border-color: #cbd5e0;
            background: #f7fafc;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .category-btn.selected {
            border-color: #10b981;
            background: #f0fdf4;
            color: #059669;
        }
        
        .category-btn.negative.selected {
            border-color: #f59e0b;
            background: #fffbeb;
            color: #d97706;
        }
        
        .category-btn .category-icon {
            font-size: 1.25rem;
            flex-shrink: 0;
        }
        
        .category-btn .category-text {
            flex-grow: 1;
            font-weight: 500;
            font-size: 0.875rem;
            line-height: 1.3;
        }
        
        .category-btn .score-change {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.25rem 0.5rem;
            border-radius: 0.25rem;
            background: #e5e7eb;
            color: #374151;
        }
        
        .category-btn.selected .score-change {
            background: #dcfce7;
            color: #166534;
        }
        
        .category-btn.negative.selected .score-change {
            background: #fef3c7;
            color: #92400e;
        }
        
        .category-section {
            animation: slideDown 0.3s ease-out;
        }
        
        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        
        .page-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 2rem 0;
            margin-bottom: 2rem;
        }
        
        .temperature-slider {
            width: 100%;
            -webkit-appearance: none;
            appearance: none;
            height: 8px;
            border-radius: 5px;
            background: linear-gradient(to right, #8b5cf6, #06b6d4, #10b981, #f59e0b, #ef4444);
            outline: none;
            opacity: 0.8;
            transition: opacity 0.2s;
        }
        
        .temperature-slider:hover {
            opacity: 1;
        }
        
        .temperature-slider::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 25px;
            height: 25px;
            border-radius: 50%;
            background: white;
            cursor: pointer;
            border: 2px solid #ddd;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        
        .temperature-slider::-moz-range-thumb {
            width: 25px;
            height: 25px;
            border-radius: 50%;
            background: white;
            cursor: pointer;
            border: 2px solid #ddd;
            box-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }
        
        .temperature-display {
            font-size: 2rem;
            font-weight: bold;
            text-align: center;
            margin: 1rem 0;
            min-height: 3rem;
        }
        
        .like-buttons {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin: 2rem 0;
        }
        
        .like-btn {
            padding: 1rem 2rem;
            border: 2px solid;
            border-radius: 50px;
            background: white;
            font-size: 1.2rem;
            cursor: pointer;
            transition: all 0.3s ease;
            min-width: 120px;
        }
        
        .like-btn.like {
            border-color: #10b981;
            color: #10b981;
        }
        
        .like-btn.like.active {
            background: #10b981;
            color: white;
        }
        
        .like-btn.dislike {
            border-color: #ef4444;
            color: #ef4444;
        }
        
        .like-btn.dislike.active {
            background: #ef4444;
            color: white;
        }
        
        .evaluation-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            padding: 2rem;
            margin-bottom: 2rem;
        }
        
        .user-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            font-weight: bold;
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
                    <i class="fas fa-star me-2"></i>매너 평가하기
                </h1>
                <p class="mb-0">함께 여행한 동행자들에 대한 솔직한 평가를 남겨주세요</p>
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

            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <!-- 이미 평가한 사용자들 표시 -->
                    <c:if test="${not empty evaluatedUsers}">
                        <div class="card shadow-sm mb-4">
                            <div class="card-header bg-success text-white">
                                <h5 class="mb-0"><i class="fas fa-check me-2"></i>이미 평가를 완료한 참여자</h5>
                            </div>
                            <div class="card-body">
                                <c:forEach var="userId" items="${evaluatedUsers}">
                                    <div class="d-flex align-items-center mb-3 p-3" style="background-color: #f8f9fa; border-radius: 10px;">
                                        <div class="user-avatar me-3" style="width: 50px; height: 50px; font-size: 1.2rem;">
                                            <c:choose>
                                                <c:when test="${not empty userMap[userId] and not empty userMap[userId].userName}">
                                                    ${userMap[userId].userName.substring(0,1).toUpperCase()}
                                                </c:when>
                                                <c:otherwise>
                                                    ${userId.substring(0,1).toUpperCase()}
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="flex-grow-1">
                                            <h6 class="mb-1" style="color: #2d3748;">
                                                <c:choose>
                                                    <c:when test="${not empty userMap[userId] and not empty userMap[userId].nickname}">
                                                        ${userMap[userId].nickname}
                                                    </c:when>
                                                    <c:when test="${not empty userMap[userId] and not empty userMap[userId].userName}">
                                                        ${userMap[userId].userName}
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${userId}
                                                    </c:otherwise>
                                                </c:choose>
                                            </h6>
                                            <small style="color: #718096;">(${userId})</small>
                                        </div>
                                        <div class="text-success">
                                            <i class="fas fa-check-circle me-2"></i>
                                            <span class="fw-bold">평가 완료</span>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>
                    
                    <c:choose>
                        <c:when test="${empty evaluatableUsers}">
                            <div class="alert alert-info text-center">
                                <i class="fas fa-check-circle me-2"></i>
                                <h5>모든 참여자에 대한 평가를 완료했습니다!</h5>
                                <p class="mb-0">이미 모든 동행자들에게 매너 평가를 남겼습니다.</p>
                                <div class="mt-3">
                                    <a href="${pageContext.request.contextPath}/travel/detail/${planId}" class="btn btn-primary">
                                        <i class="fas fa-arrow-left me-2"></i>여행 상세로 돌아가기
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- 아직 평가하지 않은 사용자들 -->
                            <c:if test="${not empty evaluatableUsers}">
                                <div class="card shadow-sm mb-4">
                                    <div class="card-header bg-primary text-white">
                                        <h5 class="mb-0"><i class="fas fa-star me-2"></i>평가 대기중인 참여자</h5>
                                    </div>
                                    <div class="card-body p-0">
                            </c:if>
                            <c:forEach var="userId" items="${evaluatableUsers}">
                                <div class="evaluation-card" data-user-id="${userId}">
                                    <div class="row align-items-center mb-4">
                                        <div class="col-auto">
                                            <div class="user-avatar">
                                                <c:choose>
                                                    <c:when test="${not empty userMap[userId] and not empty userMap[userId].userName}">
                                                        ${userMap[userId].userName.substring(0,1).toUpperCase()}
                                                    </c:when>
                                                    <c:otherwise>
                                                        ${userId.substring(0,1).toUpperCase()}
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                <div class="col">
                                    <h5 class="mb-1" style="color: #2d3748;">
                                        <c:choose>
                                            <c:when test="${not empty userMap[userId] and not empty userMap[userId].nickname}">
                                                ${userMap[userId].nickname}
                                            </c:when>
                                            <c:when test="${not empty userMap[userId] and not empty userMap[userId].userName}">
                                                ${userMap[userId].userName}
                                            </c:when>
                                            <c:otherwise>
                                                ${userId}
                                            </c:otherwise>
                                        </c:choose>
                                    </h5>
                                    <small style="color: #718096;">
                                        동행자 
                                        <c:if test="${not empty userMap[userId] and not empty userMap[userId].userId}">
                                            (${userMap[userId].userId})
                                        </c:if>
                                    </small>
                                </div>
                            </div>
                            
                            <!-- 매너온도 카테고리 평가 -->
                            <div class="manner-evaluation-form" id="evaluationForm_${userId}">
                                <!-- 1단계: 평가 유형 선택 -->
                                <div class="evaluation-type-selector mb-4">
                                    <h6 class="mb-3" style="color: #2d3748;">
                                        <i class="fas fa-star me-2"></i>이번 동행은 어떠셨나요?
                                    </h6>
                                    <div class="row">
                                        <div class="col-6">
                                            <button type="button" class="evaluation-type-btn positive-btn w-100" 
                                                    id="positiveBtn_${userId}"
                                                    onclick="selectEvaluationType('${userId}', 'POSITIVE')">
                                                <span class="icon">👍</span>
                                                <span class="text">긍정적 평가</span>
                                                <small>좋은 경험이었어요</small>
                                            </button>
                                        </div>
                                        <div class="col-6">
                                            <button type="button" class="evaluation-type-btn negative-btn w-100" 
                                                    id="negativeBtn_${userId}"
                                                    onclick="selectEvaluationType('${userId}', 'NEGATIVE')">
                                                <span class="icon">👎</span>
                                                <span class="text">부정적 평가</span>
                                                <small>아쉬운 경험이었어요</small>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- 2단계: 긍정 카테고리 선택 -->
                                <div id="positive-categories_${userId}" class="category-section" style="display:none;">
                                    <h6 class="mb-3" style="color: #2d3748;"><span class="me-2">😊</span> 어떤 점이 좋았나요?</h6>
                                    <div class="row">
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn w-100" onclick="selectCategory('${userId}', '시간약속', 20, this)">
                                                <span class="category-icon">⏰</span>
                                                <span class="category-text">시간 약속을 잘 지켜요</span>
                                                <span class="score-change">+2.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn w-100" onclick="selectCategory('${userId}', '친절함', 20, this)">
                                                <span class="category-icon">😊</span>
                                                <span class="category-text">친절하고 매너가 좋아요</span>
                                                <span class="score-change">+2.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn w-100" onclick="selectCategory('${userId}', '빠른응답', 15, this)">
                                                <span class="category-icon">💬</span>
                                                <span class="category-text">응답이 빨라요</span>
                                                <span class="score-change">+1.5°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn w-100" onclick="selectCategory('${userId}', '계획력', 20, this)">
                                                <span class="category-icon">📋</span>
                                                <span class="category-text">계획을 잘 세워요</span>
                                                <span class="score-change">+2.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn w-100" onclick="selectCategory('${userId}', '배려심', 25, this)">
                                                <span class="category-icon">🤝</span>
                                                <span class="category-text">여행 중 배려심이 많아요</span>
                                                <span class="score-change">+2.5°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn w-100" onclick="selectCategory('${userId}', '재동행', 30, this)">
                                                <span class="category-icon">✈️</span>
                                                <span class="category-text">다시 함께 여행하고 싶어요</span>
                                                <span class="score-change">+3.0°C</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- 3단계: 부정 카테고리 선택 -->
                                <div id="negative-categories_${userId}" class="category-section" style="display:none;">
                                    <h6 class="mb-3" style="color: #2d3748;"><span class="me-2">😔</span> 어떤 점이 아쉬웠나요?</h6>
                                    <div class="row">
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn negative w-100" onclick="selectCategory('${userId}', '시간미준수', -30, this)">
                                                <span class="category-icon">⏰</span>
                                                <span class="category-text">시간 약속을 안 지켜요</span>
                                                <span class="score-change">-3.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn negative w-100" onclick="selectCategory('${userId}', '불친절', -40, this)">
                                                <span class="category-icon">😞</span>
                                                <span class="category-text">불친절하고 매너가 나빠요</span>
                                                <span class="score-change">-4.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn negative w-100" onclick="selectCategory('${userId}', '늦은응답', -20, this)">
                                                <span class="category-icon">💬</span>
                                                <span class="category-text">응답이 늦어요</span>
                                                <span class="score-change">-2.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn negative w-100" onclick="selectCategory('${userId}', '즉흥적', -20, this)">
                                                <span class="category-icon">📋</span>
                                                <span class="category-text">계획 없이 즉흥적이에요</span>
                                                <span class="score-change">-2.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn negative w-100" onclick="selectCategory('${userId}', '이기적', -30, this)">
                                                <span class="category-icon">🚫</span>
                                                <span class="category-text">여행 중 이기적이었어요</span>
                                                <span class="score-change">-3.0°C</span>
                                            </button>
                                        </div>
                                        <div class="col-md-6 mb-2">
                                            <button class="category-btn negative w-100" onclick="selectCategory('${userId}', '비추천', -50, this)">
                                                <span class="category-icon">❌</span>
                                                <span class="category-text">다시는 함께 여행하고 싶지 않아요</span>
                                                <span class="score-change">-5.0°C</span>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- 선택된 카테고리 표시 -->
                                <div class="selected-info mb-3" id="selectedInfo_${userId}" style="display:none;">
                                    <div class="alert alert-info">
                                        <strong>선택한 평가:</strong> <span id="selectedCategory_${userId}"></span>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- 평가 코멘트 -->
                            <div class="mb-4">
                                <h6 class="mb-3" style="color: #2d3748;">
                                    <i class="fas fa-comment-alt me-2"></i>평가 코멘트 (선택사항)
                                </h6>
                                <textarea class="form-control" 
                                          rows="3" 
                                          id="comment_${userId}"
                                          placeholder="이번 여행에서의 동행 경험을 간단히 적어주세요..."
                                          style="background-color: #f7fafc; color: #2d3748; border-color: #e2e8f0;"></textarea>
                            </div>
                            
                            <!-- 평가 제출 버튼 -->
                            <div class="text-end">
                                <button class="btn btn-primary" 
                                        onclick="submitEvaluation('${userId}')">
                                    <i class="fas fa-paper-plane me-2"></i>평가 제출
                                </button>
                            </div>
                                </div>
                            </c:forEach>
                            
                            <c:if test="${not empty evaluatableUsers}">
                                    </div>
                                </div>
                            </c:if>
                            
                            <div class="text-center">
                                <a href="${pageContext.request.contextPath}/travel/detail/${planId}" class="btn btn-outline-secondary">
                                    <i class="fas fa-arrow-left me-2"></i>여행 상세로 돌아가기
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
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
    
    <script>
        // 사용자별 평가 데이터 저장
        const userEvaluations = {};
        
        // 평가 유형 선택 함수
        function selectEvaluationType(userId, type) {
            // 이전 선택 초기화
            const positiveBtn = document.getElementById('positiveBtn_' + userId);
            const negativeBtn = document.getElementById('negativeBtn_' + userId);
            
            if (positiveBtn) positiveBtn.classList.remove('selected');
            if (negativeBtn) negativeBtn.classList.remove('selected');
            
            // 카테고리 섹션 숨기기
            const positiveCats = document.getElementById('positive-categories_' + userId);
            const negativeCats = document.getElementById('negative-categories_' + userId);
            const selectedInfo = document.getElementById('selectedInfo_' + userId);
            
            if (positiveCats) positiveCats.style.display = 'none';
            if (negativeCats) negativeCats.style.display = 'none';
            if (selectedInfo) selectedInfo.style.display = 'none';
            
            // 새 선택 활성화
            if (type === 'POSITIVE') {
                if (positiveBtn) positiveBtn.classList.add('selected');
                if (positiveCats) positiveCats.style.display = 'block';
            } else {
                if (negativeBtn) negativeBtn.classList.add('selected');
                if (negativeCats) negativeCats.style.display = 'block';
            }
            
            // 사용자 평가 데이터 초기화
            userEvaluations[userId] = {
                type: type,
                category: null,
                score: 0
            };
            
            // 제출 버튼 비활성화 - 더 안전한 방법으로 찾기
            const evaluationForm = document.getElementById('evaluationForm_' + userId);
            if (evaluationForm) {
                const submitBtn = evaluationForm.querySelector('button[onclick*="submitEvaluation"]');
                if (submitBtn) {
                    submitBtn.disabled = true;
                    submitBtn.classList.add('disabled');
                }
            }
        }
        
        // 카테고리 선택 함수
        function selectCategory(userId, category, score, element) {
            if (!element) return;
            
            // 같은 섹션의 다른 버튼들 비활성화
            const parentSection = element.closest('.category-section');
            if (parentSection) {
                const allCategoryBtns = parentSection.querySelectorAll('.category-btn');
                allCategoryBtns.forEach(btn => btn.classList.remove('selected'));
            }
            
            // 현재 버튼 활성화
            element.classList.add('selected');
            
            // 평가 데이터 업데이트
            if (!userEvaluations[userId]) {
                userEvaluations[userId] = {};
            }
            userEvaluations[userId].category = category;
            userEvaluations[userId].score = score;
            
            // 선택된 카테고리 표시
            const selectedInfo = document.getElementById('selectedInfo_' + userId);
            const selectedCategory = document.getElementById('selectedCategory_' + userId);
            
            if (selectedInfo && selectedCategory) {
                const categoryText = element.querySelector('.category-text');
                const scoreChange = element.querySelector('.score-change');
                
                if (categoryText && scoreChange) {
                    selectedCategory.textContent = categoryText.textContent + 
                        ' (' + scoreChange.textContent + ')';
                    selectedInfo.style.display = 'block';
                }
            }
            
            // 제출 버튼 활성화
            const evaluationForm = document.getElementById('evaluationForm_' + userId);
            if (evaluationForm) {
                const submitBtn = evaluationForm.querySelector('button[onclick*="submitEvaluation"]');
                if (submitBtn) {
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('disabled');
                }
            }
        }
        
        // 평가 제출
        function submitEvaluation(userId) {
            const comment = document.getElementById('comment_' + userId);
            const userEval = userEvaluations[userId];
            
            if (!userEval || !userEval.category) {
                alert('평가 카테고리를 선택해주세요.');
                return;
            }
            
            const evaluation = {
                travelPlanId: ${planId},
                evaluatedId: userId,
                evaluationType: userEval.type,
                evaluationCategory: userEval.category,
                mannerScore: Math.abs(userEval.score), // 절댓값으로 저장
                isLike: userEval.type === 'POSITIVE',
                evaluationComment: comment.value.trim() || null
            };
            
            console.log('전송할 평가 데이터:', evaluation);
            
            $.ajax({
                url: '${pageContext.request.contextPath}/manner/evaluate',
                type: 'POST',
                contentType: 'application/json; charset=UTF-8',
                data: JSON.stringify(evaluation),
                dataType: 'json',
                beforeSend: function() {
                    // 제출 버튼 비활성화
                    const submitBtn = document.querySelector('[data-user-id="' + userId + '"] .btn-primary');
                    if (submitBtn) {
                        submitBtn.disabled = true;
                        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>제출 중...';
                    }
                },
                success: function(response) {
                    console.log('서버 응답:', response);
                    if (response.success) {
                        alert('매너 평가가 성공적으로 제출되었습니다.');
                        // 해당 카드를 숨기거나 제출 완료 표시
                        const card = document.querySelector('[data-user-id="' + userId + '"]');
                        card.style.opacity = '0.5';
                        card.style.pointerEvents = 'none';
                        
                        // 제출 완료 표시 추가
                        const submitBtn = card.querySelector('button');
                        submitBtn.innerHTML = '<i class="fas fa-check me-2"></i>제출 완료';
                        submitBtn.classList.remove('btn-primary');
                        submitBtn.classList.add('btn-success');
                        submitBtn.disabled = true;
                    } else {
                        alert('매너 평가 제출에 실패했습니다: ' + response.message);
                        // 버튼 복구
                        const submitBtn = document.querySelector('[data-user-id="' + userId + '"] button');
                        if (submitBtn) {
                            submitBtn.disabled = false;
                            submitBtn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>평가 제출';
                        }
                    }
                },
                error: function(xhr, textStatus, errorThrown) {
                    console.log('AJAX 오류:', textStatus, errorThrown);
                    console.log('응답 상태:', xhr.status);
                    console.log('응답 텍스트:', xhr.responseText);
                    
                    // 버튼 복구
                    const submitBtn = document.querySelector('[data-user-id="' + userId + '"] button');
                    if (submitBtn) {
                        submitBtn.disabled = false;
                        submitBtn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>평가 제출';
                    }
                    
                    let errorMessage = '매너 평가 제출 중 오류가 발생했습니다.';
                    
                    if (xhr.status === 401) {
                        errorMessage = '로그인이 필요합니다.';
                        location.href = '${pageContext.request.contextPath}/member/login';
                    } else if (xhr.status === 403) {
                        errorMessage = '평가 권한이 없습니다.';
                    } else if (xhr.status === 400) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            errorMessage = response.message || '잘못된 요청입니다.';
                        } catch (e) {
                            errorMessage = '잘못된 요청입니다.';
                        }
                    } else if (xhr.status === 500) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            errorMessage = response.message || '서버 오류가 발생했습니다.';
                        } catch (e) {
                            errorMessage = '서버 오류가 발생했습니다.';
                        }
                    }
                    
                    alert(errorMessage);
                }
            });
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>