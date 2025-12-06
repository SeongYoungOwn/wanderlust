<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>${board.boardTitle} - AI 여행 동행 매칭 플랫폼</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --success-gradient: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            --card-shadow: 0 10px 40px rgba(0,0,0,0.1);
            --hover-shadow: 0 20px 60px rgba(0,0,0,0.15);
            --text-primary: #2c3e50;
            --text-secondary: #7f8c8d;
            --bg-light: #f8f9fa;
            --border-light: rgba(0,0,0,0.08);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(to bottom, #ffffff 0%, #f8f9fa 100%);
            color: var(--text-primary);
            line-height: 1.6;
            padding-top: 100px;
        }

        .container-custom {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* 게시판 상세 헤더 */
        .board-detail-header {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: var(--card-shadow);
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
        }

        .board-detail-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 5px;
            background: var(--primary-gradient);
        }

        .board-category {
            display: inline-block;
            padding: 0.4rem 1rem;
            background: var(--primary-gradient);
            color: white;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }

        .board-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            color: var(--text-primary);
        }

        .board-meta {
            display: flex;
            align-items: center;
            gap: 2rem;
            padding-top: 1.5rem;
            border-top: 1px solid var(--border-light);
        }

        .board-author {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .author-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: var(--primary-gradient);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
        }

        /* 콘텐츠 섹션 */
        .content-section {
            background: white;
            border-radius: 20px;
            padding: 2.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            position: relative;
            padding-left: 1rem;
        }

        .section-title::before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 4px;
            height: 24px;
            background: var(--primary-gradient);
            border-radius: 2px;
        }

        /* 태그 스타일 */
        .tag-modern {
            display: inline-block;
            padding: 0.6rem 1.2rem;
            background: white;
            border: 2px solid #e3e8ef;
            border-radius: 25px;
            font-size: 0.9rem;
            font-weight: 600;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .tag-modern:hover {
            background: var(--primary-gradient);
            color: white;
            border-color: transparent;
            transform: translateY(-2px);
        }

        /* 댓글 섹션 */
        .comment-section {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }

        .comment-item {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border-light);
            transition: background 0.3s ease;
        }

        .comment-item:hover {
            background: var(--bg-light);
        }

        .comment-item:last-child {
            border-bottom: none;
        }

        .comment-input {
            width: 100%;
            padding: 1rem;
            border: 2px solid var(--border-light);
            border-radius: 15px;
            resize: none;
            transition: border-color 0.3s ease;
            font-family: inherit;
        }

        .comment-input:focus {
            outline: none;
            border-color: #667eea;
        }

        /* 플로팅 액션 버튼 */
        .floating-actions {
            position: fixed;
            bottom: 30px;
            right: 30px;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            z-index: 100;
        }

        .fab-btn {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: white;
            box-shadow: 0 5px 20px rgba(0,0,0,0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            font-size: 1.3rem;
        }

        .fab-btn:hover {
            transform: scale(1.1);
        }

        .fab-btn.primary {
            background: var(--primary-gradient);
            color: white;
        }

        /* 좋아요 버튼 스타일 */
        .btn-like-active {
            background: #dc3545 !important;
            color: white !important;
        }

        .btn-dislike-active {
            background: #ffc107 !important;
            color: white !important;
        }

        /* 이미지 스타일 */
        .board-image {
            width: 100%;
            border-radius: 15px;
            margin-bottom: 1.5rem;
        }

        /* 반응형 디자인 */
        @media (max-width: 768px) {
            .board-title {
                font-size: 1.8rem;
            }

            .board-meta {
                flex-direction: column;
                align-items: flex-start;
                gap: 1rem;
            }

            .content-section {
                padding: 1.5rem;
            }
        }

        /* 애니메이션 */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .animate-fade-in {
            animation: fadeInUp 0.6s ease-out;
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>

    <div class="container-custom mt-5">
        <!-- 게시글 헤더 -->
        <div class="board-detail-header animate-fade-in">
            <span class="board-category">커뮤니티</span>
            <h1 class="board-title">${board.boardTitle}</h1>

            <div class="board-meta">
                <div class="board-author">
                    <div class="author-avatar">${fn:substring(writer.userName, 0, 1)}</div>
                    <div>
                        <div class="fw-bold">${writer.userName}</div>
                        <small class="text-muted">
                            <fmt:formatDate value="${board.boardRegdate}" pattern="yyyy.MM.dd"/> 작성
                        </small>
                    </div>
                </div>

                <div class="d-flex gap-4">
                    <div>
                        <i class="fas fa-eye text-primary"></i>
                        <span class="ms-1">${board.boardViews}</span>
                    </div>
                    <div>
                        <i class="fas fa-comment text-success"></i>
                        <span class="ms-1">${commentCount}</span>
                    </div>
                    <div>
                        <i class="fas fa-heart text-danger"></i>
                        <span class="ms-1" id="likeCountHeader">${board.boardLikes}</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- 메시지 알림 -->
        <c:if test="${not empty success}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle me-2"></i>${success}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle me-2"></i>${error}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="row mt-4">
            <!-- 메인 콘텐츠 -->
            <div class="col-lg-8">
                <!-- 게시글 내용 -->
                <div class="content-section">
                    <!-- 이미지가 있는 경우 -->
                    <c:if test="${not empty board.boardImage}">
                        <img src="${pageContext.request.contextPath}/uploads/${board.boardImage}"
                             alt="게시글 이미지" class="board-image">
                    </c:if>

                    <div style="line-height: 1.8; color: var(--text-secondary);">
                        <c:choose>
                            <c:when test="${not empty board.boardContent}">
                                <div style="white-space: pre-wrap; word-wrap: break-word;">${board.boardContent}</div>
                            </c:when>
                            <c:otherwise>
                                <p class="text-muted">내용이 없습니다.</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- 좋아요/공유 버튼 -->
                    <div class="d-flex gap-2 mt-4 pt-4 border-top">
                        <c:if test="${not empty sessionScope.loginUser}">
                            <button class="btn btn-outline-danger" id="likeBtn" onclick="toggleLike()">
                                <i class="fas fa-heart" id="likeIcon"></i>
                                <span id="likeBtnText">좋아요</span>
                                <span id="likeBtnCount">${board.boardLikes}</span>
                            </button>
                            <button class="btn btn-outline-warning" id="dislikeBtn" onclick="toggleDislike()">
                                <i class="fas fa-thumbs-down" id="dislikeIcon"></i>
                                <span id="dislikeBtnText">싫어요</span>
                                <span id="dislikeBtnCount">${board.boardDislikes}</span>
                            </button>
                            <c:if test="${sessionScope.loginUser.userId ne board.boardWriter}">
                                <c:choose>
                                    <c:when test="${userFavorite}">
                                        <button class="btn btn-secondary" onclick="toggleBoardFavorite(${board.boardId}, false)">
                                            <i class="fas fa-bookmark"></i> 저장 취소
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-outline-secondary" onclick="toggleBoardFavorite(${board.boardId}, true)">
                                            <i class="fas fa-bookmark"></i> 저장
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                                <button class="btn btn-outline-warning" onclick="openReportModal()">
                                    <i class="fas fa-flag"></i> 신고
                                </button>
                            </c:if>
                        </c:if>
                        <c:if test="${empty sessionScope.loginUser}">
                            <div class="alert alert-info mb-0">
                                <i class="fas fa-info-circle me-2"></i>
                                로그인 후 이용 가능합니다.
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- 댓글 섹션 -->
                <div class="comment-section mt-4">
                    <h3 class="section-title">댓글 ${commentCount}개</h3>

                    <!-- 댓글 입력 -->
                    <c:if test="${not empty sessionScope.loginUser}">
                        <div class="mb-4">
                            <form action="${pageContext.request.contextPath}/comment/create" method="post">
                                <input type="hidden" name="boardId" value="${board.boardId}">
                                <textarea class="comment-input" name="commentContent" rows="3"
                                          placeholder="댓글을 입력하세요..." maxlength="1000" required></textarea>
                                <div class="text-end mt-2">
                                    <span class="text-muted me-2">
                                        <span id="commentCharCount">0</span> / 1000자
                                    </span>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane me-1"></i>댓글 작성
                                    </button>
                                </div>
                            </form>
                        </div>
                    </c:if>

                    <!-- 댓글 목록 -->
                    <c:choose>
                        <c:when test="${empty comments}">
                            <div class="text-center py-4 text-muted">
                                <i class="fas fa-comment fa-2x mb-2"></i>
                                <p>첫 번째 댓글을 작성해보세요!</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach items="${comments}" var="comment">
                                <div class="comment-item" id="comment-${comment.commentId}">
                                    <div class="d-flex align-items-start">
                                        <div class="author-avatar me-3">
                                            ${fn:substring(comment.commentWriter, 0, 1)}
                                        </div>
                                        <div class="flex-fill">
                                            <div class="d-flex justify-content-between">
                                                <div>
                                                    <strong>${comment.commentWriter}</strong>
                                                    <small class="text-muted ms-2">
                                                        <fmt:formatDate value="${comment.commentRegdate}"
                                                                      pattern="yyyy.MM.dd HH:mm"/>
                                                    </small>
                                                </div>
                                                <c:if test="${not empty sessionScope.loginUser && sessionScope.loginUser.userId eq comment.commentWriter}">
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-light dropdown-toggle"
                                                                data-bs-toggle="dropdown">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <ul class="dropdown-menu">
                                                            <li>
                                                                <a class="dropdown-item" href="#"
                                                                   onclick="editComment(${comment.commentId}, this)"
                                                                   data-content="${fn:escapeXml(comment.commentContent)}">
                                                                    <i class="fas fa-edit me-2"></i>수정
                                                                </a>
                                                            </li>
                                                            <li>
                                                                <a class="dropdown-item text-danger" href="#"
                                                                   onclick="deleteComment(${comment.commentId})">
                                                                    <i class="fas fa-trash me-2"></i>삭제
                                                                </a>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </c:if>
                                            </div>
                                            <div class="comment-content mt-2" id="content-${comment.commentId}">
                                                <p class="mb-0">${comment.commentContent}</p>
                                            </div>
                                            <!-- 수정 폼 -->
                                            <div class="comment-edit-form" id="edit-form-${comment.commentId}"
                                                 style="display: none;">
                                                <form action="${pageContext.request.contextPath}/comment/edit/${comment.commentId}"
                                                      method="post">
                                                    <input type="hidden" name="boardId" value="${board.boardId}">
                                                    <div class="mb-2">
                                                        <textarea class="form-control" name="commentContent" rows="3"
                                                                  maxlength="1000" required></textarea>
                                                    </div>
                                                    <div class="text-end">
                                                        <button type="button" class="btn btn-sm btn-secondary me-2"
                                                                onclick="cancelEdit(${comment.commentId})">취소</button>
                                                        <button type="submit" class="btn btn-sm btn-primary">수정 완료</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- 사이드바 -->
            <div class="col-lg-4">
                <!-- 작성자 정보 -->
                <div class="content-section">
                    <h3 class="section-title">작성자 정보</h3>
                    <a href="${pageContext.request.contextPath}/member/profile/${writer.userId}"
                       class="text-decoration-none">
                        <div class="d-flex align-items-center mb-3" style="cursor: pointer; transition: all 0.3s ease;">
                            <div class="author-avatar me-3" style="width: 60px; height: 60px; font-size: 1.5rem;">
                                ${fn:substring(writer.userName, 0, 1)}
                            </div>
                            <div>
                                <div class="fw-bold text-dark">${writer.userName}</div>
                                <small class="text-muted">@${writer.userId}</small>
                                <c:if test="${not empty writer.userMbti}">
                                    <div class="small text-muted">MBTI: ${writer.userMbti}</div>
                                </c:if>
                            </div>
                        </div>
                    </a>

                    <!-- 액션 버튼 -->
                    <c:if test="${not empty sessionScope.loginUser}">
                        <c:choose>
                            <c:when test="${sessionScope.loginUser.userId eq board.boardWriter}">
                                <!-- 작성자 버튼 -->
                                <a href="${pageContext.request.contextPath}/board/edit/${board.boardId}"
                                   class="btn btn-primary w-100 mb-2">
                                    <i class="fas fa-edit me-2"></i>수정하기
                                </a>
                                <form action="${pageContext.request.contextPath}/board/delete/${board.boardId}"
                                      method="post" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                                    <button type="submit" class="btn btn-danger w-100 mb-2">
                                        <i class="fas fa-trash me-2"></i>삭제하기
                                    </button>
                                </form>
                            </c:when>
                            <c:when test="${sessionScope.loginUser.userRole eq 'ADMIN'}">
                                <!-- 관리자 버튼 (삭제만) -->
                                <form action="${pageContext.request.contextPath}/board/delete/${board.boardId}"
                                      method="post" onsubmit="return confirm('정말 삭제하시겠습니까?');">
                                    <button type="submit" class="btn btn-danger w-100 mb-2">
                                        <i class="fas fa-trash me-2"></i>삭제하기 (관리자)
                                    </button>
                                </form>
                            </c:when>
                        </c:choose>
                    </c:if>

                    <a href="${pageContext.request.contextPath}/board/list"
                       class="btn btn-outline-secondary w-100">
                        <i class="fas fa-list me-2"></i>목록으로
                    </a>
                </div>

                <!-- 인기 글 -->
                <div class="content-section">
                    <h3 class="section-title">🔥 인기 게시글</h3>
                    <div class="list-group list-group-flush">
                        <c:choose>
                            <c:when test="${not empty popularBoards}">
                                <c:forEach items="${popularBoards}" var="popular" varStatus="status">
                                    <a href="${pageContext.request.contextPath}/board/detail/${popular.boardId}"
                                       class="list-group-item list-group-item-action border-0 px-0">
                                        <div class="d-flex align-items-center">
                                            <span class="badge ${status.index == 0 ? 'bg-danger' : status.index == 1 ? 'bg-warning text-dark' : status.index == 2 ? 'bg-success' : status.index == 3 ? 'bg-primary' : 'bg-info'} me-2">
                                                ${status.count}
                                            </span>
                                            <div class="flex-grow-1">
                                                <h6 class="mb-0 text-truncate" style="max-width: 200px;">
                                                    ${popular.boardTitle}
                                                </h6>
                                                <small class="text-muted">
                                                    조회 <fmt:formatNumber value="${popular.boardViews}" pattern="#,###"/>
                                                </small>
                                            </div>
                                        </div>
                                    </a>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="text-center py-3 text-muted">
                                    <i class="fas fa-info-circle"></i> 인기 게시글이 없습니다.
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 플로팅 액션 버튼 -->
    <div class="floating-actions">
        <button class="fab-btn" title="위로 가기" onclick="window.scrollTo({top: 0, behavior: 'smooth'})">
            <i class="fas fa-arrow-up"></i>
        </button>
        <c:if test="${not empty sessionScope.loginUser}">
            <a href="${pageContext.request.contextPath}/board/create" class="fab-btn primary" title="글쓰기">
                <i class="fas fa-pen"></i>
            </a>
        </c:if>
    </div>

    <!-- 신고 모달 -->
    <div class="modal fade" id="reportModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">게시글 신고하기</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">신고 사유</label>
                        <select class="form-select" id="reportCategory" required>
                            <option value="">선택해주세요</option>
                            <option value="SPAM">스팸/도배</option>
                            <option value="INAPPROPRIATE">부적절한 내용</option>
                            <option value="HARASSMENT">욕설/비방</option>
                            <option value="COPYRIGHT">저작권 침해</option>
                            <option value="FRAUD">사기/허위정보</option>
                            <option value="OTHER">기타</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">상세 내용</label>
                        <textarea class="form-control" id="reportContent" rows="4"
                                  placeholder="신고 사유를 구체적으로 작성해주세요. (최소 10자 이상)" required></textarea>
                        <div class="form-text">허위 신고 시 제재를 받을 수 있습니다.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                    <button type="button" class="btn btn-danger" onclick="submitReport()">신고하기</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <script>
        // 댓글 글자수 카운트
        document.addEventListener('DOMContentLoaded', function() {
            const commentTextarea = document.querySelector('.comment-input');
            if (commentTextarea) {
                commentTextarea.addEventListener('input', function() {
                    const charCount = this.value.length;
                    document.getElementById('commentCharCount').textContent = charCount;
                });
            }

            // 애니메이션 효과
            const observerOptions = {
                threshold: 0.1,
                rootMargin: '0px 0px -50px 0px'
            };

            const observer = new IntersectionObserver(function(entries) {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('animate-fade-in');
                    }
                });
            }, observerOptions);

            document.querySelectorAll('.content-section').forEach(el => {
                observer.observe(el);
            });
        });

        // 댓글 수정
        function editComment(commentId, element) {
            const content = element.getAttribute('data-content');
            document.getElementById('content-' + commentId).style.display = 'none';
            document.getElementById('edit-form-' + commentId).style.display = 'block';
            const textarea = document.querySelector('#edit-form-' + commentId + ' textarea');
            if (textarea && content) {
                textarea.value = content;
            }
        }

        function cancelEdit(commentId) {
            document.getElementById('edit-form-' + commentId).style.display = 'none';
            document.getElementById('content-' + commentId).style.display = 'block';
        }

        function deleteComment(commentId) {
            if (confirm('정말 이 댓글을 삭제하시겠습니까?')) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = '${pageContext.request.contextPath}/comment/delete/' + commentId;

                const boardIdInput = document.createElement('input');
                boardIdInput.type = 'hidden';
                boardIdInput.name = 'boardId';
                boardIdInput.value = '${board.boardId}';

                form.appendChild(boardIdInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        // 좋아요/싫어요 초기화
        <c:if test="${not empty sessionScope.loginUser}">
        loadLikeStatus();
        </c:if>

        function loadLikeStatus() {
            fetch('${pageContext.request.contextPath}/like/status?boardId=${board.boardId}')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        updateLikeButton(data.isLiked, data.likeCount);
                        updateDislikeButton(data.isDisliked, data.dislikeCount);
                    }
                })
                .catch(error => console.error('좋아요/싫어요 상태 로드 오류:', error));
        }

        function toggleLike() {
            fetch('${pageContext.request.contextPath}/like/toggle', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'boardId=${board.boardId}'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    updateLikeButton(data.isLiked, data.likeCount);
                    updateDislikeButton(data.isDisliked, data.dislikeCount);
                    document.getElementById('likeCountHeader').textContent = data.likeCount;
                } else {
                    alert(data.message || '좋아요 처리 중 오류가 발생했습니다.');
                }
            })
            .catch(error => {
                console.error('좋아요 처리 오류:', error);
                alert('좋아요 처리 중 오류가 발생했습니다.');
            });
        }

        function updateLikeButton(isLiked, likeCount) {
            const likeBtn = document.getElementById('likeBtn');
            const likeBtnCount = document.getElementById('likeBtnCount');

            if (likeBtn) {
                if (isLiked) {
                    likeBtn.classList.add('btn-like-active');
                    likeBtn.classList.remove('btn-outline-danger');
                } else {
                    likeBtn.classList.remove('btn-like-active');
                    likeBtn.classList.add('btn-outline-danger');
                }
                likeBtnCount.textContent = likeCount;
            }
        }

        function toggleDislike() {
            fetch('${pageContext.request.contextPath}/like/dislike/toggle', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'boardId=${board.boardId}'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    updateLikeButton(data.isLiked, data.likeCount);
                    updateDislikeButton(data.isDisliked, data.dislikeCount);
                    document.getElementById('likeCountHeader').textContent = data.likeCount;
                } else {
                    alert(data.message || '싫어요 처리 중 오류가 발생했습니다.');
                }
            })
            .catch(error => {
                console.error('싫어요 처리 오류:', error);
                alert('싫어요 처리 중 오류가 발생했습니다.');
            });
        }

        function updateDislikeButton(isDisliked, dislikeCount) {
            const dislikeBtn = document.getElementById('dislikeBtn');
            const dislikeBtnCount = document.getElementById('dislikeBtnCount');

            if (dislikeBtn) {
                if (isDisliked) {
                    dislikeBtn.classList.add('btn-dislike-active');
                    dislikeBtn.classList.remove('btn-outline-warning');
                } else {
                    dislikeBtn.classList.remove('btn-dislike-active');
                    dislikeBtn.classList.add('btn-outline-warning');
                }
                dislikeBtnCount.textContent = dislikeCount;
            }
        }

        function toggleBoardFavorite(boardId, isAdd) {
            const url = isAdd
                ? '${pageContext.request.contextPath}/board/favorite/' + boardId
                : '${pageContext.request.contextPath}/board/unfavorite/' + boardId;

            $.ajax({
                url: url,
                type: 'POST',
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        location.reload();
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('찜하기 처리 중 오류가 발생했습니다.');
                }
            });
        }

        function openReportModal() {
            <c:choose>
                <c:when test="${empty sessionScope.loginUser}">
                    alert('로그인 후 신고할 수 있습니다.');
                </c:when>
                <c:otherwise>
                    $('#reportModal').modal('show');
                </c:otherwise>
            </c:choose>
        }

        function submitReport() {
            const category = $('#reportCategory').val();
            const content = $('#reportContent').val().trim();

            if (!category) {
                alert('신고 사유를 선택해주세요.');
                return;
            }

            if (content.length < 10) {
                alert('신고 내용을 10자 이상 작성해주세요.');
                return;
            }

            const reportData = {
                reportedContentType: 'BOARD',
                reportedContentId: ${board.boardId},
                reportedUserId: '${board.boardWriter}',
                reportCategory: category,
                reportContent: content
            };

            $.ajax({
                url: '${pageContext.request.contextPath}/api/reports/submit',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(reportData),
                success: function(response) {
                    if (response.success) {
                        alert(response.message);
                        $('#reportModal').modal('hide');
                        $('#reportCategory').val('');
                        $('#reportContent').val('');
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('신고 접수 중 오류가 발생했습니다.');
                }
            });
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>