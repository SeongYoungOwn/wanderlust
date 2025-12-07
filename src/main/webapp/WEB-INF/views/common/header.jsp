<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
/* Modern Header Styles */
header {
    background: rgba(255, 255, 255, 0.98);
    backdrop-filter: blur(20px);
    padding: 0.6rem 0;
    position: fixed;
    width: 100%;
    top: 0;
    z-index: 1000;
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);
    box-shadow: 0 1px 20px rgba(0, 0, 0, 0.04);
}

nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1400px;
    margin: 0 auto;
    padding: 0 2rem;
    height: 60px;
}

.logo {
    font-size: 1.75rem;
    font-weight: 700;
    background: linear-gradient(135deg, #667eea, #764ba2);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    letter-spacing: -0.02em;
    text-decoration: none;
    transition: all 0.3s ease;
}

.logo:hover {
    transform: scale(1.05);
    background: linear-gradient(135deg, #ff6b6b, #ffd93d);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.nav-links {
    display: flex;
    list-style: none;
    gap: 2rem;
    margin: 0;
    padding: 0;
}

.nav-links a {
    text-decoration: none;
    color: #2d3748;
    font-weight: 500;
    font-size: 0.95rem;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    position: relative;
    padding: 0.75rem 1rem;
    border-radius: 12px;
    backdrop-filter: blur(10px);
}

.nav-links a:hover {
    color: #667eea;
    background: rgba(102, 126, 234, 0.08);
    transform: translateY(-1px);
}

.nav-links a::before {
    content: '';
    position: absolute;
    bottom: 0;
    left: 50%;
    width: 0;
    height: 2px;
    background: linear-gradient(90deg, #667eea, #764ba2);
    transition: all 0.3s ease;
    transform: translateX(-50%);
    border-radius: 2px;
}

.nav-links a:hover::before {
    width: 80%;
}

.nav-links a.active {
    color: #ff6b6b;
    background: linear-gradient(135deg, rgba(255, 107, 107, 0.15), rgba(78, 205, 196, 0.15));
    font-weight: 600;
}

.nav-links a.active::before {
    width: 80%;
    background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
}

.nav-actions {
    display: flex;
    gap: 0.75rem;
    align-items: center;
}

.cta-button {
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    padding: 0.65rem 1.5rem;
    border: none;
    border-radius: 25px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 4px 16px rgba(102, 126, 234, 0.25);
    font-size: 0.9rem;
    text-decoration: none;
    display: inline-block;
    position: relative;
    overflow: hidden;
}

.cta-button::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    transition: left 0.5s ease;
}

.cta-button:hover::before {
    left: 100%;
}

.cta-button:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(102, 126, 234, 0.35);
    color: white;
}

.user-menu {
    position: relative;
    display: inline-block;
}

.user-toggle {
    background: transparent;
    color: #4a5568;
    border: 2px solid rgba(255, 107, 107, 0.3);
    padding: 0.7rem 1.5rem;
    border-radius: 25px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-block;
}

.user-toggle:hover {
    background: #ff6b6b;
    color: white;
    transform: translateY(-2px);
}

.user-dropdown {
    position: absolute;
    top: 100%;
    right: 0;
    background: white;
    border-radius: 15px;
    box-shadow: 0 15px 40px rgba(0,0,0,0.15);
    border: 1px solid rgba(255, 107, 107, 0.1);
    min-width: 200px;
    opacity: 0;
    visibility: hidden;
    transform: translateY(-10px);
    transition: all 0.3s ease;
    margin-top: 0.5rem;
}

.user-menu:hover .user-dropdown {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.user-dropdown a {
    display: flex;
    align-items: center;
    padding: 0.75rem 1.5rem;
    color: #4a5568;
    text-decoration: none;
    font-weight: 500;
    transition: all 0.3s ease;
    border-bottom: 1px solid rgba(255, 107, 107, 0.1);
}

.user-dropdown a i {
    width: 20px;
    text-align: center;
    margin-right: 10px;
    flex-shrink: 0;
}

.user-dropdown a:last-child {
    border-bottom: none;
}

.user-dropdown a:hover {
    background: linear-gradient(135deg, rgba(255, 107, 107, 0.1), rgba(255, 217, 61, 0.1));
    color: #ff6b6b;
    transform: translateX(5px);
}

.hamburger {
    display: none;
    flex-direction: column;
    cursor: pointer;
    padding: 0.5rem;
}

.hamburger span {
    width: 25px;
    height: 3px;
    background: #ff6b6b;
    margin: 3px 0;
    transition: 0.3s;
    border-radius: 2px;
}

/* Mobile Responsive */
@media (max-width: 768px) {
    header {
        padding: 0.4rem 0;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
    }
    
    nav {
        padding: 0 1rem;
        height: 50px;
    }
    
    .nav-links {
        display: none;
    }
    
    .hamburger {
        display: flex;
    }
    
    .logo {
        font-size: 1.4rem;
    }
    
    .nav-actions {
        gap: 0.5rem;
    }
    
    .cta-button, .user-toggle {
        padding: 0.5rem 1rem;
        font-size: 0.85rem;
        border-radius: 20px;
    }
    
    .user-dropdown {
        right: 0;
        left: auto;
        min-width: 180px;
    }
}
</style>

<!-- Navigation -->
<header>
    <nav>
        <a href="${pageContext.request.contextPath}/home" class="logo">Wanderlust</a>
        
        <ul class="nav-links">
            <li><a href="${pageContext.request.contextPath}/travel/list" data-page="travel"><i class="fas fa-map-marked-alt me-1"></i>여행 계획</a></li>
            <li><a href="${pageContext.request.contextPath}/guide/list" data-page="guide"><i class="fas fa-user-tie me-1"></i>가이드</a></li>
            <li><a href="${pageContext.request.contextPath}/board/list" data-page="board"><i class="fas fa-comments me-1"></i>커뮤니티</a></li>
            <li><a href="${pageContext.request.contextPath}/travel-mbti/test" data-page="travel-mbti"><i class="fas fa-user-tag me-1"></i>여행 MBTI</a></li>
            <li><a href="${pageContext.request.contextPath}/ai/model" data-page="ai-model"><i class="fas fa-brain me-1"></i>AI 모델</a></li>
            <li><a href="${pageContext.request.contextPath}/notice/list" data-page="notice"><i class="fas fa-bullhorn me-1"></i>공지사항</a></li>
        </ul>
        
        <div class="nav-actions">
            <c:choose>
                <c:when test="${not empty sessionScope.loginUser}">
                    <div class="user-menu">
                        <a href="#" class="user-toggle">
                            <i class="fas fa-user me-1"></i>
                            <c:choose>
                                <c:when test="${not empty sessionScope.loginUser.nickname}">
                                    ${sessionScope.loginUser.nickname}님
                                </c:when>
                                <c:otherwise>
                                    ${sessionScope.loginUser.userName}님
                                </c:otherwise>
                            </c:choose>
                        </a>
                        <div class="user-dropdown">
                            <c:if test="${sessionScope.loginUser.userRole eq 'ADMIN' || sessionScope.loginUser.userId eq 'admin'}">
                                <a href="${pageContext.request.contextPath}/admin/dashboard">
                                    <i class="fas fa-tachometer-alt me-2"></i>관리자 대시보드
                                </a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/member/mypage">
                                <i class="fas fa-user-circle me-2"></i>마이페이지
                            </a>
                            <a href="${pageContext.request.contextPath}/manner/my-evaluations">
                                <i class="fas fa-star me-2"></i>내 매너 평가
                            </a>
                            <a href="${pageContext.request.contextPath}/chat/rooms">
                                <i class="fas fa-comments me-2"></i>내 채팅방
                            </a>
                            <a href="${pageContext.request.contextPath}/travel-mbti/history">
                                <i class="fas fa-user-tag me-2"></i>여행 MBTI 기록
                            </a>
                            <a href="${pageContext.request.contextPath}/travel/create">
                                <i class="fas fa-plus-circle me-2"></i>여행 계획 만들기
                            </a>
                            <c:if test="${empty sessionScope.guideApplicationStatus or sessionScope.guideApplicationStatus eq 'rejected'}">
                                <a href="${pageContext.request.contextPath}/guide/register">
                                    <i class="fas fa-user-tie me-2"></i>가이드 신청
                                </a>
                            </c:if>
                            <a href="${pageContext.request.contextPath}/board/create">
                                <i class="fas fa-pen me-2"></i>글쓰기
                            </a>
                            <a href="${pageContext.request.contextPath}/member/logout">
                                <i class="fas fa-sign-out-alt me-2"></i>로그아웃
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/member/login" class="user-toggle">
                        <i class="fas fa-sign-in-alt me-1"></i>로그인
                    </a>
                </c:otherwise>
            </c:choose>
            
            <div class="hamburger">
                <span></span>
                <span></span>
                <span></span>
            </div>
        </div>
    </nav>
</header>

<script>
// Header scroll effect
function updateHeaderBackground() {
    const header = document.querySelector('header');
    
    if (window.scrollY > 100) {
        header.style.background = 'rgba(253, 251, 247, 0.98)';
        header.style.boxShadow = '0 4px 30px rgba(0,0,0,0.1)';
    } else {
        header.style.background = 'rgba(253, 251, 247, 0.95)';
        header.style.boxShadow = 'none';
    }
}

window.addEventListener('scroll', updateHeaderBackground);

// Active navigation menu
document.addEventListener('DOMContentLoaded', function() {
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-links a');
    
    // Remove all active classes first
    navLinks.forEach(link => link.classList.remove('active'));
    
    // Add active class based on current path
    if (currentPath.includes('/travel/')) {
        document.querySelector('[data-page="travel"]')?.classList.add('active');
    } else if (currentPath.includes('/guide/')) {
        document.querySelector('[data-page="guide"]')?.classList.add('active');
    } else if (currentPath.includes('/board/')) {
        document.querySelector('[data-page="board"]')?.classList.add('active');
    } else if (currentPath.includes('/travel-mbti/')) {
        document.querySelector('[data-page="travel-mbti"]')?.classList.add('active');
    } else if (currentPath.includes('/ai/chat')) {
        document.querySelector('[data-page="ai"]')?.classList.add('active');
    } else if (currentPath.includes('/ai/model')) {
        document.querySelector('[data-page="ai-model"]')?.classList.add('active');
    } else if (currentPath.includes('/notice/')) {
        document.querySelector('[data-page="notice"]')?.classList.add('active');
    }
});
</script>