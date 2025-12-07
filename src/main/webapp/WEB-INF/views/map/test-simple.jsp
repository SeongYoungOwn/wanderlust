<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simple Map Test</title>
    <style>
        body {
            margin: 0;
            padding-top: 60px;
            font-family: 'Noto Sans KR', Arial, sans-serif;
            background-color: #f5f7fa;
        }
        .container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 30px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            margin-bottom: 10px;
            font-size: 2rem;
        }
        .subtitle {
            color: #7f8c8d;
            margin-bottom: 30px;
            font-size: 1rem;
        }
        #map {
            width: 100%;
            height: 500px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 24px;
            font-weight: 600;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.2);
        }
        .info-box {
            margin-top: 25px;
            padding: 20px;
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            border-radius: 6px;
        }
        .info-box h3 {
            margin-top: 0;
            color: #667eea;
            font-size: 1.2rem;
        }
        .info-box ul {
            list-style: none;
            padding: 0;
            margin: 15px 0 0 0;
        }
        .info-box li {
            padding: 8px 0;
            color: #555;
            line-height: 1.6;
        }
        .info-box li::before {
            content: "✓ ";
            color: #667eea;
            font-weight: bold;
            margin-right: 8px;
        }
        .status {
            display: inline-block;
            padding: 6px 12px;
            background: #28a745;
            color: white;
            border-radius: 4px;
            font-size: 0.9rem;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <%@ include file="/WEB-INF/views/common/header.jsp" %>

    <div class="container">
        <h1>🗺️ Simple Map Test</h1>
        <p class="subtitle">간단한 지도 기능 테스트 페이지입니다.</p>

        <div id="map">
            지도 영역 (테스트용)
        </div>

        <div class="info-box">
            <h3>테스트 정보</h3>
            <ul>
                <li><span class="status">활성화</span> 페이지 상태: 정상 작동</li>
                <li>엔드포인트: /map/test-simple</li>
                <li>컨트롤러: MapController</li>
                <li>용도: 간단한 지도 기능 테스트</li>
            </ul>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
