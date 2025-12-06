<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>여행 계획 만들기 - AI 여행 동행 매칭 플랫폼</title>
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
                        <i class="fas fa-map-marked-alt me-3"></i>
                        새로운 여행 계획 만들기
                    </h1>
                    <p class="page-subtitle">
                        완벽한 여행을 위한 첫 걸음, 함께할 동행을 찾아 특별한 추억을 만들어보세요.
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
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <h2 class="form-title">여행 계획 등록</h2>
                                    <p class="form-subtitle">멋진 여행을 계획하고 함께할 동행을 찾아보세요</p>
                                </div>
                                <button type="button" class="btn btn-outline-primary" id="loadPlanBtn" onclick="showSavedPlans()">
                                    <i class="fas fa-download me-2"></i>계획 불러오기
                                </button>
                            </div>
                        </div>
                        
                        <div class="form-body">

                            <!-- Messages -->
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                                    <i class="fas fa-exclamation-triangle"></i> ${error}
                                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                                </div>
                            </c:if>

                            <form action="/travel/create" method="post" id="createForm" enctype="multipart/form-data">
                                <div class="form-group">
                                    <label for="planTitle" class="form-label required">
                                        <i class="fas fa-heading"></i>여행 제목
                                    </label>
                                    <input type="text" class="form-control" id="planTitle" name="planTitle" 
                                           required maxlength="255" 
                                           placeholder="예: 제주도 힐링 여행, 유럽 배낭여행">
                                    <div class="form-text">여행의 특징을 잘 나타내는 제목을 입력하세요</div>
                                </div>

                                <div class="form-group">
                                    <label for="planDestination" class="form-label required">
                                        <i class="fas fa-map-marker-alt"></i>여행 목적지
                                    </label>
                                    <input type="text" class="form-control" id="planDestination" name="planDestination" 
                                           required maxlength="255" 
                                           placeholder="예: 제주도, 파리, 도쿄">
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="planStartDate" class="form-label required">
                                                <i class="fas fa-calendar-alt"></i>여행 시작일
                                            </label>
                                            <input type="date" class="form-control" id="planStartDate" name="planStartDate" 
                                                   required>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="planEndDate" class="form-label required">
                                                <i class="fas fa-calendar-check"></i>여행 종료일
                                            </label>
                                            <input type="date" class="form-control" id="planEndDate" name="planEndDate" 
                                                   required>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="planBudget" class="form-label">
                                                <i class="fas fa-won-sign"></i>예상 예산 (선택사항)
                                            </label>
                                            <div class="input-group">
                                                <input type="text" class="form-control" id="planBudgetDisplay" 
                                                       placeholder="예: 1,000,000" 
                                                       onkeyup="formatBudgetInput(this)" 
                                                       onblur="validateBudget(this)">
                                                <span class="input-group-text">원</span>
                                            </div>
                                            <div class="form-text">1인 기준 총 예산을 입력하세요 (최대 천만원 미만)</div>
                                            <input type="hidden" id="planBudget" name="planBudget" value="">
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="maxParticipants" class="form-label required">
                                                <i class="fas fa-users"></i>최대 참여 인원
                                            </label>
                                            <select class="form-control" id="maxParticipants" name="maxParticipants" required>
                                                <option value="">인원을 선택하세요</option>
                                                <option value="2">2명</option>
                                                <option value="3">3명</option>
                                                <option value="4">4명</option>
                                                <option value="5">5명</option>
                                                <option value="6" selected>6명</option>
                                                <option value="7">7명</option>
                                                <option value="8">8명</option>
                                                <option value="9">9명</option>
                                                <option value="10">10명</option>
                                            </select>
                                            <div class="form-text">여행에 참여할 수 있는 최대 인원수를 선택하세요</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="planImage" class="form-label">
                                        <i class="fas fa-image"></i>여행 대표 이미지
                                    </label>
                                    <input type="file" class="form-control" id="planImage" name="planImage" 
                                           accept="image/*" onchange="previewTravelImage(this)">
                                    <div class="form-text">여행지를 대표하는 이미지를 선택하세요 (선택사항, 최대 10MB)</div>
                                    <div id="travelImagePreview" class="mt-3" style="display: none;">
                                        <img id="previewTravelImg" src="" alt="미리보기" style="max-width: 300px; max-height: 200px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">
                                        <div class="mt-2">
                                            <button type="button" class="btn btn-sm btn-outline-danger" onclick="removeTravelImage()">
                                                <i class="fas fa-times"></i> 이미지 제거
                                            </button>
                                        </div>
                                    </div>
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
                                            <input type="checkbox" class="btn-check" id="create-tag-힐링여행" name="planTags" value="힐링여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-힐링여행">#힐링여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-감성여행" name="planTags" value="감성여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-감성여행">#감성여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-식도락여행" name="planTags" value="식도락여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-식도락여행">#식도락여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-액티비티" name="planTags" value="액티비티" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-액티비티">#액티비티</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-뚜벅이여행" name="planTags" value="뚜벅이여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-뚜벅이여행">#뚜벅이여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-캠핑" name="planTags" value="캠핑" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-캠핑">#캠핑</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-호캉스" name="planTags" value="호캉스" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-호캉스">#호캉스</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-커플여행" name="planTags" value="커플여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-커플여행">#커플여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-우정여행" name="planTags" value="우정여행" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-우정여행">#우정여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-반려동물동반" name="planTags" value="반려동물동반" autocomplete="off">
                                            <label class="btn btn-outline-success btn-sm" for="create-tag-반려동물동반">#반려동물동반</label>
                                        </div>
                                        
                                        <h6 class="fw-bold mb-2 text-primary">📍 여행지 & 지역</h6>
                                        <div class="d-flex flex-wrap gap-2 mb-3">
                                            <input type="checkbox" class="btn-check" id="create-tag-국내여행" name="planTags" value="국내여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="create-tag-국내여행">#국내여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-해외여행" name="planTags" value="해외여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="create-tag-해외여행">#해외여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-일본여행" name="planTags" value="일본여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="create-tag-일본여행">#일본여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-유럽여행" name="planTags" value="유럽여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="create-tag-유럽여행">#유럽여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-동남아여행" name="planTags" value="동남아여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="create-tag-동남아여행">#동남아여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-미주여행" name="planTags" value="미주여행" autocomplete="off">
                                            <label class="btn btn-outline-primary btn-sm" for="create-tag-미주여행">#미주여행</label>
                                        </div>
                                        
                                        <h6 class="fw-bold mb-2 text-warning">🗓️ 기간 & 시기</h6>
                                        <div class="d-flex flex-wrap gap-2 mb-3">
                                            <input type="checkbox" class="btn-check" id="create-tag-당일치기" name="planTags" value="당일치기" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-당일치기">#당일치기</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-1박2일" name="planTags" value="1박2일" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-1박2일">#1박2일</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-2박3일" name="planTags" value="2박3일" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-2박3일">#2박3일</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-장기여행" name="planTags" value="장기여행" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-장기여행">#장기여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-여름휴가" name="planTags" value="여름휴가" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-여름휴가">#여름휴가</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-겨울여행" name="planTags" value="겨울여행" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-겨울여행">#겨울여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-봄꽃여행" name="planTags" value="봄꽃여행" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-봄꽃여행">#봄꽃여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-가을단풍" name="planTags" value="가을단풍" autocomplete="off">
                                            <label class="btn btn-outline-warning btn-sm" for="create-tag-가을단풍">#가을단풍</label>
                                        </div>
                                        
                                        <h6 class="fw-bold mb-2 text-info">👍 기타 & 추천</h6>
                                        <div class="d-flex flex-wrap gap-2 mb-3">
                                            <input type="checkbox" class="btn-check" id="create-tag-인생샷" name="planTags" value="인생샷" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="create-tag-인생샷">#인생샷</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-숨은명소" name="planTags" value="숨은명소" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="create-tag-숨은명소">#숨은명소</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-맛집추천" name="planTags" value="맛집추천" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="create-tag-맛집추천">#맛집추천</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-카페투어" name="planTags" value="카페투어" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="create-tag-카페투어">#카페투어</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-가성비여행" name="planTags" value="가성비여행" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="create-tag-가성비여행">#가성비여행</label>
                                            
                                            <input type="checkbox" class="btn-check" id="create-tag-여행꿀팁" name="planTags" value="여행꿀팁" autocomplete="off">
                                            <label class="btn btn-outline-info btn-sm" for="create-tag-여행꿀팁">#여행꿀팁</label>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group">
                                    <label for="planContent" class="form-label">
                                        <i class="fas fa-file-alt"></i>여행 계획 상세 내용
                                    </label>
                                    <textarea class="form-control" id="planContent" name="planContent" 
                                              maxlength="3000"
                                              placeholder="여행 일정, 가고 싶은 곳, 하고 싶은 활동, 찾는 동행 스타일 등을 자유롭게 작성해주세요."></textarea>
                                    <div class="form-text">
                                        <span id="charCount">0</span> / 3000자
                                    </div>
                                </div>

                                <div class="form-group">
                                    <button type="submit" class="primary-button" id="submitBtn">
                                        <i class="fas fa-save me-2"></i>여행 계획 등록
                                    </button>
                                    <a href="${pageContext.request.contextPath}/travel/list" class="secondary-button">
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

    <!-- 저장된 계획 선택 모달 -->
    <div class="modal fade" id="savedPlansModal" tabindex="-1" aria-labelledby="savedPlansModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="savedPlansModalLabel">
                        <i class="fas fa-folder-open me-2"></i>저장된 계획 불러오기
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="savedPlansLoading" class="text-center py-4">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-3 text-muted">저장된 계획을 불러오는 중...</p>
                    </div>
                    <div id="savedPlansContent" style="display: none;">
                        <div id="savedPlansList"></div>
                    </div>
                    <div id="savedPlansEmpty" style="display: none;" class="text-center py-5">
                        <i class="fas fa-folder-open fa-3x text-muted mb-3"></i>
                        <p class="text-muted">저장된 계획이 없습니다.</p>
                        <p class="small text-muted">AI 플래너에서 계획을 저장해보세요!</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
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
        document.getElementById('createForm').addEventListener('submit', function(e) {
            const startDate = document.getElementById('planStartDate').value;
            const endDate = document.getElementById('planEndDate').value;
            
            if (endDate < startDate) {
                e.preventDefault();
                alert('여행 종료일은 시작일 이후여야 합니다.');
                return false;
            }

            // 오늘 이전 날짜 체크
            const today = new Date().toISOString().split('T')[0];
            if (startDate < today) {
                e.preventDefault();
                alert('여행 시작일은 오늘 이후여야 합니다.');
                return false;
            }
        });

        // 오늘 날짜로 최소값 설정 및 AI 추천 데이터 자동 입력
        window.onload = function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('planStartDate').min = today;
            document.getElementById('planEndDate').min = today;
            
            // AI 추천 데이터가 있으면 자동으로 폼에 입력
            <c:if test="${not empty aiRecommendation}">
                fillFormWithAIRecommendation();
            </c:if>
        };
        
        // AI 추천 데이터로 폼 자동 입력 함수
        function fillFormWithAIRecommendation() {
            <c:if test="${not empty aiRecommendation}">
                console.log('=== AI 추천 데이터 자동 입력 시작 ===');
                
                const aiData = {
                    region: '<c:out value="${aiRecommendation.region}" escapeXml="true"/>',
                    period: '<c:out value="${aiRecommendation.period}" escapeXml="true"/>',
                    count: '<c:out value="${aiRecommendation.count}" escapeXml="true"/>',
                    budget: '<c:out value="${aiRecommendation.budget}" escapeXml="true"/>',
                    content: `<c:out value="${aiRecommendation.content}" escapeXml="false"/>`.replace(/\r\n/g, '\n').replace(/\r/g, '\n')
                };
                
                console.log('AI 추천 데이터:', aiData);
                
                // 1. 여행 제목 - AI 추천 지역을 포함한 제목 생성
                if (aiData.region && aiData.period) {
                    const title = aiData.region + " " + aiData.period + "일 여행";
                    document.getElementById('planTitle').value = title;
                    console.log('제목 설정:', title);
                }
                
                // 2. 여행 목적지 - AI 추천 지역
                if (aiData.region) {
                    document.getElementById('planDestination').value = aiData.region;
                    console.log('목적지 설정:', aiData.region);
                }
                
                // 3. 여행 기간 설정 (시작일은 오늘, 종료일은 시작일 + 기간)
                if (aiData.period) {
                    const today = new Date();
                    const startDate = new Date(today);
                    startDate.setDate(today.getDate() + 1); // 내일부터 시작
                    
                    const endDate = new Date(startDate);
                    endDate.setDate(startDate.getDate() + parseInt(aiData.period) - 1);
                    
                    const startDateStr = formatDateForInput(startDate);
                    const endDateStr = formatDateForInput(endDate);
                    
                    if (startDateStr && endDateStr) {
                        document.getElementById('planStartDate').value = startDateStr;
                        document.getElementById('planEndDate').value = endDateStr;
                        console.log('여행 기간 설정:', startDateStr, '~', endDateStr);
                    }
                }
                
                // 4. 최대 참여 인원 - AI에서 제공한 인원수
                if (aiData.count) {
                    const maxParticipantsSelect = document.getElementById('maxParticipants');
                    const count = parseInt(aiData.count);
                    if (count >= 2 && count <= 10) {
                        maxParticipantsSelect.value = count.toString();
                        console.log('최대 참여 인원 설정:', count);
                    }
                }
                
                // 5. 예산 정보 - AI에서 제공한 예산
                if (aiData.budget) {
                    const budget = parseInt(aiData.budget);
                    if (budget > 0 && budget < 10000000) {
                        document.getElementById('planBudget').value = budget;
                        document.getElementById('planBudgetDisplay').value = budget.toLocaleString('ko-KR');
                        console.log('예산 설정:', budget);
                    }
                }
                
                // 6. 여행 계획 상세 내용 - AI 추천 내용
                if (aiData.content) {
                    document.getElementById('planContent').value = aiData.content;
                    // 문자 수 업데이트
                    document.getElementById('charCount').textContent = aiData.content.length;
                    console.log('상세 내용 설정 완료, 글자 수:', aiData.content.length);
                }
                
                // 7. 관련 태그 자동 선택
                autoSelectTagsBasedOnAI(aiData);
                
                console.log('=== AI 추천 데이터 자동 입력 완료 ===');
                
                // 팝업 알림 제거됨
            </c:if>
        }
        
        // AI 데이터를 기반으로 적절한 태그 자동 선택
        function autoSelectTagsBasedOnAI(aiData) {
            console.log('=== 태그 자동 선택 시작 ===');
            
            const region = aiData.region ? aiData.region.toLowerCase() : '';
            const period = parseInt(aiData.period) || 0;
            const content = aiData.content ? aiData.content.toLowerCase() : '';
            
            // 지역 기반 태그 선택
            if (region.includes('제주') || region.includes('jeju')) {
                selectTag('국내여행');
                selectTag('힐링여행');
            } else if (region.includes('서울') || region.includes('경기') || region.includes('인천')) {
                selectTag('국내여행');
                selectTag('당일치기');
            } else if (region.includes('부산') || region.includes('강릉') || region.includes('속초')) {
                selectTag('국내여행');
                selectTag('힐링여행');
            } else if (region.includes('일본') || region.includes('도쿄') || region.includes('오사카')) {
                selectTag('해외여행');
                selectTag('일본여행');
            } else if (region.includes('유럽') || region.includes('파리') || region.includes('런던')) {
                selectTag('해외여행');
                selectTag('유럽여행');
            } else if (region.includes('태국') || region.includes('베트남') || region.includes('필리핀')) {
                selectTag('해외여행');
                selectTag('동남아여행');
            } else {
                selectTag('국내여행'); // 기본값
            }
            
            // 기간 기반 태그 선택
            if (period === 1) {
                selectTag('당일치기');
            } else if (period === 2) {
                selectTag('1박2일');
            } else if (period === 3) {
                selectTag('2박3일');
            } else if (period > 3) {
                selectTag('장기여행');
            }
            
            // 내용 기반 태그 선택
            if (content.includes('맛집') || content.includes('음식') || content.includes('먹거리')) {
                selectTag('식도락여행');
                selectTag('맛집추천');
            }
            if (content.includes('힐링') || content.includes('휴식') || content.includes('여유')) {
                selectTag('힐링여행');
            }
            if (content.includes('액티비티') || content.includes('체험') || content.includes('활동')) {
                selectTag('액티비티');
            }
            if (content.includes('사진') || content.includes('인생샷') || content.includes('포토')) {
                selectTag('인생샷');
            }
            if (content.includes('카페') || content.includes('커피')) {
                selectTag('카페투어');
            }
            if (content.includes('캠핑') || content.includes('글램핑')) {
                selectTag('캠핑');
            }
            
            console.log('=== 태그 자동 선택 완료 ===');
        }
        
        // 태그 선택 헬퍼 함수
        function selectTag(tagValue) {
            const checkbox = document.querySelector(`input[value="${tagValue}"]`);
            if (checkbox) {
                checkbox.checked = true;
                console.log('태그 선택됨:', tagValue);
            }
        }

        // 여행 이미지 미리보기 함수
        function previewTravelImage(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById('previewTravelImg').src = e.target.result;
                    document.getElementById('travelImagePreview').style.display = 'block';
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        // 여행 이미지 제거 함수
        function removeTravelImage() {
            document.getElementById('planImage').value = '';
            document.getElementById('travelImagePreview').style.display = 'none';
            document.getElementById('previewTravelImg').src = '';
        }
        
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

        // 저장된 계획 보기 함수
        function showSavedPlans() {
            const modal = new bootstrap.Modal(document.getElementById('savedPlansModal'));
            
            // 로딩 상태로 설정
            document.getElementById('savedPlansLoading').style.display = 'block';
            document.getElementById('savedPlansContent').style.display = 'none';
            document.getElementById('savedPlansEmpty').style.display = 'none';
            
            modal.show();
            
            // 저장된 계획 조회 (AI 플래너에서 저장한 계획만)
            fetch('/api/travel-plans/my-plans')
            .then(response => {
                if (!response.ok) {
                    if (response.status === 401) {
                        throw new Error('LOGIN_REQUIRED');
                    }
                    throw new Error('HTTP ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                displaySavedPlansList(data);
            })
            .catch(error => {
                console.error('저장된 계획 조회 중 오류:', error);
                document.getElementById('savedPlansLoading').style.display = 'none';
                
                if (error.message === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    window.location.href = '/member/login?returnUrl=/travel/create';
                } else {
                    alert('저장된 계획을 불러오는 중 오류가 발생했습니다: ' + error.message);
                    modal.hide();
                }
            });
        }

        // 저장된 계획 목록 표시
        function displaySavedPlansList(plans) {
            document.getElementById('savedPlansLoading').style.display = 'none';
            
            if (!plans || plans.length === 0) {
                document.getElementById('savedPlansEmpty').style.display = 'block';
                return;
            }
            
            let plansHtml = '';
            plans.forEach(plan => {
                plansHtml += '<div class="card mb-3 saved-plan-card" style="cursor: pointer; transition: all 0.3s ease;" ' +
                           'onclick="selectPlan(' + plan.planId + ', \'' + plan.planType + '\')" ' +
                           'onmouseover="this.style.boxShadow=\'0 4px 15px rgba(0,0,0,0.1)\'" ' +
                           'onmouseout="this.style.boxShadow=\'\'"><div class="card-body">' +
                           '<h5 class="card-title text-primary">' + (plan.title || '제목 없음') + 
                           '<span class="badge ms-2 ' + (plan.planType === 'AI_PLANNER' ? 'bg-info' : 'bg-secondary') + '">' + 
                           (plan.planType === 'AI_PLANNER' ? 'AI 플래너' : '일반 계획') + '</span></h5>' +
                           '<div class="row"><div class="col-md-6">' +
                           '<p class="card-text mb-1"><i class="fas fa-map-marker-alt text-danger me-2"></i><strong>목적지:</strong> ' + (plan.destination || '미정') + '</p>' +
                           '<p class="card-text mb-1"><i class="fas fa-calendar text-info me-2"></i><strong>기간:</strong> ' + (plan.duration || '미정') + '일</p>' +
                           '</div><div class="col-md-6">';
                
                if (plan.budget && plan.budget > 0) {
                    plansHtml += '<p class="card-text mb-1"><i class="fas fa-won-sign text-success me-2"></i><strong>예산:</strong> ' + 
                               plan.budget.toLocaleString('ko-KR') + '원</p>';
                }
                
                plansHtml += '<p class="card-text mb-0"><i class="fas fa-clock text-secondary me-2"></i><strong>저장일:</strong> ' + 
                           formatDate(plan.createdAt) + '</p>' +
                           '</div></div>' +
                           '<div class="mt-2"><button type="button" class="btn btn-primary btn-sm" onclick="event.stopPropagation(); selectPlan(' + plan.planId + ', \'' + plan.planType + '\')">' +
                           '<i class="fas fa-check me-1"></i>이 계획 선택</button></div>' +
                           '</div></div>';
            });
            
            document.getElementById('savedPlansList').innerHTML = plansHtml;
            document.getElementById('savedPlansContent').style.display = 'block';
        }

        // 계획 선택 함수
        function selectPlan(planId, planType) {
            // 계획 상세 정보 조회 (통합 API 사용)
            fetch('/api/travel-plans/detail/' + planId + '?planType=' + planType)
            .then(response => {
                if (!response.ok) {
                    if (response.status === 401) {
                        throw new Error('LOGIN_REQUIRED');
                    }
                    throw new Error('HTTP ' + response.status);
                }
                return response.json();
            })
            .then(plan => {
                fillFormWithPlan(plan, planType);
                // 모달 닫기
                const modal = bootstrap.Modal.getInstance(document.getElementById('savedPlansModal'));
                modal.hide();
            })
            .catch(error => {
                console.error('계획 상세 조회 중 오류:', error);
                if (error.message === 'LOGIN_REQUIRED') {
                    alert('로그인이 필요한 서비스입니다.');
                    window.location.href = '/member/login?returnUrl=/travel/create';
                } else {
                    alert('계획을 불러오는 중 오류가 발생했습니다: ' + error.message);
                }
            });
        }

        // 폼에 계획 데이터 채우기 - 모든 필드 자동 입력
        function fillFormWithPlan(plan, planType) {
            console.log('=== Loading plan data ===');
            console.log('Plan object:', plan);
            console.log('Plan type:', planType);
            
            // AI 플래너와 일반 계획의 필드명이 다르므로 구분 처리
            let title, destination, startDate, endDate, budget, content, maxParticipants, tags;
            
            if (planType === 'AI_PLANNER') {
                // AI 플래너 데이터 구조
                title = plan.title;
                destination = plan.destination;
                startDate = plan.startDate;
                endDate = plan.endDate;
                budget = plan.budget;
                content = plan.planContent;
                maxParticipants = plan.maxParticipants;
                tags = plan.tags;
                
                console.log('AI Planner data extracted:');
                console.log('- startDate:', startDate);
                console.log('- endDate:', endDate);
            } else if (planType === 'REGULAR') {
                // 일반 여행 계획 데이터 구조
                title = plan.planTitle;
                destination = plan.planDestination;
                startDate = plan.planStartDate;
                endDate = plan.planEndDate;
                budget = plan.planBudget;
                content = plan.planContent;
                maxParticipants = plan.maxParticipants;
                tags = plan.planTags ? plan.planTags.split(',').map(tag => tag.trim()) : [];
            }
            
            // 1. 여행 제목
            if (title) {
                document.getElementById('planTitle').value = title;
            }
            
            // 2. 여행 목적지
            if (destination) {
                document.getElementById('planDestination').value = destination;
            }
            
            // 3. 여행 시작일 (날짜 포맷 변환)
            console.log('Processing start date:', startDate);
            if (startDate) {
                const startDateFormatted = formatDateForInput(startDate);
                console.log('Start date formatted:', startDateFormatted);
                if (startDateFormatted) {
                    const startDateElement = document.getElementById('planStartDate');
                    if (startDateElement) {
                        startDateElement.value = startDateFormatted;
                        console.log('Start date set to:', startDateElement.value);
                    }
                }
            }
            
            // 4. 여행 종료일 (날짜 포맷 변환)
            console.log('Processing end date:', endDate);
            if (endDate) {
                const endDateFormatted = formatDateForInput(endDate);
                console.log('End date formatted:', endDateFormatted);
                if (endDateFormatted) {
                    const endDateElement = document.getElementById('planEndDate');
                    if (endDateElement) {
                        endDateElement.value = endDateFormatted;
                        console.log('End date set to:', endDateElement.value);
                    }
                }
            }
            
            // 5. 예상 예산
            if (budget && budget > 0) {
                document.getElementById('planBudget').value = budget;
                document.getElementById('planBudgetDisplay').value = Number(budget).toLocaleString('ko-KR');
            }
            
            // 6. 최대 참여 인원
            const maxParticipantsSelect = document.getElementById('maxParticipants');
            if (maxParticipants && maxParticipants > 0) {
                maxParticipantsSelect.value = maxParticipants;
            } else {
                // 기본값 4명 설정
                maxParticipantsSelect.value = '4';
            }
            
            // 7. 여행 계획 상세 내용
            if (content) {
                document.getElementById('planContent').value = content;
                // 문자 수 업데이트
                document.getElementById('charCount').textContent = content.length;
            }
            
            // 8. 여행 스타일 태그 자동 선택
            if (tags && tags.length > 0) {
                tags.forEach(tag => {
                    const checkbox = document.querySelector(`input[value="${tag}"]`);
                    if (checkbox) {
                        checkbox.checked = true;
                    }
                });
            }
            
            console.log('Plan data loaded successfully');
            alert('계획이 성공적으로 불러와졌습니다!');
        }
        
        // 날짜를 input[type=date] 형식으로 변환하는 함수 (개선된 버전)
        function formatDateForInput(dateString) {
            console.log('Format date input received:', dateString, 'Type:', typeof dateString);
            
            if (!dateString) return null;
            
            try {
                let date;
                
                // 이미 YYYY-MM-DD 형식인 경우
                if (typeof dateString === 'string' && dateString.match(/^\d{4}-\d{2}-\d{2}$/)) {
                    console.log('Date is already in YYYY-MM-DD format:', dateString);
                    return dateString;
                }
                
                // 날짜 객체 생성
                if (typeof dateString === 'string') {
                    // 다양한 형식 처리
                    if (dateString.includes('T')) {
                        // ISO 형식 (2024-01-01T00:00:00.000Z)
                        date = new Date(dateString);
                    } else if (dateString.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/)) {
                        // MySQL datetime 형식 (2024-01-01 00:00:00)
                        date = new Date(dateString.replace(' ', 'T'));
                    } else {
                        date = new Date(dateString);
                    }
                } else {
                    date = new Date(dateString);
                }
                
                if (isNaN(date.getTime())) {
                    console.error('Invalid date:', dateString);
                    return null;
                }
                
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0');
                const day = String(date.getDate()).padStart(2, '0');
                const formatted = `${year}-${month}-${day}`;
                
                console.log('Date formatted from', dateString, 'to', formatted);
                return formatted;
                
            } catch (e) {
                console.error('Date formatting error:', e, 'Input:', dateString);
                return null;
            }
        }

        // 날짜 포맷 함수
        function formatDate(dateString) {
            if (!dateString) return '미정';
            const date = new Date(dateString);
            return date.getFullYear() + '.' + 
                   String(date.getMonth() + 1).padStart(2, '0') + '.' + 
                   String(date.getDate()).padStart(2, '0');
        }
    </script>
</body>
</html>