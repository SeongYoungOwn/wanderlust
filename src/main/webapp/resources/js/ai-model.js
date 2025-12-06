// AI 모델 페이지 JavaScript 코드

// 현재 선택된 AI 모델 ID
let currentModelId = null;

// 리뷰 페이징 변수
let currentPage = 1;
let hasNextPage = false;
let hasPrevPage = false;

// AI 모델 ID를 한국어 이름으로 매핑하는 함수
function getModelKoreanName(modelId) {
    const modelNames = {
        'mbti-matching': 'MBTI 매칭 모델',
        'claude-3-5-sonnet': '여행 플레이리스트 모델', 
        'claude-3-haiku': 'AI 지도 모델',
        'gpt-4o': '패킹 어시스턴트 모델',
        'gpt-4o-mini': '소셜 트렌드 분석 모델',
        'gemini-pro': 'AI 채팅 모델'
    };
    return modelNames[modelId] || modelId;
}

// 모델 선택 함수 (토글 기능 추가)
function selectModel(modelId) {
    console.log('모델 선택:', modelId);
    
    // 이미 선택된 모델을 다시 클릭하면 선택 해제
    if (currentModelId === modelId) {
        currentModelId = null;
        
        // 모든 모델 카드의 선택 상태 제거
        document.querySelectorAll('.ai-model-card').forEach(card => {
            card.classList.remove('selected');
        });
        
        // 버튼 영역 숨기기
        const buttonArea = document.getElementById('selectedModelActions');
        if (buttonArea) {
            buttonArea.style.display = 'none';
        }
        return;
    }
    
    currentModelId = modelId;
    
    // 이전 선택 상태 제거
    document.querySelectorAll('.ai-model-card').forEach(card => {
        card.classList.remove('selected');
    });
    
    // 새로운 선택 상태 추가
    const selectedCard = document.querySelector(`[onclick="selectModel('${modelId}')"]`);
    if (selectedCard) {
        selectedCard.classList.add('selected');
    }
    
    // 선택된 모델에 따른 동적 버튼 영역 표시
    showModelActions(modelId);
}

// 전역 함수로 등록
window.selectModel = selectModel;

function showModelActions(modelId) {
    const buttonArea = document.getElementById('selectedModelActions');
    if (!buttonArea) return;
    
    const modelName = getModelKoreanName(modelId);
    
    // 모델별 특화 버튼들
    let actionsHtml = '';
    
    switch(modelId) {
        case 'mbti-matching':
            actionsHtml = `
                <div class="model-action-header">
                    <h4>🎯 ${modelName} - 사용 가능한 기능</h4>
                    <p>개인 성향을 분석하여 최적의 여행 동반자를 찾아드립니다.</p>
                </div>
                <div class="action-buttons">
                    <button class="action-btn primary" onclick="startMbtiMatching()">
                        <i class="fas fa-users"></i> MBTI 매칭 시작
                    </button>
                    <button class="action-btn secondary" onclick="viewMbtiHistory()">
                        <i class="fas fa-history"></i> 매칭 기록 보기
                    </button>
                </div>
            `;
            break;
            
        case 'gpt-4o-mini':
            actionsHtml = `
                <div class="model-action-header">
                    <h4>📊 ${modelName} - 사용 가능한 기능</h4>
                    <p>실시간 소셜 미디어 데이터를 분석하여 여행 트렌드를 예측합니다.</p>
                </div>
                <div class="action-buttons">
                    <button class="action-btn primary" onclick="alert('소셜 트렌드 분석 기능은 개발 중입니다.')">
                        <i class="fas fa-chart-line"></i> 트렌드 분석 시작
                    </button>
                    <button class="action-btn secondary" onclick="alert('분석 기록 기능은 개발 중입니다.')">
                        <i class="fas fa-history"></i> 분석 기록 보기
                    </button>
                </div>
            `;
            break;
            
        case 'claude-3-5-sonnet':
            actionsHtml = `
                <div class="model-action-header">
                    <h4>🎵 ${modelName} - 사용 가능한 기능</h4>
                    <p>여행지의 분위기에 맞는 완벽한 플레이리스트를 생성합니다.</p>
                </div>
                <div class="action-buttons">
                    <button class="action-btn primary" onclick="createPlaylist()">
                        <i class="fas fa-music"></i> 플레이리스트 생성
                    </button>
                    <button class="action-btn secondary" onclick="browseDestinations()">
                        <i class="fas fa-map-marked-alt"></i> 여행지 둘러보기
                    </button>
                </div>
            `;
            break;
            
        case 'claude-3-haiku':
            actionsHtml = `
                <div class="model-action-header">
                    <h4>🗺️ ${modelName} - 사용 가능한 기능</h4>
                    <p>개인 취향을 고려한 최적 경로와 숨겨진 명소를 추천합니다.</p>
                </div>
                <div class="action-buttons">
                    <button class="action-btn primary" onclick="findOptimalRoute()">
                        <i class="fas fa-route"></i> 최적 경로 찾기
                    </button>
                    <button class="action-btn secondary" onclick="discoverHiddenGems()">
                        <i class="fas fa-gem"></i> 숨겨진 명소 발견
                    </button>
                </div>
            `;
            break;
            
        case 'gpt-4o':
            actionsHtml = `
                <div class="model-action-header">
                    <h4>🎒 ${modelName} - 사용 가능한 기능</h4>
                    <p>여행 일정과 기후를 고려한 스마트 패킹 리스트를 제공합니다.</p>
                </div>
                <div class="action-buttons">
                    <button class="action-btn primary" onclick="createPackingList()">
                        <i class="fas fa-suitcase"></i> 패킹 리스트 생성
                    </button>
                    <button class="action-btn secondary" onclick="checkWeatherForecast()">
                        <i class="fas fa-cloud-sun"></i> 날씨 예보 확인
                    </button>
                </div>
            `;
            break;
            
        case 'gemini-pro':
            actionsHtml = `
                <div class="model-action-header">
                    <h4>💬 ${modelName} - 사용 가능한 기능</h4>
                    <p>여행 관련 모든 질문에 대한 개인화된 답변을 제공합니다.</p>
                </div>
                <div class="action-buttons">
                    <button class="action-btn primary" onclick="startAiChat()">
                        <i class="fas fa-comment-dots"></i> AI 채팅 시작
                    </button>
                    <button class="action-btn secondary" onclick="viewChatHistory()">
                        <i class="fas fa-history"></i> 채팅 기록 보기
                    </button>
                </div>
            `;
            break;
    }
    
    buttonArea.innerHTML = actionsHtml;
    buttonArea.style.display = 'block';
    
    // 부드러운 애니메이션으로 스크롤
    setTimeout(() => {
        buttonArea.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 100);
}

// 전역 함수로 등록
window.showModelActions = showModelActions;

// 8:00 PM 상태 - 소셜 트렌드 분석은 아직 개발 중

// 나머지 함수들은 현재 JSP 파일에서 추출하여 추가해야 합니다...
// (파일 크기 제한으로 인해 일부만 포함)

// 패킹 어시스턴트 관련 변수
let currentConversationId = null;
let packingStepCounter = 0;

// 패킹 어시스턴트 메시지 전송
function sendPackingMessage() {
    const messageInput = document.getElementById('packingMessageInput');
    const message = messageInput.value.trim();
    
    if (!message) {
        alert('메시지를 입력해주세요.');
        return;
    }
    
    // 사용자 메시지 표시
    addChatMessage('user', message);
    messageInput.value = '';
    
    // 로딩 표시
    showPackingLoading();
    
    // 대화 ID가 없으면 생성
    if (!currentConversationId) {
        currentConversationId = 'conv_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    
    // API 호출
    fetch('/api/packing/chat', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            message: message,
            conversationId: currentConversationId
        })
    })
    .then(response => response.json())
    .then(data => {
        hidePackingLoading();
        
        if (data.success) {
            // AI 응답 표시
            addChatMessage('ai', data.aiMessage);
            
            // 대화가 완료되면 패킹 리스트 표시
            if (data.conversationComplete && data.packingList) {
                displayPackingList(data.packingList);
            }
        } else {
            addChatMessage('ai', '죄송합니다. 오류가 발생했습니다: ' + data.message);
        }
    })
    .catch(error => {
        hidePackingLoading();
        console.error('패킹 채팅 오류:', error);
        addChatMessage('ai', '죄송합니다. 오류가 발생했습니다: ' + error.message);
    });
}

