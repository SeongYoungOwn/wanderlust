<!-- 영수증.html 완벽 복사본 스타일 -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    /* 티켓 컨테이너 기본 스타일 */
    .receipt-container {
        background: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
        margin: 0;
        padding: 60px 20px;
        border-radius: 20px;
        margin-bottom: 40px;
        position: relative;
        overflow: hidden;
        min-height: 600px;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 8px 25px rgba(74, 144, 226, 0.3);
    }

    .output {
        align-self: center;
        background: inherit;
        border-radius: 100px;
        padding: 0 12px 0 10px;
        height: 42px;
        min-width: 700px;
        position: relative;
        top: -140px;
    }

    .output .cover {
        position: absolute;
        top: 2px;
        right: 2px;
        bottom: 2px;
        left: 2px;
        border-radius: 100px;
        clip-path: inset(0 0 0 0 round 100px);
        background: rgba(255, 255, 255, 0.3);
        transition: filter 1000ms cubic-bezier(0, 0, 0, 1);
        filter: blur(5px);
    }

    .output .cover::after {
        content: "";
        top: -10px;
        right: -10px;
        bottom: -10px;
        left: -10px;
        border-radius: 100px;
        position: absolute;
        background: inherit;
        opacity: 0.5;
    }

    .output .wrap-colors-1,
    .output .wrap-colors-2 {
        overflow: hidden;
        border-radius: 100px;
        position: absolute;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        pointer-events: none;
    }

    .output .wrap-colors-1 {
        opacity: 0.35;
        filter: blur(3px);
    }

    .output .bg-colors {
        background: conic-gradient(transparent 0deg,
                transparent 324deg,
                transparent 360deg);
        position: absolute;
        width: 700px;
        height: 400px;
        margin: auto;
        inset: 0;
        left: 50%;
        transform: translateX(-50%) rotate(220deg);
        border-radius: 50%;
        animation: cycle-rotate 3s ease-in-out infinite;
    }

    .output::before {
        content: "";
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        border-radius: inherit;
        position: absolute;
        border: 1px solid rgba(255, 255, 255, 0.2);
        background: #ffffff14;
        opacity: 0.4;
        transition: opacity 400ms linear, background-color 400ms linear;
    }

    .output::after {
        content: "";
        position: absolute;
        left: 12px;
        right: 12px;
        top: 14px;
        background: linear-gradient(0deg, transparent, black);
        height: 9px;
        mix-blend-mode: soft-light;
        border-radius: 100px;
    }

    @keyframes cycle-rotate {
        from { transform: translateX(-50%) rotate(0deg); }
        to { transform: translateX(-50%) rotate(360deg); }
    }

    .area {
        --ease-elastic: cubic-bezier(0.5, 2, 0.3, 0.8);
        display: flex;
        align-items: center;
        justify-content: center;
        position: absolute;
        inset: 0;
    }

    .area::after {
        pointer-events: none;
        content: "";
        position: absolute;
        top: 66%;
        left: 0;
        right: 0;
        height: 100px;
        width: 30%;
        margin: auto;
        background-color: rgba(255, 255, 255, 0.3);
        filter: blur(2em);
        opacity: 0.7;
        transform: perspective(10px) rotateX(5deg) scale(1, 0.5);
        z-index: 0;
    }

    .ticket-mask {
        position: absolute;
        overflow: hidden;
        display: flex;
        justify-content: center;
        mask-image: linear-gradient(rgba(0, 0, 0, 0.1) 0%, white 20px);
        perspective: 1000px;
        top: calc(50% - 142px);
        left: 0;
        right: 0;
        height: 100%;
        min-height: 1500px;
    }

    .ticket {
        float: left;
        animation: ticket-move 16s ease-in-out infinite;
        transform: translateY(50px);
        perspective: 3000px;
    }

    @keyframes ticket-move {
        0% { transform: translateY(-300px); }
        5% { transform: translateY(-250px); }
        8% { transform: translateY(-200px); }
        11% { transform: translateY(-170px); }
        15% { transform: translateY(-100px); }
        19% { transform: translateY(-40px); }
        23%, 93% { transform: translateY(45px); }
        100% { transform: translateY(100%) rotateX(160deg) scale(5); }
    }

    .ticket:hover .ticket-flip-container {
        transform: rotateY(180deg);
    }

    .ticket-flip-container {
        transition: 0.6s;
        transform-style: preserve-3d;
        position: relative;
    }

    .float {
        transform-style: preserve-3d;
        pointer-events: none;
        animation: float 3s ease-in-out infinite;
    }

    .front, .back {
        display: inline-block;
        backface-visibility: hidden;
        transform-style: preserve-3d;
    }

    .front {
        z-index: 1;
    }

    .back {
        position: absolute;
        top: 0;
        left: 0;
        transform: rotateY(-180deg);
    }

    @keyframes float {
        0% { transform: translateY(0); }
        50% { transform: translateY(-15px); }
        100% { transform: translateY(0); }
    }

    .icon-cube {
        position: absolute;
        height: 110%;
        z-index: 1;
        top: -3px;
        left: 0;
        right: 0;
        margin: auto;
        mix-blend-mode: soft-light;
        opacity: 0.6;
    }

    .icon-cube path {
        animation-delay: calc(var(--i) * 100ms) !important;
        transform-origin: center;
    }

    .icon-cube .path-center { animation: path-center 3s ease-in-out infinite; }
    @keyframes path-center { 50% { transform: scale(1.3); } }

    .icon-cube .path-t { animation: path-t 1.6s ease-in-out infinite; }
    @keyframes path-t { 50% { transform: translateY(1px); } }

    .icon-cube .path-tl { animation: path-tl 1.6s ease-in-out infinite; }
    @keyframes path-tl { 50% { transform: translateX(1px) translateY(1px); } }

    .icon-cube .path-tr { animation: path-tr 1.6s ease-in-out infinite; }
    @keyframes path-tr { 50% { transform: translateX(-1px) translateY(1px); } }

    .icon-cube .path-br { animation: path-br 1.6s ease-in-out infinite; }
    @keyframes path-br { 50% { transform: translateX(-1px) translateY(-1px); } }

    .icon-cube .path-bl { animation: path-bl 1.6s ease-in-out infinite; }
    @keyframes path-bl { 50% { transform: translateX(1px) translateY(-1px); } }

    .icon-cube .path-b { animation: path-b 1.6s ease-in-out infinite; }
    @keyframes path-b { 50% { transform: translateY(-1px); } }

    .ticket-body {
        display: block;
        position: relative;
        width: 600px;
        margin-bottom: 20px;
        padding: 0;
        border-radius: 7px 7px 0px 0px;
        background-color: white;
        text-align: center;
        background: linear-gradient(to bottom, white, #E8F5E9);
        color: black;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }

    .ticket-body svg,
    .ticket-body img {
        pointer-events: none;
    }

    .ticket-body .bold {
        font-weight: 800;
    }

    .ticket-body header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        position: relative;
        padding: 15px;
        border-bottom: 1px dashed rgba(0, 0, 0, 0.4);
        text-align: left;
        height: 54px;
        background: radial-gradient(at 30% -5%,
                #90f1f1,
                #d3ccf0,
                rgba(255, 255, 255, 0) 25%),
            radial-gradient(at 30% 40%, #aad1f0, rgba(255, 255, 255, 0) 20%),
            radial-gradient(at 50% 70%, #c4f2e5, rgba(255, 255, 255, 0) 30%),
            radial-gradient(at 70% 0%, #d3ccf0, rgba(255, 255, 255, 0) 20%),
            linear-gradient(75deg,
                #90f1f1 5%,
                rgba(255, 255, 255, 0),
                #aad1f0,
                rgba(255, 255, 255, 0),
                #e9d0ed,
                rgba(255, 255, 255, 0),
                #d3ccf0,
                rgba(255, 255, 255, 0),
                #c4f2e5 90%),
            radial-gradient(at 30% 50%, #90f1f1, rgba(255, 255, 255, 0) 30%),
            radial-gradient(at 30% 50%, #9cb9fc, rgba(255, 255, 255, 0) 30%),
            radial-gradient(at 100% 50%, #90f1f1, #c2dcf2, rgba(255, 255, 255, 0) 50%),
            linear-gradient(115deg,
                #90f1f1 5%,
                #aad1f0 10%,
                #d3ccf0,
                #e9d0ed 20%,
                #aad1f0,
                #aad1f0 30%,
                #d3ccf0,
                #c2dcf2 40%,
                #90f1f1,
                #aad1f0 70%);
    }

    .ticket-body header .ticket-name {
        font-weight: 300;
        font-size: 1.3em;
        line-height: normal;
        align-items: center;
        display: flex;
        gap: 4px;
        letter-spacing: -2px;
    }

    .ticket-body header span {
        display: inline-block;
    }

    .ticket-body header time {
        display: flex;
    }

    .ticket-body header .slash {
        padding: 0 1px;
        color: rgba(0, 0, 0, 0.4);
    }

    .ticket-body header::after,
    .ticket-body header::before {
        content: "";
        display: block;
        width: 13px;
        height: 13px;
        background: transparent;
        position: absolute;
        right: -8px;
        border-radius: 50%;
        z-index: 11;
        bottom: -7px;
    }

    .ticket-body header:after {
        left: -8px;
    }

    .ticket-body .contents {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
        min-height: 260px;
        position: relative;
        pointer-events: all;
    }

    .ticket-body .contents .event {
        display: flex;
        flex-direction: column;
        position: relative;
        z-index: 1;
        margin-top: -30px;
        font-weight: 600;
    }

    .ticket-body .contents .event span {
        display: inline-block;
        height: 15px;
        font-size: 3.5rem;
        font-weight: 400;
        line-height: 1;
    }

    .ticket-body .contents .event span.bold {
        font-size: 3rem;
        font-weight: 800;
        margin-right: -3px;
    }

    .ticket-body .contents .event div:nth-child(2) {
        font-size: 16px;
        letter-spacing: 0.45em;
        margin-left: 6px;
        color: #00000062;
    }

    .ticket-body .contents .number {
        position: absolute;
        left: 15px;
        bottom: -6px;
        font-size: 2.5em;
        color: #2903fd;
        font-weight: bolder;
    }

    .ticket-body:after {
        content: "";
        display: block;
        position: absolute;
        bottom: -16px;
        left: 0;
        background:
            -webkit-linear-gradient(-135deg, #E8F5E9 50%, transparent 50%) 0 50%,
            -webkit-linear-gradient(-45deg, #E8F5E9 50%, transparent 50%) 0 50%,
            transparent;
        background-repeat: repeat-x;
        background-size: 16px 16px, 16px 16px, cover, cover;
        height: 16px;
        width: 100%;
        pointer-events: none;
    }

    .barcode {
        box-shadow:
            1px 0 0 1px, 5px 0 0 1px, 10px 0 0 1px, 11px 0 0 1px,
            15px 0 0 1px, 18px 0 0 1px, 22px 0 0 1px, 23px 0 0 1px,
            26px 0 0 1px, 30px 0 0 1px, 35px 0 0 1px, 37px 0 0 1px,
            41px 0 0 1px, 44px 0 0 1px, 47px 0 0 1px, 51px 0 0 1px,
            56px 0 0 1px, 59px 0 0 1px, 64px 0 0 1px, 68px 0 0 1px,
            72px 0 0 1px, 74px 0 0 1px, 77px 0 0 1px, 81px 0 0 1px,
            85px 0 0 1px, 88px 0 0 1px, 92px 0 0 1px, 95px 0 0 1px,
            96px 0 0 1px, 97px 0 0 1px;
        display: inline-block;
        height: 30px;
        width: 0;
        position: absolute;
        top: 12px;
        right: 110px;
    }

    .mjc-logo {
        position: absolute;
        right: 5px;
        bottom: -5px;
        height: 70px;
        z-index: 2;
        pointer-events: none;
    }

    @keyframes appear {
        0% { opacity: 0; transform: translateX(100%); }
        100% { opacity: 1; transform: translateY(0); }
    }

    @keyframes appear2 {
        0% { opacity: 1; transform: translateY(0); }
        100% { opacity: 0; transform: translateX(100%); }
    }

    .back header span { animation: none; }

    .ticket:hover .back header span {
        opacity: 0;
        animation: appear 0.5s var(--ease-elastic) forwards calc(var(--i) * 20ms + 400ms);
    }

    .ticket:hover .front header span {
        opacity: 1;
        animation: appear2;
    }

    .front header span {
        opacity: 0;
        animation: appear 0.5s var(--ease-elastic) forwards calc(var(--i) * 20ms + 400ms);
    }

    .reflex {
        pointer-events: none;
        position: absolute;
        inset: 0;
        bottom: -5px;
        z-index: 10;
        overflow: hidden;
    }

    .reflex::before {
        content: "";
        position: absolute;
        width: 300px;
        background: linear-gradient(to right,
                rgba(255, 255, 255, 0.2) 10%,
                rgba(221, 245, 255, 0.3) 60%,
                rgba(221, 246, 255, 0.25) 60%,
                rgba(221, 255, 254, 0.2) 90%);
        top: -10%;
        bottom: -10%;
        left: -132%;
        transform: translateX(0) skew(-30deg);
        transition: all 0.7s ease;
    }

    .float:hover .reflex::before {
        transform: translate(550%, 0) skew(-30deg);
    }

    .float .front .reflex::before {
        transition-delay: 0.3s;
    }
     .ticket-body::before {
            content: "";
            position: absolute;
            inset: 0;
            mask-image: linear-gradient(white 50%, transparent 100%);
            border-radius: 7px 7px 0px 0px;
            background: radial-gradient(at 30% -5%,
                    #90f1f1,
                    #d3ccf0,
                    rgba(255, 255, 255, 0) 25%),
                radial-gradient(at 30% 40%, #aad1f0, rgba(255, 255, 255, 0) 20%),
                radial-gradient(at 50% 70%, #c4f2e5, rgba(255, 255, 255, 0) 30%),
                radial-gradient(at 70% 0%, #d3ccf0, rgba(255, 255, 255, 0) 20%),
                linear-gradient(75deg,
                    #90f1f1 5%,
                    rgba(255, 255, 255, 0),
                    #aad1f0,
                    rgba(255, 255, 255, 0),
                    #e9d0ed,
                    rgba(255, 255, 255, 0),
                    #d3ccf0,
                    rgba(255, 255, 255, 0),
                    #c4f2e5 90%),
                radial-gradient(at 30% 50%, #90f1f1, rgba(255, 255, 255, 0) 30%),
                radial-gradient(at 30% 50%, #9cb9fc, rgba(255, 255, 255, 0) 30%),
                radial-gradient(at 100% 50%, #90f1f1, #c2dcf2, rgba(255, 255, 255, 0) 50%),
                linear-gradient(115deg,
                    #90f1f1 5%,
                    #aad1f0 10%,
                    #d3ccf0,
                    #e9d0ed 20%,
                    #aad1f0,
                    #aad1f0 30%,
                    #d3ccf0,
                    #c2dcf2 40%,
                    #90f1f1,
                    #aad1f0 70%);
        }

    .noise {
        position: absolute;
        top: -25px;
        bottom: -20px;
        left: 0;
        right: 0;
        opacity: 0.07;
        mask-image: linear-gradient(transparent 5%, white 30%, white 70%, transparent 95%);
        filter: grayscale(1);
        pointer-events: none;
        z-index: 1;
    }
</style>