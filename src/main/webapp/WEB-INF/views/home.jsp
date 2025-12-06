<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="common/head.jsp" %>
    <title>AI 여행 동행 매칭 플랫폼</title>
    <style>
        /* --- Root Variables & Global Styles (plan3.md 기반 블루-오렌지 테마) --- */
        :root {
            --primary-color: #0052D4;   /* Main Blue for Trust */
            --secondary-color: #4364F7;
            --accent-color: #FF8C00;    /* Bright Orange for CTAs */
            --text-dark: #1A202C;
            --text-light: #4A5568;
            --text-muted: #718096;
            --bg-main: #F7FAFC;
            --bg-light: #FFFFFF;
            --gradient-primary: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            --gradient-accent: linear-gradient(135deg, var(--accent-color), #FF6B6B);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--bg-primary);
            color: var(--text-primary);
            line-height: 1.6;
            overflow-x: hidden;
        }

        .container-custom {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 2rem;
        }
        
        .section {
            padding: 5rem 0;
        }

        .section-header {
            text-align: center;
            margin-bottom: 3.5rem;
        }

        .section-title {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 1.2rem;
            color: var(--text-dark);
            line-height: 1.3;
        }

        .section-subtitle {
            font-size: 1.1rem;
            color: var(--text-muted);
            max-width: 600px;
            margin: 0 auto;
            line-height: 1.6;
        }

        /* Header Override - 기존 네비바 스타일 덮어쓰기 */
        .navbar.navbar-expand-lg.navbar-dark.bg-primary {
            background: var(--bg-card) !important;
            backdrop-filter: blur(15px);
            padding: 1.2rem 0 !important;
            border-bottom: 1px solid rgba(255, 107, 107, 0.1);
            transition: all 0.3s ease;
            position: fixed !important;
            top: 0 !important;
            width: 100% !important;
            z-index: 1000 !important;
        }

        .navbar-brand {
            font-size: 2rem !important;
            font-weight: 800 !important;
            background: linear-gradient(135deg, #ff6b6b, #ffd93d) !important;
            -webkit-background-clip: text !important;
            -webkit-text-fill-color: transparent !important;
            background-clip: text !important;
            letter-spacing: -0.02em !important;
        }

        .navbar-nav .nav-link {
            color: var(--text-secondary) !important;
            font-weight: 500 !important;
            transition: all 0.3s ease !important;
            position: relative !important;
        }

        .navbar-nav .nav-link:hover {
            color: #ff6b6b !important;
            transform: translateY(-2px) !important;
        }

        .navbar-nav .nav-link::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, #ff6b6b, #ffd93d);
            transition: width 0.3s ease;
        }

        .navbar-nav .nav-link:hover::after {
            width: 100%;
        }

        /* 토글 버튼 스타일 */
        .navbar-toggler {
            border-color: rgba(255, 107, 107, 0.3) !important;
        }

        .navbar-toggler-icon {
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='%23ff6b6b' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M4 7h22M4 15h22M4 23h22'/%3e%3c/svg%3e") !important;
        }

        /* 드롭다운 메뉴 스타일 */
        .dropdown-menu {
            background: var(--bg-card) !important;
            backdrop-filter: blur(10px) !important;
            border: 1px solid rgba(255, 107, 107, 0.1) !important;
            border-radius: 15px !important;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1) !important;
        }

        .dropdown-item {
            color: var(--text-secondary) !important;
            transition: all 0.3s ease !important;
        }

        .dropdown-item:hover {
            background: linear-gradient(135deg, rgba(255, 107, 107, 0.1), rgba(255, 217, 61, 0.1)) !important;
            color: #ff6b6b !important;
        }

        /* Hero Section */
        .hero {
            min-height: 110vh;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            margin-top: -80px;
            padding-top: 100px;
            color: white;
            text-align: center;
        }
        
        #hero-video {
            position: absolute;
            top: 50%;
            left: 50%;
            min-width: 100%;
            min-height: 100%;
            width: auto;
            height: auto;
            z-index: -2;
            transform: translateX(-50%) translateY(-50%);
        }
        
        .hero-video-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: -1;
        }


        @keyframes float {
            0%, 100% { transform: translateY(0px) rotate(0deg); }
            50% { transform: translateY(-30px) rotate(3deg); }
        }

        .hero-content {
            z-index: 2;
            position: relative;
            max-width: 1000px;
            margin: 0 auto;
        }

        .hero-text {
            animation: slideInLeft 1s ease-out;
        }

        @keyframes slideInLeft {
            from { opacity: 0; transform: translateX(-50px); }
            to { opacity: 1; transform: translateX(0); }
        }

        .hero-text h1 {
            font-size: 4rem;
            font-weight: 900;
            margin-bottom: 2rem;
            color: white;
            line-height: 1.1;
            letter-spacing: -0.02em;
            text-shadow: 2px 2px 6px rgba(0, 0, 0, 0.8);
        }

        .hero-text .subtitle {
            font-size: 1.4rem;
            color: white;
            margin-bottom: 2.5rem;
            line-height: 1.6;
            font-weight: 400;
            opacity: 0.95;
            text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.7);
        }

        .hero-buttons {
            display: flex;
            gap: 2rem;
            margin-bottom: 3rem;
            justify-content: center;
        }

        .primary-button {
            background: var(--gradient-accent);
            color: white;
            padding: 1rem 2.2rem;
            border: none;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 6px 20px rgba(255, 140, 0, 0.3);
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .primary-button:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 25px rgba(255, 140, 0, 0.4);
            color: white;
            text-decoration: none;
        }

        .secondary-button {
            background: rgba(255, 255, 255, 0.2);
            color: white;
            border: 1px solid white;
            padding: 1rem 2.2rem;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-block;
            text-align: center;
        }

        .secondary-button:hover {
            background: var(--bg-card);
            color: var(--primary-color);
            text-decoration: none;
        }

        .trust-indicators {
            display: flex;
            gap: 2rem;
            opacity: 0.8;
        }

        .trust-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        .hero-visual {
            position: relative;
            height: 600px;
            animation: slideInRight 1s ease-out;
        }

        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(50px); }
            to { opacity: 1; transform: translateX(0); }
        }

        .visual-container {
            position: relative;
            width: 100%;
            height: 100%;
            border-radius: 25px;
            overflow: hidden;
            background: linear-gradient(45deg, #667eea, #764ba2);
            box-shadow: 0 25px 80px rgba(0,0,0,0.15);
        }

        .floating-card {
            position: absolute;
            background: var(--bg-card);
            border-radius: 20px;
            padding: 1.5rem;
            box-shadow: 0 15px 40px rgba(0,0,0,0.15);
            backdrop-filter: blur(10px);
            animation: floatCard 8s ease-in-out infinite;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .floating-card:hover {
            transform: scale(1.05) translateY(-5px);
            box-shadow: 0 20px 50px rgba(0,0,0,0.2);
        }

        .floating-card:nth-child(1) {
            top: 15%;
            left: 10%;
            animation-delay: 0s;
        }

        .floating-card:nth-child(2) {
            top: 45%;
            right: 10%;
            animation-delay: 2.5s;
        }

        .floating-card:nth-child(3) {
            bottom: 20%;
            left: 15%;
            animation-delay: 5s;
        }

        @keyframes floatCard {
            0%, 100% { transform: translateY(0px) rotate(-1deg); }
            33% { transform: translateY(-20px) rotate(1deg); }
            66% { transform: translateY(-10px) rotate(-0.5deg); }
        }

        .card-header {
            display: flex;
            align-items: center;
            gap: 0.8rem;
            margin-bottom: 0.8rem;
        }

        .card-emoji {
            font-size: 1.5rem;
        }

        .card-title {
            font-weight: 700;
            color: var(--text-primary);
            font-size: 1rem;
        }

        .card-content {
            color: var(--text-secondary);
            font-size: 0.9rem;
            line-height: 1.4;
        }

        /* Features Section */
        .features-section {
            padding: 8rem 0;
            background: var(--bg-secondary);
            position: relative;
        }

        /* Glassmorphism Features Section */
        .glass-features-section {
            background: linear-gradient(-45deg, #e0c3fc, #8ec5fc, #e0c3fc, #8ec5fc);
            background-size: 400% 400%;
            animation: galaxyAnimate 15s ease infinite;
            padding: 8rem 0;
            position: relative;
            overflow: hidden;
            min-height: 60vh;
            display: flex;
            align-items: center;
        }

        @keyframes galaxyAnimate {
            0% {
                background-position: 0% 50%;
            }
            50% {
                background-position: 100% 50%;
            }
            100% {
                background-position: 0% 50%;
            }
        }
        
        .glass-container {
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 4rem;
        }

        .glass-container .glass {
            position: relative;
            width: 180px;
            height: 200px;
            background: linear-gradient(#fff2, transparent);
            border: 1px solid rgba(255, 255, 255, 0.1);
            box-shadow: 0 25px 25px rgba(0, 0, 0, 0.25);
            display: flex;
            justify-content: center;
            align-items: center;
            transition: 0.5s;
            border-radius: 10px;
            margin: 0 -45px;
            backdrop-filter: blur(10px);
            transform: rotate(calc(var(--r) * 1deg));
        }

        .glass-container:hover .glass {
            transform: rotate(0deg);
            margin: 0 10px;
        }

        .glass-container .glass::before {
            content: attr(data-text);
            position: absolute;
            bottom: 40px;
            width: 100%;
            height: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #000;
            font-size: 1.2em;
            font-weight: 500;
        }

        .glass-container .glass::after {
            content: attr(data-subtitle);
            position: absolute;
            bottom: 0;
            width: 100%;
            height: 40px;
            background: rgba(255, 255, 255, 0.05);
            display: flex;
            justify-content: center;
            align-items: center;
            color: #000;
            font-size: 0.8em;
            font-weight: 300;
        }
        
        .glass-container .glass svg {
            font-size: 2.5em;
            fill: #000;
        }

        .glass-features-section .section-title {
            color: #000;
        }
        
        .glass-features-section .section-subtitle {
            color: rgba(0, 0, 0, 0.8);
        }

        .section-header {
            text-align: center;
            margin-bottom: 5rem;
        }

        .section-title {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 1.5rem;
            color: var(--text-primary);
        }

        .section-subtitle {
            font-size: 1.3rem;
            color: var(--text-muted);
            max-width: 600px;
            margin: 0 auto;
            line-height: 1.6;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2rem;
            margin-top: 2rem;
        }

        .feature-card {
            background: var(--bg-light);
            border-radius: 20px;
            padding: 2rem;
            text-align: center;
            border: 1px solid #E2E8F0;
            transition: all 0.3s ease;
        }

        .feature-card:hover { 
            transform: translateY(-10px); 
            box-shadow: 0 20px 40px rgba(0,0,0,0.08); 
        }

        .feature-icon {
            display: inline-flex; 
            align-items: center; 
            justify-content: center;
            width: 70px; 
            height: 70px; 
            margin-bottom: 1.5rem;
            background: var(--gradient-primary);
            border-radius: 16px; 
            color: white;
        }
        
        .feature-icon svg { 
            width: 32px; 
            height: 32px; 
        }
        
        .feature-title { 
            font-size: 1.3rem; 
            font-weight: 700; 
            margin-bottom: 0.8rem; 
            color: var(--text-dark);
        }
        
        .feature-description { 
            color: var(--text-light); 
            font-size: 0.95rem; 
            line-height: 1.6;
        }

        /* Destinations Section - Video + Description Layout */
        #destinations { 
            background: var(--bg-light);
            padding: 3rem 0; /* 섹션 패딩 줄임 */
        }
        
        .destinations-content {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 3rem; /* gap 줄임 */
            margin-top: 2rem; /* margin 줄임 */
            align-items: center;
            max-height: 70vh; /* 최대 높이 제한 */
        }

        .destinations-video-side {
            position: relative;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
        }

        .destinations-video {
            width: 100%;
            height: 350px; /* 높이 줄임 */
            object-fit: cover;
            display: block;
        }
        /* 이미지용 클래스 추가 */
        .destinations-image {
         width: 100%;
         height: 350px;
         object-fit: cover;
         display: block;
        }
        .video-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(
                45deg, 
                rgba(99, 102, 241, 0.1) 0%, 
                rgba(168, 85, 247, 0.1) 100%
            );
            pointer-events: none;
        }

        .destinations-description-side {
            padding: 1rem 0; /* 패딩 줄임 */
        }

        .destinations-intro {
            margin-bottom: 1.5rem; /* 마진 줄임 */
        }

        .destinations-intro h3 {
            font-size: 1.5rem; /* 폰트 사이즈 줄임 */
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 0.8rem; /* 마진 줄임 */
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
            -webkit-background-clip: text;
            background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .destinations-intro p {
            font-size: 1rem; /* 폰트 사이즈 줄임 */
            color: var(--text-light);
            line-height: 1.6; /* 라인 높이 줄임 */
            margin-bottom: 1.5rem; /* 마진 줄임 */
        }

        .destinations-features {
            display: grid;
            gap: 1rem; /* gap 줄임 */
        }

        .destination-feature {
            display: flex;
            align-items: flex-start;
            gap: 0.8rem; /* gap 줄임 */
            padding: 1rem; /* 패딩 줄임 */
            background: white;
            border-radius: 12px; /* 라운드 줄임 */
            border: 1px solid #E2E8F0;
            transition: all 0.3s ease;
        }

        .destination-feature:hover {
            transform: translateX(10px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            border-color: var(--primary-color);
        }

        .feature-icon {
            width: 40px; /* 크기 줄임 */
            height: 40px; /* 크기 줄임 */
            border-radius: 10px; /* 라운드 줄임 */
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
            color: white;
            font-size: 1.3rem; /* 폰트 사이즈 줄임 */
            flex-shrink: 0;
        }

        .feature-content h4 {
            font-size: 1.1rem; /* 폰트 사이즈 줄임 */
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 0.3rem; /* 마진 줄임 */
        }

        .feature-content p {
            color: var(--text-light);
            line-height: 1.4; /* 라인 높이 줄임 */
            font-size: 0.9rem; /* 폰트 사이즈 줄임 */
        }

        .destinations-cta {
            margin-top: 1.5rem; /* 마진 줄임 */
        }

        .destinations-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 1rem 2rem;
            background: linear-gradient(135deg, var(--primary-color), var(--accent-color));
            color: white;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
        }

        .destinations-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(99, 102, 241, 0.4);
            color: white;
            text-decoration: none;
        }

        /* Mobile Responsiveness */
        @media (max-width: 768px) {
            .destinations-content {
                grid-template-columns: 1fr;
                gap: 2rem;
            }

            .destinations-video {
                height: 300px;
            }

            .destinations-intro h3 {
                font-size: 1.5rem;
            }

            .destination-feature:hover {
                transform: none;
            }
        }

        /* Testimonials Section */
        .testimonial-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); 
            gap: 2rem; 
            margin-top: 2rem;
        }
        
        .testimonial-card {
            background: var(--bg-light);
            border-radius: 16px;
            padding: 2rem;
            border: 1px solid #E2E8F0;
            transition: all 0.3s ease;
        }
        
        .testimonial-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.08);
        }
        
        .testimonial-card p { 
            font-style: italic; 
            color: var(--text-light); 
            margin-bottom: 1.5rem; 
            line-height: 1.6;
            font-size: 0.95rem;
        }
        
        .user-info { 
            display: flex; 
            align-items: center; 
            gap: 1rem; 
        }
        
        .user-avatar { 
            width: 50px; 
            height: 50px; 
            border-radius: 50%; 
            object-fit: cover; 
        }
        
        .user-details h4 { 
            font-weight: 700; 
            margin-bottom: 0.3rem;
            color: var(--text-dark);
        }
        
        .user-details span { 
            color: var(--text-muted); 
            font-size: 0.9rem; 
        }

        .feature-tags {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .feature-tag {
            background: linear-gradient(135deg, #ff6b6b, #ff8e53);
            color: white;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        /* Community Section */
        .community-section {
            padding: 8rem 0;
            background: var(--bg-primary);
        }

        .community-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2.5rem;
            margin-top: 4rem;
        }

        .community-card {
            background: var(--bg-card);
            border-radius: 20px;
            padding: 2rem;
            border: 1px solid #e2e8f0;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .community-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #ff6b6b, #ffd93d);
        }

        .community-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 50px rgba(0,0,0,0.1);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .user-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff6b6b, #ffd93d);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 700;
            font-size: 1.3rem;
        }

        .user-details h4 {
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.3rem;
        }

        .user-location {
            color: var(--text-muted);
            font-size: 0.9rem;
        }

        .travel-story {
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 1rem;
            font-style: italic;
        }

        .story-tags {
            display: flex;
            gap: 0.5rem;
            flex-wrap: wrap;
        }

        .story-tag {
            background: linear-gradient(135deg, #ff6b6b, #ff8e53);
            color: white;
            padding: 0.3rem 0.8rem;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        /* Get Started Section (NEW) */
        .steps-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2.5rem;
            margin-top: 2rem;
            text-align: center;
        }
        .step-item .step-icon {
            width: 80px; 
            height: 80px;
            background: linear-gradient(to right, #e0c3fc, #8ec5fc);
            color: white;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
            font-size: 2rem;
            font-weight: 700;
        }
        .step-item h3 { 
            font-size: 1.3rem; 
            margin-bottom: 0.8rem; 
            color: var(--text-dark);
        }
        .step-item p { 
            color: var(--text-light); 
            line-height: 1.6;
            font-size: 0.95rem;
        }

        /* Community Preview Section (NEW) */
        #community { background: var(--bg-light); }
        .post-list {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1.2rem;
            max-width: 750px;
            margin: 2rem auto 0;
        }
        .post-item {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            padding: 1.5rem;
            background: var(--bg-card);
            border-radius: 12px;
            border: 1px solid #E2E8F0;
            transition: all 0.3s ease;
            text-decoration: none;
            color: var(--text-dark);
        }
        .post-item:hover { 
            transform: translateY(-3px); 
            box-shadow: 0 10px 25px rgba(0,0,0,0.08); 
            text-decoration: none;
            color: var(--text-dark);
        }
        .post-item img { 
            width: 75px; 
            height: 75px; 
            object-fit: cover; 
            border-radius: 8px; 
        }
        .post-content h4 { 
            font-size: 1rem; 
            margin-bottom: 0.5rem; 
            line-height: 1.4;
        }
        .post-meta { 
            font-size: 0.85rem; 
            color: var(--text-muted); 
        }
        .post-meta .post-tag { 
            background: var(--bg-accent); 
            color: #805AD5; 
            padding: 0.3rem 0.7rem; 
            border-radius: 6px; 
            font-weight: 600; 
            margin-right: 0.5rem;
        }
        .community-cta { 
            text-align: center; 
            margin-top: 2.5rem; 
        }

        /* Final CTA Section */
        .final-cta { 
            background: var(--gradient-primary); 
            color: white; 
            text-align: center; 
            border-radius: 20px; 
            padding: 4rem 2rem; 
            max-width: 900px; 
            margin: 0 auto;
        }
        
        .final-cta h2 {
            font-size: 2.2rem;
            font-weight: 800;
            margin-bottom: 1rem;
            line-height: 1.3;
        }
        
        .final-cta p {
            font-size: 1.1rem;
            margin-bottom: 2rem;
            opacity: 0.9;
            line-height: 1.5;
        }



        .final-cta .primary-button {
            background: var(--bg-card);
            color: var(--primary-color);
            box-shadow: 0 8px 30px rgba(255,255,255,0.3);
        }

        .final-cta .primary-button:hover {
            transform: translateY(-4px);
            box-shadow: 0 15px 50px rgba(255,255,255,0.4);
            color: var(--primary-color);
        }

        /* Animations */
        .fade-in-up {
            opacity: 0;
            transform: translateY(30px);
            transition: opacity 0.6s ease-out, transform 0.6s ease-out;
        }
        .fade-in-up.visible { 
            opacity: 1; 
            transform: translateY(0); 
        }
        
        /* Responsive Design */
        @media (max-width: 1024px) {
            .container-custom {
                padding: 0 1.5rem;
            }
            
            .section {
                padding: 4rem 0;
            }
            
            .features-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 2rem;
            }
            
            .destination-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 2rem;
            }
            
            .testimonial-grid {
                gap: 2rem;
            }
        }
        
        @media (max-width: 768px) {
            .container-custom {
                padding: 0 1rem;
            }
            
            .section {
                padding: 3rem 0;
            }
            
            .section-header {
                margin-bottom: 2.5rem;
            }
            
            .section-title { 
                font-size: 2rem; 
                margin-bottom: 1rem;
            }
            
            .section-subtitle {
                font-size: 1rem;
            }
            
            .features-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 1.5rem;
                margin-top: 1.5rem;
            }
            
            .destination-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
                margin-top: 1.5rem;
            }
            
            .testimonial-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
                margin-top: 1.5rem;
            }
            
            .steps-container {
                gap: 2rem;
                margin-top: 1.5rem;
            }
            
            .final-cta {
                padding: 3rem 1.5rem;
                margin: 0 1rem;
            }
            
            .final-cta h2 {
                font-size: 1.8rem;
            }
            
            .destination-card {
                height: 300px;
            }
            
            .post-item {
                flex-direction: column;
                text-align: center;
                gap: 1rem;
            }
            
            .post-item img {
                width: 100%;
                height: 150px;
            }
        }
        
        @media (max-width: 480px) {
            .section {
                padding: 2.5rem 0;
            }
            
            .section-title {
                font-size: 1.8rem;
            }
            
            .features-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
            
            .feature-card,
            .testimonial-card {
                padding: 1.5rem;
            }
            
            .final-cta {
                padding: 2.5rem 1rem;
            }
        }

    </style>
