<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UI Components Demo - Tour Project</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <!-- UI Component Styles -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pagination.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/ui-utils.css">
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f8fafc;
            padding: 2rem 0;
        }
        
        .demo-section {
            background: white;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
        }
        
        .demo-title {
            color: #1f2937;
            font-weight: 600;
            margin-bottom: 1.5rem;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 0.5rem;
        }
        
        .demo-button {
            margin: 0.5rem;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            border: none;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .demo-button-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .demo-button-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }
        
        .demo-button-secondary {
            background: #f3f4f6;
            color: #374151;
            border: 1px solid #d1d5db;
        }
        
        .demo-button-secondary:hover {
            background: #e5e7eb;
        }
        
        .code-block {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
            font-family: 'Monaco', 'Consolas', monospace;
            font-size: 0.875rem;
            color: #495057;
        }
        
        .file-input-demo {
            border: 2px dashed #d1d5db;
            border-radius: 8px;
            padding: 2rem;
            text-align: center;
            background: #f9fafb;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .file-input-demo:hover {
            border-color: #667eea;
            background: #f0f7ff;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="text-center mb-5">
            <h1 class="display-4 fw-bold text-primary">UI Components Demo</h1>
            <p class="lead text-muted">Tour Project에서 사용할 수 있는 모든 UI 컴포넌트들을 테스트해보세요.</p>
        </div>

        <!-- Loading Spinner Demo -->
        <div class="demo-section">
            <h2 class="demo-title">
                <i class="fas fa-spinner me-2"></i>Loading Spinner
            </h2>
            <p class="text-muted mb-3">로딩 상태를 사용자에게 표시하는 컴포넌트입니다.</p>
            
            <button class="demo-button demo-button-primary" onclick="demoLoadingSpinner()">
                <i class="fas fa-play me-2"></i>Loading Spinner 테스트
            </button>
            
            <div class="code-block">
                <strong>사용법:</strong><br>
                UIComponents.loading.show('로딩 메시지');<br>
                UIComponents.loading.hide();
            </div>
        </div>

        <!-- Skeleton Screen Demo -->
        <div class="demo-section">
            <h2 class="demo-title">
                <i class="fas fa-image me-2"></i>Skeleton Screen
            </h2>
            <p class="text-muted mb-3">콘텐츠 로딩 중 구조를 미리 보여주는 컴포넌트입니다.</p>
            
            <button class="demo-button demo-button-primary" onclick="demoSkeletonCard()">
                <i class="fas fa-th-large me-2"></i>Card Skeleton
            </button>
            <button class="demo-button demo-button-secondary" onclick="demoSkeletonList()">
                <i class="fas fa-list me-2"></i>List Skeleton
            </button>
            
            <div class="code-block">
                <strong>사용법:</strong><br>
                UIComponents.skeleton.showCard(); // 카드 형태<br>
                UIComponents.skeleton.showList(); // 리스트 형태<br>
                UIComponents.skeleton.hide();
            </div>
        </div>

        <!-- Toast Messages Demo -->
        <div class="demo-section">
            <h2 class="demo-title">
                <i class="fas fa-comment-dots me-2"></i>Toast Messages
            </h2>
            <p class="text-muted mb-3">사용자에게 알림 메시지를 표시하는 컴포넌트입니다.</p>
            
            <button class="demo-button demo-button-primary bg-success" onclick="demoToastSuccess()">
                <i class="fas fa-check me-2"></i>Success Toast
            </button>
            <button class="demo-button demo-button-primary bg-danger" onclick="demoToastError()">
                <i class="fas fa-exclamation-circle me-2"></i>Error Toast
            </button>
            <button class="demo-button demo-button-primary bg-warning" onclick="demoToastWarning()">
                <i class="fas fa-exclamation-triangle me-2"></i>Warning Toast
            </button>
            <button class="demo-button demo-button-primary bg-info" onclick="demoToastInfo()">
                <i class="fas fa-info-circle me-2"></i>Info Toast
            </button>
            
            <div class="code-block">
                <strong>사용법:</strong><br>
                UIComponents.toast.success('성공 메시지');<br>
                UIComponents.toast.error('에러 메시지');<br>
                UIComponents.toast.warning('경고 메시지');<br>
                UIComponents.toast.info('정보 메시지');
            </div>
        </div>

        <!-- Progress Bar Demo -->
        <div class="demo-section">
            <h2 class="demo-title">
                <i class="fas fa-tasks me-2"></i>Progress Bar
            </h2>
            <p class="text-muted mb-3">파일 업로드나 긴 작업의 진행률을 표시하는 컴포넌트입니다.</p>
            
            <button class="demo-button demo-button-primary" onclick="demoUploadProgress()">
                <i class="fas fa-upload me-2"></i>Upload Progress
            </button>
            <button class="demo-button demo-button-secondary" onclick="demoGeneralProgress()">
                <i class="fas fa-cog me-2"></i>General Progress
            </button>
            <button class="demo-button demo-button-secondary" onclick="demoPageProgress()">
                <i class="fas fa-globe me-2"></i>Page Progress
            </button>
            
            <div class="file-input-demo" onclick="document.getElementById('demoFile').click()">
                <i class="fas fa-cloud-upload-alt fa-3x text-muted mb-3"></i>
                <h5>실제 파일 업로드 테스트</h5>
                <p class="text-muted">클릭하여 파일을 선택하세요</p>
                <input type="file" id="demoFile" style="display: none;" onchange="handleFileUpload(this)">
            </div>
            
            <div class="code-block">
                <strong>사용법:</strong><br>
                UIComponents.progress.showUpload('파일명');<br>
                UIComponents.progress.updateUpload(loaded, total);<br>
                UIComponents.progress.show('제목', '메시지');<br>
                UIComponents.progress.update(percentage, '메시지');
            </div>
        </div>

        <!-- Pagination Demo -->
        <div class="demo-section">
            <h2 class="demo-title">
                <i class="fas fa-list-ol me-2"></i>Pagination
            </h2>
            <p class="text-muted mb-3">페이지네이션 컴포넌트 스타일링 예시입니다.</p>
            
            <nav aria-label="페이지네이션 데모">
                <ul class="pagination justify-content-center">
                    <li class="page-item disabled">
                        <span class="page-link">
                            <i class="fas fa-chevron-left me-1"></i>이전
                        </span>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="#">1</a>
                    </li>
                    <li class="page-item active">
                        <span class="page-link">2</span>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="#">3</a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="#">4</a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="#">5</a>
                    </li>
                    <li class="page-item">
                        <a class="page-link" href="#">
                            다음<i class="fas fa-chevron-right ms-1"></i>
                        </a>
                    </li>
                </ul>
            </nav>
            
            <div class="text-center mt-3 text-muted">
                <small>
                    전체 <strong>150</strong>개 중 
                    <strong>11</strong>-<strong>20</strong>번째 표시
                    (전체 <strong>15</strong> 페이지 중 <strong>2</strong> 페이지)
                </small>
            </div>
        </div>

        <!-- AJAX & Validation Demo -->
        <div class="demo-section">
            <h2 class="demo-title">
                <i class="fas fa-code me-2"></i>AJAX & Validation
            </h2>
            <p class="text-muted mb-3">AJAX 요청과 폼 검증 유틸리티 데모입니다.</p>
            
            <div class="row">
                <div class="col-md-6">
                    <h5>AJAX 요청</h5>
                    <button class="demo-button demo-button-primary" onclick="demoAjaxRequest()">
                        <i class="fas fa-satellite-dish me-2"></i>AJAX GET 요청
                    </button>
                    <button class="demo-button demo-button-secondary" onclick="demoAjaxWithLoading()">
                        <i class="fas fa-spinner me-2"></i>Loading과 함께
                    </button>
                </div>
                <div class="col-md-6">
                    <h5>폼 검증</h5>
                    <div class="mb-3">
                        <input type="email" id="emailInput" class="form-control" placeholder="이메일을 입력하세요">
                    </div>
                    <button class="demo-button demo-button-primary" onclick="demoValidation()">
                        <i class="fas fa-check me-2"></i>이메일 검증
                    </button>
                </div>
            </div>
        </div>

        <!-- Utility Functions Demo -->
        <div class="demo-section">
            <h2 class="demo-title">
                <i class="fas fa-tools me-2"></i>Utility Functions
            </h2>
            <p class="text-muted mb-3">유용한 유틸리티 함수들을 테스트해보세요.</p>
            
            <button class="demo-button demo-button-primary" onclick="demoCopyToClipboard()">
                <i class="fas fa-copy me-2"></i>클립보드 복사
            </button>
            <button class="demo-button demo-button-secondary" onclick="demoFormatNumber()">
                <i class="fas fa-hashtag me-2"></i>숫자 포맷팅
            </button>
            <button class="demo-button demo-button-secondary" onclick="demoFormatDate()">
                <i class="fas fa-calendar me-2"></i>날짜 포맷팅
            </button>
            
            <div id="utilityResults" class="mt-3 p-3 bg-light rounded" style="display: none;">
                <h6>결과:</h6>
                <div id="utilityOutput"></div>
            </div>
        </div>
    </div>

    <!-- UI Components -->
    <jsp:include page="../../../resources/components/loading-spinner.jsp" />
    <jsp:include page="../../../resources/components/skeleton-screen.jsp" />
    <jsp:include page="../../../resources/components/toast-messages.jsp" />
    <jsp:include page="../../../resources/components/progress-bar.jsp" />

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="${pageContext.request.contextPath}/resources/js/ui-components.js"></script>

    <script>
        // Loading Spinner Demo
        function demoLoadingSpinner() {
            UIComponents.loading.show('데모 로딩 중...');
            setTimeout(() => {
                UIComponents.loading.hide();
                UIComponents.toast.success('로딩이 완료되었습니다!');
            }, 3000);
        }

        // Skeleton Screen Demo
        function demoSkeletonCard() {
            UIComponents.skeleton.showCard();
            setTimeout(() => {
                UIComponents.skeleton.hide();
                UIComponents.toast.info('카드 스켈레톤이 숨겨졌습니다.');
            }, 3000);
        }

        function demoSkeletonList() {
            UIComponents.skeleton.showList();
            setTimeout(() => {
                UIComponents.skeleton.hide();
                UIComponents.toast.info('리스트 스켈레톤이 숨겨졌습니다.');
            }, 3000);
        }

        // Toast Messages Demo
        function demoToastSuccess() {
            UIComponents.toast.success('성공적으로 처리되었습니다!', 3000);
        }

        function demoToastError() {
            UIComponents.toast.error('오류가 발생했습니다. 다시 시도해주세요.');
        }

        function demoToastWarning() {
            UIComponents.toast.warning('주의: 이 작업은 되돌릴 수 없습니다.');
        }

        function demoToastInfo() {
            UIComponents.toast.info('새로운 업데이트가 있습니다.');
        }

        // Progress Bar Demo
        function demoUploadProgress() {
            UIComponents.progress.showUpload('demo-file.jpg');
            
            let progress = 0;
            const total = 1000000; // 1MB
            const interval = setInterval(() => {
                progress += Math.random() * 100000;
                if (progress >= total) {
                    progress = total;
                    clearInterval(interval);
                }
                UIComponents.progress.updateUpload(progress, total);
                
                if (progress >= total) {
                    setTimeout(() => {
                        UIComponents.toast.success('파일 업로드가 완료되었습니다!');
                    }, 1000);
                }
            }, 200);
        }

        function demoGeneralProgress() {
            UIComponents.progress.show('데이터 처리 중', '잠시만 기다려주세요...');
            
            let progress = 0;
            const interval = setInterval(() => {
                progress += Math.random() * 15;
                if (progress >= 100) {
                    progress = 100;
                    clearInterval(interval);
                }
                UIComponents.progress.update(progress, `진행률: ${Math.round(progress)}%`);
            }, 300);
        }

        function demoPageProgress() {
            const interval = UIComponents.progress.showPage();
            setTimeout(() => {
                clearInterval(interval);
                UIComponents.progress.completePage();
                UIComponents.toast.info('페이지 로딩이 완료되었습니다.');
            }, 3000);
        }

        // File Upload Demo
        function handleFileUpload(input) {
            if (input.files && input.files[0]) {
                const file = input.files[0];
                
                // 파일 크기 검증
                if (!UIComponents.validation.fileSize(file, 10)) {
                    return;
                }
                
                // 파일 확장자 검증
                if (!UIComponents.validation.fileExtension(file, ['jpg', 'jpeg', 'png', 'gif'])) {
                    return;
                }
                
                // 업로드 시뮬레이션
                UIComponents.progress.showUpload(file.name);
                
                let progress = 0;
                const interval = setInterval(() => {
                    progress += Math.random() * 50000;
                    if (progress >= file.size) {
                        progress = file.size;
                        clearInterval(interval);
                    }
                    UIComponents.progress.updateUpload(progress, file.size);
                    
                    if (progress >= file.size) {
                        setTimeout(() => {
                            UIComponents.toast.success(`${file.name} 업로드가 완료되었습니다!`);
                        }, 1000);
                    }
                }, 100);
            }
        }

        // AJAX Demo
        function demoAjaxRequest() {
            // JSON placeholder API 사용
            UIComponents.ajax.get('https://jsonplaceholder.typicode.com/posts/1')
                .then(data => {
                    UIComponents.toast.success('AJAX 요청이 성공했습니다!');
                    console.log('받은 데이터:', data);
                })
                .catch(error => {
                    UIComponents.toast.error('AJAX 요청이 실패했습니다.');
                    console.error('에러:', error);
                });
        }

        function demoAjaxWithLoading() {
            UIComponents.ajax.get('https://jsonplaceholder.typicode.com/posts', {
                showLoading: true
            })
                .then(data => {
                    UIComponents.toast.success(`${data.length}개의 포스트를 불러왔습니다!`);
                })
                .catch(error => {
                    UIComponents.toast.error('데이터를 불러오는데 실패했습니다.');
                });
        }

        // Validation Demo
        function demoValidation() {
            const email = document.getElementById('emailInput').value;
            
            if (UIComponents.validation.required(email, '이메일')) {
                if (UIComponents.validation.email(email)) {
                    UIComponents.toast.success('유효한 이메일 주소입니다!');
                }
            }
        }

        // Utility Functions Demo
        function demoCopyToClipboard() {
            const text = 'UI Components Demo - Tour Project에서 복사된 텍스트입니다!';
            UIComponents.utils.copyToClipboard(text);
        }

        function demoFormatNumber() {
            const number = 1234567.89;
            const formatted = UIComponents.utils.formatNumber(number);
            showUtilityResult('숫자 포맷팅', `${number} → ${formatted}`);
        }

        function demoFormatDate() {
            const date = new Date();
            const formatted = UIComponents.utils.formatDate(date, 'YYYY.MM.DD HH:mm');
            showUtilityResult('날짜 포맷팅', `현재 시간: ${formatted}`);
        }

        function showUtilityResult(title, result) {
            const resultsDiv = document.getElementById('utilityResults');
            const outputDiv = document.getElementById('utilityOutput');
            
            outputDiv.innerHTML = `<strong>${title}:</strong> ${result}`;
            resultsDiv.style.display = 'block';
            
            setTimeout(() => {
                resultsDiv.style.display = 'none';
            }, 5000);
        }
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>