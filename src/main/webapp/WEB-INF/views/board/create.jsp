<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>게시글 작성 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        /* Plan2.html Design Variables */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #fdfbf7;
            color: #2d3748;
            line-height: 1.6;
            overflow-x: hidden;
            min-height: 100vh;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* Page Header */
        .page-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 140px 0 60px 0;
            margin-top: 0;
            position: relative;
            overflow: hidden;
        }
        
        .page-header::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><defs><pattern id="stars" width="20" height="20" patternUnits="userSpaceOnUse"><circle cx="10" cy="10" r="1" fill="white" opacity="0.1"/></pattern></defs><rect width="100" height="100" fill="url(%23stars)"/></svg>');
            animation: twinkle 20s ease-in-out infinite;
        }
        
        @keyframes twinkle {
            0%, 100% { opacity: 0.5; }
            50% { opacity: 1; }
        }

        .page-title {
            font-size: 2.2rem;
            font-weight: 700;
            color: white;
            margin-bottom: 1rem;
            line-height: 1.3;
            z-index: 1;
            position: relative;
        }

        .page-subtitle {
            font-size: 1rem;
            color: rgba(255, 255, 255, 0.9);
            font-weight: 400;
            z-index: 1;
            position: relative;
            max-width: 600px;
            margin: 0 auto;
        }

        /* Form Section */
        .form-section {
            padding: 4rem 0;
            min-height: calc(100vh - 200px);
        }

        .form-card {
            background: white;
            border-radius: 25px;
            overflow: hidden;
            box-shadow: 0 25px 80px rgba(0,0,0,0.15);
            border: 1px solid rgba(255, 107, 107, 0.1);
            position: relative;
            transition: all 0.4s ease;
        }
        
        .form-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 107, 107, 0.1), transparent);
            transition: left 0.5s ease;
        }
        
        .form-card:hover::before {
            left: 100%;
        }
        
        .form-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 35px 100px rgba(255, 107, 107, 0.2);
            border-color: rgba(255, 107, 107, 0.25);
        }

        .form-header {
            background: linear-gradient(135deg, rgba(255, 107, 107, 0.05), rgba(255, 217, 61, 0.05));
            padding: 2.5rem 3rem;
            text-align: center;
            border-bottom: 1px solid rgba(255, 107, 107, 0.1);
        }

        .form-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #ff6b6b, #ff8e53);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1.5rem auto;
            font-size: 2rem;
            color: white;
            box-shadow: 0 8px 24px rgba(255, 107, 107, 0.3);
        }

        .form-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 0.5rem;
        }

        .form-subtitle {
            color: #4a5568;
            font-size: 1rem;
            font-weight: 500;
        }

        .form-body {
            padding: 3rem;
        }

        /* Form Elements */
        .form-group {
            margin-bottom: 2rem;
        }

        .form-label {
            font-weight: 700;
            color: #2d3748;
            margin-bottom: 0.8rem;
            font-size: 1rem;
            display: flex;
            align-items: center;
        }

        .form-label i {
            color: #ff6b6b;
            margin-right: 0.5rem;
        }

        .required::after {
            content: " *";
            color: #e53e3e;
            font-weight: 700;
        }

        .form-control {
            border: 2px solid rgba(255, 107, 107, 0.2);
            border-radius: 20px;
            padding: 1rem 1.5rem;
            font-size: 1rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background: #fdfbf7;
            color: #2d3748;
            font-weight: 500;
        }

        .form-control:focus {
            border-color: #ff6b6b;
            box-shadow: 0 0 0 0.25rem rgba(255, 107, 107, 0.15);
            background: white;
            outline: none;
            transform: translateY(-2px);
        }

        .form-control::placeholder {
            color: #a0aec0;
            font-weight: 500;
        }

        textarea.form-control {
            min-height: 250px;
            resize: vertical;
            line-height: 1.7;
        }

        .form-text {
            font-size: 0.875rem;
            color: #718096;
            margin-top: 0.5rem;
            font-weight: 500;
        }

        .editor-toolbar {
            background: linear-gradient(135deg, rgba(255, 107, 107, 0.03), rgba(255, 217, 61, 0.03));
            border: 2px solid rgba(255, 107, 107, 0.15);
            border-bottom: none;
            padding: 1rem 1.5rem;
            border-radius: 20px 20px 0 0;
            font-weight: 600;
        }
        
        .editor-toolbar i {
            color: #ff6b6b;
            margin-right: 0.3rem;
        }
        
        .content-editor {
            border-radius: 0 0 20px 20px !important;
            border-top: none !important;
            border: 2px solid rgba(255, 107, 107, 0.2) !important;
            border-top: none !important;
        }

        /* Buttons */
        .primary-button {
            background: linear-gradient(135deg, #ff6b6b, #ff8e53);
            color: white;
            border: none;
            padding: 1.2rem 2.5rem;
            border-radius: 35px;
            font-weight: 700;
            font-size: 1.1rem;
            cursor: pointer;
            width: 100%;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 8px 24px rgba(255, 107, 107, 0.3);
            text-decoration: none;
            display: inline-block;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .primary-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s ease;
        }
        
        .primary-button:hover::before {
            left: 100%;
        }

        .primary-button:hover {
            transform: translateY(-4px) scale(1.02);
            box-shadow: 0 12px 40px rgba(255, 107, 107, 0.4);
            color: white;
        }

        .secondary-button {
            background: transparent;
            color: #ff6b6b;
            border: 2px solid #ff6b6b;
            padding: 1.1rem 2.3rem;
            border-radius: 35px;
            font-weight: 600;
            font-size: 1.1rem;
            cursor: pointer;
            width: 100%;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            margin-top: 1rem;
        }

        .secondary-button:hover {
            background: #ff6b6b;
            color: white;
            transform: translateY(-2px);
            text-decoration: none;
        }

        /* Alert Messages */
        .alert {
            border-radius: 20px;
            border: none;
            margin-bottom: 2rem;
            padding: 1.2rem 1.5rem;
            font-weight: 600;
        }

        .alert-danger {
            background: linear-gradient(135deg, #fed7d7, #feb2b2);
            color: #742a2a;
        }

        .alert i {
            margin-right: 0.5rem;
        }

        /* Character Count */
        #charCount {
            font-weight: 700;
        }
        
        .text-warning {
            color: #ff8c00 !important;
        }
        
        .text-danger {
            color: #e53e3e !important;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .page-header {
                padding: 120px 0 40px 0;
            }
            
            .page-title {
                font-size: 1.8rem;
            }
            
            .page-subtitle {
                font-size: 0.9rem;
            }
            
            .form-body {
                padding: 2rem 1.5rem;
            }
            
            .form-header {
                padding: 2rem 1.5rem;
            }
            
            .form-title {
                font-size: 1.5rem;
            }
            
            .container {
                padding: 0 15px;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>
        
        <!-- Page Header -->
        <div class="page-header">
            <div class="container">
                <div class="text-center">
                    <h1 class="page-title">
                        <i class="fas fa-pen-fancy me-3"></i>
                        새 게시글 작성
                    </h1>
                    <p class="page-subtitle">
                        여행의 이야기를 나누고, 함께할 사람들과 소통하여 더 풍성한 여행을 만들어보세요.
                    </p>
                </div>
            </div>
        </div>

        <!-- Form Section -->
        <div class="container form-section">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="form-card">
                        <div class="form-header">
                            <div class="form-icon">
                                <i class="fas fa-edit"></i>
                            </div>
                            <h2 class="form-title">게시글 등록</h2>
                            <p class="form-subtitle">여행 이야기를 공유하고 동행을 찾아보세요</p>
                        </div>
                        
                        <div class="form-body">

                            <!-- Messages -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="fas fa-exclamation-triangle"></i> ${error}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                </div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/board/create" method="post" id="createForm" enctype="multipart/form-data">
                                <div class="form-group">
                                    <label for="boardCategory" class="form-label required">
                                        <i class="fas fa-tags"></i>카테고리
                                    </label>
                                    <select class="form-control" id="boardCategory" name="boardCategory" required>
                                        <option value="">카테고리를 선택하세요</option>
                                        <option value="여행 후기">여행 후기</option>
                                        <option value="여행 팁">여행 팁</option>
                                        <option value="QnA">QnA</option>
                                        <option value="자유">자유</option>
                                    </select>
                                    <div class="form-text">게시글의 성격에 맞는 카테고리를 선택해주세요</div>
                                </div>

                                <div class="form-group">
                                    <label for="boardTitle" class="form-label required">
                                        <i class="fas fa-heading"></i>제목
                                    </label>
                                    <input type="text" class="form-control" id="boardTitle" name="boardTitle" 
                                           required maxlength="255" 
                                           placeholder="제목을 입력하세요">
                                    <div class="form-text">게시글의 내용을 잘 나타내는 제목을 입력하세요</div>
                                </div>

                                <div class="form-group">
                                    <label for="boardImage" class="form-label">
                                        <i class="fas fa-image"></i>이미지
                                    </label>
                                    <input type="file" class="form-control" id="boardImage" name="boardImage" 
                                           accept="image/*" onchange="previewImage(this)">
                                    <div class="form-text">이미지 파일을 선택하세요 (선택사항, 최대 10MB)</div>
                                    <div id="imagePreview" class="mt-3" style="display: none;">
                                        <img id="previewImg" src="" alt="미리보기" style="max-width: 300px; max-height: 200px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
                                        <div class="mt-2">
                                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeImage()">
                                                <i class="fas fa-times"></i> 이미지 제거
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="boardContent" class="form-label required">
                                        <i class="fas fa-file-alt"></i>내용
                                    </label>
                                    <div class="editor-toolbar">
                                        <small class="text-muted">
                                            <i class="fas fa-info-circle"></i>
                                            여행 정보, 동행 모집, 후기 등을 자유롭게 작성해주세요
                                        </small>
                                    </div>
                                    <textarea class="form-control content-editor" id="boardContent" name="boardContent" 
                                              required maxlength="5000"
                                              placeholder="내용을 입력하세요...

• 여행지 정보 공유
• 동행자 모집
• 여행 후기
• 질문 및 답변
• 기타 여행 관련 이야기

자유롭게 작성해주세요!"></textarea>
                                    <div class="form-text">
                                        <span id="charCount">0</span> / 5000자
                                    </div>
                                </div>

                                <div class="form-group">
                                    <button type="submit" class="primary-button" id="submitBtn">
                                        <i class="fas fa-save me-2"></i>게시글 등록
                                    </button>
                                    <a href="${pageContext.request.contextPath}/board/list" class="secondary-button">
                                        <i class="fas fa-arrow-left me-2"></i>목록으로 돌아가기
                                    </a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
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
        document.getElementById('createForm').addEventListener('submit', function(e) {
            const category = document.getElementById('boardCategory').value;
            const title = document.getElementById('boardTitle').value.trim();
            const content = document.getElementById('boardContent').value.trim();
            
            if (!category) {
                e.preventDefault();
                alert('카테고리를 선택해주세요.');
                document.getElementById('boardCategory').focus();
                return false;
            }
            
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

        // 페이지 나가기 전 확인
        let isSubmitting = false;
        document.getElementById('createForm').addEventListener('submit', function() {
            isSubmitting = true;
        });

        window.addEventListener('beforeunload', function(e) {
            const category = document.getElementById('boardCategory').value;
            const title = document.getElementById('boardTitle').value.trim();
            const content = document.getElementById('boardContent').value.trim();
            
            if (!isSubmitting && (category || title || content)) {
                e.preventDefault();
                e.returnValue = '작성 중인 내용이 있습니다. 정말 나가시겠습니까?';
            }
        });

        // 이미지 미리보기 함수
        function previewImage(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('previewImg').src = e.target.result;
                    document.getElementById('imagePreview').style.display = 'block';
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        // 이미지 제거 함수
        function removeImage() {
            document.getElementById('boardImage').value = '';
            document.getElementById('imagePreview').style.display = 'none';
            document.getElementById('previewImg').src = '';
        }
    </script>
</body>
</html>