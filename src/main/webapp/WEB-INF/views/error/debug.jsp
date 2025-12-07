<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>디버그 정보</title>
    <style>
        body { font-family: monospace; padding: 20px; background: #f5f5f5; }
        .error-box { background: #fff; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .error-title { color: #d32f2f; font-size: 1.5em; margin-bottom: 10px; }
        .error-content { background: #f8f8f8; padding: 15px; border-radius: 4px; }
        .stack-trace { background: #2d2d2d; color: #f5f5f5; padding: 15px; border-radius: 4px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="error-box">
        <div class="error-title">디버그 정보</div>
        <div class="error-content">
            <h3>에러 메시지:</h3>
            <p>${error}</p>
            
            <h3>스택 트레이스:</h3>
            <div class="stack-trace">
                <pre>${stackTrace}</pre>
            </div>
        </div>
    </div>
    
    <a href="/">홈으로 돌아가기</a>
</body>
</html>