// 채팅 메시지 추가
function addChatMessage(sender, message) {
    const chatMessages = document.querySelector('.packing-chat-messages');
    if (!chatMessages) return;
    
    const messageDiv = document.createElement('div');
    messageDiv.className = `chat-message ${sender}`;
    
    if (sender === 'user') {
        messageDiv.innerHTML = `
            <div class="message-content user-message">
                <p>${message}</p>
            </div>
        `;
    } else {
        messageDiv.innerHTML = `
            <div class="message-content ai-message">
                <div class="ai-avatar">🤖</div>
                <div class="ai-text">
                    <p>${message.replace(/\n/g, '<br>')}</p>
                </div>
            </div>
        `;
    }
    
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
    
    // 단계 카운터 업데이트
    updatePackingStep();
}

// 패킹 단계 업데이트
function updatePackingStep() {
    packingStepCounter++;
    const stepIndicator = document.querySelector('.ai-step-indicator');
    if (stepIndicator) {
        stepIndicator.textContent = `${Math.min(packingStepCounter, 3)}/3 단계`;
    }
}

// 패킹 로딩 표시
function showPackingLoading() {
    const chatMessages = document.querySelector('.packing-chat-messages');
    if (!chatMessages) return;
    
    const loadingDiv = document.createElement('div');
    loadingDiv.className = 'chat-message ai loading-message';
    loadingDiv.id = 'packingLoadingMessage';
    loadingDiv.innerHTML = `
        <div class="message-content ai-message">
            <div class="ai-avatar">🤖</div>
            <div class="ai-text">
                <div class="typing-indicator">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        </div>
    `;
    
    chatMessages.appendChild(loadingDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

// 패킹 로딩 숨기기
function hidePackingLoading() {
    const loadingMessage = document.getElementById('packingLoadingMessage');
    if (loadingMessage) {
        loadingMessage.remove();
    }
}

// 패킹 리스트 표시
function displayPackingList(packingList) {
    const packingResultsDiv = document.getElementById('packingResults');
    const packingCategoriesDiv = document.getElementById('packingCategories');
    
    if (!packingResultsDiv || !packingCategoriesDiv) return;
    
    // 카테고리별 패킹 리스트 생성
    packingCategoriesDiv.innerHTML = '';
    let totalItems = 0;
    
    for (const [category, items] of Object.entries(packingList)) {
        if (items && items.length > 0) {
            const categoryDiv = document.createElement('div');
            categoryDiv.className = 'packing-category';
            
            const itemsHtml = items.map(item => {
                totalItems++;
                return `
                    <div class="packing-item">
                        <label class="item-checkbox">
                            <input type="checkbox" onchange="updateItemChecked('${item.itemName}', this.checked)">
                            <span class="checkmark"></span>
                        </label>
                        <div class="item-info">
                            <span class="item-name ${item.necessityLevel === '필수' ? 'essential' : ''}">${item.itemName}</span>
                            <span class="item-description">${item.description}</span>
                            <span class="necessity-badge ${item.necessityLevel}">${item.necessityLevel}</span>
                        </div>
                    </div>
                `;
            }).join('');
            
            categoryDiv.innerHTML = `
                <div class="category-header">
                    <h4>${category}</h4>
                    <span class="item-count">${items.length}개 아이템</span>
                </div>
                <div class="category-items">
                    ${itemsHtml}
                </div>
            `;
            
            packingCategoriesDiv.appendChild(categoryDiv);
        }
    }
    
    // 통계 업데이트
    updatePackingStats(totalItems, 0);
    
    // 결과 표시
    packingResultsDiv.style.display = 'block';
}

// 아이템 체크 상태 업데이트
function updateItemChecked(itemName, isChecked) {
    if (!currentConversationId) return;
    
    fetch('/api/packing/checklist', {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            conversationId: currentConversationId,
            itemName: itemName,
            isChecked: isChecked
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updatePackingStatsFromDOM();
        }
    })
    .catch(error => {
        console.error('체크리스트 업데이트 오류:', error);
    });
}

// DOM에서 통계 업데이트
function updatePackingStatsFromDOM() {
    const checkboxes = document.querySelectorAll('.packing-item input[type="checkbox"]');
    const totalItems = checkboxes.length;
    const checkedItems = document.querySelectorAll('.packing-item input[type="checkbox"]:checked').length;
    
    updatePackingStats(totalItems, checkedItems);
}

// 패킹 통계 업데이트
function updatePackingStats(totalItems, checkedItems) {
    const totalItemsSpan = document.getElementById('totalItems');
    const checkedItemsSpan = document.getElementById('checkedItems');
    const progressPercentSpan = document.getElementById('progressPercent');
    
    if (totalItemsSpan) totalItemsSpan.textContent = totalItems;
    if (checkedItemsSpan) checkedItemsSpan.textContent = checkedItems;
    if (progressPercentSpan) {
        const percent = totalItems > 0 ? Math.round((checkedItems / totalItems) * 100) : 0;
        progressPercentSpan.textContent = percent + '%';
    }
}

// PDF 내보내기
function exportPackingList() {
    if (!currentConversationId) {
        alert('내보낼 패킹 리스트가 없습니다.');
        return;
    }
    
    fetch(`/api/packing/export/${currentConversationId}`)
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // PDF 다운로드
            const link = document.createElement('a');
            link.href = data.downloadUrl;
            link.download = 'packing-list.pdf';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        } else {
            alert('PDF 생성 중 오류가 발생했습니다: ' + data.message);
        }
    })
    .catch(error => {
        console.error('PDF 내보내기 오류:', error);
        alert('PDF 생성 중 오류가 발생했습니다.');
    });
}

