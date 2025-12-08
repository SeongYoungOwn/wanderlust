<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>게시글 수정 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        body {
            background: var(--bg-primary);
            color: var(--text-primary);
        }
        
        .form-label {
            font-weight: 600;
            color: var(--text-primary);
        }
        .required::after {
            content: " *";
            color: var(--accent-primary);
        }
        .editor-toolbar {
            background-color: var(--bg-secondary);
            border: 1px solid var(--border-color);
            border-bottom: none;
            padding: 0.5rem;
            border-radius: 0.375rem 0.375rem 0 0;
        }
        .content-editor {
            border-radius: 0 0 0.375rem 0.375rem !important;
            border-top: none !important;
            min-height: 300px;
            background: var(--bg-card);
            color: var(--text-primary);
            border-color: var(--border-color);
        }
        .card {
            background: var(--bg-card);
            border-color: var(--border-color);
        }
        .form-control {
            background: var(--bg-card);
            color: var(--text-primary);
            border-color: var(--border-color);
        }
        .form-control:focus {
            background: var(--bg-card);
            color: var(--text-primary);
            border-color: var(--accent-primary);
        }
        .text-muted {
            color: var(--text-muted) !important;
        }
        .form-text {
            color: var(--text-secondary);
        }
    </style>
</head>
<body style="padding-top: 100px;">
    <%@ include file="../common/header.jsp" %>
    <div class="container-fluid p-0">

        <!-- Page Content -->
        <div class="container my-5">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card shadow">
                        <div class="card-body p-5">
                            <div class="text-center mb-4">
                                <i class="fas fa-edit fa-3x text-primary"></i>
                                <h3 class="mt-3">게시글 수정</h3>
                                <p class="text-muted">게시글을 수정하세요</p>
                            </div>

                            <!-- Messages -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="fas fa-exclamation-circle me-2"></i>${error}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                </div>
                            </c:if>

                            <form action="/board/edit/${board.boardId}" method="post" id="editForm">
                                <!-- 숨겨진 필드: 카테고리와 이미지 유지 -->
                                <input type="hidden" name="boardCategory" value="${board.boardCategory}">
                                <input type="hidden" name="boardImage" value="${board.boardImage}">

                                <div class="mb-4">
                                    <label for="boardTitle" class="form-label required">
                                        <i class="fas fa-heading me-2"></i>제목
                                    </label>
                                    <input type="text" class="form-control" id="boardTitle" name="boardTitle" 
                                           required maxlength="255" value="${board.boardTitle}"
                                           placeholder="제목을 입력하세요">
                                    <div class="form-text">게시글의 내용을 잘 나타내는 제목을 입력하세요</div>
                                </div>

                                <div class="mb-4">
                                    <label for="boardContent" class="form-label required">
                                        <i class="fas fa-file-alt me-2"></i>내용
                                    </label>
                                    <div class="editor-toolbar">
                                        <small class="text-muted">
                                            <i class="fas fa-info-circle me-1"></i>
                                            여행 정보, 동행 모집, 후기 등을 자유롭게 작성해주세요
                                        </small>
                                    </div>
                                    <textarea class="form-control content-editor" id="boardContent" name="boardContent" 
                                              required maxlength="5000"
                                              placeholder="내용을 입력하세요...">${board.boardContent}</textarea>
                                    <div class="form-text">
                                        <span id="charCount">${board.boardContent.length()}</span> / 5000자
                                    </div>
                                </div>

                                <div class="d-grid gap-2">
                                    <button type="submit" class="btn btn-primary btn-lg" id="submitBtn">
                                        <i class="fas fa-save me-2"></i>수정 완료
                                    </button>
                                    <a href="/board/detail/${board.boardId}" class="btn btn-outline-secondary">
                                        <i class="fas fa-arrow-left me-2"></i>취소
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer class="bg-dark text-white py-4 mt-5">
            <div class="container text-center">
                <p class="mb-0">&copy; 2024 AI 여행 동행 매칭 플랫폼. All rights reserved.</p>
            </div>
        </footer>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 초기 문자 수 카운트
        const initialContent = document.getElementById('boardContent').value;
        document.getElementById('charCount').textContent = initialContent.length;

        // 문자 수 카운트
        document.getElementById('boardContent').addEventListener('input', function() {
            const charCount = this.value.length;
            document.getElementById('charCount').textContent = charCount;
            
            // 글자 수가 한계에 가까우면 색상 변경
            const countElement = document.getElementById('charCount');
            if (charCount > 4500) {
                countElement.className = 'text-danger';
            } else if (charCount > 4000) {
                countElement.className = 'text-warning';
            } else {
                countElement.className = '';
            }
        });

        // 폼 제출 시 유효성 검사
        document.getElementById('editForm').addEventListener('submit', function(e) {
            const title = document.getElementById('boardTitle').value.trim();
            const content = document.getElementById('boardContent').value.trim();
            
            if (!title) {
                e.preventDefault();
                alert('제목을 입력해주세요.');
                document.getElementById('boardTitle').focus();
                return false;
            }
            
            if (!content) {
                e.preventDefault();
                alert('내용을 입력해주세요.');
                document.getElementById('boardContent').focus();
                return false;
            }
            
            if (content.length < 10) {
                e.preventDefault();
                alert('내용을 10자 이상 입력해주세요.');
                document.getElementById('boardContent').focus();
                return false;
            }
        });

        // 변경사항 추적
        const originalTitle = document.getElementById('boardTitle').value;
        const originalContent = document.getElementById('boardContent').value;
        let isSubmitting = false;

        document.getElementById('editForm').addEventListener('submit', function() {
            isSubmitting = true;
        });

        // 페이지 나가기 전 확인
        window.addEventListener('beforeunload', function(e) {
            const currentTitle = document.getElementById('boardTitle').value;
            const currentContent = document.getElementById('boardContent').value;
            
            if (!isSubmitting && (currentTitle !== originalTitle || currentContent !== originalContent)) {
                e.preventDefault();
                e.returnValue = '수정된 내용이 저장되지 않았습니다. 정말 나가시겠습니까?';
            }
        });
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>