<%-- JSP와 JavaScript 템플릿 리터럴 충돌 해결을 위한 공통 설정 --%>
<%--
    이 파일을 JavaScript 템플릿 리터럴을 사용하는 JSP 페이지에 include하세요.
    JavaScript에서 ${} 사용 시 JSP EL과 충돌하는 문제를 해결합니다.
--%>

<%-- 방법 1: 특정 페이지에서만 EL 비활성화 (권장하지 않음) --%>
<%-- <%@ page isELIgnored="true" %> --%>

<%-- 방법 2: JavaScript 템플릿 리터럴 이스케이프 --%>
<script>
    // JavaScript 템플릿 리터럴에서 ${} 사용 시 \${}로 이스케이프
    // 예시: const message = "Hello " + name;

    // 또는 EL과 충돌하지 않도록 변수로 처리
    const DOLLAR = '$';
</script>