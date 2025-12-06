<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>쪽지 상세보기 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #fdfbf7;
            color: #2d3748;
            line-height: 1.6;
            overflow-x: hidden;
            padding-top: 60px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem 20px;
        }

        .page-header {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white;
            padding: 4rem 0 2rem 0;
            margin-bottom: 2rem;
            border-radius: 15px;
        }

        .message-detail {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 2px 20px rgba(0,0,0,0.1);
        }

        .message-header {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 2rem;
            border-bottom: 2px solid #dee2e6;
        }

        .message-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 1rem;
        }

        .message-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .message-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #6c757d;
            font-size: 0.9rem;
        }

        .info-item i {
            color: #667eea;
        }

        .message-status {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-badge.read {
            background: #d4edda;
            color: #155724;
        }

        .status-badge.unread {
            background: #f8d7da;
            color: #721c24;
        }

        .message-content {
            padding: 2rem;
        }

        .message-text {
            font-size: 1.1rem;
            line-height: 1.7;
            color: #495057;
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        .message-actions {
            padding: 1.5rem 2rem;
            background: #f8f9fa;
            border-top: 1px solid #dee2e6;
            text-align: center;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
            margin: 0 0.5rem;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            color: white;
            text-decoration: none;
        }

        .btn-danger {
            background: #dc3545;
            color: white;
            border: none;
        }

        .btn-danger:hover {
            background: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(220, 53, 69, 0.4);
            color: white;
            text-decoration: none;
        }

        .btn-secondary {
            background: #6c757d;
            color: white;
            border: none;
        }

        .btn-secondary:hover {
            background: #5a6268;
            color: white;
            text-decoration: none;
        }

        .back-link {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
            margin-bottom: 1rem;
            display: inline-block;
            transition: color 0.3s ease;
        }

        .back-link:hover {
            color: #764ba2;
            text-decoration: none;
        }

        .loading {
            display: none;
            text-align: center;
            padding: 1rem;
        }

        @media (max-width: 576px) {
            .message-meta {
                flex-direction: column;
                align-items: stretch;
                text-align: center;
            }

            .message-info {
                justify-content: center;
            }

            .message-actions {
                flex-direction: column;
                gap: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <div class="page-header">
            <div class="container text-center">
                <h1><i class="fas fa-envelope-open me-3"></i>쪽지 상세보기</h1>
                <p>쪽지 내용을 확인하세요</p>
            </div>
        </div>

        <div class="container">
            <!-- 뒤로가기 링크 -->
            <a href="javascript:history.back()" class="back-link">
                <i class="fas fa-arrow-left me-2"></i>뒤로 가기
            </a>

            <!-- 쪽지 상세 내용 -->
            <div class="message-detail">
                <!-- 헤더 -->
                <div class="message-header">
                    <h2 class="message-title">${message.messageTitle}</h2>
                    <div class="message-meta">
                        <div class="message-info">
                            <div class="info-item">
                                <i class="fas fa-user"></i>
                                <span>
                                    <c:choose>
                                        <c:when test="${isReceiver}">
                                            ${message.senderName} (보낸이)
                                        </c:when>
                                        <c:otherwise>
                                            ${message.receiverName} (받는이)
                                        </c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="info-item">
                                <i class="fas fa-clock"></i>
                                <span>
                                    <fmt:formatDate value="${message.sentDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                                </span>
                            </div>
                            <c:if test="${message.readDate != null}">
                                <div class="info-item">
                                    <i class="fas fa-eye"></i>
                                    <span>
                                        읽은 시간: <fmt:formatDate value="${message.readDate}" pattern="yyyy-MM-dd HH:mm:ss"/>
                                    </span>
                                </div>
                            </c:if>
                        </div>
                        <div class="message-status">
                            <span class="status-badge ${message.read ? 'read' : 'unread'}">
                                ${message.read ? '읽음' : '읽지 않음'}
                            </span>
                        </div>
                    </div>
                </div>

                <!-- 내용 -->
                <div class="message-content">
                    <div class="message-text">${message.messageContent}</div>
                </div>

                <!-- 액션 버튼 -->
                <div class="message-actions">
                    <div class="loading" id="loading">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">처리 중...</span>
                        </div>
                    </div>

                    <div id="actionButtons">
                        <c:if test="${isReceiver}">
                            <!-- 받은 쪽지인 경우 답장 버튼 -->
                            <a href="${pageContext.request.contextPath}/message/compose?receiverId=${message.senderId}" 
                               class="btn btn-primary">
                                <i class="fas fa-reply me-2"></i>답장
                            </a>
                            <!-- 받은 쪽지 삭제 -->
                            <button onclick="deleteMessage('received', ${message.messageId})" 
                                    class="btn btn-danger">
                                <i class="fas fa-trash me-2"></i>삭제
                            </button>
                        </c:if>
                        
                        <c:if test="${not isReceiver}">
                            <!-- 보낸 쪽지인 경우 삭제만 -->
                            <button onclick="deleteMessage('sent', ${message.messageId})" 
                                    class="btn btn-danger">
                                <i class="fas fa-trash me-2"></i>삭제
                            </button>
                        </c:if>

                        <!-- 목록으로 -->
                        <a href="${pageContext.request.contextPath}/message/${isReceiver ? 'inbox' : 'outbox'}" 
                           class="btn btn-secondary">
                            <i class="fas fa-list me-2"></i>목록으로
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>

    <script>
        function deleteMessage(type, messageId) {
            if (!confirm('정말로 이 쪽지를 삭제하시겠습니까?')) {
                return;
            }

            const loading = document.getElementById('loading');
            const buttons = document.getElementById('actionButtons');

            loading.style.display = 'block';
            buttons.style.display = 'none';

            const endpoint = type === 'received' ? '/message/delete/received' : '/message/delete/sent';

            fetch('${pageContext.request.contextPath}' + endpoint, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'messageId=' + messageId
            })
            .then(response => response.json())
            .then(data => {
                loading.style.display = 'none';
                buttons.style.display = 'block';

                if (data.success) {
                    alert('쪽지가 삭제되었습니다.');
                    const returnUrl = type === 'received' ? '/message/inbox' : '/message/outbox';
                    window.location.href = '${pageContext.request.contextPath}' + returnUrl;
                } else {
                    alert('오류: ' + data.message);
                }
            })
            .catch(error => {
                loading.style.display = 'none';
                buttons.style.display = 'block';
                console.error('Error:', error);
                alert('삭제 중 오류가 발생했습니다.');
            });
        }
    </script>
</body>
</html>