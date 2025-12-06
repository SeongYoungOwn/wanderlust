<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>게시판 관리 - 관리자 대시보드</title>
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
        .admin-sidebar {
            background: var(--bg-secondary) !important;
        }
        .main-content {
            background: var(--bg-primary) !important;
        }
        .card {
            background: var(--bg-card) !important;
            color: var(--text-primary) !important;
        }
        .table {
            color: var(--text-primary) !important;
        }
        .table td, .table th {
            border-color: rgba(255, 107, 107, 0.1) !important;
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
                        <i class="fas fa-newspaper" style="margin-right: 0.75rem; opacity: 0.9;"></i>
                        게시판 관리
                    </h1>
                    <p class="dashboard-subtitle">
                        <i class="fas fa-edit" style="margin-right: 0.5rem; opacity: 0.8;"></i>
                        모든 게시글을 조회하고 관리할 수 있습니다
                    </p>
                </div>
                
                <!-- Search and Filters -->
                <div class="content-grid">
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-search"></i>
                                검색 및 필터
                            </h3>
                        </div>
                        <div class="content-card-body">
                            <form class="search-form" method="GET" style="display: flex; gap: 1rem; align-items: end; flex-wrap: wrap;">
                        <div class="form-group">
                            <label class="form-label">검색</label>
                            <input type="text" class="form-control" name="search" value="${search}" 
                                   placeholder="제목, 내용, 작성자 검색">
                        </div>
                        <div class="form-group" style="flex: 0 0 150px;">
                            <label class="form-label">정렬 기준</label>
                            <select class="form-control" name="orderBy">
                                <option value="board_regdate" ${orderBy == 'board_regdate' ? 'selected' : ''}>작성일</option>
                                <option value="board_views" ${orderBy == 'board_views' ? 'selected' : ''}>조회수</option>
                                <option value="board_likes" ${orderBy == 'board_likes' ? 'selected' : ''}>좋아요</option>
                                <option value="board_dislikes" ${orderBy == 'board_dislikes' ? 'selected' : ''}>싫어요</option>
                            </select>
                        </div>
                        <div class="form-group" style="flex: 0 0 100px;">
                            <label class="form-label">순서</label>
                            <select class="form-control" name="orderDirection">
                                <option value="DESC" ${orderDirection == 'DESC' ? 'selected' : ''}>내림차순</option>
                                <option value="ASC" ${orderDirection == 'ASC' ? 'selected' : ''}>오름차순</option>
                            </select>
                        </div>
                                <div style="flex: 0 0 auto;">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-search me-1"></i> 검색
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
                
                <!-- Posts Table -->
                <div class="content-grid">
                    <div class="content-card">
                        <div class="content-card-header">
                            <h3 class="content-card-title">
                                <i class="fas fa-list-alt"></i>
                                게시글 목록 (총 ${totalPosts}개)
                            </h3>
                        </div>
                        <div class="content-card-body" style="max-height: none;">
                    
                    <c:choose>
                        <c:when test="${not empty posts}">
                            <div class="table-container">
                                <table class="posts-table">
                                    <thead>
                                        <tr>
                                            <th>게시글 정보</th>
                                            <th style="width: 120px;">통계</th>
                                            <th style="width: 100px;">작성일</th>
                                            <th style="width: 100px;">관리</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="post" items="${posts}">
                                            <tr data-post-id="${post.board_id}">
                                                <td>
                                                    <div class="post-title">
                                                        <c:choose>
                                                            <c:when test="${fn:length(post.board_title) > 50}">
                                                                ${fn:substring(post.board_title, 0, 50)}...
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${post.board_title}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="post-meta">
                                                        게시글 ID: ${post.board_id} | 작성자: ${post.board_writer}
                                                    </div>
                                                </td>
                                                <td class="stats-cell">
                                                    <div class="stat-item view-count">
                                                        <i class="fas fa-eye"></i>
                                                        ${post.board_views}
                                                    </div>
                                                    <div class="stat-item like-count">
                                                        <i class="fas fa-thumbs-up"></i>
                                                        ${post.board_likes}
                                                    </div>
                                                    <div class="stat-item dislike-count">
                                                        <i class="fas fa-thumbs-down"></i>
                                                        ${post.board_dislikes}
                                                    </div>
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${post.board_regdate}" pattern="yyyy-MM-dd"/>
                                                </td>
                                                <td>
                                                    <div class="actions">
                                                        <a href="${pageContext.request.contextPath}/board/detail/${post.board_id}" 
                                                           class="btn btn-info btn-sm" target="_blank">
                                                            <i class="fas fa-eye"></i> 보기
                                                        </a>
                                                        <button class="btn btn-danger btn-sm" 
                                                                onclick="deletePost(${post.board_id}, '${fn:escapeXml(post.board_title)}')">
                                                            <i class="fas fa-trash"></i> 삭제
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            
                            <!-- Pagination -->
                            <div class="pagination-section">
                                <div class="pagination-info">
                                    총 ${totalPosts}개 중 ${(currentPage-1)*size + 1} - ${currentPage*size > totalPosts ? totalPosts : currentPage*size}개 표시
                                </div>
                                
                                <div class="pagination">
                                    <c:if test="${currentPage > 1}">
                                        <a href="?page=${currentPage-1}&size=${size}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}" 
                                           class="page-link">
                                            <i class="fas fa-chevron-left"></i>
                                        </a>
                                    </c:if>
                                    
                                    <c:forEach begin="${currentPage > 3 ? currentPage - 2 : 1}" 
                                               end="${currentPage + 2 < totalPages ? currentPage + 2 : totalPages}" 
                                               var="page">
                                        <a href="?page=${page}&size=${size}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}" 
                                           class="page-link ${page == currentPage ? 'active' : ''}">
                                            ${page}
                                        </a>
                                    </c:forEach>
                                    
                                    <c:if test="${currentPage < totalPages}">
                                        <a href="?page=${currentPage+1}&size=${size}&search=${search}&orderBy=${orderBy}&orderDirection=${orderDirection}" 
                                           class="page-link">
                                            <i class="fas fa-chevron-right"></i>
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <i class="fas fa-list-alt"></i>
                                <h3>게시글이 없습니다</h3>
                                <p>검색 조건을 변경해보세요.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 게시글 삭제
        function deletePost(boardId, boardTitle) {
            // 제목이 너무 길면 자르기
            const shortTitle = boardTitle.length > 50 ? boardTitle.substring(0, 50) + '...' : boardTitle;
            
            if (confirm('게시글 "' + shortTitle + '"을(를) 삭제하시겠습니까?\\n\\n이 작업은 되돌릴 수 없습니다.')) {
                fetch('${pageContext.request.contextPath}/admin/posts/' + boardId + '/delete', {
                    method: 'POST'
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert(data.message);
                        location.reload();
                    } else {
                        alert('오류: ' + data.message);
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('요청 처리 중 오류가 발생했습니다.');
                });
            }
        }
    </script>
</body>
</html>