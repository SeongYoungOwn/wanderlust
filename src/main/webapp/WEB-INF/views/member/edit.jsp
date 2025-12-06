<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>프로필 수정 - AI 여행 동행 매칭 플랫폼</title>
    <style>
        body {
            padding-top: 100px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            background-attachment: fixed;
            min-height: 100vh;
        }
        
        .edit-container {
            max-width: 600px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
        }
        
        .edit-header {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .edit-header h2 {
            color: #667eea;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        
        .edit-header p {
            color: #6c757d;
            margin: 0;
        }
        
        .form-floating {
            margin-bottom: 1.5rem;
        }
        
        .form-control {
            border: 2px solid rgba(102, 126, 234, 0.1);
            border-radius: 12px;
            padding: 0.75rem 1rem;
            background: rgba(255, 255, 255, 0.9);
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
            background: white;
        }
        
        .form-label {
            color: #495057;
            font-weight: 500;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            border: none;
            border-radius: 12px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
        }
        
        .btn-secondary {
            background: #6c757d;
            border: none;
            border-radius: 12px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s ease;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-2px);
        }
        
        .alert {
            border: none;
            border-radius: 12px;
            margin-bottom: 1.5rem;
        }
        
        .password-section {
            background: rgba(102, 126, 234, 0.05);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }
        
        .password-section h5 {
            color: #667eea;
            margin-bottom: 1rem;
        }
        
        .form-text {
            font-size: 0.875rem;
            color: #6c757d;
        }
        
        .readonly-field {
            background-color: #f8f9fa !important;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>
        
        <div class="container my-5">
            <div class="edit-container">
                <div class="edit-header">
                    <h2><i class="fas fa-user-edit me-2"></i>프로필 수정</h2>
                    <p>개인정보를 수정하려면 현재 비밀번호를 입력해주세요</p>
                </div>
                
                <!-- 메시지 표시 -->
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-triangle me-2"></i>${error}
                    </div>
                </c:if>
                
                <c:if test="${not empty success}">
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle me-2"></i>${success}
                    </div>
                </c:if>
                
                <form method="post" action="${pageContext.request.contextPath}/member/edit" id="editForm">
                    <!-- 현재 비밀번호 -->
                    <div class="form-floating">
                        <input type="password" class="form-control" id="currentPassword" name="currentPassword" 
                               placeholder="현재 비밀번호" required>
                        <label for="currentPassword">현재 비밀번호 *</label>
                        <div class="form-text">수정을 위해 현재 비밀번호를 입력해주세요</div>
                    </div>
                    
                    <!-- 아이디 (수정 불가) -->
                    <div class="form-floating">
                        <input type="text" class="form-control readonly-field" id="userId" 
                               value="${member.userId}" readonly>
                        <label for="userId">아이디</label>
                        <div class="form-text">아이디는 보안상 변경할 수 없습니다</div>
                    </div>
                    
                    <!-- 이름 (수정 불가) -->
                    <div class="form-floating">
                        <input type="text" class="form-control readonly-field" id="userName" 
                               value="${member.userName}" readonly>
                        <label for="userName">이름</label>
                        <div class="form-text">이름은 변경할 수 없습니다</div>
                    </div>
                    
                    <!-- 닉네임 -->
                    <div class="form-floating">
                        <input type="text" class="form-control" id="nickname" name="nickname" 
                               value="${member.nickname}" placeholder="닉네임" required>
                        <label for="nickname">닉네임 *</label>
                        <div class="form-text" id="nicknameMessage"></div>
                    </div>
                    
                    <!-- 이메일 -->
                    <div class="form-floating">
                        <input type="email" class="form-control" id="userEmail" name="userEmail" 
                               value="${member.userEmail}" placeholder="이메일" required>
                        <label for="userEmail">이메일 *</label>
                        <div class="form-text" id="emailMessage"></div>
                    </div>
                    
                    <!-- 비밀번호 변경 섹션 -->
                    <div class="password-section">
                        <h5><i class="fas fa-lock me-2"></i>비밀번호 변경 (선택사항)</h5>
                        <div class="form-floating mb-3">
                            <input type="password" class="form-control" id="newPassword" name="newPassword" 
                                   placeholder="새 비밀번호">
                            <label for="newPassword">새 비밀번호</label>
                            <div class="form-text">비밀번호를 변경하지 않으려면 비워두세요</div>
                        </div>
                        
                        <div class="form-floating">
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" 
                                   placeholder="새 비밀번호 확인">
                            <label for="confirmPassword">새 비밀번호 확인</label>
                            <div class="form-text" id="passwordMessage"></div>
                        </div>
                    </div>
                    
                    <!-- 버튼 -->
                    <div class="row">
                        <div class="col-6">
                            <button type="button" class="btn btn-secondary" onclick="history.back()">
                                <i class="fas fa-arrow-left me-2"></i>취소
                            </button>
                        </div>
                        <div class="col-6">
                            <button type="submit" class="btn btn-primary" id="submitBtn">
                                <i class="fas fa-save me-2"></i>수정하기
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        
        <%@ include file="../common/footer.jsp" %>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 원본 값들 저장
        const originalNickname = '${member.nickname}';
        const originalEmail = '${member.userEmail}';
        
        // 닉네임 중복 확인
        $('#nickname').on('blur', function() {
            const nickname = $(this).val().trim();
            const messageDiv = $('#nicknameMessage');
            
            if (nickname === '') {
                messageDiv.text('닉네임을 입력해주세요').removeClass('text-success text-danger').addClass('text-warning');
                return;
            }
            
            if (nickname === originalNickname) {
                messageDiv.text('현재 사용중인 닉네임입니다').removeClass('text-danger text-warning').addClass('text-success');
                return;
            }
            
            $.get('/member/check-nickname', { nickname: nickname })
                .done(function(response) {
                    if (response.exists) {
                        messageDiv.text(response.message).removeClass('text-success text-warning').addClass('text-danger');
                    } else {
                        messageDiv.text(response.message).removeClass('text-danger text-warning').addClass('text-success');
                    }
                })
                .fail(function() {
                    messageDiv.text('닉네임 확인 중 오류가 발생했습니다').removeClass('text-success text-warning').addClass('text-danger');
                });
        });
        
        // 이메일 유효성 검사
        $('#userEmail').on('blur', function() {
            const email = $(this).val().trim();
            const messageDiv = $('#emailMessage');
            
            if (email === originalEmail) {
                messageDiv.text('현재 사용중인 이메일입니다').removeClass('text-danger text-warning').addClass('text-success');
                return;
            }
            
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
                messageDiv.text('올바른 이메일 형식이 아닙니다').removeClass('text-success text-warning').addClass('text-danger');
                return;
            }
            
            messageDiv.text('사용 가능한 이메일입니다').removeClass('text-danger text-warning').addClass('text-success');
        });
        
        // 비밀번호 확인
        $('#confirmPassword').on('input', function() {
            const newPassword = $('#newPassword').val();
            const confirmPassword = $(this).val();
            const messageDiv = $('#passwordMessage');
            
            if (newPassword === '' && confirmPassword === '') {
                messageDiv.text('');
                return;
            }
            
            if (newPassword !== confirmPassword) {
                messageDiv.text('비밀번호가 일치하지 않습니다').removeClass('text-success').addClass('text-danger');
            } else if (newPassword.length < 4) {
                messageDiv.text('비밀번호는 4자 이상이어야 합니다').removeClass('text-success').addClass('text-danger');
            } else {
                messageDiv.text('비밀번호가 일치합니다').removeClass('text-danger').addClass('text-success');
            }
        });
        
        // 새 비밀번호 입력시
        $('#newPassword').on('input', function() {
            const newPassword = $(this).val();
            const confirmPassword = $('#confirmPassword').val();
            
            if (confirmPassword !== '') {
                $('#confirmPassword').trigger('input');
            }
        });
        
        // 폼 제출 전 검증
        $('#editForm').on('submit', function(e) {
            const currentPassword = $('#currentPassword').val().trim();
            const nickname = $('#nickname').val().trim();
            const email = $('#userEmail').val().trim();
            const newPassword = $('#newPassword').val();
            const confirmPassword = $('#confirmPassword').val();
            
            // 필수 필드 검증
            if (!currentPassword) {
                alert('현재 비밀번호를 입력해주세요.');
                e.preventDefault();
                return;
            }
            
            if (!nickname) {
                alert('닉네임을 입력해주세요.');
                e.preventDefault();
                return;
            }
            
            if (!email) {
                alert('이메일을 입력해주세요.');
                e.preventDefault();
                return;
            }
            
            // 새 비밀번호 검증
            if (newPassword || confirmPassword) {
                if (newPassword !== confirmPassword) {
                    alert('새 비밀번호가 일치하지 않습니다.');
                    e.preventDefault();
                    return;
                }
                
                if (newPassword.length < 4) {
                    alert('새 비밀번호는 4자 이상이어야 합니다.');
                    e.preventDefault();
                    return;
                }
            }
            
            // 제출 버튼 비활성화
            $('#submitBtn').prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-2"></i>수정 중...');
        });
    </script>
</body>
</html>