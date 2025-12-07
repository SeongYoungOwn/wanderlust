<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>AI 여행 플래너 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        /* CSS Variables from home.jsp */
        :root {
            --primary-color: #0052D4;
            --secondary-color: #4364F7;
            --accent-color: #FF8C00;
            --text-dark: #1A202C;
            --text-light: #4A5568;
            --text-muted: #718096;
            --bg-main: #F7FAFC;
            --bg-light: #FFFFFF;
            --gradient-primary: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            --gradient-accent: linear-gradient(135deg, var(--accent-color), #FF6B6B);
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--bg-header-gradient);
            background-attachment: fixed;
            color: var(--text-primary);
            line-height: 1.6;
            overflow: hidden;
            padding: 0;
            margin: 0;
            height: 100vh;
        }

        .container {
            width: 100%;
            height: 100vh;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
        }

        .chat-container {
            max-width: 1400px;
            width: 90%;
            height: calc(100vh - 70px);
            margin: 70px auto 0;
            display: flex;
            flex-direction: column;
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(20px);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
            transition: none;
        }
        
        
        .chat-header {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white;
            padding: 1rem;
            text-align: center;
            position: relative;
            overflow: hidden;
            flex-shrink: 0;
            height: auto;
        }
        
        .chat-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="stars" width="20" height="20" patternUnits="userSpaceOnUse"><circle cx="10" cy="10" r="1" fill="white" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23stars)"/></svg>');
            animation: twinkle 20s ease-in-out infinite;
        }
        
        @keyframes twinkle {
            0%, 100% { opacity: 0.5; }
            50% { opacity: 1; }
        }
        
        .chat-header h2 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.3rem;
            z-index: 10;
            position: relative;
            text-shadow: 0 4px 20px rgba(0,0,0,0.3);
            letter-spacing: -0.5px;
            line-height: 1.2;
        }
        
        .chat-header h2 i {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            filter: drop-shadow(0 2px 4px rgba(255, 255, 255, 0.3));
            margin-right: 1rem;
        }
        
        .chat-header p {
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.95);
            font-weight: 300;
            z-index: 10;
            position: relative;
            max-width: 500px;
            margin: 0 auto;
            line-height: 1.3;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }
        
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 15px 25px;
            background: var(--bg-primary);
            height: 100%;
            position: relative;
        }
        
        .chat-messages::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 107, 107, 0.2), transparent);
        }
        
        .message {
            margin-bottom: 32px;
            animation: fadeIn 0.6s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .message.user {
            text-align: right;
        }
        
        .message.ai {
            text-align: left;
        }
        
        .message-content {
            display: inline-block;
            padding: 16px 20px;
            border-radius: 20px;
            max-width: 85%;
            word-wrap: break-word;
            white-space: pre-wrap;
            font-size: 0.9rem;
            line-height: 1.5;
            position: relative;
            min-height: 16px;
            backdrop-filter: blur(10px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        .user .message-content {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white;
            box-shadow: 
                0 8px 32px rgba(255, 107, 107, 0.25),
                0 4px 16px rgba(78, 205, 196, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .user .message-content:hover {
            transform: translateY(-2px);
            box-shadow: 
                0 12px 40px rgba(255, 107, 107, 0.3),
                0 6px 20px rgba(78, 205, 196, 0.2);
        }
        
        .ai .message-content {
            background: var(--bg-card);
            color: var(--text-primary);
            border: 1px solid rgba(255, 107, 107, 0.15);
            box-shadow: 
                0 8px 32px rgba(255, 107, 107, 0.08),
                0 4px 16px rgba(0, 0, 0, 0.04),
                inset 0 1px 0 rgba(255, 255, 255, 0.8);
        }
        
        .ai .message-content:hover {
            transform: translateY(-2px);
            box-shadow: 
                0 12px 40px rgba(255, 107, 107, 0.12),
                0 6px 20px rgba(0, 0, 0, 0.06),
                inset 0 1px 0 rgba(255, 255, 255, 0.9);
            border-color: rgba(255, 107, 107, 0.25);
        }
        
        /* Copy Button Styles */
        .copy-button {
            position: absolute;
            top: 12px;
            right: 12px;
            background: rgba(255, 107, 107, 0.08);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 107, 107, 0.2);
            color: #ff6b6b;
            padding: 8px 14px;
            border-radius: 16px;
            cursor: pointer;
            font-size: 0.82rem;
            font-weight: 600;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            opacity: 0;
            transform: translateY(-8px) scale(0.9);
            box-shadow: 0 4px 16px rgba(255, 107, 107, 0.1);
        }
        
        .ai .message-content:hover .copy-button {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
        
        .copy-button:hover {
            background: rgba(255, 107, 107, 0.15);
            border-color: rgba(255, 107, 107, 0.4);
            transform: translateY(-2px) scale(1.05);
            box-shadow: 0 6px 20px rgba(255, 107, 107, 0.2);
        }
        
        .copy-button.copied {
            background: rgba(40, 167, 69, 0.12);
            border-color: rgba(40, 167, 69, 0.35);
            color: #28a745;
            box-shadow: 0 6px 20px rgba(40, 167, 69, 0.15);
        }
        
        .copy-button i {
            margin-right: 4px;
        }
        
        .chat-input-container {
            padding: 15px 0;
            background: linear-gradient(135deg, rgba(253, 251, 247, 0.95) 0%, rgba(248, 249, 250, 0.9) 100%);
            backdrop-filter: blur(20px);
            border-top: 1px solid rgba(255, 107, 107, 0.12);
            position: relative;
            flex-shrink: 0;
        }
        
        .chat-input-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(255, 107, 107, 0.3), transparent);
        }
        
        .quick-options {
            margin-bottom: 16px;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            padding: 0 30px;
        }
        
        .quick-option-btn {
            margin: 0;
            padding: 10px 16px;
            border: 1px solid rgba(255, 107, 107, 0.2);
            border-radius: 24px;
            background: var(--bg-card);
            backdrop-filter: blur(10px);
            cursor: pointer;
            font-weight: 600;
            font-size: 0.8rem;
            color: var(--accent-primary);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 16px rgba(255, 107, 107, 0.08);
        }
        
        .quick-option-btn:hover {
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
            border-color: transparent;
            transform: translateY(-3px) scale(1.02);
            box-shadow: 0 8px 24px rgba(255, 107, 107, 0.25);
        }
        
        .input-form {
            display: flex;
            gap: 16px;
            align-items: end;
            padding: 20px 30px;
            background: rgba(255, 255, 255, 0.95);
            border-top: 1px solid rgba(255, 107, 107, 0.1);
            flex-shrink: 0;
        }
        
        .chat-input {
            flex: 1;
            padding: 18px 24px;
            border: 2px solid rgba(255, 107, 107, 0.2);
            border-radius: 32px;
            outline: none;
            font-size: 16px;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 16px rgba(255, 107, 107, 0.08);
            font-weight: 500;
            color: #2d3748;
        }
        
        .chat-input:focus {
            border-color: #ff6b6b;
            background: white;
            box-shadow: 
                0 8px 24px rgba(255, 107, 107, 0.15),
                0 0 0 4px rgba(255, 107, 107, 0.1);
            transform: translateY(-2px);
        }
        
        .chat-input::placeholder {
            color: #a0aec0;
            font-weight: 500;
        }
        
        .send-btn {
            padding: 18px 28px;
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white;
            border: none;
            border-radius: 32px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 700;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 
                0 8px 24px rgba(255, 107, 107, 0.25),
                0 4px 16px rgba(78, 205, 196, 0.15);
            position: relative;
            overflow: hidden;
        }
        
        .send-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s ease;
        }
        
        .send-btn:hover::before {
            left: 100%;
        }
        
        .send-btn:hover {
            transform: translateY(-3px) scale(1.05);
            box-shadow: 
                0 12px 32px rgba(255, 107, 107, 0.35),
                0 6px 20px rgba(78, 205, 196, 0.25);
        }
        
        .send-btn:disabled {
            background: linear-gradient(135deg, #e2e8f0, #cbd5e0);
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .send-btn:disabled::before {
            display: none;
        }
        
        .typing-indicator {
            display: none;
            padding: 28px 40px;
            text-align: left;
            margin-bottom: 24px;
        }
        
        .typing-dot {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            margin: 0 3px;
            animation: typing 1.6s infinite ease-in-out;
            box-shadow: 0 2px 8px rgba(255, 107, 107, 0.3);
        }
        
        .typing-dot:nth-child(2) {
            animation-delay: 0.2s;
        }
        
        .typing-dot:nth-child(3) {
            animation-delay: 0.4s;
        }
        
        @keyframes typing {
            0%, 60%, 100% {
                transform: translateY(0) scale(1);
                opacity: 0.7;
            }
            30% {
                transform: translateY(-12px) scale(1.1);
                opacity: 1;
            }
        }
        
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px) scale(0.95);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }
        
        .clear-btn {
            position: absolute;
            top: 24px;
            right: 24px;
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.25);
            padding: 10px 18px;
            border-radius: 24px;
            cursor: pointer;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
            z-index: 2;
        }
        
        .clear-btn:hover {
            background: rgba(255, 255, 255, 0.25);
            border-color: rgba(255, 255, 255, 0.4);
            transform: translateY(-2px) scale(1.05);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }
        
        /* Responsive Design */
        @media (max-width: 768px) {
            .chat-container {
                width: 99%;
                height: 80vh;
                min-height: 600px;
                margin: 0 auto;
            }
            
            .chat-messages {
                padding: 25px 20px;
                max-height: calc(80vh - 200px);
            }
            
            .message-content {
                max-width: 95%;
                padding: 14px 18px;
                font-size: 0.85rem;
                line-height: 1.5;
            }
            
            .copy-button {
                position: static;
                margin-top: 10px;
                opacity: 1;
                transform: none;
                display: inline-block;
            }
            
            .chat-header {
                padding: 1.5rem;
            }
        }
        
        @media (min-width: 1920px) {
            .chat-container {
                max-width: 1800px;
                height: 88vh;
            }
            
            .chat-messages {
                padding: 50px;
                max-height: calc(88vh - 240px);
            }
            
            .message-content {
                font-size: 0.95rem;
                padding: 18px 24px;
            }
        }
        
        /* Travel detail link styling */
        .travel-detail-link {
            color: #0052D4 !important;
            text-decoration: none;
            font-weight: 600;
            padding: 8px 16px;
            background: linear-gradient(135deg, rgba(0, 82, 212, 0.1), rgba(67, 100, 247, 0.1));
            border-radius: 20px;
            border: 1px solid rgba(0, 82, 212, 0.3);
            display: inline-block;
            margin: 8px 0;
            transition: all 0.3s ease;
        }
        
        .travel-detail-link:hover {
            background: linear-gradient(135deg, rgba(0, 82, 212, 0.2), rgba(67, 100, 247, 0.2));
            border-color: rgba(0, 82, 212, 0.5);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 82, 212, 0.2);
            color: #0052D4 !important;
        }

        /* Medium screens optimization for better readability */
        @media (max-width: 1366px) and (min-width: 769px) {
            .message-content {
                font-size: 0.92rem;
                padding: 18px 22px;
                line-height: 1.6;
                font-weight: 450;
            }
            
            .chat-messages {
                padding: 45px 55px;
            }
            
            .chat-input-container {
                padding: 15px 0;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>
        
        <div class="d-flex justify-content-center my-5">
            <div class="chat-container">
                <div class="chat-header position-relative">
                    <h3 class="mb-0">
                        <i class="fas fa-robot me-2"></i>AI 여행 플래너
                    </h3>
                    <p class="mb-0 mt-2">어떤 여행을 계획하고 계신가요?</p>
                    <button class="clear-btn" onclick="clearChat()">
                        <i class="fas fa-trash me-1"></i>대화 초기화
                    </button>
                </div>
                
                <div class="chat-messages" id="chatMessages">
                    <c:forEach items="${chatHistory}" var="message">
                        <div class="message ${message.role}">
                            <div class="message-content">
                                <c:choose>
                                    <c:when test="${message.role == 'ai'}">
                                        <div class="ai-content">${message.content}</div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:out value="${message.content}" escapeXml="true"/>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                    
                    <c:if test="${empty chatHistory}">
                        <div class="message ai">
                            <div class="message-content">
안녕하세요! AI 여행 플래너입니다. 
여행지, 기간, 관심사 등을 알려주시면 맞춤형 여행 일정을 만들어드릴게요!

예시: "일본 도쿄로 4일 동안 혼자 여행을 갑니다. 맛집과 쇼핑을 좋아해요."

<c:choose>
    <c:when test="${loginUser != null}">
🔐 <strong>로그인 사용자 전용 기능:</strong>
• 여행 매칭: "유럽 여행을 가고싶은데 프랑스 여행을 계획하는 사람과 매칭시켜줘."
• 계획 저장/불러오기 및 개인화된 추천
    </c:when>
    <c:otherwise>
🎁 <strong>체험하기:</strong> 일반 여행 계획 생성은 로그인 없이도 바로 이용 가능합니다!
개인화 기능(매칭, 저장 등)은 <a href="/member/login?returnUrl=/ai/chat" style="color: #0052D4; text-decoration: underline; font-weight: bold;">로그인</a> 후 이용해주세요.
    </c:otherwise>
</c:choose>
                            </div>
                        </div>
                    </c:if>
                    
                    <div class="typing-indicator" id="typingIndicator">
                        <span class="typing-dot"></span>
                        <span class="typing-dot"></span>
                        <span class="typing-dot"></span>
                    </div>
                </div>
                
                <div class="chat-input-container">
                    <div class="quick-options">
                        <button class="quick-option-btn" onclick="quickOption('일본 도쿄')">일본 도쿄</button>
                        <button class="quick-option-btn" onclick="quickOption('유럽 여행')">유럽 여행</button>
                        <button class="quick-option-btn" onclick="quickOption('제주도')">제주도</button>
                        <button class="quick-option-btn" onclick="quickOption('동남아')">동남아</button>
                        <c:if test="${loginUser != null}">
                            <button class="quick-option-btn" onclick="quickOption1('최적의 여행')">최적의 여행</button>
                            <button class="quick-option-btn" onclick="quickOption1('일본 같이 가는 사람과')">일본 같이 가는 사람과</button>
                            <button class="quick-option-btn saved-plans-btn" onclick="showSavedPlans()">
                                <i class="fas fa-folder"></i> 저장된 계획
                            </button>
                            <button class="quick-option-btn templates-btn" onclick="showTemplates()">
                                <i class="fas fa-star"></i> 인기 템플릿
                            </button>
                        </c:if>
                        <c:if test="${loginUser == null}">
                            <a href="/member/login?returnUrl=/ai/chat" class="quick-option-btn login-btn">
                                <i class="fas fa-sign-in-alt"></i> 로그인하여 더 많은 기능 사용
                            </a>
                        </c:if>
                    </div>
                    
                    <form class="input-form" onsubmit="sendMessage(event)">
                        <input type="text" 
                               class="chat-input" 
                               id="userInput" 
                               placeholder="여행 계획에 대해 물어보세요..."
                               autocomplete="off"
                               required>
                        <button type="submit" class="send-btn" id="sendBtn">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
        
        <%@ include file="../common/footer.jsp" %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 로그인 상태 확인
        function checkLoginStatus() {
            <c:choose>
                <c:when test="${loginUser == null}">
                    return false;
                </c:when>
                <c:otherwise>
                    return true;
                </c:otherwise>
            </c:choose>
        }

        // 메시지 전송 함수
        function sendMessage(event) {
            event.preventDefault();
            
            const input = document.getElementById('userInput');
            const message = input.value.trim();
            
            if (!message) return;
            
            // 사용자 메시지 표시
            addMessage('user', message);
            
            // 입력 필드 초기화 및 비활성화
            input.value = '';
            input.disabled = true;
            document.getElementById('sendBtn').disabled = true;
            
            // 타이핑 인디케이터 표시
            showTypingIndicator();
            
            // API 호출
            fetch('/ai/generate-plan', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    userMessage: message
                })
            })
            .then(response => response.json())
            .then(data => {
                hideTypingIndicator();
                
                if (data.success) {
                    addMessage('ai', data.message);
                } else {
                    // 로그인 필요 메시지는 그대로 표시 (리다이렉트 없음)
                    addMessage('ai', '죄송합니다. 오류가 발생했습니다: ' + (data.message || data.error || '알 수 없는 오류'));
                }
                
                // 입력 필드 활성화
                input.disabled = false;
                document.getElementById('sendBtn').disabled = false;
                input.focus();
            })
            .catch(error => {
                hideTypingIndicator();
                addMessage('ai', '죄송합니다. 서버와의 연결에 문제가 발생했습니다.');
                
                // 입력 필드 활성화
                input.disabled = false;
                document.getElementById('sendBtn').disabled = false;
                input.focus();
            });
        }
        
        // 메시지 추가 함수
        function addMessage(role, content) {
            const messagesContainer = document.getElementById('chatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + role;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            
            // AI 메시지의 경우 HTML 링크를 처리, 사용자 메시지는 텍스트만
            if (role === 'ai') {
                // HTML 내용을 안전하게 처리하고 링크를 활성화
                const tempDiv = document.createElement('div');
                tempDiv.innerHTML = content;
                
                // 모든 링크에 이벤트 리스너 추가
                const links = tempDiv.querySelectorAll('a.travel-detail-link');
                links.forEach(link => {
                    link.addEventListener('click', function(e) {
                        e.preventDefault();
                        window.open(link.href, '_blank');
                    });
                });
                
                contentDiv.innerHTML = tempDiv.innerHTML;
            } else {
                contentDiv.textContent = content;
            }
            
            // AI 메시지인 경우 복사 버튼 및 저장 버튼 추가
            if (role === 'ai') {
                // 여행 계획이 포함된 AI 응답인지 감지
                if (isPlanContent(content)) {
                    const actionButtons = createPlanActionButtons(content);
                    contentDiv.appendChild(actionButtons);
                }
                
                const copyButton = document.createElement('button');
                copyButton.className = 'copy-button';
                copyButton.innerHTML = '<i class="fas fa-copy"></i>복사';
                copyButton.onclick = function() {
                    copyToClipboard(content, copyButton);
                };
                contentDiv.appendChild(copyButton);
            }
            
            messageDiv.appendChild(contentDiv);
            messagesContainer.insertBefore(messageDiv, document.getElementById('typingIndicator'));
            
            // 스크롤을 맨 아래로
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }
        
        // 클립보드 복사 함수
        function copyToClipboard(text, button) {
            // 임시 textarea 생성
            const tempTextarea = document.createElement('textarea');
            tempTextarea.value = text;
            document.body.appendChild(tempTextarea);
            
            // 텍스트 선택 및 복사
            tempTextarea.select();
            tempTextarea.setSelectionRange(0, 99999); // 모바일 지원
            
            try {
                const successful = document.execCommand('copy');
                if (successful) {
                    // 복사 성공 시 버튼 상태 변경
                    button.innerHTML = '<i class="fas fa-check"></i>복사됨';
                    button.classList.add('copied');
                    
                    // 2초 후 원래 상태로 복원
                    setTimeout(() => {
                        button.innerHTML = '<i class="fas fa-copy"></i>복사';
                        button.classList.remove('copied');
                    }, 2000);
                } else {
                    throw new Error('복사 실패');
                }
            } catch (err) {
                // fallback: 최신 브라우저의 Clipboard API 사용
                if (navigator.clipboard) {
                    navigator.clipboard.writeText(text).then(() => {
                        button.innerHTML = '<i class="fas fa-check"></i>복사됨';
                        button.classList.add('copied');
                        
                        setTimeout(() => {
                            button.innerHTML = '<i class="fas fa-copy"></i>복사';
                            button.classList.remove('copied');
                        }, 2000);
                    }).catch(() => {
                        alert('복사에 실패했습니다. 텍스트를 수동으로 선택해서 복사해주세요.');
                    });
                } else {
                    alert('복사 기능을 지원하지 않는 브라우저입니다.');
                }
            } finally {
                // 임시 textarea 제거
                document.body.removeChild(tempTextarea);
            }
        }
        
        // 타이핑 인디케이터 표시/숨김
        function showTypingIndicator() {
            document.getElementById('typingIndicator').style.display = 'block';
            const messagesContainer = document.getElementById('chatMessages');
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }
        
        function hideTypingIndicator() {
            document.getElementById('typingIndicator').style.display = 'none';
        }
        
        // 빠른 옵션 선택
        function quickOption(destination) {
            const input = document.getElementById('userInput');
            input.value = destination + ' 여행 계획을 짜주세요.';
            input.focus();
        }
        // 빠른 옵션 선택
        function quickOption1(destination) {
            const input = document.getElementById('userInput');
            input.value = destination + ' 매칭시켜주세요.';
            input.focus();
        }
        
        // 대화 초기화
        function clearChat() {
            
            if (confirm('모든 대화 내용을 삭제하시겠습니까?')) {
                fetch('/ai/clear', {
                    method: 'POST'
                })
                .then(response => response.text())
                .then(result => {
                    if (result === 'login_required') {
                        alert('로그인이 필요한 서비스입니다.');
                        window.location.href = '/member/login?returnUrl=/ai/chat';
                        return;
                    }
                    location.reload();
                });
            }
        }
        
        // 페이지 로드 시 기존 AI 메시지에 복사 버튼 및 링크 처리 추가
        document.addEventListener('DOMContentLoaded', function() {
            const aiMessages = document.querySelectorAll('.message.ai .message-content');
            aiMessages.forEach(function(messageContent) {
                // 링크 처리
                const links = messageContent.querySelectorAll('a.travel-detail-link');
                links.forEach(link => {
                    link.addEventListener('click', function(e) {
                        e.preventDefault();
                        window.open(link.href, '_blank');
                    });
                });
                
                // 이미 복사 버튼이 있는지 확인
                if (!messageContent.querySelector('.copy-button')) {
                    const copyButton = document.createElement('button');
                    copyButton.className = 'copy-button';
                    copyButton.innerHTML = '<i class="fas fa-copy"></i>복사';
                    copyButton.onclick = function() {
                        const text = messageContent.textContent.replace('복사', '').trim();
                        copyToClipboard(text, copyButton);
                    };
                    messageContent.appendChild(copyButton);
                }
            });
        });
        
        // =========================
        // AI 여행 계획 저장 기능
        // =========================
        
        // 여행 계획이 포함된 AI 응답인지 감지
        function isPlanContent(content) {
            const planKeywords = ['일차', '여행', '계획', '일정', '숙박', '교통', '예산', '추천', '방문'];
            const hasKeyword = planKeywords.some(keyword => content.includes(keyword));
            const isLongContent = content.length > 200;
            const hasStructure = content.includes('일') || content.includes('Day') || content.includes('•') || content.includes('-');
            
            return hasKeyword && isLongContent && hasStructure;
        }
        
        // 계획 액션 버튼 생성
        function createPlanActionButtons(planContent) {
            const actionContainer = document.createElement('div');
            actionContainer.className = 'plan-action-buttons';
            actionContainer.style.cssText = `
                display: flex;
                gap: 12px;
                margin-top: 16px;
                padding-top: 12px;
                border-top: 1px solid rgba(255, 107, 107, 0.1);
                flex-wrap: wrap;
            `;
            
            // 저장 버튼
            const saveButton = document.createElement('button');
            saveButton.className = 'save-plan-btn';
            saveButton.innerHTML = '<i class="fas fa-save"></i> 계획 저장하기';
            saveButton.style.cssText = `
                background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
                color: white;
                border: none;
                padding: 10px 16px;
                border-radius: 20px;
                font-size: 0.85rem;
                font-weight: 600;
                cursor: pointer;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                box-shadow: 0 4px 15px rgba(255, 107, 107, 0.2);
                display: flex;
                align-items: center;
                gap: 6px;
            `;
            saveButton.onmouseover = function() {
                this.style.transform = 'translateY(-2px)';
                this.style.boxShadow = '0 6px 20px rgba(255, 107, 107, 0.3)';
                this.style.background = 'linear-gradient(135deg, #4ecdc4 0%, #ff6b6b 100%)';
            };
            saveButton.onmouseout = function() {
                this.style.transform = 'translateY(0)';
                this.style.boxShadow = '0 4px 15px rgba(255, 107, 107, 0.2)';
                this.style.background = 'linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%)';
            };
            saveButton.onclick = function() {
                showSavePlanModal(planContent);
            };
            
            // 공유 버튼
            const shareButton = document.createElement('button');
            shareButton.className = 'share-plan-btn';
            shareButton.innerHTML = '<i class="fas fa-share"></i> 공유하기';
            shareButton.style.cssText = saveButton.style.cssText;
            shareButton.onmouseover = saveButton.onmouseover;
            shareButton.onmouseout = saveButton.onmouseout;
            shareButton.onclick = function() {
                sharePlan(planContent);
            };
            
            actionContainer.appendChild(saveButton);
            actionContainer.appendChild(shareButton);
            
            return actionContainer;
        }
        
        // 계획 저장 모달 표시
        function showSavePlanModal(planContent) {
            // 로그인 확인
            if (!checkLoginStatus()) {
                alert('로그인이 필요한 서비스입니다.');
                window.location.href = '/member/login?returnUrl=/ai/chat';
                return;
            }
            
            // 기존 모달이 있으면 제거
            const existingModal = document.getElementById('savePlanModal');
            if (existingModal) {
                existingModal.remove();
            }
            
            // 모달 HTML 생성
            const modalHtml = `
                <div class="save-plan-modal" id="savePlanModal" style="
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
                    backdrop-filter: blur(10px);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    z-index: 1000;
                ">
                    <div class="modal-content" style="
                        background: white;
                        border-radius: 20px;
                        padding: 30px;
                        max-width: 500px;
                        width: 90%;
                        max-height: 80vh;
                        overflow-y: auto;
                        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                        transform: scale(0.9);
                        transition: transform 0.3s ease;
                    ">
                        <h3 style="
                            text-align: center;
                            margin-bottom: 25px;
                            color: #333;
                            font-weight: 700;
                            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
                            -webkit-background-clip: text;
                            -webkit-text-fill-color: transparent;
                            background-clip: text;
                        ">✈️ 여행 계획 저장</h3>
                        
                        <form id="savePlanForm">
                            <div class="form-group" style="margin-bottom: 20px;">
                                <label style="display: block; margin-bottom: 8px; font-weight: 600; color: #555;">계획 제목 *</label>
                                <input type="text" id="planTitle" placeholder="예: 제주도 3박4일 힐링여행" required style="
                                    width: 100%;
                                    padding: 12px 16px;
                                    border: 2px solid rgba(255, 107, 107, 0.2);
                                    border-radius: 12px;
                                    font-size: 16px;
                                    outline: none;
                                    transition: border-color 0.3s ease;
                                    box-sizing: border-box;
                                ">
                            </div>
                            
                            <div class="form-group" style="margin-bottom: 20px;">
                                <label style="display: block; margin-bottom: 8px; font-weight: 600; color: #555;">목적지</label>
                                <input type="text" id="planDestination" placeholder="예: 제주도" style="
                                    width: 100%;
                                    padding: 12px 16px;
                                    border: 2px solid rgba(255, 107, 107, 0.2);
                                    border-radius: 12px;
                                    font-size: 16px;
                                    outline: none;
                                    transition: border-color 0.3s ease;
                                    box-sizing: border-box;
                                ">
                            </div>
                            
                            <div class="form-group" style="margin-bottom: 20px;">
                                <label style="display: block; margin-bottom: 8px; font-weight: 600; color: #555;">태그</label>
                                <input type="text" id="planTags" placeholder="제주도, 힐링, 가족여행 (쉼표로 구분)" style="
                                    width: 100%;
                                    padding: 12px 16px;
                                    border: 2px solid rgba(255, 107, 107, 0.2);
                                    border-radius: 12px;
                                    font-size: 16px;
                                    outline: none;
                                    transition: border-color 0.3s ease;
                                    box-sizing: border-box;
                                ">
                            </div>
                            
                            <div class="form-group" style="margin-bottom: 25px;">
                                <label style="display: block; margin-bottom: 8px; font-weight: 600; color: #555;">메모</label>
                                <textarea id="planMemo" placeholder="이 계획에 대한 간단한 메모..." style="
                                    width: 100%;
                                    padding: 12px 16px;
                                    border: 2px solid rgba(255, 107, 107, 0.2);
                                    border-radius: 12px;
                                    font-size: 16px;
                                    outline: none;
                                    transition: border-color 0.3s ease;
                                    box-sizing: border-box;
                                    min-height: 80px;
                                    resize: vertical;
                                    font-family: inherit;
                                "></textarea>
                            </div>
                            
                            <div class="form-actions" style="
                                display: flex;
                                gap: 12px;
                                justify-content: flex-end;
                            ">
                                <button type="button" onclick="closeSavePlanModal()" style="
                                    padding: 12px 24px;
                                    border: 2px solid #ddd;
                                    background: white;
                                    color: #666;
                                    border-radius: 12px;
                                    cursor: pointer;
                                    font-weight: 600;
                                    transition: all 0.3s ease;
                                ">취소</button>
                                <button type="submit" style="
                                    padding: 12px 24px;
                                    background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
                                    color: white;
                                    border: none;
                                    border-radius: 12px;
                                    cursor: pointer;
                                    font-weight: 600;
                                    transition: all 0.3s ease;
                                ">저장하기</button>
                            </div>
                        </form>
                    </div>
                </div>
            `;
            
            // 모달을 body에 추가
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            
            // 모달 애니메이션
            setTimeout(() => {
                const modalContent = document.querySelector('#savePlanModal .modal-content');
                modalContent.style.transform = 'scale(1)';
            }, 10);
            
            // 폼 이벤트 리스너 추가
            document.getElementById('savePlanForm').addEventListener('submit', function(e) {
                e.preventDefault();
                savePlan(planContent);
            });
            
            // 모달 외부 클릭 시 닫기
            document.getElementById('savePlanModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closeSavePlanModal();
                }
            });
            
            // 입력 필드 포커스 효과
            const inputs = document.querySelectorAll('#savePlanModal input, #savePlanModal textarea');
            inputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.style.borderColor = '#ff6b6b';
                    this.style.boxShadow = '0 0 0 3px rgba(255, 107, 107, 0.1)';
                });
                input.addEventListener('blur', function() {
                    this.style.borderColor = 'rgba(255, 107, 107, 0.2)';
                    this.style.boxShadow = 'none';
                });
            });
        }
        
        // 모달 닫기
        function closeSavePlanModal() {
            const modal = document.getElementById('savePlanModal');
            if (modal) {
                const modalContent = modal.querySelector('.modal-content');
                modalContent.style.transform = 'scale(0.9)';
                setTimeout(() => {
                    modal.remove();
                }, 300);
            }
        }
        
        // 계획 저장 API 호출
        function savePlan(planContent) {
            const title = document.getElementById('planTitle').value.trim();
            const destination = document.getElementById('planDestination').value.trim();
            const tagsString = document.getElementById('planTags').value.trim();
            const memo = document.getElementById('planMemo').value.trim();
            
            if (!title) {
                alert('계획 제목을 입력해주세요.');
                return;
            }
            
            // 계획 콘텐츠 정리 - 특수 문자로 인한 문제 방지
            if (planContent) {
                try {
                    // 문제가 될 수 있는 특수 문자들을 안전하게 처리
                    planContent = planContent.replace(/[\x00-\x1F\x7F]/g, ''); // 제어 문자 제거
                    planContent = planContent.trim();
                } catch (e) {
                    console.error('Plan content processing error:', e);
                    // 오류 발생 시 원본 사용
                }
            }
            
            // 태그를 배열로 변환
            const tags = tagsString ? tagsString.split(',').map(tag => tag.trim()).filter(tag => tag) : [];
            
            // 저장 버튼 비활성화
            const saveBtn = document.querySelector('#savePlanForm button[type="submit"]');
            saveBtn.disabled = true;
            saveBtn.textContent = '저장 중...';
            
            // API 호출
            fetch('/api/travel-plans/save', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    title: title,
                    destination: destination,
                    planContent: planContent,
                    tags: tags,
                    memo: memo,
                    isTemplate: false
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('여행 계획이 성공적으로 저장되었습니다!');
                    closeSavePlanModal();
                } else {
                    if (data.message && data.message.includes('로그인이 필요')) {
                        alert('로그인이 필요한 서비스입니다.');
                        window.location.href = '/member/login?returnUrl=/ai/chat';
                        return;
                    }
                    alert('저장 중 오류가 발생했습니다: ' + (data.message || '알 수 없는 오류'));
                }
            })
            .catch(error => {
                console.error('Error saving plan:', error);
                alert('저장 중 오류가 발생했습니다. 다시 시도해주세요.');
            })
            .finally(() => {
                // 저장 버튼 활성화
                saveBtn.disabled = false;
                saveBtn.textContent = '저장하기';
            });
        }
        
        // 계획 공유 기능
        function sharePlan(planContent) {
            if (navigator.share) {
                navigator.share({
                    title: 'AI 여행 계획',
                    text: planContent,
                    url: window.location.href
                }).catch(console.error);
            } else {
                // 클립보드에 복사
                copyToClipboard(planContent, null);
                alert('여행 계획이 클립보드에 복사되었습니다!');
            }
        }
        
        // =========================
        // 저장된 계획 불러오기 기능
        // =========================
        
        // 저장된 계획 목록 표시
        function showSavedPlans() {
            // 로그인 확인
            if (!checkLoginStatus()) {
                alert('로그인이 필요한 서비스입니다.');
                window.location.href = '/member/login?returnUrl=/ai/chat';
                return;
            }
            
            // 기존 모달이 있으면 제거
            const existingModal = document.getElementById('savedPlansModal');
            if (existingModal) {
                existingModal.remove();
            }
            
            // 로딩 모달 먼저 표시
            showLoadingSavedPlansModal();
            
            // 저장된 계획 목록 조회
            fetch('/api/travel-plans/my-plans')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log('API Response Data:', data); // 디버깅용 로그 추가
                hideLoadingSavedPlansModal();
                
                // 오류 응답 확인 - API는 배열을 직접 반환함
                if (data.success === false) {
                    if (data.message && data.message.includes('로그인이 필요')) {
                        alert('로그인이 필요한 서비스입니다.');
                        window.location.href = '/member/login?returnUrl=/ai/chat';
                        return;
                    }
                    throw new Error(data.message || '알 수 없는 오류');
                }
                
                // 약간의 지연 후 모달 표시 (DOM 업데이트 대기)
                setTimeout(() => {
                    displaySavedPlans(data);
                }, 100);
            })
            .catch(error => {
                hideLoadingSavedPlansModal();
                console.error('Error loading saved plans:', error);
                alert('저장된 계획을 불러오는 중 오류가 발생했습니다: ' + error.message);
            });
        }
        
        // 로딩 모달 표시
        function showLoadingSavedPlansModal() {
            const modalHtml = `
                <div class="saved-plans-modal" id="savedPlansModal" style="
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
                    backdrop-filter: blur(10px);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    z-index: 1000;
                ">
                    <div class="modal-content" style="
                        background: white;
                        border-radius: 20px;
                        padding: 40px;
                        text-align: center;
                        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                    ">
                        <div style="
                            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
                            -webkit-background-clip: text;
                            -webkit-text-fill-color: transparent;
                            background-clip: text;
                            font-size: 1.2rem;
                            font-weight: 700;
                            margin-bottom: 20px;
                        ">📂 저장된 계획 불러오는 중...</div>
                        <div style="
                            width: 40px;
                            height: 40px;
                            border: 4px solid #f3f3f3;
                            border-top: 4px solid #ff6b6b;
                            border-radius: 50%;
                            animation: spin 1s linear infinite;
                            margin: 0 auto;
                        "></div>
                    </div>
                </div>
                <style>
                @keyframes spin {
                    0% { transform: rotate(0deg); }
                    100% { transform: rotate(360deg); }
                }
                @keyframes slideIn {
                    0% { 
                        opacity: 0; 
                        transform: translateX(100%) translateY(-50%); 
                    }
                    100% { 
                        opacity: 1; 
                        transform: translateX(0) translateY(0); 
                    }
                }
                @keyframes slideOut {
                    0% { 
                        opacity: 1; 
                        transform: translateX(0) translateY(0); 
                    }
                    100% { 
                        opacity: 0; 
                        transform: translateX(100%) translateY(-50%); 
                    }
                }
                </style>
            `;
            document.body.insertAdjacentHTML('beforeend', modalHtml);
        }
        
        // 로딩 모달 숨기기
        function hideLoadingSavedPlansModal() {
            const modal = document.getElementById('savedPlansModal');
            if (modal) {
                modal.remove();
            }
        }
        
        // 저장된 계획 목록 표시
        function displaySavedPlans(plans) {
            let plansHtml = '';
            
            if (plans.length === 0) {
                plansHtml = `
                    <div style="text-align: center; padding: 40px; color: #666;">
                        <i class="fas fa-folder-open" style="font-size: 3rem; margin-bottom: 20px; color: #ddd;"></i>
                        <p style="font-size: 1.1rem; margin-bottom: 10px;">저장된 여행 계획이 없습니다.</p>
                        <p style="font-size: 0.9rem; color: #999;">AI가 생성한 여행 계획을 저장해보세요!</p>
                    </div>
                `;
            } else {
                plansHtml = plans.map(plan => {
                    const createdDate = new Date(plan.createdAt).toLocaleDateString('ko-KR', {
                        year: 'numeric', month: 'short', day: 'numeric'
                    });
                    const tagsHtml = plan.tags && plan.tags.length > 0 ? 
                        plan.tags.map(tag => '<span class="tag-item">' + tag + '</span>').join('') : 
                        '<span style="color: #999; font-size: 0.8rem;">태그 없음</span>';
                    
                    return '<div class="saved-plan-card" data-plan-id="' + plan.planId + '" style="' +
                            'border: 2px solid rgba(255, 107, 107, 0.1);' +
                            'border-radius: 16px;' +
                            'padding: 20px;' +
                            'margin-bottom: 16px;' +
                            'background: white;' +
                            'transition: all 0.3s ease;' +
                            'cursor: pointer;">' +
                        '<div class="plan-header" style="margin-bottom: 12px;">' +
                            '<h4 style="margin: 0; color: #333; font-size: 1.1rem; font-weight: 700;">' + plan.title + '</h4>' +
                            '<div class="plan-meta" style="display: flex; gap: 12px; margin-top: 8px; flex-wrap: wrap;">' +
                                (plan.destination ? '<span class="meta-item" style="background: rgba(255, 107, 107, 0.1); color: #ff6b6b; padding: 4px 8px; border-radius: 8px; font-size: 0.8rem;">' + plan.destination + '</span>' : '') +
                                (plan.duration ? '<span class="meta-item" style="background: rgba(78, 205, 196, 0.1); color: #4ecdc4; padding: 4px 8px; border-radius: 8px; font-size: 0.8rem;">' + plan.duration + '일</span>' : '') +
                                (plan.budget ? '<span class="meta-item" style="background: rgba(255, 193, 7, 0.1); color: #ffc107; padding: 4px 8px; border-radius: 8px; font-size: 0.8rem;">' + plan.budget.toLocaleString('ko-KR') + '원</span>' : '') +
                            '</div>' +
                        '</div>' +
                        '<div class="plan-tags" style="margin-bottom: 16px;">' +
                            tagsHtml +
                        '</div>' +
                        (plan.memo ? '<div class="plan-memo" style="color: #666; font-size: 0.9rem; margin-bottom: 16px; font-style: italic;">"' + plan.memo + '"</div>' : '') +
                        '<div class="plan-actions" style="display: flex; gap: 8px; justify-content: space-between; align-items: center;">' +
                            '<div class="plan-date" style="color: #999; font-size: 0.8rem;">' +
                                '저장일: ' + createdDate +
                            '</div>' +
                            '<div style="display: flex; gap: 8px;">' +
                                '<button class="plan-action-btn" onclick="viewPlanDetail(' + plan.planId + ')" style="' +
                                    'background: linear-gradient(135deg, #007bff, #0056b3);' +
                                    'color: white;' +
                                    'border: none;' +
                                    'padding: 6px 12px;' +
                                    'border-radius: 12px;' +
                                    'font-size: 0.8rem;' +
                                    'cursor: pointer;' +
                                    'font-weight: 600;' +
                                '">보기</button>' +
                                '<button class="plan-action-btn" onclick="loadPlan(' + plan.planId + ')" style="' +
                                    'background: linear-gradient(135deg, #ff6b6b, #4ecdc4);' +
                                    'color: white;' +
                                    'border: none;' +
                                    'padding: 6px 12px;' +
                                    'border-radius: 12px;' +
                                    'font-size: 0.8rem;' +
                                    'cursor: pointer;' +
                                    'font-weight: 600;' +
                                '">불러오기</button>' +
                                '<button class="plan-action-btn" onclick="deleteSavedPlan(' + plan.planId + ')" style="' +
                                    'background: #dc3545;' +
                                    'color: white;' +
                                    'border: none;' +
                                    'padding: 6px 12px;' +
                                    'border-radius: 12px;' +
                                    'font-size: 0.8rem;' +
                                    'cursor: pointer;' +
                                    'font-weight: 600;' +
                                '">삭제</button>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
                }).join('');
            }
            
            const modalHtml = `
                <div class="saved-plans-modal" id="savedPlansModal" style="
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
                    backdrop-filter: blur(10px);
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    z-index: 1000;
                ">
                    <div class="modal-content" style="
                        background: white;
                        border-radius: 20px;
                        padding: 30px;
                        max-width: 700px;
                        width: 90%;
                        max-height: 80vh;
                        overflow-y: auto;
                        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                    ">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px;">
                            <h3 style="
                                margin: 0;
                                color: #333;
                                font-weight: 700;
                                background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
                                -webkit-background-clip: text;
                                -webkit-text-fill-color: transparent;
                                background-clip: text;
                            ">📂 저장된 여행 계획</h3>
                            <button onclick="closeSavedPlansModal()" style="
                                background: none;
                                border: none;
                                font-size: 1.5rem;
                                cursor: pointer;
                                color: #666;
                                padding: 8px;
                                border-radius: 8px;
                                transition: background 0.3s ease;
                            ">×</button>
                        </div>
                        
                        <div class="saved-plans-list">
                            ` + plansHtml + `
                        </div>
                    </div>
                </div>
                <style>
                .tag-item {
                    background: rgba(255, 107, 107, 0.1);
                    color: #ff6b6b;
                    padding: 4px 8px;
                    border-radius: 12px;
                    font-size: 0.7rem;
                    margin-right: 6px;
                    margin-bottom: 6px;
                    display: inline-block;
                }
                .saved-plan-card:hover {
                    border-color: rgba(255, 107, 107, 0.3);
                    transform: translateY(-2px);
                    box-shadow: 0 8px 25px rgba(255, 107, 107, 0.15);
                }
                .plan-action-btn:hover {
                    transform: translateY(-1px);
                    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
                }
                </style>
            `;
            
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            
            // 모달 외부 클릭 시 닫기
            document.getElementById('savedPlansModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closeSavedPlansModal();
                }
            });
        }
        
        // 저장된 계획 모달 닫기
        function closeSavedPlansModal() {
            const modal = document.getElementById('savedPlansModal');
            if (modal) {
                modal.remove();
            }
        }
        
        // 계획 불러오기
        function loadPlan(planId) {
            fetch('/api/travel-plans/' + planId)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                // 오류 응답 확인
                if (data.success === false) {
                    if (data.message && data.message.includes('로그인이 필요')) {
                        alert('로그인이 필요한 서비스입니다.');
                        window.location.href = '/member/login?returnUrl=/ai/chat';
                        return;
                    }
                    throw new Error(data.message || '알 수 없는 오류');
                }
                
                // 성공한 경우 plan 객체 사용 (ApiResponse가 아닌 직접 AiTravelPlanDTO 반환)
                const plan = data;
                // 모달 닫기
                closeSavedPlansModal();
                
                // 여행 계획 입력칸에 자동으로 내용 채우기
                const userInput = document.getElementById('userInput');
                if (userInput) {
                    // 저장된 계획을 바탕으로 새로운 질문 형태로 구성
                    let autoFillText = '';
                    
                    if (plan.destination) {
                        autoFillText += `${plan.destination} `;
                    }
                    if (plan.duration) {
                        autoFillText += `${plan.duration}일 `;
                    }
                    if (plan.budget) {
                        const formattedBudget = new Intl.NumberFormat('ko-KR').format(plan.budget);
                        autoFillText += `예산 ${formattedBudget}원 `;
                    }
                    if (plan.travelStyle) {
                        autoFillText += `${plan.travelStyle} 스타일 `;
                    }
                    
                    autoFillText += '여행 계획을 다시 짜주세요.';
                    
                    // 메모가 있으면 추가 요청사항으로 포함
                    if (plan.memo) {
                        autoFillText += ` 추가 요청: ${plan.memo}`;
                    }
                    
                    userInput.value = autoFillText;
                    userInput.focus();
                }
                
                // 성공 알림
                const notification = document.createElement('div');
                notification.style.cssText = `
                    position: fixed;
                    top: 20px;
                    right: 20px;
                    background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
                    color: white;
                    padding: 12px 20px;
                    border-radius: 12px;
                    font-weight: 600;
                    z-index: 2000;
                    box-shadow: 0 8px 25px rgba(255, 107, 107, 0.3);
                    animation: slideIn 0.3s ease-out;
                `;
                notification.innerHTML = `📂 "${plan.title}" 계획이 입력칸에 자동으로 채워졌습니다!`;
                document.body.appendChild(notification);
                
                // 3초 후 알림 제거
                setTimeout(() => {
                    notification.style.animation = 'slideOut 0.3s ease-in forwards';
                    setTimeout(() => notification.remove(), 300);
                }, 3000);
            })
            .catch(error => {
                console.error('Error loading plan:', error);
                alert('계획을 불러오는 중 오류가 발생했습니다.');
            });
        }
        
        // 저장된 계획 삭제
        function deleteSavedPlan(planId) {
            if (!confirm('이 계획을 삭제하시겠습니까?\n삭제된 계획은 복구할 수 없습니다.')) {
                return;
            }
            
            fetch('/api/travel-plans/' + planId, {
                method: 'DELETE'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 목록 새로고침
                    showSavedPlans();
                } else {
                    alert('계획 삭제 중 오류가 발생했습니다: ' + (data.message || '알 수 없는 오류'));
                }
            })
            .catch(error => {
                console.error('Error deleting plan:', error);
                alert('계획 삭제 중 오류가 발생했습니다.');
            });
        }
        
        // 계획 상세 보기 모달 표시
        function viewPlanDetail(planId) {
            // 로딩 표시
            showPlanDetailLoading(planId);
            
            // API 호출로 계획 상세 정보 가져오기
            fetch('/api/travel-plans/' + planId)
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                // 오류 응답 확인
                if (data.success === false) {
                    throw new Error(data.message || '계획을 불러올 수 없습니다.');
                }
                
                const plan = data.data || data;
                showPlanDetailModal(plan);
            })
            .catch(error => {
                hidePlanDetailLoading();
                console.error('Error loading plan detail:', error);
                alert('계획 상세 정보를 불러오는 중 오류가 발생했습니다: ' + error.message);
            });
        }
        
        // 계획 상세 로딩 모달 표시
        function showPlanDetailLoading(planId) {
            const modalHtml = `
                <div class="plan-detail-modal" id="planDetailModal" style="
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.6);
                    backdrop-filter: blur(8px);
                    z-index: 10000;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    opacity: 1;
                    transition: opacity 0.3s ease;
                ">
                    <div class="modal-content" style="
                        background: white;
                        border-radius: 16px;
                        max-width: 800px;
                        width: 90%;
                        max-height: 80%;
                        overflow-y: auto;
                        position: relative;
                        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                        transform: scale(0.9);
                        transition: transform 0.3s ease;
                        text-align: center;
                        padding: 40px;
                    ">
                        <div style="
                            font-size: 1.2rem;
                            font-weight: 700;
                            background: linear-gradient(135deg, #007bff, #0056b3);
                            -webkit-background-clip: text;
                            -webkit-text-fill-color: transparent;
                            background-clip: text;
                            margin-bottom: 20px;
                        ">📖 여행 계획 상세 정보 로딩 중...</div>
                        <div style="
                            width: 40px;
                            height: 40px;
                            border: 4px solid #f3f3f3;
                            border-top: 4px solid #007bff;
                            border-radius: 50%;
                            animation: spin 1s linear infinite;
                            margin: 0 auto;
                        "></div>
                    </div>
                </div>
            `;
            
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            
            setTimeout(() => {
                const modalContent = document.querySelector('#planDetailModal .modal-content');
                if (modalContent) {
                    modalContent.style.transform = 'scale(1)';
                }
            }, 10);
        }
        
        // 계획 상세 로딩 모달 숨기기
        function hidePlanDetailLoading() {
            const modal = document.getElementById('planDetailModal');
            if (modal) {
                modal.remove();
            }
        }
        
        // 계획 상세 내용 모달 표시
        function showPlanDetailModal(plan) {
            hidePlanDetailLoading();
            
            // 계획 콘텐츠 처리 (JSON에서 추출)
            let planContent = plan.planContent || '';
            if (typeof planContent === 'string' && planContent.startsWith('{')) {
                try {
                    const parsedContent = JSON.parse(planContent);
                    planContent = parsedContent.content || planContent;
                } catch (e) {
                    console.log('Plan content is not JSON format, using as is');
                }
            }
            
            // 줄바꿈을 <br> 태그로 변환
            planContent = planContent.replace(/\n/g, '<br>');
            
            // 태그 HTML 생성
            const tagsHtml = plan.tags && plan.tags.length > 0 ? 
                plan.tags.map(tag => `<span style="
                    background: linear-gradient(135deg, #007bff, #0056b3);
                    color: white;
                    padding: 4px 8px;
                    border-radius: 12px;
                    font-size: 0.7rem;
                    font-weight: 600;
                    margin-right: 8px;
                    margin-bottom: 4px;
                    display: inline-block;
                ">${tag}</span>`).join('') : 
                '<span style="color: #999;">태그 없음</span>';
            
            // 날짜 포맷팅
            const formatDate = (dateStr) => {
                if (!dateStr) return '미설정';
                return new Date(dateStr).toLocaleDateString('ko-KR', {
                    year: 'numeric', month: 'long', day: 'numeric'
                });
            };
            
            const createdDate = plan.createdAt ? 
                new Date(plan.createdAt).toLocaleDateString('ko-KR', {
                    year: 'numeric', month: 'short', day: 'numeric', 
                    hour: '2-digit', minute: '2-digit'
                }) : '알 수 없음';
            
            const modalHtml = `
                <div class="plan-detail-modal" id="planDetailModal" style="
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.6);
                    backdrop-filter: blur(8px);
                    z-index: 10000;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    opacity: 1;
                    transition: opacity 0.3s ease;
                ">
                    <div class="modal-content" style="
                        background: white;
                        border-radius: 16px;
                        max-width: 900px;
                        width: 95%;
                        max-height: 85%;
                        overflow-y: auto;
                        position: relative;
                        box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                        transform: scale(0.9);
                        transition: transform 0.3s ease;
                    ">
                        <!-- 모달 헤더 -->
                        <div style="
                            background: linear-gradient(135deg, #007bff, #0056b3);
                            color: white;
                            padding: 20px 30px;
                            border-radius: 16px 16px 0 0;
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                        ">
                            <h3 style="margin: 0; font-size: 1.4rem; font-weight: 700;">
                                📖 여행 계획 상세 보기
                            </h3>
                            <button onclick="closePlanDetailModal()" style="
                                background: rgba(255, 255, 255, 0.2);
                                border: none;
                                color: white;
                                font-size: 1.5rem;
                                cursor: pointer;
                                padding: 8px;
                                border-radius: 8px;
                                transition: background 0.3s ease;
                                width: 40px;
                                height: 40px;
                                display: flex;
                                align-items: center;
                                justify-content: center;
                            ">×</button>
                        </div>
                        
                        <!-- 모달 콘텐츠 -->
                        <div style="padding: 30px;">
                            <!-- 계획 기본 정보 -->
                            <div style="margin-bottom: 30px;">
                                <div style="
                                    background: linear-gradient(135deg, #f8f9ff, #e3f2fd);
                                    border-radius: 12px;
                                    padding: 20px;
                                    border-left: 4px solid #007bff;
                                ">
                                    <h4 style="
                                        margin: 0 0 15px 0;
                                        font-size: 1.6rem;
                                        color: #333;
                                        font-weight: 700;
                                    ">\${plan.title || '제목 없음'}</h4>
                                    
                                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 15px;">
                                        <div>
                                            <strong style="color: #007bff;">🌍 목적지:</strong><br>
                                            <span style="color: #666;">\${plan.destination || '미설정'}</span>
                                        </div>
                                        <div>
                                            <strong style="color: #007bff;">📅 여행 기간:</strong><br>
                                            <span style="color: #666;">\${plan.duration ? plan.duration + '일' : '미설정'}</span>
                                        </div>
                                        <div>
                                            <strong style="color: #007bff;">🗓️ 시작일:</strong><br>
                                            <span style="color: #666;">\${formatDate(plan.startDate)}</span>
                                        </div>
                                        <div>
                                            <strong style="color: #007bff;">🗓️ 종료일:</strong><br>
                                            <span style="color: #666;">\${formatDate(plan.endDate)}</span>
                                        </div>
                                        <div>
                                            <strong style="color: #007bff;">💰 예산:</strong><br>
                                            <span style="color: #666;">\${plan.budget ? new Intl.NumberFormat('ko-KR').format(plan.budget) + '원' : '미설정'}</span>
                                        </div>
                                        <div>
                                            <strong style="color: #007bff;">👥 최대 인원:</strong><br>
                                            <span style="color: #666;">\${plan.maxParticipants || '미설정'}명</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- 태그 -->
                            <div style="margin-bottom: 30px;">
                                <h5 style="margin: 0 0 10px 0; color: #333; font-size: 1.1rem; font-weight: 600;">
                                    🏷️ 태그
                                </h5>
                                <div style="line-height: 1.8;">
                                    ${tagsHtml}
                                </div>
                            </div>
                            
                            <!-- 메모 -->
                            \${plan.memo ? `
                            <div style="margin-bottom: 30px;">
                                <h5 style="margin: 0 0 10px 0; color: #333; font-size: 1.1rem; font-weight: 600;">
                                    📝 메모
                                </h5>
                                <div style="
                                    background: #f8f9fa;
                                    padding: 15px;
                                    border-radius: 8px;
                                    border-left: 3px solid #28a745;
                                    font-style: italic;
                                    color: #666;
                                ">${plan.memo}</div>
                            </div>
                            ` : ''}
                            
                            <!-- 여행 계획 내용 -->
                            <div style="margin-bottom: 30px;">
                                <h5 style="margin: 0 0 15px 0; color: #333; font-size: 1.1rem; font-weight: 600;">
                                    ✈️ 상세 여행 계획
                                </h5>
                                <div style="
                                    background: white;
                                    border: 1px solid #e9ecef;
                                    border-radius: 8px;
                                    padding: 20px;
                                    line-height: 1.8;
                                    font-size: 0.95rem;
                                    color: #444;
                                    white-space: pre-wrap;
                                    max-height: 400px;
                                    overflow-y: auto;
                                ">\${planContent || '계획 내용이 없습니다.'}</div>
                            </div>
                            
                            <!-- 저장 정보 -->
                            <div style="
                                background: #f8f9fa;
                                padding: 15px;
                                border-radius: 8px;
                                text-align: center;
                                color: #666;
                                font-size: 0.9rem;
                                margin-bottom: 20px;
                            ">
                                💾 저장일시: ${createdDate}
                            </div>
                            
                            <!-- 액션 버튼들 -->
                            <div style="text-align: center; border-top: 1px solid #e9ecef; padding-top: 20px;">
                                <button onclick="loadPlanFromDetail(\${plan.planId || plan.id})" style="
                                    background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
                                    color: white;
                                    border: none;
                                    padding: 12px 24px;
                                    border-radius: 25px;
                                    font-size: 0.9rem;
                                    cursor: pointer;
                                    font-weight: 600;
                                    margin-right: 10px;
                                    transition: all 0.3s ease;
                                ">📝 이 계획으로 새 여행 계획하기</button>
                                <button onclick="copyPlanContent()" style="
                                    background: linear-gradient(135deg, #28a745, #20c997);
                                    color: white;
                                    border: none;
                                    padding: 12px 24px;
                                    border-radius: 25px;
                                    font-size: 0.9rem;
                                    cursor: pointer;
                                    font-weight: 600;
                                    transition: all 0.3s ease;
                                ">📋 계획 내용 복사</button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            
            // 모달 애니메이션
            setTimeout(() => {
                const modalContent = document.querySelector('#planDetailModal .modal-content');
                if (modalContent) {
                    modalContent.style.transform = 'scale(1)';
                }
            }, 10);
            
            // 모달 외부 클릭 시 닫기
            document.getElementById('planDetailModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    closePlanDetailModal();
                }
            });
            
            // 현재 계획 내용을 전역변수에 저장 (복사 기능용)
            window.currentPlanContent = planContent;
        }
        
        // 계획 상세 모달 닫기
        function closePlanDetailModal() {
            const modal = document.getElementById('planDetailModal');
            if (modal) {
                const modalContent = modal.querySelector('.modal-content');
                modalContent.style.transform = 'scale(0.9)';
                setTimeout(() => {
                    modal.remove();
                }, 300);
            }
        }
        
        // 상세 모달에서 계획 불러오기
        function loadPlanFromDetail(planId) {
            closePlanDetailModal();
            loadPlan(planId);
        }
        
        // 계획 내용 복사하기
        function copyPlanContent() {
            if (window.currentPlanContent) {
                copyToClipboard(window.currentPlanContent, null);
                alert('여행 계획 내용이 클립보드에 복사되었습니다!');
            } else {
                alert('복사할 내용이 없습니다.');
            }
        }
        
        // 템플릿 계획 표시
        function showTemplates() {
            alert('템플릿 기능은 곧 추가될 예정입니다!');
        }
    </script>
</body>
</html>