<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="contextPath" content="${pageContext.request.contextPath}">
    <title>시도별 지도 - AI 여행 추천</title>
    
    <!-- External CSS -->
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/resources/css/map-page.css'/>">
    
    <!-- External Scripts -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/proj4js/2.8.0/proj4.min.js"></script>
    <script type="text/javascript" src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=5ce45af9de7c941243bd02f08dc5c4b3"></script>
</head>
<body>
    <%@ include file="../common/header.jsp" %>
    
    <div class="map-page-container">
        <div class="map-page-header">
            <h1>AI와 함께하는 맞춤 여행</h1>
            <p>원하는 지역을 선택하고 여행 기간과 인원을 입력하면 AI가 최적의 여행 코스를 추천해드립니다.</p>
        </div>
        
        <div class="map-content-grid">
            <div class="map-section">
                <div id="map"></div>
            </div>
            
            <div class="travel-panel">
                <div class="option-card">
                    <h3><i class="fas fa-map-marker-alt"></i>여행 지역</h3>
                    <div id="selectedRegion" class="region-display">지역을 선택해주세요</div>
                </div>
                
                <div class="option-card">
                    <h3><i class="fas fa-calendar-alt"></i>여행 기간</h3>
                    <div class="custom-dropdown">
                        <div class="dropdown-trigger" id="periodTrigger">
                            <span>기간을 선택해주세요</span>
                            <i class="fas fa-chevron-down"></i>
                        </div>
                        <div class="dropdown-menu" id="periodMenu">
                            <div class="dropdown-item" data-value="1">당일치기</div>
                            <div class="dropdown-item" data-value="2">1박2일</div>
                            <div class="dropdown-item" data-value="3">2박3일</div>
                            <div class="dropdown-item" data-value="4">3박4일</div>
                            <div class="dropdown-item" data-value="5">4박5일</div>
                            <div class="dropdown-item" data-value="6">5박6일</div>
                            <div class="dropdown-item" data-value="7">6박7일</div>
                            <div class="dropdown-item" data-value="8">7박8일</div>
                        </div>
                    </div>
                </div>
                
                <div class="option-card">
                    <h3><i class="fas fa-users"></i>동행 인원</h3>
                    <div class="custom-dropdown">
                        <div class="dropdown-trigger" id="countTrigger">
                            <span>인원을 선택해주세요</span>
                            <i class="fas fa-chevron-down"></i>
                        </div>
                        <div class="dropdown-menu" id="countMenu">
                            <div class="dropdown-item" data-value="1">1명</div>
                            <div class="dropdown-item" data-value="2">2명</div>
                            <div class="dropdown-item" data-value="3">3명</div>
                            <div class="dropdown-item" data-value="4">4명</div>
                            <div class="dropdown-item" data-value="5">5명</div>
                            <div class="dropdown-item" data-value="6">6명</div>
                            <div class="dropdown-item" data-value="7">7명</div>
                            <div class="dropdown-item" data-value="8">8명</div>
                            <div class="dropdown-item" data-value="9">9명</div>
                            <div class="dropdown-item" data-value="10">10명</div>
                        </div>
                    </div>
                </div>
                
                <div class="option-card">
                    <h3><i class="fas fa-wallet"></i>여행 경비</h3>
                    <div class="custom-dropdown">
                        <div class="dropdown-trigger" id="budgetTrigger">
                            <span>예산을 선택해주세요</span>
                            <i class="fas fa-chevron-down"></i>
                        </div>
                        <div class="dropdown-menu" id="budgetMenu">
                            <div class="dropdown-item" data-value="200000">1인당 20만원 이하</div>
                            <div class="dropdown-item" data-value="300000">1인당 30만원 이하</div>
                            <div class="dropdown-item" data-value="400000">1인당 40만원 이하</div>
                            <div class="dropdown-item" data-value="500000">1인당 50만원 이하</div>
                            <div class="dropdown-item" data-value="600000">1인당 60만원 이하</div>
                            <div class="dropdown-item" data-value="700000">1인당 70만원 이하</div>
                            <div class="dropdown-item" data-value="800000">1인당 80만원 이상</div>
                        </div>
                    </div>
                </div>
                
                <div class="option-card">
                    <button id="aiRecommendBtn" class="ai-button">
                        <i class="fas fa-robot"></i>
                        <span>AI 여행 추천 받기</span>
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Recommendation Modal -->
    <div class="modal-overlay" id="modalOverlay"></div>
    <div class="recommendation-modal" id="recommendationModal">
        <button class="close-modal" onclick="closeRecommendation()">
            <i class="fas fa-times"></i>
        </button>
        <div class="recommendation-header">
            <h3><i class="fas fa-robot"></i> AI 맞춤 여행 추천</h3>
            <p>당신을 위한 특별한 여행 코스</p>
        </div>
        <div class="recommendation-content" id="recommendationContent">
            <!-- AI recommendation content will be inserted here -->
        </div>
        <div class="recommendation-actions">
            <button class="save-plan-btn" id="savePlanBtn" onclick="saveTravelPlan()">
                <i class="fas fa-save"></i>
                <span>여행 계획 저장</span>
            </button>
        </div>
    </div>
    
    <!-- JavaScript -->
    <script src="<c:url value='/resources/js/map-page.js'/>"></script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>