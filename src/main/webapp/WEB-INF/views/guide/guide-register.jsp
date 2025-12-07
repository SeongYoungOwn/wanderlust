<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>가이드 등록 신청</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/resources/css/guide.css" rel="stylesheet">
    <style>
        .info-box {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
            padding: 1.5rem;
            border-radius: 15px;
            margin-bottom: 2rem;
            border: 1px solid rgba(102, 126, 234, 0.2);
        }

        .info-box p {
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .info-box ul {
            margin: 0;
            padding-left: 1.5rem;
            color: var(--text-secondary);
        }

        .waiting-message {
            display: none;
            text-align: center;
            padding: 4rem 2rem;
            background: var(--bg-white);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow-md);
        }

        .waiting-message.active {
            display: block;
        }

        .waiting-icon {
            font-size: 4rem;
            color: var(--accent-color);
            margin-bottom: 1.5rem;
        }

        .waiting-message h3 {
            color: var(--text-primary);
            font-weight: 700;
            margin-bottom: 1rem;
        }

        .waiting-message p {
            color: var(--text-secondary);
            line-height: 1.8;
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp" />

    <div class="guide-container">
        <div class="page-header">
            <h1>가이드 등록 신청</h1>
            <p>전문 가이드가 되어 특별한 여행 경험을 제공해보세요</p>
        </div>

        <div class="guide-register-container">

        <div class="info-box">
            <p><strong>안내사항</strong></p>
            <ul>
                <li>가이드 등록 신청 후 관리자 승인이 필요합니다.</li>
                <li>승인까지 최대 1-2일이 소요될 수 있습니다.</li>
                <li>모든 필수 정보를 정확하게 입력해주세요.</li>
            </ul>
        </div>

        <!-- 메시지 표시 -->
        <c:if test="${not empty message}">
            <div class="alert" style="padding: 1.5rem; margin: 2rem 0; border-radius: 10px; text-align: center;
                <c:choose>
                    <c:when test="${message.contains('거절')}">
                        background: linear-gradient(135deg, #fef3c7, #fde68a); border: 2px solid #fbbf24; color: #92400e;
                    </c:when>
                    <c:when test="${message.contains('진행 중') or message.contains('등록되어')}">
                        background: linear-gradient(135deg, #dbeafe, #bfdbfe); border: 2px solid #3b82f6; color: #1e40af;
                    </c:when>
                    <c:otherwise>
                        background: linear-gradient(135deg, #fecaca, #fca5a5); border: 2px solid #ef4444; color: #991b1b;
                    </c:otherwise>
                </c:choose>">
                <i class="fas fa-info-circle" style="font-size: 2rem; margin-bottom: 0.5rem;"></i>
                <h3 style="margin: 0.5rem 0; font-size: 1.5rem; font-weight: 700;">${message}</h3>
                <c:if test="${message.contains('진행 중') or message.contains('등록되어')}">
                    <p style="margin-top: 1rem; opacity: 0.8;">마이페이지에서 신청 상태를 확인하실 수 있습니다.</p>
                    <a href="${pageContext.request.contextPath}/member/mypage" class="btn-submit" style="display: inline-block; margin-top: 1rem; text-decoration: none;">
                        마이페이지로 이동
                    </a>
                </c:if>
            </div>
        </c:if>

        <!-- 폼은 가이드가 없고, 거절되었거나 신청 내역이 없을 때만 표시 -->
        <c:if test="${empty existingGuide and (empty existingApplication or existingApplication.status eq 'rejected')}">
        <form id="guideRegisterForm" action="${pageContext.request.contextPath}/guide/apply" method="post">
            <!-- 기본 정보 섹션 -->
            <div class="form-section">
                <h4 class="section-title">기본 정보</h4>

                <div class="form-group">
                    <label for="region" class="form-label">활동 지역 <span class="required-mark">*</span></label>
                    <select class="form-control form-select" id="region" name="region" required>
                        <option value="">지역을 선택하세요</option>
                        <option value="서울">서울</option>
                        <option value="부산">부산</option>
                        <option value="대구">대구</option>
                        <option value="인천">인천</option>
                        <option value="광주">광주</option>
                        <option value="대전">대전</option>
                        <option value="울산">울산</option>
                        <option value="세종">세종</option>
                        <option value="경기">경기</option>
                        <option value="강원">강원</option>
                        <option value="충북">충북</option>
                        <option value="충남">충남</option>
                        <option value="전북">전북</option>
                        <option value="전남">전남</option>
                        <option value="경북">경북</option>
                        <option value="경남">경남</option>
                        <option value="제주">제주</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="address" class="form-label">상세 주소 <span class="required-mark">*</span></label>
                    <input type="text" class="form-control" id="address" name="address" required
                           placeholder="예: 서울시 강남구 역삼동">
                </div>

                <div class="form-group">
                    <label for="phone" class="form-label">연락처 <span class="required-mark">*</span></label>
                    <input type="tel" class="form-control" id="phone" name="phone" required
                           placeholder="010-0000-0000" pattern="[0-9]{3}-[0-9]{4}-[0-9]{4}">
                </div>
            </div>

            <!-- 전문 분야 섹션 -->
            <div class="form-section">
                <h4 class="section-title">전문 분야</h4>

                <div class="form-group">
                    <label for="specialtyRegion" class="form-label">전문 지역 <span class="required-mark">*</span></label>
                    <input type="text" class="form-control" id="specialtyRegion" name="specialtyRegion" required
                           placeholder="예: 서울 전 지역, 제주도">
                </div>

                <div class="form-group">
                    <label for="specialtyTheme" class="form-label">전문 테마 <span class="required-mark">*</span></label>
                    <div class="specialty-group">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="specialtyTheme" value="역사문화" id="theme1">
                            <label class="form-check-label" for="theme1">역사문화</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="specialtyTheme" value="자연생태" id="theme2">
                            <label class="form-check-label" for="theme2">자연생태</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="specialtyTheme" value="맛집탐방" id="theme3">
                            <label class="form-check-label" for="theme3">맛집탐방</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="specialtyTheme" value="쇼핑" id="theme4">
                            <label class="form-check-label" for="theme4">쇼핑</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="specialtyTheme" value="레저스포츠" id="theme5">
                            <label class="form-check-label" for="theme5">레저스포츠</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="specialtyTheme" value="힐링휴양" id="theme6">
                            <label class="form-check-label" for="theme6">힐링휴양</label>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="specialtyArea" class="form-label">특화 영역 <span class="required-mark">*</span></label>
                    <input type="text" class="form-control" id="specialtyArea" name="specialtyArea" required
                           placeholder="예: 한국사 전공, 트레킹 전문가, 사진 촬영">
                </div>
            </div>

            <!-- 자기소개 섹션 -->
            <div class="form-section">
                <h4 class="section-title">자기소개</h4>

                <div class="form-group">
                    <label for="introduction" class="form-label">자기소개 <span class="required-mark">*</span></label>
                    <textarea class="form-control" id="introduction" name="introduction" rows="5" required
                              placeholder="가이드로서의 경험, 전문성, 특별한 능력 등을 자유롭게 소개해주세요."></textarea>
                </div>

                <div class="form-group">
                    <label for="greetingMessage" class="form-label">관리자에게 보낼 인사말 <span class="required-mark">*</span></label>
                    <textarea class="form-control" id="greetingMessage" name="greetingMessage" rows="3" required
                              placeholder="가이드 승인을 위한 간단한 인사말을 작성해주세요."></textarea>
                </div>
            </div>

            <!-- 제출 섹션 -->
            <div class="btn-group">
                <button type="submit" class="btn-submit">가이드 신청하기</button>
                <button type="button" class="btn-cancel" onclick="history.back()">취소</button>
            </div>
        </form>
        </c:if>

        <!-- 대기 메시지 -->
        <div id="waitingMessage" class="waiting-message">
            <div class="waiting-icon">⏳</div>
            <h3>신청이 완료되었습니다!</h3>
            <p class="text-muted mt-3">
                관리자가 승인할 때까지 기다려주세요.<br>
                승인 여부는 마이페이지에서 확인하실 수 있습니다.
            </p>
            <a href="${pageContext.request.contextPath}/member/mypage" class="btn-submit mt-3">마이페이지로 이동</a>
        </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function() {
            // 전문 테마 최소 1개 선택 검증
            $('#guideRegisterForm').on('submit', function(e) {
                e.preventDefault();

                var checkedThemes = $('input[name="specialtyTheme"]:checked');
                if (checkedThemes.length === 0) {
                    alert('전문 테마를 최소 1개 이상 선택해주세요.');
                    return false;
                }

                // 선택된 테마들을 콤마로 연결
                var themes = [];
                checkedThemes.each(function() {
                    themes.push($(this).val());
                });

                // AJAX로 신청 처리
                $.ajax({
                    url: $(this).attr('action'),
                    method: 'POST',
                    data: {
                        region: $('#region').val(),
                        address: $('#address').val(),
                        phone: $('#phone').val(),
                        specialtyRegion: $('#specialtyRegion').val(),
                        specialtyTheme: themes.join(','),
                        specialtyArea: $('#specialtyArea').val(),
                        introduction: $('#introduction').val(),
                        greetingMessage: $('#greetingMessage').val()
                    },
                    success: function(response) {
                        if (response.success) {
                            // 신청 성공
                            $('#guideRegisterForm').hide();
                            $('#waitingMessage').addClass('active');
                        } else {
                            // 신청 실패 (중복 등)
                            alert(response.message);
                        }
                    },
                    error: function(xhr, status, error) {
                        alert('신청 중 오류가 발생했습니다. 다시 시도해주세요.');
                    }
                });
            });

            // 전화번호 자동 포맷팅
            $('#phone').on('input', function() {
                var value = $(this).val().replace(/[^0-9]/g, '');
                if (value.length >= 3 && value.length <= 6) {
                    value = value.slice(0, 3) + '-' + value.slice(3);
                } else if (value.length >= 7) {
                    value = value.slice(0, 3) + '-' + value.slice(3, 7) + '-' + value.slice(7, 11);
                }
                $(this).val(value);
            });
        });
    </script>
    <%@ include file="../common/footer.jsp" %>
</body>
</html>