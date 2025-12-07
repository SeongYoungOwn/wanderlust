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
            color: #333333;
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
            background: #ffffff;
            border: 2px solid #d1d5db;
            border-radius: 12px;
            color: #333333;
            font-size: 1.05rem;
            font-family: 'Consolas', 'Monaco', monospace;
            transition: all 0.3s ease;
            letter-spacing: 0.5px;
        }

        .api-input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.25);
            background: #ffffff;
        }

        .api-input::placeholder {
            color: #9ca3af;
        }

        .toggle-visibility {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #6b7280;
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
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 12px;
            padding: 1.25rem 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s ease;
        }

        .feature-item:hover {
            background: #f1f3f4;
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

        .feature-icon.chat { background: rgba(102, 126, 234, 0.25); color: #667eea; }
        .feature-icon.travel { background: rgba(46, 213, 115, 0.25); color: #2ed573; }
        .feature-icon.packing { background: rgba(255, 193, 7, 0.25); color: #f59f00; }
        .feature-icon.playlist { background: rgba(255, 71, 87, 0.25); color: #ff4757; }
        .feature-icon.trend { background: rgba(52, 152, 219, 0.25); color: #3498db; }

        .feature-name {
            font-weight: 600;
            font-size: 1.05rem;
            color: #333333;
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
                        AI Provider 설정
                    </h1>
                    <p class="dashboard-subtitle">
                        <i class="fas fa-robot" style="margin-right: 0.5rem; opacity: 0.8;"></i>
                        Claude와 Gemini API를 관리하고 Fallback 기능을 설정합니다
                    </p>
                </div>

                <!-- Alert Container -->
                <div id="alertContainer"></div>

                <!-- Provider Status Overview -->
                <div class="api-status-card">
                    <div class="status-indicator">
                        <div class="status-dot ${isAnyProviderAvailable ? 'active' : 'inactive'}" id="statusDot"></div>
                        <span class="status-text ${isAnyProviderAvailable ? 'active' : 'inactive'}" id="statusText">
                            ${isAnyProviderAvailable ? 'AI 기능 활성화됨' : 'AI 기능 비활성화됨'}
                        </span>
                    </div>

                    <!-- Primary Provider Selection -->
                    <div style="margin-bottom: 1.5rem; padding: 1.25rem; background: rgba(0,0,0,0.2); border-radius: 12px;">
                        <div style="display: flex; align-items: center; gap: 1rem; flex-wrap: wrap;">
                            <span style="color: rgba(255,255,255,0.9); font-size: 1.1rem; font-weight: 600;">
                                <i class="fas fa-star" style="color: #ffc107; margin-right: 0.5rem;"></i>Primary Provider:
                            </span>
                            <select id="primaryProviderSelect" class="api-input" style="width: auto; min-width: 150px; padding: 0.75rem 1rem;">
                                <option value="claude" ${primaryProvider == 'claude' ? 'selected' : ''}>Claude</option>
                                <option value="gemini" ${primaryProvider == 'gemini' ? 'selected' : ''}>Gemini</option>
                            </select>
                            <button type="button" class="btn-save" onclick="setPrimaryProvider()" style="padding: 0.75rem 1.5rem;">
                                <i class="fas fa-check"></i> 변경
                            </button>
                        </div>
                        <p style="color: rgba(255,255,255,0.6); font-size: 0.95rem; margin-top: 0.75rem; margin-bottom: 0;">
                            <i class="fas fa-info-circle" style="margin-right: 0.5rem;"></i>
                            Primary Provider가 실패하면 자동으로 다른 Provider로 Fallback됩니다.
                            <span id="fallbackStatus" style="margin-left: 0.5rem; color: ${isFallbackAvailable ? '#2ed573' : '#ff4757'};">
                                (Fallback: ${isFallbackAvailable ? '사용 가능' : '설정 필요'})
                            </span>
                        </p>
                    </div>

                    <!-- Provider Status Grid -->
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1rem;">
                        <!-- Claude Status -->
                        <div style="background: rgba(102, 126, 234, 0.15); border: 1px solid rgba(102, 126, 234, 0.3); border-radius: 12px; padding: 1.25rem;">
                            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.75rem;">
                                <div class="status-dot ${isConfigured ? 'active' : 'inactive'}" style="width: 12px; height: 12px;"></div>
                                <span style="font-weight: 600; font-size: 1.1rem; color: #8fa4f0;">Claude API</span>
                                <c:if test="${primaryProvider == 'claude'}">
                                    <span style="background: #ffc107; color: #000; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600;">PRIMARY</span>
                                </c:if>
                            </div>
                            <c:choose>
                                <c:when test="${isConfigured}">
                                    <span class="masked-key" style="font-size: 0.9rem;">${maskedKey}</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: rgba(255,255,255,0.5);">설정되지 않음</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Gemini Status -->
                        <div style="background: rgba(46, 213, 115, 0.15); border: 1px solid rgba(46, 213, 115, 0.3); border-radius: 12px; padding: 1.25rem;">
                            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.75rem;">
                                <div class="status-dot ${isGeminiConfigured ? 'active' : 'inactive'}" style="width: 12px; height: 12px;"></div>
                                <span style="font-weight: 600; font-size: 1.1rem; color: #5be089;">Gemini API</span>
                                <c:if test="${primaryProvider == 'gemini'}">
                                    <span style="background: #ffc107; color: #000; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600;">PRIMARY</span>
                                </c:if>
                            </div>
                            <c:choose>
                                <c:when test="${isGeminiConfigured}">
                                    <span class="masked-key" style="font-size: 0.9rem;">${geminiMaskedKey}</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: rgba(255,255,255,0.5);">설정되지 않음</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Claude API Key Form -->
                <div class="api-form-card">
                    <h3 class="form-title">
                        <i class="fas fa-comment-dots" style="color: #667eea;"></i>
                        Claude API 키 설정
                    </h3>

                    <form id="apiKeyForm">
                        <div class="api-input-group">
                            <input type="password"
                                   id="apiKeyInput"
                                   class="api-input"
                                   placeholder="sk-ant-api03-xxxxxxxx..."
                                   autocomplete="off">
                            <button type="button" class="toggle-visibility" onclick="toggleVisibility('apiKeyInput', 'visibilityIcon')">
                                <i class="fas fa-eye" id="visibilityIcon"></i>
                            </button>
                        </div>

                        <div class="btn-group">
                            <button type="button" class="btn-test" onclick="testClaudeApiKey()">
                                <span class="spinner"></span>
                                <i class="fas fa-check-circle btn-text"></i>
                                <span class="btn-text">키 검증</span>
                            </button>
                            <button type="button" class="btn-save" onclick="saveClaudeApiKey()" id="saveBtn">
                                <span class="spinner"></span>
                                <i class="fas fa-save btn-text"></i>
                                <span class="btn-text">저장</span>
                            </button>
                            <c:if test="${isConfigured}">
                                <button type="button" class="btn-delete" onclick="deleteClaudeApiKey()">
                                    <span class="spinner"></span>
                                    <i class="fas fa-trash btn-text"></i>
                                    <span class="btn-text">삭제</span>
                                </button>
                            </c:if>
                        </div>
                    </form>
                </div>

                <!-- Gemini API Key Form -->
                <div class="api-form-card">
                    <h3 class="form-title">
                        <i class="fas fa-gem" style="color: #2ed573;"></i>
                        Gemini API 키 설정
                    </h3>

                    <form id="geminiApiKeyForm">
                        <div class="api-input-group">
                            <input type="password"
                                   id="geminiApiKeyInput"
                                   class="api-input"
                                   placeholder="AIzaSy..."
                                   autocomplete="off">
                            <button type="button" class="toggle-visibility" onclick="toggleVisibility('geminiApiKeyInput', 'geminiVisibilityIcon')">
                                <i class="fas fa-eye" id="geminiVisibilityIcon"></i>
                            </button>
                        </div>

                        <div class="btn-group">
                            <button type="button" class="btn-test" onclick="testGeminiApiKey()">
                                <span class="spinner"></span>
                                <i class="fas fa-check-circle btn-text"></i>
                                <span class="btn-text">키 검증</span>
                            </button>
                            <button type="button" class="btn-save" onclick="saveGeminiApiKey()" id="saveGeminiBtn" style="background: linear-gradient(135deg, #2ed573 0%, #1abc9c 100%);">
                                <span class="spinner"></span>
                                <i class="fas fa-save btn-text"></i>
                                <span class="btn-text">저장</span>
                            </button>
                            <c:if test="${isGeminiConfigured}">
                                <button type="button" class="btn-delete" onclick="deleteGeminiApiKey()">
                                    <span class="spinner"></span>
                                    <i class="fas fa-trash btn-text"></i>
                                    <span class="btn-text">삭제</span>
                                </button>
                            </c:if>
                        </div>
                    </form>
                </div>

                <!-- Info Card -->
                <div class="api-form-card">
                    <div class="info-card" style="margin-top: 0;">
                        <h4><i class="fas fa-info-circle"></i> API 키 안내</h4>
                        <ul>
                            <li>
                                <i class="fas fa-comment-dots" style="color: #667eea;"></i>
                                <strong>Claude API</strong>: <a href="https://console.anthropic.com/" target="_blank" style="color: #667eea;">Anthropic Console</a>에서 발급 (<code>sk-ant-api</code>로 시작)
                            </li>
                            <li>
                                <i class="fas fa-gem" style="color: #2ed573;"></i>
                                <strong>Gemini API</strong>: <a href="https://aistudio.google.com/apikey" target="_blank" style="color: #2ed573;">Google AI Studio</a>에서 발급 (<code>AIza</code>로 시작)
                            </li>
                            <li>
                                <i class="fas fa-shield-alt"></i>
                                저장된 키는 <strong>AES-256</strong>으로 암호화되어 안전하게 보관됩니다.
                            </li>
                            <li>
                                <i class="fas fa-sync-alt"></i>
                                <strong>Fallback 기능</strong>: Primary Provider 실패 시 자동으로 다른 Provider로 전환됩니다.
                            </li>
                            <li>
                                <i class="fas fa-lightbulb"></i>
                                <strong>권장 설정</strong>: 두 API 키 모두 설정하면 안정적인 AI 서비스를 제공할 수 있습니다.
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
        function toggleVisibility(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);

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

        // ==================== Primary Provider ====================

        function setPrimaryProvider() {
            const provider = $('#primaryProviderSelect').val();

            $.ajax({
                url: contextPath + '/admin/api-settings/provider',
                method: 'POST',
                data: { provider: provider },
                success: function(response) {
                    if (response.success) {
                        showAlert('success', response.message);
                        setTimeout(function() {
                            location.reload();
                        }, 1000);
                    } else {
                        showAlert('error', response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : 'Provider 변경 중 오류가 발생했습니다.');
                }
            });
        }

        // ==================== Claude API ====================

        // Claude API 키 검증
        function testClaudeApiKey() {
            const apiKey = $('#apiKeyInput').val().trim();

            if (!apiKey) {
                showAlert('error', 'Claude API 키를 입력해주세요.');
                return;
            }

            const btn = $('#apiKeyForm .btn-test');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/test',
                method: 'POST',
                data: { apiKey: apiKey },
                success: function(response) {
                    if (response.success) {
                        showAlert('success', 'Claude: ' + response.message + ' (' + response.maskedKey + ')');
                    } else {
                        showAlert('error', 'Claude: ' + response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : 'Claude 키 검증 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // Claude API 키 저장
        function saveClaudeApiKey() {
            const apiKey = $('#apiKeyInput').val().trim();

            if (!apiKey) {
                showAlert('error', 'Claude API 키를 입력해주세요.');
                return;
            }

            if (!confirm('Claude API 키를 저장하시겠습니까?')) {
                return;
            }

            const btn = $('#saveBtn');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/save',
                method: 'POST',
                data: { apiKey: apiKey },
                success: function(response) {
                    if (response.success) {
                        showAlert('success', 'Claude: ' + response.message);
                        $('#apiKeyInput').val('');
                        setTimeout(function() {
                            location.reload();
                        }, 1500);
                    } else {
                        showAlert('error', 'Claude: ' + response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : 'Claude 키 저장 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // Claude API 키 삭제
        function deleteClaudeApiKey() {
            if (!confirm('Claude API 키를 삭제하시겠습니까?')) {
                return;
            }

            if (!confirm('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
                return;
            }

            const btn = $('#apiKeyForm .btn-delete');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/delete',
                method: 'POST',
                success: function(response) {
                    if (response.success) {
                        showAlert('warning', 'Claude: ' + response.message);
                        setTimeout(function() {
                            location.reload();
                        }, 1500);
                    } else {
                        showAlert('error', 'Claude: ' + response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : 'Claude 키 삭제 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // ==================== Gemini API ====================

        // Gemini API 키 검증
        function testGeminiApiKey() {
            const apiKey = $('#geminiApiKeyInput').val().trim();

            if (!apiKey) {
                showAlert('error', 'Gemini API 키를 입력해주세요.');
                return;
            }

            const btn = $('#geminiApiKeyForm .btn-test');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/gemini/test',
                method: 'POST',
                data: { apiKey: apiKey },
                success: function(response) {
                    if (response.success) {
                        showAlert('success', 'Gemini: ' + response.message + ' (' + response.maskedKey + ')');
                    } else {
                        showAlert('error', 'Gemini: ' + response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : 'Gemini 키 검증 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // Gemini API 키 저장
        function saveGeminiApiKey() {
            const apiKey = $('#geminiApiKeyInput').val().trim();

            if (!apiKey) {
                showAlert('error', 'Gemini API 키를 입력해주세요.');
                return;
            }

            if (!confirm('Gemini API 키를 저장하시겠습니까?')) {
                return;
            }

            const btn = $('#saveGeminiBtn');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/gemini/save',
                method: 'POST',
                data: { apiKey: apiKey },
                success: function(response) {
                    if (response.success) {
                        showAlert('success', 'Gemini: ' + response.message);
                        $('#geminiApiKeyInput').val('');
                        setTimeout(function() {
                            location.reload();
                        }, 1500);
                    } else {
                        showAlert('error', 'Gemini: ' + response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : 'Gemini 키 저장 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // Gemini API 키 삭제
        function deleteGeminiApiKey() {
            if (!confirm('Gemini API 키를 삭제하시겠습니까?')) {
                return;
            }

            if (!confirm('정말 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
                return;
            }

            const btn = $('#geminiApiKeyForm .btn-delete');
            btn.addClass('loading');

            $.ajax({
                url: contextPath + '/admin/api-settings/gemini/delete',
                method: 'POST',
                success: function(response) {
                    if (response.success) {
                        showAlert('warning', 'Gemini: ' + response.message);
                        setTimeout(function() {
                            location.reload();
                        }, 1500);
                    } else {
                        showAlert('error', 'Gemini: ' + response.message);
                    }
                },
                error: function(xhr) {
                    const response = xhr.responseJSON;
                    showAlert('error', response ? response.message : 'Gemini 키 삭제 중 오류가 발생했습니다.');
                },
                complete: function() {
                    btn.removeClass('loading');
                }
            });
        }

        // ==================== 공통 ====================

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
                saveClaudeApiKey();
            }
        });

        $('#geminiApiKeyInput').on('keypress', function(e) {
            if (e.which === 13) {
                e.preventDefault();
                saveGeminiApiKey();
            }
        });
    </script>
</body>
</html>
