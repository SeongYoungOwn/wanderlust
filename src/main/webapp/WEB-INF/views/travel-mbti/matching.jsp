<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>MBTI 여행 매칭 - Travel Together</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #b4b9cf 0%, #7d31c9 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* 팝업 모드일 때 상단 여백 제거 */
        .popup-mode {
            margin-top: 0 !important;
        }

        .main-content {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            min-height: calc(100vh - 60px); /* Added min-height */
        }

        .matching-container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
            text-align: center;
            max-width: 500px;
            width: 100%;
        }

        .matching-title {
            font-size: 2em;
            color: #333;
            margin-bottom: 10px;
            font-weight: 600;
        }

        .matching-subtitle {
            color: #666;
            margin-bottom: 40px;
            font-size: 1.1em;
        }

        .matching-icon {
            font-size: 4em;
            margin-bottom: 30px;
            color: #667eea;
        }

        .start-matching-btn {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px 40px;
            border-radius: 50px;
            font-size: 1.2em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }

        .start-matching-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 25px rgba(102, 126, 234, 0.4);
        }

        .start-matching-btn:active {
            transform: translateY(0);
        }

        .start-matching-btn:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .status-message {
            padding: 12px 20px;
            border-radius: 15px;
            text-align: center;
            font-weight: 500;
            font-size: 1em;
            margin: 0 auto;
            max-width: 400px;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .status-login {
            background: rgba(255, 193, 7, 0.9);
            color: #856404;
        }

        .status-test {
            background: rgba(13, 202, 240, 0.9);
            color: #055160;
        }

        .status-ready {
            background: rgba(25, 135, 84, 0.9);
            color: #0a3622;
        }

        .status-error {
            background: rgba(220, 53, 69, 0.9);
            color: #721c24;
        }

        /* 글래즈모피즘 모달 스타일 */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, 
                rgba(102, 126, 234, 0.3) 0%, 
                rgba(118, 75, 162, 0.3) 100%);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            animation: modalFadeIn 0.4s ease-out;
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
                backdrop-filter: blur(0px);
            }
            to {
                opacity: 1;
                backdrop-filter: blur(20px);
            }
        }

        .modal-content {
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin: 2% auto;
            padding: 0;
            border-radius: 25px;
            width: 95%;
            max-width: 1200px;
            max-height: 90vh;
            overflow: hidden;
            position: relative;
            box-shadow: 
                0 25px 50px rgba(0, 0, 0, 0.15),
                0 0 0 1px rgba(255, 255, 255, 0.2),
                inset 0 1px 0 rgba(255, 255, 255, 0.4);
            animation: modalSlideIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        @keyframes modalSlideIn {
            from {
                transform: translateY(-50px) scale(0.9);
                opacity: 0;
            }
            to {
                transform: translateY(0) scale(1);
                opacity: 1;
            }
        }

        .modal-header {
            background: linear-gradient(135deg, 
                rgba(102, 126, 234, 0.8) 0%, 
                rgba(118, 75, 162, 0.8) 100%);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            color: white;
            padding: 25px 30px;
            border-radius: 25px 25px 0 0;
            position: relative;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .modal-title {
            font-size: 1.8em;
            font-weight: 600;
            margin: 0;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .close {
            position: absolute;
            right: 25px;
            top: 50%;
            transform: translateY(-50%);
            color: rgba(255, 255, 255, 0.9);
            font-size: 2em;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.1);
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .close:hover {
            color: white;
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-50%) scale(1.1) rotate(90deg);
        }

        .modal-body {
            padding: 30px;
            max-height: calc(85vh - 120px);
            overflow-y: auto;
            background: rgba(255, 255, 255, 0.1);
        }

        /* 스크롤바 스타일링 */
        .modal-body::-webkit-scrollbar {
            width: 8px;
        }

        .modal-body::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
        }

        .modal-body::-webkit-scrollbar-thumb {
            background: rgba(102, 126, 234, 0.5);
            border-radius: 10px;
            border: 2px solid transparent;
            background-clip: content-box;
        }

        .modal-body::-webkit-scrollbar-thumb:hover {
            background: rgba(102, 126, 234, 0.7);
            background-clip: content-box;
        }

        .matching-info {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            gap: 20px;
        }

        .mbti-card {
            flex: 1;
            background: rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border-radius: 20px;
            padding: 25px 20px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.4);
            box-shadow: 
                0 8px 32px rgba(0, 0, 0, 0.1),
                inset 0 1px 0 rgba(255, 255, 255, 0.6);
            transition: all 0.3s ease;
        }

        .mbti-card:hover {
            background: rgba(255, 255, 255, 0.4);
            transform: translateY(-2px);
            box-shadow: 
                0 12px 40px rgba(0, 0, 0, 0.15),
                inset 0 1px 0 rgba(255, 255, 255, 0.7);
        }

        .mbti-type {
            font-size: 2.2em;
            font-weight: bold;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
            text-shadow: 0 0 30px rgba(102, 126, 234, 0.5);
        }

        .mbti-name {
            font-size: 1.2em;
            color: rgba(51, 51, 51, 0.9);
            margin-bottom: 15px;
            font-weight: 600;
        }

        .compatibility-score {
            background: rgba(102, 126, 234, 0.8);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            color: white;
            padding: 10px 20px;
            border-radius: 25px;
            font-weight: 600;
            display: inline-block;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }

        .users-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }

        .user-card {
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border-radius: 20px;
            padding: 25px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 
                0 8px 32px rgba(0, 0, 0, 0.1),
                inset 0 1px 0 rgba(255, 255, 255, 0.5);
            transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .user-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(135deg, 
                rgba(102, 126, 234, 0.1) 0%, 
                rgba(118, 75, 162, 0.1) 100%);
            opacity: 0;
            transition: opacity 0.3s ease;
            pointer-events: none;
        }

        .user-card:hover {
            transform: translateY(-8px) scale(1.02);
            background: rgba(255, 255, 255, 0.35);
            box-shadow: 
                0 20px 60px rgba(0, 0, 0, 0.15),
                0 0 50px rgba(102, 126, 234, 0.2),
                inset 0 1px 0 rgba(255, 255, 255, 0.6);
        }

        .user-card:hover::before {
            opacity: 1;
        }

        .user-avatar {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            margin: 0 auto 20px;
            background: linear-gradient(135deg, rgba(129, 143, 206, 0.8), rgba(49, 32, 206, 0.8));
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2.2em;
            font-weight: bold;
            border: 2px solid rgba(255, 255, 255, 0.3);
            box-shadow: 
                0 8px 25px rgba(102, 126, 234, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.4);
            transition: all 0.3s ease;
        }

        .user-avatar:hover {
            transform: scale(1.05);
            box-shadow: 
                0 12px 35px rgba(102, 126, 234, 0.4),
                inset 0 1px 0 rgba(255, 255, 255, 0.5);
        }

        .user-avatar img {
            width: 100%;
            height: 100%;
            border-radius: 50%;
            object-fit: cover;
        }

        .user-name {
            font-size: 1.3em;
            font-weight: 700;
            color: rgba(51, 51, 51, 0.9);
            margin-bottom: 15px;
            text-align: center;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .user-stats {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 15px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .stat-item {
            text-align: center;
            flex: 1;
            position: relative;
        }

        .stat-item:not(:last-child)::after {
            content: '';
            position: absolute;
            right: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 1px;
            height: 30px;
            background: rgba(255, 255, 255, 0.3);
        }

        .stat-label {
            font-size: 0.9em;
            color: rgba(102, 102, 102, 0.8);
            margin-bottom: 8px;
            font-weight: 500;
        }

        .stat-value {
            font-weight: bold;
            font-size: 1.1em;
            color: rgba(51, 51, 51, 0.9);
        }

        .compatibility-value {
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 800;
        }

        .manner-temp {
            background: linear-gradient(135deg, #ff6b6b, #ff8e53);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 800;
        }
        
        .user-actions {
            display: flex;
            gap: 8px;
            justify-content: center;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid rgba(255, 255, 255, 0.3);
        }
        
        .btn-profile, .btn-message {
            width: 40px;
            height: 40px;
            border: none;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 16px;
            position: relative;
            z-index: 10;
        }
        
        .btn-profile {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-message {
            background: linear-gradient(135deg, #ff6b6b, #ff8e53);
            color: white;
        }
        
        .btn-profile:hover, .btn-message:hover {
            transform: translateY(-2px) scale(1.1);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }
        
        .btn-profile:hover {
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-message:hover {
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.4);
        }

        .loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            border-radius: 25px;
            border: 1px solid rgba(255, 255, 255, 0.4);
        }

        .loading-spinner {
            width: 70px;
            height: 70px;
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top: 4px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 25px;
            box-shadow: 0 0 30px rgba(102, 126, 234, 0.3);
        }

        .loading-text {
            font-size: 1.3em;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-weight: 700;
            text-shadow: 0 0 30px rgba(102, 126, 234, 0.5);
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .no-users-message {
            text-align: center;
            padding: 50px 30px;
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: rgba(102, 102, 102, 0.9);
            font-size: 1.1em;
            font-weight: 500;
            box-shadow: 
                0 8px 32px rgba(0, 0, 0, 0.1),
                inset 0 1px 0 rgba(255, 255, 255, 0.5);
        }

        .error-message {
            background: rgba(255, 230, 230, 0.8);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            color: #d8000c;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 20px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.3);
            box-shadow: 
                0 8px 25px rgba(216, 0, 12, 0.2),
                inset 0 1px 0 rgba(255, 255, 255, 0.5);
        }

        .test-required {
            background: rgba(255, 243, 205, 0.8);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            color: #856404;
            padding: 30px;
            border-radius: 20px;
            text-align: center;
            margin-bottom: 20px;
            border: 1px solid rgba(255, 255, 255, 0.4);
            box-shadow: 
                0 8px 32px rgba(0, 0, 0, 0.1),
                inset 0 1px 0 rgba(255, 255, 255, 0.6);
        }

        .test-required h3 {
            margin-bottom: 15px;
            font-size: 1.4em;
        }

        .test-link {
            display: inline-block;
            background: rgba(102, 126, 234, 0.9);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            color: white;
            padding: 12px 25px;
            border-radius: 25px;
            text-decoration: none;
            margin-top: 20px;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.3);
            font-weight: 600;
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        .test-link:hover {
            background: rgba(90, 111, 216, 0.9);
            transform: translateY(-3px);
            box-shadow: 0 12px 35px rgba(102, 126, 234, 0.5);
            color: white;
            text-decoration: none;
        }

        @media (max-width: 768px) {
            .modal-content {
                width: 98%;
                margin: 1% auto;
                max-width: none;
                max-height: 95vh;
            }
            
            .matching-info {
                flex-direction: column;
            }
            
            .users-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="${not empty param.popup ? 'popup-mode' : ''}">
    <c:if test="${empty param.popup}">
        <%@ include file="../common/header.jsp" %>
    </c:if>
    
    <div class="main-content">
        <div class="matching-container">
            <div class="matching-icon">🎯</div>
            <h1 class="matching-title">MBTI 매칭</h1>
            <p class="matching-subtitle">당신과 완벽하게 맞는 여행 파트너를 찾아보세요!</p>
            
            <div id="statusMessage" class="status-message" style="display: none; margin-bottom: 20px;"></div>
            
            <button class="start-matching-btn" id="startMatchingBtn">
                매칭 시작하기
            </button>
        </div>
    </div>

    <!-- 매칭 결과 모달 -->
    <div id="matchingModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">🎯 매칭 결과</h2>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            
            <div class="modal-body">
                <div id="modalContent">
                    <!-- 동적 콘텐츠가 여기에 로드됩니다 -->
                </div>
            </div>
            
            <!-- 로딩 오버레이 -->
            <div id="loadingOverlay" class="loading-overlay" style="display: none;">
                <div class="loading-spinner"></div>
                <div class="loading-text">완벽한 매칭을 찾는 중...</div>
            </div>
        </div>
    </div>

    <!-- 로그인 요청 모달 -->
    <div id="loginModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">🔐 로그인 필요</h2>
                <span class="close" onclick="closeLoginModal()">&times;</span>
            </div>
            
            <div class="modal-body">
                <div style="text-align: center; padding: 30px;">
                    <div style="font-size: 3em; margin-bottom: 20px;">🚫</div>
                    <h3 style="color: #333; margin-bottom: 15px;">로그인이 필요한 서비스입니다</h3>
                    <p style="color: #666; margin-bottom: 30px; line-height: 1.6;">
                        MBTI 매칭 서비스를 이용하시려면<br>
                        먼저 로그인을 해주세요!
                    </p>
                    <div style="display: flex; gap: 15px; justify-content: center;">
                        <button onclick="goToLogin()" style="
                            background: linear-gradient(45deg, #667eea, #764ba2);
                            color: white;
                            border: none;
                            padding: 12px 25px;
                            border-radius: 25px;
                            font-weight: 600;
                            cursor: pointer;
                            transition: all 0.3s ease;
                            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
                        ">
                            로그인하기
                        </button>
                        <button onclick="closeLoginModal()" style="
                            background: rgba(102, 102, 102, 0.1);
                            color: #666;
                            border: 1px solid rgba(102, 102, 102, 0.3);
                            padding: 12px 25px;
                            border-radius: 25px;
                            font-weight: 600;
                            cursor: pointer;
                            transition: all 0.3s ease;
                        ">
                            취소
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 컨텍스트 패스 전역 변수
        const contextPath = '${pageContext.request.contextPath}';
        
        // 매칭 시작 함수 - 먼저 정의
        function startMatching() {
            const btn = document.querySelector('.start-matching-btn');
            const modal = document.getElementById('matchingModal');
            const loadingOverlay = document.getElementById('loadingOverlay');
            
            console.log('=== 매칭 시작 ===');
            console.log('버튼 클릭됨');
            console.log('contextPath:', contextPath);
            console.log('현재 페이지 URL:', window.location.href);
            console.log('User Agent:', navigator.userAgent);
            
            // 버튼 비활성화
            btn.disabled = true;
            btn.textContent = '매칭 중...';
            
            // 모달 표시
            modal.style.display = 'block';
            loadingOverlay.style.display = 'flex';
            
            console.log('로딩 오버레이 표시됨');
            
            // AJAX 요청
            const requestUrl = contextPath + '/travel-mbti/matching/data';
            console.log('AJAX 요청 URL:', requestUrl);
            console.log('전체 URL:', window.location.origin + requestUrl);
            
            fetch(requestUrl)
                .then(response => {
                    console.log('응답 상태:', response.status);
                    if (!response.ok) {
                        throw new Error(`HTTP error! status: ${response.status}`);
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('=== 전체 응답 데이터 ===');
                    console.log(JSON.stringify(data, null, 2));
                    console.log('======================');
                    
                    // 각 필드별 상세 로깅
                    console.log('data.success:', data.success);
                    console.log('data.myMbtiType:', data.myMbtiType);
                    console.log('data.myMbtiResult:', data.myMbtiResult);
                    console.log('data.matchingMbti:', data.matchingMbti);
                    console.log('data.matchingMbtiResult:', data.matchingMbtiResult);
                    console.log('data.matchingUsers 배열 길이:', data.matchingUsers ? data.matchingUsers.length : 'null/undefined');
                    
                    if (data.matchingUsers && Array.isArray(data.matchingUsers)) {
                        data.matchingUsers.forEach((user, index) => {
                            console.log(`매칭 사용자 ${index + 1}:`, {
                                userId: user.userId,
                                userName: user.userName,
                                compatibility: user.compatibilityPercentage + '%',
                                mannerTemp: user.mannerTemperature + '°C'
                            });
                        });
                    }
                    
                    // 로딩 오버레이 숨기기
                    loadingOverlay.style.display = 'none';
                    
                    if (data.success) {
                        displayMatchingResults(data);
                    } else {
                        console.error('매칭 데이터 가져오기 실패:', data);
                        if (data.needTest) {
                            displayMessage('먼저 MBTI 테스트를 완료해주세요!', 'test');
                        } else if (data.error && data.error.includes('로그인이 필요합니다')) {
                            displayMessage('로그인 후 이용해주세요!', 'login');
                        } else {
                            displayMessage('매칭 중 오류가 발생했습니다. 다시 시도해주세요.', 'error');
                        }
                    }
                })
                .catch(error => {
                    console.error('매칭 요청 중 오류:', error);
                    loadingOverlay.style.display = 'none';
                    displayMessage('네트워크 오류가 발생했습니다. 다시 시도해주세요.', 'error');
                })
                .finally(() => {
                    // 버튼 활성화
                    btn.disabled = false;
                    btn.textContent = '매칭 시작하기';
                    console.log('매칭 요청 완료');
                });
        }
        
        // 즉시 전역으로 할당
        window.startMatching = startMatching;

        // 페이지 로드 시 상태 확인
        document.addEventListener('DOMContentLoaded', function() {
            checkUserStatus();
            
            // 매칭 시작 버튼에 이벤트 리스너 추가
            const matchingBtn = document.getElementById('startMatchingBtn');
            if (matchingBtn) {
                matchingBtn.addEventListener('click', function() {
                    console.log('Button clicked via event listener');
                    startMatching();
                });
            }
        });
        
        function checkUserStatus() {
            console.log('=== 사용자 상태 확인 ===');
            
            // 로그인 상태 확인
            fetch(contextPath + '/travel-mbti/my-result')
                .then(response => response.json())
                .then(data => {
                    console.log('사용자 상태:', data);
                    
                    if (!data.success) {
                        if (data.message && data.message.includes('로그인이 필요합니다')) {
                            showStatusMessage('로그인 후 이용해주세요', 'login');
                        } else if (data.message && data.message.includes('테스트 기록이 없습니다')) {
                            showStatusMessage('먼저 MBTI 테스트를 완료해주세요', 'test');
                        }
                    } else {
                        showStatusMessage('매칭을 시작할 준비가 완료되었습니다!', 'ready');
                    }
                })
                .catch(error => {
                    console.error('상태 확인 중 오류:', error);
                    showStatusMessage('상태 확인 중 오류가 발생했습니다', 'error');
                });
        }
        
        function showStatusMessage(message, type) {
            const statusDiv = document.getElementById('statusMessage');
            if (statusDiv) {
                statusDiv.textContent = message;
                statusDiv.className = 'status-message status-' + type;
                statusDiv.style.display = 'block';
            }
        }
        
        
        function displayMatchingResults(data) {
            console.log('매칭 결과 표시 함수 호출됨', data);
            const content = document.getElementById('modalContent');
            
            // 데이터 검증 및 기본값 설정
            const myMbtiType = data.myMbtiType || 'UNKNOWN';
            const myMbtiName = data.myMbtiResult && data.myMbtiResult.typeName ? data.myMbtiResult.typeName : '여행 타입';
            const matchingMbti = data.matchingMbti || 'UNKNOWN';
            const matchingMbtiName = data.matchingMbtiResult && data.matchingMbtiResult.typeName ? data.matchingMbtiResult.typeName : '매칭 타입';
            
            console.log('=== MBTI 데이터 디버깅 ===');
            console.log('data.myMbtiType:', data.myMbtiType);
            console.log('data.myMbtiResult:', data.myMbtiResult);
            console.log('data.matchingMbti:', data.matchingMbti);
            console.log('data.matchingMbtiResult:', data.matchingMbtiResult);
            console.log('처리된 데이터:', {
                myMbtiType,
                myMbtiName,
                matchingMbti,
                matchingMbtiName
            });
            console.log('========================');
            
            // MBTI 정보 표시를 위한 템플릿 - 플레이스홀더 방식 사용
            let mbtiTemplate = '<div class="matching-info">';
            mbtiTemplate += '<div class="mbti-card">';
            mbtiTemplate += '<div class="mbti-type">MY_MBTI_TYPE_PLACEHOLDER</div>';
            mbtiTemplate += '<div class="mbti-name">MY_MBTI_NAME_PLACEHOLDER</div>';
            mbtiTemplate += '<div style="color: #666;">나의 MBTI</div>';
            mbtiTemplate += '</div>';
            mbtiTemplate += '<div style="display: flex; align-items: center; font-size: 2em;">💕</div>';
            mbtiTemplate += '<div class="mbti-card">';
            mbtiTemplate += '<div class="mbti-type">MATCHING_MBTI_TYPE_PLACEHOLDER</div>';
            mbtiTemplate += '<div class="mbti-name">MATCHING_MBTI_NAME_PLACEHOLDER</div>';
            mbtiTemplate += '<div style="color: #666;">최적의 매칭</div>';
            mbtiTemplate += '</div>';
            mbtiTemplate += '</div>';
            
            let html = mbtiTemplate
                .replace('MY_MBTI_TYPE_PLACEHOLDER', myMbtiType)
                .replace('MY_MBTI_NAME_PLACEHOLDER', myMbtiName)
                .replace('MATCHING_MBTI_TYPE_PLACEHOLDER', matchingMbti)
                .replace('MATCHING_MBTI_NAME_PLACEHOLDER', matchingMbtiName);
            
            console.log('매칭된 사용자 수:', data.matchingUsers ? data.matchingUsers.length : 0);
            
            if (data.matchingUsers && data.matchingUsers.length > 0) {
                html += '<h3 style="margin-bottom: 20px; color: #333;">🎯 매칭된 사용자들</h3>';
                html += '<div class="users-grid">';
                
                data.matchingUsers.forEach((user, index) => {
                    console.log(`사용자 ${index + 1}:`, user);
                    
                    // 변수 충돌을 방지하기 위해 블록 스코프 내에서 처리
                    (function(currentUser, userIndex) {
                        // 사용자 데이터 검증 및 기본값 설정
                        const currentUserId = currentUser.userId || `user${userIndex}`;
                        const currentUserName = currentUser.userName || currentUser.userId || '사용자';
                        
                        // 숫자 필드 안전한 변환 - 다중 조건 체크
                        let currentCompatibilityPercentage = 75; // 기본값
                        if (currentUser.compatibilityPercentage !== null && 
                            currentUser.compatibilityPercentage !== undefined && 
                            currentUser.compatibilityPercentage !== 0 &&
                            !isNaN(currentUser.compatibilityPercentage)) {
                            currentCompatibilityPercentage = parseInt(currentUser.compatibilityPercentage);
                        }
                        
                        let currentMannerTemperature = '36.5'; // 기본값
                        if (currentUser.mannerTemperature !== null && 
                            currentUser.mannerTemperature !== undefined && 
                            currentUser.mannerTemperature !== 0 &&
                            !isNaN(currentUser.mannerTemperature)) {
                            currentMannerTemperature = parseFloat(currentUser.mannerTemperature).toFixed(1);
                        }
                        
                        const currentAvatarContent = (currentUser.profileImage && currentUser.profileImage.trim() !== '') 
                            ? `<img src="${currentUser.profileImage}" alt="${currentUserName}">` 
                            : currentUserName.charAt(0).toUpperCase();
                        
                        console.log(`=== 사용자 ${userIndex + 1} 원본 데이터 ===`);
                        console.log('전체 user 객체:', currentUser);
                        console.log('currentUser.compatibilityPercentage:', currentUser.compatibilityPercentage, typeof currentUser.compatibilityPercentage);
                        console.log('currentUser.mannerTemperature:', currentUser.mannerTemperature, typeof currentUser.mannerTemperature);
                        console.log(`=== 사용자 ${userIndex + 1} 처리된 데이터 ===`);
                        console.log({
                            currentUserId,
                            currentUserName,
                            currentCompatibilityPercentage,
                            currentMannerTemperature,
                            raw_compatibilityPercentage: currentUser.compatibilityPercentage,
                            raw_mannerTemperature: currentUser.mannerTemperature
                        });
                        console.log('================================');
                        
                        // Debug: 템플릿 전 변수 확인
                        console.log('템플릿 생성 직전 변수 상태:', {
                            currentUserId: currentUserId,
                            currentUserName: currentUserName,
                            currentCompatibilityPercentage: currentCompatibilityPercentage,
                            currentMannerTemperature: currentMannerTemperature,
                            currentAvatarContent: currentAvatarContent
                        });
                        
                        // 변수 타입과 값 재검증
                        console.log('변수 타입 검증:');
                        console.log('currentUserId type:', typeof currentUserId, 'value:', currentUserId);
                        console.log('currentUserName type:', typeof currentUserName, 'value:', currentUserName);
                        console.log('currentCompatibilityPercentage type:', typeof currentCompatibilityPercentage, 'value:', currentCompatibilityPercentage);
                        console.log('currentMannerTemperature type:', typeof currentMannerTemperature, 'value:', currentMannerTemperature);
                        
                        // 템플릿 문자열 방식 변경 - replace 함수 사용
                        let templateHtml = '<div class="user-card" onclick="viewProfile(\'USERID_PLACEHOLDER\')" style="cursor: pointer;">';
                        templateHtml += '<div class="user-avatar">AVATAR_PLACEHOLDER</div>';
                        templateHtml += '<div class="user-name">USERNAME_PLACEHOLDER</div>';
                        templateHtml += '<div class="user-stats">';
                        templateHtml += '<div class="stat-item">';
                        templateHtml += '<div class="stat-label">궁합도</div>';
                        templateHtml += '<div class="stat-value compatibility-value">COMPATIBILITY_PLACEHOLDER%</div>';
                        templateHtml += '</div>';
                        templateHtml += '<div class="stat-item">';
                        templateHtml += '<div class="stat-label">매너온도</div>';
                        templateHtml += '<div class="stat-value manner-temp">MANNER_PLACEHOLDER°C</div>';
                        templateHtml += '</div>';
                        templateHtml += '</div>';
                        templateHtml += '<div class="user-actions">';
                        templateHtml += '<button class="btn-profile" onclick="event.stopPropagation(); viewProfile(\'USERID_PLACEHOLDER\')" title="프로필 보기">';
                        templateHtml += '<i class="fas fa-user"></i>';
                        templateHtml += '</button>';
                        templateHtml += '<button class="btn-message" onclick="event.stopPropagation(); openMessageModal(\'USERID_PLACEHOLDER\', \'USERNAME_PLACEHOLDER\')" title="쪽지 보내기">';
                        templateHtml += '<i class="fas fa-envelope"></i>';
                        templateHtml += '</button>';
                        templateHtml += '</div>';
                        templateHtml += '</div>';
                        
                        // 플레이스홀더를 실제 값으로 교체 (정규식으로 모두 교체)
                        const userCardHtml = templateHtml
                            .replace(/USERID_PLACEHOLDER/g, currentUserId)
                            .replace(/AVATAR_PLACEHOLDER/g, currentAvatarContent)
                            .replace(/USERNAME_PLACEHOLDER/g, currentUserName)
                            .replace(/COMPATIBILITY_PLACEHOLDER/g, currentCompatibilityPercentage)
                            .replace(/MANNER_PLACEHOLDER/g, currentMannerTemperature);
                        
                        // HTML에 추가
                        html += userCardHtml;
                        
                        // Debug: 실제 생성된 HTML 확인
                        console.log(`사용자 ${userIndex + 1} 생성된 HTML:`, userCardHtml.substring(0, 200) + '...');
                        
                    })(user, index);
                });
                
                html += '</div>';
            } else {
                html += `
                    <div class="no-users-message">
                        아직 매칭되는 사용자가 없습니다.<br>
                        더 많은 사용자들이 테스트를 완료하면 매칭 결과를 확인할 수 있어요! 🌟
                    </div>
                `;
            }
            
            // Debug: 최종 HTML 확인
            console.log('=== 최종 HTML 디버깅 ===');
            console.log('HTML 길이:', html.length);
            console.log('HTML 내용 (첫 1000자):', html.substring(0, 1000));
            console.log('HTML에 포함된 사용자 이름들:');
            const nameMatches = html.match(/user-name">[^<]+</g);
            console.log('추출된 이름들:', nameMatches);
            const compatibilityMatches = html.match(/compatibility-value">([^<]+)</g);
            console.log('추출된 궁합도들:', compatibilityMatches);
            const temperatureMatches = html.match(/manner-temp">([^<]+)</g);
            console.log('추출된 매너온도들:', temperatureMatches);
            
            content.innerHTML = html;
            
            // Debug: DOM 삽입 후 확인
            setTimeout(() => {
                console.log('=== DOM 삽입 후 디버깅 ===');
                const userNames = content.querySelectorAll('.user-name');
                const compatibilityValues = content.querySelectorAll('.compatibility-value');
                const mannerTempValues = content.querySelectorAll('.manner-temp');
                
                console.log('DOM에서 발견된 사용자 이름들:');
                userNames.forEach((el, i) => console.log(`${i+1}. ${el.textContent}`));
                
                console.log('DOM에서 발견된 궁합도들:');
                compatibilityValues.forEach((el, i) => console.log(`${i+1}. ${el.textContent}`));
                
                console.log('DOM에서 발견된 매너온도들:');
                mannerTempValues.forEach((el, i) => console.log(`${i+1}. ${el.textContent}`));
                
                console.log('첫 번째 사용자 카드 전체 HTML:', userNames[0]?.closest('.user-card')?.outerHTML);
            }, 100);
            
            console.log('매칭 결과 HTML 렌더링 완료');
        }
        
        function displayError(data) {
            console.log('에러 표시 함수 호출됨', data);
            const content = document.getElementById('modalContent');
            const isPopupMode = new URLSearchParams(window.location.search).get('popup') === 'true';
            console.log('팝업 모드:', isPopupMode);
            
            if (data.needTest) {
                console.log('MBTI 테스트 필요 상황');
                const testLinkTarget = isPopupMode ? 'target="_parent"' : '';
                content.innerHTML = `
                    <div class="test-required">
                        <h3>✋ MBTI 테스트가 필요해요!</h3>
                        <p>${data.message}</p>
                        <a href="${contextPath}/travel-mbti/test" class="test-link" ${testLinkTarget}>테스트 하러 가기</a>
                    </div>
                `;
            } else {
                console.log('일반 에러 상황:', data.error);
                console.log('에러 세부사항:', data.details);
                content.innerHTML = `
                    <div class="error-message">
                        ❌ ${data.error || '알 수 없는 오류가 발생했습니다.'}
                        ${data.details ? '<br><small style="color: #666;">세부사항: ' + data.details + '</small>' : ''}
                    </div>
                `;
            }
            console.log('에러 메시지 렌더링 완료');
        }
        
        function closeModal() {
            document.getElementById('matchingModal').style.display = 'none';
        }
        window.closeModal = closeModal;
        
        function showLoginModal() {
            // 매칭 모달 닫기
            document.getElementById('matchingModal').style.display = 'none';
            // 로그인 모달 표시
            document.getElementById('loginModal').style.display = 'block';
        }
        window.showLoginModal = showLoginModal;
        
        function closeLoginModal() {
            document.getElementById('loginModal').style.display = 'none';
        }
        window.closeLoginModal = closeLoginModal;
        
        function goToLogin() {
            const isPopupMode = new URLSearchParams(window.location.search).get('popup') === 'true';
            
            if (isPopupMode) {
                // 팝업 모드에서는 부모 창에서 로그인 페이지로 이동
                window.parent.location.href = contextPath + '/member/login';
            } else {
                // 일반 모드에서는 현재 창에서 로그인 페이지로 이동
                window.location.href = contextPath + '/member/login';
            }
        }
        window.goToLogin = goToLogin;
        
        function viewProfile(userId) {
            const isPopupMode = new URLSearchParams(window.location.search).get('popup') === 'true';
            console.log('Profile link clicked for userId:', userId);
            
            if (isPopupMode) {
                // 팝업 모드에서는 새 창으로 열기
                window.open(contextPath + '/member/profile/' + userId, '_blank');
            } else {
                // 일반 모드에서는 현재 창에서 이동
                window.location.href = contextPath + '/member/profile/' + userId;
            }
        }
        window.viewProfile = viewProfile;
        
        // 모달 외부 클릭 시 닫기
        window.onclick = function(event) {
            const matchingModal = document.getElementById('matchingModal');
            const loginModal = document.getElementById('loginModal');
            
            if (event.target == matchingModal) {
                closeModal();
            } else if (event.target == loginModal) {
                closeLoginModal();
            }
        }
        
        // ESC 키로 모달 닫기
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                const matchingModal = document.getElementById('matchingModal');
                const loginModal = document.getElementById('loginModal');
                
                if (matchingModal.style.display === 'block') {
                    closeModal();
                } else if (loginModal.style.display === 'block') {
                    closeLoginModal();
                }
            }
        });
        
        // 쪽지 보내기 모달 관련 함수들
        let currentReceiverId = '';
        let currentReceiverName = '';
        
        function openMessageModal(receiverId, receiverName) {
            // 로그인 확인
            const isLoggedIn = ${not empty sessionScope.loginUser};
            if (!isLoggedIn) {
                alert('로그인이 필요합니다.');
                return;
            }
            
            currentReceiverId = receiverId;
            currentReceiverName = receiverName;
            
            // 모달 정보 설정
            document.getElementById('messageReceiverId').value = receiverId;
            document.getElementById('messageReceiverName').textContent = receiverName;
            
            // 폼 초기화
            document.getElementById('messageForm').reset();
            document.getElementById('messageTitleCounter').textContent = '0';
            document.getElementById('messageContentCounter').textContent = '0';
            
            // 모달 표시
            document.getElementById('messageModal').style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        window.openMessageModal = openMessageModal;
        
        function closeMessageModal() {
            document.getElementById('messageModal').style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        window.closeMessageModal = closeMessageModal;
        
        function sendMessageFromModal() {
            const title = document.getElementById('messageTitle').value.trim();
            const content = document.getElementById('messageContent').value.trim();
            
            // 유효성 검사
            if (!title) {
                alert('제목을 입력하세요.');
                document.getElementById('messageTitle').focus();
                return;
            }
            
            if (!content) {
                alert('내용을 입력하세요.');
                document.getElementById('messageContent').focus();
                return;
            }
            
            // 버튼 비활성화
            const sendButton = document.querySelector('#messageModal .btn-send');
            const originalText = sendButton.innerHTML;
            sendButton.disabled = true;
            sendButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 전송 중...';
            
            // 쪽지 전송 요청
            const messageData = {
                receiverId: currentReceiverId,
                messageTitle: title,
                messageContent: content
            };
            
            fetch(contextPath + '/message/send', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(messageData)
            })
            .then(response => response.json())
            .then(data => {
                sendButton.disabled = false;
                sendButton.innerHTML = originalText;
                
                if (data.success) {
                    alert('쪽지가 성공적으로 전송되었습니다.');
                    closeMessageModal();
                } else {
                    alert('오류: ' + data.message);
                }
            })
            .catch(error => {
                sendButton.disabled = false;
                sendButton.innerHTML = originalText;
                console.error('Error:', error);
                alert('쪽지 전송 중 오류가 발생했습니다.');
            });
        }
        window.sendMessageFromModal = sendMessageFromModal;
        
        // 글자 수 카운터
        function updateCounter(inputId, counterId, maxLength) {
            const input = document.getElementById(inputId);
            const counter = document.getElementById(counterId);
            if (input && counter) {
                counter.textContent = input.value.length;
                if (input.value.length > maxLength) {
                    counter.style.color = '#dc3545';
                } else {
                    counter.style.color = '#6c757d';
                }
            }
        }
        window.updateCounter = updateCounter;
    </script>
    
    <!-- 쪽지 보내기 모달 -->
    <div id="messageModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-envelope"></i> 쪽지 보내기</h3>
                <span class="close" onclick="closeMessageModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="messageForm">
                    <!-- 받는 사람 -->
                    <div class="form-group">
                        <label>받는 사람</label>
                        <div class="receiver-info">
                            <i class="fas fa-user"></i>
                            <span id="messageReceiverName"></span>
                        </div>
                        <input type="hidden" id="messageReceiverId" name="receiverId">
                    </div>
                    
                    <!-- 제목 -->
                    <div class="form-group">
                        <label for="messageTitle">제목</label>
                        <input type="text" id="messageTitle" name="messageTitle" 
                               placeholder="쪽지 제목을 입력하세요" maxlength="100" required
                               oninput="updateCounter('messageTitle', 'messageTitleCounter', 100)">
                        <div class="counter-text">
                            <span id="messageTitleCounter">0</span> / 100
                        </div>
                    </div>
                    
                    <!-- 내용 -->
                    <div class="form-group">
                        <label for="messageContent">내용</label>
                        <textarea id="messageContent" name="messageContent" rows="6"
                                  placeholder="쪽지 내용을 입력하세요" maxlength="1000" required
                                  oninput="updateCounter('messageContent', 'messageContentCounter', 1000)"></textarea>
                        <div class="counter-text">
                            <span id="messageContentCounter">0</span> / 1000
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-cancel" onclick="closeMessageModal()">취소</button>
                <button type="button" class="btn-send" onclick="sendMessageFromModal()">
                    <i class="fas fa-paper-plane"></i> 쪽지 보내기
                </button>
            </div>
        </div>
    </div>
    
    <style>
        /* 쪽지 모달 스타일 */
        .modal {
            display: none;
            position: fixed;
            z-index: 10000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(5px);
        }
        
        .login-modal .modal-content {
            background-color: white;
            margin: 5% auto;
            padding: 0;
            border-radius: 15px;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 50px rgba(0, 0, 0, 0.3);
            animation: modalSlideDown 0.3s ease-out;
        }
        
        @keyframes modalSlideDown {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .modal-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 20px;
            border-radius: 15px 15px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-header h3 {
            margin: 0;
            font-size: 1.3rem;
        }
        
        .modal-header .close {
            color: white;
            font-size: 24px;
            cursor: pointer;
            padding: 5px;
            border-radius: 50%;
            width: 35px;
            height: 35px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.3s ease;
        }
        
        .modal-header .close:hover {
            background-color: rgba(255, 255, 255, 0.2);
        }
        
        .modal-body {
            padding: 20px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        
        .form-group input, .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s ease;
        }
        
        .form-group input:focus, .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .receiver-info {
            background: #f8f9fa;
            padding: 12px;
            border-radius: 8px;
            color: #495057;
            border: 2px solid #e0e0e0;
        }
        
        .receiver-info i {
            margin-right: 8px;
            color: #667eea;
        }
        
        .counter-text {
            text-align: right;
            font-size: 12px;
            color: #6c757d;
            margin-top: 5px;
        }
        
        .modal-footer {
            padding: 20px;
            border-top: 1px solid #e0e0e0;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .btn-cancel, .btn-send {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .btn-cancel {
            background: #6c757d;
            color: white;
        }
        
        .btn-cancel:hover {
            background: #5a6268;
        }
        
        .btn-send {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-send:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-send:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }
    </style>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>