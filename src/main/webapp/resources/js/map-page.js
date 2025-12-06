let map;
let polygons = [];
let selectedPolygon = null;
let selectedRegionName = null;
let currentRecommendation = null;

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
    const dataUrl = document.querySelector('meta[name="contextPath"]')?.getAttribute('content') || '';
    fetch(dataUrl + '/resources/data/si.json')
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
            const areaName = areaNames[index] || `지역 ${index + 1}`;
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
    
    // 예산 드롭다운
    const budgetTrigger = document.getElementById('budgetTrigger');
    const budgetMenu = document.getElementById('budgetMenu');
    
    budgetTrigger.addEventListener('click', function() {
        const dropdown = this.closest('.custom-dropdown');
        const card = this.closest('.option-card');
        
        // 다른 드롭다운 닫기
        document.querySelectorAll('.option-card').forEach(c => c.classList.remove('dropdown-active'));
        document.getElementById('periodMenu').classList.remove('show');
        document.getElementById('periodTrigger').classList.remove('open');
        document.getElementById('periodTrigger').closest('.custom-dropdown').classList.remove('open');
        document.getElementById('countMenu').classList.remove('show');
        document.getElementById('countTrigger').classList.remove('open');
        document.getElementById('countTrigger').closest('.custom-dropdown').classList.remove('open');
        
        // 현재 드롭다운 토글
        this.classList.toggle('open');
        dropdown.classList.toggle('open');
        budgetMenu.classList.toggle('show');
        
        if (budgetMenu.classList.contains('show')) {
            card.classList.add('dropdown-active');
        } else {
            card.classList.remove('dropdown-active');
        }
    });
    
    budgetMenu.addEventListener('click', function(e) {
        if (e.target.classList.contains('dropdown-item')) {
            budgetTrigger.querySelector('span').textContent = e.target.textContent;
            budgetMenu.classList.remove('show');
            budgetTrigger.classList.remove('open');
            budgetTrigger.closest('.custom-dropdown').classList.remove('open');
            budgetTrigger.closest('.option-card').classList.remove('dropdown-active');
            
            budgetMenu.querySelectorAll('.dropdown-item').forEach(item => {
                item.classList.remove('selected');
            });
            e.target.classList.add('selected');
        }
    });
    
    // 외부 클릭시 드롭다운 닫기
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.custom-dropdown')) {
            document.querySelectorAll('.dropdown-menu').forEach(menu => {
                menu.classList.remove('show');
            });
            document.querySelectorAll('.dropdown-trigger').forEach(trigger => {
                trigger.classList.remove('open');
                trigger.closest('.custom-dropdown').classList.remove('open');
            });
            document.querySelectorAll('.option-card').forEach(card => {
                card.classList.remove('dropdown-active');
            });
        }
    });
}

// AI 추천 기능
function initAIRecommendation() {
    const aiBtn = document.getElementById('aiRecommendBtn');
    const modal = document.getElementById('recommendationModal');
    const overlay = document.getElementById('modalOverlay');
    
    aiBtn.addEventListener('click', async function() {
        if (!selectedRegionName) {
            alert('여행 지역을 먼저 선택해주세요!');
            return;
        }
        
        const periodText = document.getElementById('periodTrigger').querySelector('span').textContent;
        const countText = document.getElementById('countTrigger').querySelector('span').textContent;
        const budgetText = document.getElementById('budgetTrigger').querySelector('span').textContent;
        
        if (periodText === '기간을 선택해주세요') {
            alert('여행 기간을 선택해주세요!');
            return;
        }
        
        if (countText === '인원을 선택해주세요') {
            alert('동행 인원을 선택해주세요!');
            return;
        }
        
        if (budgetText === '예산을 선택해주세요') {
            alert('여행 예산을 선택해주세요!');
            return;
        }
        
        // 로딩 시작
        aiBtn.disabled = true;
        aiBtn.innerHTML = '<div class="loading-spinner"></div><span>AI가 추천을 준비하고 있습니다...</span>';
        
        try {
            console.log('AI 추천 요청 시작:', {
                region: selectedRegionName,
                period: periodText,
                count: countText,
                budget: budgetText
            });
            
            const response = await fetch('/api/ai/recommend', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `region=${encodeURIComponent(selectedRegionName)}&period=${encodeURIComponent(periodText)}&count=${encodeURIComponent(countText)}&budget=${encodeURIComponent(budgetText)}`
            });
            
            console.log('API 응답 상태:', response.status);
            console.log('API 응답 헤더:', response.headers);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }
            
            const responseText = await response.text();
            console.log('원시 응답 텍스트:', responseText);
            
            let data;
            try {
                data = JSON.parse(responseText);
                console.log('파싱된 응답 데이터:', data);
            } catch (parseError) {
                console.error('JSON 파싱 오류:', parseError);
                console.error('응답 내용:', responseText);
                throw new Error('서버 응답을 파싱할 수 없습니다.');
            }
            
            if (data.success) {
                // 현재 추천 정보 저장
                currentRecommendation = {
                    region: selectedRegionName,
                    period: periodText,
                    count: countText,
                    budget: budgetText,
                    recommendation: data.recommendation
                };
                showRecommendation(data.recommendation, selectedRegionName, periodText, countText, budgetText);
            } else {
                const errorMessage = data.message || data.error || '알 수 없는 오류가 발생했습니다.';
                alert('추천을 받는 중 오류가 발생했습니다: ' + errorMessage);
            }
        } catch (error) {
            console.error('AI 추천 오류:', error);
            alert('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.');
        } finally {
            // 로딩 종료
            aiBtn.disabled = false;
            aiBtn.innerHTML = '<i class="fas fa-robot"></i><span>AI 여행 추천 받기</span>';
        }
    });
    
    // 모달 닫기
    overlay.addEventListener('click', closeRecommendation);
}

