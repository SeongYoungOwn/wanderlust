<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>지도 테스트</title>
    <style>
        body {
            margin: 0;
            padding-top: 60px;
            font-family: Arial, sans-serif;
        }
        .container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 20px;
        }
        #map {
            width: 100%;
            height: 400px;
            border: 1px solid #ddd;
            background-color: #f0f0f0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            color: #666;
        }
        .info {
            margin-top: 20px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        .status {
            color: #28a745;
            font-weight: bold;
        }
        .error {
            color: #dc3545;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>
    
    <div class="container">
        <h1>지도 기능 테스트</h1>
        
        <div id="map">
            지도가 여기에 표시됩니다.
        </div>
        
        <div class="info">
            <h3>테스트 결과</h3>
            <div id="test-results">
                <p>테스트 진행 중...</p>
            </div>
        </div>
    </div>
    
    <script>
        const testResults = document.getElementById('test-results');
        let results = [];
        
        // 1. proj4 라이브러리 테스트
        try {
            if (typeof proj4 !== 'undefined') {
                results.push('<p class="status">✓ proj4 라이브러리 로드 성공</p>');
            } else {
                results.push('<p class="error">✗ proj4 라이브러리 로드 실패</p>');
            }
        } catch (e) {
            results.push('<p class="error">✗ proj4 테스트 오류: ' + e.message + '</p>');
        }
        
        // 2. 데이터 파일 접근 테스트
        fetch('<c:url value="/resources/data/si.json"/>')
            .then(response => {
                if (response.ok) {
                    results.push('<p class="status">✓ si.json 파일 접근 성공</p>');
                    return response.json();
                } else {
                    results.push('<p class="error">✗ si.json 파일 접근 실패 (HTTP ' + response.status + ')</p>');
                }
            })
            .then(data => {
                if (data) {
                    results.push('<p class="status">✓ si.json 파일 파싱 성공 (geometries: ' + (data.geometries ? data.geometries.length : 0) + '개)</p>');
                }
                updateResults();
            })
            .catch(error => {
                results.push('<p class="error">✗ si.json 파일 로드 오류: ' + error.message + '</p>');
                updateResults();
            });
        
        fetch('<c:url value="/resources/data/sido.json"/>')
            .then(response => {
                if (response.ok) {
                    results.push('<p class="status">✓ sido.json 파일 접근 성공</p>');
                    return response.json();
                } else {
                    results.push('<p class="error">✗ sido.json 파일 접근 실패 (HTTP ' + response.status + ')</p>');
                }
            })
            .then(data => {
                if (data) {
                    results.push('<p class="status">✓ sido.json 파일 파싱 성공 (features: ' + (data.features ? data.features.length : 0) + '개)</p>');
                }
                updateResults();
            })
            .catch(error => {
                results.push('<p class="error">✗ sido.json 파일 로드 오류: ' + error.message + '</p>');
                updateResults();
            });
        
        // 3. 좌표 변환 테스트
        setTimeout(() => {
            try {
                if (typeof proj4 !== 'undefined') {
                    const tmProjection = '+proj=tmerc +lat_0=38 +lon_0=127.5 +k=0.9996 +x_0=1000000 +y_0=2000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs';
                    const wgs84Projection = '+proj=longlat +datum=WGS84 +no_defs';
                    
                    // 서울 좌표로 테스트 (TM 좌표계)
                    const testCoord = [954491, 1959777];
                    const [lng, lat] = proj4(tmProjection, wgs84Projection, testCoord);
                    
                    if (lng > 120 && lng < 140 && lat > 30 && lat < 45) {
                        results.push('<p class="status">✓ 좌표 변환 테스트 성공 (TM: [' + testCoord[0] + ', ' + testCoord[1] + '] → WGS84: [' + lng.toFixed(4) + ', ' + lat.toFixed(4) + '])</p>');
                    } else {
                        results.push('<p class="error">✗ 좌표 변환 결과 이상: [' + lng + ', ' + lat + ']</p>');
                    }
                } else {
                    results.push('<p class="error">✗ proj4 라이브러리 없음 - 좌표 변환 불가</p>');
                }
                
                updateResults();
            } catch (e) {
                results.push('<p class="error">✗ 좌표 변환 오류: ' + e.message + '</p>');
                updateResults();
            }
        }, 1000);
        
        function updateResults() {
            testResults.innerHTML = results.join('');
        }
        
        // 간단한 지도 표시 테스트 (Kakao Maps 없이)
        document.getElementById('map').innerHTML = 
            '<div style="text-align: center;">' +
            '<p style="margin: 0; font-size: 16px; color: #666;">지도 라이브러리 로드 중...</p>' +
            '<p style="margin: 10px 0 0 0; font-size: 14px; color: #888;">Kakao Maps API 키가 필요합니다</p>' +
            '</div>';
    </script>
    
    <!-- proj4 라이브러리 로드 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/proj4js/2.8.0/proj4.min.js"></script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>