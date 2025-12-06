<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <title>AI 저장 목록 - AI 여행 동행 매칭 플랫폼</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #fdfbf7;
            color: #2d3748;
            line-height: 1.6;
            overflow-x: hidden;
            padding-top: 60px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 20px;
        }

        .page-header {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            color: white;
            padding: 4rem 0 2rem 0;
            margin-bottom: 2rem;
            border-radius: 15px;
        }

        .message-nav {
            background: white;
            border-radius: 10px;
            padding: 1rem;
            margin-bottom: 2rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .nav-tabs .nav-link {
            border: none;
            color: #6c757d;
            font-weight: 500;
            padding: 0.75rem 1.5rem;
        }

        .nav-tabs .nav-link.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 8px;
        }

        .message-table {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .message-row {
            padding: 1rem;
            border-bottom: 1px solid #e9ecef;
            transition: all 0.3s ease;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .message-content {
            flex: 1;
        }

        .message-actions {
            margin-left: 1rem;
            display: flex;
            gap: 0.5rem;
        }

        .stats-bar {
            background: white;
            padding: 1rem;
            border-radius: 10px;
            margin-bottom: 1rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #6c757d;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .pagination-wrapper {
            margin-top: 2rem;
            display: flex;
            justify-content: center;
        }

        /* Sections */
        .section {
            background: white;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            margin-bottom: 2rem;
            overflow: hidden;
        }

        .section-header {
            padding: 1.5rem;
            border-bottom: 1px solid #e2e8f0;
            background-color: #fafafa;
        }

        .section-title {
            font-size: 1.3rem;
            font-weight: 600;
            color: #374151;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .section-icon {
            width: 24px;
            height: 24px;
            color: #4f46e5;
        }

        .section-count {
            background: #4f46e5;
            color: white;
            font-size: 0.8rem;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            margin-left: auto;
        }

        /* Content Items */
        .content-list {
            padding: 0;
        }

        .content-item {
            padding: 1.5rem;
            border-bottom: 1px solid #f1f5f9;
            transition: background-color 0.2s;
        }

        .content-item:hover {
            background-color: #f8fafc;
        }

        .content-item:last-child {
            border-bottom: none;
        }

        .item-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }

        .item-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: #1f2937;
            margin: 0;
        }

        .item-date {
            color: #9ca3af;
            font-size: 0.9rem;
        }

        .item-details {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin-bottom: 1rem;
        }

        .detail-tag {
            background: #f3f4f6;
            color: #374151;
            font-size: 0.8rem;
            padding: 0.25rem 0.75rem;
            border-radius: 20px;
            display: flex;
            align-items: center;
            gap: 0.25rem;
        }

        .detail-tag i {
            font-size: 0.7rem;
        }

        .item-actions {
            display: flex;
            gap: 0.75rem;
        }

        .btn-simple {
            padding: 0.5rem 1rem;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.2s;
            border: none;
            cursor: pointer;
        }

        .btn-primary {
            background-color: #4f46e5;
            color: white;
        }

        .btn-primary:hover {
            background-color: #4338ca;
            color: white;
        }

        .btn-secondary {
            background-color: #f9fafb;
            color: #6b7280;
            border: 1px solid #d1d5db;
        }

        .btn-secondary:hover {
            background-color: #f3f4f6;
            color: #374151;
        }

        /* Empty State */
        .empty-state {
            padding: 3rem 1.5rem;
            text-align: center;
            color: #9ca3af;
        }

        .empty-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            opacity: 0.5;
        }

        .empty-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #6b7280;
            margin-bottom: 0.5rem;
        }

        .empty-description {
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 1.5rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .main-container {
                padding: 1rem;
            }

            .page-title {
                font-size: 2rem;
            }

            .item-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 0.5rem;
            }

            .item-actions {
                width: 100%;
            }

            .btn-simple {
                flex: 1;
                text-align: center;
            }
        }

        /* Simple hover effects */
        .section {
            transition: box-shadow 0.2s;
        }

        .section:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }
    </style>
