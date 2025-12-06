<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>API 설정 - 관리자 대시보드</title>
    <!-- Pretendard Font -->
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css" />
    <!-- Admin CSS Files -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-navbar.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/admin/admin-dashboard-new.css">
    <style>
        body {
            background: var(--bg-primary) !important;
            color: var(--text-primary) !important;
        }
        .admin-container {
            background: var(--bg-primary) !important;
        }
        .main-content {
            background: var(--bg-primary) !important;
        }

        /* API Settings Specific Styles */
        .api-status-card {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border: 1px solid rgba(102, 126, 234, 0.3);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
        }

        .status-indicator {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .status-dot {
            width: 16px;
            height: 16px;
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        .status-dot.active {
            background: #2ed573;
            box-shadow: 0 0 20px rgba(46, 213, 115, 0.5);
        }

        .status-dot.inactive {
            background: #ff4757;
            box-shadow: 0 0 20px rgba(255, 71, 87, 0.5);
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .status-text {
            font-size: 1.75rem;
            font-weight: 700;
            letter-spacing: 0.5px;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .status-text.active { color: #2ed573; }
        .status-text.inactive { color: #ff4757; }

        .masked-key {
            font-family: 'Consolas', 'Monaco', monospace;
            background: rgba(0, 0, 0, 0.4);
            padding: 1rem 1.5rem;
            border-radius: 10px;
            font-size: 1.1rem;
            color: #e0e0e0;
            letter-spacing: 1.5px;
            font-weight: 500;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .api-form-card {
            background: var(--bg-card);
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
        }

        .form-title {
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 1.75rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #ffffff;
            letter-spacing: 0.3px;
        }

        .form-title i {
            color: #667eea;
            font-size: 1.3rem;
        }

        .api-input-group {
            position: relative;
            margin-bottom: 1.5rem;
        }

        .api-input {
            width: 100%;
            padding: 1.1rem 1.5rem;
            padding-right: 55px;
            background: rgba(255, 255, 255, 0.08);
            border: 2px solid rgba(255, 255, 255, 0.15);
            border-radius: 12px;
            color: #ffffff;
            font-size: 1.05rem;
            font-family: 'Consolas', 'Monaco', monospace;
            transition: all 0.3s ease;
            letter-spacing: 0.5px;
        }

        .api-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.25);
            background: rgba(255, 255, 255, 0.1);
        }

        .api-input::placeholder {
            color: rgba(255, 255, 255, 0.4);
        }

        .toggle-visibility {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: rgba(255, 255, 255, 0.5);
            cursor: pointer;
            font-size: 1.2rem;
            transition: color 0.3s ease;
        }

        .toggle-visibility:hover {
            color: #667eea;
        }

        .btn-group {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .btn-save {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 1rem 2.25rem;
            border-radius: 10px;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.6rem;
            letter-spacing: 0.3px;
        }

        .btn-save:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
        }

        .btn-save:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        .btn-delete {
            background: rgba(255, 71, 87, 0.15);
            color: #ff6b7a;
            border: 1px solid rgba(255, 71, 87, 0.35);
            padding: 1rem 2.25rem;
            border-radius: 10px;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.6rem;
            letter-spacing: 0.3px;
        }

        .btn-delete:hover {
            background: rgba(255, 71, 87, 0.25);
            transform: translateY(-2px);
        }

        .btn-test {
            background: rgba(46, 213, 115, 0.15);
            color: #5be089;
            border: 1px solid rgba(46, 213, 115, 0.35);
            padding: 1rem 2.25rem;
            border-radius: 10px;
            font-size: 1.05rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.6rem;
            letter-spacing: 0.3px;
        }

        .btn-test:hover {
            background: rgba(46, 213, 115, 0.25);
            transform: translateY(-2px);
        }

        .info-card {
            background: rgba(240, 248, 255, 0.95);
            border: 1px solid rgba(52, 152, 219, 0.4);
            border-radius: 14px;
            padding: 1.75rem;
            margin-top: 2.25rem;
        }

        .info-card h4 {
            color: #1a5276;
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 0.6rem;
            font-size: 1.15rem;
            font-weight: 600;
        }

        .info-card ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .info-card li {
            padding: 0.65rem 0;
            color: #2c3e50;
            display: flex;
            align-items: flex-start;
            gap: 0.65rem;
            font-size: 1rem;
            line-height: 1.5;
        }

        .info-card li i {
            color: #2980b9;
            margin-top: 4px;
            font-size: 0.9rem;
        }

        .info-card li code {
            background: rgba(52, 152, 219, 0.15);
            color: #1a5276;
            padding: 0.2rem 0.5rem;
            border-radius: 4px;
            font-size: 0.95rem;
            font-weight: 600;
        }

        .info-card li a {
            color: #2980b9;
            font-weight: 600;
            text-decoration: none;
            transition: color 0.2s ease;
        }

        .info-card li a:hover {
            color: #1a5276;
            text-decoration: underline;
        }

        .update-info {
            margin-top: 1.75rem;
            padding-top: 1.5rem;
            border-top: 1px solid rgba(255, 255, 255, 0.15);
            font-size: 1rem;
            color: rgba(255, 255, 255, 0.75);
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem 2.5rem;
        }

        .update-info span {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .update-info i {
            color: #667eea;
            font-size: 0.9rem;
        }

        /* Alert Messages */
        .alert {
            padding: 1rem 1.5rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .alert-success {
            background: rgba(46, 213, 115, 0.15);
            border: 1px solid rgba(46, 213, 115, 0.3);
            color: #2ed573;
        }

        .alert-error {
            background: rgba(255, 71, 87, 0.15);
            border: 1px solid rgba(255, 71, 87, 0.3);
            color: #ff4757;
        }

        .alert-warning {
            background: rgba(255, 193, 7, 0.15);
            border: 1px solid rgba(255, 193, 7, 0.3);
            color: #ffc107;
        }

        /* Loading Spinner */
        .spinner {
            display: none;
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        .loading .spinner {
            display: inline-block;
        }

        .loading .btn-text {
            display: none;
        }

        /* AI Features List */
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1rem;
            margin-top: 1.5rem;
        }

        .feature-item {
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 12px;
            padding: 1.25rem 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s ease;
        }

        .feature-item:hover {
            background: rgba(255, 255, 255, 0.08);
            transform: translateY(-2px);
        }

        .feature-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            flex-shrink: 0;
        }

        .feature-icon.chat { background: rgba(102, 126, 234, 0.25); color: #8fa4f0; }
        .feature-icon.travel { background: rgba(46, 213, 115, 0.25); color: #5be089; }
        .feature-icon.packing { background: rgba(255, 193, 7, 0.25); color: #ffcd38; }
        .feature-icon.playlist { background: rgba(255, 71, 87, 0.25); color: #ff6b7a; }
        .feature-icon.trend { background: rgba(52, 152, 219, 0.25); color: #5dade2; }

        .feature-name {
            font-weight: 600;
            font-size: 1.05rem;
            color: #ffffff;
            letter-spacing: 0.2px;
        }

        .feature-status {
            margin-left: auto;
            font-size: 0.95rem;
            font-weight: 600;
            padding: 0.4rem 0.9rem;
            border-radius: 20px;
            white-space: nowrap;
        }

        .feature-status.active {
            color: #2ed573;
            background: rgba(46, 213, 115, 0.15);
        }
        .feature-status.inactive {
            color: #ff4757;
            background: rgba(255, 71, 87, 0.15);
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <!-- Include Admin Navigation Bar -->
        <%@ include file="includes/admin-navbar-new.jsp" %>

        <div class="admin-container">

            <!-- Main Content -->
            <main class="admin-main">
                <div class="dashboard-header">
                    <h1 class="dashboard-title">
                        <i class="fas fa-key" style="margin-right: 0.75rem; opacity: 0.9;"></i>
                        API 설정
                    </h1>
                    <p class="dashboard-subtitle">
                        <i class="fas fa-robot" style="margin-right: 0.5rem; opacity: 0.8;"></i>
                        Claude AI API 키를 관리하고 AI 기능을 활성화합니다
                    </p>
                </div>

                <!-- Alert Container -->
                <div id="alertContainer"></div>

                <!-- API Status Card -->
                <div class="api-status-card">
                    <div class="status-indicator">
                        <div class="status-dot ${isActive ? 'active' : 'inactive'}" id="statusDot"></div>
                        <span class="status-text ${isActive ? 'active' : 'inactive'}" id="statusText">
                            ${isActive ? 'AI 기능 활성화됨' : 'AI 기능 비활성화됨'}
                        </span>
                    </div>

                    <c:if test="${isConfigured}">
                        <div style="margin-bottom: 1.25rem; display: flex; align-items: center; flex-wrap: wrap; gap: 0.75rem;">
                            <span style="color: rgba(255,255,255,0.8); font-size: 1.05rem; font-weight: 500;">현재 API 키:</span>
                            <span class="masked-key" id="maskedKeyDisplay">${maskedKey}</span>
                        </div>
                    </c:if>

                    <c:if test="${apiKeyInfo != null && apiKeyInfo.updatedAt != null}">
                        <div class="update-info">
                            <span><i class="fas fa-clock"></i> 마지막 수정: <fmt:formatDate value="${apiKeyInfo.updatedAt}" pattern="yyyy-MM-dd HH:mm:ss"/></span>
                            <c:if test="${apiKeyInfo.updatedBy != null}">
                                <span><i class="fas fa-user"></i> 수정자: ${apiKeyInfo.updatedBy}</span>
                            </c:if>
                        </div>
                    </c:if>
                </div>

                <!-- API Key Form -->
                <div class="api-form-card">
                    <h3 class="form-title">
                        <i class="fas fa-edit"></i>
                        API 키 설정
                    </h3>

                    <form id="apiKeyForm">
                        <div class="api-input-group">
                            <input type="password"
                                   id="apiKeyInput"
                                   class="api-input"
                                   placeholder="sk-ant-api03-xxxxxxxx..."
                                   autocomplete="off">
                            <button type="button" class="toggle-visibility" onclick="toggleVisibility()">
                                <i class="fas fa-eye" id="visibilityIcon"></i>
                            </button>
                        </div>

                        <div class="btn-group">
                            <button type="button" class="btn-test" onclick="testApiKey()">
                                <span class="spinner"></span>
                                <i class="fas fa-check-circle btn-text"></i>
                                <span class="btn-text">키 검증</span>
                            </button>
                            <button type="button" class="btn-save" onclick="saveApiKey()" id="saveBtn">
                                <span class="spinner"></span>
                                <i class="fas fa-save btn-text"></i>
                                <span class="btn-text">저장</span>
                            </button>
                            <c:if test="${isConfigured}">
                                <button type="button" class="btn-delete" onclick="deleteApiKey()">
                                    <span class="spinner"></span>
                                    <i class="fas fa-trash btn-text"></i>
                                    <span class="btn-text">삭제</span>
                                </button>
                            </c:if>
                        </div>
                    </form>

                    <!-- Info Card -->
                    <div class="info-card">
                        <h4><i class="fas fa-info-circle"></i> API 키 안내</h4>
                        <ul>
                            <li>
                                <i class="fas fa-check"></i>
                                Claude API 키는 <a href="https://console.anthropic.com/" target="_blank" style="color: #667eea;">Anthropic Console</a>에서 발급받을 수 있습니다.
                            </li>
                            <li>
                                <i class="fas fa-check"></i>
                                API 키는 <code>sk-ant-api</code>로 시작합니다.
                            </li>
                            <li>
                                <i class="fas fa-shield-alt"></i>
                                저장된 키는 AES-256으로 암호화되어 안전하게 보관됩니다.
                            </li>
                            <li>
                                <i class="fas fa-sync"></i>
                                키 저장 후 즉시 모든 AI 기능에 적용됩니다.
                            </li>
                        </ul>
                    </div>
                </div>

                <!-- AI Features Status -->
                <div class="api-form-card">
                    <h3 class="form-title">
                        <i class="fas fa-robot"></i>
                        AI 기능 현황
                    </h3>
                    <p style="color: rgba(255,255,255,0.75); margin-bottom: 1.5rem; font-size: 1.05rem; line-height: 1.6;">
                        API 키가 활성화되면 아래 기능들을 사용할 수 있습니다.
                    </p>

                    <div class="features-grid">
                        <div class="feature-item">
                            <div class="feature-icon chat">
                                <i class="fas fa-comments"></i>
                            </div>
                            <span class="feature-name">AI 채팅</span>
                            <span class="feature-status ${isActive ? 'active' : 'inactive'}">
                                ${isActive ? '사용 가능' : '비활성화'}
                            </span>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon travel">
                                <i class="fas fa-plane"></i>
                            </div>
                            <span class="feature-name">AI 여행 계획</span>
                            <span class="feature-status ${isActive ? 'active' : 'inactive'}">
                                ${isActive ? '사용 가능' : '비활성화'}
                            </span>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon packing">
                                <i class="fas fa-suitcase"></i>
                            </div>
                            <span class="feature-name">패킹 어시스턴트</span>
                            <span class="feature-status ${isActive ? 'active' : 'inactive'}">
                                ${isActive ? '사용 가능' : '비활성화'}
                            </span>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon playlist">
                                <i class="fas fa-music"></i>
                            </div>
                            <span class="feature-name">여행 플레이리스트</span>
                            <span class="feature-status ${isActive ? 'active' : 'inactive'}">
                                ${isActive ? '사용 가능' : '비활성화'}
                            </span>
                        </div>
                        <div class="feature-item">
                            <div class="feature-icon trend">
                                <i class="fas fa-chart-line"></i>
                            </div>
                            <span class="feature-name">트렌드 분석</span>
                            <span class="feature-status ${isActive ? 'active' : 'inactive'}">
                                ${isActive ? '사용 가능' : '비활성화'}
                            </span>
                        </div>
                    </div>
                </div>

            </main>
        </div>
    </div>

    <%@ include file="../common/footer.jsp" %>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        const contextPath = '${pageContext.request.contextPath}';

        // 비밀번호 표시/숨김 토글
        function toggleVisibility() {
            const input = document.getElementById('apiKeyInput');
            const icon = document.getElementById('visibilityIcon');

            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        // 알림 표시
        function showAlert(type, message) {
            const alertHtml = '<div class="alert alert-' + type + '">' +
                '<i class="fas fa-' + (type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'exclamation-triangle') + '"></i>' +
                message +
                '</div>';

            $('#alertContainer').html(alertHtml);

            setTimeout(function() {
                $('#alertContainer').html('');
            }, 5000);
        }

        // API 키 검증
        function testApiKey() {
            const apiKey = $('#apiKeyInput').val().trim();

            if (!apiKey) {
                showAlert('error', 'API 키를 입력해주세요.');
                return;
            }

            const btn = $('.btn-test');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/test',
                method: 'POST',
                data: { apiKey: apiKey },
                success: function(response) {
                    if (response.success) {
                        showAlert('success', response.message + ' (' + response.maskedKey + ')');
                    } else {
                        showAlert('error', response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : '검증 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // API 키 저장
        function saveApiKey() {
            const apiKey = $('#apiKeyInput').val().trim();

            if (!apiKey) {
                showAlert('error', 'API 키를 입력해주세요.');
                return;
            }

            if (!confirm('API 키를 저장하시겠습니까?\n저장 즉시 AI 기능이 활성화됩니다.')) {
                return;
            }

            const btn = $('.btn-save');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/save',
                method: 'POST',
                data: { apiKey: apiKey },
                success: function(response) {
                    if (response.success) {
                        showAlert('success', response.message);

                        // UI 업데이트
                        updateStatusUI(true, response.maskedKey);

                        // 입력 필드 초기화
                        $('#apiKeyInput').val('');

                        // 페이지 새로고침 (삭제 버튼 등 업데이트)
                        setTimeout(function() {
                            location.reload();
                        }, 1500);
                    } else {
                        showAlert('error', response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : '저장 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // API 키 삭제
        function deleteApiKey() {
            if (!confirm('API 키를 삭제하시겠습니까?\n삭제 즉시 모든 AI 기능이 비활성화됩니다.')) {
                return;
            }

            if (!confirm('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
                return;
            }

            const btn = $('.btn-delete');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/delete',
                method: 'POST',
                success: function(response) {
                    if (response.success) {
                        showAlert('warning', response.message);

                        // UI 업데이트
                        updateStatusUI(false, null);

                        // 페이지 새로고침
                        setTimeout(function() {
                            location.reload();
                        }, 1500);
                    } else {
                        showAlert('error', response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : '삭제 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // 상태 UI 업데이트
        function updateStatusUI(isActive, maskedKey) {
            const statusDot = document.getElementById('statusDot');
            const statusText = document.getElementById('statusText');

            if (isActive) {
                statusDot.classList.remove('inactive');
                statusDot.classList.add('active');
                statusText.classList.remove('inactive');
                statusText.classList.add('active');
                statusText.textContent = 'AI 기능 활성화됨';
            } else {
                statusDot.classList.remove('active');
                statusDot.classList.add('inactive');
                statusText.classList.remove('active');
                statusText.classList.add('inactive');
                statusText.textContent = 'AI 기능 비활성화됨';
            }

            if (maskedKey) {
                $('#maskedKeyDisplay').text(maskedKey);
            }

            // 기능 상태 업데이트
            $('.feature-status').each(function() {
                if (isActive) {
                    $(this).removeClass('inactive').addClass('active').text('사용 가능');
                } else {
                    $(this).removeClass('active').addClass('inactive').text('비활성화');
                }
            });
        }

        // 엔터키로 저장
        $('#apiKeyInput').on('keypress', function(e) {
            if (e.which === 13) {
                e.preventDefault();
                saveApiKey();
            }
        });
    </script>
</body>
</html>
