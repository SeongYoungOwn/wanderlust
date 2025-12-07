<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 테스트 페이지</title>
</head>
<body>
    <h1>로그인 테스트</h1>
    <form action="${pageContext.request.contextPath}/member/login" method="post">
        <input type="text" name="userId" placeholder="아이디">
        <input type="password" name="userPw" placeholder="비밀번호">
        <button type="submit">로그인</button>
    </form>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>