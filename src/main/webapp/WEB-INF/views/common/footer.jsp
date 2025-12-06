<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .footer {
        background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
        color: white;
        padding: 4rem 0 1rem 0;
        margin-top: 5rem;
        position: relative;
        overflow: hidden;
    }
    
    .footer::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 4px;
        background: linear-gradient(90deg, #ff6b6b, #4ecdc4, #ffe66d, #a8e6cf);
        animation: gradient-shift 10s ease infinite;
    }
    
    @keyframes gradient-shift {
        0%, 100% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
    }
    
    .footer-content {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }
    
    .footer-top {
        display: grid;
        grid-template-columns: 2fr 1fr 1fr 1fr;
        gap: 3rem;
        margin-bottom: 3rem;
    }
    
    .footer-brand {
        max-width: 350px;
    }
    
    .footer-logo {
        font-size: 2rem;
        font-weight: 800;
        background: linear-gradient(135deg, #ff6b6b, #ffd93d);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
        margin-bottom: 1rem;
        display: inline-block;
    }
    
    .footer-description {
        color: #a0a0a0;
        line-height: 1.6;
        margin-bottom: 1.5rem;
    }
    
    .footer-social {
        display: flex;
        gap: 1rem;
    }
    
    .social-link {
        width: 40px;
        height: 40px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.1);
        display: flex;
        align-items: center;
        justify-content: center;
        text-decoration: none;
        color: white;
        transition: all 0.3s ease;
        border: 1px solid rgba(255, 255, 255, 0.1);
    }
    
    .social-link:hover {
        background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
        transform: translateY(-3px);
        color: white;
    }
    
    .footer-column h4 {
        font-size: 1.1rem;
        font-weight: 600;
        margin-bottom: 1.5rem;
        color: #ffffff;
        position: relative;
        padding-bottom: 0.5rem;
    }
    
    .footer-column h4::after {
        content: '';
        position: absolute;
        bottom: 0;
        left: 0;
        width: 30px;
        height: 2px;
        background: linear-gradient(90deg, #ff6b6b, #4ecdc4);
    }
    
    .footer-links {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    
    .footer-links li {
        margin-bottom: 0.8rem;
    }
    
    .footer-links a {
        color: #a0a0a0;
        text-decoration: none;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
    }
    
    .footer-links a:hover {
        color: #ff6b6b;
        transform: translateX(5px);
    }
    
    .footer-links i {
        font-size: 0.8rem;
        opacity: 0.5;
    }
    
    .footer-middle {
        padding: 2rem 0;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        margin-bottom: 2rem;
    }
    
    .newsletter {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 2rem;
    }
    
    .newsletter-text h4 {
        font-size: 1.3rem;
        margin-bottom: 0.5rem;
        color: white;
    }
    
    .newsletter-text p {
        color: #a0a0a0;
        margin: 0;
    }
    
    .newsletter-form {
        display: flex;
        gap: 1rem;
        flex: 1;
        max-width: 400px;
    }
    
    .newsletter-input {
        flex: 1;
        padding: 0.8rem 1.2rem;
        border: 1px solid rgba(255, 255, 255, 0.2);
        background: rgba(255, 255, 255, 0.05);
        border-radius: 50px;
        color: white;
        font-size: 0.95rem;
    }
    
    .newsletter-input::placeholder {
        color: #a0a0a0;
    }
    
    .newsletter-input:focus {
        outline: none;
        border-color: #ff6b6b;
        background: rgba(255, 255, 255, 0.1);
    }
    
    .newsletter-btn {
        padding: 0.8rem 2rem;
        background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
        border: none;
        border-radius: 50px;
        color: white;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;
    }
    
    .newsletter-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 10px 30px rgba(255, 107, 107, 0.3);
    }
    
    .footer-bottom {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 1rem;
    }
    
    .footer-copyright {
        color: #a0a0a0;
        font-size: 0.9rem;
    }
    
    .footer-legal {
        display: flex;
        gap: 2rem;
        list-style: none;
        padding: 0;
        margin: 0;
    }
    
    .footer-legal a {
        color: #a0a0a0;
        text-decoration: none;
        font-size: 0.9rem;
        transition: color 0.3s ease;
    }
    
    .footer-legal a:hover {
        color: #ff6b6b;
    }
    
    /* Responsive Design */
    @media (max-width: 992px) {
        .footer-top {
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
        }
        
        .footer-brand {
            grid-column: span 2;
            max-width: none;
        }
    }
    
    @media (max-width: 576px) {
        .footer-top {
            grid-template-columns: 1fr;
            gap: 2rem;
        }
        
        .footer-brand {
            grid-column: span 1;
        }
        
        .newsletter {
            flex-direction: column;
            align-items: flex-start;
        }
        
        .newsletter-form {
            width: 100%;
            max-width: none;
        }
        
        .footer-bottom {
            flex-direction: column;
            text-align: center;
        }
        
        .footer-legal {
            flex-direction: column;
            gap: 0.5rem;
        }
    }
    
    /* Back to top button */
    .back-to-top {
        position: fixed;
        bottom: 30px;
        right: 30px;
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background: linear-gradient(135deg, #ff6b6b, #4ecdc4);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        text-decoration: none;
        opacity: 0;
        visibility: hidden;
        transition: all 0.3s ease;
        z-index: 999;
        box-shadow: 0 5px 20px rgba(255, 107, 107, 0.3);
    }
    
    .back-to-top.show {
        opacity: 1;
        visibility: visible;
    }
    
    .back-to-top:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 30px rgba(255, 107, 107, 0.5);
        color: white;
    }
</style>

<!-- Footer -->
<footer class="footer">
    <div class="footer-content">
        <!-- Footer Top -->
        <div class="footer-top">
            <!-- Brand Column -->
            <div class="footer-brand">
                <div class="footer-logo">Wanderlust</div>
                <p class="footer-description">
                    AI 기반 여행 동행 매칭 플랫폼으로 완벽한 여행 파트너를 찾아드립니다. 
                    여행 MBTI 분석을 통해 나와 잘 맞는 동행자를 만나보세요.
                </p>
                <div class="footer-social">
                    <a href="https://www.facebook.com/" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Facebook">
                        <i class="fab fa-facebook-f"></i>
                    </a>
                    <a href="https://www.instagram.com/" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Instagram">
                        <i class="fab fa-instagram"></i>
                    </a>
                    <a href="https://twitter.com/" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="Twitter">
                        <i class="fab fa-twitter"></i>
                    </a>
                    <a href="https://www.youtube.com/" target="_blank" rel="noopener noreferrer" class="social-link" aria-label="YouTube">
                        <i class="fab fa-youtube"></i>
                    </a>
                </div>
            </div>
            
            <!-- Quick Links -->
            <div class="footer-column">
                <h4>빠른 링크</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/travel/list"><i class="fas fa-angle-right"></i>여행 계획</a></li>
                    <li><a href="${pageContext.request.contextPath}/board/list"><i class="fas fa-angle-right"></i>커뮤니티</a></li>
                    <li><a href="${pageContext.request.contextPath}/travel-mbti/test"><i class="fas fa-angle-right"></i>여행 MBTI</a></li>
                    <li><a href="${pageContext.request.contextPath}/ai/chat"><i class="fas fa-angle-right"></i>AI 플래너</a></li>
                    <li><a href="${pageContext.request.contextPath}/notice/list"><i class="fas fa-angle-right"></i>공지사항</a></li>
                </ul>
            </div>
            
            <!-- Services -->
            <div class="footer-column">
                <h4>서비스</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/travel/create"><i class="fas fa-angle-right"></i>여행 만들기</a></li>
                    <li><a href="${pageContext.request.contextPath}/board/create"><i class="fas fa-angle-right"></i>게시글 작성</a></li>
                    <li><a href="${pageContext.request.contextPath}/member/mypage"><i class="fas fa-angle-right"></i>마이페이지</a></li>
                    <li><a href="${pageContext.request.contextPath}/member/favorites"><i class="fas fa-angle-right"></i>찜한 여행</a></li>
                    <li><a href="${pageContext.request.contextPath}/manner/my-evaluations"><i class="fas fa-angle-right"></i>매너 평가</a></li>
                </ul>
            </div>
            
            <!-- Contact Info -->
            <div class="footer-column">
                <h4>고객센터</h4>
                <ul class="footer-links">
                    <li><a href="#"><i class="fas fa-phone"></i>1588-0000</a></li>
                    <li><a href="#"><i class="fas fa-envelope"></i>support@wanderlust.com</a></li>
                    <li><a href="#"><i class="fas fa-clock"></i>평일 09:00 - 18:00</a></li>
                    <li><a href="#"><i class="fas fa-map-marker-alt"></i>서울특별시 강남구</a></li>
                </ul>
            </div>
        </div>
        
        <!-- Newsletter Section -->
        <div class="footer-middle">
            <div class="newsletter">
                <div class="newsletter-text">
                    <h4>뉴스레터 구독</h4>
                    <p>최신 여행 정보와 특별한 혜택을 받아보세요</p>
                </div>
                <form class="newsletter-form" onsubmit="subscribeNewsletter(event)">
                    <input type="email" class="newsletter-input" placeholder="이메일 주소를 입력하세요" required>
                    <button type="submit" class="newsletter-btn">구독하기</button>
                </form>
            </div>
        </div>
        
        <!-- Footer Bottom -->
        <div class="footer-bottom">
            <p class="footer-copyright">
                &copy; 2024 Wanderlust. All rights reserved. Made with <i class="fas fa-heart" style="color: #ff6b6b;"></i> by Tour Team
            </p>
            <ul class="footer-legal">
                <li><a href="#">이용약관</a></li>
                <li><a href="#">개인정보처리방침</a></li>
                <li><a href="#">쿠키정책</a></li>
            </ul>
        </div>
    </div>
</footer>

<!-- Back to Top Button -->
<a href="#" class="back-to-top" id="backToTop">
    <i class="fas fa-arrow-up"></i>
</a>

<script>
    // Back to top button functionality
    window.addEventListener('scroll', function() {
        const backToTop = document.getElementById('backToTop');
        if (backToTop && window.scrollY > 300) {
            backToTop.classList.add('show');
        } else if (backToTop) {
            backToTop.classList.remove('show');
        }
    });
    
    const backToTopBtn = document.getElementById('backToTop');
    if (backToTopBtn) {
        backToTopBtn.addEventListener('click', function(e) {
            e.preventDefault();
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
    
    // Newsletter subscription
    function subscribeNewsletter(event) {
        event.preventDefault();
        const email = event.target.querySelector('input[type="email"]').value;
        alert('구독해 주셔서 감사합니다! ' + email + '로 뉴스레터를 발송해드리겠습니다.');
        event.target.reset();
    }
</script>