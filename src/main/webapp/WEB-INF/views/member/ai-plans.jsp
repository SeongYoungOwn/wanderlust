<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>내 AI 여행 계획 - AI 여행 동행 매칭 플랫폼</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #f8fafc;
            color: #2d3748;
            line-height: 1.6;
            padding-top: 60px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        /* Header */
        .page-header {
            text-align: center;
            margin-bottom: 3rem;
        }
        
        .page-header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
        }
        
        .page-header p {
            font-size: 1.1rem;
            color: #718096;
            max-width: 600px;
            margin: 0 auto;
        }
        
        /* Plans Grid */
        .plans-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }
        
        .plan-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            padding: 1.5rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid rgba(255, 255, 255, 0.8);
            position: relative;
            overflow: hidden;
        }
        
        .plan-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12);
        }
        
        .plan-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(135deg, #667eea, #764ba2);
        }
        
        .plan-header {
            display: flex;
            justify-content: between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }
        
        .plan-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 0.5rem;
        }
        
        .plan-destination {
            display: flex;
            align-items: center;
            color: #667eea;
            font-weight: 500;
            margin-bottom: 0.5rem;
        }
        
        .plan-destination i {
            margin-right: 0.5rem;
        }
        
        .plan-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1rem;
            font-size: 0.9rem;
            color: #718096;
        }
        
        .plan-meta-item {
            display: flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        .plan-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .plan-tag {
            background: linear-gradient(135deg, #667eea20, #764ba220);
            color: #667eea;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            border: 1px solid rgba(102, 126, 234, 0.2);
        }
        
        .plan-date {
            color: #718096;
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }
        
        .plan-actions {
            display: flex;
            gap: 0.5rem;
            margin-top: auto;
        }
        
        .btn {
            padding: 0.5rem 1rem;
            border-radius: 8px;
            border: none;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.9rem;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }
        
        .btn-secondary {
            background: #f7fafc;
            color: #4a5568;
            border: 1px solid #e2e8f0;
        }
        
        .btn-secondary:hover {
            background: #edf2f7;
        }
        
        .btn-danger {
            background: #fed7d7;
            color: #c53030;
            border: 1px solid #feb2b2;
        }
        
        .btn-danger:hover {
            background: #fbb6ce;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #718096;
        }
        
        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            color: #cbd5e0;
        }
        
        .empty-state h3 {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
            color: #4a5568;
        }
        
        .empty-state p {
            margin-bottom: 2rem;
        }
        
        /* Loading State */
        .loading {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 4rem;
        }
        
        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #e2e8f0;
            border-top: 4px solid #667eea;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        /* Plan Detail Modal */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            z-index: 1000;
            display: none;
        }
        
        .modal {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            border-radius: 15px;
            max-width: 800px;
            width: 90%;
            max-height: 80%;
            overflow-y: auto;
            z-index: 1001;
        }
        
        .modal-header {
            padding: 2rem;
            border-bottom: 1px solid #e2e8f0;
            display: flex;
            justify-content: between;
            align-items: center;
        }
        
        .modal-content {
            padding: 2rem;
        }
        
        .close-btn {
            background: none;
            border: none;
            font-size: 1.5rem;
            cursor: pointer;
            color: #718096;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .plans-grid {
                grid-template-columns: 1fr;
            }
            
            .page-header h1 {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>
    
    <div class="container">
        <div class="page-header">
            <h1><i class="fas fa-robot"></i> 내 AI 여행 계획</h1>
            <p>AI가 추천한 맞춤형 여행 계획을 확인하고 관리하세요</p>
        </div>
        
        <div id="plansContainer" class="loading">
            <div class="spinner"></div>
        </div>
    </div>
    
    <!-- Plan Detail Modal -->
    <div class="modal-overlay" id="modalOverlay">
        <div class="modal">
            <div class="modal-header">
                <h2 id="modalTitle">여행 계획 상세</h2>
                <button class="close-btn" onclick="closeModal()">&times;</button>
            </div>
            <div class="modal-content" id="modalContent">
                <!-- Detail content will be loaded here -->
            </div>
        </div>
    </div>
    
    <script>
        var userPlans = [];
        
        // 페이지 로드 시 AI 여행 계획 목록 로드
        document.addEventListener('DOMContentLoaded', function() {
            loadAIPlans();
        });
        
        // AI 여행 계획 목록 로드
        function loadAIPlans() {
            fetch('/api/travel-plans/my-plans')
                .then(function(response) { return response.json(); })
                .then(function(data) {
                    userPlans = data;
                    renderPlans(data);
                })
                .catch(function(error) {
                    console.error('계획 로드 오류:', error);
                    renderError();
                });
        }
        
        // 계획 목록 렌더링
        function renderPlans(plans) {
            var container = document.getElementById('plansContainer');
            
            if (!plans || plans.length === 0) {
                container.innerHTML = 
                    '<div class="empty-state">' +
                        '<i class="fas fa-map-marked-alt"></i>' +
                        '<h3>저장된 AI 여행 계획이 없습니다</h3>' +
                        '<p>지도에서 AI 여행 추천을 받고 계획을 저장해보세요!</p>' +
                        '<a href="/map/sido-map" class="btn btn-primary">' +
                            '<i class="fas fa-map"></i> AI 여행 추천 받기' +
                        '</a>' +
                    '</div>';
                return;
            }
            
            var plansHtml = '';
            for (var i = 0; i < plans.length; i++) {
                var plan = plans[i];
                var tagsHtml = '';
                if (plan.tags && plan.tags.length > 0) {
                    tagsHtml = '<div class="plan-tags">';
                    for (var j = 0; j < plan.tags.length; j++) {
                        tagsHtml += '<span class="plan-tag">#' + plan.tags[j] + '</span>';
                    }
                    tagsHtml += '</div>';
                }
                
                var memoHtml = '';
                if (plan.memo) {
                    memoHtml = '<div class="plan-date"><i class="fas fa-sticky-note"></i> ' + plan.memo + '</div>';
                }
                
                plansHtml += '<div class="plan-card">' +
                    '<div class="plan-header">' +
                        '<div>' +
                            '<div class="plan-title">' + (plan.title || '제목 없음') + '</div>' +
                            '<div class="plan-destination">' +
                                '<i class="fas fa-map-marker-alt"></i>' +
                                (plan.destination || '목적지 미정') +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                    '<div class="plan-meta">' +
                        '<div class="plan-meta-item">' +
                            '<i class="fas fa-calendar"></i>' +
                            '<span>' + (plan.duration || 3) + '일</span>' +
                        '</div>' +
                        '<div class="plan-meta-item">' +
                            '<i class="fas fa-clock"></i>' +
                            '<span>' + formatDate(plan.createdDate) + '</span>' +
                        '</div>' +
                    '</div>' +
                    tagsHtml +
                    memoHtml +
                    '<div class="plan-actions">' +
                        '<button class="btn btn-primary" onclick="viewPlan(' + plan.planId + ')">' +
                            '<i class="fas fa-eye"></i> 상세보기' +
                        '</button>' +
                        '<button class="btn btn-secondary" onclick="editPlan(' + plan.planId + ')">' +
                            '<i class="fas fa-edit"></i> 수정' +
                        '</button>' +
                        '<button class="btn btn-danger" onclick="deletePlan(' + plan.planId + ')">' +
                            '<i class="fas fa-trash"></i> 삭제' +
                        '</button>' +
                    '</div>' +
                '</div>';
            }
            
            container.innerHTML = '<div class="plans-grid">' + plansHtml + '</div>';
        }
        
        // 오류 상태 렌더링
        function renderError() {
            var container = document.getElementById('plansContainer');
            container.innerHTML = 
                '<div class="empty-state">' +
                    '<i class="fas fa-exclamation-triangle"></i>' +
                    '<h3>계획을 불러오는 중 오류가 발생했습니다</h3>' +
                    '<p>잠시 후 다시 시도해주세요.</p>' +
                    '<button class="btn btn-primary" onclick="loadAIPlans()">' +
                        '<i class="fas fa-refresh"></i> 다시 시도' +
                    '</button>' +
                '</div>';
        }
        
        // 날짜 포맷팅
        function formatDate(dateString) {
            if (!dateString) return '날짜 없음';
            var date = new Date(dateString);
            return date.toLocaleDateString('ko-KR');
        }
        
        // 계획 상세보기
        function viewPlan(planId) {
            fetch('/api/travel-plans/' + planId)
                .then(function(response) { return response.json(); })
                .then(function(plan) {
                    showPlanDetail(plan);
                })
                .catch(function(error) {
                    console.error('계획 상세 로드 오류:', error);
                    alert('계획 상세 정보를 불러오는 중 오류가 발생했습니다.');
                });
        }
        
        // 계획 상세 모달 표시
        function showPlanDetail(plan) {
            var modalTitle = document.getElementById('modalTitle');
            var modalContent = document.getElementById('modalContent');
            var modalOverlay = document.getElementById('modalOverlay');
            
            modalTitle.textContent = plan.title || '여행 계획';
            
            var planContentHtml = '';
            try {
                var planData = JSON.parse(plan.planContent);
                if (planData.aiContent) {
                    planContentHtml = 
                        '<h3><i class="fas fa-robot"></i> AI 추천 내용</h3>' +
                        '<div style="background: #f7fafc; padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; white-space: pre-line;">' +
                            planData.aiContent +
                        '</div>';
                }
                
                if (planData.recommendations && planData.recommendations.length > 0) {
                    planContentHtml += '<h3><i class="fas fa-list"></i> 추천 일정</h3>';
                    planContentHtml += '<div style="margin-bottom: 1.5rem;">';
                    for (var k = 0; k < planData.recommendations.length; k++) {
                        var rec = planData.recommendations[k];
                        planContentHtml += '<div style="background: white; border-left: 4px solid #667eea; padding: 1rem; margin-bottom: 0.5rem; border-radius: 0 8px 8px 0;">' +
                            '<strong>' + (rec.day || '추천') + '</strong><br>' +
                            '<span style="color: #667eea;">' + (rec.place || '') + '</span><br>' +
                            (rec.description || '') +
                        '</div>';
                    }
                    planContentHtml += '</div>';
                }
            } catch (e) {
                planContentHtml = 
                    '<div style="background: #f7fafc; padding: 1rem; border-radius: 8px; white-space: pre-line;">' +
                        (plan.planContent || '내용 없음') +
                    '</div>';
            }
            
            var tagsSection = '';
            if (plan.tags && plan.tags.length > 0) {
                tagsSection = '<div style="margin-bottom: 1.5rem;">' +
                    '<h4><i class="fas fa-tags"></i> 태그</h4>' +
                    '<div class="plan-tags">';
                for (var m = 0; m < plan.tags.length; m++) {
                    tagsSection += '<span class="plan-tag">#' + plan.tags[m] + '</span>';
                }
                tagsSection += '</div></div>';
            }
            
            modalContent.innerHTML = 
                '<div style="margin-bottom: 1.5rem;">' +
                    '<h4><i class="fas fa-map-marker-alt"></i> 목적지</h4>' +
                    '<p>' + (plan.destination || '미정') + '</p>' +
                '</div>' +
                '<div style="margin-bottom: 1.5rem;">' +
                    '<h4><i class="fas fa-calendar"></i> 여행 기간</h4>' +
                    '<p>' + (plan.duration || 3) + '일</p>' +
                '</div>' +
                tagsSection +
                planContentHtml +
                '<div style="margin-top: 2rem; text-align: right; color: #718096;">' +
                    '생성일: ' + formatDate(plan.createdDate) +
                '</div>';
            
            modalOverlay.style.display = 'block';
        }
        
        // 모달 닫기
        function closeModal() {
            document.getElementById('modalOverlay').style.display = 'none';
        }
        
        // 계획 수정 (향후 구현)
        function editPlan(planId) {
            alert('수정 기능은 향후 구현 예정입니다.');
        }
        
        // 계획 삭제
        function deletePlan(planId) {
            if (!confirm('이 여행 계획을 삭제하시겠습니까?')) {
                return;
            }
            
            fetch('/api/travel-plans/' + planId, {
                method: 'DELETE'
            })
            .then(function(response) { return response.json(); })
            .then(function(data) {
                if (data.success) {
                    alert('계획이 삭제되었습니다.');
                    loadAIPlans(); // 목록 새로고침
                } else {
                    throw new Error(data.message || '삭제 실패');
                }
            })
            .catch(function(error) {
                console.error('삭제 오류:', error);
                alert('삭제 중 오류가 발생했습니다: ' + error.message);
            });
        }
        
        // 모달 외부 클릭 시 닫기
        document.getElementById('modalOverlay').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });
    </script>
    
    <%@ include file="../common/footer.jsp" %>
</body>
</html>