</head>
<body>
    <%@ include file="common/header.jsp" %>

    <!-- Hero Section - plan3.html 스타일 with 비디오 배경 -->
    <section class="hero">
        <video autoplay muted loop playsinline id="hero-video">
            <source src="/resources/videos/2169880-uhd_2560_1440_30fps.mp4" type="video/mp4">
        </video>
        <div class="hero-video-overlay"></div>
        <div class="container-custom hero-content">
            <h1>당신의 완벽한 여행 동반자를 AI로 만나다</h1>
            <p>취향, 스타일, 일정까지 맞춘 여행 메이트와 함께 잊지 못할 여정을 시작하세요!</p>
            <div class="hero-buttons">
                <c:choose>
                    <c:when test="${not empty sessionScope.loginUser}">
                        <a href="${pageContext.request.contextPath}/travel/create" class="primary-button">지금 매칭 시작하기</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/member/login?mode=signup" class="primary-button">지금 매칭 시작하기</a>
                    </c:otherwise>
                </c:choose>
                <a href="#features" class="secondary-button">플랫폼 둘러보기</a>
            </div>
        </div>
    </section>

<!-- Features Section - plan3.html 스타일 -->
    <section id="features" class="section glass-features-section">
        <div class="container-custom">
            <div class="section-header fade-in-up">
                <h2 class="section-title">AI 여행 어시스턴트</h2>
                <p class="section-subtitle">똑똑한 AI가 여행의 모든 순간을 도와드립니다</p>
            </div>
            <div class="glass-container">
                <div data-text="MBTI 매칭" data-subtitle="성향 기반 동반자 찾기" style="--r:-15;" class="glass">
                    <svg viewBox="0 0 640 512" height="1em" xmlns="http://www.w3.org/2000/svg">
                        <path d="M320 0c17.7 0 32 14.3 32 32V96H472c39.8 0 72 32.2 72 72V440c0 39.8-32.2 72-72 72H168c-39.8 0-72-32.2-72-72V168c0-39.8 32.2-72 72-72H288V32c0-17.7 14.3-32 32-32zM208 384c-8.8 0-16 7.2-16 16s7.2 16 16 16h32c8.8 0 16-7.2 16-16s-7.2-16-16-16H208zm96 0c-8.8 0-16 7.2-16 16s7.2 16 16 16h32c8.8 0 16-7.2 16-16s-7.2-16-16-16H304zm96 0c-8.8 0-16 7.2-16 16s7.2 16 16 16h32c8.8 0 16-7.2 16-16s-7.2-16-16-16H400zM264 256a40 40 0 1 0 -80 0 40 40 0 1 0 80 0zm152 40a40 40 0 1 0 0-80 40 40 0 1 0 0 80zM48 224H64V416H48c-26.5 0-48-21.5-48-48V272c0-26.5 21.5-48 48-48zm544 0c26.5 0 48 21.5 48 48v96c0 26.5-21.5 48-48 48H576V224h16z" fill="#000"/>
                    </svg>
                </div>
                
                <div data-text="패킹 어시스턴트" data-subtitle="스마트 짐 준비 도움" style="--r:5;" class="glass">
                    <svg viewBox="0 0 512 512" height="1em" xmlns="http://www.w3.org/2000/svg">
                        <path d="M190.5 68.8L225.3 128H224 152c-22.1 0-40-17.9-40-40s17.9-40 40-40h2.2c14.9 0 28.8 7.9 36.3 20.8zM64 88c0 14.4 3.5 28 9.6 40H32c-17.7 0-32 14.3-32 32v64c0 17.7 14.3 32 32 32H480c17.7 0 32-14.3 32-32V160c0-17.7-14.3-32-32-32H438.4c6.1-12 9.6-25.6 9.6-40c0-48.6-39.4-88-88-88h-2.2c-31.9 0-61.5 16.9-77.7 44.4L256 85.5l-24.1-41C215.7 16.9 186.1 0 154.2 0H152C103.4 0 64 39.4 64 88zm336 200v32c0 6.4-6.4 12-12 12H124c-6.4 0-12-5.6-12-12V288H64v144c0 26.5 21.5 48 48 48H400c26.5 0 48-21.5 48-48V288H400z" fill="#000"/>
                    </svg>
                </div>
                
                <div data-text="지도 기반 계획" data-subtitle="위치 기반 추천 모델" style="--r:25;" class="glass">
                    <svg viewBox="0 0 576 512" height="1em" xmlns="http://www.w3.org/2000/svg">
                        <path d="M408 120c0 54.6-73.1 151.9-105.2 192c-7.7 9.6-22 9.6-29.6 0C241.1 271.9 168 174.6 168 120C168 53.7 221.7 0 288 0s120 53.7 120 120zm8 80.4c3.5-6.9 6.7-13.8 9.6-20.6c.5-1.2 1-2.5 1.5-3.7l116-46.4C558.9 123.4 576 135 576 152V422.8c0 9.8-6 18.6-15.1 22.3L416 503V200.4zM137.6 138.3c2.4 14.1 7.2 28.3 12.8 41.5c2.9 6.8 6.1 13.7 9.6 20.6V451.8L32.9 502.7C17.1 509 0 497.4 0 480.4V209.6c0-9.8 6-18.6 15.1-22.3l122.6-49zM327.8 332c13.9-17.4 35.7-45.7 56.2-77V504.3L192 449.4V255c20.5 31.3 42.3 59.6 56.2 77c20.5 25.6 59.1 25.6 79.6 0zM288 152c22.1 0 40-17.9 40-40s-17.9-40-40-40s-40 17.9-40 40s17.9 40 40 40z" fill="#000"/>
                    </svg>
                </div>
                
                <div data-text="여행 플레이리스트" data-subtitle="분위기별 음악 추천" style="--r:-5;" class="glass">
                    <svg viewBox="0 0 512 512" height="1em" xmlns="http://www.w3.org/2000/svg">
                        <path d="M499.1 6.3c8.1 6 12.9 15.6 12.9 25.7v72V368c0 44.2-43 80-96 80s-96-35.8-96-80s43-80 96-80c11.2 0 22 1.6 32 4.6V147L192 223.8V432c0 44.2-43 80-96 80s-96-35.8-96-80s43-80 96-80c11.2 0 22 1.6 32 4.6V200 128c0-14.1 9.3-26.6 22.8-30.7l320-96c9.7-2.9 20.2-1.1 28.3 5z" fill="#000"/>
                    </svg>
                    </svg>
                </div>

                <div data-text="AI 채팅 모델" data-subtitle="통합 여행 어시스턴트" style="--r:15;" class="glass">
                    <svg viewBox="0 0 512 512" height="1em" xmlns="http://www.w3.org/2000/svg">
                        <path d="M123.6 391.3c12.9-9.4 29.6-11.8 44.6-6.4c26.5 9.6 56.2 15.1 87.8 15.1c124.7 0 208-80.5 208-160s-83.3-160-208-160S48 160.5 48 240c0 32 12.4 62.8 35.7 89.2c8.6 9.7 12.8 22.5 11.8 35.5c-1.4 18.1-5.7 34.7-11.3 49.4c17-7.9 33.5-16.7 48.9-26.8zM464 352c-16.1 10.1-32.5 18.9-49.5 26.8c-5.6-14.7-9.9-31.3-11.3-49.4c-1-13.1 3.2-25.9 11.8-35.5c23.3-26.4 35.7-57.2 35.7-89.2c0-79.5-83.3-160-208-160S48 160.5 48 240s83.3 160 208 160c31.6 0 61.3-5.5 87.8-15.1c15-5.4 31.7-3.1 44.6 6.4c15.4 10.1 31.8 18.9 48.9 26.8c2.2 1 4.6 1.9 7.1 2.8c2.5 .9 5.2 1.4 7.9 1.4c11.9 0 21.6-9.7 21.6-21.6c0-7.2-3.6-13.5-9.1-17.3c-2.7-1.9-5.2-4.1-7.5-6.6c-1.1-1.2-2.1-2.4-3-3.7z" fill="#000"/>
                    </svg>
                </div>
            </div>
        </div>
    </section>
    <!-- AI Travel Features Timeline Section - Identical to 타임라인.html -->
    <section id="ai-features" class="section">
        <div class="timeline-container">
            <div class="timeline-header">
                <h2 class="timeline-title">사이트 이용방법</h2>
                <p class="timeline-subtitle">5단계로 완성하는 완벽한 여행 경험</p>
            </div>

            <div class="timeline-content">
                <div class="timeline-line"></div>
                <div class="timeline-progress" id="progressLine"></div>
                <div class="timeline-comet" id="comet"></div>

                <div class="timeline-events" id="timelineEvents">
                    <!-- Step 1 -->
                    <div class="timeline-event">
                        <div class="timeline-dot" data-index="0"></div>
                        <div class="timeline-card parallax" data-index="0">
                            <div class="timeline-date">
                                <svg class="timeline-icon" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zM4 8h12v8H4V8z"/>
                                </svg>
                                Step 1
                            </div>
                            <h3 class="timeline-card-title">회원가입 & MBTI 설정</h3>
                            <p class="timeline-card-subtitle">시작하기</p>
                            <p class="timeline-card-description">로그인 및 회원가입을 하고 여행 MBTI 테스트를 통해 당신의 여행 성향을 설정하세요.</p>
                        </div>
                    </div>

                    <!-- Step 2 -->
                    <div class="timeline-event">
                        <div class="timeline-dot" data-index="1"></div>
                        <div class="timeline-card parallax" data-index="1">
                            <div class="timeline-date">
                                <svg class="timeline-icon" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zM4 8h12v8H4V8z"/>
                                </svg>
                                Step 2
                            </div>
                            <h3 class="timeline-card-title">AI 추천 서비스 이용</h3>
                            <p class="timeline-card-subtitle">맞춤 추천</p>
                            <p class="timeline-card-description">매칭 시작을 눌러 동반자 추천을 받거나 여행계획, 준비물, 음악 등 AI 추천을 받아보세요.</p>
                        </div>
                    </div>

                    <!-- Step 3 -->
                    <div class="timeline-event">
                        <div class="timeline-dot" data-index="2"></div>
                        <div class="timeline-card parallax" data-index="2">
                            <div class="timeline-date">
                                <svg class="timeline-icon" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zM4 8h12v8H4V8z"/>
                                </svg>
                                Step 3
                            </div>
                            <h3 class="timeline-card-title">여행계획 등록</h3>
                            <p class="timeline-card-subtitle">계획 공유</p>
                            <p class="timeline-card-description">나만의 여행계획을 등록하고 동행을 원하는 여행자들과 연결되세요.</p>
                        </div>
                    </div>

                    <!-- Step 4 -->
                    <div class="timeline-event">
                        <div class="timeline-dot" data-index="3"></div>
                        <div class="timeline-card parallax" data-index="3">
                            <div class="timeline-date">
                                <svg class="timeline-icon" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zM4 8h12v8H4V8z"/>
                                </svg>
                                Step 4
                            </div>
                            <h3 class="timeline-card-title">동행자 매칭 & 채팅</h3>
                            <p class="timeline-card-subtitle">소통하기</p>
                            <p class="timeline-card-description">매칭된 동행자와 채팅을 통해 세부 계획을 조율하고 여행 준비를 함께 하세요.</p>
                        </div>
                    </div>

                    <!-- Step 5 -->
                    <div class="timeline-event">
                        <div class="timeline-dot" data-index="4"></div>
                        <div class="timeline-card parallax" data-index="4">
                            <div class="timeline-date">
                                <svg class="timeline-icon" fill="currentColor" viewBox="0 0 20 20">
                                    <path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zM4 8h12v8H4V8z"/>
                                </svg>
                                Step 5
                            </div>
                            <h3 class="timeline-card-title">여행 완료 & 평가</h3>
                            <p class="timeline-card-subtitle">신뢰도 구축</p>
                            <p class="timeline-card-description">즐거운 여행을 마친 후 서로의 매너를 평가하여 신뢰도를 쌓고 더 좋은 매칭을 받으세요.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <style>
            /* Timeline Styles - Exact Copy from 타임라인.html */
            #ai-features {
                --primary: #6366f1;
                --primary-light: #818cf8;
                --primary-dark: #4f46e5;
                --gradient-start: #22d3ee;
                --gradient-mid: #6366f1;
                --gradient-end: #a855f7;
                --background: #ffffff;
                --foreground: #0f172a;
                --card-bg: #ffffff;
                --muted: #64748b;
                --border: #e2e8f0;
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                background-color: var(--background);
                color: var(--foreground);
                overflow-x: hidden;
                padding: 30px 0;
            }

            #ai-features .timeline-container {
                position: relative;
                min-height: 60vh;
                width: 100%;
            }

            #ai-features .timeline-header {
                text-align: center;
                padding: 40px 16px;
            }

            #ai-features .timeline-title {
                font-size: 2.5rem;
                font-weight: bold;
                margin-bottom: 12px;
                background: linear-gradient(135deg, var(--gradient-mid), var(--gradient-end));
                -webkit-background-clip: text;
                background-clip: text;
                -webkit-text-fill-color: transparent;
            }

            #ai-features .timeline-subtitle {
                font-size: 1rem;
                color: var(--muted);
                max-width: 48rem;
                margin: 0 auto;
            }

            #ai-features .timeline-content {
                position: relative;
                max-width: 72rem;
                margin: 0 auto;
                padding: 0 16px 50px;
            }

            #ai-features .timeline-line {
                position: absolute;
                left: 50%;
                transform: translateX(-50%);
                width: 2px;
                height: 100%;
                background-color: rgba(99, 102, 241, 0.3);
                z-index: 10;
            }

            #ai-features .timeline-progress {
                position: absolute;
                left: 50%;
                transform: translateX(-50%);
                width: 2px;
                height: 0; /* 초기 높이 설정 */
                background: linear-gradient(to bottom, var(--gradient-start), var(--gradient-mid), var(--gradient-end));
                box-shadow: 
                    0 0 15px rgba(99, 102, 241, 0.5),
                    0 0 25px rgba(168, 85, 247, 0.3);
                z-index: 15;
                transition: height 0.3s ease;
                border-radius: 9999px;
            }

            #ai-features .timeline-comet {
                position: absolute;
                left: 50%;
                top: 0; /* 초기 위치 설정 */
                transform: translateX(-50%) translateY(-50%);
                width: 20px;
                height: 20px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(168, 85, 247, 0.8) 0%, rgba(99, 102, 241, 0.5) 40%, rgba(34, 211, 238, 0) 70%);
                box-shadow: 
                    0 0 15px 4px rgba(168, 85, 247, 0.6),
                    0 0 25px 8px rgba(99, 102, 241, 0.4),
                    0 0 40px 15px rgba(34, 211, 238, 0.2);
                z-index: 20;
                animation: aiTimelinePulse 2s ease-in-out infinite;
                transition: top 0.3s ease;
            }

            @keyframes aiTimelinePulse {
                0%, 100% {
                    transform: translateX(-50%) translateY(-50%) scale(1);
                }
                50% {
                    transform: translateX(-50%) translateY(-50%) scale(1.3);
                }
            }

            #ai-features .timeline-events {
                position: relative;
                z-index: 20;
            }

            #ai-features .timeline-event {
                position: relative;
                display: flex;
                align-items: center;
                margin-bottom: 50px;
                padding: 12px 0;
                opacity: 0;
                transform: translateY(20px);
                animation: aiTimelineFadeInUp 0.7s ease forwards;
            }

            #ai-features .timeline-event:nth-child(even) {
                flex-direction: row-reverse;
            }

            @keyframes aiTimelineFadeInUp {
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            #ai-features .timeline-event:nth-child(1) { animation-delay: 0.1s; }
            #ai-features .timeline-event:nth-child(2) { animation-delay: 0.3s; }
            #ai-features .timeline-event:nth-child(3) { animation-delay: 0.5s; }
            #ai-features .timeline-event:nth-child(4) { animation-delay: 0.7s; }
            #ai-features .timeline-event:nth-child(5) { animation-delay: 0.9s; }

            #ai-features .timeline-dot {
                position: absolute;
                left: 50%;
                top: 50%;
                transform: translate(-50%, -50%);
                width: 24px;
                height: 24px;
                border-radius: 50%;
                border: 4px solid var(--primary);
                background-color: var(--background);
                z-index: 30;
                transition: all 0.3s ease;
            }

            #ai-features .timeline-dot.active {
                animation: aiTimelineDotPulse 0.8s ease;
            }

            @keyframes aiTimelineDotPulse {
                0%, 100% {
                    transform: translate(-50%, -50%) scale(1);
                    box-shadow: 0 0 0px rgba(99, 102, 241, 0);
                }
                50% {
                    transform: translate(-50%, -50%) scale(1.3);
                    box-shadow: 0 0 12px rgba(99, 102, 241, 0.6);
                }
            }

            #ai-features .timeline-card {
                width: calc(50% - 40px);
                background: var(--card-bg);
                border: 1px solid var(--border);
                border-radius: 8px;
                padding: 18px;
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                transition: all 0.3s ease;
                position: relative;
            }

            #ai-features .timeline-event:nth-child(odd) .timeline-card {
                margin-right: auto;
            }

            #ai-features .timeline-event:nth-child(even) .timeline-card {
                margin-left: auto;
            }

            #ai-features .timeline-card:hover {
                transform: translateY(-4px);
                box-shadow: 
                    0 10px 25px rgba(0, 0, 0, 0.1),
                    0 0 15px rgba(99, 102, 241, 0.2);
            }

            #ai-features .timeline-date {
                display: inline-flex;
                align-items: center;
                margin-bottom: 8px;
                color: var(--primary);
                font-weight: bold;
                font-size: 0.875rem;
            }

            #ai-features .timeline-icon {
                width: 16px;
                height: 16px;
                margin-right: 8px;
            }

            #ai-features .timeline-card-title {
                font-size: 1.25rem;
                font-weight: bold;
                margin-bottom: 4px;
                color: var(--foreground);
            }

            #ai-features .timeline-card-subtitle {
                color: var(--muted);
                font-weight: 500;
                margin-bottom: 8px;
            }

            #ai-features .timeline-card-description {
                color: var(--muted);
                line-height: 1.6;
            }

            #ai-features .ai-cta-section {
                text-align: center;
                padding: 2rem 0;
                display: flex;
                gap: 1rem;
                justify-content: center;
                flex-wrap: wrap;
            }

            /* Mobile Responsive */
            @media (max-width: 768px) {
                #ai-features .timeline-title {
                    font-size: 2rem;
                }

                #ai-features .timeline-event {
                    flex-direction: column !important;
                }

                #ai-features .timeline-card {
                    width: 100%;
                    margin-top: 48px !important;
                    margin-left: 0 !important;
                    margin-right: 0 !important;
                }

                #ai-features .timeline-dot {
                    top: 24px;
                }
                
                #ai-features .ai-cta-section {
                    flex-direction: column;
                    align-items: center;
                }
            }

            /* Parallax effect */
            #ai-features .parallax {
                transition: transform 0.3s ease-out;
            }
        </style>

        <!-- External JavaScript file for timeline functionality -->
        <script src="${pageContext.request.contextPath}/resources/js/home-timeline.js"></script>

        <!-- JavaScript moved to external file: /resources/js/home-timeline.js -->
    </section>
    <!-- Popular Destinations Section -->
    <section id="destinations" class="section">
        <div class="container-custom">
            <div class="section-header fade-in-up">
                <h2 class="section-title">지금 뜨는 여행지로 떠나볼까요?</h2>
                <p class="section-subtitle">AI가 분석한 트렌드와 당신의 취향을 바탕으로 최고의 여행지를 추천합니다.</p>
            </div>
            <div class="destinations-content">
                <div class="destinations-video-side">
                    <img src="/resources/img/ai.png" alt="AI 여행 매칭" class="destinations-image">
                    <div class="video-overlay"></div>
                </div>

                <div class="destinations-description-side">
                    <div class="destinations-intro">
                        <h3>세계를 탐험하고 경험을 나누세요</h3>
                        <p>AI 기반 맞춤 매칭으로 당신과 완벽하게 어울리는 여행 동반자를 찾아보세요. 안전하고 즐거운 여행을 위한 모든 것이 준비되어 있습니다.</p>
                    </div>

                    <div class="destinations-features">
                        <div class="destination-feature">
                            <div class="feature-icon">🎯</div>
                            <div class="feature-content">
                                <h4>여행 MBTI</h4>
                                <p>취향, 성격, 여행 스타일을 종합 분석하여 최적의 동반자 및 여행지를 추천합니다.</p>
                            </div>
                        </div>

                        <div class="destination-feature">
                            <div class="feature-icon">🛡️</div>
                            <div class="feature-content">
                                <h4>안전한 소통 환경</h4>
                                <p>신원 확인과 안전 채팅을 통해 믿을 만한 여행 파트너만 만날 수 있습니다.</p>
                            </div>
                        </div>

                        <div class="destination-feature">
                            <div class="feature-icon">🌏</div>
                            <div class="feature-content">
                                <h4>전 세계 여행지</h4>
                                <p>국내외 인기 여행지부터 숨겨진 명소까지, 어디든 함께할 동반자를 찾아보세요.</p>
                            </div>
                        </div>

                    </div>

                    <div class="destinations-cta">
                        <c:choose>
                            <c:when test="${not empty sessionScope.loginUser}">
                                <a href="${pageContext.request.contextPath}/travel/create" class="destinations-btn">
                                    지금 여행 동반자 찾기 →
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/member/login?mode=signup" class="destinations-btn">
                                    지금 여행 동반자 찾기 →
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Testimonials Slider Section -->
    <section id="testimonials" class="section">
        <div class="container-custom">
            <div class="section-header fade-in-up">
                <h2 class="section-title">함께한 여행자들의 이야기</h2>
                <p class="section-subtitle">Wanderlust를 통해 특별한 인연을 만난 사람들의 생생한 후기를 확인하세요.</p>
            </div>
            
            <div class="testimonial-slider-wrapper">
                <div
                    class="testimonial-slider"
                    style="--width: 300px;
                    --height: 200px;
                    --quantity: 6;"
                >
                    <div class="testimonial-list">
                        <div class="testimonial-item" style="--position: 1">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #ff7e5f, #feb47b)">
                                <p>"AI 덕분에 저와 취향이 정말 비슷한 친구를 만나 유럽 여행을 완벽하게 즐겼어요!"</p>
                                <div class="slide-author">지수, 28세 - 디자이너</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 2">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #6a11cb, #2575fc)">
                                <p>"계획적인 저(ISTJ)와 즉흥적인 동행(ENFP)의 만남! 결과는 대성공!"</p>
                                <div class="slide-author">민준, 31세 - 개발자</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 3">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #00c6ff, #0072ff)">
                                <p>"안전 채팅으로 충분히 대화하고 만나니 안심됐어요. 최고의 여행 버디가 되었답니다!"</p>
                                <div class="slide-author">서연, 26세 - 대학생</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 4">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #ff512f, #dd2476)">
                                <p>"혼자 여행하기 무서웠는데, 믿을 만한 동행자를 만나 안전하게 즐겼어요!"</p>
                                <div class="slide-author">현우, 29세 - 마케터</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 5">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #ffb6c1, #ff69b4)">
                                <p>"여행 MBTI 덕분에 성향이 잘 맞는 분과 만나 편안한 여행을 했어요!"</p>
                                <div class="slide-author">소영, 25세 - 간호사</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 6">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #84fab0, #8fd3f4)">
                                <p>"AI 추천 덕분에 새로운 친구도 만들고 숨겨진 명소도 발견했어요!"</p>
                                <div class="slide-author">태민, 33세 - 사진작가</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div
                    class="testimonial-slider"
                    reverse="true"
                    style="--width: 300px;
                    --height: 200px;
                    --quantity: 6;"
                >
                    <div class="testimonial-list">
                        <div class="testimonial-item" style="--position: 1">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #a1c4fd, #c2e9fb)">
                                <p>"커뮤니티에서 여행 팁을 얻고, 실제 여행에서 큰 도움이 되었어요!"</p>
                                <div class="slide-author">예린, 27세 - 교사</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 2">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #fbc2eb, #a18cd1)">
                                <p>"매너온도 시스템 덕분에 안전하고 즐거운 만남이 가능했어요!"</p>
                                <div class="slide-author">도현, 30세 - 공무원</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 3">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #ff9a8b, #ffc3a0)">
                                <p>"일정 플래너로 체계적으로 계획세워서 알찬 여행이 되었습니다!"</p>
                                <div class="slide-author">수진, 26세 - 회계사</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 4">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #667eea, #764ba2)">
                                <p>"같은 관심사를 가진 분들과 만나 의미있는 여행을 할 수 있었어요!"</p>
                                <div class="slide-author">진호, 32세 - 엔지니어</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 5">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #f093fb, #f5576c)">
                                <p>"처음 해외여행이었는데 경험 많은 동행자와 함께해서 든든했어요!"</p>
                                <div class="slide-author">은지, 24세 - 학생</div>
                            </div>
                        </div>
                        <div class="testimonial-item" style="--position: 6">
                            <div class="testimonial-slide" style="background: linear-gradient(to right, #4facfe, #00f2fe)">
                                <p>"비슷한 예산대에서 여행하는 분과 만나 부담없이 즐겼습니다!"</p>
                                <div class="slide-author">성민, 28세 - 디자이너</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <style>
            /* Testimonials Slider Styles */
            #testimonials .testimonial-slider-wrapper {
                display: flex;
                flex-direction: column;
                gap: 40px;
                margin-top: 3rem;
                padding: 2rem 0;
            }

            #testimonials .testimonial-slide {
                width: 100%;
                height: 100%;
                padding: 20px;
                border: 1px solid #ccc;
                border-radius: 12px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                color: white;
                text-align: center;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                box-sizing: border-box;
                transition: transform 0.3s ease;
            }

            #testimonials .testimonial-slide p {
                font-size: 15px;
                color: white;
                margin: 0 0 15px 0;
                line-height: 1.5;
                font-weight: 400;
            }

            #testimonials .slide-author {
                font-size: 12px;
                color: rgba(255, 255, 255, 0.9);
                font-weight: 600;
                margin-top: auto;
            }

            #testimonials .testimonial-slider {
                width: 100%;
                height: var(--height);
                overflow: hidden;
                mask-image: linear-gradient(to right, transparent, #000 10% 90%, transparent);
                margin-bottom: 20px;
            }
            
            #testimonials .testimonial-list {
                display: flex;
                width: 100%;
                min-width: calc(var(--width) * var(--quantity));
                position: relative;
            }
            
            #testimonials .testimonial-item {
                width: var(--width);
                height: var(--height);
                position: absolute;
                left: 100%;
                animation: autoRun 12s linear infinite;
                transition: filter 0.5s;
                animation-delay: calc((12s / var(--quantity)) * (var(--position) - 1) - 12s);
            }
            
            @keyframes autoRun {
                from {
                    left: 100%;
                }
                to {
                    left: calc(var(--width) * -1);
                }
            }
            
            #testimonials .testimonial-slider:hover .testimonial-item {
                animation-play-state: paused !important;
                filter: grayscale(0.7);
            }
            
            #testimonials .testimonial-item:hover {
                filter: grayscale(0) !important;
                transform: scale(1.05);
            }
            
            /* Reverse direction slider */
            #testimonials .testimonial-slider[reverse="true"] .testimonial-item {
                animation: reversePlay 12s linear infinite;
                animation-delay: calc((12s / var(--quantity)) * (var(--position) - 1) - 12s);
            }
            
            @keyframes reversePlay {
                from {
                    left: calc(var(--width) * -1);
                }
                to {
                    left: 100%;
                }
            }

            /* Responsive Design */
            @media (max-width: 768px) {
                #testimonials .testimonial-slider-wrapper {
                    gap: 20px;
                }

                #testimonials .testimonial-slider {
                    --width: 250px !important;
                    --height: 180px !important;
                }

                #testimonials .testimonial-slide {
                    padding: 15px;
                }

                #testimonials .testimonial-slide p {
                    font-size: 13px;
                }

                #testimonials .slide-author {
                    font-size: 11px;
                }
            }

            @media (max-width: 480px) {
                #testimonials .testimonial-slider {
                    --width: 200px !important;
                    --height: 160px !important;
                }

                #testimonials .testimonial-slide {
                    padding: 12px;
                }

                #testimonials .testimonial-slide p {
                    font-size: 12px;
                }
            }
        </style>
    </section>

    <!-- Community Preview Section -->
    <section id="community" class="section">
        <div class="container-custom">
            <div class="section-header fade-in-up">
                <h2 class="section-title">여행자들의 생생한 소통</h2>
                <p class="section-subtitle">실시간으로 올라오는 여행 팁과 질문들을 보며 다음 여행을 준비해보세요.</p>
            </div>
            <div class="post-list fade-in-up">
                <a href="/board/list" class="post-item">
                    <img src="https://images.unsplash.com/photo-1528164344705-47542687000d?q=80&w=200" alt="Post thumbnail">
                    <div class="post-content">
                        <h4><span class="post-tag">여행 팁</span> 일본 현지인만 아는 라멘 맛집 리스트 공유합니다!</h4>
                        <div class="post-meta">by 라멘마스터 · 5분 전</div>
                    </div>
                </a>
                <a href="/board/list" class="post-item">
                    <img src="https://images.unsplash.com/photo-1746238737644-77e26f167afb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDJ8fHxlbnwwfHx8fHw%3D" alt="Post thumbnail">
                    <div class="post-content">
                        <h4><span class="post-tag">질문</span> 7월에 베트남 다낭 가는데, 여자 혼자 괜찮을까요?</h4>
                        <div class="post-meta">by 처음여행러 · 23분 전</div>
                    </div>
                </a>
                <a href="/board/list" class="post-item">
                    <img src="data:image/jpeg;base64,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" alt="Post thumbnail">
                    <div class="post-content">
                        <h4><span class="post-tag">후기</span> 이번에 매칭된 분이랑 스위스 다녀온 후기 (사진 많음)</h4>
                        <div class="post-meta">by 그린델발트 · 1시간 전</div>
                    </div>
                </a>
            </div>
            <div class="community-cta fade-in-up">
                <a href="/board/list" class="primary-button">커뮤니티 참여하기</a>
            </div>
        </div>
    </section>

    <!-- Final CTA -->
    <section class="section">
        <div class="container-custom">
            <div class="final-cta fade-in-up">
                 <h2>지금 당신의 여행을 시작하세요!</h2>
                 <p style="color:white; opacity:0.8; margin-bottom: 2rem;">완벽한 동행자와 함께 만들 잊지 못할 추억이 기다리고 있습니다.</p>
                 <c:choose>
                    <c:when test="${not empty sessionScope.loginUser}">
                        <a href="${pageContext.request.contextPath}/travel/list" class="primary-button">여행 계획 보기</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/member/login" class="primary-button">무료로 시작하기</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>

    <%@ include file="common/footer.jsp" %>

    <!-- Fade-in animation logic included in home-timeline.js -->
</body>
</html>