// 추천 결과 표시
function showRecommendation(recommendation, region, period, count, budget) {
    const modal = document.getElementById('recommendationModal');
    const overlay = document.getElementById('modalOverlay');
    const content = document.getElementById('recommendationContent');
    
    // 먼저 모든 드롭다운 닫기
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.classList.remove('show');
    });
    document.querySelectorAll('.dropdown-trigger').forEach(trigger => {
        trigger.classList.remove('open');
        trigger.closest('.custom-dropdown').classList.remove('open');
    });
    document.querySelectorAll('.option-card').forEach(card => {
        card.classList.remove('dropdown-active');
    });
    
    content.innerHTML = `
        <div class="recommendation-info">
            <p><strong>지역:</strong> ${region}</p>
            <p><strong>기간:</strong> ${period}</p>
            <p><strong>인원:</strong> ${count}</p>
            <p><strong>예산:</strong> ${budget}</p>
        </div>
        <div class="recommendation-text">${formatRecommendation(recommendation)}</div>
    `;
    
    modal.classList.add('show');
    overlay.classList.add('show');
    document.body.style.overflow = 'hidden';
}

// 추천 텍스트 포맷팅
function formatRecommendation(text) {
    if (!text) return '';
    
    // 텍스트를 줄 단위로 분리
    const lines = text.split('\n').filter(line => line.trim());
    let formattedHtml = '';
    let currentDay = '';
    
    lines.forEach(line => {
        line = line.trim();
        if (!line) return;
        
        // 일차별 제목 매칭 (1일차, 첫째날, Day 1 등)
        if (line.match(/^(\d+일차|\d+일|첫째날|둘째날|셋째날|넷째날|다섯째날|여섯째날|일곱째날|Day\s*\d+)/i)) {
            if (currentDay) {
                formattedHtml += '</div>'; // 이전 일차 종료
            }
            currentDay = line.replace(':', '');
            formattedHtml += `
                <div class="day-schedule">
                    <div class="day-title">
                        <i class="fas fa-calendar-day"></i>
                        ${currentDay}
                    </div>
                    <div class="day-activities">
            `;
        }
        // 시간 매칭 (08:00, 오전 8시, 8:00 등)
        else if (line.match(/^(\d{1,2}:\d{2}|\d{1,2}시|\오전\s*\d{1,2}시|\오후\s*\d{1,2}시)/)) {
            const timeMatch = line.match(/^([^-]+)\s*-\s*(.+)/) || line.match(/^([^:]+):\s*(.+)/) || [null, line.substring(0, 10), line.substring(10)];
            if (timeMatch) {
                const time = timeMatch[1].trim();
                const activity = timeMatch[2] ? timeMatch[2].trim() : '';
                formattedHtml += `
                    <div class="schedule-item">
                        <div class="schedule-time">${time}</div>
                        <div class="schedule-content">
                            <div class="schedule-title">${activity}</div>
                        </div>
                    </div>
                `;
            }
        }
        // 장소나 활동 매칭 (- 시작하는 리스트 등)
        else if (line.startsWith('-') || line.startsWith('•') || line.startsWith('*')) {
            const activity = line.replace(/^[-•*]\s*/, '');
            formattedHtml += `
                <div class="activity-item">
                    <i class="fas fa-map-marker-alt"></i>
                    <span>${activity}</span>
                </div>
            `;
        }
        // 일반 텍스트
        else if (line.length > 5) {
            formattedHtml += `<div class="recommendation-text">${line}</div>`;
        }
    });
    
    if (currentDay) {
        formattedHtml += '</div></div>'; // 마지막 일차 종료
    }
    
    // 만약 일차별 구조가 없다면 기본 텍스트로 처리
    if (!formattedHtml.includes('day-schedule')) {
        formattedHtml = `<div class="recommendation-text">${text.replace(/\n/g, '<br>')}</div>`;
    }
    
    return formattedHtml;
}