// 패킹 어시스턴트 다시 시작
function restartPacking() {
    // 대화 기록 초기화
    if (currentConversationId) {
        fetch(`/api/packing/conversation/${currentConversationId}`, {
            method: 'DELETE'
        });
    }
    
    // 변수 초기화
    currentConversationId = null;
    packingStepCounter = 0;
    
    // UI 초기화
    const chatMessages = document.querySelector('.packing-chat-messages');
    const packingResults = document.getElementById('packingResults');
    const stepIndicator = document.querySelector('.ai-step-indicator');
    
    if (chatMessages) {
        chatMessages.innerHTML = `
            <div class="chat-message ai">
                <div class="message-content ai-message">
                    <div class="ai-avatar">🤖</div>
                    <div class="ai-text">
                        <p>안녕하세요! 여행 패킹을 도와드릴게요. 🎒</p>
                        <p>어떤 여행을 계획하고 계신가요?</p>
                    </div>
                </div>
            </div>
        `;
    }
    
    if (packingResults) {
        packingResults.style.display = 'none';
    }
    
    if (stepIndicator) {
        stepIndicator.textContent = '0/3 단계';
    }
}

// 패킹 어시스턴트 모달 열기
function openPackingAssistant() {
    const modal = document.getElementById('packingAssistantModal');
    if (modal) {
        modal.style.display = 'block';
        restartPacking(); // 모달 열 때마다 초기화
    }
}

// 패킹 어시스턴트 모달 닫기
function closePackingAssistant() {
    const modal = document.getElementById('packingAssistantModal');
    if (modal) {
        modal.style.display = 'none';
    }
}

// Enter 키 처리
document.addEventListener('keydown', function(event) {
    if (event.key === 'Enter' && event.target.id === 'packingMessageInput') {
        event.preventDefault();
        sendPackingMessage();
    }
});

