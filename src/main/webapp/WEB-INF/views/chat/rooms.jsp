<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 채팅방 - Wanderlust</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding-top: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
        }

        .page-header {
            background: white;
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
        }

        .page-header h1 {
            margin: 0;
            font-size: 2rem;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .page-header p {
            margin: 10px 0 0 0;
            color: #666;
        }

        .chat-rooms-list {
            display: grid;
            gap: 20px;
        }

        .chat-room-card {
            background: white;
            border-radius: 20px;
            padding: 25px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: block;
        }

        .chat-room-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }

        .chat-room-header {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }

        .chat-room-icon {
            width: 60px;
            height: 60px;
            border-radius: 15px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
            flex-shrink: 0;
        }

        .chat-room-info {
            flex: 1;
            min-width: 0;
        }

        .chat-room-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #2d3748;
            margin: 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .chat-room-destination {
            font-size: 0.9rem;
            color: #718096;
            margin: 5px 0 0 0;
        }

        .chat-room-meta {
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
            margin-top: 5px;
        }

        .chat-room-meta span {
            font-size: 0.85rem;
            color: #a0aec0;
        }

        .chat-room-meta i {
            margin-right: 5px;
        }

        .chat-room-last-message {
            background: #f7fafc;
            border-radius: 10px;
            padding: 15px;
            margin-top: 15px;
        }

        .last-message-label {
            font-size: 0.8rem;
            color: #718096;
            margin-bottom: 5px;
        }

        .last-message-content {
            color: #4a5568;
            font-size: 0.95rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .last-message-time {
            font-size: 0.8rem;
            color: #a0aec0;
            margin-top: 5px;
        }

        .empty-state {
            background: white;
            border-radius: 20px;
            padding: 60px 30px;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
        }

        .empty-state i {
            font-size: 4rem;
            color: #cbd5e0;
            margin-bottom: 20px;
        }

        .empty-state h3 {
            color: #4a5568;
            margin-bottom: 10px;
        }

        .empty-state p {
            color: #718096;
            margin-bottom: 20px;
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.35);
            color: white;
        }

        .error-message {
            background: #fff5f5;
            border: 1px solid #feb2b2;
            border-radius: 10px;
            padding: 15px;
            color: #c53030;
            margin-bottom: 20px;
        }

        @media (max-width: 768px) {
            body {
                padding-top: 70px;
            }

            .page-header {
                padding: 20px;
            }

            .page-header h1 {
                font-size: 1.5rem;
            }

            .chat-room-card {
                padding: 20px;
            }

            .chat-room-icon {
                width: 50px;
                height: 50px;
                font-size: 1.2rem;
            }

            .chat-room-title {
                font-size: 1.1rem;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="../common/header.jsp"/>

    <div class="container">
        <div class="page-header">
            <h1><i class="fas fa-comments me-2"></i>내 채팅방</h1>
            <p>참여 중인 여행 동행 채팅방 목록입니다</p>
        </div>

        <c:if test="${not empty error}">
            <div class="error-message">
                <i class="fas fa-exclamation-circle me-2"></i>${error}
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty chatRooms}">
                <div class="empty-state">
                    <i class="fas fa-comments"></i>
                    <h3>참여 중인 채팅방이 없습니다</h3>
                    <p>여행 계획에 참여하면 채팅방에서 동행자들과 소통할 수 있습니다</p>
                    <a href="${pageContext.request.contextPath}/travel/list" class="btn-primary-custom">
                        <i class="fas fa-search me-2"></i>여행 계획 찾아보기
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="chat-rooms-list">
                    <c:forEach var="room" items="${chatRooms}">
                        <a href="${pageContext.request.contextPath}/chat/room/${room.planId}" class="chat-room-card">
                            <div class="chat-room-header">
                                <div class="chat-room-icon">
                                    <i class="fas fa-plane-departure"></i>
                                </div>
                                <div class="chat-room-info">
                                    <h3 class="chat-room-title">${room.planTitle}</h3>
                                    <p class="chat-room-destination">
                                        <i class="fas fa-map-marker-alt"></i> ${room.planDestination}
                                    </p>
                                    <div class="chat-room-meta">
                                        <span>
                                            <i class="fas fa-users"></i> ${room.participantCount}/${room.maxParticipants}명
                                        </span>
                                        <span>
                                            <i class="fas fa-calendar"></i>
                                            <fmt:formatDate value="${room.planStartDate}" pattern="yyyy-MM-dd"/>
                                        </span>
                                        <c:if test="${not empty room.planBudget}">
                                            <span>
                                                <i class="fas fa-won-sign"></i>
                                                <fmt:formatNumber value="${room.planBudget}" pattern="#,###"/>원
                                            </span>
                                        </c:if>
                                    </div>
                                </div>
                            </div>

                            <c:if test="${not empty room.lastMessage}">
                                <div class="chat-room-last-message">
                                    <div class="last-message-label">최근 메시지</div>
                                    <div class="last-message-content">${room.lastMessage}</div>
                                    <div class="last-message-time">
                                        <c:choose>
                                            <c:when test="${not empty room.lastMessageTime}">
                                                <fmt:formatDate value="${room.lastMessageTime}" pattern="yyyy-MM-dd HH:mm" type="both"/>
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:formatDate value="${room.planRegdate}" pattern="yyyy-MM-dd HH:mm" type="both"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:if>
                        </a>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="../common/footer.jsp"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
