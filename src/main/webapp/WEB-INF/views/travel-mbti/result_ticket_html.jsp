<!-- 영수증.html 완벽 복사본 HTML 구조 -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="output">
    <div class="wrap-colors-1">
        <div class="bg-colors"></div>
    </div>
    <div class="wrap-colors-2">
        <div class="bg-colors"></div>
    </div>
    <div class="cover"></div>
</div>

<div class="area">
    <div class="area-wrapper">
        <div class="ticket-mask">
            <div class="ticket">
                <div class="ticket-flip-container">
                    <div class="float">
                        <div class="front">
                            <div class="ticket-body">
                                <div class="reflex"></div>
                                <svg class="icon-cube" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <path style="--i: 1" class="path-center" d="M12 12.75L14.25 11.437M12 12.75L9.75 11.437M12 12.75V15" stroke="black" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"></path>
                                    <path style="--i: 2" class="path-t" d="M9.75 4.562 L12 3.25 L14.25 4.563" stroke="black" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"></path>
                                    <path style="--i: 3" class="path-tr" d="M21 7.5L18.75 6.187M21 7.5V9.75M21 7.5L18.75 8.813" stroke="black" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"></path>
                                    <path style="--i: 4" class="path-br" d="M21 14.25V16.5L18.75 17.813" stroke="black" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"></path>
                                    <path style="--i: 5" class="path-b" d="M12 21.75L14.25 20.437M12 21.75V19.5M12 21.75L9.75 20.437" stroke="black" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"></path>
                                    <path style="--i: 6" class="path-bl" d="M5.25 17.813L3 16.5V14.25" stroke="black" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"></path>
                                    <path style="--i: 7" class="path-tl" d="M3 7.5L5.25 6.187M3 7.5L5.25 8.813M3 7.5V9.75" stroke="black" stroke-width="1" stroke-linecap="round" stroke-linejoin="round"></path>
                                </svg>
                                <header>
                                    <div class="ticket-name">
                                        <div>
                                            <span style="--i: 1">여</span>
                                            <span style="--i: 2">행</span>
                                            <span style="--i: 3">용</span>
                                        </div>
                                        <div>
                                            <span class="bold" style="--i: 4">M</span>
                                            <span class="bold" style="--i: 5">B</span>
                                            <span class="bold" style="--i: 6">T</span>
                                            <span class="bold" style="--i: 7">I</span>
                                        </div>
                                    </div>
                                    <div class="barcode"></div>
                                </header>
                                <div class="contents">
                                    <div class="event">
                                        <div>
                                            <span class="bold">${mbtiType}</span>
                                        </div>
                                        <div>${result.typeName}</div>
                                    </div>
                                    <div class="number">#001</div>
                                    <img src="${pageContext.request.contextPath}/resources/images/mjc_qr.png" class="mjc-logo" alt="MJC QR">
                                </div>
                            </div>
                        </div>

                        <div class="back">
                            <div class="ticket-body">
                                <div class="reflex"></div>
                                <header>
                                    <div class="ticket-name">
                                        <div>
                                            <span style="--i: 1">당</span>
                                            <span style="--i: 2">신</span>
                                            <span style="--i: 3">의</span>
                                        </div>
                                        <b>
                                            <span class="bold" style="--i: 4">스</span>
                                            <span class="bold" style="--i: 5">타</span>
                                            <span class="bold" style="--i: 6">일</span>
                                        </b>
                                    </div>
                                    <time>
                                        <%
                                            java.time.LocalDate now = java.time.LocalDate.now();
                                            String day = String.format("%02d", now.getDayOfMonth());
                                            String month = String.format("%02d", now.getMonthValue());
                                            String year = String.valueOf(now.getYear());
                                        %>
                                        <span style="--i: 8" class="bold"><%= day.charAt(0) %></span>
                                        <span style="--i: 9" class="bold"><%= day.charAt(1) %></span>
                                        <span style="--i: 10" class="slash">/</span>
                                        <span style="--i: 11"><%= month.charAt(0) %></span>
                                        <span style="--i: 12"><%= month.charAt(1) %></span>
                                        <span style="--i: 13" class="slash">/</span>
                                        <span style="--i: 14"><%= year.charAt(0) %></span>
                                        <span style="--i: 15"><%= year.charAt(1) %></span>
                                        <span style="--i: 16"><%= year.charAt(2) %></span>
                                        <span style="--i: 17"><%= year.charAt(3) %></span>
                                    </time>
                                </header>
                                <div class="contents" style="padding: 15px;">
                                    <div style="font-size: 1.1rem; line-height: 1.6; text-align: left;">
                                        ${result.typeDescription}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="noise">
    <svg height="100%" width="100%">
        <defs>
            <pattern height="500" width="500" patternUnits="userSpaceOnUse" id="noise-pattern">
                <filter y="0" x="0" id="noise">
                    <feTurbulence stitchTiles="stitch" numOctaves="3" baseFrequency="0.65" type="fractalNoise"></feTurbulence>
                    <feBlend mode="screen"></feBlend>
                </filter>
                <rect filter="url(#noise)" height="500" width="500"></rect>
            </pattern>
        </defs>
        <rect fill="url(#noise-pattern)" height="100%" width="100%"></rect>
    </svg>
</div>