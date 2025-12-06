<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- 플로팅 액션 버튼 스타일 -->
<style>
.fab-container {
    position: fixed;
    bottom: 30px;
    right: 30px;
    z-index: 9999;
}

.fab-main {
    width: 60px;
    height: 60px;
    border-radius: 50%;
    background: linear-gradient(135deg, #667eea, #764ba2);
    border: none;
    cursor: pointer;
    box-shadow: 0 4px 20px rgba(102, 126, 234, 0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
    position: relative;
}

.fab-main:hover {
    transform: scale(1.1) rotate(90deg);
    box-shadow: 0 6px 30px rgba(102, 126, 234, 0.6);
}

.fab-main.active {
    transform: rotate(135deg);
    background: linear-gradient(135deg, #ff6b6b, #ffd93d);
}

.fab-icon {
    width: 28px;
    height: 28px;
    fill: white;
}

.fab-menu {
    position: absolute;
    bottom: 80px;
    right: 0;
    display: flex;
    flex-direction: column;
    gap: 15px;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s cubic-bezier(0.68, -0.55, 0.265, 1.55);
}

.fab-menu.active {
    opacity: 1;
    visibility: visible;
}

.fab-item {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    background: white;
    border: 2px solid transparent;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
    position: relative;
    box-shadow: 0 3px 15px rgba(0, 0, 0, 0.1);
    transform: scale(0);
}

.fab-menu.active .fab-item {
    transform: scale(1);
}

.fab-menu.active .fab-item:nth-child(1) { transition-delay: 0.05s; }
.fab-menu.active .fab-item:nth-child(2) { transition-delay: 0.1s; }
.fab-menu.active .fab-item:nth-child(3) { transition-delay: 0.15s; }
.fab-menu.active .fab-item:nth-child(4) { transition-delay: 0.2s; }
.fab-menu.active .fab-item:nth-child(5) { transition-delay: 0.25s; }

.fab-item:hover {
    transform: scale(1.15);
    box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
}

.fab-item.planner {
    background: linear-gradient(135deg, #667eea, #764ba2);
}

.fab-item.playlist {
    background: linear-gradient(135deg, #ff6b6b, #ffd93d);
}

.fab-item.map {
    background: linear-gradient(135deg, #4ecdc4, #44a08d);
}

.fab-item.packing {
    background: linear-gradient(135deg, #fa709a, #fee140);
}

.fab-item.mbti {
    background: linear-gradient(135deg, #a8e063, #56ab2f);
}

.fab-item-icon {
    width: 24px;
    height: 24px;
    fill: white;
}

.fab-tooltip {
    position: absolute;
    right: 60px;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(0, 0, 0, 0.9);
    color: white;
    padding: 8px 15px;
    border-radius: 8px;
    font-size: 14px;
    white-space: nowrap;
    opacity: 0;
    visibility: hidden;
    transition: all 0.3s ease;
    pointer-events: none;
}

.fab-item:hover .fab-tooltip {
    opacity: 1;
    visibility: visible;
    right: 70px;
}

/* 모달 팝업 스타일 */
.ai-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.7);
    backdrop-filter: blur(5px);
    z-index: 10000;
    animation: fadeIn 0.3s ease;
}

.ai-modal.active {
    display: flex;
    align-items: center;
    justify-content: center;
}

.ai-modal-content {
    background: white;
    border-radius: 20px;
    width: 90%;
    max-width: 900px;
    height: 85vh;
    max-height: 700px;
    overflow: hidden;
    position: relative;
    animation: slideUp 0.4s ease;
    display: flex;
    flex-direction: column;
}

.ai-modal-header {
    padding: 20px 25px;
    border-bottom: 1px solid #eee;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
}

.ai-modal-title {
    font-size: 1.3rem;
    font-weight: 600;
    color: #2d3748;
    display: flex;
    align-items: center;
    gap: 10px;
}

.ai-modal-close {
    width: 35px;
    height: 35px;
    border-radius: 50%;
    border: none;
    background: transparent;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.3s ease;
}

.ai-modal-close:hover {
    background: rgba(0, 0, 0, 0.05);
    transform: rotate(90deg);
}

.ai-modal-body {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes slideUp {
    from {
        transform: translateY(30px);
        opacity: 0;
    }
    to {
        transform: translateY(0);
        opacity: 1;
    }
}

/* 반응형 디자인 */
@media (max-width: 768px) {
    .fab-container {
        bottom: 20px;
        right: 20px;
    }

    .ai-modal-content {
        width: 95%;
        height: 90vh;
        border-radius: 15px;
    }
}
</style>

<!-- 플로팅 액션 버튼 HTML -->
<div class="fab-container">
    <!-- 메인 FAB 버튼 -->
    <button class="fab-main" id="fabMain" aria-label="AI 기능 메뉴">
        <svg class="fab-icon" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-2-13h4v4h4v4h-4v4h-4v-4H6v-4h4V7z"/>
        </svg>
    </button>

    <!-- 서브 메뉴 -->
    <div class="fab-menu" id="fabMenu">
        <!-- AI 여행 플래너 -->
        <button class="fab-item planner" data-action="planner" aria-label="AI 여행 플래너">
            <svg class="fab-item-icon" viewBox="0 0 24 24">
                <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1s-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
            </svg>
            <span class="fab-tooltip">AI 여행 플래너</span>
        </button>

        <!-- 여행 플레이리스트 -->
        <button class="fab-item playlist" data-action="playlist" aria-label="여행 플레이리스트">
            <svg class="fab-item-icon" viewBox="0 0 24 24">
                <path d="M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z"/>
            </svg>
            <span class="fab-tooltip">여행 플레이리스트</span>
        </button>

        <!-- AI 지도 -->
        <button class="fab-item map" data-action="map" aria-label="AI 지도">
            <svg class="fab-item-icon" viewBox="0 0 24 24">
                <path d="M20.5 3l-.16.03L15 5.1 9 3 3.36 4.9c-.21.07-.36.25-.36.48V20.5c0 .28.22.5.5.5l.16-.03L9 18.9l6 2.1 5.64-1.9c.21-.07.36-.25.36-.48V3.5c0-.28-.22-.5-.5-.5zM15 19l-6-2.11V5l6 2.11V19z"/>
            </svg>
            <span class="fab-tooltip">AI 지도</span>
        </button>

        <!-- 패킹 어시스턴트 -->
        <button class="fab-item packing" data-action="packing" aria-label="패킹 어시스턴트">
            <svg class="fab-item-icon" viewBox="0 0 24 24">
                <path d="M17 6h-2V3c0-.55-.45-1-1-1h-4c-.55 0-1 .45-1 1v3H7c-1.1 0-2 .9-2 2v11c0 1.1.9 2 2 2 0 .55.45 1 1 1s1-.45 1-1h6c0 .55.45 1 1 1s1-.45 1-1c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2zM10 3h4v3h-4V3zm7 16H7V8h10v11z"/>
            </svg>
            <span class="fab-tooltip">패킹 어시스턴트</span>
        </button>

        <!-- MBTI 매칭 -->
        <button class="fab-item mbti" data-action="mbti" aria-label="MBTI 매칭">
            <svg class="fab-item-icon" viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            <span class="fab-tooltip">MBTI 매칭</span>
        </button>
    </div>
</div>

<!-- AI 모달 컨테이너 -->
<div class="ai-modal" id="aiModal">
    <div class="ai-modal-content">
        <div class="ai-modal-header">
            <h2 class="ai-modal-title" id="modalTitle">
                <span id="modalIcon"></span>
                <span id="modalTitleText"></span>
            </h2>
            <button class="ai-modal-close" id="modalClose">
                <svg width="20" height="20" viewBox="0 0 24 24">
                    <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                </svg>
            </button>
        </div>
        <div class="ai-modal-body" id="modalBody">
            <!-- 동적으로 콘텐츠가 로드됩니다 -->
        </div>
    </div>
</div>

<!-- 플로팅 액션 버튼 JavaScript -->
<script>
(function() {
    const fabMain = document.getElementById('fabMain');
    const fabMenu = document.getElementById('fabMenu');
    const aiModal = document.getElementById('aiModal');
    const modalClose = document.getElementById('modalClose');
    const modalTitle = document.getElementById('modalTitleText');
    const modalBody = document.getElementById('modalBody');
    const fabItems = document.querySelectorAll('.fab-item');

    // 메인 FAB 버튼 클릭 이벤트
    fabMain.addEventListener('click', function() {
        fabMain.classList.toggle('active');
        fabMenu.classList.toggle('active');
    });

    // 서브 메뉴 아이템 클릭 이벤트
    fabItems.forEach(item => {
        item.addEventListener('click', function() {
            const action = this.getAttribute('data-action');
            openAiModal(action);

            // 메뉴 닫기
            fabMain.classList.remove('active');
            fabMenu.classList.remove('active');
        });
    });

    // 모달 닫기
    modalClose.addEventListener('click', closeModal);
    aiModal.addEventListener('click', function(e) {
        if (e.target === aiModal) {
            closeModal();
        }
    });

    // ESC 키로 모달 닫기
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && aiModal.classList.contains('active')) {
            closeModal();
        }
    });

    function openAiModal(action) {
        let content = '';
        let title = '';

        switch(action) {
            case 'planner':
                title = 'AI 여행 플래너';
                content = `
                    <iframe src="${pageContext.request.contextPath}/ai/chat"
                            style="width: 100%; height: 100%; border: none;">
                    </iframe>
                `;
                break;

            case 'playlist':
                title = '여행 플레이리스트';
                content = `
                    <div class="playlist-container" style="padding: 20px;">
                        <form id="playlistForm">
                            <div class="form-group">
                                <label>음악 국가 선택</label>
                                <select name="musicOrigin" class="form-control" required>
                                    <option value="">선택하세요</option>
                                    <option value="KOREA">한국</option>
                                    <option value="USA">미국</option>
                                    <option value="JAPAN">일본</option>
                                    <option value="FRANCE">프랑스</option>
                                    <option value="SPAIN">스페인</option>
                                    <option value="BRAZIL">브라질</option>
                                    <option value="INDIA">인도</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>여행지 유형</label>
                                <select name="destinationType" class="form-control" required>
                                    <option value="">선택하세요</option>
                                    <option value="beach">해변</option>
                                    <option value="mountain">산</option>
                                    <option value="city">도시</option>
                                    <option value="countryside">시골</option>
                                    <option value="desert">사막</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>음악 장르</label>
                                <select name="musicGenre" class="form-control" required>
                                    <option value="">선택하세요</option>
                                    <option value="pop">팝</option>
                                    <option value="rock">록</option>
                                    <option value="jazz">재즈</option>
                                    <option value="classical">클래식</option>
                                    <option value="hiphop">힙합</option>
                                    <option value="indie">인디</option>
                                    <option value="edm">EDM</option>
                                    <option value="folk">포크</option>
                                </select>
                            </div>
                            <button type="submit" class="btn-primary" style="width: 100%; padding: 12px; margin-top: 20px;">
                                플레이리스트 생성
                            </button>
                        </form>
                        <div id="playlistResult" style="margin-top: 30px;"></div>
                    </div>
                `;
                break;

            case 'map':
                title = 'AI 지도';
                content = `
                    <iframe src="${pageContext.request.contextPath}/ai/map"
                            style="width: 100%; height: 100%; border: none;">
                    </iframe>
                `;
                break;

            case 'packing':
                title = '패킹 어시스턴트';
                content = `
                    <div class="packing-container" style="padding: 20px;">
                        <form id="packingForm">
                            <div class="form-group">
                                <label>여행지</label>
                                <input type="text" name="destination" class="form-control"
                                       placeholder="예: 제주도, 도쿄, 파리" required>
                            </div>
                            <div class="form-group">
                                <label>여행 기간</label>
                                <input type="number" name="duration" class="form-control"
                                       placeholder="일 수" min="1" max="30" required>
                            </div>
                            <div class="form-group">
                                <label>계절</label>
                                <select name="season" class="form-control" required>
                                    <option value="">선택하세요</option>
                                    <option value="spring">봄</option>
                                    <option value="summer">여름</option>
                                    <option value="autumn">가을</option>
                                    <option value="winter">겨울</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>여행 목적</label>
                                <select name="purpose" class="form-control" required>
                                    <option value="">선택하세요</option>
                                    <option value="leisure">휴양</option>
                                    <option value="adventure">모험</option>
                                    <option value="business">비즈니스</option>
                                    <option value="culture">문화탐방</option>
                                </select>
                            </div>
                            <button type="submit" class="btn-primary" style="width: 100%; padding: 12px; margin-top: 20px;">
                                패킹 리스트 생성
                            </button>
                        </form>
                        <div id="packingResult" style="margin-top: 30px;"></div>
                    </div>
                `;
                break;

            case 'mbti':
                title = 'MBTI 여행 스타일 테스트';
                content = `
                    <iframe src="${pageContext.request.contextPath}/travel-mbti/test"
                            style="width: 100%; height: 100%; border: none;">
                    </iframe>
                `;
                break;
        }

        modalTitle.textContent = title;
        modalBody.innerHTML = content;
        aiModal.classList.add('active');

        // 폼 이벤트 바인딩
        if (action === 'playlist') {
            bindPlaylistForm();
        } else if (action === 'packing') {
            bindPackingForm();
        }
    }

    function closeModal() {
        aiModal.classList.remove('active');
        modalBody.innerHTML = '';
    }

    // 플레이리스트 폼 처리
    function bindPlaylistForm() {
        const form = document.getElementById('playlistForm');
        if (form) {
            form.addEventListener('submit', async function(e) {
                e.preventDefault();

                const formData = new FormData(form);
                const data = Object.fromEntries(formData);

                const resultDiv = document.getElementById('playlistResult');
                resultDiv.innerHTML = '<p>플레이리스트 생성 중...</p>';

                try {
                    const response = await fetch('${pageContext.request.contextPath}/api/playlist/generate', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(data)
                    });

                    const result = await response.json();
                    displayPlaylistResult(result);
                } catch (error) {
                    resultDiv.innerHTML = '<p style="color: red;">오류가 발생했습니다.</p>';
                }
            });
        }
    }

    // 패킹 폼 처리
    function bindPackingForm() {
        const form = document.getElementById('packingForm');
        if (form) {
            form.addEventListener('submit', async function(e) {
                e.preventDefault();

                const formData = new FormData(form);
                const data = Object.fromEntries(formData);

                const resultDiv = document.getElementById('packingResult');
                resultDiv.innerHTML = '<p>패킹 리스트 생성 중...</p>';

                try {
                    const response = await fetch('${pageContext.request.contextPath}/api/packing/recommend', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify(data)
                    });

                    const result = await response.json();
                    displayPackingResult(result);
                } catch (error) {
                    resultDiv.innerHTML = '<p style="color: red;">오류가 발생했습니다.</p>';
                }
            });
        }
    }

    function displayPlaylistResult(result) {
        const resultDiv = document.getElementById('playlistResult');
        if (result.songs && result.songs.length > 0) {
            let html = '<h3>추천 플레이리스트</h3><ul>';
            result.songs.forEach(song => {
                html += `<li>${song.title} - ${song.artist}</li>`;
            });
            html += '</ul>';
            resultDiv.innerHTML = html;
        }
    }

    function displayPackingResult(result) {
        const resultDiv = document.getElementById('packingResult');
        if (result.items && result.items.length > 0) {
            let html = '<h3>패킹 체크리스트</h3><ul>';
            result.items.forEach(item => {
                html += `<li>${item.name} (${item.quantity})</li>`;
            });
            html += '</ul>';
            resultDiv.innerHTML = html;
        }
    }
})();
</script>