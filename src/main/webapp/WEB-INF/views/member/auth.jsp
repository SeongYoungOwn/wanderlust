<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>로그인 & 회원가입 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        @import url("https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&display=swap");
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Montserrat", sans-serif;
        }

        body {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            min-height: 100vh;
            padding-top: 80px;
        }

        .container {
            background-color: #fff;
            border-radius: 30px;
            box-shadow: 0 5px 15px rgba(60, 48, 48, 0.35);
            position: relative;
            overflow: hidden;
            width: 900px;
            max-width: 100%;
            min-height: 680px;
        }

        .container p {
            font-size: 16px;
            line-height: 22px;
            letter-spacing: 0.3px;
            margin: 20px 0;
        }

        .container span {
            font-size: 14px;
            margin-bottom: 15px;
        }
        
        .container h1 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .container a {
            color: #333333;
            font-size: 13px;
            text-decoration: none;
            margin: 15px 0 10px;
        }

        .container button {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: #ffffff;
            font-size: 14px;
            padding: 12px 45px;
            border: 1px solid transparent;
            border-radius: 8px;
            font-weight: 600;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin-top: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .container button.hidden {
            background-color: transparent;
            border-color: #ffffff;
        }

        .container form {
            background-color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 20px 40px;
            height: 100%;
            overflow-y: auto;
        }

        .container input {
            background-color: #ffffff;
            border: 1px solid #ced4da;
            margin: 8px 0;
            padding: 12px 15px;
            font-size: 14px;
            border-radius: 6px;
            width: 100%;
            outline: none;
            transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
        }
        
        .container input:focus {
            border-color: #ff6b6b;
            box-shadow: 0 0 0 0.2rem rgba(255, 107, 107, 0.25);
        }
        
        .container input::placeholder {
            color: #6c757d;
            opacity: 1;
        }

        .form-container {
            position: absolute;
            top: 0;
            height: 100%;
            transition: all 0.6s ease-in-out;
        }

        .sign-in {
            left: 0;
            width: 50%;
            z-index: 2;
        }

        .container.active .sign-in {
            transform: translateX(100%);
        }

        .sign-up {
            left: 0;
            width: 50%;
            opacity: 0;
            z-index: 1;
        }

        .container.active .sign-up {
            transform: translateX(100%);
            opacity: 1;
            z-index: 5;
            animation: move 0.6s;
        }

        @keyframes move {
            0%, 49.99% {
                opacity: 0;
                z-index: 1;
            }
            50%, 100% {
                opacity: 1;
                z-index: 5;
            }
        }

        .toggle-container {
            position: absolute;
            top: 0;
            left: 50%;
            width: 50%;
            height: 100%;
            overflow: hidden;
            transition: all 0.6s ease-in-out;
            border-radius: 150px 0 0 100px;
            z-index: 1000;
        }

        .container.active .toggle-container {
            transform: translateX(-100%);
            border-radius: 0 150px 100px 0;
        }

        .toggle {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            height: 100%;
            color: #ffffff;
            position: relative;
            left: -100%;
            height: 100%;
            width: 200%;
            transform: translateX(0);
            transition: all 0.6s ease-in-out;
        }

        .container.active .toggle {
            transform: translateX(50%);
        }

        .toggle-panel {
            position: absolute;
            width: 50%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 0 30px;
            text-align: center;
            top: 0;
            transform: translateX(0);
            transition: all 0.6s ease-in-out;
        }

        .toggle-left {
            transform: translateX(-200%);
        }

        .container.active .toggle-left {
            transform: translateX(0);
        }

        .toggle-right {
            right: 0;
            transform: translateX(0);
        }

        .container.active .toggle-right {
            transform: translateX(200%);
        }

        /* Duplicate check button styling */
        .duplicate-check {
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 6px 0;
            width: 100%;
        }
        
        .duplicate-check input {
            flex: 1;
            margin: 0;
        }
        
        .duplicate-check .btn {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
            font-size: 14px;
            padding: 12px 15px;
            border: 1px solid transparent;
            border-radius: 6px;
            font-weight: 600;
            white-space: nowrap;
            cursor: pointer;
            transition: all 0.3s ease;
            height: 44px;
            min-width: 100px;
        }
        
        .duplicate-check .btn:hover {
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
        }

        .form-text {
            font-size: 12px;
            color: #6c757d;
            margin-top: 4px;
            margin-bottom: 5px;
        }

        .text-success {
            color: #28a745 !important;
        }

        .text-danger {
            color: #dc3545 !important;
        }

        .text-warning {
            color: #ffc107 !important;
        }

        .radio-group {
            display: flex;
            gap: 15px;
            margin: 10px 0;
            justify-content: center;
        }

        .radio-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .radio-item label {
            font-size: 14px;
            color: #495057;
            cursor: pointer;
        }
        
        .radio-item input[type="radio"] {
            width: 16px;
            height: 16px;
            margin: 0;
        }

        .alert {
            padding: 12px;
            margin: 10px 0;
            border-radius: 6px;
            font-size: 13px;
            border: 1px solid transparent;
        }

        .alert-success {
            background: #d1fae5;
            color: #047857;
        }

        .alert-danger {
            background: #fee2e2;
            color: #dc2626;
        }

        .btn-close {
            float: right;
            background: none;
            border: none;
            font-size: 16px;
            cursor: pointer;
        }

        /* Enhanced Responsive Design */
        @media (max-width: 1024px) {
            .container {
                width: 90%;
                max-width: 750px;
                min-height: 600px;
            }
            
            .toggle-container {
                border-radius: 120px 0 0 80px;
            }
            
            .container.active .toggle-container {
                border-radius: 0 120px 80px 0;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-top: 60px;
                padding-bottom: 20px;
            }
            
            .container {
                width: 95%;
                max-width: none;
                margin: 10px;
                min-height: auto;
                flex-direction: column;
                position: relative;
                border-radius: 20px;
            }
            
            .form-container {
                position: relative !important;
                width: 100% !important;
                height: auto !important;
                opacity: 1 !important;
                transform: none !important;
                z-index: auto !important;
            }
            
            .sign-up {
                display: none;
            }
            
            .container.active .sign-up {
                display: block;
                animation: none;
                transform: none;
            }
            
            .container.active .sign-in {
                display: none;
                transform: none;
            }
            
            .toggle-container {
                position: relative !important;
                left: 0 !important;
                top: auto !important;
                width: 100% !important;
                height: auto !important;
                border-radius: 0 0 20px 20px !important;
                order: 1;
                overflow: visible;
            }
            
            .container.active .toggle-container {
                transform: none !important;
                border-radius: 0 0 20px 20px !important;
            }
            
            .toggle {
                position: relative !important;
                left: 0 !important;
                width: 100% !important;
                height: 120px !important;
                transform: none !important;
                border-radius: 0 0 20px 20px;
            }
            
            .container.active .toggle {
                transform: none !important;
            }
            
            .toggle-panel {
                position: relative !important;
                width: 100% !important;
                height: 120px !important;
                transform: none !important;
                padding: 20px;
            }
            
            .toggle-left {
                transform: none !important;
                display: none;
            }
            
            .container.active .toggle-left {
                display: flex;
                transform: none !important;
            }
            
            .toggle-right {
                display: flex;
                transform: none !important;
            }
            
            .container.active .toggle-right {
                display: none;
                transform: none !important;
            }
            
            .container form {
                padding: 25px 20px;
            }
            
            .container h1 {
                font-size: 1.6rem;
                margin-bottom: 1.5rem;
            }
            
            .container button {
                padding: 14px 20px;
                font-size: 16px;
                margin-top: 20px;
                border-radius: 12px;
                min-height: 48px;
            }
            
            .container input {
                padding: 14px 16px;
                font-size: 16px;
                margin: 10px 0;
                border-radius: 12px;
                min-height: 48px;
            }
            
            .duplicate-check .btn {
                padding: 14px 16px;
                min-height: 48px;
                min-width: 90px;
                font-size: 14px;
            }
            
            .radio-group {
                margin: 15px 0;
                gap: 20px;
            }
            
            .radio-item input[type="radio"] {
                width: 18px;
                height: 18px;
            }
        }
        
        @media (max-width: 480px) {
            body {
                padding-top: 50px;
            }
            
            .container {
                width: calc(100% - 20px);
                margin: 10px;
                border-radius: 16px;
            }
            
            .container form {
                padding: 20px 16px;
            }
            
            .container h1 {
                font-size: 1.4rem;
                margin-bottom: 1rem;
            }
            
            .container button {
                padding: 16px 20px;
                font-size: 15px;
            }
            
            .container input {
                padding: 16px 14px;
                font-size: 15px;
            }
            
            .duplicate-check {
                gap: 6px;
            }
            
            .duplicate-check .btn {
                min-width: 80px;
                font-size: 13px;
                padding: 16px 12px;
            }
            
            .toggle {
                height: 100px !important;
            }
            
            .toggle-panel {
                height: 100px !important;
                padding: 15px;
            }
            
            .toggle-panel h1 {
                font-size: 1.3rem;
            }
            
            .toggle-panel p {
                font-size: 14px;
                margin: 10px 0;
            }
            
            .toggle-panel button {
                padding: 10px 20px;
                font-size: 14px;
            }
        }

        /* Touch and Interaction Improvements */
        @media (hover: none) and (pointer: coarse) {
            .container button:hover {
                transform: none;
                box-shadow: 0 5px 15px rgba(60, 48, 48, 0.35);
            }
            
            .container button:active {
                transform: scale(0.98);
            }
            
            .duplicate-check .btn:hover {
                transform: none;
            }
            
            .duplicate-check .btn:active {
                transform: scale(0.95);
            }
        }

        /* Loading States */
        .loading {
            position: relative;
            pointer-events: none;
            opacity: 0.7;
        }
        
        .loading::after {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 20px;
            height: 20px;
            margin: -10px 0 0 -10px;
            border: 2px solid #fff;
            border-top-color: transparent;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }
        
        .form-message {
            padding: 12px 16px;
            margin: 12px 0;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .form-message.success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #047857;
            border: 1px solid #34d399;
        }
        
        .form-message.error {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #dc2626;
            border: 1px solid #f87171;
        }
        
        .form-message.loading {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1d4ed8;
            border: 1px solid #60a5fa;
        }
        
        /* Screen Reader Only - Accessibility */
        .sr-only {
            position: absolute !important;
            width: 1px !important;
            height: 1px !important;
            padding: 0 !important;
            margin: -1px !important;
            overflow: hidden !important;
            clip: rect(0, 0, 0, 0) !important;
            white-space: nowrap !important;
            border: 0 !important;
        }
        
        /* Focus indicators for accessibility */
        .container input:focus,
        .container button:focus {
            outline: 3px solid #ff6b6b;
            outline-offset: 2px;
        }
        
        .radio-item input[type="radio"]:focus {
            outline: 2px solid #ff6b6b;
            outline-offset: 1px;
        }
        
        /* High contrast mode support */
        @media (prefers-contrast: high) {
            .container {
                border: 2px solid #000;
            }
            
            .container input,
            .container button {
                border: 2px solid #000;
            }
            
            .form-text.text-success {
                color: #000 !important;
                background: #90EE90 !important;
                padding: 4px 8px;
                border-radius: 4px;
            }
            
            .form-text.text-danger {
                color: #000 !important;
                background: #FFB6C1 !important;
                padding: 4px 8px;
                border-radius: 4px;
            }
        }
        
        /* Reduced motion support */
        @media (prefers-reduced-motion: reduce) {
            .container,
            .form-container,
            .toggle,
            .toggle-panel,
            .toggle-container,
            .container button,
            .form-text {
                transition: none !important;
                animation: none !important;
                transform: none !important;
            }
            
            .loading::after {
                animation: none !important;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="container" id="container">
        <!-- 회원가입 폼 -->
        <div class="form-container sign-up">
            <form action="${pageContext.request.contextPath}/member/signup" method="post" id="signupForm" 
                  role="form" aria-labelledby="signup-title">
                <h1 id="signup-title">회원가입</h1>
                <!-- 에러/성공 메시지 -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger" role="alert" aria-live="polite">
                        <i class="fas fa-exclamation-triangle" aria-hidden="true"></i> ${error}
                        <button type="button" class="btn-close" onclick="this.parentElement.style.display='none'" 
                                aria-label="메시지 닫기">×</button>
                    </div>
                </c:if>
                
                <c:if test="${not empty success}">
                    <div class="alert alert-success" role="alert" aria-live="polite">
                        <i class="fas fa-check-circle" aria-hidden="true"></i> ${success}
                        <button type="button" class="btn-close" onclick="this.parentElement.style.display='none'" 
                                aria-label="메시지 닫기">×</button>
                    </div>
                </c:if>

                <div class="duplicate-check">
                    <input type="text" id="signupUserId" name="userId" required 
                           placeholder="아이디 (4-20자)" minlength="4" maxlength="20"
                           aria-describedby="userIdCheck" autocomplete="username">
                    <button type="button" class="btn" onclick="checkUserId()" 
                            aria-describedby="userIdCheck">중복확인</button>
                </div>
                <div class="form-text" id="userIdCheck" role="status" aria-live="polite">4-20자의 영문, 숫자 조합</div>

                <input type="text" name="userName" placeholder="실제 이름" required maxlength="50"
                       aria-label="실제 이름" autocomplete="name">
                
                <input type="number" name="age" placeholder="나이" required min="18" max="100"
                       aria-label="나이" autocomplete="age">
                
                <div class="duplicate-check">
                    <input type="text" id="signupNickname" name="nickname" required 
                           placeholder="닉네임 (2-20자)" minlength="2" maxlength="20"
                           aria-describedby="nicknameCheck" autocomplete="nickname">
                    <button type="button" class="btn" onclick="checkNickname()" 
                            aria-describedby="nicknameCheck">중복확인</button>
                </div>
                <div class="form-text" id="nicknameCheck" role="status" aria-live="polite">2-20자의 한글, 영문, 숫자 조합</div>

                <fieldset class="radio-group" role="radiogroup" aria-labelledby="gender-label">
                    <legend id="gender-label" class="sr-only">성별 선택</legend>
                    <div class="radio-item">
                        <input type="radio" name="gender" id="genderM" value="M" required>
                        <label for="genderM">남자</label>
                    </div>
                    <div class="radio-item">
                        <input type="radio" name="gender" id="genderF" value="F" required>
                        <label for="genderF">여자</label>
                    </div>
                </fieldset>

                <input type="password" id="signupUserPassword" name="userPassword" 
                       placeholder="비밀번호 (6자 이상)" required minlength="6"
                       aria-describedby="passwordCheck" autocomplete="new-password">
                <input type="password" id="confirmPassword" placeholder="비밀번호 확인" required minlength="6"
                       aria-describedby="passwordCheck" aria-label="비밀번호 확인" autocomplete="new-password">
                <div class="form-text" id="passwordCheck" role="status" aria-live="polite"></div>
                
                <div class="email-verification-group">
                    <div style="display: flex; gap: 10px; margin: 8px 0;">
                        <input type="email" name="userEmail" id="userEmail" placeholder="이메일" required
                               aria-label="이메일 주소" autocomplete="email" style="flex: 1;">
                        <button type="button" id="sendCodeBtn" onclick="sendVerificationCode()"
                                style="padding: 12px 20px; min-width: 120px;">인증번호 발송</button>
                    </div>
                    <div id="verificationSection" style="display: none;">
                        <div style="display: flex; gap: 10px; margin: 8px 0;">
                            <input type="text" id="verificationCode" placeholder="인증번호 6자리"
                                   maxlength="6" pattern="[0-9]{6}" style="flex: 1;">
                            <button type="button" id="verifyCodeBtn" onclick="verifyCode()"
                                    style="padding: 12px 20px; min-width: 120px;">인증 확인</button>
                        </div>
                        <div style="display: flex; justify-content: space-between; margin: 8px 0;">
                            <span id="timer" style="color: #ff6b6b; font-size: 14px; font-weight: 600;"></span>
                            <button type="button" id="resendBtn" onclick="resendVerificationCode()"
                                    style="background: none; border: none; color: #4ecdc4;
                                           text-decoration: underline; cursor: pointer; font-size: 14px;">새 인증번호 발송</button>
                        </div>
                    </div>
                    <input type="hidden" id="emailVerified" name="emailVerified" value="false">
                </div>

                <button type="submit" aria-describedby="signup-title">회원가입</button>
            </form>
        </div>

        <!-- 로그인 폼 -->
        <div class="form-container sign-in">
            <form action="${pageContext.request.contextPath}/member/login" method="post"
                  role="form" aria-labelledby="login-title">
                <h1 id="login-title">로그인</h1>

                <!-- returnUrl 파라미터 전달 -->
                <c:if test="${param.returnUrl != null}">
                    <input type="hidden" name="returnUrl" value="${param.returnUrl}">
                </c:if>

                <input type="text" name="userId" placeholder="아이디" required
                       aria-label="아이디" autocomplete="username">
                <input type="password" name="userPassword" placeholder="비밀번호" required
                       aria-label="비밀번호" autocomplete="current-password">

                <button type="submit" aria-describedby="login-title">로그인</button>
            </form>
        </div>

        <!-- 토글 패널 -->
        <div class="toggle-container">
            <div class="toggle">
                <div class="toggle-panel toggle-left">
                    <h1>환영합니다!</h1>
                    <p>이미 계정이 있으시나요? 로그인해주세요</p>
                    <button class="hidden" id="login" type="button" 
                            aria-label="로그인 폼으로 전환">로그인</button>
                </div>
                <div class="toggle-panel toggle-right">
                    <h1>안녕하세요!</h1>
                    <p>계정이 없으시다면 회원가입을 해주세요</p>
                    <button class="hidden" id="register" type="button" 
                            aria-label="회원가입 폼으로 전환">회원가입</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Check for suspended account error message
        <c:if test="${not empty error && fn:contains(error, '정지')}">
            alert("${error}");
        </c:if>

        const container = document.getElementById('container');
        const registerBtn = document.getElementById('register');
        const loginBtn = document.getElementById('login');
        
        registerBtn.addEventListener('click', () => {
            container.classList.add("active");
        });
        
        loginBtn.addEventListener('click', () => {
            container.classList.remove("active");
        });

        // Utility function for validation messages
        function showValidationMessage(element, message, type) {
            element.textContent = message;
            element.className = 'form-text text-' + type;
            
            // Add visual feedback animation
            element.style.transform = 'scale(0.95)';
            setTimeout(() => {
                element.style.transform = 'scale(1)';
            }, 100);
        }
        
        // Enhanced password validation
        document.getElementById('signupUserPassword').addEventListener('input', function() {
            const password = this.value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const checkDiv = document.getElementById('passwordCheck');
            
            if (password === '') {
                showValidationMessage(checkDiv, '6자 이상의 비밀번호를 입력해주세요', '');
                return;
            }
            
            // Password strength validation
            if (password.length < 6) {
                showValidationMessage(checkDiv, '⚠ 비밀번호는 최소 6자 이상이어야 합니다', 'warning');
            } else if (password.length < 8) {
                showValidationMessage(checkDiv, '⚠ 보안을 위해 8자 이상을 권장합니다', 'warning');
            } else {
                showValidationMessage(checkDiv, '✓ 사용 가능한 비밀번호입니다', 'success');
            }
            
            // Recheck confirm password if it exists
            if (confirmPassword) {
                validatePasswordConfirmation();
            }
        });
        
        // Enhanced password confirmation validation
        document.getElementById('confirmPassword').addEventListener('input', validatePasswordConfirmation);
        
        function validatePasswordConfirmation() {
            const password = document.getElementById('signupUserPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const checkDiv = document.getElementById('passwordCheck');
            
            if (confirmPassword === '') {
                if (password.length >= 6) {
                    showValidationMessage(checkDiv, '비밀번호 확인을 입력해주세요', '');
                }
            } else if (password === confirmPassword) {
                showValidationMessage(checkDiv, '✓ 비밀번호가 일치합니다', 'success');
            } else {
                showValidationMessage(checkDiv, '✗ 비밀번호가 일치하지 않습니다', 'danger');
            }
        }
        
        // Enhanced user ID validation
        let userIdChecked = false;
        function checkUserId() {
            const userId = document.getElementById('signupUserId').value;
            const checkDiv = document.getElementById('userIdCheck');
            const button = event.target;
            
            if (!userId || userId.length < 4) {
                showValidationMessage(checkDiv, '⚠ 4자 이상 입력해주세요', 'warning');
                userIdChecked = false;
                return;
            }
            
            // Validate format
            const userIdRegex = /^[a-zA-Z0-9]{4,20}$/;
            if (!userIdRegex.test(userId)) {
                showValidationMessage(checkDiv, '⚠ 4-20자의 영문, 숫자만 사용 가능합니다', 'warning');
                userIdChecked = false;
                return;
            }
            
            // Show loading state
            button.classList.add('loading');
            button.disabled = true;
            showValidationMessage(checkDiv, '확인 중...', 'loading');
            
            fetch('${pageContext.request.contextPath}/member/check-userid?userId=' + encodeURIComponent(userId))
                .then(response => {
                    if (!response.ok) {
                        throw new Error('네트워크 오류가 발생했습니다.');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.exists) {
                        showValidationMessage(checkDiv, '✗ ' + data.message, 'error');
                        userIdChecked = false;
                    } else {
                        showValidationMessage(checkDiv, '✓ ' + data.message, 'success');
                        userIdChecked = true;
                    }
                })
                .catch(error => {
                    console.error('UserId check error:', error);
                    showValidationMessage(checkDiv, '⚠ 서버 연결에 실패했습니다. 다시 시도해주세요.', 'error');
                    userIdChecked = false;
                })
                .finally(() => {
                    button.classList.remove('loading');
                    button.disabled = false;
                });
        }
        
        // Enhanced nickname validation
        let nicknameChecked = false;
        function checkNickname() {
            const nickname = document.getElementById('signupNickname').value;
            const checkDiv = document.getElementById('nicknameCheck');
            const button = event.target;
            
            if (!nickname || nickname.length < 2) {
                showValidationMessage(checkDiv, '⚠ 2자 이상 입력해주세요', 'warning');
                nicknameChecked = false;
                return;
            }
            
            // Validate format
            const nicknameRegex = /^[가-힣a-zA-Z0-9]{2,20}$/;
            if (!nicknameRegex.test(nickname)) {
                showValidationMessage(checkDiv, '⚠ 2-20자의 한글, 영문, 숫자만 사용 가능합니다', 'warning');
                nicknameChecked = false;
                return;
            }
            
            // Show loading state
            button.classList.add('loading');
            button.disabled = true;
            showValidationMessage(checkDiv, '확인 중...', 'loading');
            
            fetch('${pageContext.request.contextPath}/member/check-nickname?nickname=' + encodeURIComponent(nickname))
                .then(response => {
                    if (!response.ok) {
                        throw new Error('네트워크 오류가 발생했습니다.');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.exists) {
                        showValidationMessage(checkDiv, '✗ ' + data.message, 'error');
                        nicknameChecked = false;
                    } else {
                        showValidationMessage(checkDiv, '✓ ' + data.message, 'success');
                        nicknameChecked = true;
                    }
                })
                .catch(error => {
                    console.error('Nickname check error:', error);
                    showValidationMessage(checkDiv, '⚠ 서버 연결에 실패했습니다. 다시 시도해주세요.', 'error');
                    nicknameChecked = false;
                })
                .finally(() => {
                    button.classList.remove('loading');
                    button.disabled = false;
                });
        }
        
        // 아이디 입력 시 중복 확인 초기화
        document.getElementById('signupUserId').addEventListener('input', function() {
            userIdChecked = false;
            const checkDiv = document.getElementById('userIdCheck');
            checkDiv.textContent = '4-20자의 영문, 숫자 조합';
            checkDiv.className = 'form-text';
        });
        
        // 닉네임 입력 시 중복 확인 초기화
        document.getElementById('signupNickname').addEventListener('input', function() {
            nicknameChecked = false;
            const checkDiv = document.getElementById('nicknameCheck');
            checkDiv.textContent = '2-20자의 한글, 영문, 숫자 조합';
            checkDiv.className = 'form-text';
        });
        
        // Enhanced form validation and submission
        document.getElementById('signupForm').addEventListener('submit', function(e) {
            const formData = validateSignupForm();
            if (!formData.isValid) {
                e.preventDefault();
                showFormMessage(formData.message, 'error');
                focusFirstError();
                return;
            }
            
            // Show loading state but allow form to submit normally
            const submitButton = this.querySelector('button[type="submit"]');
            submitButton.classList.add('loading');
            submitButton.disabled = true;
            
            // Re-enable button after a delay in case of validation errors
            setTimeout(() => {
                submitButton.classList.remove('loading');
                submitButton.disabled = false;
            }, 5000);
        });
        
        // Enhanced login form submission
        const loginForm = document.querySelector('.sign-in form');
        if (loginForm) {
            loginForm.addEventListener('submit', function(e) {
                const userId = this.querySelector('input[name="userId"]').value.trim();
                const password = this.querySelector('input[name="userPassword"]').value;
                
                if (!userId || !password) {
                    e.preventDefault();
                    showFormMessage('아이디와 비밀번호를 모두 입력해주세요.', 'error');
                    return;
                }
                
                // Show loading state but allow form to submit normally
                const submitButton = this.querySelector('button[type="submit"]');
                submitButton.classList.add('loading');
                submitButton.disabled = true;
                
                // Re-enable button after a delay in case of validation errors
                setTimeout(() => {
                    submitButton.classList.remove('loading');
                    submitButton.disabled = false;
                }, 5000);
            });
        }
        
        // Form validation helper
        function validateSignupForm() {
            const userId = document.getElementById('signupUserId').value.trim();
            const userName = document.querySelector('input[name="userName"]').value.trim();
            const nickname = document.getElementById('signupNickname').value.trim();
            const password = document.getElementById('signupUserPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const email = document.querySelector('input[name="userEmail"]').value.trim();
            const gender = document.querySelector('input[name="gender"]:checked');
            
            if (!userId || userId.length < 4) {
                return { isValid: false, message: '아이디를 4자 이상 입력해주세요.' };
            }
            
            if (!userName) {
                return { isValid: false, message: '이름을 입력해주세요.' };
            }
            
            if (!nickname || nickname.length < 2) {
                return { isValid: false, message: '닉네임을 2자 이상 입력해주세요.' };
            }
            
            if (!password || password.length < 6) {
                return { isValid: false, message: '비밀번호를 6자 이상 입력해주세요.' };
            }
            
            if (password !== confirmPassword) {
                return { isValid: false, message: '비밀번호가 일치하지 않습니다.' };
            }
            
            if (!email || !isValidEmail(email)) {
                return { isValid: false, message: '올바른 이메일 주소를 입력해주세요.' };
            }
            
            if (!gender) {
                return { isValid: false, message: '성별을 선택해주세요.' };
            }
            
            const age = document.querySelector('input[name="age"]').value;
            if (!age || age < 18 || age > 100) {
                return { isValid: false, message: '나이를 올바르게 입력해주세요 (18-100세).' };
            }
            
            if (!userIdChecked) {
                return { isValid: false, message: '아이디 중복 확인을 먼저 진행해주세요.' };
            }
            
            if (!nicknameChecked) {
                return { isValid: false, message: '닉네임 중복 확인을 먼저 진행해주세요.' };
            }
            
            return { isValid: true };
        }
        
        // Email verification variables
        let timerInterval;
        let timeLeft = 300; // 5 minutes in seconds

        // Send verification code function
        function sendVerificationCode() {
            const email = document.getElementById('userEmail').value;

            if (!email || !isValidEmail(email)) {
                alert('올바른 이메일 주소를 입력해주세요.');
                return;
            }

            const sendBtn = document.getElementById('sendCodeBtn');
            sendBtn.disabled = true;
            sendBtn.textContent = '발송 중...';

            fetch('${pageContext.request.contextPath}/member/api/send-verification-code', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'email=' + encodeURIComponent(email)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    document.getElementById('verificationSection').style.display = 'block';

                    // 이메일 필드를 읽기 전용으로 만들고 스타일 변경
                    const emailField = document.getElementById('userEmail');
                    emailField.readOnly = true;
                    emailField.style.backgroundColor = '#f5f5f5';
                    emailField.style.cursor = 'not-allowed';

                    // 버튼 텍스트 변경
                    sendBtn.textContent = '재발송';

                    // 타이머 시작
                    startTimer();
                } else {
                    alert(data.message);
                }
                sendBtn.disabled = false;
            })
            .catch(error => {
                console.error('Error:', error);
                alert('인증번호 발송 중 오류가 발생했습니다.\n콘솔에서 자세한 오류를 확인하세요.');
                sendBtn.disabled = false;
                sendBtn.textContent = '인증번호 발송';
            });
        }

        // Verify code function
        function verifyCode() {
            const email = document.getElementById('userEmail').value;
            const code = document.getElementById('verificationCode').value;

            if (!code || code.length !== 6) {
                alert('6자리 인증번호를 입력해주세요.');
                return;
            }

            const verifyBtn = document.getElementById('verifyCodeBtn');
            verifyBtn.disabled = true;
            verifyBtn.textContent = '확인 중...';

            fetch('${pageContext.request.contextPath}/member/api/verify-code', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'email=' + encodeURIComponent(email) + '&code=' + code
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    document.getElementById('emailVerified').value = 'true';
                    document.getElementById('verificationSection').style.display = 'none';
                    document.getElementById('sendCodeBtn').style.display = 'none';

                    // 이메일 필드를 영구적으로 읽기 전용으로
                    const emailField = document.getElementById('userEmail');
                    emailField.style.backgroundColor = '#e8f5e9';
                    emailField.readOnly = true;
                    emailField.style.cursor = 'not-allowed';

                    clearInterval(timerInterval);

                    // 인증 완료 표시 (중복 방지)
                    if (!document.getElementById('email-verified-msg')) {
                        const successMsg = document.createElement('span');
                        successMsg.id = 'email-verified-msg';
                        successMsg.style.color = '#4ecdc4';
                        successMsg.style.fontSize = '14px';
                        successMsg.style.marginLeft = '10px';
                        successMsg.textContent = '✓ 인증 완료';
                        emailField.parentNode.appendChild(successMsg);
                    }
                } else {
                    alert(data.message);
                    document.getElementById('verificationCode').value = '';
                }
                verifyBtn.disabled = false;
                verifyBtn.textContent = '인증 확인';
            })
            .catch(error => {
                console.error('Error:', error);
                alert('인증 확인 중 오류가 발생했습니다.');
                verifyBtn.disabled = false;
                verifyBtn.textContent = '인증 확인';
            });
        }

        // Timer function
        function startTimer() {
            timeLeft = 300; // 5분 = 300초
            clearInterval(timerInterval);

            // 타이머 즉시 표시
            updateTimerDisplay();

            timerInterval = setInterval(() => {
                timeLeft--;

                if (timeLeft <= 0) {
                    clearInterval(timerInterval);
                    document.getElementById('timer').textContent = '⏰ 시간 만료 - 재발송 필요';
                    document.getElementById('timer').style.color = '#dc3545';
                    document.getElementById('verifyCodeBtn').disabled = true;
                    document.getElementById('verificationCode').disabled = true;
                    return;
                }

                updateTimerDisplay();
            }, 1000);
        }

        // 타이머 표시 업데이트 함수
        function updateTimerDisplay() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            const timerElement = document.getElementById('timer');

            timerElement.textContent = '⏰ 남은 시간: ' + minutes + ':' + seconds.toString().padStart(2, '0');

            // 30초 남았을 때 경고 색상
            if (timeLeft <= 30) {
                timerElement.style.color = '#dc3545';
                timerElement.style.fontWeight = 'bold';
            } else if (timeLeft <= 60) {
                timerElement.style.color = '#ffc107';
            } else {
                timerElement.style.color = '#28a745';
            }
        }

        // Email validation helper
        // Resend verification code function (재발송 시 이메일 수정 가능)
        function resendVerificationCode() {
            if (confirm('새로운 인증번호를 발송하시겠습니까?\n이메일 주소를 변경하실 수도 있습니다.')) {
                // 타이머 정지
                clearInterval(timerInterval);

                // 이메일 필드 수정 가능하게 변경
                const emailField = document.getElementById('userEmail');
                emailField.readOnly = false;
                emailField.style.backgroundColor = '#ffffff';
                emailField.style.cursor = 'text';
                emailField.focus();

                // 인증 섹션 초기화
                document.getElementById('verificationCode').value = '';
                document.getElementById('verificationCode').disabled = false;
                document.getElementById('verifyCodeBtn').disabled = false;

                // 버튼 텍스트 원복
                document.getElementById('sendCodeBtn').textContent = '인증번호 발송';

                // 타이머 초기화
                document.getElementById('timer').textContent = '이메일 확인 후 인증번호를 재발송해주세요.';
                document.getElementById('timer').style.color = '#6c757d';

                alert('이메일 주소를 확인하고 인증번호 발송 버튼을 클릭해주세요.');
            }
        }

        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }
        
        // Form message display helper
        function showFormMessage(message, type) {
            // Remove existing messages
            const existingMessages = document.querySelectorAll('.form-message');
            existingMessages.forEach(msg => msg.remove());
            
            // Create new message
            const messageDiv = document.createElement('div');
            messageDiv.className = 'form-message ' + type;
            
            const icon = type === 'success' ? 'fa-check-circle' : 
                        type === 'error' ? 'fa-exclamation-triangle' : 'fa-info-circle';
            
            messageDiv.innerHTML =
                '<i class="fas ' + icon + '"></i>' +
                '<span>' + message + '</span>';
            
            // Insert message at the top of the active form
            const activeForm = document.querySelector('.container.active .form-container form') || 
                              document.querySelector('.sign-in form');
            if (activeForm) {
                activeForm.insertBefore(messageDiv, activeForm.firstElementChild);
                
                // Auto remove after 5 seconds
                setTimeout(() => {
                    if (messageDiv.parentNode) {
                        messageDiv.remove();
                    }
                }, 5000);
            }
        }

        // Keyboard navigation support
        document.addEventListener('keydown', function(e) {
            // Toggle between forms with Tab + Enter when focused on toggle buttons
            if (e.key === 'Enter' || e.key === ' ') {
                if (e.target.id === 'register') {
                    e.preventDefault();
                    container.classList.add("active");
                    // Focus on first input of signup form
                    setTimeout(() => {
                        document.getElementById('signupUserId').focus();
                    }, 100);
                } else if (e.target.id === 'login') {
                    e.preventDefault();
                    container.classList.remove("active");
                    // Focus on first input of login form
                    setTimeout(() => {
                        document.querySelector('.sign-in input[name="userId"]').focus();
                    }, 100);
                }
            }
            
            // Escape key to reset form state
            if (e.key === 'Escape') {
                // Remove any active error states
                const errorMessages = document.querySelectorAll('.form-message');
                errorMessages.forEach(msg => msg.remove());
            }
        });
        
        // Enhanced focus management
        function focusFirstError() {
            const errorElement = document.querySelector('.text-danger');
            if (errorElement) {
                const associatedInput = document.querySelector('[aria-describedby="' + errorElement.id + '"]');
                if (associatedInput) {
                    associatedInput.focus();
                    associatedInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            }
        }
        
        // Announce form state changes to screen readers
        function announceToScreenReader(message) {
            const announcement = document.createElement('div');
            announcement.setAttribute('aria-live', 'assertive');
            announcement.setAttribute('aria-atomic', 'true');
            announcement.className = 'sr-only';
            announcement.textContent = message;
            document.body.appendChild(announcement);
            
            // Remove after announcement
            setTimeout(() => {
                document.body.removeChild(announcement);
            }, 1000);
        }
        
        // URL 파라미터 확인하여 초기 탭 설정
        const urlParams = new URLSearchParams(window.location.search);
        const mode = urlParams.get('mode');
        if (mode === 'signup') {
            container.classList.add("active");
            announceToScreenReader('회원가입 폼이 활성화되었습니다');
        } else {
            announceToScreenReader('로그인 폼이 활성화되었습니다');
        }
        
        // Success message handling from URL params
        const successMessage = urlParams.get('success');
        if (successMessage) {
            setTimeout(() => {
                showFormMessage(decodeURIComponent(successMessage), 'success');
            }, 500);
        }
        
        // Error message handling from URL params
        const errorMessage = urlParams.get('error');
        if (errorMessage) {
            setTimeout(() => {
                showFormMessage(decodeURIComponent(errorMessage), 'error');
            }, 500);
        }
    </script>

</body>
</html>