// 기본적인 이벤트 리스너 설정
document.addEventListener('DOMContentLoaded', function() {
    // 모달 외부 클릭 시 닫기
    window.addEventListener('click', function(event) {
        const modal = document.getElementById('socialTrendModal');
        if (event.target === modal) {
            if (modal.style.display === 'block') {
                closeSocialTrendModal();
            }
        }
        
        const packingModal = document.getElementById('packingAssistantModal');
        if (event.target === packingModal) {
            if (packingModal.style.display === 'block') {
                closePackingAssistant();
            }
        }
    });
});

// 여행 플레이리스트 생성 함수 (모달로 변경)
function createPlaylist() {
    console.log('플레이리스트 모달 열기 시작');
    
    // 먼저 window.openPlaylistModal이 있는지 확인
    if (typeof window.openPlaylistModal === 'function') {
        console.log('window.openPlaylistModal 함수 호출');
        window.openPlaylistModal();
    } else if (typeof openPlaylistModal === 'function') {
        console.log('openPlaylistModal 함수 호출');
        openPlaylistModal();
    } else {
        // 함수가 정의되지 않은 경우 직접 모달 열기
        console.log('플레이리스트 모달 함수 없음, 직접 열기');
        const modal = document.getElementById('playlistRecommendModal');
        if (modal) {
            modal.style.display = 'block';
            console.log('모달 표시 완료');
            
            // 초기화 함수도 직접 호출
            setTimeout(() => {
                if (typeof window.initializePlaylistModal === 'function') {
                    window.initializePlaylistModal();
                } else {
                    console.log('초기화 함수 없음');
                }
            }, 100);
        } else {
            console.error('플레이리스트 모달 요소를 찾을 수 없습니다');
        }
    }
}

// 전역 함수로 등록
window.createPlaylist = createPlaylist;

// 여행지 둘러보기 함수 (추후 구현)
function browseDestinations() {
    alert('여행지 둘러보기 기능은 준비 중입니다.');
}

// 패킹 리스트 생성 함수
function createPackingList() {
    openPackingAssistant();
}

// 다른 기능들 추가 (추후 구현)
function startMbtiMatching() {
    alert('MBTI 매칭 기능은 준비 중입니다.');
}

function viewMbtiHistory() {
    alert('매칭 기록 기능은 준비 중입니다.');
}

function findOptimalRoute() {
    alert('최적 경로 찾기 기능은 준비 중입니다.');
}

function discoverHiddenGems() {
    alert('숨겨진 명소 발견 기능은 준비 중입니다.');
}

function checkWeatherForecast() {
    alert('날씨 예보 확인 기능은 준비 중입니다.');
}

function startAiChat() {
    alert('AI 채팅 기능은 준비 중입니다.');
}

function viewChatHistory() {
    alert('채팅 기록 기능은 준비 중입니다.');
}

