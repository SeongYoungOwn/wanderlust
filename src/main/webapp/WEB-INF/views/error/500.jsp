<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>오류 발생 - AI 여행 동행 매칭 플랫폼</title>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <div class="container my-5">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card shadow">
                        <div class="card-body text-center py-5">
                            <div class="mb-4">
                                <i class="fas fa-exclamation-triangle fa-5x text-warning"></i>
                            </div>
                            <h2 class="mb-3">서버 오류가 발생했습니다</h2>
                            <p class="text-muted mb-4">
                                죄송합니다. 일시적인 서버 오류가 발생했습니다.<br>
                                잠시 후 다시 시도해 주세요.
                            </p>
                            
                            <c:if test="${not empty error}">
                                <div class="alert alert-danger text-start">
                                    <strong>오류 상세:</strong> ${error}
                                </div>
                            </c:if>

                            <c:if test="${not empty exception}">
                                <div class="alert alert-warning text-start">
                                    <strong>예외 타입:</strong> ${exception}<br>
                                    <strong>메시지:</strong> ${trace}
                                </div>
                            </c:if>

                            <c:if test="${not empty errorMessage}">
                                <div class="alert alert-info text-start">
                                    <strong>에러 메시지:</strong> ${errorMessage}
                                </div>
                            </c:if>
                            
                            <div class="mt-4">
                                <a href="${pageContext.request.contextPath}/" class="btn btn-primary me-2">
                                    <i class="fas fa-home me-2"></i>홈으로 돌아가기
                                </a>
                                <button onclick="history.back()" class="btn btn-outline-secondary">
                                    <i class="fas fa-arrow-left me-2"></i>이전 페이지
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>
</body>
</html>