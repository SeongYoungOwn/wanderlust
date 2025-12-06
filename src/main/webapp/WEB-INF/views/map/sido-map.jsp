<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>시도별 지도 - AI 여행 추천</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/proj4js/2.8.0/proj4.min.js"></script>
    <style>
        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
            margin: 0;
            padding: 0;
            background: #f8f9fa;
            color: #2d3748;
            line-height: 1.6;
            padding-top: 60px;
        }
        
        .map-page-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 1rem;
        }
        
        /* Page Header with Modern Gradient */
        .map-page-header {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
            border-radius: 20px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.04);
            padding: 2rem;
            margin-bottom: 1.5rem;
            text-align: center;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.8);
        }
        
        .map-page-header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 1rem;
        }
        
        .map-page-header p {
            font-size: 1.1rem;
            color: #718096;
            max-width: 600px;
            margin: 0 auto;
        }
        
        /* Main Content Grid */
        .map-content-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 1rem;
            margin-top: 1rem;
        }
        
        /* Map Container with Modern Style */
        .map-section {
            background: white;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.06);
            padding: 1rem;
            height: 500px;
        }
        
        #map {
            width: 100%;
            height: 100%;
            border-radius: 15px;
            overflow: hidden;
        }
        
        /* Travel Options Panel */
        .travel-panel {
            display: flex;
            flex-direction: column;
            gap: 0.8rem;
            height: 500px;
            position: relative;
            overflow: visible;
        }
        
        
        .option-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.05);
            padding: 1rem;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid rgba(255, 255, 255, 0.8);
            flex: 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: visible;
        }
        
        .option-card:hover:not(.dropdown-active) {
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.08);
        }
        
        .option-card.dropdown-active {
            z-index: 100001;
        }
        
        .option-card h3 {
            font-size: 1rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .option-card h3 i {
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 1.1em;
        }
        
        /* Region Display */
        .region-display {
            background: linear-gradient(135deg, #f7fafc, #edf2f7);
            border: 2px dashed #cbd5e0;
            border-radius: 10px;
            padding: 0.75rem;
            text-align: center;
            font-size: 0.95rem;
            color: #718096;
            transition: all 0.3s ease;
            min-height: 35px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .region-display.active {
            background: linear-gradient(135deg, rgba(255, 107, 107, 0.1), rgba(78, 205, 196, 0.1));
            border-color: #ff6b6b;
            color: #2d3748;
            font-weight: 600;
            font-size: 1.2rem;
        }
        
        /* Custom Dropdown */
        .custom-dropdown {
            position: relative;
            z-index: 10000;
        }
        
        .custom-dropdown.open {
            z-index: 100000;
        }
        
        .dropdown-trigger {
            background: #f7fafc;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            padding: 0.6rem 0.75rem;
            cursor: pointer;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s ease;
            font-size: 0.9rem;
            color: #4a5568;
        }
        
        .dropdown-trigger:hover {
            border-color: #667eea;
            background: #edf2f7;
        }
        
        .dropdown-trigger.open {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        
        .dropdown-trigger i {
            transition: transform 0.3s ease;
        }
        
        .dropdown-trigger.open i {
            transform: rotate(180deg);
        }
        
        .dropdown-menu {
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            right: 0;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
            z-index: 99999 !important;
            max-height: 200px;
            overflow-y: auto;
            opacity: 0;
            transform: translateY(-10px);
            visibility: hidden;
            transition: all 0.2s ease;
        }
        
        .dropdown-menu.show {
            opacity: 1;
            transform: translateY(0);
            visibility: visible;
        }
        
        .dropdown-item {
            padding: 1rem 1.5rem;
            cursor: pointer;
            transition: all 0.2s ease;
            color: #4a5568;
            border-bottom: 1px solid #f1f1f1;
        }
        
        .dropdown-item:last-child {
            border-bottom: none;
        }
        
        .dropdown-item:hover {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
            color: #667eea;
        }
        
        .dropdown-item.selected {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            font-weight: 500;
        }
        
        /* AI Button */
        .ai-button {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 12px;
            padding: 1rem 1.5rem;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.25);
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            position: relative;
            overflow: hidden;
            margin: auto;
            z-index: 1;
        }
        
        .ai-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.5s ease;
        }
        
        .ai-button:hover::before {
            left: 100%;
        }
        
        .ai-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(102, 126, 234, 0.35);
        }
        
        .ai-button:disabled {
            background: #cbd5e0;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        
        .ai-button:disabled::before {
            display: none;
        }
        
        /* Loading Spinner */
        .loading-spinner {
            width: 20px;
            height: 20px;
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: #ffffff;
            animation: spin 1s ease-in-out infinite;
            margin-right: 0.5rem;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        /* Recommendation Modal */
        .recommendation-modal {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) scale(0.9);
            background: white;
            border-radius: 25px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
            z-index: 1001;
            max-width: 800px;
            width: 90%;
            max-height: 80vh;
            overflow-y: auto;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            padding: 2.5rem;
        }
        
        .recommendation-modal.show {
            opacity: 1;
            visibility: visible;
            transform: translate(-50%, -50%) scale(1);
        }
        
        .recommendation-header {
            text-align: center;
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 2px solid #f1f1f1;
        }
        
        .recommendation-header h3 {
            font-size: 1.75rem;
            font-weight: 700;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.5rem;
        }
        
        .recommendation-header p {
            color: #718096;
            font-size: 1.1rem;
        }
        
        .recommendation-content {
            line-height: 1.8;
            color: #4a5568;
            white-space: pre-line;
        }
        
        .recommendation-info {
            background: linear-gradient(135deg, #f7fafc, #edf2f7);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            border-left: 4px solid #667eea;
        }
        
        .recommendation-info p {
            margin: 0.5rem 0;
            color: #2d3748;
        }
        
        .recommendation-info strong {
            color: #667eea;
        }
        
        /* Day Schedule Styling */
        .day-schedule {
            background: linear-gradient(135deg, #f8f9fa, #e9ecef);
            border-radius: 15px;
            padding: 1.5rem;
            margin: 1rem 0;
            border-left: 4px solid #4ecdc4;
        }
        
        .day-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #2d3748;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .schedule-item {
            display: flex;
            align-items: flex-start;
            gap: 1rem;
            margin: 0.75rem 0;
            padding: 0.5rem 0;
            border-bottom: 1px dashed rgba(0, 0, 0, 0.1);
        }
        
        .schedule-item:last-child {
            border-bottom: none;
        }
        
        .time-slot {
            font-weight: 500;
            color: #718096;
            min-width: 60px;
        }
        
        .activity {
            color: #2d3748;
            margin-left: 1rem;
        }
        
        .modal-actions {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 2px solid #e2e8f0;
        }
        
        .modal-btn {
            padding: 0.75rem 2rem;
            border-radius: 25px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            font-size: 1rem;
        }
        
        .modal-btn.close {
            background: #e2e8f0;
            color: #4a5568;
        }
        
        .modal-btn.close:hover {
            background: #cbd5e0;
            transform: translateY(-2px);
        }
        
        .modal-btn.save {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.25);
        }
        
        .modal-btn.save:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.35);
        }
        
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(5px);
            z-index: 999;
        }
        
        /* Responsive Design */
        @media (max-width: 1024px) {
            .map-content-grid {
                grid-template-columns: 1fr;
            }
            
            .travel-panel {
                position: static;
                max-height: none;
            }
            
            .map-section {
                height: 500px;
            }
        }
        
        @media (max-width: 768px) {
            .map-page-container {
                padding: 1rem;
            }
            
            .map-page-header {
                padding: 2rem 1.5rem;
            }
            
            .map-page-header h1 {
                font-size: 2rem;
            }
            
            .option-card {
                padding: 1.25rem;
            }
            
            .recommendation-modal {
                margin: 1rem;
                max-width: calc(100% - 2rem);
                padding: 2rem 1.5rem;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>
    
    <div class="map-page-container">
        <div class="map-page-header">
            <h1>AI와 함께하는 맞춤 여행</h1>
            <p>원하는 지역을 선택하고 여행 기간과 인원을 입력하면, AI가 최적의 여행 코스를 추천해드립니다.</p>
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
        <div class="recommendation-header">
            <h3><i class="fas fa-robot"></i> AI 맞춤 여행 추천</h3>
            <p>당신을 위한 특별한 여행 코스</p>
        </div>
        <div class="recommendation-content" id="recommendationContent">
            <!-- AI recommendation content will be inserted here -->
        </div>
        <div class="modal-actions">
            <button class="modal-btn close" onclick="closeRecommendation()">닫기</button>
            <button class="modal-btn save" onclick="saveTravelPlan()">
                <i class="fas fa-save"></i> 여행 계획 작성하러가기
            </button>
        </div>
    </div>
    
    <script>
        let map;
        let polygons = [];
        let selectedPolygon = null;
        let selectedRegionName = null;
        
        // AI 추천 데이터 저장용 전역 변수
        let currentAIRecommendation = {
            region: '',
            period: '',
            count: '',
            content: ''
        };
        
        // 좌표계 정의
        const tmProjection = '+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs';
        const wgs84Projection = '+proj=longlat +datum=WGS84 +no_defs';
        
        // 시도별 색상
        const sidoColors = {
            '서울특별시': '#FF5722',
            '부산광역시': '#2196F3',
            '대구광역시': '#03A9F4',
            '인천광역시': '#00BCD4',
            '광주광역시': '#009688',
            '대전광역시': '#4CAF50',
            '울산광역시': '#8BC34A',
            '세종특별자치시': '#9C27B0',
            '경기도': '#CDDC39',
            '강원특별자치도': '#FF6F00',
            '충청북도': '#FFC107',
            '충청남도': '#FF9800',
            '전북특별자치도': '#795548',
            '전라남도': '#3F51B5',
            '경상북도': '#E91E63',
            '경상남도': '#00ACC1',
            '제주특별자치도': '#7C4DFF'
        };
        
        // 지도 초기화
        function initMap() {
            const container = document.getElementById('map');
            const options = {
                center: new kakao.maps.LatLng(36.3504, 127.3845),
                level: 12
            };
            map = new kakao.maps.Map(container, options);
            
            // si.json 파일 로드
            fetch('<c:url value="/resources/data/si.json"/>')
                .then(response => response.json())
                .then(data => {
                    drawSidoPolygons(data);
                })
                .catch(error => console.error('Error loading si.json:', error));
        }
        
        // 시도 폴리곤 그리기
        function drawSidoPolygons(geoData) {
            if (geoData.type === 'GeometryCollection' && geoData.geometries) {
                const areaNames = [
                    '서울특별시', '부산광역시', '대구광역시', '인천광역시',
                    '광주광역시', '대전광역시', '울산광역시', '세종특별자치시',
                    '경기도', '충청북도', '충청남도', '전북특별자치도',
                    '전라남도', '경상북도', '경상남도', '제주특별자치도', '강원특별자치도'
                ];
                
                geoData.geometries.forEach((geometry, index) => {
                    const areaName = areaNames[index] || `지역 ` + (index + 1);
                    const areaColor = sidoColors[areaName] || generateRandomColor();
                    
                    if (geometry.type === 'Polygon') {
                        drawPolygon(geometry.coordinates[0], areaName, areaColor);
                    } else if (geometry.type === 'MultiPolygon') {
                        geometry.coordinates.forEach(polygon => {
                            drawPolygon(polygon[0], areaName, areaColor);
                        });
                    }
                });
            }
        }
        
        function generateRandomColor() {
            const colors = [
                '#FF5722', '#2196F3', '#03A9F4', '#00BCD4', '#009688',
                '#4CAF50', '#8BC34A', '#9C27B0', '#CDDC39', '#FF6F00'
            ];
            return colors[Math.floor(Math.random() * colors.length)];
        }
        
        // 개별 폴리곤 그리기
        function drawPolygon(coords, areaName, areaColor) {
            const path = coords.map(coord => {
                try {
                    const [lng, lat] = proj4(tmProjection, wgs84Projection, [coord[0], coord[1]]);
                    return new kakao.maps.LatLng(lat, lng);
                } catch (error) {
                    console.warn('좌표 변환 오류:', coord, error);
                    return new kakao.maps.LatLng(37.5665, 126.9780);
                }
            }).filter(point => point.getLat() > 33 && point.getLat() < 39 && point.getLng() > 124 && point.getLng() < 132);
            
            if (path.length >= 3) {
                const polygon = new kakao.maps.Polygon({
                    path: path,
                    strokeWeight: 2,
                    strokeColor: '#fff',
                    strokeOpacity: 0.8,
                    fillColor: areaColor,
                    fillOpacity: 0.3
                });
                
                polygon.setMap(map);
                polygons.push(polygon);
                
                if (areaName.includes('광역시') || areaName.includes('특별시') || areaName.includes('특별자치시')) {
                    polygon.setZIndex(1000);
                } else {
                    polygon.setZIndex(100);
                }
                
                // 클릭 이벤트
                kakao.maps.event.addListener(polygon, 'click', function() {
                    selectArea(areaName, polygon, areaColor);
                });
                
                // 마우스 오버 이벤트
                kakao.maps.event.addListener(polygon, 'mouseover', function() {
                    polygon.setOptions({
                        fillOpacity: 0.6,
                        strokeWeight: 3
                    });
                });
                
                // 마우스 아웃 이벤트
                kakao.maps.event.addListener(polygon, 'mouseout', function() {
                    if (polygon !== selectedPolygon) {
                        polygon.setOptions({
                            fillOpacity: 0.3,
                            strokeWeight: 2
                        });
                    }
                });
            }
        }
        
        // 지역 선택
        function selectArea(areaName, polygon, areaColor) {
            if (selectedPolygon) {
                selectedPolygon.setOptions({
                    fillOpacity: 0.3,
                    strokeWeight: 2
                });
            }
            
            selectedPolygon = polygon;
            selectedRegionName = areaName;
            polygon.setOptions({
                fillOpacity: 0.6,
                strokeWeight: 4
            });
            
            const selectedRegion = document.getElementById('selectedRegion');
            selectedRegion.textContent = areaName;
            selectedRegion.className = 'region-display active';
            selectedRegion.style.borderColor = areaColor;
        }
        
        // 드롭다운 초기화
        function initDropdowns() {
            // 여행 기간 드롭다운
            const periodTrigger = document.getElementById('periodTrigger');
            const periodMenu = document.getElementById('periodMenu');
            
            periodTrigger.addEventListener('click', function() {
                const dropdown = this.closest('.custom-dropdown');
                const card = this.closest('.option-card');
                
                // 다른 드롭다운 닫기
                document.querySelectorAll('.option-card').forEach(c => c.classList.remove('dropdown-active'));
                document.getElementById('countMenu').classList.remove('show');
                document.getElementById('countTrigger').classList.remove('open');
                document.getElementById('countTrigger').closest('.custom-dropdown').classList.remove('open');
                
                // 현재 드롭다운 토글
                this.classList.toggle('open');
                dropdown.classList.toggle('open');
                periodMenu.classList.toggle('show');
                
                if (periodMenu.classList.contains('show')) {
                    card.classList.add('dropdown-active');
                } else {
                    card.classList.remove('dropdown-active');
                }
            });
            
            periodMenu.addEventListener('click', function(e) {
                if (e.target.classList.contains('dropdown-item')) {
                    periodTrigger.querySelector('span').textContent = e.target.textContent;
                    periodMenu.classList.remove('show');
                    periodTrigger.classList.remove('open');
                    periodTrigger.closest('.custom-dropdown').classList.remove('open');
                    periodTrigger.closest('.option-card').classList.remove('dropdown-active');
                    
                    periodMenu.querySelectorAll('.dropdown-item').forEach(item => {
                        item.classList.remove('selected');
                    });
                    e.target.classList.add('selected');
                }
            });
            
            // 동행 인원 드롭다운
            const countTrigger = document.getElementById('countTrigger');
            const countMenu = document.getElementById('countMenu');
            
            countTrigger.addEventListener('click', function() {
                const dropdown = this.closest('.custom-dropdown');
                const card = this.closest('.option-card');
                
                // 다른 드롭다운 닫기
                document.querySelectorAll('.option-card').forEach(c => c.classList.remove('dropdown-active'));
                document.getElementById('periodMenu').classList.remove('show');
                document.getElementById('periodTrigger').classList.remove('open');
                document.getElementById('periodTrigger').closest('.custom-dropdown').classList.remove('open');
                
                // 현재 드롭다운 토글
                this.classList.toggle('open');
                dropdown.classList.toggle('open');
                countMenu.classList.toggle('show');
                
                if (countMenu.classList.contains('show')) {
                    card.classList.add('dropdown-active');
                } else {
                    card.classList.remove('dropdown-active');
                }
            });
            
            countMenu.addEventListener('click', function(e) {
                if (e.target.classList.contains('dropdown-item')) {
                    countTrigger.querySelector('span').textContent = e.target.textContent;
                    countMenu.classList.remove('show');
                    countTrigger.classList.remove('open');
                    countTrigger.closest('.custom-dropdown').classList.remove('open');
                    countTrigger.closest('.option-card').classList.remove('dropdown-active');
                    
                    countMenu.querySelectorAll('.dropdown-item').forEach(item => {
                        item.classList.remove('selected');
                    });
                    e.target.classList.add('selected');
                }
            });
            
            // 외부 클릭 시 드롭다운 닫기
            document.addEventListener('click', function(e) {
                if (!e.target.closest('.custom-dropdown')) {
                    document.querySelectorAll('.dropdown-menu').forEach(menu => {
                        menu.classList.remove('show');
                    });
                    document.querySelectorAll('.dropdown-trigger').forEach(trigger => {
                        trigger.classList.remove('open');
                        trigger.closest('.custom-dropdown').classList.remove('open');
                    });
                    document.querySelectorAll('.option-card').forEach(c => c.classList.remove('dropdown-active'));
                }
            });
        }
        
        // AI 추천 기능 초기화
        function initAIRecommendation() {
            const aiBtn = document.getElementById('aiRecommendBtn');
            
            aiBtn.addEventListener('click', function() {
                const selectedRegion = document.getElementById('selectedRegion').textContent;
                const selectedPeriod = document.getElementById('periodTrigger').querySelector('span').textContent;
                const selectedCount = document.getElementById('countTrigger').querySelector('span').textContent;
                
                if (selectedRegion === '지역을 선택해주세요') {
                    alert('먼저 지도에서 지역을 선택해주세요!');
                    return;
                }
                if (selectedPeriod === '기간을 선택해주세요') {
                    alert('여행 기간을 선택해주세요!');
                    return;
                }
                if (selectedCount === '인원을 선택해주세요') {
                    alert('동행 인원을 선택해주세요!');
                    return;
                }
                
                // 로딩 상태
                aiBtn.disabled = true;
                aiBtn.innerHTML = '<span class="loading-spinner"></span><span>AI가 추천 중...</span>';
                
                // AI 추천 요청
                generateAIRecommendation(selectedRegion, selectedPeriod, selectedCount);
            });
        }
        
        function generateAIRecommendation(region, period, count) {
            // Claude AI API 호출
            fetch('/api/ai/recommend', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `region=` + encodeURIComponent(region) + `&period=` + encodeURIComponent(period) + `&count=` + encodeURIComponent(count)
            })
            .then(response => response.json())
            .then(data => {
                const aiBtn = document.getElementById('aiRecommendBtn');
                aiBtn.disabled = false;
                aiBtn.innerHTML = '<i class="fas fa-robot"></i><span>AI 여행 추천 받기</span>';
                
                if (data.success) {
                    displayAIRecommendation(region, period, count, data.recommendation);
                } else {
                    alert('AI 추천 생성 중 오류가 발생했습니다: ' + (data.error || '알 수 없는 오류'));
                    // Fallback으로 기본 추천 표시
                    displayFallbackRecommendation(region, period, count);
                }
            })
            .catch(error => {
                console.error('AI API 호출 오류:', error);
                const aiBtn = document.getElementById('aiRecommendBtn');
                aiBtn.disabled = false;
                aiBtn.innerHTML = '<i class="fas fa-robot"></i><span>AI 여행 추천 받기</span>';
                
                alert('네트워크 오류가 발생했습니다. 기본 추천을 표시합니다.');
                // Fallback으로 기본 추천 표시
                displayFallbackRecommendation(region, period, count);
            });
        }
        
        function displayAIRecommendation(region, period, count, aiResponse) {
            // AI 추천 데이터를 전역 변수에 저장
            currentAIRecommendation = {
                region: region,
                period: period,
                count: count,
                content: aiResponse
            };
            
            const content = document.getElementById('recommendationContent');
            
            let html = '<div class="recommendation-info">' +
                '<p><strong><i class="fas fa-map-marker-alt"></i> 여행지:</strong> ' + region + '</p>' +
                '<p><strong><i class="fas fa-calendar-alt"></i> 여행 기간:</strong> ' + period + '</p>' +
                '<p><strong><i class="fas fa-users"></i> 동행 인원:</strong> ' + count + '</p>' +
                '</div>' +
                '<hr style="margin: 1.5rem 0; border: none; border-top: 2px solid #e2e8f0;">' +
                '<div class="ai-recommendation-content">' + formatAIResponse(aiResponse) + '</div>';
            
            content.innerHTML = html;
            showRecommendation();
        }
        
        function formatAIResponse(response) {
            // AI 응답을 HTML로 포맷팅
            let formatted = response
                .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')  // **텍스트** -> <strong>텍스트</strong>
                .replace(/🎯|📅|🌅|🍽️|☀️|🌆|🏨|💡|💰/g, '<br><span style="font-size: 1.2em;">$&</span>')  // 이모지 강조
                .replace(/\n/g, '<br>')  // 줄바꿈
                .replace(/- (.*?)(<br>|$)/g, '<div style="margin-left: 1rem; margin-bottom: 0.5rem;">• $1</div>')  // 리스트 항목
                .replace(/<br><br>/g, '<br>');  // 연속된 줄바꿈 정리
            
            return '<div style="line-height: 1.8; color: #4a5568;">' + formatted + '</div>';
        }
        
        function displayFallbackRecommendation(region, period, count) {
            const content = document.getElementById('recommendationContent');
            
            let html = '<div class="recommendation-info">' +
                '<p><strong><i class="fas fa-map-marker-alt"></i> 여행지:</strong> ' + region + '</p>' +
                '<p><strong><i class="fas fa-calendar-alt"></i> 여행 기간:</strong> ' + period + '</p>' +
                '<p><strong><i class="fas fa-users"></i> 동행 인원:</strong> ' + count + '</p>' +
                '</div>' +
                '<hr style="margin: 1.5rem 0; border: none; border-top: 2px solid #e2e8f0;">';
            
            html += generateFallbackContent(region, period, count);
            
            content.innerHTML = html;
            showRecommendation();
        }
        
        function generateFallbackContent(region, period, count) {
            // 기간에서 일수 추출
            const dayCount = period.includes('당일') ? 1 : parseInt(period.match(/\d+/)[0]) + 1;
            
            let content = '<div class="day-schedule">';
            content += '<div class="day-title">🌟 ' + region + ' ' + period + ' 추천 일정</div>';
            
            for (let day = 1; day <= dayCount; day++) {
                content += '<div class="schedule-item">';
                content += '<span class="time-slot">' + day + '일차</span>';
                content += '<span class="activity">주요 관광지 및 맛집 탐방</span>';
                content += '</div>';
            }
            
            content += '</div>';
            content += '<p><strong>💡 추천 포인트:</strong><br>';
            content += '• ' + region + '의 대표적인 관광명소들을 방문해보세요<br>';
            content += '• ' + count + '에게 적합한 다양한 액티비티를 즐겨보세요<br>';
            content += '• 현지 맛집에서 특색있는 음식을 맛보세요</p>';
            
            return content;
        }
        
        function showRecommendation() {
            const modal = document.getElementById('recommendationModal');
            const overlay = document.getElementById('modalOverlay');
            
            overlay.style.display = 'block';
            modal.classList.add('show');
        }
        
        function closeRecommendation() {
            const modal = document.getElementById('recommendationModal');
            const overlay = document.getElementById('modalOverlay');
            
            modal.classList.remove('show');
            overlay.style.display = 'none';
        }
        
        function saveTravelPlan() {
            if (!currentAIRecommendation.region || !currentAIRecommendation.content) {
                alert('저장할 AI 추천 데이터가 없습니다.');
                return;
            }
            
            // 저장 로딩 상태 표시
            const saveButton = document.querySelector('.modal-btn.save');
            const originalContent = saveButton.innerHTML;
            saveButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 저장 중...';
            saveButton.disabled = true;
            
            // AI 추천 데이터를 직접 여행 계획으로 저장
            const planData = {
                title: currentAIRecommendation.region + ' AI 맞춤 여행',
                destination: currentAIRecommendation.region,
                duration: parseInt(currentAIRecommendation.period) || 3,
                planContent: JSON.stringify({
                    source: 'ai_map_recommendation',
                    region: currentAIRecommendation.region,
                    period: currentAIRecommendation.period,
                    count: currentAIRecommendation.count,
                    aiContent: currentAIRecommendation.content,
                    recommendations: parseAIContent(currentAIRecommendation.content)
                }),
                tags: ['AI추천', currentAIRecommendation.region, currentAIRecommendation.period + '일'],
                memo: '지도에서 생성된 AI 맞춤 여행 추천',
                isTemplate: false
            };
            
            // AI 여행 계획 저장 API 호출
            fetch('/api/travel-plans/save', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(planData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 저장 성공 알림
                    alert('AI 여행 계획이 성공적으로 저장되었습니다!');
                    // 팝업창 닫기
                    closeRecommendation();
                    // 저장된 계획 보기 여부 확인
                    if (confirm('저장된 여행 계획을 보시겠습니까?')) {
                        window.open('/member/ai-plans', '_blank');
                    }
                } else {
                    throw new Error(data.message || '저장에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('AI 여행 계획 저장 오류:', error);
                alert('여행 계획 저장 중 오류가 발생했습니다: ' + error.message);
            })
            .finally(() => {
                // 버튼 상태 복원
                saveButton.innerHTML = originalContent;
                saveButton.disabled = false;
            });
        }
        
        // AI 추천 내용을 파싱하여 구조화된 데이터로 변환
        function parseAIContent(content) {
            try {
                const recommendations = [];
                const lines = content.split('\n');
                let currentDay = null;
                let currentPlace = null;
                
                lines.forEach(line => {
                    line = line.trim();
                    if (line.includes('일차') || line.includes('Day')) {
                        currentDay = line;
                        currentPlace = null;
                    } else if (line.includes('추천') || line.includes('장소') || line.includes('관광지')) {
                        currentPlace = line;
                    } else if (line && currentDay && line.length > 10) {
                        recommendations.push({
                            day: currentDay,
                            place: currentPlace || '추천 장소',
                            description: line
                        });
                    }
                });
                
                return recommendations;
            } catch (e) {
                console.error('AI 내용 파싱 오류:', e);
                return [{ description: content }];
            }
        }
        
        // 기존 세션 저장 함수 (백업용)
        function saveTravelPlanToSession() {
            if (!currentAIRecommendation.region) {
                alert('저장할 AI 추천 데이터가 없습니다.');
                return;
            }
            
            // AI 추천 데이터를 서버에 세션으로 저장
            fetch('/ai-travel/save-session', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(currentAIRecommendation)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // 팝업창 닫기
                    closeRecommendation();
                    // travel/create 페이지로 이동
                    window.location.href = '/travel/create?from=ai';
                } else {
                    alert('저장에 실패했습니다: ' + (data.error || '알 수 없는 오류'));
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('저장 중 오류가 발생했습니다.');
            });
        }
        
        // 페이지 로드 시 초기화
        function initializePage() {
            console.log('페이지 초기화 시작');
            
            // Kakao API 로드 상태 확인
            if (typeof kakao === 'undefined') {
                console.log('Kakao API 동적 로드 시작');
                const script = document.createElement('script');
                script.src = 'https://dapi.kakao.com/v2/maps/sdk.js?appkey=5ce45af9de7c941243bd02f08dc5c4b3&libraries=services';
                script.onload = function() {
                    console.log('Kakao Maps API 스크립트 로드 완료');
                    setTimeout(() => {
                        if (typeof kakao !== 'undefined' && kakao.maps) {
                            console.log('Kakao Maps 객체 확인 완료');
                            initializeComponents();
                        } else {
                            console.error('Kakao Maps 객체 로드 실패');
                            showError();
                        }
                    }, 500);
                };
                script.onerror = function() {
                    console.error('Kakao Maps API 스크립트 로드 실패');
                    showError();
                };
                document.head.appendChild(script);
            } else {
                console.log('Kakao API 이미 로드됨');
                initializeComponents();
            }
        }
        
        function initializeComponents() {
            console.log('컴포넌트 초기화 시작');
            try {
                initMap();
                initDropdowns();
                initAIRecommendation();
                console.log('모든 컴포넌트 초기화 완료');
            } catch (error) {
                console.error('컴포넌트 초기화 오류:', error);
                showError();
            }
        }
        
        function showError() {
            alert('지도 서비스를 로드할 수 없습니다. 페이지를 새로고침해주세요.');
        }
        
        // DOM 로드 완료 시 초기화
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializePage);
        } else {
            initializePage();
        }
        
        // 모달 외부 클릭 시 닫기 (안전한 이벤트 리스너)
        function attachModalEvents() {
            const modalOverlay = document.getElementById('modalOverlay');
            if (modalOverlay) {
                modalOverlay.addEventListener('click', function() {
                    closeRecommendation();
                });
            }
        }
        
        // 페이지 로드 후 모달 이벤트 추가
        setTimeout(attachModalEvents, 1000);
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>