<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>여행 계획 수정 - AI 여행 동행 매칭 플랫폼</title>
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
            min-height: 180px;
            resize: vertical;
            line-height: 1.7;
        }

        .input-group-text {
            background: linear-gradient(135deg, #ff6b6b, #ff8e53);
            color: white;
            border: 2px solid transparent;
            border-radius: 0 20px 20px 0;
            font-weight: 600;
            padding: 1rem 1.5rem;
        }

        .form-text {
            font-size: 0.875rem;
            color: #718096;
            margin-top: 0.5rem;
            font-weight: 500;
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
                        <i class="fas fa-edit me-3"></i>
                        여행 계획 수정하기
                    </h1>
                    <p class="page-subtitle">
                        더 나은 여행을 위해 계획을 업데이트하세요.
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
                                <i class="fas fa-route"></i>
                            </div>
                            <h2 class="form-title">여행 계획 수정</h2>
                            <p class="form-subtitle">여행 정보를 수정하고 더 많은 동행을 찾아보세요</p>
                        </div>
                        
                        <div class="form-body">

                            <!-- Messages -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="fas fa-exclamation-triangle"></i> ${error}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                </div>
                            </c:if>

                            <form action="/travel/edit/${travelPlan.planId}" method="post" id="editForm">
                                <div class="form-group">
                                    <label for="planTitle" class="form-label required">
                                        <i class="fas fa-heading"></i>여행 제목
                                    </label>
                                    <input type="text" class="form-control" id="planTitle" name="planTitle" 
                                           required maxlength="255" value="${travelPlan.planTitle}"
                                           placeholder="예: 제주도 힐링 여행, 유럽 배낭여행">
                                    <div class="form-text">여행의 특징을 잘 나타내는 제목을 입력하세요</div>
                                </div>

                                <div class="form-group">
                                    <label for="planDestination" class="form-label required">
                                        <i class="fas fa-map-marker-alt"></i>여행 목적지
                                    </label>
                                    <input type="text" class="form-control" id="planDestination" name="planDestination" 
                                           required maxlength="255" value="${travelPlan.planDestination}"
                                           placeholder="예: 제주도, 파리, 도쿄">
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="planStartDate" class="form-label required">
                                                <i class="fas fa-calendar-alt"></i>여행 시작일
                                            </label>
                                            <input type="date" class="form-control" id="planStartDate" name="planStartDate" 
                                                   required value="<fmt:formatDate value='${travelPlan.planStartDate}' pattern='yyyy-MM-dd'/>">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="planEndDate" class="form-label required">
                                                <i class="fas fa-calendar-check"></i>여행 종료일
                                            </label>
                                            <input type="date" class="form-control" id="planEndDate" name="planEndDate" 
                                                   required value="<fmt:formatDate value='${travelPlan.planEndDate}' pattern='yyyy-MM-dd'/>">
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="planBudget" class="form-label">
                                        <i class="fas fa-won-sign"></i>예상 예산 (선택사항)
                                    </label>
                                    <div class="input-group">
                                        <input type="text" class="form-control" id="planBudgetDisplay" 
                                               value="<c:if test='${travelPlan.planBudget > 0}'>${travelPlan.planBudget}</c:if>"
                                               placeholder="예: 1,000,000" 
                                               onkeyup="formatBudgetInput(this)" 
                                               onblur="validateBudget(this)">
                                        <span class="input-group-text">원</span>
                                    </div>
                                    <div class="form-text">1인 기준 총 예산을 입력하세요 (최대 천만원 미만)</div>
                                    <input type="hidden" id="planBudget" name="planBudget" value="${travelPlan.planBudget > 0 ? travelPlan.planBudget : ''}">
                                </div>

                                <div class="form-group">
                                    <label for="maxParticipants" class="form-label required">
                                        <i class="fas fa-users"></i>최대 참여 인원
                                    </label>
                                    <select class="form-control" id="maxParticipants" name="maxParticipants" required>
                                        <option value="2" ${travelPlan.maxParticipants == 2 ? 'selected' : ''}>2명</option>
                                        <option value="3" ${travelPlan.maxParticipants == 3 ? 'selected' : ''}>3명</option>
                                        <option value="4" ${travelPlan.maxParticipants == 4 ? 'selected' : ''}>4명</option>
                                        <option value="5" ${travelPlan.maxParticipants == 5 ? 'selected' : ''}>5명</option>
                                        <option value="6" ${travelPlan.maxParticipants == 6 || travelPlan.maxParticipants == 0 ? 'selected' : ''}>6명</option>
                                        <option value="7" ${travelPlan.maxParticipants == 7 ? 'selected' : ''}>7명</option>
                                        <option value="8" ${travelPlan.maxParticipants == 8 ? 'selected' : ''}>8명</option>
                                        <option value="9" ${travelPlan.maxParticipants == 9 ? 'selected' : ''}>9명</option>
                                        <option value="10" ${travelPlan.maxParticipants == 10 ? 'selected' : ''}>10명</option>
                                    </select>
                                    <div class="form-text">본인 포함 최대 참여 인원을 선택하세요</div>
                                </div>

                                <!-- 여행 태그 선택 -->
                                <div class="form-group">
                                    <label class="form-label">
                                        <i class="fas fa-tags"></i>여행 스타일 & 테마 (선택사항)
                                    </label>
                                    <div class="form-text mb-3">여행의 특징을 나타내는 태그를 선택하세요. 검색 시 다른 사용자가 쉽게 찾을 수 있습니다.</div>
                                    
                                    <div class="tags-section">
                                        <h6 class="fw-bold mb-2 text-success">🗺️ 여행 스타일 & 테마</h6>
                                        <div class="d-flex flex-wrap gap-2 mb-3">
                                            <input type="checkbox" class="btn-check" id="edit-tag-힐링여행" name="planTags" value="힐링여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-힐링여행">#힐링여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-감성여행" name="planTags" value="감성여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-감성여행">#감성여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-식도락여행" name="planTags" value="식도락여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-식도락여행">#식도락여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-액티비티" name="planTags" value="액티비티" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-액티비티">#액티비티</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-뚜벅이여행" name="planTags" value="뚜벅이여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-뚜벅이여행">#뚜벅이여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-캠핑" name="planTags" value="캠핑" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-캠핑">#캠핑</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-호캉스" name="planTags" value="호캉스" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-호캉스">#호캉스</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-커플여행" name="planTags" value="커플여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-커플여행">#커플여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-우정여행" name="planTags" value="우정여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-우정여행">#우정여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-반려동물동반" name="planTags" value="반려동물동반" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="edit-tag-반려동물동반">#반려동물동반</label>
                                        </div>
                                        
                                        <h6 class="fw-bold mb-2 text-primary">📍 여행지 & 지역</h6>
                                        <div class="d-flex flex-wrap gap-2 mb-3">
                                            <input type="checkbox" class="btn-check" id="edit-tag-국내여행" name="planTags" value="국내여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="edit-tag-국내여행">#국내여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-해외여행" name="planTags" value="해외여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="edit-tag-해외여행">#해외여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-일본여행" name="planTags" value="일본여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="edit-tag-일본여행">#일본여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-유럽여행" name="planTags" value="유럽여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="edit-tag-유럽여행">#유럽여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-동남아여행" name="planTags" value="동남아여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="edit-tag-동남아여행">#동남아여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-미주여행" name="planTags" value="미주여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="edit-tag-미주여행">#미주여행</label>
                                        </div>
                                        
                                        <h6 class="fw-bold mb-2 text-warning">🗓️ 기간 & 시기</h6>
                                        <div class="d-flex flex-wrap gap-2 mb-3">
                                            <input type="checkbox" class="btn-check" id="edit-tag-당일치기" name="planTags" value="당일치기" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-당일치기">#당일치기</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-1박2일" name="planTags" value="1박2일" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-1박2일">#1박2일</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-2박3일" name="planTags" value="2박3일" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-2박3일">#2박3일</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-장기여행" name="planTags" value="장기여행" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-장기여행">#장기여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-여름휴가" name="planTags" value="여름휴가" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-여름휴가">#여름휴가</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-겨울여행" name="planTags" value="겨울여행" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-겨울여행">#겨울여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-봄꽃여행" name="planTags" value="봄꽃여행" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-봄꽃여행">#봄꽃여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-가을단풍" name="planTags" value="가을단풍" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="edit-tag-가을단풍">#가을단풍</label>
                                        </div>
                                        
                                        <h6 class="fw-bold mb-2 text-info">👍 기타 & 추천</h6>
                                        <div class="d-flex flex-wrap gap-2 mb-3">
                                            <input type="checkbox" class="btn-check" id="edit-tag-인생샷" name="planTags" value="인생샷" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="edit-tag-인생샷">#인생샷</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-숨은명소" name="planTags" value="숨은명소" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="edit-tag-숨은명소">#숨은명소</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-맛집추천" name="planTags" value="맛집추천" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="edit-tag-맛집추천">#맛집추천</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-카페투어" name="planTags" value="카페투어" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="edit-tag-카페투어">#카페투어</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-가성비여행" name="planTags" value="가성비여행" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="edit-tag-가성비여행">#가성비여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="edit-tag-여행꿀팁" name="planTags" value="여행꿀팁" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="edit-tag-여행꿀팁">#여행꿀팁</label>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="planContent" class="form-label">
                                        <i class="fas fa-file-alt"></i>여행 계획 상세 내용
                                    </label>
                                    <textarea class="form-control" id="planContent" name="planContent" 
                                              maxlength="3000"
                                              placeholder="여행 일정, 가고 싶은 곳, 하고 싶은 활동, 찾는 동행 스타일 등을 자유롭게 작성해주세요.">${travelPlan.planContent}</textarea>
                                    <div class="form-text">
                                        <span id="charCount">${not empty travelPlan.planContent ? travelPlan.planContent.length() : 0}</span> / 3000자
                                    </div>
                                </div>

                                <div class="form-group">
                                    <button type="submit" class="primary-button" id="submitBtn">
                                        <i class="fas fa-save me-2"></i>여행 계획 수정
                                    </button>
                                    <a href="${pageContext.request.contextPath}/travel/detail/${travelPlan.planId}" class="secondary-button">
                                        <i class="fas fa-arrow-left me-2"></i>취소하기
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
        // 기존 태그 선택 상태 복원
        document.addEventListener('DOMContentLoaded', function() {
            const existingTags = '${travelPlan.planTags}';
            if (existingTags) {
                const tagArray = existingTags.split(',');
                tagArray.forEach(function(tag) {
                    const checkbox = document.getElementById('edit-tag-' + tag.trim());
                    if (checkbox) {
                        checkbox.checked = true;
                    }
                });
            }
        });

        // 날짜 유효성 검사
        document.getElementById('planStartDate').addEventListener('change', function() {
            const startDate = this.value;
            const endDateInput = document.getElementById('planEndDate');
            
            // 종료일은 시작일 이후여야 함
            endDateInput.min = startDate;
            
            // 종료일이 시작일보다 이전이면 초기화
            if (endDateInput.value && endDateInput.value < startDate) {
                endDateInput.value = startDate;
            }
        });

        // 문자 수 카운트
        document.getElementById('planContent').addEventListener('input', function() {
            const charCount = this.value.length;
            document.getElementById('charCount').textContent = charCount;
        });

        // 폼 제출 시 유효성 검사
        document.getElementById('editForm').addEventListener('submit', function(e) {
            const startDate = document.getElementById('planStartDate').value;
            const endDate = document.getElementById('planEndDate').value;
            
            if (endDate < startDate) {
                e.preventDefault();
                alert('여행 종료일은 시작일 이후여야 합니다.');
                return false;
            }
        });

        // 오늘 날짜로 최소값 설정
        window.onload = function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('planStartDate').min = today;
            document.getElementById('planEndDate').min = today;
            
            // 기존 예산 값 포맷팅
            const budgetInput = document.getElementById('planBudgetDisplay');
            if (budgetInput.value) {
                formatBudgetInput(budgetInput);
            }
        };
        
        // 예산 입력 포맷팅 함수
        function formatBudgetInput(input) {
            let value = input.value.replace(/[^0-9]/g, ''); // 숫자만 추출
            
            if (value === '') {
                input.value = '';
                document.getElementById('planBudget').value = '';
                return;
            }
            
            // 천만원(10,000,000) 미만으로 제한
            let numValue = parseInt(value);
            if (numValue >= 10000000) {
                numValue = 9999999;
                value = numValue.toString();
                input.style.borderColor = '#dc3545';
                setTimeout(() => {
                    input.style.borderColor = '';
                }, 2000);
            }
            
            // 콤마 추가
            let formattedValue = value.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            input.value = formattedValue;
            document.getElementById('planBudget').value = value; // 실제 숫자값 저장
        }
        
        // 예산 유효성 검사
        function validateBudget(input) {
            let value = input.value.replace(/[^0-9]/g, '');
            
            if (value === '') return;
            
            let numValue = parseInt(value);
            if (numValue >= 10000000) {
                alert('예산은 천만원 미만으로 입력해주세요.');
                input.focus();
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>