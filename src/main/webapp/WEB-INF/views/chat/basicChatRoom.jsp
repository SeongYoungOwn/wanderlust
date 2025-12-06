<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>채팅방 - ${travelPlan.planTitle}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding-top: 100px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .chat-container {
            max-width: 1000px;
            margin: 20px auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .chat-header h3 {
            margin: 0;
            font-size: 1.5rem;
            font-weight: 600;
        }
        .chat-header small {
            opacity: 0.9;
            font-size: 0.9rem;
        }
        .chat-messages {
            height: 500px;
            overflow-y: auto;
            padding: 30px;
            background: #f8f9fa;
            display: flex;
            flex-direction: column;
        }
        .message {
            margin-bottom: 15px;
            padding: 12px 18px;
            background: white;
            border-radius: 18px;
            max-width: 60%;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            align-self: flex-start;
        }
        .message strong {
            color: #667eea;
            font-weight: 600;
        }
        .message.own {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            align-self: flex-end;
        }
        .message.own strong {
            color: white;
        }
        .system-message {
            text-align: center;
            color: #6c757d;
            font-style: italic;
            margin: 15px 0;
            font-size: 0.9rem;
            align-self: center;
        }
        .chat-input {
            display: flex;
            padding: 20px 30px;
            gap: 15px;
            background: white;
            border-top: 1px solid #e9ecef;
        }
        .chat-input input {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid #e9ecef;
            border-radius: 25px;
            outline: none;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        .chat-input input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .chat-input button {
            padding: 15px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }
        .chat-input button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
        }
        .participants {
            display: none; /* 임시로 숨김 처리 */
            position: fixed;
            top: 100px;
            right: 30px;
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            min-width: 220px;
            max-height: 400px;
            overflow-y: auto;
        }
        .participants h4 {
            margin-top: 0;
            margin-bottom: 15px;
            color: #667eea;
            font-size: 1.1rem;
            font-weight: 600;
            border-bottom: 2px solid #667eea;
            padding-bottom: 10px;
        }
        .participant {
            padding: 8px 0;
            color: #495057;
            font-weight: 500;
            border-bottom: 1px solid #f1f3f5;
        }
        .participant:last-child {
            border-bottom: none;
        }

        @media (max-width: 768px) {
            body {
                padding-top: 70px;
            }
            .chat-container {
                margin: 10px;
                border-radius: 15px;
            }
            .chat-messages {
                height: 400px;
                padding: 20px;
            }
            .participants {
                display: none;
            }
            .message {
                max-width: 80%;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="chat-container">
        <div class="chat-header">
            <h3>${travelPlan.planTitle}</h3>
            <small>사용자: ${currentUser.userId}</small>
        </div>
        
        <div class="chat-messages" id="messages">
            <!-- 메시지가 여기에 표시됩니다 -->
        </div>
        
        <div class="chat-input">
            <input type="text" id="messageInput" placeholder="메시지를 입력하세요..." maxlength="500">
            <button onclick="sendMessage()">보내기</button>
        </div>
    </div>

    <div class="participants">
        <h4>참여자 (<span id="participantCount">0</span>명)</h4>
        <div id="participantsList">
            <!-- 참여자 목록이 여기에 표시됩니다 -->
        </div>
    </div>

    <script>
        let stompClient = null;
        const travelPlanId = ${travelPlanId != null ? travelPlanId : 0};
        const currentUserId = '${currentUserId != null ? currentUserId : ""}';
        const currentUserName = '${currentUserName != null ? currentUserName : ""}';
        let isConnected = false;

        // 페이지 로드 시 초기화
        window.onload = function() {
            // Enter 키로 메시지 전송
            document.getElementById('messageInput').addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    sendMessage();
                }
            });

            // 채팅 히스토리 로드
            loadChatHistory();

            // 참여자 목록 로드
            loadParticipants();

            // WebSocket 연결
            connect();
        };

        // 채팅 히스토리 로드
        function loadChatHistory() {
            fetch('/chat/messages/' + travelPlanId + '?limit=50&offset=0')
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.messages) {
                        data.messages.forEach(message => {
                            displayMessage(message);
                        });
                    }
                })
                .catch(error => console.error('히스토리 로드 실패:', error));
        }

        // 참여자 목록 로드
        function loadParticipants() {
            fetch('/chat/participants/' + travelPlanId)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        updateParticipants(data);
                    }
                })
                .catch(error => console.error('참여자 목록 로드 실패:', error));
        }

        // WebSocket 연결
        function connect() {
            if (isConnected) return;
            
            try {
                const socket = new SockJS('/ws');
                stompClient = Stomp.over(socket);

                stompClient.connect({}, function(frame) {
                    console.log('Connected: ' + frame);
                    isConnected = true;

                    // 채팅방 메시지 구독
                    stompClient.subscribe('/topic/chat/' + travelPlanId, function(message) {
                        const chatMessage = JSON.parse(message.body);
                        displayMessage(chatMessage);
                    });

                    // 참여자 상태 구독
                    stompClient.subscribe('/topic/participants/' + travelPlanId, function(message) {
                        const participantData = JSON.parse(message.body);
                        updateParticipants(participantData);
                    });

                    // 사용자 입장 알림
                    stompClient.send("/app/chat/" + travelPlanId + "/addUser", {}, JSON.stringify({
                        senderId: currentUserId,
                        senderName: currentUserName,
                        type: 'JOIN',
                        content: currentUserName + '님이 입장했습니다.'
                    }));

                }, function(error) {
                    console.error('Connection error:', error);
                    isConnected = false;
                });

            } catch (error) {
                console.error('Connect function error:', error);
                isConnected = false;
            }
        }

        // 메시지 전송
        function sendMessage() {
            const input = document.getElementById('messageInput');
            const message = input.value.trim();

            if (message && stompClient && isConnected) {
                stompClient.send("/app/chat/" + travelPlanId, {}, JSON.stringify({
                    senderId: currentUserId,
                    senderName: currentUserName,
                    content: message,
                    type: 'CHAT'
                }));
                input.value = '';
            }
        }

        // 메시지 표시
        function displayMessage(message) {
            const messagesDiv = document.getElementById('messages');
            const messageDiv = document.createElement('div');
            
            if (message.type === 'JOIN' || message.type === 'LEAVE') {
                messageDiv.className = 'system-message';
                messageDiv.textContent = message.content;
            } else {
                messageDiv.className = 'message' + (message.senderId === currentUserId ? ' own' : '');
                messageDiv.innerHTML = `
                    <strong>${message.senderName}:</strong> ${message.content}
                    <small style="display: block; margin-top: 5px; opacity: 0.7;">
                        ${formatTime(message.timestamp)}
                    </small>
                `;
            }
            
            messagesDiv.appendChild(messageDiv);
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }

        // 참여자 목록 업데이트
        function updateParticipants(data) {
            const participantsList = document.getElementById('participantsList');
            const participantCount = document.getElementById('participantCount');

            participantsList.innerHTML = '';

            if (data.participants && data.participants.length > 0) {
                data.participants.forEach(participant => {
                    const div = document.createElement('div');
                    div.className = 'participant';

                    // 객체인지 문자열인지 확인
                    if (typeof participant === 'object') {
                        // 새로운 형식: {userId, userName, status, isOnline, isHost}
                        const displayName = participant.userName || participant.userId;
                        const isMe = participant.userId === currentUserId;
                        // 동행장 표시 (HOST 상태 또는 isHost 플래그)
                        const statusBadge = (participant.status === 'HOST' || participant.isHost) ? ' 👑' :
                                          participant.status === 'LEADER' ? ' ⭐' : '';
                        const onlineIndicator = participant.isOnline ? ' 🟢' : ' ⚪';

                        div.textContent = displayName + statusBadge + (isMe ? ' (나)' : '') + onlineIndicator;
                    } else {
                        // 기존 형식: userId만 문자열로
                        div.textContent = participant;
                    }

                    participantsList.appendChild(div);
                });
                participantCount.textContent = data.totalCount || data.participants.length;
            } else {
                participantCount.textContent = '0';
            }
        }

        // 시간 포맷팅
        function formatTime(timestamp) {
            if (!timestamp) return '';
            const date = new Date(timestamp);
            return date.toLocaleTimeString('ko-KR', { 
                hour: '2-digit', 
                minute: '2-digit' 
            });
        }

        // 페이지 나가기 전 정리
        window.onbeforeunload = function() {
            if (stompClient && isConnected) {
                stompClient.send("/app/chat/" + travelPlanId + "/removeUser", {}, JSON.stringify({
                    senderId: currentUserId,
                    senderName: currentUserName,
                    type: 'LEAVE',
                    content: currentUserName + '님이 나갔습니다.'
                }));
                stompClient.disconnect();
            }
        };
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>