// 전역 함수로 등록
window.browseDestinations = browseDestinations;
window.createPackingList = createPackingList;
window.startMbtiMatching = startMbtiMatching;
window.viewMbtiHistory = viewMbtiHistory;
window.findOptimalRoute = findOptimalRoute;
window.discoverHiddenGems = discoverHiddenGems;
window.checkWeatherForecast = checkWeatherForecast;
window.startAiChat = startAiChat;
window.viewChatHistory = viewChatHistory;        // 플레이리스트 모달 변수
        let playlistCurrentStep = 1;
        const playlistTotalSteps = 5;
        const playlistSelections = {
            musicOrigin: '',
            destinationType: '',
            musicGenre: '',
            timeOfDay: '',
            travelStyle: ''
        };

        // 플레이리스트 모달 열기 (전역 함수로 등록)
        function openPlaylistModal() {
            console.log('플레이리스트 모달 열기');
            
            const modal = document.getElementById('playlistRecommendModal');
            if (!modal) {
                console.error('플레이리스트 모달을 찾을 수 없습니다');
                return;
            }
            
            modal.style.display = 'block';
            
            // 간단한 초기화
            setTimeout(() => {
                initializePlaylistModal();
            }, 100);
        }
        
        function initializePlaylistModal() {
            console.log('플레이리스트 모달 초기화');
            
            // 첫 번째 스텝 활성화
            showPlaylistStep(1);
            
            // 선택 버튼 이벤트 설정
            setupPlaylistButtons();
        }
        
        function showPlaylistStep(stepNumber) {
            console.log('스텝 표시:', stepNumber);
            
            // 모든 스텝 숨기기
            const allSteps = document.querySelectorAll('.playlist-step');
            allSteps.forEach(step => step.classList.remove('active'));
            
            // 현재 스텝 보이기
            const currentStep = document.getElementById(`playlistStep${stepNumber}`);
            if (currentStep) {
                currentStep.classList.add('active');
                console.log('스텝 활성화 성공:', stepNumber);
            } else {
                console.error('스텝 요소 없음:', stepNumber);
            }
            
            // 스텝 인디케이터 업데이트
            updateStepIndicator(stepNumber);
        }
        
        function updateStepIndicator(currentStep) {
            const stepDots = document.querySelectorAll('.step-indicator .step-dot');
            stepDots.forEach((dot, index) => {
                const stepNum = index + 1;
                dot.classList.remove('active', 'completed');
                
                if (stepNum === currentStep) {
                    dot.classList.add('active');
                } else if (stepNum < currentStep) {
                    dot.classList.add('completed');
                }
            });
        }
        
        function setupPlaylistButtons() {
            console.log('플레이리스트 버튼 설정');
            
            const choiceButtons = document.querySelectorAll('.playlist-choice-button');
            console.log('버튼 개수:', choiceButtons.length);
            
            choiceButtons.forEach(button => {
                button.onclick = function() {
                    handlePlaylistChoice(this);
                };
            });
        }
        
        function handlePlaylistChoice(button) {
            console.log('선택 처리:', button.dataset.value);
            
            const stepType = button.dataset.step;
            const value = button.dataset.value;
            
            // 같은 스텝의 다른 버튼들 선택 해제
            const stepContainer = button.closest('.playlist-step');
            stepContainer.querySelectorAll('.playlist-choice-button').forEach(btn => {
                btn.classList.remove('selected');
            });
            
            // 현재 버튼 선택
            button.classList.add('selected');
            
            // 선택값 저장
            playlistSelections[stepType] = value;
            console.log('저장완료:', stepType, '=', value);
            
            // 현재 스텝 번호 찾기
            const currentStepElement = button.closest('.playlist-step');
            const currentStepId = currentStepElement.id;
            const currentStepNumber = parseInt(currentStepId.replace('playlistStep', ''));
            
            console.log('현재 스텝:', currentStepNumber);
            
            // 다음 스텝으로 이동 또는 추천 요청
            if (currentStepNumber < 5) {
                setTimeout(() => {
                    showPlaylistStep(currentStepNumber + 1);
                }, 500);
            } else {
                setTimeout(() => {
                    requestPlaylistRecommendation();
                }, 500);
            }
        }
        
        function requestPlaylistRecommendation() {
            console.log('플레이리스트 추천 요청', playlistSelections);
            
            // 로딩 표시
            const container = document.getElementById('playlistSelectionContainer');
            container.innerHTML = `
                <div style="text-align: center; padding: 2rem;">
                    <div class="loading-spinner" style="width: 50px; height: 50px; border: 3px solid #f3f3f3; border-top: 3px solid #667eea; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 1rem;"></div>
                    <h3>AI가 당신만의 플레이리스트를 만들고 있습니다...</h3>
                    <p>잠시만 기다려주세요.</p>
                </div>
            `;
            
            // API 호출
            fetch('http://localhost:8083/playlist/recommend', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(playlistSelections)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displayPlaylistResults(data);
                } else {
                    alert('플레이리스트 추천에 실패했습니다: ' + data.message);
                }
            })
            .catch(error => {
                console.error('플레이리스트 추천 오류:', error);
                alert('서버 연결에 실패했습니다.');
            });
        }
        
        function displayPlaylistResults(data) {
            const container = document.getElementById('playlistSelectionContainer');
            const originText = data.musicOrigin === 'korean' ? '🇰🇷 한국 음악' : '🌍 외국 음악';
            
            let resultsHtml = `
                <div style="text-align: center; margin-bottom: 2rem;">
                    <h3>${originText} 플레이리스트</h3>
                    <p>총 ${data.recommendations.length}곡의 맞춤 추천</p>
                </div>
                <div style="display: grid; gap: 1rem;">
            `;
            
            data.recommendations.forEach(music => {
                resultsHtml += `
                    <div style="background: white; border-radius: 12px; padding: 1rem; box-shadow: 0 4px 12px rgba(0,0,0,0.1); border-left: 4px solid #667eea;">
                        <div style="display: flex; align-items: center; gap: 1rem;">
                            <div style="width: 30px; height: 30px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold;">${music.order}</div>
                            <div style="flex: 1;">
                                <div style="font-size: 1.1rem; font-weight: 600; color: #2d3748; margin-bottom: 0.25rem;">${music.songTitle}</div>
                                <div style="color: #667eea; font-weight: 500; margin-bottom: 0.5rem;">${music.artist}</div>
                                <div style="color: #4a5568; font-size: 0.9rem; font-style: italic;">${music.reason}</div>
                                <div style="background: rgba(102, 126, 234, 0.1); color: #667eea; padding: 0.25rem 0.5rem; border-radius: 12px; font-size: 0.8rem; display: inline-block; margin-top: 0.5rem;">${music.genre}</div>
                            </div>
                        </div>
                    </div>
                `;
            });
            
            resultsHtml += `
                </div>
                <div style="text-align: center; margin-top: 2rem;">
                    <button onclick="resetPlaylistModal()" style="background: #f7fafc; color: #4a5568; border: 1px solid #e2e8f0; padding: 0.75rem 1.5rem; border-radius: 8px; margin-right: 1rem; cursor: pointer;">
                        <i class="fas fa-redo"></i> 다시 추천받기
                    </button>
                    <button onclick="closePlaylistModal()" style="background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 8px; cursor: pointer;">
                        <i class="fas fa-check"></i> 완료
                    </button>
                </div>
            `;
            
            container.innerHTML = resultsHtml;
        }
        
        function resetPlaylistModal() {
            playlistCurrentStep = 1;
            playlistSelections = {
                musicOrigin: '',
                destinationType: '',
                musicGenre: '',
                timeOfDay: '',
                travelStyle: ''
            };
            
            // 모든 버튼 선택 해제
            const allButtons = document.querySelectorAll('.playlist-choice-button');
            allButtons.forEach(btn => btn.classList.remove('selected'));
            
            // 첫 번째 스텝으로 돌아가기
            showPlaylistStep(1);
        }

        // 플레이리스트 모달 닫기
        function closePlaylistModal() {
            const modal = document.getElementById('playlistRecommendModal');
            modal.style.display = 'none';
        }
        
        // createPlaylist 함수 정의 (ai-model.js 로드 문제 대비)
        function createPlaylist() {
            console.log('플레이리스트 생성 버튼 클릭됨');
            openPlaylistModal();
        }
        
        // 패킹 어시스턴트 함수들 (ai-model.js 로드 문제 대비)
        function createPackingList() {
            openPackingAssistant();
        }
        
        function startMbtiMatching() {
            alert('MBTI 매칭 기능은 준비 중입니다.');
        }
        
        function viewMbtiHistory() {
            alert('MBTI 매칭 기록 기능은 준비 중입니다.');
        }
        
        function findOptimalRoute() {
            alert('최적 경로 찾기 기능은 준비 중입니다.');
        }
        
        function discoverHiddenGems() {
            alert('숨겨진 명소 발견 기능은 준비 중입니다.');
        }
        
        function checkWeatherForecast() {
            alert('날씨 예보 확인 기능은 준비 중입니다.');
        }
        
        function startAiChat() {
            alert('AI 채팅 기능은 준비 중입니다.');
        }
        
        function viewChatHistory() {
            alert('채팅 기록 보기 기능은 준비 중입니다.');
        }
        
        function browseDestinations() {
            alert('여행지 둘러보기 기능은 준비 중입니다.');
        }
        
        // showModelActions 함수 정의 (ai-model.js 로드 문제 대비)
        function showModelActions(modelId) {
            const buttonArea = document.getElementById('selectedModelActions');
            if (!buttonArea) return;
            
            const modelName = getModelKoreanName(modelId);
            
            // 모델별 특화 버튼들
            let actionsHtml = '';
            
            switch(modelId) {
                case 'mbti-matching':
                    actionsHtml = `
                        <div class="model-action-header">
                            <h4>🎯 ${modelName} - 사용 가능한 기능</h4>
                            <p>개인 성향을 분석하여 최적의 여행 동반자를 찾아드립니다.</p>
                        </div>
                        <div class="action-buttons">
                            <button class="action-btn primary" onclick="startMbtiMatching()">
                                <i class="fas fa-users"></i> MBTI 매칭 시작
                            </button>
                            <button class="action-btn secondary" onclick="viewMbtiHistory()">
                                <i class="fas fa-history"></i> 매칭 기록 보기
                            </button>
                        </div>
                    `;
                    break;
                    
                case 'gpt-4o-mini':
                    actionsHtml = `
                        <div class="model-action-header">
                            <h4>📊 ${modelName} - 사용 가능한 기능</h4>
                            <p>실시간 소셜 미디어 데이터를 분석하여 여행 트렌드를 예측합니다.</p>
                        </div>
                        <div class="action-buttons">
                            <button class="action-btn primary" onclick="alert('소셜 트렌드 분석 기능은 개발 중입니다.')">
                                <i class="fas fa-chart-line"></i> 트렌드 분석 시작
                            </button>
                            <button class="action-btn secondary" onclick="alert('분석 기록 기능은 개발 중입니다.')">
                                <i class="fas fa-history"></i> 분석 기록 보기
                            </button>
                        </div>
                    `;
                    break;
                    
                case 'claude-3-5-sonnet':
                    actionsHtml = `
                        <div class="model-action-header">
                            <h4>🎵 ${modelName} - 사용 가능한 기능</h4>
                            <p>여행지의 분위기에 맞는 완벽한 플레이리스트를 생성합니다.</p>
                        </div>
                        <div class="action-buttons">
                            <button class="action-btn primary" onclick="createPlaylist()">
                                <i class="fas fa-music"></i> 플레이리스트 생성
                            </button>
                            <button class="action-btn secondary" onclick="browseDestinations()">
                                <i class="fas fa-map-marked-alt"></i> 여행지 둘러보기
                            </button>
                        </div>
                    `;
                    break;
                    
                case 'claude-3-haiku':
                    actionsHtml = `
                        <div class="model-action-header">
                            <h4>🗺️ ${modelName} - 사용 가능한 기능</h4>
                            <p>개인 취향을 고려한 최적 경로와 숨겨진 명소를 추천합니다.</p>
                        </div>
                        <div class="action-buttons">
                            <button class="action-btn primary" onclick="findOptimalRoute()">
                                <i class="fas fa-route"></i> 최적 경로 찾기
                            </button>
                            <button class="action-btn secondary" onclick="discoverHiddenGems()">
                                <i class="fas fa-gem"></i> 숨겨진 명소 발견
                            </button>
                        </div>
                    `;
                    break;
                    
                case 'gpt-4o':
                    actionsHtml = `
                        <div class="model-action-header">
                            <h4>🎒 ${modelName} - 사용 가능한 기능</h4>
                            <p>여행 일정과 기후를 고려한 스마트 패킹 리스트를 제공합니다.</p>
                        </div>
                        <div class="action-buttons">
                            <button class="action-btn primary" onclick="createPackingList()">
                                <i class="fas fa-suitcase"></i> 패킹 리스트 생성
                            </button>
                            <button class="action-btn secondary" onclick="checkWeatherForecast()">
                                <i class="fas fa-cloud-sun"></i> 날씨 예보 확인
                            </button>
                        </div>
                    `;
                    break;
                    
                case 'gemini-pro':
                    actionsHtml = `
                        <div class="model-action-header">
                            <h4>💬 ${modelName} - 사용 가능한 기능</h4>
                            <p>여행 관련 모든 질문에 대한 개인화된 답변을 제공합니다.</p>
                        </div>
                        <div class="action-buttons">
                            <button class="action-btn primary" onclick="startAiChat()">
                                <i class="fas fa-comment-dots"></i> AI 채팅 시작
                            </button>
                            <button class="action-btn secondary" onclick="viewChatHistory()">
                                <i class="fas fa-history"></i> 채팅 기록 보기
                            </button>
                        </div>
                    `;
                    break;
            }
            
            buttonArea.innerHTML = actionsHtml;
            buttonArea.style.display = 'block';
            
            // 부드러운 애니메이션으로 스크롤
            setTimeout(() => {
                buttonArea.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 100);
        }
        
        // 전역 함수로 등록
        window.openPlaylistModal = openPlaylistModal;
        window.closePlaylistModal = closePlaylistModal;
        window.initializePlaylistModal = initializePlaylistModal;
        window.createPlaylist = createPlaylist;

        // 플레이리스트 모달 초기화
        function resetPlaylistModal() {
            console.log('플레이리스트 모달 초기화 시작');
            
            playlistCurrentStep = 1;
            
            // 선택 초기화
            Object.keys(playlistSelections).forEach(key => playlistSelections[key] = '');
            
            // 버튼 선택 해제
            const choiceButtons = document.querySelectorAll('#playlistRecommendModal .playlist-choice-button');
            console.log('선택 버튼 개수:', choiceButtons.length);
            
            if (choiceButtons.length > 0) {
                choiceButtons.forEach(btn => {
                    btn.classList.remove('selected');
                });
            }
            
            // 화면 초기화
            const selectionContainer = document.getElementById('playlistSelectionContainer');
            const loadingContainer = document.getElementById('playlistLoading');
            const resultsContainer = document.getElementById('playlistResults');
            
            if (selectionContainer) selectionContainer.style.display = 'block';
            if (loadingContainer) loadingContainer.style.display = 'none';
            if (resultsContainer) resultsContainer.style.display = 'none';
            
            showPlaylistStep(1);
            updatePlaylistUI();
            setupPlaylistChoiceButtons();
            setupPlaylistNavigationButtons();
            
            console.log('플레이리스트 모달 초기화 완료');
        }
        
        // 네비게이션 버튼 이벤트 설정
        function setupPlaylistNavigationButtons() {
            console.log('네비게이션 버튼 이벤트 설정 시작');
            
            const prevBtn = document.getElementById('playlistPrevBtn');
            const nextBtn = document.getElementById('playlistNextBtn');
            const recommendBtn = document.getElementById('playlistRecommendBtn');
            
            console.log('네비게이션 버튼들:', { prevBtn: !!prevBtn, nextBtn: !!nextBtn, recommendBtn: !!recommendBtn });
            
            // 기존 이벤트 리스너 제거 후 새로 설정
            if (prevBtn) {
                prevBtn.onclick = null;
                prevBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    console.log('이전 버튼 클릭');
                    previousPlaylistStep();
                });
            }
            
            if (nextBtn) {
                nextBtn.onclick = null;
                nextBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    console.log('다음 버튼 클릭');
                    nextPlaylistStep();
                });
            }
            
            if (recommendBtn) {
                recommendBtn.onclick = null;
                recommendBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    console.log('추천 버튼 클릭');
                    getPlaylistRecommendation();
                });
            }
            
            console.log('네비게이션 버튼 이벤트 설정 완료');
        }

        // 선택 버튼 이벤트 설정
        function setupPlaylistChoiceButtons() {
            document.querySelectorAll('.playlist-choice-button').forEach(button => {
                button.addEventListener('click', function() {
                    const step = this.closest('.playlist-step');
                    const stepKey = this.dataset.step;
                    const value = this.dataset.value;
                    
                    // 같은 스텝의 다른 버튼들 선택 해제
                    step.querySelectorAll('.playlist-choice-button').forEach(btn => {
                        btn.classList.remove('selected');
                    });
                    
                    // 현재 버튼 선택
                    this.classList.add('selected');
                    
                    // 선택값 저장
                    playlistSelections[stepKey] = value;
                    
                    console.log('선택됨:', stepKey, value);
                    updatePlaylistUI();
                });
            });
        }

        // 다음 스텝
        function nextPlaylistStep() {
            if (playlistCurrentStep < playlistTotalSteps && isPlaylistCurrentStepValid()) {
                playlistCurrentStep++;
                showPlaylistStep(playlistCurrentStep);
                updatePlaylistUI();
            }
        }

        // 이전 스텝
        function previousPlaylistStep() {
            if (playlistCurrentStep > 1) {
                playlistCurrentStep--;
                showPlaylistStep(playlistCurrentStep);
                updatePlaylistUI();
            }
        }

        // 스텝 표시
        function showPlaylistStep(step) {
            console.log('스텝 표시:', step);
            
            const steps = document.querySelectorAll('#playlistRecommendModal .playlist-step');
            console.log('플레이리스트 스텝 요소들:', steps.length);
            
            if (steps.length > 0) {
                steps.forEach(s => {
                    s.classList.remove('active');
                    console.log('스텝 비활성화:', s.id);
                });
            }
            
            const currentStep = document.getElementById(`playlistStep${step}`);
            console.log('현재 스텝 요소:', currentStep);
            
            if (currentStep) {
                currentStep.classList.add('active');
                console.log('스텝 활성화:', currentStep.id);
            } else {
                console.error(`playlistStep${step} 요소를 찾을 수 없습니다`);
            }
        }

        // UI 업데이트
        function updatePlaylistUI() {
            console.log('UI 업데이트 시작, 현재 스텝:', playlistCurrentStep);
            
            // 스텝 인디케이터 업데이트
            const stepDots = document.querySelectorAll('#playlistRecommendModal .step-indicator .step-dot');
            console.log('스텝 인디케이터 요소들:', stepDots.length);
            
            if (stepDots.length > 0) {
                stepDots.forEach((dot, index) => {
                    const stepNum = index + 1;
                    dot.classList.remove('active', 'completed');
                    
                    if (stepNum === playlistCurrentStep) {
                        dot.classList.add('active');
                        console.log('스텝 점 활성화:', stepNum);
                    } else if (stepNum < playlistCurrentStep) {
                        dot.classList.add('completed');
                        console.log('스텝 점 완료:', stepNum);
                    }
                });
            }

            // 버튼 상태 업데이트
            const prevBtn = document.getElementById('playlistPrevBtn');
            const nextBtn = document.getElementById('playlistNextBtn');
            const recommendBtn = document.getElementById('playlistRecommendBtn');

            if (prevBtn) {
                prevBtn.style.display = playlistCurrentStep === 1 ? 'none' : 'flex';
            }
            
            if (playlistCurrentStep === playlistTotalSteps) {
                if (nextBtn) nextBtn.style.display = 'none';
                if (recommendBtn) recommendBtn.style.display = isPlaylistCurrentStepValid() ? 'flex' : 'none';
            } else {
                if (nextBtn) {
                    nextBtn.style.display = 'flex';
                    nextBtn.disabled = !isPlaylistCurrentStepValid();
                }
                if (recommendBtn) recommendBtn.style.display = 'none';
            }
        }

        // 현재 스텝 유효성 검사
        function isPlaylistCurrentStepValid() {
            const stepKeys = {
                1: 'musicOrigin',
                2: 'destinationType', 
                3: 'musicGenre',
                4: 'timeOfDay',
                5: 'travelStyle'
            };
            
            const stepKey = stepKeys[playlistCurrentStep];
            return playlistSelections[stepKey] && playlistSelections[stepKey].length > 0;
        }

        // 플레이리스트 추천 요청
        async function getPlaylistRecommendation() {
            if (!validatePlaylistSelections()) {
                alert('모든 항목을 선택해주세요.');
                return;
            }

            // 로딩 표시
            document.getElementById('playlistSelectionContainer').style.display = 'none';
            document.getElementById('playlistLoading').style.display = 'block';

            try {
                const response = await fetch('http://localhost:8083/playlist/recommend', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(playlistSelections)
                });

                const data = await response.json();

                if (data.success) {
                    displayPlaylistResults(data);
                } else {
                    showPlaylistError(data.message || '추천 생성에 실패했습니다.');
                }

            } catch (error) {
                console.error('추천 요청 실패:', error);
                showPlaylistError('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.');
            } finally {
                document.getElementById('playlistLoading').style.display = 'none';
            }
        }

        // 결과 표시
        function displayPlaylistResults(data) {
            const playlistInfo = document.getElementById('playlistInfo');
            const musicList = document.getElementById('playlistMusicList');

            // 플레이리스트 정보
            const originText = data.musicOrigin === 'korean' ? '🇰🇷 한국 음악' : '🌍 외국 음악';
            playlistInfo.innerHTML = `
                <h4>${originText} 플레이리스트</h4>
                <p>총 ${data.recommendations.length}곡의 맞춤 추천</p>
            `;

            // 음악 리스트
            musicList.innerHTML = '';
            data.recommendations.forEach(music => {
                const musicItem = document.createElement('div');
                musicItem.className = 'music-item';
                musicItem.innerHTML = `
                    <div class="number">${music.order}</div>
                    <div class="title">${music.songTitle}</div>
                    <div class="artist">${music.artist}</div>
                    <div class="reason">💡 ${music.reason}</div>
                    <div class="genre">${music.genre}</div>
                `;
                musicList.appendChild(musicItem);
            });

            document.getElementById('playlistResults').style.display = 'block';
        }

        // 에러 표시
        function showPlaylistError(message) {
            alert('오류: ' + message);
            document.getElementById('playlistSelectionContainer').style.display = 'block';
        }

        // 모든 선택 검증
        function validatePlaylistSelections() {
            return Object.values(playlistSelections).every(value => value && value.length > 0);
        }

        // 다시 시작
        function restartPlaylistRecommendation() {
            resetPlaylistModal();
        }

        // 모달 외부 클릭 시 닫기 이벤트만 등록 (초기화는 위에서 처리)
        window.addEventListener('click', function(event) {
            const playlistModal = document.getElementById('playlistRecommendModal');
            if (event.target === playlistModal) {
                closePlaylistModal();
            }
        });
