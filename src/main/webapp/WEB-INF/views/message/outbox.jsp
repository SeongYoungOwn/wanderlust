<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>보낸 쪽지함 - AI 여행 동행 매칭 플랫폼</title>
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
            max-width: 1200px;
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

        .message-nav {
            background: white;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .nav-tabs .nav-link {
            border: none;
            color: #6c757d;
            font-weight: 500;
            padding: 0.75rem 1.5rem;
        }

        .nav-tabs .nav-link.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 8px;
        }

        .message-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .message-row {
            padding: 1rem;
            border-bottom: 1px solid #e9ecef;
            transition: all 0.3s ease;
        }

        .message-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.5rem;
        }

        .receiver-name {
            font-weight: 600;
            color: #495057;
        }

        .message-date {
            color: #6c757d;
            font-size: 0.9rem;
        }

        .message-title {
            font-size: 1.1rem;
            color: #2d3748;
            margin-bottom: 0.25rem;
        }

        .message-preview {
            color: #6c757d;
            font-size: 0.9rem;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .read-status {
            display: flex;
            align-items: center;
            gap: 0.25rem;
            font-size: 0.8rem;
        }

        .read-indicator {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            display: inline-block;
        }

        .read-indicator.read {
            background: #28a745;
        }

        .read-indicator.unread {
            background: #dc3545;
        }

        .pagination-wrapper {
            margin-top: 2rem;
            display: flex;
            justify-content: center;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #6c757d;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .stats-bar {
            background: white;
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <div class="page-header">
            <div class="container text-center">
                <h1><i class="fas fa-paper-plane me-3"></i>보낸 쪽지함</h1>
                <p>보낸 쪽지를 확인하고 관리하세요</p>
            </div>
        </div>

        <div class="container">
            <!-- 네비게이션 탭 -->
            <div class="message-nav">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/message/inbox">
                            <i class="fas fa-inbox me-2"></i>받은 쪽지함
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/message/outbox">
                            <i class="fas fa-paper-plane me-2"></i>보낸 쪽지함
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/message/compose">
                            <i class="fas fa-edit me-2"></i>쪽지 쓰기
                        </a>
                    </li>
                </ul>
            </div>

            <!-- 통계 정보 -->
            <div class="stats-bar">
                <div class="row text-center">
                    <div class="col-md-6">
                        <strong>전체 보낸 쪽지</strong>
                        <span class="text-primary ms-2">${totalCount}개</span>
                    </div>
                    <div class="col-md-6">
                        <strong>현재 페이지</strong>
                        <span class="text-info ms-2">${currentPage} / ${totalPages}</span>
                    </div>
                </div>
            </div>

            <!-- 쪽지 목록 -->
            <div class="message-table">
                <c:choose>
                    <c:when test="${not empty messages}">
                        <c:forEach var="message" items="${messages}">
                            <div class="message-row">
                                <div class="message-meta">
                                    <div class="receiver-name">
                                        <i class="fas fa-user me-2"></i>${message.receiverName}
                                    </div>
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="read-status">
                                            <span class="read-indicator ${message.read ? 'read' : 'unread'}"></span>
                                            <span>${message.read ? '읽음' : '읽지 않음'}</span>
                                        </div>
                                        <div class="message-date">
                                            ${message.sentDate.toString().substring(5, 16).replace('T', ' ')}
                                        </div>
                                    </div>
                                </div>
                                <div class="message-title">${message.messageTitle}</div>
                                <div class="message-preview">
                                    <c:choose>
                                        <c:when test="${message.messageContent.length() > 100}">
                                            ${message.messageContent.substring(0, 100)}...
                                        </c:when>
                                        <c:otherwise>
                                            ${message.messageContent}
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <i class="fas fa-paper-plane"></i>
                            <h3>보낸 쪽지가 없습니다</h3>
                            <p>아직 보낸 쪽지가 없습니다.</p>
                            <a href="${pageContext.request.contextPath}/message/compose" class="btn btn-primary mt-3">
                                <i class="fas fa-edit me-2"></i>쪽지 쓰기
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- 페이징 -->
            <c:if test="${totalPages > 1}">
                <div class="pagination-wrapper">
                    <nav aria-label="쪽지 페이지네이션">
                        <ul class="pagination">
                            <c:if test="${currentPage > 1}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage - 1}">이전</a>
                                </li>
                            </c:if>
                            
                            <c:forEach var="i" begin="1" end="${totalPages}">
                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                    <a class="page-link" href="?page=${i}">${i}</a>
                                </li>
                            </c:forEach>
                            
                            <c:if test="${currentPage < totalPages}">
                                <li class="page-item">
                                    <a class="page-link" href="?page=${currentPage + 1}">다음</a>
                                </li>
                            </c:if>
                        </ul>
                    </nav>
                </div>
            </c:if>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>

    <script>
        // 보낸 쪽지함에서는 클릭 기능을 제거했습니다.
        // 읽음 상태는 수신자가 읽었을 때 자동으로 업데이트됩니다.
    </script>
</body>
</html>