</head>
<body>
    <div class="container-fluid p-0">
        <%@ include file="../common/header.jsp" %>

        <div class="page-header">
            <div class="container text-center">
                <h1><i class="fas fa-robot me-3"></i>AI 저장 목록(개발중)</h1>
                <p>AI가 생성한 콘텐츠를 관리하세요</p>
            </div>
        </div>

        <div class="container">

        <!-- 통계 정보 -->
        <div class="stats-bar">
            <div class="row text-center">
                <div class="col-md-3">
                    <strong>전체 저장</strong>
                    <span class="text-primary ms-2">${totalCount}개</span>
                </div>
                <div class="col-md-3">
                    <strong>여행계획</strong>
                    <span class="text-success ms-2">${savedAiPlanCount}개</span>
                </div>
                <div class="col-md-3">
                    <strong>플레이리스트</strong>
                    <span class="text-info ms-2">${savedPlaylistCount}개</span>
                </div>
                <div class="col-md-3">
                    <strong>패킹리스트</strong>
                    <span class="text-warning ms-2">${savedPackingCount != null ? savedPackingCount : 0}개</span>
                </div>
            </div>
        </div>

        <!-- 저장된 여행계획 -->
        <div class="message-table">
            <div style="background: #f8f9fa; padding: 1rem; border-bottom: 1px solid #e9ecef;">
                <h5 class="mb-0">
                    <i class="fas fa-route me-2"></i>저장된 여행계획 (${savedAiPlanCount}개)
                </h5>
            </div>
            <c:choose>
                <c:when test="${not empty savedAiPlans}">
                    <c:forEach var="plan" items="${savedAiPlans}">
                        <div class="message-row">
                            <div class="message-content">
                                <div class="message-meta">
                                    <div class="sender-name">
                                        <i class="fas fa-map-marker-alt me-2"></i>${plan.destination}
                                    </div>
                                    <div class="message-date">2024.08.16</div>
                                </div>
                                <div class="message-title">${plan.title}</div>
                                <div class="message-preview">
                                    <c:if test="${plan.duration != null}">
                                        ${plan.duration}일 여행 • 
                                    </c:if>
                                    <c:if test="${plan.budget != null && plan.budget > 0}">
                                        예산 <fmt:formatNumber value="${plan.budget}" pattern="#,###"/>원
                                    </c:if>
                                </div>
                            </div>
                            <div class="message-actions">
                                <button class="btn btn-sm btn-outline-primary me-1">
                                    <i class="fas fa-eye me-1"></i>보기
                                </button>
                                <button class="btn btn-sm btn-outline-secondary">
                                    <i class="fas fa-share me-1"></i>공유
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-route"></i>
                        <h3>저장된 여행계획이 없습니다</h3>
                        <p>AI 플래너로 맞춤형 여행계획을 생성해보세요.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 저장된 플레이리스트 -->
        <div class="message-table">
            <div style="background: #f8f9fa; padding: 1rem; border-bottom: 1px solid #e9ecef;">
                <h5 class="mb-0">
                    <i class="fas fa-music me-2"></i>저장된 플레이리스트 (${savedPlaylistCount}개)
                </h5>
            </div>
            <c:choose>
                <c:when test="${not empty savedPlaylists}">
                    <c:forEach var="playlist" items="${savedPlaylists}">
                        <div class="message-row">
                            <div class="message-content">
                                <div class="message-meta">
                                    <div class="sender-name">
                                        <i class="fas fa-music me-2"></i>${playlist.musicGenreDescription}
                                    </div>
                                    <div class="message-date">
                                        <fmt:formatDate value="${playlist.createdAt}" pattern="MM/dd"/>
                                    </div>
                                </div>
                                <div class="message-title">${playlist.playlistName}</div>
                                <div class="message-preview">
                                    ${playlist.musicOriginDescription} • ${playlist.destinationTypeDescription}
                                </div>
                            </div>
                            <div class="message-actions">
                                <button class="btn btn-sm btn-outline-success me-1">
                                    <i class="fas fa-play me-1"></i>재생
                                </button>
                                <button class="btn btn-sm btn-outline-info">
                                    <i class="fas fa-download me-1"></i>다운로드
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-music"></i>
                        <h3>저장된 플레이리스트가 없습니다</h3>
                        <p>AI 모델로 맞춤형 플레이리스트를 생성해보세요.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 저장된 패킹리스트 -->
        <div class="message-table">
            <div style="background: #f8f9fa; padding: 1rem; border-bottom: 1px solid #e9ecef;">
                <h5 class="mb-0">
                    <i class="fas fa-suitcase me-2"></i>저장된 패킹리스트 (${savedPackingCount != null ? savedPackingCount : 0}개)
                </h5>
            </div>
            <c:choose>
                <c:when test="${not empty savedPackingLists}">
                    <c:forEach var="packing" items="${savedPackingLists}">
                        <div class="message-row">
                            <div class="message-content">
                                <div class="message-meta">
                                    <div class="sender-name">
                                        <i class="fas fa-suitcase me-2"></i>${packing.travelType != null ? packing.travelType : '일반 여행'}
                                    </div>
                                    <div class="message-date">
                                        <fmt:formatDate value="${packing.createdAt}" pattern="MM/dd"/>
                                    </div>
                                </div>
                                <div class="message-title">${packing.packingListName != null ? packing.packingListName : '패킹리스트'}</div>
                                <div class="message-preview">
                                    ${packing.destination != null ? packing.destination : ''} • 
                                    ${packing.duration != null ? packing.duration : ''}일 여행
                                    <c:if test="${packing.totalItems != null}"> • 총 ${packing.totalItems}개 아이템</c:if>
                                </div>
                            </div>
                            <div class="message-actions">
                                <button class="btn btn-sm btn-outline-warning me-1">
                                    <i class="fas fa-eye me-1"></i>보기
                                </button>
                                <button class="btn btn-sm btn-outline-secondary">
                                    <i class="fas fa-check me-1"></i>체크리스트
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <i class="fas fa-suitcase"></i>
                        <h3>저장된 패킹리스트가 없습니다</h3>
                        <p>AI 패킹 어시스턴트로 맞춤형 패킹리스트를 생성해보세요.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 뒤로가기 버튼 -->
        <div class="text-center mt-4">
            <a href="${pageContext.request.contextPath}/member/mypage" class="btn btn-secondary">
                <i class="fas fa-arrow-left me-1"></i>마이페이지로 돌아가기
            </a>
        </div>
        </div>

        <%@ include file="../common/footer.jsp" %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>