// 추천 모달 닫기
function closeRecommendation() {
    const modal = document.getElementById('recommendationModal');
    const overlay = document.getElementById('modalOverlay');
    
    modal.classList.remove('show');
    overlay.classList.remove('show');
    document.body.style.overflow = 'auto';
    
    // 드롭다운도 모두 닫기
    document.querySelectorAll('.dropdown-menu').forEach(menu => {
        menu.classList.remove('show');
    });
    document.querySelectorAll('.dropdown-trigger').forEach(trigger => {
        trigger.classList.remove('open');
        trigger.closest('.custom-dropdown').classList.remove('open');
    });
    document.querySelectorAll('.option-card').forEach(card => {
        card.classList.remove('dropdown-active');
    });
}

// 여행 계획 저장
function saveTravelPlan() {
    if (!currentRecommendation) {
        alert('저장할 여행 계획이 없습니다.');
        return;
    }
    
    try {
        // AI 추천 내용에서 일차별 상세 일정 이후 내용만 추출
        let detailedContent = currentRecommendation.recommendation;
        const dailyScheduleIndex = detailedContent.indexOf('📅 **일차별 상세 일정**');
        if (dailyScheduleIndex !== -1) {
            // "📅 **일차별 상세 일정**" 이후의 내용만 추출
            detailedContent = detailedContent.substring(dailyScheduleIndex + '📅 **일차별 상세 일정**'.length).trim();
        }

        // AI 추천 내용 포맷팅 (헤더 제거하고 일차별 내용만 포함)
        const planContent = detailedContent;

        // 예산 숫자 추출 (AI 내용에서 총합 금액 찾기)
        let budgetAmount = 0;
        
        // 먼저 AI 추천 내용에서 "총합: XXX원" 패턴을 찾아서 추출
        const totalBudgetMatch = currentRecommendation.recommendation.match(/총합:\s*([0-9,]+)원/);
        if (totalBudgetMatch) {
            const totalBudgetStr = totalBudgetMatch[1].replace(/,/g, ''); // 콤마 제거
            budgetAmount = parseInt(totalBudgetStr);
            console.log('AI 내용에서 총합 예산 추출:', budgetAmount);
        } else if (currentRecommendation.budget) {
            // 총합을 찾지 못했을 경우 기존 예산 필드에서 추출
            const budgetMatch = currentRecommendation.budget.match(/\d+/);
            if (budgetMatch) {
                budgetAmount = parseInt(budgetMatch[0]) * 10000; // 만원을 원으로 변환
                console.log('기존 예산 필드에서 추출:', budgetAmount);
            }
        }

        // AI 추천 데이터를 서버 세션에 저장
        const aiRecommendationData = {
            region: currentRecommendation.region,
            period: currentRecommendation.period.match(/\d+/)?.[0] || '3', // 숫자만 추출
            count: currentRecommendation.count.match(/\d+/)?.[0] || '4', // 숫자만 추출
            budget: budgetAmount, // 예산 정보 추가
            content: planContent
        };
        
        console.log('=== AI 추천 데이터 서버 저장 시도 ===');
        console.log('데이터:', aiRecommendationData);
        
        // 서버에 AI 추천 데이터 저장
        fetch('/ai-travel/save-session', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(aiRecommendationData)
        })
        .then(response => response.json())
        .then(data => {
            console.log('=== 서버 응답 ===', data);
            if (data.success) {
                // 모달 닫기
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
        
    } catch (error) {
        console.error('여행 계획 저장 오류:', error);
        alert('여행 계획 데이터 처리 중 오류가 발생했습니다.');
    }
}

// Kakao Maps API 로드 완료 후 초기화
function loadKakaoMaps() {
    if (window.kakao && window.kakao.maps) {
        initMap();
        initDropdowns();
        initAIRecommendation();
    } else {
        console.error('Kakao Maps API가 로드되지 않았습니다.');
    }
}

// DOM 로드 완료 후 실행
document.addEventListener('DOMContentLoaded', function() {
    // proj4가 로드되었는지 확인
    if (typeof proj4 === 'undefined') {
        console.error('proj4 라이브러리가 로드되지 않았습니다.');
        return;
    }
    
    // Kakao Maps API 로드 확인 및 초기화
    if (window.kakao && window.kakao.maps) {
        loadKakaoMaps();
    } else {
        // Kakao Maps API 로드 대기
        const checkKakao = setInterval(function() {
            if (window.kakao && window.kakao.maps) {
                clearInterval(checkKakao);
                loadKakaoMaps();
            }
        }, 100);
        
        // 10초 후에도 로드되지 않으면 에러 표시
        setTimeout(() => {
            clearInterval(checkKakao);
            if (!window.kakao || !window.kakao.maps) {
                console.error('Kakao Maps API 로드 실패');
                alert('지도를 로드할 수 없습니다. 페이지를 새로고침해주세요.');
            }
        }, 10000);
    }
});