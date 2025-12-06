<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>쪽지 쓰기 - AI 여행 동행 매칭 플랫폼</title>
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

        .compose-form {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            box-shadow: 0 2px 20px rgba(0,0,0,0.1);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 600;
            color: #495057;
        }

        .form-control {
            width: 100%;
            padding: 0.75rem 1rem;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 1rem;
            transition: border-color 0.3s ease;
        }

        .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
        }

        .form-control.is-invalid {
            border-color: #dc3545;
        }

        .invalid-feedback {
            display: block;
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }

        .btn-secondary {
            background: #6c757d;
            border: none;
            padding: 0.75rem 2rem;
            border-radius: 8px;
            font-weight: 600;
            color: white;
            text-decoration: none;
            display: inline-block;
            transition: all 0.3s ease;
        }

        .btn-secondary:hover {
            background: #5a6268;
            color: white;
            text-decoration: none;
        }

        .receiver-info {
            background: #e3f2fd;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1rem;
        }

        .receiver-info strong {
            color: #1976d2;
        }

        .message-counter {
            text-align: right;
            font-size: 0.875rem;
            color: #6c757d;
            margin-top: 0.25rem;
        }

        .loading {
            display: none;
            text-align: center;
            padding: 1rem;
        }

        .spinner-border {
            width: 2rem;
            height: 2rem;
        }

        /* 닉네임 자동완성 드롭다운 스타일 */
        .autocomplete-dropdown {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            border: 1px solid #e9ecef;
            border-top: none;
            border-radius: 0 0 8px 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            display: none;
        }

        .autocomplete-item {
            padding: 0.75rem 1rem;
            cursor: pointer;
            border-bottom: 1px solid #f8f9fa;
            transition: background-color 0.2s ease;
        }

        .autocomplete-item:hover,
        .autocomplete-item.selected {
            background-color: #667eea;
            color: white;
        }

        .autocomplete-item:last-child {
            border-bottom: none;
        }

        .no-results {
            padding: 0.75rem 1rem;
            color: #6c757d;
            font-style: italic;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <div class="page-header">
            <div class="container text-center">
                <h1><i class="fas fa-edit me-3"></i>쪽지 쓰기</h1>
                <p>새로운 쪽지를 작성해보세요</p>
            </div>
        </div>

        <div class="container">
            <div class="compose-form">
                <form id="messageForm">
                    <!-- 수신자 정보 (미리 설정된 경우) -->
                    <c:if test="${not empty receiverInfo}">
                        <div class="receiver-info">
                            <strong>수신자:</strong> ${receiverInfo.userName} (${receiverInfo.userId})
                        </div>
                    </c:if>

                    <!-- 수신자 입력 -->
                    <div class="form-group">
                        <label for="receiverNickname" class="form-label">
                            <i class="fas fa-user me-2"></i>받는 사람 닉네임
                        </label>
                        <div class="autocomplete-wrapper" style="position: relative;">
                            <input type="text" 
                                   id="receiverNickname" 
                                   name="receiverNickname" 
                                   class="form-control" 
                                   value="${receiverInfo != null ? receiverInfo.nickname : ''}"
                                   placeholder="받는 사람의 닉네임을 입력하세요" 
                                   autocomplete="off"
                                   required>
                            <div id="nicknameAutocomplete" class="autocomplete-dropdown"></div>
                        </div>
                        <div class="invalid-feedback" id="receiverNicknameError"></div>
                    </div>

                    <!-- 제목 -->
                    <div class="form-group">
                        <label for="messageTitle" class="form-label">
                            <i class="fas fa-tag me-2"></i>제목
                        </label>
                        <input type="text" 
                               id="messageTitle" 
                               name="messageTitle" 
                               class="form-control" 
                               placeholder="쪽지 제목을 입력하세요" 
                               maxlength="100"
                               required>
                        <div class="message-counter">
                            <span id="titleCounter">0</span> / 100
                        </div>
                        <div class="invalid-feedback" id="messageTitleError"></div>
                    </div>

                    <!-- 내용 -->
                    <div class="form-group">
                        <label for="messageContent" class="form-label">
                            <i class="fas fa-comment me-2"></i>내용
                        </label>
                        <textarea id="messageContent" 
                                  name="messageContent" 
                                  class="form-control" 
                                  rows="8" 
                                  placeholder="쪽지 내용을 입력하세요" 
                                  maxlength="1000"
                                  required></textarea>
                        <div class="message-counter">
                            <span id="contentCounter">0</span> / 1000
                        </div>
                        <div class="invalid-feedback" id="messageContentError"></div>
                    </div>

                    <!-- 버튼 -->
                    <div class="text-center">
                        <div class="loading" id="loading">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">전송 중...</span>
                            </div>
                            <p>쪽지를 전송하고 있습니다...</p>
                        </div>
                        
                        <div id="buttons">
                            <button type="submit" class="btn btn-primary me-3">
                                <i class="fas fa-paper-plane me-2"></i>쪽지 보내기
                            </button>
                            <a href="${pageContext.request.contextPath}/message/inbox" class="btn btn-secondary">
                                <i class="fas fa-times me-2"></i>취소
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>

    <script>
        // 닉네임 자동완성 관련 변수
        let searchTimeout = null;
        let selectedIndex = -1;
        let currentNicknames = [];

        // 문자 수 카운터
        document.getElementById('messageTitle').addEventListener('input', function() {
            const count = this.value.length;
            document.getElementById('titleCounter').textContent = count;
        });

        document.getElementById('messageContent').addEventListener('input', function() {
            const count = this.value.length;
            document.getElementById('contentCounter').textContent = count;
        });

        // 닉네임 자동완성 기능
        document.getElementById('receiverNickname').addEventListener('input', function() {
            const query = this.value.trim();
            const dropdown = document.getElementById('nicknameAutocomplete');
            
            // 검색어가 없으면 드롭다운 숨기기
            if (query.length === 0) {
                dropdown.style.display = 'none';
                return;
            }
            
            // 이전 검색 요청 취소
            if (searchTimeout) {
                clearTimeout(searchTimeout);
            }
            
            // 300ms 후에 검색 실행 (디바운싱)
            searchTimeout = setTimeout(() => {
                searchNicknames(query);
            }, 300);
        });

        // 닉네임 검색 AJAX 함수
        function searchNicknames(query) {
            fetch('${pageContext.request.contextPath}/message/search-nicknames?query=' + encodeURIComponent(query))
                .then(response => response.json())
                .then(data => {
                    const dropdown = document.getElementById('nicknameAutocomplete');
                    dropdown.innerHTML = '';
                    currentNicknames = [];
                    selectedIndex = -1;
                    
                    if (data.success && data.nicknames && data.nicknames.length > 0) {
                        currentNicknames = data.nicknames;
                        data.nicknames.forEach((nickname, index) => {
                            const item = document.createElement('div');
                            item.className = 'autocomplete-item';
                            item.textContent = nickname;
                            item.addEventListener('click', () => selectNickname(nickname));
                            dropdown.appendChild(item);
                        });
                        dropdown.style.display = 'block';
                    } else {
                        const noResults = document.createElement('div');
                        noResults.className = 'no-results';
                        noResults.textContent = '검색 결과가 없습니다.';
                        dropdown.appendChild(noResults);
                        dropdown.style.display = 'block';
                    }
                })
                .catch(error => {
                    console.error('닉네임 검색 오류:', error);
                    const dropdown = document.getElementById('nicknameAutocomplete');
                    dropdown.style.display = 'none';
                });
        }

        // 닉네임 선택 처리
        function selectNickname(nickname) {
            document.getElementById('receiverNickname').value = nickname;
            document.getElementById('nicknameAutocomplete').style.display = 'none';
            selectedIndex = -1;
            currentNicknames = [];
        }

        // 키보드 네비게이션 처리
        document.getElementById('receiverNickname').addEventListener('keydown', function(e) {
            const dropdown = document.getElementById('nicknameAutocomplete');
            const items = dropdown.querySelectorAll('.autocomplete-item');
            
            if (items.length === 0) return;
            
            switch(e.key) {
                case 'ArrowDown':
                    e.preventDefault();
                    selectedIndex = Math.min(selectedIndex + 1, items.length - 1);
                    updateSelection(items);
                    break;
                case 'ArrowUp':
                    e.preventDefault();
                    selectedIndex = Math.max(selectedIndex - 1, -1);
                    updateSelection(items);
                    break;
                case 'Enter':
                    e.preventDefault();
                    if (selectedIndex >= 0 && selectedIndex < currentNicknames.length) {
                        selectNickname(currentNicknames[selectedIndex]);
                    }
                    break;
                case 'Escape':
                    dropdown.style.display = 'none';
                    selectedIndex = -1;
                    break;
            }
        });

        // 선택 상태 업데이트
        function updateSelection(items) {
            items.forEach((item, index) => {
                if (index === selectedIndex) {
                    item.classList.add('selected');
                } else {
                    item.classList.remove('selected');
                }
            });
        }

        // 문서 클릭 시 드롭다운 숨기기
        document.addEventListener('click', function(e) {
            const dropdown = document.getElementById('nicknameAutocomplete');
            const input = document.getElementById('receiverNickname');
            
            if (!dropdown.contains(e.target) && e.target !== input) {
                dropdown.style.display = 'none';
                selectedIndex = -1;
            }
        });

        // 폼 제출 처리
        document.getElementById('messageForm').addEventListener('submit', function(e) {
            e.preventDefault();
            sendMessage();
        });

        function sendMessage() {
            const loading = document.getElementById('loading');
            const buttons = document.getElementById('buttons');
            
            // 입력값 검증
            if (!validateForm()) {
                return;
            }

            // 로딩 상태 표시
            loading.style.display = 'block';
            buttons.style.display = 'none';

            // 폼 데이터 수집
            const messageData = {
                receiverNickname: document.getElementById('receiverNickname').value.trim(),
                messageTitle: document.getElementById('messageTitle').value.trim(),
                messageContent: document.getElementById('messageContent').value.trim()
            };

            // AJAX 요청
            fetch('${pageContext.request.contextPath}/message/send', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(messageData)
            })
            .then(response => response.json())
            .then(data => {
                loading.style.display = 'none';
                buttons.style.display = 'block';

                if (data.success) {
                    alert('쪽지가 전송되었습니다.');
                    window.location.href = '${pageContext.request.contextPath}/message/inbox';
                } else {
                    alert('오류: ' + data.message);
                }
            })
            .catch(error => {
                loading.style.display = 'none';
                buttons.style.display = 'block';
                console.error('Error:', error);
                alert('쪽지 전송 중 오류가 발생했습니다.');
            });
        }

        function validateForm() {
            let isValid = true;

            // 모든 에러 메시지 초기화
            clearErrors();

            // 수신자 닉네임 검증
            const receiverNickname = document.getElementById('receiverNickname').value.trim();
            if (!receiverNickname) {
                showError('receiverNickname', '받는 사람 닉네임을 입력하세요.');
                isValid = false;
            }

            // 제목 검증
            const messageTitle = document.getElementById('messageTitle').value.trim();
            if (!messageTitle) {
                showError('messageTitle', '제목을 입력하세요.');
                isValid = false;
            } else if (messageTitle.length > 100) {
                showError('messageTitle', '제목은 100자 이내로 입력하세요.');
                isValid = false;
            }

            // 내용 검증
            const messageContent = document.getElementById('messageContent').value.trim();
            if (!messageContent) {
                showError('messageContent', '내용을 입력하세요.');
                isValid = false;
            } else if (messageContent.length > 1000) {
                showError('messageContent', '내용은 1000자 이내로 입력하세요.');
                isValid = false;
            }

            return isValid;
        }

        function showError(fieldId, message) {
            const field = document.getElementById(fieldId);
            const errorDiv = document.getElementById(fieldId + 'Error');
            
            field.classList.add('is-invalid');
            errorDiv.textContent = message;
        }

        function clearErrors() {
            const fields = ['receiverNickname', 'messageTitle', 'messageContent'];
            fields.forEach(fieldId => {
                const field = document.getElementById(fieldId);
                const errorDiv = document.getElementById(fieldId + 'Error');
                
                field.classList.remove('is-invalid');
                errorDiv.textContent = '';
            });
        }
    </script>
</body>
</html>