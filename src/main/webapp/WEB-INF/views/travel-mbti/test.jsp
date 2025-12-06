<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>여행 MBTI 테스트 - Wanderlust</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: var(--bg-primary);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
        }
        .test-container {
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            margin-top: 80px;
        }
        .test-header {
            text-align: center;
            margin-bottom: 40px;
            padding: 50px 0 30px 0;
            background: linear-gradient(-45deg, #e0c3fc, #8ec5fc, #e0c3fc, #8ec5fc);
            background-size: 400% 400%;
            animation: gradientAnimation 15s ease infinite;
            color: white;
            border-radius: 25px;
            box-shadow: 0 25px 80px rgba(142, 197, 252, 0.3);
            position: relative;
            overflow: hidden;
            min-height: 50vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        @keyframes gradientAnimation {
            0% {
                background-position: 0% 50%;
            }
            50% {
                background-position: 100% 50%;
            }
            100% {
                background-position: 0% 50%;
            }
        }
        
        
        .test-header h1 {
            font-size: 2.8rem !important;
            font-weight: 800;
            margin-bottom: 1.5rem;
            line-height: 1.2;
            z-index: 10;
            position: relative;
            text-shadow: 0 4px 20px rgba(0,0,0,0.3);
            letter-spacing: -0.5px;
        }
        
        .test-header h1 i {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.9), rgba(255, 255, 255, 0.7));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            filter: drop-shadow(0 2px 4px rgba(255, 255, 255, 0.3));
            margin-right: 1rem;
        }
        
        .test-header .lead {
            font-size: 1.2rem;
            color: rgba(255, 255, 255, 0.95);
            font-weight: 300;
            z-index: 10;
            position: relative;
            max-width: 700px;
            margin: 0 auto 2rem;
            line-height: 1.6;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }
        
        .test-header .alert {
            position: relative;
            z-index: 5;
        }
        .question-card {
            background: var(--bg-card);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            display: none;
            color: var(--text-primary);
        }
        .question-card.active {
            display: block;
        }
        .option-btn {
            width: 100%;
            text-align: left;
            padding: 15px 20px;
            margin: 10px 0;
            border: 2px solid rgba(255, 107, 107, 0.2);
            border-radius: 10px;
            background: var(--bg-secondary);
            color: var(--text-primary);
            transition: all 0.3s ease;
        }
        .option-btn:hover {
            border-color: var(--accent-primary);
            background: var(--bg-card);
        }
        .option-btn.selected {
            border-color: #ff6b6b;
            background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
            color: white;
            transform: scale(1.02);
            box-shadow: 0 4px 15px rgba(255, 107, 107, 0.3);
        }
        .progress {
            height: 10px;
            border-radius: 10px;
            background-color: #e9ecef;
            margin-bottom: 20px;
        }
        .progress-bar {
            background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>
    
    <div class="test-container">
        <div class="test-header">
            <h1 class="display-4 fw-bold">
                <i class="fas fa-brain me-3"></i>
                여행 MBTI 테스트
            </h1>
            <p class="lead">당신의 여행 성향을 알아보세요!</p>
            
            <!-- MBTI 차원 설명 -->
            <div class="alert alert-light mt-4 text-start">
                <h6 class="fw-bold mb-3"><i class="fas fa-lightbulb me-2"></i>여행 MBTI 4가지 차원</h6>
                <div class="row">
                    <div class="col-md-6 mb-2">
                        <strong>P/J:</strong> <span class="text-muted">계획형 vs 즉흥형</span>
                    </div>
                    <div class="col-md-6 mb-2">
                        <strong>A/S:</strong> <span class="text-muted">모험형 vs 안전형</span>
                    </div>
                    <div class="col-md-6 mb-2">
                        <strong>G/I:</strong> <span class="text-muted">그룹형 vs 개인형</span>
                    </div>
                    <div class="col-md-6 mb-2">
                        <strong>L/B:</strong> <span class="text-muted">럭셔리형 vs 백패킹형</span>
                    </div>
                </div>
                <small class="text-muted">총 16가지 여행 스타일로 분류됩니다.</small>
            </div>
            
            <c:if test="${!isLoggedIn}">
                <div class="alert alert-info mt-3">
                    <i class="fas fa-info-circle me-2"></i>
                    로그인하시면 테스트 결과를 저장하고 마이페이지에서 확인할 수 있습니다.
                </div>
            </c:if>
        </div>

        <div class="progress">
            <div class="progress-bar" id="progress-bar" style="width: 12.5%"></div>
        </div>
        <div class="text-center mb-4">
            <span id="progress-text">1 / ${totalQuestions}</span>
        </div>

        <form id="mbti-form">
            <c:forEach var="question" items="${questions}" varStatus="status">
                <div class="question-card ${status.index == 0 ? 'active' : ''}" data-question="${status.index + 1}">
                    <div class="question-number">질문 ${status.index + 1}</div>
                    <h3 class="question-text mb-4">${question.questionText}</h3>
                    <div class="options">
                        <button type="button" class="btn option-btn" data-value="A" data-question="q${status.index + 1}">
                            <i class="fas fa-circle me-2"></i>
                            ${question.optionA}
                        </button>
                        <button type="button" class="btn option-btn" data-value="B" data-question="q${status.index + 1}">
                            <i class="fas fa-circle me-2"></i>
                            ${question.optionB}
                        </button>
                    </div>
                </div>
            </c:forEach>
        </form>

        <div class="text-center mt-4">
            <button type="button" class="btn btn-outline-secondary me-2" id="prev-btn" disabled>
                <i class="fas fa-arrow-left me-2"></i>이전
            </button>
            <button type="button" class="btn btn-primary" id="next-btn" disabled>
                다음<i class="fas fa-arrow-right ms-2"></i>
            </button>
            <button type="button" class="btn btn-success" id="submit-btn" style="display: none;">
                <i class="fas fa-check me-2"></i>결과 보기
            </button>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentQuestion = 1;
        const totalQuestions = ${totalQuestions};
        let answers = {};

        // 옵션 선택 이벤트
        document.querySelectorAll('.option-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const questionKey = this.getAttribute('data-question');
                const value = this.getAttribute('data-value');
                
                // 같은 질문의 다른 선택지 비활성화
                const parentCard = this.closest('.question-card');
                const questionBtns = parentCard.querySelectorAll('.option-btn');
                questionBtns.forEach(b => b.classList.remove('selected'));
                
                // 현재 선택지 활성화
                this.classList.add('selected');
                
                // 답변 저장
                answers[questionKey] = value;
                
                // 다음 버튼 활성화
                updateNavigationButtons();
            });
        });

        // 다음 질문으로 이동
        document.getElementById('next-btn').addEventListener('click', function() {
            if (currentQuestion < totalQuestions) {
                showQuestion(currentQuestion + 1);
            }
        });

        // 이전 질문으로 이동
        document.getElementById('prev-btn').addEventListener('click', function() {
            if (currentQuestion > 1) {
                showQuestion(currentQuestion - 1);
            }
        });

        // 질문 표시
        function showQuestion(questionNum) {
            document.querySelectorAll('.question-card').forEach(card => {
                card.classList.remove('active');
            });
            
            document.querySelector('.question-card[data-question="' + questionNum + '"]').classList.add('active');
            currentQuestion = questionNum;
            
            // 진행률 업데이트
            const progress = (currentQuestion / totalQuestions) * 100;
            document.getElementById('progress-bar').style.width = progress + '%';
            document.getElementById('progress-text').textContent = currentQuestion + ' / ' + totalQuestions;
            
            updateNavigationButtons();
        }

        // 네비게이션 버튼 업데이트
        function updateNavigationButtons() {
            const prevBtn = document.getElementById('prev-btn');
            const nextBtn = document.getElementById('next-btn');
            const submitBtn = document.getElementById('submit-btn');
            
            prevBtn.disabled = currentQuestion === 1;
            
            const currentQuestionKey = 'q' + currentQuestion;
            const hasAnswer = answers[currentQuestionKey];
            
            if (currentQuestion === totalQuestions) {
                nextBtn.style.display = 'none';
                submitBtn.style.display = hasAnswer ? 'inline-block' : 'none';
            } else {
                nextBtn.style.display = 'inline-block';
                nextBtn.disabled = !hasAnswer;
                submitBtn.style.display = 'none';
            }
        }

        // 결과 제출
        document.getElementById('submit-btn').addEventListener('click', function() {
            if (Object.keys(answers).length < totalQuestions) {
                alert('모든 질문에 답변해주세요.');
                return;
            }

            this.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>결과 계산 중...';
            this.disabled = true;

            fetch('${pageContext.request.contextPath}/travel-mbti/submit', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(answers)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    window.location.href = '${pageContext.request.contextPath}/travel-mbti/result/' + data.mbtiType;
                } else {
                    alert(data.message || '오류가 발생했습니다.');
                    this.innerHTML = '<i class="fas fa-check me-2"></i>결과 보기';
                    this.disabled = false;
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('네트워크 오류가 발생했습니다.');
                this.innerHTML = '<i class="fas fa-check me-2"></i>결과 보기';
                this.disabled = false;
            });
        });
    </script>
    
        <%@ include file="../common/footer.jsp" %>
    </div>
</body>
</html>