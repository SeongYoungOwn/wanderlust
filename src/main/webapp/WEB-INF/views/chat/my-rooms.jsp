<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>내 채팅방 목록 - Wanderlust</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica', 'Arial', sans-serif;
        }

        .chat-container {
            max-width: 900px;
            margin: 2rem auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .chat-header h2 {
            margin: 0;
            font-size: 1.5rem;
            font-weight: 600;
        }

        .back-btn {
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            border-radius: 10px;
            transition: background 0.3s;
        }

        .back-btn:hover {
            background: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .chat-list {
            max-height: 70vh;
            overflow-y: auto;
        }

        .chat-room-item {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid #f0f0f0;
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
            display: block;
            text-decoration: none;
            color: inherit;
        }

        .chat-room-item:hover {
            background: #f8f9fa;
            text-decoration: none;
            color: inherit;
        }

        .chat-room-item:last-child {
            border-bottom: none;
        }

        .room-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 0.5rem;
        }

        .room-title {
            font-weight: 600;
            font-size: 1.1rem;
            color: #2d3436;
            margin-bottom: 0.2rem;
        }

        .room-destination {
            color: #667eea;
            font-size: 0.9rem;
        }

        .room-date {
            color: #95a5a6;
            font-size: 0.85rem;
        }

        .room-last-message {
            color: #636e72;
            font-size: 0.9rem;
            margin-top: 0.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }

        .room-metadata {
            display: flex;
            gap: 1rem;
            margin-top: 0.8rem;
            font-size: 0.85rem;
            color: #95a5a6;
        }

        .room-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.3rem;
            padding: 0.2rem 0.6rem;
            background: #f0f0f0;
            border-radius: 15px;
            font-size: 0.8rem;
        }

        .badge-host {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .badge-online {
            background: #48dbfb;
            color: white;
        }

        .last-message-time {
            color: #95a5a6;
            font-size: 0.85rem;
            position: absolute;
            right: 1.5rem;
            top: 1rem;
        }

        .empty-state {
            padding: 4rem 2rem;
            text-align: center;
            color: #95a5a6;
        }

        .empty-state i {
            font-size: 4rem;
            color: #dfe6e9;
            margin-bottom: 1rem;
        }

        .empty-state h4 {
            color: #636e72;
            margin-bottom: 1rem;
        }

        .empty-state p {
            margin-bottom: 2rem;
        }

        .btn-create-travel {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 0.8rem 2rem;
            border-radius: 25px;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .btn-create-travel:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
            color: white;
        }

        .online-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            background: #00d2d3;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% {
                box-shadow: 0 0 0 0 rgba(0, 210, 211, 0.7);
            }
            70% {
                box-shadow: 0 0 0 10px rgba(0, 210, 211, 0);
            }
            100% {
                box-shadow: 0 0 0 0 rgba(0, 210, 211, 0);
            }
        }

        /* 스크롤바 스타일 */
        .chat-list::-webkit-scrollbar {
            width: 8px;
        }

        .chat-list::-webkit-scrollbar-track {
            background: #f1f1f1;
        }

        .chat-list::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 4px;
        }

        .chat-list::-webkit-scrollbar-thumb:hover {
            background: #555;
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="chat-container">
        <div class="chat-header">
            <h2><i class="fas fa-comments"></i> 내 채팅방</h2>
            <a href="/home" class="back-btn">
                <i class="fas fa-arrow-left"></i> 돌아가기
            </a>
        </div>

        <div class="chat-list">
            <c:choose>
                <c:when test="${not empty chatRooms}">
                    <c:forEach items="${chatRooms}" var="room">
                        <a href="/chat/room/${room.travelId}" class="chat-room-item">
                            <!-- 마지막 메시지 시간 -->
                            <c:if test="${room.lastMessageTime != null}">
                                <span class="last-message-time">
                                    <fmt:formatDate value="${room.lastMessageTime}" pattern="a h:mm" />
                                </span>
                            </c:if>

                            <div class="room-header">
                                <div>
                                    <div class="room-title">
                                        ${room.travelTitle}
                                        <c:if test="${room.isHost}">
                                            <span class="room-badge badge-host">
                                                <i class="fas fa-crown"></i> 동행장
                                            </span>
                                        </c:if>
                                    </div>
                                    <div class="room-destination">
                                        <i class="fas fa-map-marker-alt"></i> ${room.destination}
                                    </div>
                                    <div class="room-date">
                                        <i class="fas fa-calendar"></i>
                                        <fmt:formatDate value="${room.startDate}" pattern="MM.dd" /> -
                                        <fmt:formatDate value="${room.endDate}" pattern="MM.dd" />
                                    </div>
                                </div>
                            </div>

                            <div class="room-last-message">
                                <c:choose>
                                    <c:when test="${room.lastSenderName != null}">
                                        <strong>${room.lastSenderName}:</strong> ${room.lastMessage}
                                    </c:when>
                                    <c:otherwise>
                                        ${room.lastMessage}
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="room-metadata">
                                <span class="room-badge">
                                    <i class="fas fa-users"></i>
                                    참여자 ${room.participantCount}명
                                </span>
                                <c:if test="${room.onlineCount > 0}">
                                    <span class="room-badge badge-online">
                                        <span class="online-indicator"></span>
                                        온라인 ${room.onlineCount}명
                                    </span>
                                </c:if>
                            </div>
                        </a>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-comments"></i>
                        <h4>참여 중인 채팅방이 없습니다</h4>
                        <p>여행 계획에 참가하면 채팅방이 자동으로 생성됩니다.</p>
                        <a href="/travel/list" class="btn-create-travel">
                            <i class="fas fa-plus"></i> 여행 계획 둘러보기
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 5초마다 페이지 새로고침하여 최신 메시지 표시
        setTimeout(function() {
            location.reload();
        }, 30000); // 30초마다
    </script>
</body>
</html>