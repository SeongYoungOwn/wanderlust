<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="com.tour.project.dto.MemberDTO" %>
<%
    MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="../common/head.jsp" %>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/enhanced-packing-ui.css">
    <title>AI Model Companion - AI 여행 동행 매칭 플랫폼</title>
    <style>
        /* Google Fonts: Poppins */
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap');

        :root {
            --bg-color: #0a0620;
            --bg-gradient: linear-gradient(180deg, #0a0620 0%, #1a0b3d 40%, #2d1654 80%, #1a0b3d 100%);
            --card-bg-color: rgba(25, 20, 60, 0.5);
            --card-border-color: rgba(139, 92, 246, 0.1);
            --text-primary: #FFFFFF;
            --text-secondary: #9ca3af;
            --accent-purple: #8b5cf6;
            --accent-pink: #ec4899;
            --accent-orange: #f97316;
            --font-family: 'Poppins', sans-serif;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: var(--font-family);
            background: #0a0f1e;
            color: var(--text-secondary);
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 2rem;
            min-height: 100vh;
            font-size: 16px;
            position: relative;
            overflow-x: hidden;
            margin-top: 70px;
        }

        @keyframes gradientShift {
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

        /* Background Effects from color/back.html */
        body::before {
            content: "";
            position: fixed;
            inset: 0;
            background: radial-gradient(ellipse at top left, rgba(39, 215, 184, 0.1), transparent),
                        radial-gradient(ellipse at bottom right, rgba(255, 107, 107, 0.1), transparent);
            z-index: -3;
        }
        
        .bg-gradient {
            position: fixed;
            inset: 0;
            background: linear-gradient(120deg, rgba(255, 255, 255, 0.02), transparent, rgba(255, 255, 255, 0.02));
            background-size: 300% 300%;
            animation: moveGradient 15s ease infinite;
            z-index: -2;
        }

        @keyframes moveGradient {
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

        /* Canvas particles */
        #particles {
            position: fixed;
            inset: 0;
            z-index: 1;
            pointer-events: none;
        }

        /* --- MAIN GRID --- */
        .main-container {
            display: grid;
            grid-template-columns: 300fr 400fr 300fr;
            gap: 2rem;
            width: 100%;
            max-width: 75rem;
            position: relative;
            z-index: 5;
            min-height: 100vh;
            padding: 2rem;
            margin: 0 auto;
        }
        
        /* 마우스 추적을 위한 영역 그리드 - 전체 추적 가능 */
        .main-container > .area {
            position: absolute;
            z-index: 2;
            pointer-events: auto; /* 마우스 추적 활성화 */
        }
        
        /* 5x3 그리드로 15개 영역 배치 */
        .main-container > .area:nth-child(1) { top: 0; left: 0; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(2) { top: 0; left: 20%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(3) { top: 0; left: 40%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(4) { top: 0; left: 60%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(5) { top: 0; left: 80%; width: 20%; height: 33.33%; }
        
        .main-container > .area:nth-child(6) { top: 33.33%; left: 0; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(7) { top: 33.33%; left: 20%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(8) { top: 33.33%; left: 40%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(9) { top: 33.33%; left: 60%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(10) { top: 33.33%; left: 80%; width: 20%; height: 33.33%; }
        
        .main-container > .area:nth-child(11) { top: 66.66%; left: 0; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(12) { top: 66.66%; left: 20%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(13) { top: 66.66%; left: 40%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(14) { top: 66.66%; left: 60%; width: 20%; height: 33.33%; }
        .main-container > .area:nth-child(15) { top: 66.66%; left: 80%; width: 20%; height: 33.33%; }
        

        /* --- CARD BASE STYLE --- */
        .card {
            background: rgba(25, 20, 60, 0.3);
            border: 1px solid rgba(139, 92, 246, 0.2);
            border-radius: 1.5rem;
            padding: 2rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            display: flex;
            flex-direction: column;
            position: relative;
            transition: all 0.3s ease;
            min-height: 180px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            z-index: 100; /* 카드 레이어 보장 - 버튼 포함 */
        }

        .card:hover {
            transform: translateY(-5px);
            border-color: rgba(139, 92, 246, 0.4);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
            background: rgba(25, 20, 60, 0.4);
        }

        /* --- LEFT COLUMN --- */
        .left-column {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            justify-content: flex-start;
            align-items: stretch;
            height: fit-content;
            position: relative;
            z-index: 10;
        }

        .promo-card { 
            flex-grow: 1;
            padding: 2rem;
            min-height: 180px;
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(59, 130, 246, 0.1) 100%);
            border: 1px solid rgba(99, 102, 241, 0.3);
            border-radius: 1.5rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .promo-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #6366f1, #3b82f6, #1d4ed8);
            animation: gradient-shift 5s ease infinite;
        }
        .promo-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(99, 102, 241, 0.15);
            border-color: rgba(99, 102, 241, 0.5);
        }
        
        .promo-card .logo {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--text-primary);
            background: linear-gradient(135deg, #667eea, #764ba2);
            width: 4rem;
            height: 4rem;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 1rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
            position: relative;
        }

        .promo-card .logo::after {
            content: '🤖';
            position: absolute;
            font-size: 0.875rem;
            top: -4px;
            right: -4px;
        }

        .promo-card h2 {
            font-size: 2.4rem;
            font-weight: 700;
            line-height: 1.2;
            color: var(--text-primary);
            margin-bottom: 1.5rem;
        }
        
        .promo-card .trial-info {
            font-size: 1rem;
            line-height: 1.6;
            color: #9ca3af;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
        }

        .users-card { 
            align-items: center;
            text-align: center;
            padding: 2rem;
            min-height: 180px;
            background: linear-gradient(135deg, rgba(249, 115, 22, 0.1) 0%, rgba(251, 146, 60, 0.1) 100%);
            border: 1px solid rgba(249, 115, 22, 0.3);
            border-radius: 1.5rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .users-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #f97316, #fb923c, #fdba74);
            animation: gradient-shift 5s ease infinite;
        }
        .users-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(249, 115, 22, 0.15);
            border-color: rgba(249, 115, 22, 0.5);
        }
        
        .users-card .count {
            font-size: 2.8rem;
            font-weight: 700;
            background: linear-gradient(90deg, #f97316, #ec4899);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 0.5rem;
        }
        
        .users-card .label {
            font-size: 1rem;
            margin-bottom: 1.25rem;
            color: #9ca3af;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
        }
        
        .user-avatars { 
            display: flex;
            justify-content: center;
        }
        
        .user-avatars img {
            width: 3rem;
            height: 3rem;
            border-radius: 50%;
            border: 3px solid #0a0620;
        }
        
        .user-avatars img:not(:first-child) { 
            margin-left: -0.75rem; 
        }

        .generate-btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: var(--text-primary);
            border: none;
            padding: 1.5rem 2rem;
            width: 100%;
            border-radius: 1.2rem;
            font-size: 1.2rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.75rem;
            min-height: 60px;
        }


        .generate-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.3);
        }

        /* --- CENTER COLUMN --- */
        .center-column {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            perspective: 1000px;
            padding: 2rem 0;
            min-height: 40rem;
            z-index: 10;
        }
        
        .main-title { 
            text-align: center; 
            margin-bottom: 2.5rem; 
            position: relative;
        }
        
        .main-title h1 {
            font-size: 3.25rem;
            font-weight: 800;
            line-height: 1.1;
            color: #fff;
            letter-spacing: 0.05em;
            position: relative;
            user-select: none;
        }
        
        /* 네온 글로우 효과 */
        .main-title h1 .glow-text {
            animation: neonGlow 6s ease-in-out infinite alternate;
            text-shadow:
                0 0 10px #00bfff,
                0 0 20px #00bfff,
                0 0 30px #00bfff,
                0 0 40px #00bfff,
                0 0 70px #00bfff,
                0 0 80px #00bfff,
                0 0 100px #00bfff,
                0 0 150px #00bfff;
        }
        
        /* 네온 글로우 애니메이션 - 단일 하늘색으로 천천히 */
        @keyframes neonGlow {
            0% {
                text-shadow:
                    0 0 5px #00bfff,
                    0 0 10px #00bfff,
                    0 0 15px #00bfff,
                    0 0 20px #00bfff,
                    0 0 35px #00bfff,
                    0 0 40px #00bfff,
                    0 0 50px #00bfff,
                    0 0 75px #00bfff;
                filter: brightness(0.8);
            }
            50% {
                text-shadow:
                    0 0 10px #00bfff,
                    0 0 20px #00bfff,
                    0 0 30px #00bfff,
                    0 0 40px #00bfff,
                    0 0 70px #00bfff,
                    0 0 80px #00bfff,
                    0 0 100px #00bfff,
                    0 0 150px #00bfff;
                filter: brightness(1.2);
            }
            100% {
                text-shadow:
                    0 0 5px #00bfff,
                    0 0 10px #00bfff,
                    0 0 15px #00bfff,
                    0 0 20px #00bfff,
                    0 0 35px #00bfff,
                    0 0 40px #00bfff,
                    0 0 50px #00bfff,
                    0 0 75px #00bfff;
                filter: brightness(0.8);
            }
        }
        
        /* 반사 효과 (선택사항) */
        .main-title h1::before {
            content: attr(data-text);
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            -webkit-box-reflect: below 0px linear-gradient(transparent, rgba(10, 6, 32, 0.3));
            z-index: -1;
        }

        .ai-sphere-container {
            --perspective: 1000px;
            --translateY: 45px;
            position: relative;
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            transform-style: preserve-3d;
            margin: -9rem auto 1rem;
            width: 40rem;
            height: 40rem;
            z-index: 10;
        }
        
        .container-ai-input {
            position: relative;
            left: 0;
            right: 0;
            top: 0;
            bottom: 0;
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            transform-style: preserve-3d;
        }

        .ai-sphere-container .area {
            width: 100%;
            height: 100%;
        }

        .background-blur-balls {
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translateX(-50%) translateY(-50%);
            width: 100%;
            height: 100%;
            z-index: -10;
            border-radius: 3rem;
            transition: all 0.3s ease;
            background-color: rgba(255, 255, 255, 0.8);
            overflow: hidden;
        }

        .balls {
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translateX(-50%) translateY(-50%);
            animation: rotate-background-balls 10s linear infinite;
        }

        .container-wrap:hover .balls {
            animation-play-state: paused;
        }

        .background-blur-balls .ball {
            width: 6rem;
            height: 6rem;
            position: absolute;
            border-radius: 50%;
            filter: blur(30px);
        }

        .background-blur-balls .ball.violet {
            top: 0;
            left: 50%;
            transform: translateX(-50%);
            background-color: #9147ff;
        }

        .background-blur-balls .ball.green {
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            background-color: #34d399;
        }

        .background-blur-balls .ball.rosa {
            top: 50%;
            left: 0;
            transform: translateY(-50%);
            background-color: #ec4899;
        }

        .background-blur-balls .ball.cyan {
            top: 50%;
            right: 0;
            transform: translateY(-50%);
            background-color: #05e0f5;
        }

        @keyframes rotate-background-balls {
            from {
                transform: translateX(-50%) translateY(-50%) rotate(360deg);
            }
            to {
                transform: translateX(-50%) translateY(-50%) rotate(0);
            }
        }

        /* Satellite Particles */
        .satellite-particles {
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translateX(-50%) translateY(-50%);
            width: 500px;
            height: 500px;
            pointer-events: none;
            z-index: 1;
        }

        .satellite-orbit {
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translateX(-50%) translateY(-50%);
            border-radius: 50%;
            border: 1px solid rgba(102, 126, 234, 0.1);
        }

        .satellite-particle {
            position: absolute;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(200, 255, 0, 0.8) 0%, rgba(102, 126, 234, 0.2) 70%, transparent 100%);
            box-shadow: 0 0 10px rgba(102, 126, 234, 0.6), 
                        inset 0 0 10px rgba(255, 255, 255, 0.3);
            animation-timing-function: linear;
            animation-iteration-count: infinite;
        }

        /* Orbit 1 - Closest */
        .orbit-1 {
            width: 240px;
            height: 240px;
            animation: satellite-orbit-1 8s linear infinite;
        }
        .particle-1 {
            width: 10px;
            height: 10px;
            left: -5px;
            top: 50%;
            margin-top: -5px;
            background: radial-gradient(circle, rgba(236, 72, 153, 0.9) 0%, rgba(236, 72, 153, 0.3) 70%, transparent 100%);
            box-shadow: 0 0 15px rgba(236, 72, 153, 0.7);
        }

        /* Orbit 2 */
        .orbit-2 {
            width: 300px;
            height: 300px;
            animation: satellite-orbit-2 12s linear infinite reverse;
        }
        .particle-2 {
            width: 8px;
            height: 8px;
            left: -4px;
            top: 50%;
            margin-top: -4px;
            background: radial-gradient(circle, rgba(52, 211, 153, 0.9) 0%, rgba(52, 211, 153, 0.3) 70%, transparent 100%);
            box-shadow: 0 0 12px rgba(52, 211, 153, 0.7);
        }

        /* Orbit 3 */
        .orbit-3 {
            width: 360px;
            height: 360px;
            animation: satellite-orbit-3 15s linear infinite;
        }
        .particle-3 {
            width: 12px;
            height: 12px;
            left: -6px;
            top: 50%;
            margin-top: -6px;
            background: radial-gradient(circle, rgba(145, 71, 255, 0.9) 0%, rgba(145, 71, 255, 0.3) 70%, transparent 100%);
            box-shadow: 0 0 18px rgba(145, 71, 255, 0.7);
        }

        /* Orbit 4 */
        .orbit-4 {
            width: 280px;
            height: 280px;
            animation: satellite-orbit-4 10s linear infinite reverse;
        }
        .particle-4 {
            width: 9px;
            height: 9px;
            left: -4.5px;
            top: 50%;
            margin-top: -4.5px;
            background: radial-gradient(circle, rgba(5, 224, 245, 0.9) 0%, rgba(5, 224, 245, 0.3) 70%, transparent 100%);
            box-shadow: 0 0 14px rgba(5, 224, 245, 0.7);
        }

        /* Orbit 5 */
        .orbit-5 {
            width: 420px;
            height: 420px;
            animation: satellite-orbit-5 18s linear infinite;
        }
        .particle-5 {
            width: 7px;
            height: 7px;
            left: -3.5px;
            top: 50%;
            margin-top: -3.5px;
            background: radial-gradient(circle, rgba(251, 191, 36, 0.9) 0%, rgba(251, 191, 36, 0.3) 70%, transparent 100%);
            box-shadow: 0 0 10px rgba(251, 191, 36, 0.7);
        }

        /* Orbit 6 */
        .orbit-6 {
            width: 340px;
            height: 340px;
            animation: satellite-orbit-6 14s linear infinite reverse;
        }
        .particle-6 {
            width: 11px;
            height: 11px;
            left: -5.5px;
            top: 50%;
            margin-top: -5.5px;
            background: radial-gradient(circle, rgba(139, 69, 19, 0.9) 0%, rgba(139, 69, 19, 0.3) 70%, transparent 100%);
            box-shadow: 0 0 13px rgba(139, 69, 19, 0.7);
        }

        /* Orbit animations */
        @keyframes satellite-orbit-1 {
            from { transform: translateX(-50%) translateY(-50%) rotate(0deg); }
            to { transform: translateX(-50%) translateY(-50%) rotate(360deg); }
        }

        @keyframes satellite-orbit-2 {
            from { transform: translateX(-50%) translateY(-50%) rotate(0deg); }
            to { transform: translateX(-50%) translateY(-50%) rotate(360deg); }
        }

        @keyframes satellite-orbit-3 {
            from { transform: translateX(-50%) translateY(-50%) rotate(0deg); }
            to { transform: translateX(-50%) translateY(-50%) rotate(360deg); }
        }

        @keyframes satellite-orbit-4 {
            from { transform: translateX(-50%) translateY(-50%) rotate(0deg); }
            to { transform: translateX(-50%) translateY(-50%) rotate(360deg); }
        }

        @keyframes satellite-orbit-5 {
            from { transform: translateX(-50%) translateY(-50%) rotate(0deg); }
            to { transform: translateX(-50%) translateY(-50%) rotate(360deg); }
        }

        @keyframes satellite-orbit-6 {
            from { transform: translateX(-50%) translateY(-50%) rotate(0deg); }
            to { transform: translateX(-50%) translateY(-50%) rotate(360deg); }
        }

        /* Hover effects for satellite particles */
        .container-wrap:hover .satellite-particles {
            animation-play-state: paused;
        }

        .container-wrap:hover .satellite-orbit {
            animation-play-state: paused;
        }

        .container-wrap:hover .satellite-particle {
            transform: scale(1.5);
            transition: transform 0.3s ease;
        }

        /* Area hover effects for 3D card tracking - 5x3 grid (15 areas) */
        .container-ai-input {
            --perspective: 1000px;
            --translateY: 45px;
        }

        .area:nth-child(15):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(-15deg) rotateY(15deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(14):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(-15deg) rotateY(7deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(13):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(-15deg) rotateY(0)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(12):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(-15deg) rotateY(-7deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(11):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(-15deg) rotateY(-15deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }

        .area:nth-child(10):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(0) rotateY(15deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(9):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(0) rotateY(7deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(8):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(0) rotateY(0)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(7):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(0) rotateY(-7deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(6):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(0) rotateY(-15deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }

        .area:nth-child(5):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(15deg) rotateY(15deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(4):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(15deg) rotateY(7deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(3):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(15deg) rotateY(0)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(2):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(15deg) rotateY(-7deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }
        .area:nth-child(1):hover ~ .container-wrap .card {
            transform: perspective(var(--perspective)) rotateX(15deg) rotateY(-15deg)
                translateZ(var(--translateY)) scale3d(1, 1, 1);
        }

        .container-wrap {
            display: flex;
            align-items: center;
            justify-items: center;
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translateX(-50%) translateY(-50%);
            z-index: 9;
            transform-style: preserve-3d;
            cursor: pointer;
            padding: 4px;
            transition: all 0.3s ease;
        }

        .container-wrap:hover {
            padding: 0;
        }

        .container-wrap:active {
            transform: translateX(-50%) translateY(-50%) scale(0.95);
        }

        .container-wrap:after {
            content: "";
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translateX(-50%) translateY(-55%);
            width: 12rem;
            height: 11rem;
            background: linear-gradient(135deg, 
                rgba(222, 223, 224, 0.8), 
                rgba(145, 71, 255, 0.1));
            border-radius: 3.2rem;
            transition: all 0.3s ease;
            box-shadow: 0 15px 35px rgba(145, 71, 255, 0.2);
            z-index: -1;
        }

        .container-wrap:hover:after {
            transform: translateX(-50%) translateY(-50%);
            height: 12rem;
            background: linear-gradient(135deg, 
                rgba(222, 223, 224, 0.9), 
                rgba(145, 71, 255, 0.15));
            box-shadow: 0 20px 45px rgba(145, 71, 255, 0.3);
        }

        .container-wrap input {
            opacity: 0;
            width: 0;
            height: 0;
            position: absolute;
        }

        .container-wrap input:checked + .aimo-card .eyes {
            opacity: 0;
        }

        .container-wrap input:checked + .aimo-card .content-card {
            width: 260px;
            height: 160px;
        }

        .container-wrap:active {
            transform: translateX(-50%) translateY(-50%) scale(0.95);
        }

        .container-wrap:after {
            content: "";
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translateX(-50%) translateY(-55%);
            width: 12rem;
            height: 11rem;
            background: linear-gradient(135deg, 
                rgba(145, 71, 255, 0.1), 
                rgba(139, 92, 246, 0.1), 
                rgba(99, 102, 241, 0.1));
            border-radius: 3.2rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .container-wrap:hover:after {
            transform: translateX(-50%) translateY(-50%);
            height: 12rem;
            background: linear-gradient(135deg, 
                rgba(145, 71, 255, 0.15), 
                rgba(139, 92, 246, 0.15), 
                rgba(99, 102, 241, 0.15));
        }

        .container-wrap input {
            opacity: 0;
            width: 0;
            height: 0;
            position: absolute;
        }

        .ai-sphere-container .aimo-card {
            width: 100%;
            height: 100%;
            transform-style: preserve-3d;
            will-change: transform;
            transition: all 0.6s ease;
            border-radius: 3rem;
            display: flex;
            align-items: center;
            transform: translateZ(50px);
            justify-content: center;
            position: relative;
            min-height: auto;
            backdrop-filter: blur(10px);
        }

        .ai-sphere-container .aimo-card:hover {
            box-shadow: 0 20px 40px rgba(145, 71, 255, 0.3),
                inset 0 0 20px rgba(255, 255, 255, 0.1);
            background: linear-gradient(135deg, 
                rgba(145, 71, 255, 0.1), 
                rgba(139, 92, 246, 0.1));
        }

        .content-card {
            width: 12rem;
            height: 12rem;
            display: flex;
            border-radius: 3rem;
            transition: all 0.3s ease;
            overflow: hidden;
            position: relative;
            z-index: 10;
        }

        .background-blur-card {
            width: 100%;
            height: 100%;
            backdrop-filter: blur(50px);
            background: linear-gradient(135deg, 
                rgba(145, 71, 255, 0.7) 0%,
                rgba(236, 72, 153, 0.7) 25%,
                rgba(52, 211, 153, 0.7) 50%,
                rgba(5, 224, 245, 0.7) 75%,
                rgba(147, 71, 255, 0.7) 100%);
            background-size: 400% 400%;
            animation: gradientShift 4s ease-in-out infinite;
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: 3rem;
        }
        
        @keyframes gradientShift {
            0%, 100% {
                background-position: 0% 50%;
            }
            50% {
                background-position: 100% 50%;
            }
        }

        .eyes {
            position: absolute;
            left: 50%;
            bottom: 50%;
            transform: translateX(-50%);
            display: flex;
            align-items: center;
            justify-content: center;
            height: 52px;
            gap: 2rem;
            transition: all 0.3s ease;
        }
        .eyes .eye {
            width: 26px;
            height: 52px;
            background: linear-gradient(180deg, 
                rgba(255, 255, 255, 0.9), 
                rgba(145, 71, 255, 0.3));
            border-radius: 16px;
            animation: animate-eyes 10s infinite linear;
            transition: all 0.3s ease;
            box-shadow: 0 0 15px rgba(145, 71, 255, 0.5);
        }

        .eyes.happy {
            display: none;
            color: rgba(145, 71, 255, 0.8);
            gap: 0;
        }
        .eyes.happy svg {
            width: 60px;
            filter: drop-shadow(0 0 10px rgba(145, 71, 255, 0.6));
        }

        .container-wrap:hover .eyes .eye {
            display: none;
        }

        .container-wrap:hover .eyes.happy {
            display: flex;
        }








        /* Complete main-container mouse tracking - No areas needed */




        /* 애니메이션 키프레임 */
        @keyframes animate-eyes {
            46% { height: 52px; }
            48% { height: 20px; }
            50% { height: 52px; }
            96% { height: 52px; }
            98% { height: 20px; }
            100% { height: 52px; }
        }


        .features-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            width: 100%;
            margin-top: -9rem;
        }

        .feature-card { 
            padding: 2rem;
            min-height: 200px;
            border-radius: 1.5rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .feature-card:first-child {
            background: linear-gradient(135deg, rgba(236, 72, 153, 0.1) 0%, rgba(219, 39, 119, 0.1) 100%);
            border: 1px solid rgba(236, 72, 153, 0.3);
        }
        .feature-card:first-child::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #ec4899, #db2777, #be185d);
            animation: gradient-shift 5s ease infinite;
        }
        .feature-card:first-child:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(236, 72, 153, 0.15);
            border-color: rgba(236, 72, 153, 0.5);
        }

        .feature-card:last-child {
            background: linear-gradient(135deg, rgba(168, 85, 247, 0.1) 0%, rgba(147, 51, 234, 0.1) 100%);
            border: 1px solid rgba(168, 85, 247, 0.3);
        }
        .feature-card:last-child::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #a855f7, #9333ea, #7c3aed);
            animation: gradient-shift 5s ease infinite;
        }
        .feature-card:last-child:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(168, 85, 247, 0.15);
            border-color: rgba(168, 85, 247, 0.5);
        }

        .feature-card .icon {
            width: 3.5rem; 
            height: 3.5rem;
            border-radius: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
        }

        .feature-card:first-child .icon {
            background: linear-gradient(135deg, #f97316, #ea580c);
        }

        .feature-card:last-child .icon {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }

        .feature-card .icon svg {
            width: 1.75rem;
            height: 1.75rem;
            color: white;
        }

        .feature-card h3 {
            font-size: 1.3rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.75rem;
        }

        .feature-card p {
            font-size: 1.1rem;
            line-height: 1.6;
            color: #9ca3af;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
        }

        /* Wide horizontal card */
        .wide-card {
            width: 100%;
            margin-top: 1.5rem;
            margin-bottom: 2rem;
            padding: 1rem 1.5rem;
            min-height: 200px;
            background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(236, 72, 153, 0.1) 100%);
            border: 1px solid rgba(139, 92, 246, 0.3);
            border-radius: 1.5rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .wide-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #8b5cf6, #ec4899, #f97316);
            animation: gradient-shift 6s ease infinite;
        }

        .wide-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(139, 92, 246, 0.15);
            border-color: rgba(139, 92, 246, 0.5);
        }

        .wide-card-content {
            display: flex;
            align-items: center;
            gap: 2rem;
            height: 100%;
        }

        .wide-card-icon {
            width: 4rem;
            height: 4rem;
            border-radius: 1.2rem;
            background: linear-gradient(135deg, #8b5cf6, #ec4899);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            box-shadow: 0 8px 20px rgba(139, 92, 246, 0.3);
        }

        .wide-card-icon svg {
            width: 2rem;
            height: 2rem;
            color: white;
        }

        .wide-card-text {
            flex: 1;
        }

        .wide-card-text h3 {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, #8b5cf6, #ec4899);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .wide-card-text p {
            font-size: 1.1rem;
            line-height: 1.6;
            color: #9ca3af;
            margin-bottom: 1.5rem;
        }

        .wide-card-features {
            display: flex;
            flex-direction: column;
            gap: 0.8rem;
        }

        .feature-item {
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }

        .feature-icon {
            font-size: 1.2rem;
            width: 1.8rem;
            height: 1.8rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .feature-text {
            font-size: 1rem;
            color: #9ca3af;
            font-weight: 500;
        }

        .wide-card-action {
            flex-shrink: 0;
        }

        .wide-card-button {
            padding: 0.8rem 1.8rem;
            background: linear-gradient(135deg, #8b5cf6, #ec4899);
            border: none;
            border-radius: 50px;
            color: white;
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .wide-card-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.4);
            color: white;
        }

        /* Side feature card (below AI chat button) */
        .side-feature-card {
            margin-top: 1.5rem;
            padding: 2rem;
            min-height: 180px;
            background: linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(168, 85, 247, 0.1) 100%);
            border: 1px solid rgba(99, 102, 241, 0.3);
            border-radius: 1.5rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .side-feature-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #6366f1, #a855f7, #ec4899);
            animation: gradient-shift 5s ease infinite;
        }

        .side-feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(99, 102, 241, 0.15);
            border-color: rgba(99, 102, 241, 0.5);
        }

        .side-card-icon {
            width: 3.5rem;
            height: 3.5rem;
            border-radius: 1rem;
            background: linear-gradient(135deg, #6366f1, #a855f7);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 1.5rem;
            box-shadow: 0 8px 20px rgba(99, 102, 241, 0.3);
        }

        .side-card-icon svg {
            width: 1.75rem;
            height: 1.75rem;
            color: white;
        }

        .side-card-content h3 {
            font-size: 1.3rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.75rem;
            background: linear-gradient(135deg, #6366f1, #a855f7);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .side-card-content p {
            font-size: 1rem;
            line-height: 1.6;
            color: #9ca3af;
            margin-bottom: 1.5rem;
        }

        .side-card-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.6rem 1.2rem;
            background: linear-gradient(135deg, #6366f1, #a855f7);
            border: none;
            border-radius: 50px;
            color: white;
            font-weight: 500;
            font-size: 0.9rem;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .side-card-link:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(99, 102, 241, 0.4);
            color: white;
        }

        /* --- RIGHT COLUMN --- */
        .right-column {
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            position: relative;
            z-index: 10;
        }

        .top-icon-card {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            min-height: 5rem;
            padding: 1.75rem;
        }

        .top-icon-card .icon-wrapper {
            width: 3.5rem;
            height: 3.5rem;
            border-radius: 1rem;
            background: linear-gradient(135deg, #f97316, #ea580c);
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: transform 0.3s ease;
        }

        .top-icon-card .icon-wrapper:hover {
            transform: scale(1.1);
        }

        .top-icon-card svg { 
            width: 1.25rem; 
            height: 1.25rem;
            color: white;
        }

        .review-slideshow-card { 
            text-align: center;
            padding: 1.5rem;
            min-height: 180px;
            background: linear-gradient(135deg, rgba(139, 92, 246, 0.1) 0%, rgba(124, 58, 237, 0.1) 100%);
            border: 1px solid rgba(139, 92, 246, 0.3);
            border-radius: 1.5rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .review-slideshow-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #8b5cf6, #7c3aed, #6d28d9);
            animation: gradient-shift 5s ease infinite;
        }
        .review-slideshow-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(139, 92, 246, 0.15);
            border-color: rgba(139, 92, 246, 0.5);
        }

        .review-slideshow {
            position: relative;
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .review-slide {
            display: none;
            text-align: center;
            animation: fadeIn 0.5s ease-in-out;
        }

        .review-slide.active {
            display: block;
        }

        .review-slide .stars {
            font-size: 1.2rem;
            margin-bottom: 0.8rem;
            color: #fbbf24;
        }

        .review-slide p {
            font-size: 0.9rem;
            line-height: 1.4;
            color: var(--text-primary);
            margin-bottom: 0.8rem;
            font-weight: 500;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
        }

        .review-slide .reviewer {
            font-size: 0.85rem;
            color: #9ca3af;
            font-weight: 600;
            opacity: 0.8;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .templates-card { 
            flex-grow: 1; 
            position: relative;
            min-height: 280px;
            padding: 2rem;
            background: linear-gradient(135deg, rgba(34, 197, 94, 0.1) 0%, rgba(22, 163, 74, 0.1) 100%);
            border: 1px solid rgba(34, 197, 94, 0.3);
            border-radius: 1.5rem;
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            overflow: hidden;
            transition: all 0.3s ease;
        }
        .templates-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 2px;
            background: linear-gradient(90deg, #22c55e, #16a34a, #15803d);
            animation: gradient-shift 5s ease infinite;
        }
        .templates-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(34, 197, 94, 0.15);
            border-color: rgba(34, 197, 94, 0.5);
        }

        .templates-card .trial-badge {
            position: absolute;
            top: 1.5rem; 
            right: 1.5rem;
            background: rgba(0, 0, 0, 0.4);
            padding: 0.5rem 1rem;
            border-radius: 1rem;
            font-size: 0.9rem;
            font-weight: 500;
            color: #d1d5db;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.5);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .templates-card h3 {
            font-size: 1.3rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.75rem;
        }

        .templates-card p {
            font-size: 1.1rem;
            line-height: 1.6;
            color: #9ca3af;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
            margin-bottom: 2rem;
        }

        .template-graphic {
            position: relative;
            height: 120px;
        }

        .graphic-item {
            position: absolute;
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 0.7rem;
            color: var(--text-primary);
            transition: transform 0.3s ease;
        }

        .graphic-item.rewrite {
            width: 5rem;
            height: 2.75rem;
            top: 35%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(-5deg);
            z-index: 3;
            background: linear-gradient(135deg, #667eea, #764ba2);
            font-size: 0.875rem;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
        }

        .graphic-item.file {
            width: 2.75rem;
            height: 2rem;
            font-size: 0.65rem;
            border-radius: 0.5rem;
        }

        .graphic-item.ai {
            top: 10%;
            right: 15%;
            transform: rotate(10deg);
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }

        .graphic-item.gpt {
            top: 5%;
            left: 10%;
            transform: rotate(-12deg);
            background: linear-gradient(135deg, #ec4899, #db2777);
        }

        .graphic-item.claude {
            bottom: 25%;
            right: 20%;
            transform: rotate(5deg);
            background: linear-gradient(135deg, #06b6d4, #0891b2);
        }

        .graphic-item.dot {
            width: 1.25rem;
            height: 1.25rem;
            border-radius: 50%;
            background: rgba(139, 92, 246, 0.1);
        }

        .graphic-item.dot-1 { 
            bottom: 30%;
            left: 20%;
        }

        .graphic-item.dot-2 { 
            top: 50%;
            right: 10%;
        }
        
        /* Model Quick Info */
        .model-quick-info {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 1rem;
            margin-bottom: 0.5rem;
        }
        .quick-tag {
            font-size: 0.7rem;
            padding: 0.25rem 0.5rem;
            background: rgba(34, 197, 94, 0.1);
            border: 1px solid rgba(34, 197, 94, 0.2);
            border-radius: 1rem;
            color: #22c55e;
            font-weight: 500;
        }

        /* 실시간 성능 지표 스타일 */
        .model-performance {
            margin-top: 1rem;
            padding: 1rem;
            background: rgba(22, 197, 34, 0.05);
            border: 1px solid rgba(22, 197, 34, 0.1);
            border-radius: 0.75rem;
            backdrop-filter: blur(10px);
        }

        .performance-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.75rem;
        }

        .performance-header h4 {
            font-size: 0.9rem;
            color: #22c55e;
            margin: 0;
            font-weight: 600;
        }

        .status-indicator {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            position: relative;
        }

        .status-indicator.online {
            background: #22c55e;
            box-shadow: 0 0 8px rgba(34, 197, 94, 0.5);
            animation: pulse-green 2s infinite;
        }

        @keyframes pulse-green {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.6; }
        }

        .performance-metrics {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 0.75rem;
        }

        .metric {
            text-align: center;
            padding: 0.5rem;
            background: rgba(22, 197, 34, 0.08);
            border-radius: 0.5rem;
            border: 1px solid rgba(22, 197, 34, 0.15);
            transition: all 0.3s ease;
        }

        .metric:hover {
            background: rgba(22, 197, 34, 0.12);
            transform: translateY(-2px);
        }

        .metric-value {
            display: block;
            font-size: 1.1rem;
            font-weight: 700;
            color: #22c55e;
            line-height: 1;
        }

        .metric-unit {
            font-size: 0.7rem;
            color: #16a34a;
            font-weight: 500;
        }

        .metric-label {
            display: block;
            font-size: 0.65rem;
            color: #15803d;
            margin-top: 0.25rem;
            opacity: 0.8;
        }

        /* 모델 비교 도구 스타일 */
        .model-comparison {
            margin-top: 1rem;
        }

        .comparison-btn {
            width: 100%;
            padding: 0.75rem;
            background: linear-gradient(135deg, rgba(22, 197, 34, 0.15), rgba(16, 185, 129, 0.15));
            border: 1px solid rgba(22, 197, 34, 0.3);
            border-radius: 0.75rem;
            color: #22c55e;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        .comparison-btn:hover {
            background: linear-gradient(135deg, rgba(22, 197, 34, 0.25), rgba(16, 185, 129, 0.25));
            border-color: rgba(22, 197, 34, 0.5);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(22, 197, 34, 0.2);
        }

        .comparison-btn i {
            font-size: 0.9rem;
        }

        /* Glow effects for cards */
        .card::after {
            content: '';
            position: absolute;
            inset: 0;
            border-radius: 1.5rem;
            background: radial-gradient(circle at var(--mouse-x, 50%) var(--mouse-y, 50%), 
                rgba(139, 92, 246, 0.05) 0%, 
                transparent 50%);
            pointer-events: none;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .card:hover::after {
            opacity: 1;
        }

        /* --- AI MODELS SECTION --- */
        .ai-models-section {
            width: 100%;
            max-width: 75rem;
            margin-top: 4rem;
            position: relative;
            z-index: 5;
        }

        .ai-models-title {
            text-align: center;
            margin-bottom: 3rem;
        }

        .ai-models-title h2 {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 1rem;
            background: linear-gradient(135deg, #667eea, #764ba2);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .ai-models-title p {
            font-size: 1.2rem;
            color: #9ca3af;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
            line-height: 1.6;
        }

        .ai-models-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 3rem;
            padding: 0 1rem;
        }

        /* 3D Card Style based on card.html */
        .ai-model-card {
            width: 320px;
            height: 380px;
            perspective: 1000px;
            margin: 0 auto;
            transition: all 0.3s ease;
        }

        .ai-model-card.selected {
            transform: translateY(-12px) scale(1.08);
            filter: drop-shadow(0 20px 40px rgba(102, 126, 234, 0.6));
            z-index: 10;
        }

        .ai-model-card.selected .ai-model-3d {
            background: linear-gradient(135deg, 
                rgba(102, 126, 234, 0.3) 0%, 
                rgba(118, 75, 162, 0.3) 100%);
            border: 3px solid rgba(102, 126, 234, 0.8);
            box-shadow: 
                0 0 30px rgba(102, 126, 234, 0.4),
                inset 0 0 20px rgba(255, 255, 255, 0.1);
        }

        .ai-model-card.selected .ai-model-title {
            color: #667eea !important;
            text-shadow: 0 0 10px rgba(102, 126, 234, 0.5);
            font-weight: 700;
        }

        .ai-model-card.selected::before {
            content: '✓ 선택됨';
            position: absolute;
            top: -10px;
            right: -10px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            z-index: 11;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        .ai-model-3d {
            height: 100%;
            border-radius: 50px;
            transition: all 0.5s ease-in-out;
            transform-style: preserve-3d;
            cursor: pointer;
            position: relative;
        }

        .ai-model-glass {
            transform-style: preserve-3d;
            position: absolute;
            inset: 8px;
            border-radius: 55px;
            border-top-right-radius: 100%;
            background: linear-gradient(0deg, rgba(255, 255, 255, 0.2) 0%, rgba(255, 255, 255, 0.4) 100%);
            transform: translate3d(0px, 0px, 25px);
            border-left: 1px solid rgba(255, 255, 255, 0.3);
            border-bottom: 1px solid rgba(255, 255, 255, 0.3);
            transition: all 0.5s ease-in-out;
        }

        .ai-model-content {
            padding: 70px 30px 20px 30px;
            transform: translate3d(0, 0, 26px);
            height: calc(100% - 140px);
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
        }

        .ai-model-content .ai-model-title {
            display: block;
            font-weight: 900;
            font-size: 18px;
            margin-bottom: 6px;
            line-height: 1.2;
            color: #ffffff;
            text-shadow: 0 3px 6px rgba(0, 0, 0, 0.7), 0 1px 3px rgba(0, 0, 0, 0.5);
        }

        .ai-model-content .ai-model-type {
            display: block;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 12px;
            color: rgba(255, 255, 255, 1);
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.6), 0 1px 2px rgba(0, 0, 0, 0.4);
        }

        .ai-model-content .ai-model-description {
            display: block;
            font-size: 14px;
            line-height: 1.4;
            color: rgba(255, 255, 255, 1);
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.6), 0 1px 3px rgba(0, 0, 0, 0.4);
            flex: 1;
            overflow: hidden;
        }

        .ai-model-bottom {
            padding: 12px 20px 20px 20px;
            transform-style: preserve-3d;
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            display: flex;
            flex-direction: column;
            gap: 12px;
            transform: translate3d(0, 0, 26px);
        }

        .ai-model-info-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 15px;
            background: rgba(255, 255, 255, 0.1);
            padding: 3px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .ai-model-features {
            display: flex;
            flex-direction: column;
            gap: 4px;
            flex: 1;
            min-width: 0;
        }

        .ai-model-feature-tag {
            background: rgba(255, 255, 255, 0.95);
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.8);
            color: #000000;
            text-shadow: none;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            box-shadow: none;
        }

        .ai-model-status {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 4px;
            flex-shrink: 0;
        }

        .ai-model-status-badge {
            padding: 6px 12px;
            border-radius: 18px;
            font-size: 12px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            text-shadow: none;
            white-space: nowrap;
            box-shadow: none;
            transition: all 0.3s ease;
        }

        .ai-model-status-badge:hover {
            transform: translateY(-1px);
            box-shadow: none;
        }

        .ai-model-accuracy {
            font-size: 12px;
            font-weight: 700;
            color: #000000;
            text-shadow: none;
            white-space: nowrap;
            background: rgba(255, 255, 255, 0.9);
            padding: 2px 6px;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.8);
        }

        /* AI Model Action Buttons */
        .ai-model-actions {
            display: flex;
            gap: 6px;
            transform: translate3d(0, 0, 27px);
        }

        .ai-model-btn {
            background: rgba(255, 255, 255, 0.9);
            border: 1px solid rgba(255, 255, 255, 0.9);
            border-radius: 15px;
            padding: 8px 14px;
            font-size: 12px;
            font-weight: 700;
            color: #000000;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            text-shadow: none;
            box-shadow: none;
            flex: 1;
            justify-content: center;
            white-space: nowrap;
            min-width: 0;
        }

        .ai-model-btn:hover {
            background: rgba(255, 255, 255, 1.0);
            border-color: rgba(255, 255, 255, 1.0);
            transform: translate3d(0, -2px, 5px);
            box-shadow: none;
            color: #000000;
            text-decoration: none;
        }

        .ai-model-btn.primary {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
        }

        .ai-model-btn.primary:hover {
            background: rgba(255, 255, 255, 0.4);
            border-color: rgba(255, 255, 255, 0.7);
        }

        .ai-model-btn.secondary {
            background: rgba(255, 255, 255, 0.15);
            border-color: rgba(255, 255, 255, 0.25);
        }

        .ai-model-btn.secondary:hover {
            background: rgba(255, 255, 255, 0.25);
            border-color: rgba(255, 255, 255, 0.4);
        }

        .ai-model-logo {
            position: absolute;
            right: 0;
            top: 0;
            transform-style: preserve-3d;
        }

        .ai-model-logo .logo-circle {
            display: block;
            position: absolute;
            aspect-ratio: 1;
            border-radius: 50%;
            top: 0;
            right: 0;
            box-shadow: rgba(100, 100, 111, 0.2) -10px 10px 20px 0px;
            -webkit-backdrop-filter: blur(5px);
            backdrop-filter: blur(5px);
            transition: all 0.5s ease-in-out;
        }

        .ai-model-logo .logo-circle1 {
            width: 140px;
            transform: translate3d(0, 0, 20px);
            top: 8px;
            right: 8px;
        }

        .ai-model-logo .logo-circle2 {
            width: 110px;
            transform: translate3d(0, 0, 40px);
            top: 15px;
            right: 15px;
            -webkit-backdrop-filter: blur(1px);
            backdrop-filter: blur(1px);
            transition-delay: 0.2s;
        }

        .ai-model-logo .logo-circle3 {
            width: 80px;
            transform: translate3d(0, 0, 60px);
            top: 22px;
            right: 22px;
            transition-delay: 0.4s;
        }

        .ai-model-logo .logo-circle4 {
            width: 50px;
            transform: translate3d(0, 0, 80px);
            top: 30px;
            right: 30px;
            display: grid;
            place-content: center;
            transition-delay: 0.6s;
            font-size: 20px;
        }

        /* Hover effects */
        .ai-model-card:hover .ai-model-3d {
            transform: rotate3d(1, 1, 0, 25deg);
        }

        .ai-model-card:hover .ai-model-logo .logo-circle2 {
            transform: translate3d(0, 0, 60px);
        }

        .ai-model-card:hover .ai-model-logo .logo-circle3 {
            transform: translate3d(0, 0, 80px);
        }

        .ai-model-card:hover .ai-model-logo .logo-circle4 {
            transform: translate3d(0, 0, 100px);
        }

        /* AI Model Cards - Each with different 3D color themes */
        .ai-model-card:nth-child(1) .ai-model-3d {
            background: linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #60a5fa 100%);
            box-shadow: rgba(30, 64, 175, 0.3) 40px 50px 25px -40px, rgba(30, 64, 175, 0.2) 0px 25px 25px -5px;
        }
        .ai-model-card:nth-child(1) .ai-model-3d:hover {
            box-shadow: rgba(30, 64, 175, 0.4) 30px 50px 25px -40px, rgba(30, 64, 175, 0.3) 0px 25px 30px 0px;
        }
        .ai-model-card:nth-child(1) .ai-model-logo .logo-circle {
            background: rgba(30, 64, 175, 0.3);
        }

        .ai-model-card:nth-child(2) .ai-model-3d {
            background: linear-gradient(135deg, rgb(255, 107, 107) 0%, rgb(255, 167, 38) 100%);
            box-shadow: rgba(255, 107, 107, 0.3) 40px 50px 25px -40px, rgba(255, 107, 107, 0.2) 0px 25px 25px -5px;
        }
        .ai-model-card:nth-child(2) .ai-model-3d:hover {
            box-shadow: rgba(255, 107, 107, 0.4) 30px 50px 25px -40px, rgba(255, 107, 107, 0.3) 0px 25px 30px 0px;
        }
        .ai-model-card:nth-child(2) .ai-model-logo .logo-circle {
            background: rgba(255, 107, 107, 0.3);
        }

        .ai-model-card:nth-child(3) .ai-model-3d {
            background: linear-gradient(135deg, rgb(78, 205, 196) 0%, rgb(68, 160, 141) 100%);
            box-shadow: rgba(78, 205, 196, 0.3) 40px 50px 25px -40px, rgba(78, 205, 196, 0.2) 0px 25px 25px -5px;
        }
        .ai-model-card:nth-child(3) .ai-model-3d:hover {
            box-shadow: rgba(78, 205, 196, 0.4) 30px 50px 25px -40px, rgba(78, 205, 196, 0.3) 0px 25px 30px 0px;
        }
        .ai-model-card:nth-child(3) .ai-model-logo .logo-circle {
            background: rgba(78, 205, 196, 0.3);
        }

        .ai-model-card:nth-child(4) .ai-model-3d {
            background: linear-gradient(135deg, rgb(255, 0, 0) 0%, rgb(216, 29, 29) 100%);
            box-shadow: rgba(233, 20, 20, 0.3) 40px 50px 25px -40px, rgba(235, 37, 37, 0.2) 0px 25px 25px -5px;
        }
        .ai-model-card:nth-child(4) .ai-model-3d:hover {
            box-shadow: rgba(235, 37, 37, 0.4) 30px 50px 25px -40px, rgba(230, 9, 9, 0.3) 0px 25px 30px 0px;
        }
        .ai-model-card:nth-child(4) .ai-model-logo .logo-circle {
            background: rgba(243, 12, 12, 0.3);
        }

        .ai-model-card:nth-child(5) .ai-model-3d {
            background: linear-gradient(135deg, rgb(139, 92, 246) 0%, rgb(124, 58, 237) 100%);
            box-shadow: rgba(139, 92, 246, 0.3) 40px 50px 25px -40px, rgba(139, 92, 246, 0.2) 0px 25px 25px -5px;
        }
        .ai-model-card:nth-child(5) .ai-model-3d:hover {
            box-shadow: rgba(139, 92, 246, 0.4) 30px 50px 25px -40px, rgba(139, 92, 246, 0.3) 0px 25px 30px 0px;
        }
        .ai-model-card:nth-child(5) .ai-model-logo .logo-circle {
            background: rgba(139, 92, 246, 0.3);
        }

        .ai-model-card:nth-child(6) .ai-model-3d {
            background: linear-gradient(135deg, rgb(236, 72, 153) 0%, rgb(219, 39, 119) 100%);
            box-shadow: rgba(236, 72, 153, 0.3) 40px 50px 25px -40px, rgba(236, 72, 153, 0.2) 0px 25px 25px -5px;
        }
        .ai-model-card:nth-child(6) .ai-model-3d:hover {
            box-shadow: rgba(236, 72, 153, 0.4) 30px 50px 25px -40px, rgba(236, 72, 153, 0.3) 0px 25px 30px 0px;
        }
        .ai-model-card:nth-child(6) .ai-model-logo .logo-circle {
            background: rgba(236, 72, 153, 0.3);
        }

        /* Status badge colors */
        .status-active {
            background: linear-gradient(135deg, #10b981, #059669);
            color: #ffffff;
            font-weight: 800;
            font-size: 13px;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
            box-shadow: 0 3px 10px rgba(16, 185, 129, 0.4);
            border: 1px solid rgba(16, 185, 129, 0.8);
            padding: 6px 12px;
            border-radius: 20px;
        }

        .status-beta {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: #ffffff;
            font-weight: 800;
            font-size: 13px;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
            box-shadow: 0 3px 10px rgba(245, 158, 11, 0.4);
            border: 1px solid rgba(245, 158, 11, 0.8);
            padding: 6px 12px;
            border-radius: 20px;
        }

        .status-coming {
            background: linear-gradient(135deg, #3b82f6, #1d4ed8);
            color: #000000;
            font-weight: 800;
            font-size: 12px;
            text-shadow: none;
            box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
            border: 1px solid rgba(59, 130, 246, 0.8);
        }

        .ai-model-info h3 {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
            line-height: 1.3;
        }

        .ai-model-info .model-type {
            font-size: 0.9rem;
            color: #8b5cf6;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .ai-model-description {
            color: #6b7280;
            font-size: 1rem;
            line-height: 1.6;
            margin-bottom: 2rem;
            position: relative;
            z-index: 2;
        }

        .ai-model-features {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin-bottom: 1.5rem;
            position: relative;
            z-index: 2;
        }

        .feature-tag {
            background: rgba(139, 92, 246, 0.15);
            color: #a855f7;
            padding: 0.4rem 0.8rem;
            border-radius: 1rem;
            font-size: 0.8rem;
            font-weight: 500;
            border: 1px solid rgba(139, 92, 246, 0.2);
        }

        .ai-model-status {
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
            z-index: 2;
        }

        .status-badge {
            padding: 0.5rem 1rem;
            border-radius: 1.5rem;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-active {
            background: linear-gradient(135deg, #10b981, #059669);
            color: #ffffff;
            border: 1px solid rgba(16, 185, 129, 0.8);
            font-weight: 800;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
            box-shadow: 0 3px 10px rgba(16, 185, 129, 0.4);
            padding: 6px 12px;
            border-radius: 20px;
        }

        .status-beta {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: #ffffff;
            border: 1px solid rgba(245, 158, 11, 0.8);
            font-weight: 800;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
            box-shadow: 0 3px 10px rgba(245, 158, 11, 0.4);
            padding: 6px 12px;
            border-radius: 20px;
        }

        .status-coming {
            background: rgba(59, 130, 246, 0.2);
            color: #000000;
            border: 1px solid rgba(59, 130, 246, 0.4);
            font-weight: 700;
        }

        .accuracy-score {
            font-size: 0.9rem;
            color: var(--text-primary);
            font-weight: 600;
        }

        .accuracy-score .score {
            color: #10b981;
            font-size: 1.1rem;
        }

        .ai-model-card::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><circle cx="10" cy="10" r="1" fill="%23667eea" opacity="0.3"><animate attributeName="cy" values="10;90;10" dur="3s" repeatCount="indefinite"/></circle><circle cx="30" cy="30" r="1" fill="%23ff6b6b" opacity="0.3"><animate attributeName="cy" values="30;70;30" dur="4s" repeatCount="indefinite"/></circle><circle cx="70" cy="20" r="1" fill="%234ecdc4" opacity="0.3"><animate attributeName="cy" values="20;80;20" dur="5s" repeatCount="indefinite"/></circle></svg>') repeat;
            background-size: 100px 100px;
            opacity: 0;
            transition: opacity 0.4s ease;
            pointer-events: none;
        }

        .ai-model-card:hover::after {
            opacity: 0.6;
        }

        /* 사용자 리뷰 섹션 스타일 */
        .user-reviews-section {
            margin-top: 3rem;
            padding: 2rem;
            background: rgba(22, 197, 34, 0.03);
            border: 1px solid rgba(22, 197, 34, 0.1);
            border-radius: 1.5rem;
            backdrop-filter: blur(15px);
        }

        .reviews-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .reviews-header h3 {
            font-size: 1.5rem;
            color: #22c55e;
            margin: 0;
            font-weight: 700;
        }

        .overall-rating {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .rating-stars {
            display: flex;
            gap: 0.1rem;
        }

        .star {
            font-size: 1.2rem;
            color: #374151;
            transition: all 0.2s ease;
        }

        .star.filled {
            color: #fbbf24;
            text-shadow: 0 0 8px rgba(251, 191, 36, 0.4);
        }

        .star.half {
            background: linear-gradient(90deg, #fbbf24 50%, #374151 50%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .rating-score {
            font-size: 1.3rem;
            font-weight: 700;
            color: #22c55e;
        }

        .rating-count {
            font-size: 0.9rem;
            color: #6b7280;
        }

        .reviews-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }

        .review-card {
            background: rgba(22, 197, 34, 0.05);
            border: 1px solid rgba(22, 197, 34, 0.15);
            border-radius: 1rem;
            padding: 1.5rem;
            backdrop-filter: blur(10px);
            transition: all 0.3s ease;
        }

        .review-card:hover {
            background: rgba(22, 197, 34, 0.08);
            border-color: rgba(22, 197, 34, 0.25);
            transform: translateY(-3px);
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 1rem;
        }

        .reviewer-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .reviewer-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #22c55e, #16a34a);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 0.9rem;
            overflow: hidden;
        }

        .reviewer-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            border-radius: 50%;
        }

        .reviewer-details {
            display: flex;
            flex-direction: column;
        }

        .reviewer-name {
            font-weight: 600;
            color: #22c55e;
            font-size: 0.95rem;
        }

        .review-date {
            font-size: 0.8rem;
            color: #6b7280;
        }

        .review-rating {
            display: flex;
            gap: 0.1rem;
        }

        .review-rating .star {
            font-size: 1rem;
        }

        .review-text {
            color: #e5e7eb;
            line-height: 1.6;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }

        .review-helpful {
            display: flex;
            justify-content: flex-end;
        }

        .helpful-btn {
            background: rgba(22, 197, 34, 0.1);
            border: 1px solid rgba(22, 197, 34, 0.2);
            border-radius: 0.5rem;
            padding: 0.4rem 0.8rem;
            color: #22c55e;
            font-size: 0.8rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .helpful-btn:hover {
            background: rgba(22, 197, 34, 0.15);
            border-color: rgba(22, 197, 34, 0.3);
            transform: scale(1.05);
        }

        .review-actions {
            display: flex;
            justify-content: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .write-review-btn {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            border: none;
            border-radius: 0.75rem;
            padding: 0.75rem 1.5rem;
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .write-review-btn:hover {
            background: linear-gradient(135deg, #16a34a, #15803d);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(34, 197, 94, 0.3);
        }
        
        /* 리뷰 네비게이션 스타일 */
        .review-navigation {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            margin: 1.5rem 0;
        }
        
        .nav-btn {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-primary);
            cursor: pointer;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }
        
        .nav-btn:hover:not(:disabled) {
            background: rgba(255, 255, 255, 0.2);
            border-color: rgba(255, 255, 255, 0.4);
            transform: translateY(-2px);
        }
        
        .nav-btn:disabled {
            opacity: 0.3;
            cursor: not-allowed;
        }
        
        .page-info {
            color: var(--text-primary);
            font-weight: 600;
            font-size: 14px;
            min-width: 20px;
            text-align: center;
        }

        .view-all-reviews-btn {
            background: transparent;
            border: 1px solid rgba(22, 197, 34, 0.3);
            border-radius: 0.75rem;
            padding: 0.75rem 1.5rem;
            color: #22c55e;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .view-all-reviews-btn:hover {
            background: rgba(22, 197, 34, 0.1);
            border-color: rgba(22, 197, 34, 0.5);
            transform: translateY(-2px);
        }

        /* Mobile Responsive */
        @media (max-width: 1024px) {
            .ai-models-grid {
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 1.5rem;
            }
            
            .ai-models-title h2 {
                font-size: 2rem;
            }
        }

        @media (max-width: 768px) {
            .ai-models-section {
                margin-top: 3rem;
            }
            
            .ai-models-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
                padding: 0;
            }
            
            .ai-model-card {
                padding: 2rem;
                min-height: 240px;
            }
            
            .ai-models-title h2 {
                font-size: 1.8rem;
            }
            
            .ai-model-header {
                gap: 1rem;
                margin-bottom: 1.5rem;
            }
            
            .ai-model-icon {
                width: 3rem;
                height: 3rem;
                font-size: 1.5rem;
            }
        }

        /* Mobile Responsive */
        @media (max-width: 1024px) {
            .main-container {
                grid-template-columns: 1fr;
                gap: 1.5rem;
                max-width: 600px;
            }
            
            .main-title h1 {
                font-size: 2.5rem;
            }
            
            .main-title h1 .glow-text {
                text-shadow:
                    0 0 8px #00bfff,
                    0 0 16px #00bfff,
                    0 0 24px #00bfff,
                    0 0 32px #00bfff,
                    0 0 56px #00bfff,
                    0 0 64px #00bfff;
            }
            
            .ai-sphere-container {
                width: 18rem;
                height: 18rem;
            }
        }

        @media (max-width: 768px) {
            body {
                padding: 1rem;
            }
            
            .main-title h1 {
                font-size: 2rem;
            }
            
            .main-title h1 .glow-text {
                text-shadow:
                    0 0 6px #00bfff,
                    0 0 12px #00bfff,
                    0 0 18px #00bfff,
                    0 0 24px #00bfff,
                    0 0 42px #00bfff,
                    0 0 48px #00bfff;
            }
            
            .ai-sphere-container {
                width: 16rem;
                height: 16rem;
            }
            
            .features-grid {
                grid-template-columns: 1fr;
                margin-top: -4rem;
            }
            
            .card {
                padding: 1.75rem;
                min-height: 140px;
            }
            
            .promo-card h2 {
                font-size: 1.8rem;
            }
            
            .users-card .count {
                font-size: 2.2rem;
            }
            
            .stats-card .count {
                font-size: 2.5rem;
            }
            
            .feature-card {
                min-height: 160px;
            }
            
            .templates-card {
                min-height: 220px;
            }
            
            .wide-card {
                padding: 2rem;
                margin-top: 1rem;
                margin-bottom: 1.5rem;
                width: 100%;
                min-height: 180px;
            }
            
            .wide-card-content {
                flex-direction: column;
                text-align: center;
                gap: 1.5rem;
            }
            
            .wide-card-text h3 {
                font-size: 1.2rem;
            }
            
            .wide-card-text p {
                font-size: 1rem;
                margin-bottom: 1rem;
            }
            
            .wide-card-features {
                gap: 0.6rem;
            }
            
            .feature-item {
                justify-content: center;
                gap: 0.6rem;
            }
            
            .feature-icon {
                font-size: 1rem;
                width: 1.5rem;
                height: 1.5rem;
            }
            
            .feature-text {
                font-size: 0.9rem;
            }
            
            .wide-card-button {
                padding: 0.7rem 1.5rem;
                font-size: 0.9rem;
            }
            
            .side-feature-card {
                padding: 1.5rem;
                margin-top: 1rem;
                min-height: 160px;
            }
            
            .side-card-icon {
                width: 3rem;
                height: 3rem;
                margin-bottom: 1rem;
            }
            
            .side-card-icon svg {
                width: 1.5rem;
                height: 1.5rem;
            }
            
            .side-card-content h3 {
                font-size: 1.1rem;
            }
            
            .side-card-content p {
                font-size: 0.9rem;
                margin-bottom: 1rem;
            }
            
            .side-card-link {
                padding: 0.5rem 1rem;
                font-size: 0.85rem;
            }
        }

        /* Frutiger Button Styles (로그인 버튼) */
        .frutiger-button {
            cursor: pointer;
            position: relative;
            padding: 2px;
            border-radius: 6px;
            border: 0;
            text-shadow: 1px 1px #000a;
            background: linear-gradient(#006caa, #00c3ff);
            box-shadow: 0px 4px 6px 0px #0008;
            transition: 0.3s all;
            width: 100%;
            max-width: 280px;
            margin: 0 auto;
        }

        .frutiger-button:hover {
            box-shadow: 0px 6px 12px 0px #0009;
        }

        .frutiger-button:active {
            box-shadow: 0px 0px 0px 0px #0000;
        }

        .frutiger-button .inner {
            position: relative;
            inset: 0px;
            padding: 1em;
            border-radius: 4px;
            background: radial-gradient(circle at 50% 100%, #30f8f8 10%, #30f8f800 55%),
              linear-gradient(#00526a, #009dcd);
            overflow: hidden;
            transition: inherit;
        }

        .frutiger-button .inner::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(-65deg, #0000 40%, #fff7 50%, #0000 70%);
            background-size: 200% 100%;
            background-repeat: no-repeat;
            animation: thing 3s ease infinite;
        }

        @keyframes thing {
            0% {
                background-position: 130%;
                opacity: 1;
            }
            to {
                background-position: -166%;
                opacity: 0;
            }
        }

        .frutiger-button .top-white {
            position: absolute;
            border-radius: inherit;
            inset: 0 -8em;
            background: radial-gradient(
              circle at 50% -270%,
              #fff 45%,
              #fff6 60%,
              #fff0 60%
            );
            transition: inherit;
        }

        .frutiger-button .inner::after {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: inherit;
            transition: inherit;
            box-shadow: inset 0px 2px 8px -2px #0000;
        }

        .frutiger-button:active .inner::after {
            box-shadow: inset 0px 2px 8px -2px #000a;
        }

        .frutiger-button .text {
            position: relative;
            z-index: 1;
            color: white;
            font-weight: 550;
            font-family: sans-serif;
            transition: inherit;
            font-size: 0.9rem;
        }

        /* AI 채팅 Frutiger Button Styles (다른 색감) */
        .ai-chat-frutiger-btn {
            cursor: pointer;
            position: relative;
            padding: 2px;
            border-radius: 6px;
            border: 0;
            text-shadow: 1px 1px #000a;
            background: linear-gradient(#8b5cf6, #ec4899);
            box-shadow: 0px 4px 6px 0px #0008;
            transition: 0.3s all;
            width: 100%;
            max-width: 220px;
            margin: 0 auto;
        }

        .ai-chat-frutiger-btn:hover {
            box-shadow: 0px 6px 12px 0px #8b5cf690;
        }

        .ai-chat-frutiger-btn:active {
            box-shadow: 0px 0px 0px 0px #0000;
        }

        .ai-chat-frutiger-btn .inner {
            position: relative;
            inset: 0px;
            padding: 1em;
            border-radius: 4px;
            background: radial-gradient(circle at 50% 100%, #f4b1fd 10%, #f4b1fd00 55%),
              linear-gradient(#9333ea, #d946ef);
            overflow: hidden;
            transition: inherit;
        }

        .ai-chat-frutiger-btn .inner::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(-65deg, #0000 40%, #fff7 50%, #0000 70%);
            background-size: 200% 100%;
            background-repeat: no-repeat;
            animation: aiChatShine 3s ease infinite;
        }

        @keyframes aiChatShine {
            0% {
                background-position: 130%;
                opacity: 1;
            }
            to {
                background-position: -166%;
                opacity: 0;
            }
        }

        .ai-chat-frutiger-btn .top-white {
            position: absolute;
            border-radius: inherit;
            inset: 0 -8em;
            background: radial-gradient(
              circle at 50% -270%,
              #fff 45%,
              #fff6 60%,
              #fff0 60%
            );
            transition: inherit;
        }

        .ai-chat-frutiger-btn .inner::after {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: inherit;
            transition: inherit;
            box-shadow: inset 0px 2px 8px -2px #0000;
        }

        .ai-chat-frutiger-btn:active .inner::after {
            box-shadow: inset 0px 2px 8px -2px #000a;
        }

        .ai-chat-frutiger-btn .text {
            position: relative;
            z-index: 1;
            color: white;
            font-weight: 550;
            font-family: sans-serif;
            transition: inherit;
            font-size: 1rem;
        }

        /* btn2 Interactive Button Styles (로그인 상태별 버튼) */
        .btn2-button {
            --white: #ffe7ff;
            --purple-100: #f4b1fd;
            --purple-200: #d190ff;
            --purple-300: #c389f2;
            --purple-400: #8e26e2;
            --purple-500: #5e2b83;
            --radius: 18px;

            border-radius: var(--radius);
            outline: none;
            cursor: pointer;
            font-size: 16px;
            font-family: Arial, sans-serif;
            background: transparent;
            letter-spacing: -1px;
            border: 0;
            position: relative;
            width: 220px;
            height: 60px;
            transform: rotate(353deg) skewX(4deg);
            margin: 0 auto;
            z-index: 1000; /* 버튼 클릭 최우선 보장 */
        }

        .btn2-button .bg {
            position: absolute;
            inset: 0;
            border-radius: inherit;
            filter: blur(1px);
        }

        .btn2-button .bg::before,
        .btn2-button .bg::after {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: calc(var(--radius) * 1.1);
            background: var(--purple-500);
        }

        .btn2-button .bg::before {
            filter: blur(5px);
            transition: all 0.3s ease;
            box-shadow:
              -7px 6px 0 0 rgb(115 75 155 / 40%),
              -14px 12px 0 0 rgb(115 75 155 / 30%),
              -21px 18px 4px 0 rgb(115 75 155 / 25%),
              -28px 24px 8px 0 rgb(115 75 155 / 15%),
              -35px 30px 12px 0 rgb(115 75 155 / 12%),
              -42px 36px 16px 0 rgb(115 75 155 / 8%),
              -56px 42px 20px 0 rgb(115 75 155 / 5%);
        }

        /* 로그인 버튼 그림자 (초록색) */
        .btn2-button.login-btn .bg::before {
            box-shadow:
              -7px 6px 0 0 rgb(34 197 94 / 40%),
              -14px 12px 0 0 rgb(34 197 94 / 30%),
              -21px 18px 4px 0 rgb(34 197 94 / 25%),
              -28px 24px 8px 0 rgb(34 197 94 / 15%),
              -35px 30px 12px 0 rgb(34 197 94 / 12%),
              -42px 36px 16px 0 rgb(34 197 94 / 8%),
              -56px 42px 20px 0 rgb(34 197 94 / 5%);
        }

        /* 지금 사용해보세요 버튼 그림자 (하늘색) */
        .btn2-button.use-btn .bg::before {
            box-shadow:
              -7px 6px 0 0 rgb(14 165 233 / 40%),
              -14px 12px 0 0 rgb(14 165 233 / 30%),
              -21px 18px 4px 0 rgb(14 165 233 / 25%),
              -28px 24px 8px 0 rgb(14 165 233 / 15%),
              -35px 30px 12px 0 rgb(14 165 233 / 12%),
              -42px 36px 16px 0 rgb(14 165 233 / 8%),
              -56px 42px 20px 0 rgb(14 165 233 / 5%);
        }

        .btn2-button .wrap {
            border-radius: inherit;
            overflow: hidden;
            height: 100%;
            transform: translate(6px, -6px);
            padding: 3px;
            background: linear-gradient(to bottom, var(--purple-100) 0%, var(--purple-400) 100%);
            position: relative;
            transition: all 0.3s ease;
        }

        .btn2-button .content {
            pointer-events: none;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 1;
            position: relative;
            height: 100%;
            gap: 16px;
            border-radius: calc(var(--radius) * 0.85);
            font-weight: 600;
            transition: all 0.3s ease;
            background: linear-gradient(to bottom, var(--purple-300) 0%, var(--purple-400) 100%);
            box-shadow:
              inset -2px 12px 11px -5px var(--purple-200),
              inset 1px -3px 11px 0px rgb(0 0 0 / 35%);
        }

        .btn2-button .char {
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn2-button .char span {
            display: block;
            color: transparent;
            position: relative;
        }

        .btn2-button .char.state-1 span::before,
        .btn2-button .char span::after {
            content: attr(data-label);
            position: absolute;
            color: var(--white);
            text-shadow: -1px 1px 2px var(--purple-500);
            left: 0;
        }

        .btn2-button .char span::before {
            opacity: 0;
            transform: translateY(-100%);
        }

        .btn2-button .char.state-1 span::after {
            opacity: 1;
        }

        /* 버튼별 색상 차별화 */
        .btn2-button.login-btn {
            --purple-100: #bbf7d0;
            --purple-200: #86efac;
            --purple-300: #4ade80;
            --purple-400: #22c55e;
            --purple-500: #16a34a;
        }

        .btn2-button.use-btn {
            --purple-100: #e0f2fe;
            --purple-200: #bae6fd;
            --purple-300: #7dd3fc;
            --purple-400: #38bdf8;
            --purple-500: #0ea5e9;
        }

        /* 호버 효과 */
        .btn2-button:hover .wrap {
            transform: translate(8px, -8px);
        }

        .btn2-button:hover .char.state-1 span::before {
            animation: charAppear 0.7s ease calc(var(--i) * 0.03s);
        }

        .btn2-button:hover .char.state-1 span::after {
            opacity: 1;
            animation: charDisappear 0.7s ease calc(var(--i) * 0.03s);
        }

        .btn2-button:active .bg::before {
            filter: blur(5px);
            opacity: 0.7;
            box-shadow:
              -7px 6px 0 0 rgb(115 75 155 / 40%),
              -14px 12px 0 0 rgb(115 75 155 / 25%),
              -21px 18px 4px 0 rgb(115 75 155 / 15%);
        }

        /* 로그인 버튼 active 그림자 (초록색) */
        .btn2-button.login-btn:active .bg::before {
            box-shadow:
              -7px 6px 0 0 rgb(34 197 94 / 40%),
              -14px 12px 0 0 rgb(34 197 94 / 25%),
              -21px 18px 4px 0 rgb(34 197 94 / 15%);
        }

        /* 지금 사용해보세요 버튼 active 그림자 (하늘색) */
        .btn2-button.use-btn:active .bg::before {
            box-shadow:
              -7px 6px 0 0 rgb(14 165 233 / 40%),
              -14px 12px 0 0 rgb(14 165 233 / 25%),
              -21px 18px 4px 0 rgb(14 165 233 / 15%);
        }

        .btn2-button:active .content {
            box-shadow:
              inset -1px 12px 8px -5px rgba(71, 0, 137, 0.4),
              inset 0px -3px 8px 0px var(--purple-200);
        }

        .btn2-button:active .wrap {
            transform: translate(3px, -3px);
        }

        /* Frutiger Button Styles (AI 채팅 시작 버튼) */
        .generate-btn.frutiger-button {
            cursor: pointer;
            position: relative;
            padding: 2px;
            border-radius: 6px;
            border: 0;
            text-shadow: 1px 1px #000a;
            background: linear-gradient(#006caa, #00c3ff);
            box-shadow: 0px 4px 6px 0px #0008;
            transition: 0.3s all;
            margin: 0 auto;
            width: auto;
            min-width: 200px;
        }

        .generate-btn.frutiger-button:hover {
            box-shadow: 0px 6px 12px 0px #0009;
        }

        .generate-btn.frutiger-button:active {
            box-shadow: 0px 0px 0px 0px #0000;
        }

        .generate-btn.frutiger-button .inner {
            position: relative;
            inset: 0px;
            padding: 1em 1.5em;
            border-radius: 4px;
            background: radial-gradient(circle at 50% 100%, #30f8f8 10%, #30f8f800 55%),
              linear-gradient(#00526a, #009dcd);
            overflow: hidden;
            transition: inherit;
            min-width: 250px;
        }

        .generate-btn.frutiger-button .inner::before {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(-65deg, #0000 40%, #fff7 50%, #0000 70%);
            background-size: 200% 100%;
            background-repeat: no-repeat;
            animation: thing 3s ease infinite;
        }

        @keyframes thing {
            0% {
                background-position: 130%;
                opacity: 1;
            }
            to {
                background-position: -166%;
                opacity: 0;
            }
        }

        .generate-btn.frutiger-button .top-white {
            position: absolute;
            border-radius: inherit;
            inset: 0 -8em;
            background: radial-gradient(
              circle at 50% -270%,
              #fff 45%,
              #fff6 60%,
              #fff0 60%
            );
            transition: inherit;
        }

        .generate-btn.frutiger-button .inner::after {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: inherit;
            transition: inherit;
            box-shadow: inset 0px 2px 8px -2px #0000;
        }

        .generate-btn.frutiger-button:active .inner::after {
            box-shadow: inset 0px 2px 8px -2px #000a;
        }

        .generate-btn.frutiger-button .text {
            position: relative;
            z-index: 1;
            color: white;
            font-weight: 550;
            font-family: sans-serif;
            transition: inherit;
            font-size: 1rem;
        }

        /* Interactive Button Animations */
        @keyframes charAppear {
            0% { transform: translateY(50%); opacity: 0; filter: blur(20px); }
            20% { transform: translateY(70%); opacity: 1; }
            50% { transform: translateY(-15%); opacity: 1; filter: blur(0); }
            100% { transform: translateY(0); opacity: 1; }
        }

        @keyframes charDisappear {
            0% { transform: translateY(0); opacity: 1; }
            100% { transform: translateY(-70%); opacity: 0; filter: blur(3px); }
        }

        /* Interactive Button Styles Complete */
        
        /* ================== 패킹 어시스턴트 로딩 스타일 ================== */
        .packing-loading-container {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 10px 0;
        }
        
        .packing-spinner {
            display: flex;
            gap: 8px;
        }
        
        .spinner-circle {
            width: 12px;
            height: 12px;
            background: linear-gradient(135deg, #8b5cf6, #ec4899);
            border-radius: 50%;
            animation: packing-bounce 1.4s ease-in-out infinite both;
        }
        
        .spinner-circle:nth-child(1) { animation-delay: -0.32s; }
        .spinner-circle:nth-child(2) { animation-delay: -0.16s; }
        .spinner-circle:nth-child(3) { animation-delay: 0s; }
        
        @keyframes packing-bounce {
            0%, 80%, 100% {
                transform: scale(0.6);
                opacity: 0.7;
            }
            40% {
                transform: scale(1);
                opacity: 1;
            }
        }
        
        .loading-text {
            flex: 1;
        }
        
        .loading-text p {
            margin: 0 0 8px 0;
            font-size: 14px;
            color: #9ca3af;
            font-weight: 500;
        }
        
        .loading-dots {
            display: flex;
            gap: 4px;
        }
        
        .loading-dots .dot {
            width: 6px;
            height: 6px;
            background: #8b5cf6;
            border-radius: 50%;
            animation: loading-dots 1.5s ease-in-out infinite;
        }
        
        .loading-dots .dot:nth-child(1) { animation-delay: 0s; }
        .loading-dots .dot:nth-child(2) { animation-delay: 0.2s; }
        .loading-dots .dot:nth-child(3) { animation-delay: 0.4s; }
        
        @keyframes loading-dots {
            0%, 60%, 100% {
                opacity: 0.3;
                transform: scale(0.8);
            }
            30% {
                opacity: 1;
                transform: scale(1);
            }
        }
        
        .loading-message {
            animation: fadeInUp 0.3s ease-out, pulse 2s ease-in-out infinite;
            background: rgba(139, 92, 246, 0.05);
            border: 1px solid rgba(139, 92, 246, 0.2);
            border-radius: 15px;
            padding: 15px;
            margin: 10px 0;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(10px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes pulse {
            0%, 100% {
                box-shadow: 0 0 0 0 rgba(139, 92, 246, 0.3);
            }
            50% {
                box-shadow: 0 0 0 8px rgba(139, 92, 246, 0);
            }
        }

        /* Interactive Button Animations */
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @keyframes charAppear {
            0% { transform: translateY(50%); opacity: 0; filter: blur(20px); }
            20% { transform: translateY(70%); opacity: 1; }
            50% { transform: translateY(-15%); opacity: 1; filter: blur(0); }
            100% { transform: translateY(0); opacity: 1; }
        }

        @keyframes charDisappear {
            0% { transform: translateY(0); opacity: 1; }
            100% { transform: translateY(-70%); opacity: 0; filter: blur(3px); }
        }

        /* Keyframes for button animations */

        /* Button hover states cleaned up */

        /* Modal styles for popup */
        .popup-modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, 
                rgba(102, 126, 234, 0.3) 0%, 
                rgba(118, 75, 162, 0.3) 100%);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            animation: modalFadeIn 0.4s ease-out;
        }

        .popup-modal-content {
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            margin: 1% auto;
            padding: 0;
            border-radius: 25px;
            width: 95%;
            max-width: 1200px;
            height: 95vh;
            overflow: hidden;
            position: relative;
            box-shadow: 
                0 25px 50px rgba(0, 0, 0, 0.15),
                0 0 0 1px rgba(255, 255, 255, 0.2),
                inset 0 1px 0 rgba(255, 255, 255, 0.4);
            animation: modalSlideIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        .popup-modal-header {
            background: linear-gradient(135deg, 
                rgba(102, 126, 234, 0.8) 0%, 
                rgba(118, 75, 162, 0.8) 100%);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            color: white;
            padding: 25px 30px;
            border-radius: 25px 25px 0 0;
            position: relative;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .popup-modal-header h2 {
            font-size: 1.8em;
            font-weight: 600;
            margin: 0;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
        }

        .popup-close {
            position: absolute;
            right: 25px;
            top: 50%;
            transform: translateY(-50%);
            color: rgba(255, 255, 255, 0.9);
            font-size: 2em;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.1);
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .popup-close:hover {
            color: white;
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-50%) scale(1.1) rotate(90deg);
        }

        .popup-modal-body {
            padding: 0;
            height: calc(95vh - 100px);
            overflow: hidden;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 0 0 25px 25px;
        }

        .popup-modal-body iframe {
            width: 100%;
            height: 100%;
            border: none;
            border-radius: 0 0 25px 25px;
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
                backdrop-filter: blur(0px);
            }
            to {
                opacity: 1;
                backdrop-filter: blur(20px);
            }
        }

        @keyframes modalSlideIn {
            from {
                transform: translate(-50%, -50%) translateY(-50px) scale(0.9);
                opacity: 0;
            }
            to {
                transform: translate(-50%, -50%) translateY(0) scale(1);
                opacity: 1;
            }
        }
        }

        /* 글래즈모피즘 리뷰 팝업 스타일 */
        .glassmorphism-modal {
            display: none;
            position: fixed;
            z-index: 10000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(10, 6, 32, 0.8);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            animation: modalFadeIn 0.3s ease-out;
        }

        .glassmorphism-modal-content {
            background: rgba(20, 20, 30, 0.95);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 0;
            width: 95%;
            max-width: 600px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
            animation: modalSlideIn 0.4s ease-out;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            z-index: 10001;
        }

        .glassmorphism-modal-content.large {
            max-width: 900px;
            max-height: 90vh;
            overflow-y: auto;
            width: 90%;
        }

        .glassmorphism-modal-header {
            background: rgba(40, 40, 50, 0.8);
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px 20px 0 0;
            padding: 1.5rem 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .glassmorphism-modal-header h2 {
            margin: 0;
            color: #ffffff;
            font-size: 1.5rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            text-shadow: 0 1px 2px rgba(0, 0, 0, 0.8);
        }

        .glassmorphism-close {
            color: rgba(255, 255, 255, 0.8);
            font-size: 2rem;
            font-weight: bold;
            cursor: pointer;
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.1);
        }

        .glassmorphism-close:hover {
            color: #ffffff;
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }

        .glassmorphism-modal-body {
            padding: 2rem;
            color: #ffffff;
            background: rgba(30, 30, 40, 0.6);
            border-radius: 0 0 20px 20px;
        }

        /* 폼 스타일 */
        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: rgba(255, 255, 255, 0.9);
            font-weight: 500;
        }

        .form-group input,
        .form-group textarea,
        .form-group select {
            width: 100%;
            padding: 0.75rem 1rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 10px;
            color: white;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus {
            outline: none;
            border-color: rgba(139, 92, 246, 0.5);
            background: rgba(255, 255, 255, 0.15);
            box-shadow: 0 0 0 3px rgba(139, 92, 246, 0.1);
        }

        .form-group input::placeholder,
        .form-group textarea::placeholder {
            color: rgba(255, 255, 255, 0.5);
        }

        .form-group textarea {
            min-height: 120px;
            resize: vertical;
        }

        .char-count {
            text-align: right;
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.6);
            margin-top: 0.25rem;
        }

        /* 평점 입력 스타일 */
        .rating-input {
            display: flex;
            gap: 0.25rem;
            margin-bottom: 0.5rem;
        }

        .rating-star {
            font-size: 2rem;
            color: rgba(255, 255, 255, 0.3);
            cursor: pointer;
            transition: all 0.2s ease;
            user-select: none;
        }

        .rating-star:hover,
        .rating-star.active {
            color: #ffd700;
            transform: scale(1.1);
        }

        /* 체크박스 스타일 */
        .checkbox-label {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            cursor: pointer;
            font-size: 0.9rem;
        }

        .checkbox-label input[type="checkbox"] {
            display: none;
        }

        .checkmark {
            width: 20px;
            height: 20px;
            background: rgba(255, 255, 255, 0.1);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 4px;
            position: relative;
            transition: all 0.3s ease;
        }

        .checkbox-label input[type="checkbox"]:checked + .checkmark {
            background: rgba(139, 92, 246, 0.8);
            border-color: #8b5cf6;
        }

        .checkbox-label input[type="checkbox"]:checked + .checkmark::after {
            content: '✓';
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 0.8rem;
            font-weight: bold;
        }

        /* 모달 액션 버튼 */
        .modal-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            margin-top: 2rem;
        }

        .btn-cancel,
        .btn-submit {
            padding: 0.75rem 2rem;
            border: none;
            border-radius: 10px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            backdrop-filter: blur(10px);
        }

        .btn-cancel {
            background: rgba(255, 255, 255, 0.1);
            color: rgba(255, 255, 255, 0.8);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .btn-cancel:hover {
            background: rgba(255, 255, 255, 0.2);
            color: white;
        }

        .btn-submit {
            background: linear-gradient(135deg, #8b5cf6, #ec4899);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(139, 92, 246, 0.3);
        }

        .btn-submit:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        /* 리뷰 통계 스타일 */
        .review-stats {
            display: flex;
            gap: 2rem;
            margin-bottom: 2rem;
            padding: 1.5rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .overall-rating-large {
            text-align: center;
            min-width: 150px;
        }

        .rating-number {
            font-size: 3rem;
            font-weight: bold;
            color: #ffd700;
            margin-bottom: 0.5rem;
        }

        .rating-stars-large {
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }

        .rating-count-large {
            color: rgba(255, 255, 255, 0.7);
            font-size: 0.9rem;
        }

        .rating-breakdown {
            flex: 1;
        }

        /* 필터 및 정렬 */
        .review-filters {
            display: flex;
            gap: 1.5rem;
            margin-bottom: 1.5rem;
            padding: 1rem;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .filter-group label {
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.8);
            margin: 0;
        }

        .filter-group select {
            padding: 0.5rem;
            font-size: 0.8rem;
            min-width: 120px;
        }

        /* 리뷰 목록 */
        .all-reviews-container {
            max-height: 400px;
            overflow-y: auto;
            padding-right: 0.5rem;
        }

        /* 페이징 */
        .pagination {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 1.5rem;
        }

        .pagination button {
            padding: 0.5rem 1rem;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 8px;
            color: rgba(255, 255, 255, 0.8);
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .pagination button:hover {
            background: rgba(255, 255, 255, 0.2);
            color: white;
        }

        .pagination button.active {
            background: linear-gradient(135deg, #8b5cf6, #ec4899);
            color: white;
            border-color: transparent;
        }

        .pagination button:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }

        /* 리뷰 카드 업데이트 */
        .review-card {
            background: rgba(40, 40, 50, 0.8);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1rem;
            transition: all 0.3s ease;
        }

        .review-card:hover {
            background: rgba(50, 50, 60, 0.9);
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
        }

        .review-model-badge {
            margin: 0.5rem 0;
        }

        .model-name-badge {
            display: inline-block;
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 1rem;
            font-size: 0.75rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .review-title {
            color: #ffffff;
            font-size: 1.1rem;
            font-weight: 600;
            margin: 0.5rem 0;
        }

        .review-text {
            color: rgba(255, 255, 255, 0.8);
            line-height: 1.6;
            margin: 1rem 0;
        }

        .helpful-btn {
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            padding: 0.5rem 1rem;
            color: rgba(255, 255, 255, 0.8);
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 0.85rem;
        }

        .helpful-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            color: #ffffff;
            transform: translateY(-1px);
        }

        .helpful-btn.active {
            background: linear-gradient(135deg, #8b5cf6, #ec4899);
            color: white;
            border-color: transparent;
        }

        /* 모달 내 리뷰어 정보 스타일 */
        .glassmorphism-modal .reviewer-name {
            color: #ffffff !important;
            font-weight: 600;
        }

        .glassmorphism-modal .review-date {
            color: rgba(255, 255, 255, 0.6) !important;
        }

        .glassmorphism-modal .star {
            color: #fbbf24;
        }

        .recommended-badge {
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: white;
            padding: 0.25rem 0.75rem;
            border-radius: 15px;
            font-size: 0.8rem;
            margin-left: 0.5rem;
        }

        .no-reviews {
            text-align: center;
            padding: 3rem;
            color: rgba(255, 255, 255, 0.6);
            font-style: italic;
        }

        /* 반응형 */
        @media (max-width: 768px) {
            .glassmorphism-modal-content {
                width: 95%;
                top: 50%;
                left: 50%;
                transform: translate(-50%, -50%);
            }
            
            .glassmorphism-modal-body {
                padding: 1.5rem;
            }
            
            .review-stats {
                flex-direction: column;
                gap: 1rem;
            }
            
            .review-filters {
                flex-direction: column;
                gap: 1rem;
            }
            
            .modal-actions {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <%@ include file="../common/header.jsp" %>
    
    <!-- Background elements from color/back.html -->
    <div class="bg-gradient"></div>
    <canvas id="particles"></canvas>

    <main class="main-container">
        <!-- 마우스 추적을 위한 15개 영역 추가 (전체 추적 가능) -->
        <div class="area"></div>  <!-- 1: left top -->
        <div class="area"></div>  <!-- 2: center-left top -->
        <div class="area"></div>  <!-- 3: center top -->
        <div class="area"></div>  <!-- 4: center-right top -->
        <div class="area"></div>  <!-- 5: right top -->
        <div class="area"></div>  <!-- 6: left middle -->
        <div class="area"></div>  <!-- 7: center-left middle -->
        <div class="area"></div>  <!-- 8: center middle -->
        <div class="area"></div>  <!-- 9: center-right middle -->
        <div class="area"></div>  <!-- 10: right middle -->
        <div class="area"></div>  <!-- 11: left bottom -->
        <div class="area"></div>  <!-- 12: center-left bottom -->
        <div class="area"></div>  <!-- 13: center bottom -->
        <div class="area"></div>  <!-- 14: center-right bottom -->
        <div class="area"></div>  <!-- 15: right bottom -->
        
        <div class="left-column">
            <div class="card promo-card">
                <div class="logo">
                    <img src="${pageContext.request.contextPath}/resources/img/cl.png" alt="Claude Logo" style="width: 100%; height: 100%; object-fit: contain;">
                </div>
                <h2>지능형 여행 AI 모델</h2>
                <p class="trial-info">Claude 3.5 Sonnet 모델</p>
                <p class="trial-info">실시간 맞춤형 추천</p>
            </div>
            <div class="card users-card">
                <span class="count">${activeMemberCount}</span>
                <span class="label">가입한 사용자</span>
                <div class="user-avatars">
                    <!-- 항상 안전한 기본 아바타 이미지 사용 -->
                    <img src="https://i.pravatar.cc/40?img=1" alt="사용자" title="사용자">
                    <img src="https://i.pravatar.cc/40?img=2" alt="사용자" title="사용자">
                    <img src="https://i.pravatar.cc/40?img=3" alt="사용자" title="사용자">
                </div>
            </div>
            <button class="generate-btn frutiger-button" onclick="window.location.href='${pageContext.request.contextPath}/ai/chat'">
                <div class="inner">
                    <div class="top-white"></div>
                    <span class="text">AI 채팅 시작하기</span>
                </div>
            </button>
            
            <!-- New card below AI chat button -->
            <div class="card side-feature-card">
                <div class="side-card-icon">
                    <svg viewBox="0 0 24 24" fill="currentColor">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.94-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
                    </svg>
                </div>
                <div class="side-card-content">
                    <h3>여행 동행 찾기</h3>
                    <p>MBTI 기반 맞춤 동행자를 찾아보세요</p>
                    <a href="${pageContext.request.contextPath}/travel-mbti/matching" class="side-card-link">
                        동행 찾기
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
                        </svg>
                    </a>
                </div>
            </div>
        </div>

        <div class="center-column">
            <div class="main-title">
                <h1 data-text="AI 여행 추천 모델">
                    <span class="glow-text">AI 여행 추천 모델</span>
                </h1>
            </div>
            <div class="ai-sphere-container container-ai-input" id="sphereContainer">
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <div class="area"></div>
                <label class="container-wrap">
                    <input type="checkbox" />
                    <!-- Satellite Particles Container -->
                    <div class="satellite-particles">
                        <div class="satellite-orbit orbit-1">
                            <div class="satellite-particle particle-1"></div>
                        </div>
                        <div class="satellite-orbit orbit-2">
                            <div class="satellite-particle particle-2"></div>
                        </div>
                        <div class="satellite-orbit orbit-3">
                            <div class="satellite-particle particle-3"></div>
                        </div>
                        <div class="satellite-orbit orbit-4">
                            <div class="satellite-particle particle-4"></div>
                        </div>
                        <div class="satellite-orbit orbit-5">
                            <div class="satellite-particle particle-5"></div>
                        </div>
                        <div class="satellite-orbit orbit-6">
                            <div class="satellite-particle particle-6"></div>
                        </div>
                    </div>
                    <div class="card aimo-card">
                        <div class="background-blur-balls">
                            <div class="balls">
                                <span class="ball rosa"></span>
                                <span class="ball violet"></span>
                                <span class="ball green"></span>
                                <span class="ball cyan"></span>
                            </div>
                        </div>
                        <div class="content-card">
                            <div class="background-blur-card">
                                <div class="eyes">
                                    <span class="eye"></span>
                                    <span class="eye"></span>
                                </div>
                                <div class="eyes happy">
                                    <svg fill="none" viewBox="0 0 24 24">
                                        <path fill="currentColor" d="M8.28386 16.2843C8.9917 15.7665 9.8765 14.731 12 14.731C14.1235 14.731 15.0083 15.7665 15.7161 16.2843C17.8397 17.8376 18.7542 16.4845 18.9014 15.7665C19.4323 13.1777 17.6627 11.1066 17.3088 10.5888C16.3844 9.23666 14.1235 8 12 8C9.87648 8 7.61556 9.23666 6.69122 10.5888C6.33728 11.1066 4.56771 13.1777 5.09858 15.7665C5.24582 16.4845 6.16034 17.8376 8.28386 16.2843Z"></path>
                                    </svg>
                                    <svg fill="none" viewBox="0 0 24 24">
                                        <path fill="currentColor" d="M8.28386 16.2843C8.9917 15.7665 9.8765 14.731 12 14.731C14.1235 14.731 15.0083 15.7665 15.7161 16.2843C17.8397 17.8376 18.7542 16.4845 18.9014 15.7665C19.4323 13.1777 17.6627 11.1066 17.3088 10.5888C16.3844 9.23666 14.1235 8 12 8C9.87648 8 7.61556 9.23666 6.69122 10.5888C6.33728 11.1066 4.56771 13.1777 5.09858 15.7665C5.24582 16.4845 6.16034 17.8376 8.28386 16.2843Z"></path>
                                    </svg>
                                </div>
                            </div>
                        </div>
                    </div>
                </label>
            </div>
            <div class="features-grid">
                <div class="card feature-card">
                    <div class="icon">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M14 20v-2h2.6l-3.3-3.3c-.4-.4-.4-1 0-1.4s1-.4 1.4 0L18 16.6V14h2v6h-6zm-8-8H4V6h6v2H7.4l3.3 3.3c.4.4.4 1 0 1.4s-1 .4-1.4 0L6 9.4V12z"/>
                        </svg>
                    </div>
                    <h3>맞춤형 추천</h3>
                    <p>개인 취향과 MBTI 분석을 통한 여행지 추천</p>
                </div>
                <div class="card feature-card">
                    <div class="icon">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                        </svg>
                    </div>
                    <h3>실시간 분석</h3>
                    <p>최신 데이터를 활용한 정확한 여행 정보 제공</p>
                </div>
            </div>
            
            <!-- Wide horizontal card -->
            <div class="card wide-card">
                <div class="wide-card-content">
                    <div class="wide-card-icon">
                        <svg viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                        </svg>
                    </div>
                    <div class="wide-card-text">
                        <h3>프리미엄 AI 여행 플래너</h3>
                        <p>개인 맞춤형 여행 계획부터 실시간 추천까지, 완벽한 여행을 위한 모든 기능을 경험해보세요</p>
                        <div class="wide-card-features">
                            <div class="feature-item">
                                <span class="feature-icon">🎯</span>
                                <span class="feature-text">MBTI 기반 맞춤 추천</span>
                            </div>
                            <div class="feature-item">
                                <span class="feature-icon">⚡</span>
                                <span class="feature-text">실시간 여행 정보</span>
                            </div>
                            <div class="feature-item">
                                <span class="feature-icon">🌟</span>
                                <span class="feature-text">AI 동행자 매칭</span>
                            </div>
                        </div>
                    </div>
                    <div class="wide-card-action">
                        <a href="${pageContext.request.contextPath}/travel/create" class="wide-card-button">
                            여행 계획 시작하기
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6-1.41-1.41z"/>
                            </svg>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="right-column">
            <div class="card top-icon-card">
                <c:choose>
                    <c:when test="${empty sessionScope.loginUser}">
                        <button class="btn2-button login-btn" onclick="window.location.href='${pageContext.request.contextPath}/member/login'">
                            <div class="bg"></div>
                            <div class="wrap">
                                <div class="content">
                                    <span class="char state-1">
                                        <span data-label="로" style="--i: 1">로</span>
                                        <span data-label="그" style="--i: 2">그</span>
                                        <span data-label="인" style="--i: 3">인</span>
                                        <span data-label="하" style="--i: 4">하</span>
                                        <span data-label="세" style="--i: 5">세</span>
                                        <span data-label="요" style="--i: 6">요</span>
                                    </span>
                                </div>
                            </div>
                        </button>
                    </c:when>
                    <c:otherwise>
                        <button class="btn2-button use-btn" onclick="window.location.href='${pageContext.request.contextPath}/ai/chat'">
                            <div class="bg"></div>
                            <div class="wrap">
                                <div class="content">
                                    <span class="char state-1">
                                        <span data-label="지" style="--i: 1">지</span>
                                        <span data-label="금" style="--i: 2">금</span>
                                        <span data-label=" " style="--i: 3">&nbsp;</span>
                                        <span data-label="사" style="--i: 4">사</span>
                                        <span data-label="용" style="--i: 5">용</span>
                                        <span data-label="하" style="--i: 6">하</span>
                                        <span data-label="세" style="--i: 7">세</span>
                                        <span data-label="요" style="--i: 8">요</span>
                                    </span>
                                </div>
                            </div>
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="card review-slideshow-card">
                <div class="review-slideshow">
                    <div class="review-slide active">
                        <div class="stars">⭐⭐⭐⭐⭐</div>
                        <p>"AI 매칭으로 정말 잘 맞는 동행자를 만났어요!"</p>
                        <div class="reviewer">김민지</div>
                    </div>
                    <div class="review-slide">
                        <div class="stars">⭐⭐⭐⭐⭐</div>
                        <p>"안전하고 믿을 만한 동행자를 찾을 수 있어서 정말 좋았어요."</p>
                        <div class="reviewer">박서준</div>
                    </div>
                    <div class="review-slide">
                        <div class="stars">⭐⭐⭐⭐⭐</div>
                        <p>"AI 분석 결과가 정말 정확해요! 여행이 더욱 즐거웠습니다."</p>
                        <div class="reviewer">이지은</div>
                    </div>
                    <div class="review-slide">
                        <div class="stars">⭐⭐⭐⭐⭐</div>
                        <p>"새로운 친구도 사귀고 잊지 못할 추억을 만들었습니다."</p>
                        <div class="reviewer">최현우</div>
                    </div>
                    <div class="review-slide">
                        <div class="stars">⭐⭐⭐⭐⭐</div>
                        <p>"비슷한 관심사를 가진 동행자들과 함께해서 즐거웠어요."</p>
                        <div class="reviewer">윤다영</div>
                    </div>
                </div>
            </div>
            <div class="card templates-card">
                <div class="trial-badge">AI 기반</div>
                <h3>AI 모델 템플릿</h3>
                <p>다양한 여행 시나리오를 위한 AI 모델을 활용하세요.</p>
                <div class="template-graphic">
                    <div class="graphic-item rewrite">Claude</div>
                    <div class="graphic-item file ai">AI</div>
                    <div class="graphic-item file gpt">GPT</div>
                    <div class="graphic-item file claude">모델</div>
                    <div class="graphic-item dot dot-1"></div>
                    <div class="graphic-item dot dot-2"></div>
                </div>
                
                <div class="model-quick-info">
                    <span class="quick-tag">🚀 최신 AI</span>
                    <span class="quick-tag">⭐ 실시간</span>
                    <span class="quick-tag">🔒 안전</span>
                </div>
                
                <!-- 실시간 성능 지표 -->
                <div class="model-performance">
                    <div class="performance-header">
                        <h4>실시간 성능</h4>
                        <div class="status-indicator online"></div>
                    </div>
                    <div class="performance-metrics">
                        <div class="metric">
                            <span class="metric-value" id="response-time">1.2</span>
                            <span class="metric-unit">ms</span>
                            <span class="metric-label">응답속도</span>
                        </div>
                        <div class="metric">
                            <span class="metric-value" id="accuracy">98.5</span>
                            <span class="metric-unit">%</span>
                            <span class="metric-label">정확도</span>
                        </div>
                        <div class="metric">
                            <span class="metric-value" id="usage-today">2.4</span>
                            <span class="metric-unit">K</span>
                            <span class="metric-label">오늘 사용</span>
                        </div>
                    </div>
                </div>
                
                <!-- 모델 비교 도구 -->
                <div class="model-comparison">
                    <button class="comparison-btn" onclick="openModelComparison()">
                        <i class="fas fa-balance-scale"></i>
                        모델 비교하기
                    </button>
                </div>
            </div>
        </div>
    </main>

    <!-- AI Models Section -->
    <section class="ai-models-section">
        <div class="ai-models-title">
            <h2>AI 모델 라이브러리</h2>
            <p>다양한 여행 시나리오에 특화된 6가지 AI 모델을 만나보세요</p>
        </div>
        
        <div class="ai-models-grid">
            <!-- MBTI 매칭 모델 -->
            <div class="ai-model-card" onclick="selectModel('mbti-matching')">
                <div class="ai-model-3d">
                    <div class="ai-model-logo">
                        <span class="logo-circle logo-circle1"></span>
                        <span class="logo-circle logo-circle2"></span>
                        <span class="logo-circle logo-circle3"></span>
                        <span class="logo-circle logo-circle4">🧠</span>
                    </div>
                    <div class="ai-model-glass"></div>
                    <div class="ai-model-content">
                        <span class="ai-model-title">MBTI 매칭</span>
                        <span class="ai-model-type">Personality Model</span>
                        <span class="ai-model-description">성격 유형 분석을 통해 개인에게 최적화된 여행지와 동행자를 매칭해주는 AI 모델입니다.</span>
                    </div>
                    <div class="ai-model-bottom">
                        <div class="ai-model-info-row">
                            <div class="ai-model-features">
                                <span class="ai-model-feature-tag">16가지 MBTI</span>
                                <span class="ai-model-feature-tag">성향 분석</span>
                                <span class="ai-model-feature-tag">동행 매칭</span>
                            </div>
                            <div class="ai-model-status">
                                <span class="ai-model-status-badge status-active">활성</span>
                                <div class="ai-model-accuracy">정확도: 94.2%</div>
                            </div>
                        </div>
                        <div class="ai-model-actions">
                            <a href="${pageContext.request.contextPath}/travel-mbti/test" class="ai-model-btn primary">
                                🧠 테스트 시작
                            </a>
                            <button onclick="window.location.href='${pageContext.request.contextPath}/travel-mbti/matching'" class="ai-model-btn secondary">
                                📊 매칭 시작
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 여행 플레이리스트 추천 모델 -->
            <div class="ai-model-card" onclick="selectModel('claude-3-5-sonnet')">
                <div class="ai-model-3d">
                    <div class="ai-model-logo">
                        <span class="logo-circle logo-circle1"></span>
                        <span class="logo-circle logo-circle2"></span>
                        <span class="logo-circle logo-circle3"></span>
                        <span class="logo-circle logo-circle4">🎵</span>
                    </div>
                    <div class="ai-model-glass"></div>
                    <div class="ai-model-content">
                        <span class="ai-model-title">여행 플레이리스트 </span>
                        <span class="ai-model-type">Music Recommendation</span>
                        <span class="ai-model-description">여행지의 분위기와 개인 취향을 분석하여 완벽한 여행 플레이리스트를 생성합니다.</span>
                    </div>
                    <div class="ai-model-bottom">
                        <div class="ai-model-info-row">
                            <div class="ai-model-features">
                                <span class="ai-model-feature-tag">분위기 분석</span>
                                <span class="ai-model-feature-tag">음악 큐레이션</span>
                                <span class="ai-model-feature-tag">실시간 추천</span>
                            </div>
                            <div class="ai-model-status">
                                <span class="ai-model-status-badge status-beta">베타</span>
                                <div class="ai-model-accuracy">정확도: 87.9%</div>
                            </div>
                        </div>
                        <div class="ai-model-actions">
                            <a href="#" class="ai-model-btn primary" onclick="openPlaylistModal()">
                                🎵 버튼으로 선택
                            </a>
                             <a href="#" class="ai-model-btn secondary">
                                📅 채팅으로 하기
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- AI 지도 모델 -->
            <div class="ai-model-card" onclick="selectModel('claude-3-haiku')">
                <div class="ai-model-3d">
                    <div class="ai-model-logo">
                        <span class="logo-circle logo-circle1"></span>
                        <span class="logo-circle logo-circle2"></span>
                        <span class="logo-circle logo-circle3"></span>
                        <span class="logo-circle logo-circle4">🗺️</span>
                    </div>
                    <div class="ai-model-glass"></div>
                    <div class="ai-model-content">
                        <span class="ai-model-title">AI 지도 </span>
                        <span class="ai-model-type">Navigation System</span>
                        <span class="ai-model-description">실시간 교통 상황과 개인 선호도를 고려한 최적 경로와 숨겨진 명소를 추천합니다.</span>
                    </div>
                    <div class="ai-model-bottom">
                        <div class="ai-model-info-row">
                            <div class="ai-model-features">
                                <span class="ai-model-feature-tag">실시간 경로</span>
                                <span class="ai-model-feature-tag">숨은 명소</span>
                                <span class="ai-model-feature-tag">교통 분석</span>
                            </div>
                            <div class="ai-model-status">
                                <span class="ai-model-status-badge status-active">활성</span>
                                <div class="ai-model-accuracy">정확도: 96.7%</div>
                            </div>
                        </div>
                        <div class="ai-model-actions">
                            <a href="${pageContext.request.contextPath}/map/sido" class="ai-model-btn secondary">
                                📍 AI 여행 지도
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 감정 분석 여행 추천 모델 -->
            <div class="ai-model-card" onclick="selectModel('gpt-4o')">
                <div class="ai-model-3d">
                    <div class="ai-model-logo">
                        <span class="logo-circle logo-circle1"></span>
                        <span class="logo-circle logo-circle2"></span>
                        <span class="logo-circle logo-circle3"></span>
                        <span class="logo-circle logo-circle4">💫</span>
                    </div>
                    <div class="ai-model-glass"></div>
                    <div class="ai-model-content">
                        <span class="ai-model-title">패킹 어시스턴트</span>
                        <span class="ai-model-type">Packing Assistant</span>
                        <span class="ai-model-description">여행 준비를 도와줄 맞춤형 짐 싸기 리스트를 생성하는 모델입니다.</span>
                    </div>
                    <div class="ai-model-bottom">
                        <div class="ai-model-info-row">
                            <div class="ai-model-features">
                                <span class="ai-model-feature-tag">준비물</span>
                                <span class="ai-model-feature-tag">여행 물품</span>
                                <span class="ai-model-feature-tag">수하물 규정</span>
                            </div>
                            <div class="ai-model-status">
                                <span class="ai-model-status-badge status-beta">베타</span>
                                <div class="ai-model-accuracy">정확도: 91.4%</div>
                            </div>
                        </div>
                        <div class="ai-model-actions">
                            <a href="javascript:void(0)" class="ai-model-btn primary" onclick="openPackingAssistant(); return false;">
                                💫 물품 추천
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 날씨 예측 여행 모델 -->
            <div class="ai-model-card" onclick="selectModel('gpt-4o-mini')">
                <div class="ai-model-3d">
                    <div class="ai-model-logo">
                        <span class="logo-circle logo-circle1"></span>
                        <span class="logo-circle logo-circle2"></span>
                        <span class="logo-circle logo-circle3"></span>
                        <span class="logo-circle logo-circle4">🌤️</span>
                    </div>
                    <div class="ai-model-glass"></div>
                    <div class="ai-model-content">
                        <span class="ai-model-title">날씨 트렌드 분석</span>
                        <span class="ai-model-type">Weather Intelligence</span>
                        <span class="ai-model-description">출시예정 - 고급 기상 트렌드 분석으로 여행 최적 시기를 예측하는 모델입니다.</span>
                    </div>
                    <div class="ai-model-bottom">
                        <div class="ai-model-info-row">
                            <div class="ai-model-features">
                                <span class="ai-model-feature-tag">기상 예측</span>
                                <span class="ai-model-feature-tag">일정 최적화</span>
                                <span class="ai-model-feature-tag">실외 활동</span>
                            </div>
                            <div class="ai-model-status">
                                <span class="ai-model-status-badge status-coming-soon">출시예정</span>
                                <div class="ai-model-accuracy">개발 중</div>
                            </div>
                        </div>
                        <div class="ai-model-actions">
                            <a href="#" class="ai-model-btn primary disabled">
                                🌤️ 출시예정
                            </a>
                            <a href="#" class="ai-model-btn secondary disabled">
                                📅 개발 중
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 소셜 트렌드 분석 모델 -->
            <div class="ai-model-card" onclick="selectModel('gemini-pro')">
                <div class="ai-model-3d">
                    <div class="ai-model-logo">
                        <span class="logo-circle logo-circle1"></span>
                        <span class="logo-circle logo-circle2"></span>
                        <span class="logo-circle logo-circle3"></span>
                        <span class="logo-circle logo-circle4">📱</span>
                    </div>
                    <div class="ai-model-glass"></div>
                    <div class="ai-model-content">
                        <span class="ai-model-title">소셜 트렌드 분석 </span>
                        <span class="ai-model-type">Trend Analytics</span>
                        <span class="ai-model-description">SNS와 리뷰 데이터를 실시간 분석하여 현재 가장 핫한 여행지와 액티비티를 발굴합니다.</span>
                    </div>
                    <div class="ai-model-bottom">
                        <div class="ai-model-info-row">
                            <div class="ai-model-features">
                                <span class="ai-model-feature-tag">SNS 분석</span>
                                <span class="ai-model-feature-tag">트렌드 예측</span>
                                <span class="ai-model-feature-tag">인플루언서</span>
                            </div>
                            <div class="ai-model-status">
                                <span class="ai-model-status-badge status-coming">출시 예정</span>
                                <div class="ai-model-accuracy">개발 중</div>
                            </div>
                        </div>
                        <div class="ai-model-actions">
                            <a href="#" class="ai-model-btn primary" style="opacity: 0.6; pointer-events: none;">
                                📱 트렌드 분석
                            </a>
                            <a href="#" class="ai-model-btn secondary" style="opacity: 0.6; pointer-events: none;">
                                🔔 알림 설정
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- 사용자 리뷰 및 평점 섹션 -->
        <div class="user-reviews-section">
            <div class="reviews-header">
                <h3>사용자 리뷰</h3>
                <div class="overall-rating" id="overallRating">
                    <div class="rating-stars" id="overallStars">
                        <span class="star">★</span>
                        <span class="star">★</span>
                        <span class="star">★</span>
                        <span class="star">★</span>
                        <span class="star">★</span>
                    </div>
                    <span class="rating-score" id="overallScore">0.0</span>
                    <span class="rating-count" id="overallCount">(0 리뷰)</span>
                </div>
            </div>
            
            <div class="reviews-grid" id="reviewsPreview">
                <!-- 동적으로 로드될 리뷰들 -->
            </div>
            
            <!-- 리뷰 네비게이션 -->
            <div class="review-navigation">
                <button id="prevReviewBtn" class="nav-btn" onclick="prevReviews()" disabled>
                    <i class="fas fa-chevron-left"></i>
                </button>
                <span class="page-info">
                    <span id="reviewPageInfo">1</span>
                </span>
                <button id="nextReviewBtn" class="nav-btn" onclick="nextReviews()" disabled>
                    <i class="fas fa-chevron-right"></i>
                </button>
            </div>
            
            <div class="review-actions">
                <button class="write-review-btn" onclick="openWriteReviewModal()">
                    <i class="fas fa-edit"></i>
                    리뷰 작성하기
                </button>
                <button class="view-all-reviews-btn" onclick="openAllReviewsModal()">
                    <i class="fas fa-list"></i>
                    모든 AI 모델 리뷰 보기
                </button>
            </div>
        </div>
    </section>

    <!-- 매칭 팝업 모달 -->
    <div id="matchingPopupModal" class="popup-modal">
        <div class="popup-modal-content">
            <div class="popup-modal-header">
                <h2>🎯 MBTI 매칭</h2>
                <span class="popup-close" onclick="closeMatchingPopup()">&times;</span>
            </div>
            <div class="popup-modal-body">
                <iframe id="matchingFrame" src="" width="100%" height="100%" frameborder="0"></iframe>
            </div>
        </div>
    </div>

    <!-- AI 패킹 어시스턴트 모달 -->
    <div id="packingAssistantModal" class="glassmorphism-modal">
        <div class="glassmorphism-modal-content large">
            <div class="glassmorphism-modal-header">
                <h2>🎒 AI 패킹 어시스턴트</h2>
                <button class="glassmorphism-close" onclick="closePackingAssistant()">&times;</button>
            </div>
            <div class="glassmorphism-modal-body">
                <!-- 채팅 인터페이스 -->
                <div class="packing-chat-container">
                    <div class="packing-chat-header">
                        <div class="ai-avatar">
                            <img src="https://img.pikbest.com/origin/09/23/70/59BpIkbEsT78R.png!w700wp" alt="AI Assistant" />
                        </div>
                        <div class="ai-info">
                            <h3>패킹 전문가 AI</h3>
                            <p>여행에 필요한 모든 준비물을 추천해드립니다</p>
                        </div>
                        <div class="chat-progress">
                            <div class="progress-bar">
                                <div id="progressFill" class="progress-fill"></div>
                            </div>
                            <span id="progressText">0/3 단계</span>
                        </div>
                    </div>
                    
                    <div class="packing-chat-messages" id="packingChatMessages">
                        <div class="ai-message">
                            <div class="message-content">
                                <p>안녕하세요! 여행 패킹을 도와드릴게요. 🎒</p>
                                <p>어떤 여행을 계획하고 계신가요?</p>
                            </div>
                        </div>
                        
                        <!-- 로딩 메시지 (기본적으로 숨김) -->
                        <div class="ai-message loading-message" id="packingLoadingMessage" style="display: none;">
                            <div class="message-content">
                                <div class="packing-loading-container">
                                    <div class="packing-spinner">
                                        <div class="spinner-circle"></div>
                                        <div class="spinner-circle"></div>
                                        <div class="spinner-circle"></div>
                                    </div>
                                    <div class="loading-text">
                                        <p id="loadingText">AI가 맞춤형 패킹 리스트를 만들고 있습니다...</p>
                                        <div class="loading-dots">
                                            <span class="dot"></span>
                                            <span class="dot"></span>
                                            <span class="dot"></span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="packing-chat-input">
                        <div class="input-container">
                            <input type="text" id="packingMessageInput" placeholder="여행 정보를 알려주세요 (예: 일본 도쿄 3일 여행)" />
                            <button id="sendMessageBtn" onclick="sendPackingMessage()">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- 패킹 리스트 결과 -->
                <div class="packing-results" id="packingResults" style="display: none;">
                    <div class="results-header">
                        <h3>📋 맞춤 패킹 리스트</h3>
                        <div class="results-actions">
                            <button class="btn-secondary" onclick="exportPackingList()">
                                <i class="fas fa-download"></i> PDF 다운로드
                            </button>
                            <button class="btn-secondary" onclick="restartPacking()">
                                <i class="fas fa-redo"></i> 다시 시작
                            </button>
                        </div>
                    </div>
                    
                    <div class="packing-categories" id="packingCategories">
                        <!-- 동적으로 생성될 카테고리별 패킹 리스트 -->
                    </div>
                    
                    <div class="packing-summary">
                        <div class="summary-stats">
                            <div class="stat-item">
                                <span class="stat-number" id="totalItems">0</span>
                                <span class="stat-label">전체 아이템</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-number" id="checkedItems">0</span>
                                <span class="stat-label">체크 완료</span>
                            </div>
                            <div class="stat-item">
                                <span class="stat-number" id="progressPercent">0%</span>
                                <span class="stat-label">진행률</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // 현재 선택된 AI 모델 ID
        let currentModelId = null;
        
        // 리뷰 페이징 변수
        let currentPage = 1;
        let hasNextPage = false;
        let hasPrevPage = false;
        
        // AI 모델 ID를 한국어 이름으로 매핑하는 함수
        function getModelKoreanName(modelId) {
            const modelNames = {
                'claude-3-5-sonnet': '여행 플레이리스트 모델',
                'mbti-matching': 'MBTI 매칭 모델',
                'music-recommendation': '여행 플레이리스트 모델',
                'ai-map': 'AI 지도 모델',
                'packing-assistant': '패킹 어시스턴트',
                'weather-intelligence': '날씨 트렌드 분석',
                'trend-analytics': '소셜 트렌드 분석',
                'gpt-4o': '패킹 어시스턴트',
                'gpt-4o-mini': '날씨 트렌드 분석',
                'claude-3-opus': '여행 플레이리스트 모델',
                'gemini-pro': 'AI 지도 모델',
                'claude-3-haiku': 'AI 지도 모델'
            };
            return modelNames[modelId] || modelId;
        }
        
        // 모델 선택 함수 (토글 기능 추가)
        function selectModel(modelId) {
            console.log('모델 선택:', modelId);
            
            // 이미 선택된 모델을 다시 클릭하면 선택 해제
            if (currentModelId === modelId) {
                currentModelId = null;
                console.log('모델 선택 해제');
            } else {
                currentModelId = modelId;
                console.log('새 모델 선택:', modelId);
            }
            
            // 페이지 초기화
            resetReviewPaging();
            
            // 선택된 모델의 리뷰 미리보기 로드 (선택 해제시에는 빈 화면)
            // 선택된 모델이 있으면 해당 모델 리뷰, 없으면 모든 리뷰 표시
            loadReviewPreview(currentModelId);
            
            // 모델 카드 스타일 업데이트 (선택 효과)
            updateModelSelection(currentModelId);
            
            // 추천 텍스트 업데이트
            updateRecommendText(currentModelId);
        }
        
        // 모델명 매핑
        const modelNameMap = {
            'mbti-matching': 'MBTI 매칭',
            'claude-3-5-sonnet': '여행 플레이리스트',
            'claude-3-haiku': 'AI 지도',
            'gpt-4o': '스마트 패킹 어시스턴트',
            'gpt-4o-mini': '날씨 트렌드 분석',
            'gemini-pro': '소셜 트렌드 분석'
        };
        
        // 추천 텍스트 업데이트 함수
        function updateRecommendText(modelId) {
            const recommendTextElement = document.getElementById('recommendText');
            const modelName = modelNameMap[modelId] || 'AI 모델';
            if (recommendTextElement) {
                recommendTextElement.textContent = '이 ' + modelName + ' 모델을 다른 사용자에게 추천합니다';
            }
        }
        
        // 모델 카드 선택 효과 업데이트
        function updateModelSelection(selectedModelId) {
            // 모든 모델 카드에서 선택 효과 제거
            document.querySelectorAll('.ai-model-card').forEach(card => {
                card.classList.remove('selected');
            });
            
            // 모델 ID에 따른 카드 인덱스 매핑
            const modelIndexMap = {
                'mbti-matching': 0,
                'claude-3-5-sonnet': 1,
                'claude-3-haiku': 2,
                'gpt-4o': 3,
                'gpt-4o-mini': 4,
                'gemini-pro': 5
            };
            
            // 선택된 모델 카드에 선택 효과 추가
            const cardIndex = modelIndexMap[selectedModelId];
            if (cardIndex !== undefined) {
                const selectedCard = document.querySelectorAll('.ai-model-card')[cardIndex];
                if (selectedCard) {
                    selectedCard.classList.add('selected');
                }
            }
        }
        
        // Binary code arc generation
        const container = document.getElementById('binary-code-container');
        if (container) {
            const text = "1001011010110101001110010101010011001011101010100011100101010100110010111010";
            const radius = container.offsetWidth / 2;
            const totalChars = 40;
            const angleIncrement = (Math.PI * 1.4) / totalChars;

            for (let i = 0; i < totalChars; i++) {
                const char = text[i % text.length];
                const angle = -Math.PI * 0.7 + i * angleIncrement;
                const span = document.createElement('span');
                span.innerText = char;
                const x = radius * Math.cos(angle);
                const y = radius * Math.sin(angle);
                span.style.transform = 'translate(' + x + 'px, ' + y + 'px) rotate(' + (angle + Math.PI / 2) + 'rad)';
                container.appendChild(span);
            }
        }

        // AI Sphere mouse follow effect with eye tracking
        const sphereContainer = document.getElementById('sphereContainer');
        
        // Only run sphere animation if elements exist
        if (sphereContainer) {
        let targetX = 0;
        let targetY = 0;
        let currentX = 0;
        let currentY = 0;
        let velocityX = 0;
        let velocityY = 0;
        let rafId = null;
        let mouseSpeed = 0;
        let lastMouseX = 0;
        let lastMouseY = 0;
        let globalMouseX = 0;
        let globalMouseY = 0;

        // Create style element for dynamic pseudo-element transforms
        const dynamicStyle = document.createElement('style');
        dynamicStyle.id = 'dynamic-sphere-style';
        document.head.appendChild(dynamicStyle);




        // Track mouse position globally
        document.addEventListener('mousemove', (e) => {
            globalMouseX = e.clientX;
            globalMouseY = e.clientY;
            
            const rect = sphereContainer.getBoundingClientRect();
            const centerX = rect.left + rect.width / 2;
            const centerY = rect.top + rect.height / 2;
            
            // Calculate mouse speed
            const deltaX = e.clientX - lastMouseX;
            const deltaY = e.clientY - lastMouseY;
            mouseSpeed = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
            lastMouseX = e.clientX;
            lastMouseY = e.clientY;
            
            // Calculate distance from sphere center
            const distX = e.clientX - centerX;
            const distY = e.clientY - centerY;
            const distance = Math.sqrt(distX * distX + distY * distY);
            const maxDistance = 300;
            
            // Dynamic influence based on distance and speed
            const distanceInfluence = Math.max(0, 1 - (distance / maxDistance));
            const speedMultiplier = 1 + (mouseSpeed * 0.02);
            
            // Calculate target position for sphere movement
            targetX = (distX / 8) * distanceInfluence * speedMultiplier;
            targetY = (distY / 8) * distanceInfluence * speedMultiplier;
            
        });

        // Calculate eye positions to look at mouse
        function calculateEyePosition(eyeSide) {
            const rect = sphereContainer.getBoundingClientRect();
            const sphereCenterX = rect.left + rect.width / 2;
            const sphereCenterY = rect.top + rect.height / 2;
            
            // Eye base position (left or right)
            const eyeOffsetX = eyeSide === 'left' ? -30 : 30;
            const eyeX = sphereCenterX + eyeOffsetX + currentX;
            const eyeY = sphereCenterY + currentY;
            
            // Calculate angle from eye to mouse
            const dx = globalMouseX - eyeX;
            const dy = globalMouseY - eyeY;
            const angle = Math.atan2(dy, dx);
            
            // Calculate distance (capped for pupil movement range)
            const distance = Math.min(Math.sqrt(dx * dx + dy * dy), 300);
            const pupilRange = 8; // Maximum pupil movement in pixels
            const pupilDistance = (distance / 300) * pupilRange;
            
            // Calculate pupil position
            const pupilX = Math.cos(angle) * pupilDistance;
            const pupilY = Math.sin(angle) * pupilDistance;
            
            return { x: pupilX, y: pupilY, angle: angle * (180 / Math.PI) };
        }

        // Smooth animation loop with physics
        function animateSphere() {
            // Spring physics for elastic movement
            const springStrength = 0.08;
            const damping = 0.85;
            
            // Calculate velocity
            velocityX += (targetX - currentX) * springStrength;
            velocityY += (targetY - currentY) * springStrength;
            
            // Apply damping
            velocityX *= damping;
            velocityY *= damping;
            
            // Update position
            currentX += velocityX;
            currentY += velocityY;
            
            // Calculate eye positions
            const leftEye = calculateEyePosition('left');
            const rightEye = calculateEyePosition('right');
            
            // Rotation based on velocity
            const rotateX = velocityY * 2;
            const rotateY = velocityX * -2;
            const rotateZ = (velocityX + velocityY) * 0.5;
            
            // Scale based on speed
            const scale = 1 + Math.min(Math.abs(velocityX + velocityY) * 0.005, 0.1);
            
            // Apply main sphere transform with 3D rotation (handled via CSS classes)
            // Note: aiSphere element doesn't exist, transforms applied via CSS classes below
            
            // Update eyes to look at mouse - they move within their position to track the cursor
            var cssContent = '.ai-sphere-fg::before { ' +
                'transform: translateY(-50%) translateX(' + leftEye.x + 'px) translateY(' + leftEye.y + 'px) ' +
                'rotateZ(' + leftEye.angle + 'deg) scaleX(' + (1 + Math.abs(leftEye.x) * 0.02) + ') ' +
                'scaleY(' + (1 - Math.abs(leftEye.x) * 0.01) + '); ' +
                'box-shadow: 0 0 ' + (25 + Math.abs(velocityX + velocityY)) + 'px rgba(255, 255, 255, 0.6), ' +
                '0 0 ' + (50 + Math.abs(velocityX + velocityY) * 2) + 'px rgba(102, 126, 234, 0.4); } ' +
                
                '.ai-sphere-fg::after { ' +
                'transform: translateY(-50%) translateX(' + rightEye.x + 'px) translateY(' + rightEye.y + 'px) ' +
                'rotateZ(' + rightEye.angle + 'deg) scaleX(' + (1 + Math.abs(rightEye.x) * 0.02) + ') ' +
                'scaleY(' + (1 - Math.abs(rightEye.x) * 0.01) + '); ' +
                'box-shadow: 0 0 ' + (25 + Math.abs(velocityX + velocityY)) + 'px rgba(255, 255, 255, 0.6), ' +
                '0 0 ' + (50 + Math.abs(velocityX + velocityY) * 2) + 'px rgba(102, 126, 234, 0.4); } ' +
                
                '.ai-sphere-bg { ' +
                'transform: translate(' + (currentX * 0.3) + 'px, ' + (currentY * 0.3) + 'px) ' +
                'scale(' + (1.1 + Math.abs(velocityX + velocityY) * 0.002) + ') rotate(' + (-rotateZ) + 'deg); ' +
                'filter: blur(' + (40 + Math.abs(velocityX + velocityY) * 0.5) + 'px) ' +
                'brightness(' + (1 + Math.abs(velocityX + velocityY) * 0.01) + '); } ' +
                
                '.binary-code { ' +
                'transform: translate(' + (currentX * 0.4) + 'px, ' + (currentY * 0.4) + 'px) ' +
                'scale(1.15) rotate(' + (rotateZ * 0.5) + 'deg); ' +
                'opacity: ' + (0.5 + Math.min(Math.abs(velocityX + velocityY) * 0.01, 0.3)) + '; } ' +
                
                '.ai-sphere-fg { ' +
                'box-shadow: inset 0 0 ' + (30 + Math.abs(velocityX + velocityY) * 2) + 'px rgba(102, 126, 234, 0.3), ' +
                '0 0 ' + (60 + Math.abs(velocityX + velocityY) * 3) + 'px rgba(102, 126, 234, 0.2); ' +
                'border-color: rgba(102, 126, 234, ' + (0.2 + Math.min(Math.abs(velocityX + velocityY) * 0.01, 0.3)) + '); }';
            
            // Add blink effect when mouse speed is high
            if (mouseSpeed > 50) {
                cssContent += '.ai-sphere-fg::before, .ai-sphere-fg::after { animation: blink 0.15s ease-in-out; } ' +
                             '@keyframes blink { 0%, 100% { transform: scaleY(1); } 50% { transform: scaleY(0.1); } }';
            }
            
            dynamicStyle.innerHTML = cssContent;
            
            rafId = requestAnimationFrame(animateSphere);
        }
        
        // Start animation
        animateSphere();

        // Enhanced sphere hover effect
        sphereContainer.addEventListener('mouseenter', () => {
            sphereContainer.style.cursor = 'pointer';
            // Hover effects handled by CSS classes
        });

        sphereContainer.addEventListener('mouseleave', () => {
            // Hover effects handled by CSS classes
        });

        // Add click ripple effect with wink
        sphereContainer.addEventListener('click', (e) => {
            // Navigate to AI chat when clicked
            window.location.href = '${pageContext.request.contextPath}/ai/chat';
            
            // Wink effect
            const winkStyle = document.createElement('style');
            winkStyle.innerHTML = `
                @keyframes wink {
                    0%, 100% { transform: translateY(-50%) scaleY(1); }
                    50% { transform: translateY(-50%) scaleY(0.1); }
                }
                .ai-sphere-fg::before {
                    animation: wink 0.3s ease-in-out !important;
                }
            `;
            document.head.appendChild(winkStyle);
            setTimeout(() => winkStyle.remove(), 300);
            
            const rect = sphereContainer.getBoundingClientRect();
            const x = e.clientX - rect.left;
            const y = e.clientY - rect.top;
            
            // Create ripple
            const ripple = document.createElement('div');
            ripple.style.cssText = 
                'position: absolute;' +
                'left: ' + x + 'px;' +
                'top: ' + y + 'px;' +
                'width: 10px;' +
                'height: 10px;' +
                'background: radial-gradient(circle, rgba(102, 126, 234, 0.8), transparent);' +
                'border-radius: 50%;' +
                'transform: translate(-50%, -50%);' +
                'pointer-events: none;' +
                'animation: rippleExpand 1s ease-out forwards;';
            sphereContainer.appendChild(ripple);
            setTimeout(() => ripple.remove(), 1000);
            
        });

        // Add ripple animation
        const rippleStyle = document.createElement('style');
        rippleStyle.innerHTML = `
            @keyframes rippleExpand {
                0% {
                    width: 10px;
                    height: 10px;
                    opacity: 1;
                }
                100% {
                    width: 300px;
                    height: 300px;
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(rippleStyle);

        // Card glow effect following mouse
        document.querySelectorAll('.card').forEach(card => {
            card.addEventListener('mousemove', (e) => {
                const rect = card.getBoundingClientRect();
                const x = ((e.clientX - rect.left) / rect.width) * 100;
                const y = ((e.clientY - rect.top) / rect.height) * 100;
                
                card.style.setProperty('--mouse-x', x + '%');
                card.style.setProperty('--mouse-y', y + '%');
            });
        });
        } // End of sphereContainer check


        // 매칭 팝업 기능
        function openMatchingPopup() {
            const modal = document.getElementById('matchingPopupModal');
            const iframe = document.getElementById('matchingFrame');
            
            // iframe에 매칭 페이지 로드 (popup 파라미터 추가로 네비바 숨김)
            iframe.src = '${pageContext.request.contextPath}/travel-mbti/matching?popup=true';
            
            // 모달 표시
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden'; // 배경 스크롤 방지
        }

        function closeMatchingPopup() {
            const modal = document.getElementById('matchingPopupModal');
            const iframe = document.getElementById('matchingFrame');
            
            // 모달 숨기기
            modal.style.display = 'none';
            document.body.style.overflow = 'auto'; // 배경 스크롤 복구
            
            // iframe 소스 초기화
            iframe.src = '';
        }

        // 모달 외부 클릭 시 닫기 (통합)
        window.onclick = function(event) {
            const matchingModal = document.getElementById('matchingPopupModal');
            const writeModal = document.getElementById('writeReviewModal');
            const allModal = document.getElementById('allReviewsModal');
            
            if (event.target === matchingModal) {
                closeMatchingPopup();
            }
            if (event.target === writeModal) {
                closeWriteReviewModal();
            }
            if (event.target === allModal) {
                closeAllReviewsModal();
            }
        }

        // ESC 키로 모달 닫기 (통합)
        document.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                const matchingModal = document.getElementById('matchingPopupModal');
                const writeModal = document.getElementById('writeReviewModal');
                const allModal = document.getElementById('allReviewsModal');
                
                if (matchingModal.style.display === 'block') {
                    closeMatchingPopup();
                } else if (writeModal.style.display === 'block') {
                    closeWriteReviewModal();
                } else if (allModal.style.display === 'block') {
                    closeAllReviewsModal();
                }
            }
        });

        // Area-based 3D hover effects for aimo tracking
        const areas = document.querySelectorAll('.main-container > .area');
        const aimoCard = document.querySelector('.aimo-card');
        const aimoEyes = document.querySelectorAll('.eyes .eye');
        
        console.log('Mouse tracking elements:', {
            areasCount: areas.length,
            aimoCard: !!aimoCard,
            aimoEyesCount: aimoEyes.length
        });

        if (areas && aimoCard) {
            areas.forEach((area, index) => {
                area.addEventListener('mouseenter', () => {
                    const areaIndex = index + 1; // 1-based
                    let rotateX = 0, rotateY = 0;
                    
                    // Calculate rotation based on 5x3 grid position
                    if (areaIndex <= 5) rotateX = -15;        // Top row
                    else if (areaIndex <= 10) rotateX = 0;    // Middle row
                    else rotateX = 15;                        // Bottom row
                    
                    const col = ((areaIndex - 1) % 5) + 1;
                    if (col === 1) rotateY = -15;             // Column 1
                    else if (col === 2) rotateY = -7;         // Column 2
                    else if (col === 3) rotateY = 0;          // Column 3
                    else if (col === 4) rotateY = 7;          // Column 4
                    else if (col === 5) rotateY = 15;         // Column 5
                    
                    // Apply 3D transformation
                    aimoCard.style.transform = 'perspective(1000px) rotateX(' + rotateX + 'deg) rotateY(' + rotateY + 'deg) translateZ(45px) scale3d(1.05, 1.05, 1.05)';
                    aimoEyes.forEach(eye => {
                        eye.style.transform = 'perspective(1000px) rotateX(' + rotateX + 'deg) rotateY(' + rotateY + 'deg) translateZ(45px) scale3d(1.05, 1.05, 1.05)';
                    });
                });
                
                area.addEventListener('mouseleave', () => {
                    // Reset transformation with smooth transition
                    aimoCard.style.transition = 'transform 0.6s ease-out';
                    aimoCard.style.transform = '';
                    aimoEyes.forEach(eye => {
                        eye.style.transition = 'transform 0.6s ease-out';
                        eye.style.transform = '';
                    });
                    
                    // Remove transition after animation
                    setTimeout(() => {
                        aimoCard.style.transition = '';
                        aimoEyes.forEach(eye => {
                            eye.style.transition = '';
                        });
                    }, 600);
                });
                
                // 버튼 클릭 이벤트 전파를 위해 area 내의 버튼들에 직접 클릭 이벤트 추가
                area.addEventListener('click', (e) => {
                    // area 내에서 버튼을 찾아 클릭 이벤트 전파
                    const buttons = document.querySelectorAll('.btn2-button');
                    const rect = area.getBoundingClientRect();
                    const clickX = e.clientX;
                    const clickY = e.clientY;
                    
                    buttons.forEach(button => {
                        const btnRect = button.getBoundingClientRect();
                        if (clickX >= btnRect.left && clickX <= btnRect.right &&
                            clickY >= btnRect.top && clickY <= btnRect.bottom) {
                            button.click();
                        }
                    });
                });
            });
        }

        // Backup: Complete main-container mouse tracking for aimo (if areas fail)
        const mainContainer = document.querySelector('.main-container');
        
        // Particle animation from color/back.html
        const canvas = document.getElementById('particles');
        const ctx = canvas.getContext('2d');
        let particlesArray;

        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;

        window.addEventListener('resize', () => {
            canvas.width = window.innerWidth;
            canvas.height = window.innerHeight;
            init();
        });

        class Particle {
            constructor() {
                this.x = Math.random() * canvas.width;
                this.y = Math.random() * canvas.height;
                this.size = Math.random() * 4 + 1; // 크기 증가
                this.speedX = (Math.random() - 0.5) * 0.5; // 속도 약간 증가
                this.speedY = (Math.random() - 0.5) * 0.5; // 속도 약간 증가
                this.opacity = Math.random() * 0.7 + 0.3; // 더 선명하게
            }

            update() {
                this.x += this.speedX;
                this.y += this.speedY;
                if (this.x < 0 || this.x > canvas.width) this.speedX *= -1;
                if (this.y < 0 || this.y > canvas.height) this.speedY *= -1;
            }

            draw() {
                ctx.fillStyle = 'rgba(255, 255, 255, ' + this.opacity + ')'; // 하얀색 파티클
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
                ctx.fill();
                
                // 가장자리 글로우 효과
                ctx.shadowBlur = 8;
                ctx.shadowColor = '#ffffff';
                ctx.fillStyle = 'rgba(255, 255, 255, ' + (this.opacity * 0.5) + ')';
                ctx.beginPath();
                ctx.arc(this.x, this.y, this.size * 0.5, 0, Math.PI * 2);
                ctx.fill();
                ctx.shadowBlur = 0;
            }
        }

        function init() {
            particlesArray = [];
            for (let i = 0; i < 100; i++) { // 파티클 수 약간 증가
                particlesArray.push(new Particle());
            }
        }

        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            particlesArray.forEach(p => {
                p.update();
                p.draw();
            });
            requestAnimationFrame(animate);
        }

        init();
        animate();
        
        // 실시간 성능 지표 업데이트
        function updateMetrics() {
            const responseTime = document.getElementById('response-time');
            const accuracy = document.getElementById('accuracy');
            const usageToday = document.getElementById('usage-today');
            
            if (responseTime) {
                // 0.8ms ~ 1.5ms 범위의 랜덤 값
                const randomResponseTime = (Math.random() * 0.7 + 0.8).toFixed(1);
                responseTime.textContent = randomResponseTime;
            }
            
            if (accuracy) {
                // 98.0% ~ 99.0% 범위의 랜덤 값
                const randomAccuracy = (Math.random() * 1.0 + 98.0).toFixed(1);
                accuracy.textContent = randomAccuracy;
            }
            
            if (usageToday) {
                // 2.1K ~ 2.8K 범위의 랜덤 값
                const randomUsage = (Math.random() * 0.7 + 2.1).toFixed(1);
                usageToday.textContent = randomUsage;
            }
        }
        
        // 모델 비교 팝업 열기
        function openModelComparison() {
            alert('AI 모델 비교 기능이 곧 출시됩니다!\n\n- MBTI 매칭 vs 여행 플레이리스트\n- 성능 지표 비교\n- 사용 사례별 추천');
        }
        
        // 현재 선택된 모델 ID (already declared above)
        
        
        // 리뷰 미리보기 로드 (최신 3개)
        function loadReviewsPreview() {
            loadReviewPreview(currentModelId);
        }
        
        // 리뷰 미리보기 로드 함수
        function loadReviewPreview(modelId) {
            console.log('리뷰 미리보기 로드 함수 호출됨');
            console.log('받은 modelId 파라미터:', modelId, 'typeof:', typeof modelId);
            console.log('현재 currentModelId:', currentModelId);
            
            let url;
            // modelId가 없거나 비어있으면 모든 리뷰 조회
            if (!modelId || modelId.trim() === '') {
                console.log('modelId가 비어있어서 모든 리뷰 조회');
                url = '/ai/review/list/all?page=' + currentPage + '&pageSize=3';
            } else {
                console.log('특정 모델 리뷰 조회');
                url = '/ai/review/list/' + modelId + '?page=' + currentPage + '&pageSize=3';
            }
            console.log('구성된 요청 URL:', url);
            
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        updateOverallRating(data.stats);
                        displayReviewsPreview(data.reviews);
                        // 페이징 정보 업데이트
                        hasNextPage = currentPage < data.totalPages;
                        hasPrevPage = currentPage > 1;
                        updateReviewNavigation();
                    } else {
                        console.error('API 응답 실패:', data);
                    }
                })
                .catch(error => {
                    console.error('리뷰 미리보기 로딩 실패:', error);
                });
        }
        
        // 전체 평점 업데이트
        function updateOverallRating(stats) {
            const avgRating = stats.averageRating || 0;
            const totalReviews = stats.totalReviews || 0;
            
            document.getElementById('overallScore').textContent = avgRating.toFixed(1);
            document.getElementById('overallCount').textContent = '(' + totalReviews + ' 리뷰)';
            
            // 별점 업데이트
            const stars = document.querySelectorAll('#overallStars .star');
            stars.forEach((star, index) => {
                if (index < Math.floor(avgRating)) {
                    star.classList.add('filled');
                } else if (index < avgRating) {
                    star.classList.add('half');
                } else {
                    star.classList.remove('filled', 'half');
                }
            });
        }
        
        // 리뷰 미리보기 표시
        function displayReviewsPreview(reviews) {
            const container = document.getElementById('reviewsPreview');
            container.innerHTML = '';
            
            if (reviews.length === 0) {
                container.innerHTML = '<div class="no-reviews">아직 작성된 리뷰가 없습니다. 첫 번째 리뷰를 작성해보세요!</div>';
                return;
            }
            
            reviews.forEach(review => {
                const reviewCard = createReviewCard(review);
                container.appendChild(reviewCard);
            });
        }
        
        // 리뷰 카드 생성
        function createReviewCard(review) {
            const card = document.createElement('div');
            card.className = 'review-card';
            
            const isLoggedIn = ${loginUser != null ? 'true' : 'false'};
            const modelName = getModelKoreanName(review.modelId || currentModelId);
            
            card.innerHTML = 
                '<div class="review-header">' +
                    '<div class="reviewer-info">' +
                        '<div class="reviewer-avatar">' +
                            (review.userProfileImage ? 
                                '<img src="/uploads/profile/' + review.userProfileImage + '" alt="' + review.userName + '">' : 
                                review.userName.charAt(0)
                            ) +
                        '</div>' +
                        '<div class="reviewer-details">' +
                            '<span class="reviewer-name">' + review.userName + '</span>' +
                            '<span class="review-date">' + new Date(review.createdAt).toLocaleDateString('ko-KR') + '</span>' +
                        '</div>' +
                    '</div>' +
                    '<div class="review-rating">' +
                        generateStarRating(review.rating) +
                    '</div>' +
                '</div>' +
                '<div class="review-model-badge">' +
                    '<span class="model-name-badge">' + modelName + '</span>' +
                '</div>' +
                '<h4 class="review-title">' + review.reviewTitle + '</h4>' +
                '<p class="review-text">' + review.reviewContent + '</p>' +
                '<div class="review-helpful">' +
                    '<button class="helpful-btn ' + (review.isHelpedByCurrentUser ? 'active' : '') + '" ' +
                            'onclick="toggleHelpful(' + review.reviewId + ')" ' +
                            (isLoggedIn ? '' : 'disabled') + '>' +
                        '👍 도움됨 (' + review.helpfulCount + ')' +
                    '</button>' +
                    (review.isRecommended ? '<span class="recommended-badge">👍 추천</span>' : '') +
                '</div>';
            return card;
        }
        
        // 별점 생성
        function generateStarRating(rating) {
            let stars = '';
            for (let i = 1; i <= 5; i++) {
                stars += '<span class="star ' + (i <= rating ? 'filled' : '') + '">★</span>';
            }
            return stars;
        }
        
        // 날짜 포맷팅
        function formatDate(dateString) {
            const date = new Date(dateString);
            const now = new Date();
            const diffTime = Math.abs(now - date);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            
            if (diffDays === 1) return '오늘';
            if (diffDays === 2) return '어제';
            if (diffDays <= 7) return (diffDays-1) + '일 전';
            if (diffDays <= 30) return Math.floor(diffDays/7) + '주 전';
            return date.toLocaleDateString('ko-KR');
        }
        
        // 5초마다 실시간 지표 업데이트
        setInterval(updateMetrics, 5000);
        
        // 페이지 로드 시 초기 업데이트
        updateMetrics();
        
        // 모달 초기화 - 확실히 숨김 처리
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('writeReviewModal').style.display = 'none';
            document.getElementById('allReviewsModal').style.display = 'none';
            document.getElementById('packingAssistantModal').style.display = 'none';
            
            // 리뷰 미리보기 로드 (모든 리뷰)
            loadReviewPreview(currentModelId);
            
            // 초기에는 모델 선택 없음
            updateModelSelection(currentModelId);
        });
        
        // 리뷰 작성 팝업 열기
        function openWriteReviewModal() {
            // 로그인 확인
            var isLoggedIn = ${loginUser != null ? 'true' : 'false'};
            if (!isLoggedIn) {
                alert('리뷰를 작성하려면 로그인이 필요합니다.');
                window.location.href = '/member/login';
                return;
            }
            
            // AI 모델 선택 확인
            if (!currentModelId || currentModelId.trim() === '') {
                alert('AI 모델을 선택해주세요.');
                return;
            }
            
            document.getElementById('reviewModelId').value = currentModelId;
            document.getElementById('writeReviewModal').style.display = 'block';
            
            // 평점 초기화 (5점 만점)
            updateRatingStars(5);
            
            // 폼 초기화
            document.getElementById('writeReviewForm').reset();
            document.getElementById('selectedRating').value = '5';
            
            // 제목 입력 필드 포커스만 설정 (자동 입력 제거)
            const titleInput = document.getElementById('reviewTitle');
            titleInput.value = '';  // 빈 값으로 초기화
            titleInput.focus();
            
            // 글자수 카운터 업데이트
            document.getElementById('titleCount').textContent = titleInput.value.length;
            document.getElementById('contentCount').textContent = '0';
        }
        
        // 리뷰 작성 팝업 닫기
        function closeWriteReviewModal() {
            document.getElementById('writeReviewModal').style.display = 'none';
        }
        
        // 모든 리뷰 보기 팝업 열기
        function openAllReviewsModal() {
            document.getElementById('allReviewsModal').style.display = 'block';
            loadAllReviews(1);
        }
        
        // 모든 리뷰 보기 팝업 닫기
        function closeAllReviewsModal() {
            document.getElementById('allReviewsModal').style.display = 'none';
        }
        
        // 평점 별 업데이트
        function updateRatingStars(rating) {
            const stars = document.querySelectorAll('#ratingInput .rating-star');
            stars.forEach((star, index) => {
                if (index < rating) {
                    star.classList.add('active');
                } else {
                    star.classList.remove('active');
                }
            });
            document.getElementById('selectedRating').value = rating;
        }
        
        // 평점 별 클릭 이벤트
        document.addEventListener('DOMContentLoaded', function() {
            const ratingStars = document.querySelectorAll('#ratingInput .rating-star');
            ratingStars.forEach((star, index) => {
                star.addEventListener('click', function() {
                    updateRatingStars(index + 1);
                });
            });
            
            // 글자 수 카운터
            document.getElementById('reviewTitle').addEventListener('input', function() {
                document.getElementById('titleCount').textContent = this.value.length;
            });
            
            document.getElementById('reviewContent').addEventListener('input', function() {
                document.getElementById('contentCount').textContent = this.value.length;
            });
            
            // 리뷰 작성 폼 제출
            document.getElementById('writeReviewForm').addEventListener('submit', function(e) {
                e.preventDefault();
                submitReview();
            });
        });
        
        // 리뷰 제출
        function submitReview() {
            const reviewData = {
                modelId: document.getElementById('reviewModelId').value,
                rating: parseInt(document.getElementById('selectedRating').value),
                reviewTitle: document.getElementById('reviewTitle').value.trim(),
                reviewContent: document.getElementById('reviewContent').value.trim(),
                isRecommended: document.getElementById('isRecommended').checked
            };
            
            // 유효성 검사
            if (!reviewData.reviewTitle) {
                alert('리뷰 제목을 입력해주세요.');
                return;
            }
            
            if (!reviewData.reviewContent) {
                alert('리뷰 내용을 입력해주세요.');
                return;
            }
            
            // 제출 버튼 비활성화
            const submitBtn = document.querySelector('#writeReviewForm .btn-submit');
            const originalText = submitBtn.textContent;
            submitBtn.disabled = true;
            submitBtn.textContent = '등록 중...';
            
            fetch('/ai/review/create', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(reviewData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('리뷰가 성공적으로 등록되었습니다!');
                    closeWriteReviewModal();
                    loadReviewPreview(currentModelId); // 미리보기 새로고침
                } else {
                    alert('오류: ' + data.message);
                }
            })
            .catch(error => {
                console.error('리뷰 등록 실패:', error);
                alert('리뷰 등록 중 오류가 발생했습니다.');
            })
            .finally(() => {
                submitBtn.disabled = false;
                submitBtn.textContent = originalText;
            });
        }
        
        // 모든 리뷰 로드 (모든 AI 모델 통합)
        function loadAllReviews(page = 1) {
            const sort = document.getElementById('reviewSort')?.value || 'latest';
            const ratingFilter = document.getElementById('ratingFilter')?.value || '';
            
            // 모든 AI 모델의 리뷰를 통합으로 가져오는 URL (modelId 없이)
            let url = '/ai/review/list/all?page=' + page + '&pageSize=10';
            if (sort !== 'latest') url += '&sort=' + sort;
            if (ratingFilter) url += '&rating=' + ratingFilter;
            
            console.log('모든 AI 모델 리뷰 로드 요청 URL:', url);
            
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        updateModalStats(data.stats);
                        displayAllReviews(data.reviews);
                        updatePagination(data.currentPage, data.totalPages);
                    } else {
                        console.error('모든 리뷰 로드 API 응답 실패:', data);
                    }
                })
                .catch(error => {
                    console.error('전체 리뷰 로딩 실패:', error);
                });
        }
        
        // 모달 통계 업데이트
        function updateModalStats(stats) {
            const avgRating = stats.averageRating || 0;
            const totalReviews = stats.totalReviews || 0;
            
            document.getElementById('modalOverallScore').textContent = avgRating.toFixed(1);
            document.getElementById('modalOverallCount').textContent = totalReviews + ' 리뷰';
            
            // 모달 별점 업데이트
            const modalStars = document.querySelectorAll('#modalOverallStars .star');
            modalStars.forEach((star, index) => {
                if (index < Math.floor(avgRating)) {
                    star.classList.add('filled');
                } else if (index < avgRating) {
                    star.classList.add('half');
                } else {
                    star.classList.remove('filled', 'half');
                }
            });
            
            // 평점 분포 차트 (간단한 막대 그래프)
            updateRatingBreakdown(stats);
        }
        
        // 평점 분포 차트 업데이트
        function updateRatingBreakdown(stats) {
            const breakdownContainer = document.getElementById('ratingBreakdown');
            const totalReviews = stats.totalReviews || 1;
            
            let breakdownHTML = '<h4 style="margin-bottom: 1rem; color: white;">평점 분포</h4>';
            
            for (let i = 5; i >= 1; i--) {
                const count = stats['rating' + i + 'Count'] || 0;
                const percentage = (count / totalReviews * 100).toFixed(1);
                
                breakdownHTML += 
                    '<div style="display: flex; align-items: center; margin-bottom: 0.5rem;">' +
                        '<span style="color: rgba(255,255,255,0.8); width: 30px;">' + i + '★</span>' +
                        '<div style="flex: 1; background: rgba(255,255,255,0.1); height: 8px; border-radius: 4px; margin: 0 1rem; overflow: hidden;">' +
                            '<div style="background: linear-gradient(135deg, #8b5cf6, #ec4899); height: 100%; width: ' + percentage + '%; transition: width 0.3s ease;"></div>' +
                        '</div>' +
                        '<span style="color: rgba(255,255,255,0.6); width: 40px; text-align: right;">' + count + '</span>' +
                    '</div>';
            }
            
            breakdownContainer.innerHTML = breakdownHTML;
        }
        
        // 전체 리뷰 표시
        function displayAllReviews(reviews) {
            const container = document.getElementById('allReviewsContainer');
            container.innerHTML = '';
            
            if (reviews.length === 0) {
                container.innerHTML = '<div class="no-reviews">조건에 맞는 리뷰가 없습니다.</div>';
                return;
            }
            
            reviews.forEach(review => {
                const reviewCard = createReviewCard(review);
                container.appendChild(reviewCard);
            });
        }
        
        // 페이징 업데이트
        function updatePagination(currentPage, totalPages) {
            const container = document.getElementById('reviewPagination');
            container.innerHTML = '';
            
            if (totalPages <= 1) return;
            
            // 이전 페이지
            if (currentPage > 1) {
                const prevBtn = document.createElement('button');
                prevBtn.textContent = '‹';
                prevBtn.onclick = () => loadAllReviews(currentPage - 1);
                container.appendChild(prevBtn);
            }
            
            // 페이지 번호들
            const startPage = Math.max(1, currentPage - 2);
            const endPage = Math.min(totalPages, currentPage + 2);
            
            for (let i = startPage; i <= endPage; i++) {
                const pageBtn = document.createElement('button');
                pageBtn.textContent = i;
                pageBtn.onclick = () => loadAllReviews(i);
                if (i === currentPage) {
                    pageBtn.classList.add('active');
                }
                container.appendChild(pageBtn);
            }
            
            // 다음 페이지
            if (currentPage < totalPages) {
                const nextBtn = document.createElement('button');
                nextBtn.textContent = '›';
                nextBtn.onclick = () => loadAllReviews(currentPage + 1);
                container.appendChild(nextBtn);
            }
        }
        
        // 도움됨 토글
        function toggleHelpful(reviewId) {
            // 로그인 확인
            var isLoggedIn = ${loginUser != null ? 'true' : 'false'};
            if (!isLoggedIn) {
                alert('도움됨을 누르려면 로그인이 필요합니다.');
                return;
            }
            
            console.log('도움됨 클릭:', reviewId);
            
            fetch('/ai/review/helpful/' + reviewId, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                credentials: 'same-origin'
            })
            .then(response => {
                console.log('응답 상태:', response.status);
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                console.log('도움됨 응답:', data);
                if (data.success) {
                    // 해당 버튼 업데이트
                    const helpfulBtns = document.querySelectorAll('[onclick="toggleHelpful(' + reviewId + ')"]');
                    helpfulBtns.forEach(btn => {
                        btn.textContent = '👍 도움됨 (' + data.helpfulCount + ')';
                        if (data.isHelpedByCurrentUser) {
                            btn.classList.add('active');
                        } else {
                            btn.classList.remove('active');
                        }
                    });
                    
                    // 리뷰 목록 새로고침
                    if (currentModelId) {
                        loadReviews(currentModelId, 1);
                    }
                    loadAllReviews(1);
                } else {
                    alert('오류: ' + (data.message || '알 수 없는 오류'));
                }
            })
            .catch(error => {
                console.error('도움됨 처리 실패:', error);
                alert('처리 중 오류가 발생했습니다: ' + error.message);
            });
        }
        
        
        // 리뷰 네비게이션 업데이트
        function updateReviewNavigation() {
            const prevBtn = document.getElementById('prevReviewBtn');
            const nextBtn = document.getElementById('nextReviewBtn');
            const pageInfo = document.getElementById('reviewPageInfo');
            
            if (prevBtn) prevBtn.disabled = !hasPrevPage;
            if (nextBtn) nextBtn.disabled = !hasNextPage;
            if (pageInfo) pageInfo.textContent = currentPage;
        }
        
        // 이전 리뷰 페이지
        function prevReviews() {
            if (hasPrevPage) {
                currentPage--;
                loadReviewPreview(currentModelId);
            }
        }
        
        // 다음 리뷰 페이지
        function nextReviews() {
            if (hasNextPage) {
                currentPage++;
                loadReviewPreview(currentModelId);
            }
        }
        
        // 모델 변경 시 페이지 초기화
        function resetReviewPaging() {
            currentPage = 1;
            hasNextPage = false;
            hasPrevPage = false;
        }
        
    </script>

    <!-- 리뷰 작성 팝업 모달 (글래즈모피즘) -->
    <div id="writeReviewModal" class="glassmorphism-modal" style="display: none;">
        <div class="glassmorphism-modal-content">
            <div class="glassmorphism-modal-header">
                <h2><i class="fas fa-star"></i> 리뷰 작성하기</h2>
                <span class="glassmorphism-close" onclick="closeWriteReviewModal()">&times;</span>
            </div>
            <div class="glassmorphism-modal-body">
                <form id="writeReviewForm">
                    <input type="hidden" id="reviewModelId" value="">
                    
                    <!-- 평점 선택 -->
                    <div class="form-group">
                        <label>평점</label>
                        <div class="rating-input" id="ratingInput">
                            <span class="rating-star" data-rating="1">★</span>
                            <span class="rating-star" data-rating="2">★</span>
                            <span class="rating-star" data-rating="3">★</span>
                            <span class="rating-star" data-rating="4">★</span>
                            <span class="rating-star" data-rating="5">★</span>
                        </div>
                        <input type="hidden" id="selectedRating" value="5">
                    </div>
                    
                    <!-- 리뷰 제목 -->
                    <div class="form-group">
                        <label for="reviewTitle">리뷰 제목</label>
                        <input type="text" id="reviewTitle" placeholder="리뷰 제목을 입력하세요" maxlength="200" required>
                        <div class="char-count"><span id="titleCount">0</span>/200</div>
                    </div>
                    
                    <!-- 리뷰 내용 -->
                    <div class="form-group">
                        <label for="reviewContent">리뷰 내용</label>
                        <textarea id="reviewContent" placeholder="이 AI 모델을 사용해본 경험을 자세히 알려주세요" maxlength="1000" required></textarea>
                        <div class="char-count"><span id="contentCount">0</span>/1000</div>
                    </div>
                    
                    <!-- 추천 여부 -->
                    <div class="form-group">
                        <label class="checkbox-label">
                            <input type="checkbox" id="isRecommended" checked>
                            <span class="checkmark"></span>
                            <span id="recommendText">✨ 이 스마트 패킹 어시스턴트 모델을 다른 사용자에게 추천합니다</span>
                        </label>
                    </div>
                    
                    <div class="modal-actions">
                        <button type="button" class="btn-cancel" onclick="closeWriteReviewModal()">취소</button>
                        <button type="submit" class="btn-submit">리뷰 등록</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- 모든 리뷰 보기 팝업 모달 (글래즈모피즘) -->
    <div id="allReviewsModal" class="glassmorphism-modal" style="display: none;">
        <div class="glassmorphism-modal-content large">
            <div class="glassmorphism-modal-header">
                <h2><i class="fas fa-list"></i> 모든 리뷰 보기</h2>
                <span class="glassmorphism-close" onclick="closeAllReviewsModal()">&times;</span>
            </div>
            <div class="glassmorphism-modal-body">
                <!-- 평점 통계 -->
                <div class="review-stats">
                    <div class="overall-rating-large">
                        <div class="rating-number" id="modalOverallScore">0.0</div>
                        <div class="rating-stars-large" id="modalOverallStars">
                            <span class="star">★</span>
                            <span class="star">★</span>
                            <span class="star">★</span>
                            <span class="star">★</span>
                            <span class="star">★</span>
                        </div>
                        <div class="rating-count-large" id="modalOverallCount">0 리뷰</div>
                    </div>
                    <div class="rating-breakdown" id="ratingBreakdown">
                        <!-- 평점별 분포 차트 -->
                    </div>
                </div>
                
                <!-- 필터 및 정렬 -->
                <div class="review-filters">
                    <div class="filter-group">
                        <label>정렬:</label>
                        <select id="reviewSort" onchange="loadAllReviews(1)">
                            <option value="latest">최신순</option>
                            <option value="helpful">도움됨순</option>
                            <option value="rating_high">평점 높은순</option>
                            <option value="rating_low">평점 낮은순</option>
                        </select>
                    </div>
                    <div class="filter-group">
                        <label>평점 필터:</label>
                        <select id="ratingFilter" onchange="loadAllReviews(1)">
                            <option value="">전체</option>
                            <option value="5">⭐⭐⭐⭐⭐</option>
                            <option value="4">⭐⭐⭐⭐</option>
                            <option value="3">⭐⭐⭐</option>
                            <option value="2">⭐⭐</option>
                            <option value="1">⭐</option>
                        </select>
                    </div>
                </div>
                
                <!-- 리뷰 목록 -->
                <div class="all-reviews-container" id="allReviewsContainer">
                    <!-- 동적으로 로드될 리뷰들 -->
                </div>
                
                <!-- 페이징 -->
                <div class="pagination" id="reviewPagination">
                    <!-- 동적으로 생성될 페이징 버튼들 -->
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // 패킹 어시스턴트 변수들
        let packingConversationId = null;
        let packingStep = 0;
        let packingData = {};
        let packingItems = {};
        
        // 패킹 어시스턴트 열기
        function openPackingAssistant() {
            document.getElementById('packingAssistantModal').style.display = 'block';
            resetPackingAssistant();
        }
        
        // 패킹 어시스턴트 닫기
        function closePackingAssistant() {
            document.getElementById('packingAssistantModal').style.display = 'none';
        }
        
        // 패킹 어시스턴트 초기화
        function resetPackingAssistant() {
            packingConversationId = generateUUID();
            packingStep = 0;
            packingData = {};
            packingItems = {};
            
            // UI 초기화
            const messagesContainer = document.getElementById('packingChatMessages');
            messagesContainer.innerHTML = `
                <div class="ai-message">
                   <div class="ai-avatar">
                            <img src="https://img.pikbest.com/origin/09/23/70/59BpIkbEsT78R.png!w700wp" alt="AI Assistant" />
                        </div>
                    <div class="message-content">
                        <p>안녕하세요! 여행 패킹을 도와드릴게요. 🎒</p>
                        <p>어떤 여행을 계획하고 계신가요?</p>
                    </div>
                </div>
            `;
            
            document.getElementById('packingMessageInput').value = '';
            document.getElementById('packingResults').style.display = 'none';
            updateProgress(0);
            
            // Enter 키 이벤트 추가
            const input = document.getElementById('packingMessageInput');
            input.addEventListener('keypress', function(e) {
                if (e.key === 'Enter') {
                    sendPackingMessage();
                }
            });
        }
        
        // 메시지 전송
        function sendPackingMessage() {
            const input = document.getElementById('packingMessageInput');
            const message = input.value.trim();
            
            if (!message) return;
            
            // 즉시 로딩 메시지 표시
            showPackingLoading();
            
            // 버튼 비활성화
            const sendBtn = document.getElementById('sendMessageBtn');
            sendBtn.disabled = true;
            
            // 사용자 메시지 추가
            addMessage('user', message);
            input.value = '';
            
            // AI에게 메시지 전송
            fetch('/api/packing/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    message: message,
                    conversationId: packingConversationId
                })
            })
            .then(response => response.json())
            .then(data => {
                // 로딩 메시지 숨기기
                hidePackingLoading();
                
                if (data.success) {
                    // AI 응답 추가
                    addMessage('ai', data.aiMessage);
                    
                    // 진행률 업데이트
                    packingStep++;
                    updateProgress(Math.min(packingStep * 33, 100));
                    
                    // 대화 완료 시 패킹 리스트 표시 (최소 3번의 대화 후에만)
                    if (data.conversationComplete && data.packingList && packingStep >= 3) {
                        // 패킹 리스트가 충분히 완성되었는지 체크
                        const hasItems = data.packingList && Object.keys(data.packingList).length > 0;
                        if (hasItems) {
                            setTimeout(() => {
                                showPackingResults(data.packingList);
                            }, 2000);
                        }
                    } else if (data.conversationComplete && packingStep < 3) {
                        // 너무 빨리 완료된 경우, 추가 정보 요청
                        console.log('대화가 너무 빨리 완료됨. 계속 진행...');
                    }
                } else {
                    addMessage('ai', '죄송합니다. 오류가 발생했습니다: ' + data.message);
                }
            })
            .catch(error => {
                // 로딩 메시지 숨기기
                hidePackingLoading();
                console.error('Error:', error);
                addMessage('ai', '네트워크 오류가 발생했습니다. 다시 시도해주세요.');
            })
            .finally(() => {
                sendBtn.disabled = false;
            });
        }
        
        // 패킹 로딩 메시지 표시 함수
        function showPackingLoading() {
            const loadingMessage = document.getElementById('packingLoadingMessage');
            const loadingTextElement = document.getElementById('loadingText');
            
            if (!loadingMessage) {
                console.log('패킹 로딩 메시지 요소를 찾을 수 없습니다.');
                return;
            }
            
            const loadingTexts = [
                '🧳 AI가 맞춤형 패킹 리스트를 만들고 있습니다...',
                '📊 여행 정보를 분석하고 있습니다...',
                '✨ 필수 물품들을 선별하고 있습니다...',
                '🎯 최적의 패킹 순서를 계산하고 있습니다...',
                '💡 개인 맞춤형 추천을 준비하고 있습니다...',
                '🌟 여행 스타일을 분석하고 있습니다...',
                '📝 체크리스트를 구성하고 있습니다...',
                '🔍 놓치기 쉬운 항목들을 찾고 있습니다...',
                '⚡ 스마트한 패킹 팁을 생성하고 있습니다...'
            ];
            
            // 랜덤한 로딩 텍스트 선택
            const randomText = loadingTexts[Math.floor(Math.random() * loadingTexts.length)];
            
            // 로딩 텍스트 요소가 있으면 텍스트 업데이트
            if (loadingTextElement) {
                // 타이핑 효과 추가
                loadingTextElement.textContent = '';
                let i = 0;
                const typingEffect = setInterval(() => {
                    if (i < randomText.length) {
                        loadingTextElement.textContent += randomText.charAt(i);
                        i++;
                    } else {
                        clearInterval(typingEffect);
                    }
                }, 30);
            }
            
            loadingMessage.style.display = 'block';
            
            // 채팅 컨테이너 스크롤 다운
            const chatMessages = document.getElementById('packingChatMessages');
            if (chatMessages) {
                setTimeout(() => {
                    chatMessages.scrollTop = chatMessages.scrollHeight;
                }, 100);
            }
        }

        // 패킹 로딩 메시지 숨기기 함수
        function hidePackingLoading() {
            const loadingMessage = document.getElementById('packingLoadingMessage');
            if (loadingMessage) {
                loadingMessage.style.display = 'none';
            }
        }

        // 메시지 추가
        function addMessage(role, content) {
            const messagesContainer = document.getElementById('packingChatMessages');
            const messageDiv = document.createElement('div');
            messageDiv.className = role === 'ai' ? 'ai-message' : 'user-message';
            
            const avatar = role === 'ai' ? '🤖' : '👤';
            messageDiv.innerHTML = `
                <div class="message-avatar">` + avatar + `</div>
                <div class="message-content">
                    <p>` + content.replace(/\n/g, '</p><p>') + `</p>
                </div>
            `;
            
            messagesContainer.appendChild(messageDiv);
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }
        
        // 진행률 업데이트
        function updateProgress(percentage) {
            const progressFill = document.getElementById('progressFill');
            const progressText = document.getElementById('progressText');
            
            progressFill.style.width = percentage + '%';
            progressText.textContent = Math.round(percentage / 33) + '/3 단계';
        }
        
        // 패킹 결과 표시
        function showPackingResults(packingList) {
            const chatContainer = document.querySelector('.packing-chat-container');
            const resultsContainer = document.getElementById('packingResults');
            const categoriesContainer = document.getElementById('packingCategories');
            
            // 채팅 숨기고 결과 표시
            chatContainer.style.display = 'none';
            resultsContainer.style.display = 'block';
            
            // 카테고리 아이콘 매핑
            const categoryIcons = {
                '의류': '👕',
                '세면용품': '🧴',
                '전자기기': '📱',
                '여행용품': '✈️',
                '액티비티 용품': '🏔️',
                '기타': '💼'
            };
            
            // 카테고리별 패킹 리스트 생성
            categoriesContainer.innerHTML = '';
            packingItems = packingList;
            let totalItems = 0;
            
            for (const [category, items] of Object.entries(packingList)) {
                if (items && items.length > 0) {
                    totalItems += items.length;
                    const categoryDiv = createCategoryDiv(category, items, categoryIcons[category] || '📦');
                    categoriesContainer.appendChild(categoryDiv);
                }
            }
            
            updateSummaryStats();
        }
        
        // 카테고리 DIV 생성
        function createCategoryDiv(category, items, icon) {
            const categoryDiv = document.createElement('div');
            categoryDiv.className = 'packing-category';
            
            let itemsHtml = '';
            items.forEach((item, index) => {
                const itemId = category + '-' + index;
                itemsHtml += '<div class="packing-item" id="item-' + itemId + '">' +
                    '<div class="item-checkbox" onclick="togglePackingItem(\'' + itemId + '\')" id="checkbox-' + itemId + '"></div>' +
                    '<div class="item-details">' +
                        '<h4 class="item-name">' + (item.itemName || item.name || '준비물') + '</h4>' +
                        '<p class="item-description">' + (item.description || '필요한 준비물입니다') + '</p>' +
                        '<span class="necessity-badge ' + (item.necessityLevel || '권장') + '">' + (item.necessityLevel || '권장') + '</span>' +
                    '</div>' +
                '</div>';
            });
            
            categoryDiv.innerHTML = 
                '<div class="category-header">' +
                    '<span class="category-icon">' + icon + '</span>' +
                    '<h3 class="category-title">' + category + ' (' + items.length + ')</h3>' +
                '</div>' +
                '<div class="category-items">' +
                    itemsHtml +
                '</div>';
            
            return categoryDiv;
        }
        
        // 패킹 아이템 체크 토글
        function togglePackingItem(itemId) {
            const checkbox = document.getElementById('checkbox-' + itemId);
            const item = document.getElementById('item-' + itemId);
            
            checkbox.classList.toggle('checked');
            item.classList.toggle('checked');
            
            updateSummaryStats();
        }
        
        // 요약 통계 업데이트
        function updateSummaryStats() {
            const allItems = document.querySelectorAll('.packing-item');
            const checkedItems = document.querySelectorAll('.packing-item.checked');
            
            const totalCount = allItems.length;
            const checkedCount = checkedItems.length;
            const progressPercent = totalCount > 0 ? Math.round((checkedCount / totalCount) * 100) : 0;
            
            document.getElementById('totalItems').textContent = totalCount;
            document.getElementById('checkedItems').textContent = checkedCount;
            document.getElementById('progressPercent').textContent = progressPercent + '%';
        }
        
        // PDF 내보내기
        function exportPackingList() {
            if (!packingConversationId) {
                alert('패킹 리스트가 없습니다.');
                return;
            }
            
            fetch('/api/packing/export/' + packingConversationId)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // PDF 다운로드 링크 생성
                    const link = document.createElement('a');
                    link.href = data.downloadUrl;
                    link.download = 'packing-list.pdf';
                    link.click();
                } else {
                    alert('PDF 생성에 실패했습니다: ' + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('PDF 생성 중 오류가 발생했습니다.');
            });
        }
        
        // 다시 시작
        function restartPacking() {
            const chatContainer = document.querySelector('.packing-chat-container');
            const resultsContainer = document.getElementById('packingResults');
            
            resultsContainer.style.display = 'none';
            chatContainer.style.display = 'flex';
            
            resetPackingAssistant();
        }
        
        // UUID 생성
        function generateUUID() {
            return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                const r = Math.random() * 16 | 0;
                const v = c == 'x' ? r : (r & 0x3 | 0x8);
                return v.toString(16);
            });
        }
        
        // 모달 외부 클릭 시 닫기
        window.onclick = function(event) {
            const packingModal = document.getElementById('packingAssistantModal');
            if (event.target === packingModal) {
                closePackingAssistant();
            }
        }
        
        // 플레이리스트 모달 열기 함수
        function openPlaylistModal() {
            console.log('플레이리스트 모달 열기');
            const modal = document.getElementById('playlistModal');
            modal.style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        // 플레이리스트 모달 닫기 함수
        function closePlaylistModal() {
            console.log('플레이리스트 모달 닫기');
            const modal = document.getElementById('playlistModal');
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
            
            // 선택 상태 초기화
            selectedCountry = null;
            selectedDestination = null;
            selectedGenre = null;
            document.querySelectorAll('.playlist-option-btn').forEach(btn => {
                btn.classList.remove('selected');
            });
            document.getElementById('playlistGenerateBtn').disabled = true;
            document.getElementById('playlistResultSection').style.display = 'none';
        }
        
        // 플레이리스트 변수들
        let selectedCountry = null;
        let selectedDestination = null;
        let selectedGenre = null;
        
        // 플레이리스트 옵션 선택 (토글 기능 추가)
        function selectPlaylistOption(element, type, value) {
            // 이미 선택된 버튼을 다시 클릭하면 선택 해제
            if (element.classList.contains('selected')) {
                element.classList.remove('selected');
                
                // 선택값 초기화
                if (type === 'country') {
                    selectedCountry = null;
                } else if (type === 'destination') {
                    selectedDestination = null;
                } else if (type === 'genre') {
                    selectedGenre = null;
                }
            } else {
                // 같은 타입의 다른 버튼들 선택 해제
                const sameTypeButtons = document.querySelectorAll(`.playlist-option-btn[data-type="${type}"]`);
                sameTypeButtons.forEach(btn => btn.classList.remove('selected'));
                
                // 현재 버튼 선택
                element.classList.add('selected');
                
                // 선택값 저장
                if (type === 'country') {
                    selectedCountry = value;
                } else if (type === 'destination') {
                    selectedDestination = value;
                } else if (type === 'genre') {
                    selectedGenre = value;
                }
            }
            
            console.log('선택 상태 - 국가:', selectedCountry, '여행지:', selectedDestination, '장르:', selectedGenre);
            
            // 생성 버튼 활성화 체크
            updatePlaylistGenerateButton();
        }
        
        // 플레이리스트 생성 버튼 활성화 체크 (모든 선택이 완료되어야 활성화)
        function updatePlaylistGenerateButton() {
            const generateBtn = document.getElementById('playlistGenerateBtn');
            if (selectedCountry && selectedDestination && selectedGenre) {
                generateBtn.disabled = false;
                generateBtn.classList.remove('disabled');
            } else {
                generateBtn.disabled = true;
                generateBtn.classList.add('disabled');
            }
        }
        
        // 플레이리스트 생성
        function generatePlaylist() {
            if (!selectedCountry || !selectedDestination || !selectedGenre) {
                alert('국가, 여행지, 음악 장르를 모두 선택해주세요.');
                return;
            }

            const generateBtn = document.getElementById('playlistGenerateBtn');
            const loadingOverlay = document.getElementById('playlistLoadingOverlay');
            
            // 로딩 시작
            generateBtn.disabled = true;
            loadingOverlay.style.display = 'flex';
            
            // 시간 카운터 시작
            let startTime = Date.now();
            let timerInterval = setInterval(() => {
                const elapsedSeconds = Math.floor((Date.now() - startTime) / 1000);
                document.getElementById('playlistTimer').textContent = `${elapsedSeconds}초`;
            }, 1000);
            
            // API 요청 데이터
            const requestData = {
                musicOrigin: selectedCountry,  // 선택된 국가 사용
                destinationType: selectedDestination,
                musicGenre: selectedGenre,
                timeOfDay: 'afternoon',  // 기본값
                travelStyle: 'relaxed'   // 기본값
            };

            fetch('${pageContext.request.contextPath}/playlist/recommend', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestData)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log('플레이리스트 전체 응답:', data);
                console.log('recommendations 배열:', data.recommendations);
                if (data.recommendations) {
                    data.recommendations.forEach((song, index) => {
                        console.log(`추천곡 ${index + 1}:`, {
                            title: song.songTitle,
                            artist: song.artist,
                            reason: song.reason,
                            genre: song.genre
                        });
                    });
                }
                if (data.success) {
                    displayPlaylistResult(data);
                    document.getElementById('playlistResultSection').style.display = 'block';
                    
                    // 버튼 텍스트를 "다시 추천받기"로 변경
                    const generateBtn = document.getElementById('playlistGenerateBtn');
                    generateBtn.innerHTML = '<i class="fas fa-redo me-2"></i>다시 추천받기';
                    
                    // 결과 섹션으로 스크롤
                    setTimeout(() => {
                        document.getElementById('playlistResultSection').scrollIntoView({ 
                            behavior: 'smooth', 
                            block: 'start' 
                        });
                    }, 300);
                } else {
                    alert(data.message || '플레이리스트 생성에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('플레이리스트 생성 오류:', error);
                alert('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
            })
            .finally(() => {
                // 시간 카운터 정리
                clearInterval(timerInterval);
                
                // 로딩 종료
                loadingOverlay.style.display = 'none';
                generateBtn.disabled = false;
            });
        }

        // 플레이리스트 결과 표시
        function displayPlaylistResult(data) {
            console.log('플레이리스트 결과 표시:', data);
            const resultDiv = document.getElementById('playlistResult');
            
            if (!data || !data.recommendations || data.recommendations.length === 0) {
                resultDiv.innerHTML = '<p class="no-result">플레이리스트를 생성할 수 없습니다.</p>';
                return;
            }

            let html = '';
            data.recommendations.forEach((song, index) => {
                // 데이터 확인 및 기본값 설정
                const songTitle = song.songTitle || '제목 없음';
                const artist = song.artist || '아티스트 없음';
                const reasonText = song.reason || '추천 이유 없음';
                const genre = song.genre || '장르 없음';
                
                console.log(`곡 ${index + 1}:`, { songTitle, artist, reason: reasonText, genre });
                
                html += 
                    '<div style="background: rgba(255, 255, 255, 0.95) !important; border: 1px solid rgba(139, 92, 246, 0.4) !important; border-radius: 15px !important; padding: 20px !important; margin-bottom: 15px !important; display: flex !important; align-items: flex-start !important; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08) !important;">' +
                        '<div style="margin-right: 15px !important;">' +
                            '<input type="checkbox" id="song-' + index + '" class="song-checkbox" data-song-title="' + songTitle + '" data-artist="' + artist + '" data-reason="' + reasonText + '" data-genre="' + genre + '" style="width: 20px !important; height: 20px !important; margin-top: 8px !important; cursor: pointer !important;">' +
                        '</div>' +
                        '<div style="margin-right: 15px !important;">' +
                            '<span style="display: inline-flex !important; align-items: center !important; justify-content: center !important; width: 35px !important; height: 35px !important; background: linear-gradient(135deg, #8b5cf6, #7c3aed) !important; color: white !important; border-radius: 50% !important; font-weight: 700 !important; font-size: 1rem !important; box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3) !important;">' + (index + 1) + '</span>' +
                        '</div>' +
                        '<div style="flex: 1 !important;">' +
                            '<div style="display: flex !important; justify-content: space-between !important; align-items: flex-start !important; margin-bottom: 5px !important;">' +
                                '<div style="flex: 1 !important;">' +
                                    '<div style="font-weight: 700 !important; font-size: 1.2em !important; color: #1f2937 !important; margin-bottom: 5px !important; text-shadow: 0 1px 2px rgba(0,0,0,0.1) !important;">' + songTitle + '</div>' +
                                    '<div style="color: #6b7280 !important; font-weight: 500 !important; margin-bottom: 8px !important; font-size: 1em !important;">' + artist + '</div>' +
                                '</div>' +
                            '</div>' +
                            '<div style="color: #4b5563 !important; font-size: 0.9rem !important; font-style: italic !important; background: rgba(139, 92, 246, 0.08) !important; padding: 8px 12px !important; border-radius: 8px !important; border-left: 3px solid rgba(139, 92, 246, 0.5) !important; margin-bottom: 8px !important; line-height: 1.4 !important;">💡 ' + reasonText + '</div>' +
                            '<div style="display: flex !important; justify-content: space-between !important; align-items: center !important;">' +
                                '<span style="display: inline-block !important; background: linear-gradient(135deg, #8b5cf6, #7c3aed) !important; color: white !important; padding: 4px 12px !important; border-radius: 20px !important; font-size: 0.8rem !important; font-weight: 500 !important;">' + genre + '</span>' +
                            '</div>' +
                        '</div>' +
                    '</div>';
            });
            
            // 저장하기 버튼 추가 (로그인 상태에 따른 버튼 텍스트 변경)
            const isLoggedIn = ${sessionScope.loginUser != null};
            const buttonText = isLoggedIn ? '선택한 음악 저장하기' : '로그인하고 음악 저장하기';
            html += '<div style="text-align: center; margin-top: 20px;">' +
                        '<button id="savePlaylistBtn" onclick="saveSelectedPlaylist()" style="background: linear-gradient(135deg, #10b981, #059669) !important; color: white !important; border: none !important; padding: 12px 30px !important; border-radius: 25px !important; font-size: 1rem !important; font-weight: 600 !important; cursor: pointer !important; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3) !important; transition: all 0.3s ease !important;">' +
                            '<i class="fas fa-save" style="margin-right: 8px !important;"></i>' + buttonText +
                        '</button>' +
                    '</div>';
            
            resultDiv.innerHTML = html;
        }

        // 선택한 플레이리스트 저장 함수
        function saveSelectedPlaylist() {
            // 로그인 상태 확인 (로그인 안한 사용자도 저장 가능)
            const isLoggedIn = ${sessionScope.loginUser != null};
            
            // 선택된 음악들 수집
            const selectedSongs = [];
            const checkboxes = document.querySelectorAll('.song-checkbox:checked');
            
            if (checkboxes.length === 0) {
                alert('저장할 음악을 선택해주세요.');
                return;
            }

            checkboxes.forEach(checkbox => {
                selectedSongs.push({
                    songTitle: checkbox.dataset.songTitle,
                    artist: checkbox.dataset.artist,
                    reason: checkbox.dataset.reason,
                    genre: checkbox.dataset.genre
                });
            });

            // 서버에 저장 요청
            const saveData = {
                musicOrigin: selectedCountry,
                destinationType: selectedDestination,
                musicGenre: selectedGenre,
                timeOfDay: 'afternoon',
                travelStyle: 'relaxed',
                selectedSongs: selectedSongs
            };

            fetch('${pageContext.request.contextPath}/playlist/save', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(saveData)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    alert(`선택한 ${selectedSongs.length}곡이 성공적으로 저장되었습니다!`);
                    // 체크박스 초기화
                    checkboxes.forEach(checkbox => checkbox.checked = false);
                } else {
                    alert(data.message || '플레이리스트 저장에 실패했습니다.');
                }
            })
            .catch(error => {
                console.error('플레이리스트 저장 오류:', error);
                alert('네트워크 오류가 발생했습니다. 다시 시도해주세요.');
            });
        }

        // 현재 재생 중인 오디오 추적
    </script>
    
    <!-- Enhanced Packing UI JavaScript -->
    <script src="${pageContext.request.contextPath}/js/enhanced-packing-ui.js"></script>
    
    <!-- 플레이리스트 모달 -->
    <div id="playlistModal" class="playlist-modal" style="display: none;">
        <div class="playlist-modal-content">
            <div class="playlist-modal-header">
                <h2 class="playlist-modal-title">🎵 AI 여행 플레이리스트</h2>
                <span class="playlist-modal-close" onclick="closePlaylistModal()">&times;</span>
            </div>
            
            <div class="playlist-modal-body">
                <p class="playlist-subtitle">당신만의 완벽한 여행 음악을 찾아보세요!</p>
                
                <!-- 음악 국가 선택 -->
                <div class="playlist-selection-section">
                    <h3 class="playlist-section-title">🎵 국가를 선택해주세요</h3>
                    <div class="playlist-options-grid">
                        <button class="playlist-option-btn" data-type="country" data-value="korean" 
                                onclick="selectPlaylistOption(this, 'country', 'korean')">
                            <span class="playlist-option-icon">🇰🇷</span>
                            <div class="playlist-option-title">한국 음악</div>
                            <div class="playlist-option-description">K-POP, K-발라드, K-힙합</div>
                        </button>
                        <button class="playlist-option-btn" data-type="country" data-value="foreign" 
                                onclick="selectPlaylistOption(this, 'country', 'foreign')">
                            <span class="playlist-option-icon">🌍</span>
                            <div class="playlist-option-title">외국 음악</div>
                            <div class="playlist-option-description">팝, 록, 재즈, 클래식</div>
                        </button>
                        <button class="playlist-option-btn" data-type="country" data-value="mixed" 
                                onclick="selectPlaylistOption(this, 'country', 'mixed')">
                            <span class="playlist-option-icon">🌏</span>
                            <div class="playlist-option-title">한국+외국 음악</div>
                            <div class="playlist-option-description">K-POP과 팝 등 섞어서</div>
                        </button>
                    </div>
                </div>
                
                <!-- 여행지 선택 -->
                <div class="playlist-selection-section">
                    <h3 class="playlist-section-title">🏞️ 여행지를 선택해주세요</h3>
                    <div class="playlist-options-grid">
                        <button class="playlist-option-btn" data-type="destination" data-value="pension" 
                                onclick="selectPlaylistOption(this, 'destination', 'pension')">
                            <span class="playlist-option-icon">🏠</span>
                            <div class="playlist-option-title">펜션</div>
                            <div class="playlist-option-description">조용하고 아늑한 휴식</div>
                        </button>
                        <button class="playlist-option-btn" data-type="destination" data-value="highway" 
                                onclick="selectPlaylistOption(this, 'destination', 'highway')">
                            <span class="playlist-option-icon">🛣️</span>
                            <div class="playlist-option-title">고속도로</div>
                            <div class="playlist-option-description">드라이브의 역동적 분위기</div>
                        </button>
                        <button class="playlist-option-btn" data-type="destination" data-value="beach" 
                                onclick="selectPlaylistOption(this, 'destination', 'beach')">
                            <span class="playlist-option-icon">🌊</span>
                            <div class="playlist-option-title">바닷가</div>
                            <div class="playlist-option-description">파도 소리와 바다 전망</div>
                        </button>
                        <button class="playlist-option-btn" data-type="destination" data-value="resort" 
                                onclick="selectPlaylistOption(this, 'destination', 'resort')">
                            <span class="playlist-option-icon">🏖️</span>
                            <div class="playlist-option-title">휴양지</div>
                            <div class="playlist-option-description">고급스럽고 여유로운 분위기</div>
                        </button>
                        <button class="playlist-option-btn" data-type="destination" data-value="mountain" 
                                onclick="selectPlaylistOption(this, 'destination', 'mountain')">
                            <span class="playlist-option-icon">⛰️</span>
                            <div class="playlist-option-title">산악지대</div>
                            <div class="playlist-option-description">자연 속 힐링과 활력</div>
                        </button>
                        <button class="playlist-option-btn" data-type="destination" data-value="city" 
                                onclick="selectPlaylistOption(this, 'destination', 'city')">
                            <span class="playlist-option-icon">🏙️</span>
                            <div class="playlist-option-title">도시</div>
                            <div class="playlist-option-description">번화가의 역동적 에너지</div>
                        </button>
                        <button class="playlist-option-btn" data-type="destination" data-value="camping" 
                                onclick="selectPlaylistOption(this, 'destination', 'camping')">
                            <span class="playlist-option-icon">🏕️</span>
                            <div class="playlist-option-title">캠핑장</div>
                            <div class="playlist-option-description">자연 속 모험과 낭만</div>
                        </button>
                        <button class="playlist-option-btn" data-type="destination" data-value="hotspring" 
                                onclick="selectPlaylistOption(this, 'destination', 'hotspring')">
                            <span class="playlist-option-icon">♨️</span>
                            <div class="playlist-option-title">온천</div>
                            <div class="playlist-option-description">따뜻한 온천과 힐링</div>
                        </button>
                    </div>
                </div>

                <!-- 음악 장르 선택 -->
                <div class="playlist-selection-section">
                    <h3 class="playlist-section-title">🎧 음악 장르를 선택해주세요</h3>
                    <div class="playlist-options-grid">
                        <button class="playlist-option-btn" data-type="genre" data-value="classic" 
                                onclick="selectPlaylistOption(this, 'genre', 'classic')">
                            <span class="playlist-option-icon">🎼</span>
                            <div class="playlist-option-title">클래식</div>
                            <div class="playlist-option-description">우아하고 고전적인 선율</div>
                        </button>
                        <button class="playlist-option-btn" data-type="genre" data-value="rock" 
                                onclick="selectPlaylistOption(this, 'genre', 'rock')">
                            <span class="playlist-option-icon">🎸</span>
                            <div class="playlist-option-title">락</div>
                            <div class="playlist-option-description">강렬하고 역동적인 사운드</div>
                        </button>
                        <button class="playlist-option-btn" data-type="genre" data-value="energetic" 
                                onclick="selectPlaylistOption(this, 'genre', 'energetic')">
                            <span class="playlist-option-icon">⚡</span>
                            <div class="playlist-option-title">신나는</div>
                            <div class="playlist-option-description">활기차고 업템포 음악</div>
                        </button>
                        <button class="playlist-option-btn" data-type="genre" data-value="quiet" 
                                onclick="selectPlaylistOption(this, 'genre', 'quiet')">
                            <span class="playlist-option-icon">🌙</span>
                            <div class="playlist-option-title">조용한</div>
                            <div class="playlist-option-description">잔잔하고 평온한 음악</div>
                        </button>
                        <button class="playlist-option-btn" data-type="genre" data-value="jazz" 
                                onclick="selectPlaylistOption(this, 'genre', 'jazz')">
                            <span class="playlist-option-icon">🎷</span>
                            <div class="playlist-option-title">재즈</div>
                            <div class="playlist-option-description">세련되고 감성적인 선율</div>
                        </button>
                        <button class="playlist-option-btn" data-type="genre" data-value="pop" 
                                onclick="selectPlaylistOption(this, 'genre', 'pop')">
                            <span class="playlist-option-icon">🎤</span>
                            <div class="playlist-option-title">팝</div>
                            <div class="playlist-option-description">대중적이고 친숙한 멜로디</div>
                        </button>
                        <button class="playlist-option-btn" data-type="genre" data-value="hiphop" 
                                onclick="selectPlaylistOption(this, 'genre', 'hiphop')">
                            <span class="playlist-option-icon">🎵</span>
                            <div class="playlist-option-title">힙합</div>
                            <div class="playlist-option-description">리듬감 있고 현대적 비트</div>
                        </button>
                        <button class="playlist-option-btn" data-type="genre" data-value="indie" 
                                onclick="selectPlaylistOption(this, 'genre', 'indie')">
                            <span class="playlist-option-icon">🎻</span>
                            <div class="playlist-option-title">인디</div>
                            <div class="playlist-option-description">독창적이고 개성 있는 음악</div>
                        </button>
                    </div>
                </div>

                <!-- 추천 받기 버튼 -->
                <div class="playlist-generate-section">
                    <button class="playlist-generate-btn disabled" id="playlistGenerateBtn" disabled onclick="generatePlaylist()">
                        <i class="fas fa-music me-2"></i>음악 추천받기
                    </button>
                </div>

                <!-- 결과 섹션 -->
                <div class="playlist-result-section" id="playlistResultSection" style="display: none;">
                    <h4 class="playlist-result-title">
                        <i class="fas fa-headphones me-2"></i>
                        당신을 위한 맞춤 플레이리스트
                    </h4>
                    <div id="playlistResult"></div>
                </div>
                
            </div>
            
            <!-- 로딩 오버레이 -->
            <div id="playlistLoadingOverlay" class="playlist-loading-overlay" style="display: none;">
                <div class="playlist-loading-spinner"></div>
                <div class="playlist-loading-text">AI가 완벽한 플레이리스트를 만들고 있습니다... <span id="playlistTimer">0초</span></div>
            </div>
        </div>
    </div>

    <style>
        /* 플레이리스트 모달 스타일 */
        .playlist-modal {
            display: none;
            position: fixed;
            z-index: 10000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(5px);
            -webkit-backdrop-filter: blur(5px);
        }

        .playlist-modal-content {
            background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
            margin: 2% auto;
            padding: 0;
            border-radius: 25px;
            width: 90%;
            max-width: 900px;
            max-height: 90vh;
            overflow: hidden;
            position: relative;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            animation: modalSlideIn 0.4s ease-out;
        }

        @keyframes modalSlideIn {
            from {
                opacity: 0;
                transform: translateY(-50px) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        .playlist-modal-header {
            background: rgba(0, 0, 0, 0.2);
            color: white;
            padding: 20px 30px;
            border-radius: 25px 25px 0 0;
            position: relative;
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }

        .playlist-modal-title {
            font-size: 1.8em;
            font-weight: 700;
            margin: 0;
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }

        .playlist-modal-close {
            position: absolute;
            right: 25px;
            top: 50%;
            transform: translateY(-50%);
            color: white;
            font-size: 2em;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.1);
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .playlist-modal-close:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateY(-50%) scale(1.1) rotate(90deg);
        }

        .playlist-modal-body {
            padding: 30px;
            max-height: calc(90vh - 120px);
            overflow-y: auto;
            position: relative;
        }

        .playlist-subtitle {
            color: rgba(255, 255, 255, 0.9);
            text-align: center;
            margin-bottom: 30px;
            font-size: 1.1em;
            font-weight: 300;
        }

        .playlist-selection-section {
            margin-bottom: 35px;
        }

        .playlist-section-title {
            font-size: 1.3em;
            color: white;
            margin-bottom: 20px;
            font-weight: 600;
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }

        .playlist-options-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px;
            margin-bottom: 20px;
        }

        .playlist-option-btn {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            padding: 18px 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: white;
            text-align: center;
            font-weight: 500;
            position: relative;
            overflow: hidden;
        }

        .playlist-option-btn::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: left 0.6s ease;
        }

        .playlist-option-btn:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
            border-color: rgba(255, 255, 255, 0.4);
        }

        .playlist-option-btn:hover::before {
            left: 100%;
        }

        .playlist-option-btn.selected {
            background: rgba(255, 255, 255, 0.35);
            border-color: rgba(255, 255, 255, 0.6);
            transform: scale(1.05);
            box-shadow: 0 8px 30px rgba(255, 255, 255, 0.3);
        }

        /* 한국 음악 선택 시 빨간색 */
        .playlist-option-btn[data-value="korean"].selected {
            background: linear-gradient(135deg, #ff6b6b, #ee5a52) !important;
            border-color: #ff4757 !important;
            box-shadow: 0 8px 30px rgba(255, 107, 107, 0.6) !important;
            color: white !important;
        }

        .playlist-option-btn[data-value="korean"].selected .playlist-option-title,
        .playlist-option-btn[data-value="korean"].selected .playlist-option-description {
            color: white !important;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        /* 외국 음악 선택 시 파란색 */
        .playlist-option-btn[data-value="foreign"].selected {
            background: linear-gradient(135deg, #3742fa, #2f3542) !important;
            border-color: #3742fa !important;
            box-shadow: 0 8px 30px rgba(55, 66, 250, 0.6) !important;
            color: white !important;
        }

        .playlist-option-btn[data-value="foreign"].selected .playlist-option-title,
        .playlist-option-btn[data-value="foreign"].selected .playlist-option-description {
            color: white !important;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        /* 혼합 음악 선택 시 보라색 */
        .playlist-option-btn[data-value="mixed"].selected {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed) !important;
            border-color: #6d28d9 !important;
            box-shadow: 0 8px 30px rgba(139, 92, 246, 0.6) !important;
            color: white !important;
        }

        .playlist-option-btn[data-value="mixed"].selected .playlist-option-title,
        .playlist-option-btn[data-value="mixed"].selected .playlist-option-description {
            color: white !important;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        /* 여행지 선택 시 초록색 */
        .playlist-option-btn[data-type="destination"].selected {
            background: linear-gradient(135deg, #10b981, #059669) !important;
            border-color: #047857 !important;
            box-shadow: 0 8px 30px rgba(16, 185, 129, 0.6) !important;
            color: white !important;
        }

        .playlist-option-btn[data-type="destination"].selected .playlist-option-title,
        .playlist-option-btn[data-type="destination"].selected .playlist-option-description {
            color: white !important;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        /* 장르 선택 시 주황색 */
        .playlist-option-btn[data-type="genre"].selected {
            background: linear-gradient(135deg, #f97316, #ea580c) !important;
            border-color: #c2410c !important;
            box-shadow: 0 8px 30px rgba(249, 115, 22, 0.6) !important;
            color: white !important;
        }

        .playlist-option-btn[data-type="genre"].selected .playlist-option-title,
        .playlist-option-btn[data-type="genre"].selected .playlist-option-description {
            color: white !important;
            text-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        .playlist-option-icon {
            font-size: 1.8em;
            margin-bottom: 8px;
            display: block;
        }

        .playlist-option-title {
            font-size: 1.1em;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .playlist-option-description {
            font-size: 0.85em;
            color: rgba(255, 255, 255, 0.8);
            line-height: 1.3;
        }

        .playlist-generate-section {
            text-align: center;
            margin: 30px 0;
        }

        .playlist-generate-btn {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.3), rgba(255, 255, 255, 0.1));
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            color: white;
            border: 2px solid rgba(255, 255, 255, 0.4);
            padding: 15px 40px;
            border-radius: 50px;
            font-size: 1.2em;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }

        .playlist-generate-btn:hover:not(.disabled) {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.4), rgba(255, 255, 255, 0.2));
            transform: translateY(-2px);
            box-shadow: 0 12px 35px rgba(0, 0, 0, 0.25);
        }

        .playlist-generate-btn.disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        .playlist-result-section {
            margin-top: 30px;
        }

        .playlist-result-title {
            font-size: 1.4em;
            color: white;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 600;
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }

        .playlist-music-item {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            border: 1px solid rgba(139, 92, 246, 0.4);
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 15px;
            transition: all 0.3s ease;
            display: flex;
            align-items: flex-start;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        }

        .playlist-music-item:hover {
            background: rgba(255, 255, 255, 1);
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(139, 92, 246, 0.2);
            border-color: rgba(139, 92, 246, 0.6);
        }

        .music-number-container {
            margin-right: 15px;
        }

        .playlist-music-number {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 35px;
            height: 35px;
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            color: white;
            border-radius: 50%;
            font-weight: 700;
            font-size: 1rem;
            box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
        }

        .music-info {
            flex: 1;
        }

        .playlist-music-title {
            font-weight: 700;
            font-size: 1.2em;
            color: #1f2937 !important;
            margin-bottom: 5px;
        }

        .playlist-music-artist {
            color: #6b7280 !important;
            font-weight: 500;
            margin-bottom: 8px;
            font-size: 1em;
        }

        .playlist-music-reason {
            color: #4b5563 !important;
            font-size: 0.9rem;
            font-style: italic;
            background: rgba(139, 92, 246, 0.08);
            padding: 8px 12px;
            border-radius: 8px;
            border-left: 3px solid rgba(139, 92, 246, 0.5);
            margin-bottom: 8px;
            line-height: 1.4;
        }

        .playlist-music-genre {
            display: inline-block;
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
            color: white !important;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        .playlist-loading-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            border-radius: 25px;
            z-index: 10001;
        }

        .playlist-loading-spinner {
            width: 50px;
            height: 50px;
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top: 4px solid white;
            border-radius: 50%;
            animation: playlistSpin 1s linear infinite;
            margin-bottom: 20px;
        }

        .playlist-loading-text {
            color: white;
            font-size: 1.1em;
            font-weight: 500;
            text-shadow: 0 2px 10px rgba(0,0,0,0.3);
        }

        @keyframes playlistSpin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .no-result {
            text-align: center;
            color: rgba(255, 255, 255, 0.8);
            font-style: italic;
            padding: 20px;
        }

        /* 스크롤바 스타일 */
        .playlist-modal-body::-webkit-scrollbar {
            width: 8px;
        }

        .playlist-modal-body::-webkit-scrollbar-track {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
        }

        .playlist-modal-body::-webkit-scrollbar-thumb {
            background: rgba(255, 255, 255, 0.3);
            border-radius: 10px;
            border: 2px solid transparent;
            background-clip: content-box;
        }

        .playlist-modal-body::-webkit-scrollbar-thumb:hover {
            background: rgba(255, 255, 255, 0.5);
            background-clip: content-box;
        }

        @media (max-width: 768px) {
            .playlist-modal-content {
                width: 95%;
                margin: 1% auto;
            }
            
            .playlist-options-grid {
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
                gap: 10px;
            }
            
            .playlist-option-btn {
                padding: 15px 10px;
            }
            
            .playlist-option-icon {
                font-size: 1.5em;
            }
        }
    </style>
    
    <script>
        // 리뷰 슬라이드쇼 자동 전환 JavaScript
        document.addEventListener('DOMContentLoaded', function() {
            const slides = document.querySelectorAll('.review-slide');
            let currentSlide = 0;
            
            function nextSlide() {
                // 현재 활성 슬라이드에서 active 클래스 제거
                slides[currentSlide].classList.remove('active');
                
                // 다음 슬라이드로 이동 (마지막이면 처음으로)
                currentSlide = (currentSlide + 1) % slides.length;
                
                // 새 슬라이드에 active 클래스 추가
                slides[currentSlide].classList.add('active');
            }
            
            // 3초마다 자동으로 슬라이드 전환
            setInterval(nextSlide, 3000);
        });
    </script>
    
</body>
</html>