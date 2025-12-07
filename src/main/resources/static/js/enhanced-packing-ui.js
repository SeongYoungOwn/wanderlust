// Enhanced UI Functions for AI Packing Assistant

// Enhanced progress update with smooth animations
function updateProgress(percentage) {
    const progressFill = document.getElementById('progressFill');
    const progressText = document.getElementById('progressText');
    
    if (progressFill && progressText) {
        // Smooth progress animation
        progressFill.style.transition = 'width 0.8s cubic-bezier(0.4, 0, 0.2, 1)';
        progressFill.style.width = percentage + '%';
        
        const step = Math.round(percentage / 33);
        progressText.textContent = step + '/3 단계';
        
        // Add pulse effect when progress updates
        progressFill.style.animation = 'progressPulse 0.6s ease-out';
        setTimeout(() => {
            progressFill.style.animation = '';
        }, 600);
    }
}

// Enhanced message addition with typing animation
function addMessage(role, content, isComplete = false) {
    const messagesContainer = document.getElementById('packingChatMessages');
    if (!messagesContainer) return;
    
    const messageDiv = document.createElement('div');
    messageDiv.className = role === 'ai' ? 'ai-message' : 'user-message';
    
    if (role === 'ai') {
        // Show typing indicator first
        const typingDiv = showTypingIndicator();
        
        setTimeout(() => {
            removeTypingIndicator();
            
            messageDiv.innerHTML = `
                <div class="message-content">
                    <div class="message-text" style="opacity: 0;"></div>
                    ${isComplete ? '<div class="message-actions" style="opacity: 0; margin-top: 1rem;"></div>' : ''}
                </div>
            `;
            
            messagesContainer.appendChild(messageDiv);
            
            // Typing animation effect
            const messageText = messageDiv.querySelector('.message-text');
            typeMessage(messageText, content, () => {
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
                
                // Add PDF download button if conversation is complete
                if (isComplete) {
                    addPDFDownloadButton(messageDiv);
                    // Show PDF suggestion after a delay
                    setTimeout(() => {
                        showPDFSuggestion();
                    }, 2000);
                }
            });
            
        }, 1000 + Math.random() * 1000); // Random typing delay
    } else {
        messageDiv.innerHTML = `
            <div class="message-content">
                <div class="message-text">${content.replace(/\n/g, '<br>')}</div>
            </div>
        `;
        
        messagesContainer.appendChild(messageDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
        
        // Add send animation
        messageDiv.style.transform = 'translateX(20px)';
        messageDiv.style.opacity = '0';
        
        setTimeout(() => {
            messageDiv.style.transition = 'all 0.4s ease-out';
            messageDiv.style.transform = 'translateX(0)';
            messageDiv.style.opacity = '1';
        }, 10);
    }
}

// Typing animation effect
function typeMessage(element, text, callback) {
    element.style.opacity = '1';
    let index = 0;
    const speed = 30; // milliseconds per character
    
    function typeChar() {
        if (index < text.length) {
            const char = text.charAt(index);
            if (char === '\n') {
                element.innerHTML += '<br>';
            } else {
                element.innerHTML += char;
            }
            index++;
            setTimeout(typeChar, speed);
        } else {
            if (callback) callback();
        }
    }
    
    typeChar();
}

// Show typing indicator
function showTypingIndicator() {
    const messagesContainer = document.getElementById('packingChatMessages');
    const typingDiv = document.createElement('div');
    typingDiv.className = 'ai-message typing-indicator';
    typingDiv.id = 'typingIndicator';
    
    typingDiv.innerHTML = `
        <div class="message-content">
            <div class="typing-indicator">
                <span>AI가 응답을 작성 중입니다</span>
                <div class="loading-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        </div>
    `;
    
    messagesContainer.appendChild(typingDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
    
    return typingDiv;
}

// Remove typing indicator
function removeTypingIndicator() {
    const typingIndicator = document.getElementById('typingIndicator');
    if (typingIndicator) {
        typingIndicator.style.transition = 'opacity 0.3s ease-out';
        typingIndicator.style.opacity = '0';
        setTimeout(() => {
            typingIndicator.remove();
        }, 300);
    }
}

// Add PDF download and copy buttons to AI message
function addPDFDownloadButton(messageDiv) {
    const actionsContainer = messageDiv.querySelector('.message-actions');
    if (!actionsContainer || !packingConversationId) return;
    
    // Add copy button
    const copyButton = document.createElement('button');
    copyButton.className = 'copy-text-btn';
    copyButton.innerHTML = `
        <i class="fas fa-copy"></i>
        <span>답변 복사</span>
    `;
    
    copyButton.onclick = () => copyAIResponse(messageDiv);
    actionsContainer.appendChild(copyButton);
    
    // Add PDF button
    const pdfButton = document.createElement('button');
    pdfButton.className = 'pdf-download-btn';
    pdfButton.innerHTML = `
        <i class="fas fa-file-pdf"></i>
        <span>PDF 다운로드</span>
    `;
    
    pdfButton.onclick = () => downloadPDF(packingConversationId);
    actionsContainer.appendChild(pdfButton);
    
    // Animate buttons appearance
    setTimeout(() => {
        actionsContainer.style.transition = 'opacity 0.5s ease-out';
        actionsContainer.style.opacity = '1';
        
        [copyButton, pdfButton].forEach((button, index) => {
            button.style.transform = 'scale(0.9)';
            button.style.transition = 'all 0.3s ease-out';
            setTimeout(() => {
                button.style.transform = 'scale(1)';
            }, 100 + (index * 100));
        });
    }, 500);
}

// Enhanced packing results display with animations
function showPackingResults(packingList) {
    const chatContainer = document.querySelector('.packing-chat-container');
    const resultsContainer = document.getElementById('packingResults');
    const categoriesContainer = document.getElementById('packingCategories');
    
    if (!resultsContainer || !categoriesContainer) return;
    
    // Hide chat with animation
    chatContainer.style.transition = 'opacity 0.4s ease-out, transform 0.4s ease-out';
    chatContainer.style.opacity = '0';
    chatContainer.style.transform = 'translateY(-20px)';
    
    setTimeout(() => {
        chatContainer.style.display = 'none';
        
        // Show results with animation
        resultsContainer.style.display = 'block';
        resultsContainer.style.opacity = '0';
        resultsContainer.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            resultsContainer.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
            resultsContainer.style.opacity = '1';
            resultsContainer.style.transform = 'translateY(0)';
        }, 50);
        
        // Populate categories with staggered animations
        populatePackingCategories(packingList);
        updatePackingSummary(packingList);
        
    }, 400);
}

// Populate packing categories with animations
function populatePackingCategories(packingList) {
    const categoriesContainer = document.getElementById('packingCategories');
    categoriesContainer.innerHTML = '';
    
    const categoryIcons = {
        '의류': '👕',
        '세면용품': '🧴',
        '전자기기': '📱',
        '여행용품': '✈️',
        '액티비티 용품': '🏔️',
        '기타': '💼'
    };
    
    let delay = 0;
    
    Object.entries(packingList).forEach(([category, items]) => {
        if (items && items.length > 0) {
            const categoryDiv = createPackingCategoryElement(category, items, categoryIcons[category] || '📦');
            
            // Add staggered animation
            categoryDiv.style.opacity = '0';
            categoryDiv.style.transform = 'translateY(30px) scale(0.95)';
            categoriesContainer.appendChild(categoryDiv);
            
            setTimeout(() => {
                categoryDiv.style.transition = 'all 0.5s cubic-bezier(0.4, 0, 0.2, 1)';
                categoryDiv.style.opacity = '1';
                categoryDiv.style.transform = 'translateY(0) scale(1)';
            }, delay);
            
            delay += 150; // Stagger delay
        }
    });
}

// Create packing category element
function createPackingCategoryElement(category, items, icon) {
    const categoryDiv = document.createElement('div');
    categoryDiv.className = 'packing-category';
    
    const itemsHtml = items.map(item => `
        <div class="packing-item" data-item="${item.itemName}">
            <input type="checkbox" class="item-checkbox" id="item_${item.itemName}" 
                   onchange="togglePackingItem('${item.itemName}', this.checked)">
            <div class="item-details">
                <div class="item-name">${item.itemName}</div>
                <div class="item-description">${item.description}</div>
                <span class="necessity-badge ${item.necessityLevel}">${item.necessityLevel}</span>
            </div>
        </div>
    `).join('');
    
    categoryDiv.innerHTML = `
        <div class="category-header">
            <span class="category-icon">${icon}</span>
            <h4>${category}</h4>
            <span class="category-count">${items.length}개</span>
        </div>
        <div class="category-items">
            ${itemsHtml}
        </div>
    `;
    
    return categoryDiv;
}

// Enhanced item toggle with animations
function togglePackingItem(itemName, isChecked) {
    const itemElement = document.querySelector(`[data-item="${itemName}"]`);
    if (!itemElement) return;
    
    if (isChecked) {
        itemElement.classList.add('checked');
        // Add check animation
        itemElement.style.transform = 'scale(1.02)';
        setTimeout(() => {
            itemElement.style.transform = 'scale(1)';
        }, 200);
        
        // Confetti effect for completion
        createCheckConfetti(itemElement);
    } else {
        itemElement.classList.remove('checked');
    }
    
    // Update summary with animation
    updatePackingSummaryAnimated();
    
    // Update server
    updateChecklistItem(packingConversationId, itemName, isChecked);
}

// Create check confetti effect
function createCheckConfetti(element) {
    const rect = element.getBoundingClientRect();
    const colors = ['#8b5cf6', '#ec4899', '#f97316', '#10b981'];
    
    for (let i = 0; i < 8; i++) {
        const confetti = document.createElement('div');
        confetti.style.position = 'fixed';
        confetti.style.left = rect.left + rect.width / 2 + 'px';
        confetti.style.top = rect.top + rect.height / 2 + 'px';
        confetti.style.width = '6px';
        confetti.style.height = '6px';
        confetti.style.backgroundColor = colors[Math.floor(Math.random() * colors.length)];
        confetti.style.borderRadius = '50%';
        confetti.style.pointerEvents = 'none';
        confetti.style.zIndex = '10001';
        confetti.style.transition = 'all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
        
        document.body.appendChild(confetti);
        
        setTimeout(() => {
            const angle = (Math.PI * 2 * i) / 8;
            const distance = 50 + Math.random() * 30;
            const x = Math.cos(angle) * distance;
            const y = Math.sin(angle) * distance - 20;
            
            confetti.style.transform = `translate(${x}px, ${y}px)`;
            confetti.style.opacity = '0';
            confetti.style.scale = '0';
        }, 50);
        
        setTimeout(() => {
            confetti.remove();
        }, 1000);
    }
}

// Update packing summary with animation
function updatePackingSummaryAnimated() {
    const totalItems = document.querySelectorAll('.packing-item').length;
    const checkedItems = document.querySelectorAll('.packing-item.checked').length;
    const progressPercent = totalItems > 0 ? Math.round((checkedItems / totalItems) * 100) : 0;
    
    // Animate numbers
    animateNumber('totalItems', totalItems);
    animateNumber('checkedItems', checkedItems);
    animateNumber('progressPercent', progressPercent, '%');
    
    // Update progress bar if exists
    const progressBar = document.querySelector('.summary-progress-bar');
    if (progressBar) {
        progressBar.style.width = progressPercent + '%';
    }
}

// Animate number changes
function animateNumber(elementId, targetValue, suffix = '') {
    const element = document.getElementById(elementId);
    if (!element) return;
    
    const startValue = parseInt(element.textContent) || 0;
    const duration = 800;
    const startTime = performance.now();
    
    function updateNumber(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        
        // Easing function
        const easeOut = 1 - Math.pow(1 - progress, 3);
        const currentValue = Math.round(startValue + (targetValue - startValue) * easeOut);
        
        element.textContent = currentValue + suffix;
        
        if (progress < 1) {
            requestAnimationFrame(updateNumber);
        }
    }
    
    requestAnimationFrame(updateNumber);
}

// Enhanced input focus effects
function enhanceInputInteractions() {
    const input = document.getElementById('packingMessageInput');
    const button = document.getElementById('sendMessageBtn');
    
    if (!input || !button) return;
    
    // Enhanced focus effects
    input.addEventListener('focus', () => {
        input.style.transform = 'translateY(-2px)';
        input.style.boxShadow = '0 0 30px rgba(139, 92, 246, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.2)';
    });
    
    input.addEventListener('blur', () => {
        input.style.transform = 'translateY(0)';
        input.style.boxShadow = 'inset 0 1px 0 rgba(255, 255, 255, 0.1)';
    });
    
    // Enhanced button interactions
    button.addEventListener('mousedown', () => {
        button.style.transform = 'translateY(0) scale(0.98)';
    });
    
    button.addEventListener('mouseup', () => {
        button.style.transform = 'translateY(-3px) scale(1.05)';
    });
    
    button.addEventListener('mouseleave', () => {
        button.style.transform = 'translateY(0) scale(1)';
    });
}

// Particle effects for modal background
function createModalParticles() {
    const modal = document.getElementById('packingAssistantModal');
    if (!modal) return;
    
    const particleCount = 20;
    
    for (let i = 0; i < particleCount; i++) {
        const particle = document.createElement('div');
        particle.className = 'modal-particle';
        particle.style.position = 'absolute';
        particle.style.width = Math.random() * 4 + 2 + 'px';
        particle.style.height = particle.style.width;
        particle.style.backgroundColor = `rgba(139, 92, 246, ${Math.random() * 0.3 + 0.1})`;
        particle.style.borderRadius = '50%';
        particle.style.left = Math.random() * 100 + '%';
        particle.style.top = Math.random() * 100 + '%';
        particle.style.pointerEvents = 'none';
        particle.style.animation = `floatParticle ${Math.random() * 10 + 10}s linear infinite`;
        
        modal.appendChild(particle);
        
        // Remove particle after animation
        setTimeout(() => {
            if (particle.parentNode) {
                particle.remove();
            }
        }, (Math.random() * 10 + 10) * 1000);
    }
}

// Enhanced modal animations
function enhanceModalAnimations() {
    const modal = document.getElementById('packingAssistantModal');
    if (!modal) return;
    
    // Add entrance animation
    modal.style.animation = 'modalFadeIn 0.4s ease-out';
    
    // Add particle effects
    setTimeout(() => {
        createModalParticles();
    }, 500);
    
    // Enhance close animation
    const originalClose = window.closePackingAssistant;
    window.closePackingAssistant = function() {
        modal.style.animation = 'modalFadeOut 0.3s ease-in';
        setTimeout(() => {
            if (originalClose) originalClose();
        }, 300);
    };
}

// Voice input functionality removed per user request

// Smart suggestions based on input
function addSmartSuggestions() {
    const input = document.getElementById('packingMessageInput');
    if (!input) return;
    
    const suggestions = [
        '일본 도쿄 3일 여행',
        '유럽 배낭여행 2주',
        '제주도 가족여행 4일',
        '태국 방콕 5일 출장',
        '미국 서부 렌터카 여행 10일',
        '국내 캠핑 2박 3일'
    ];
    
    const suggestionsContainer = document.createElement('div');
    suggestionsContainer.className = 'input-suggestions';
    suggestionsContainer.style.cssText = `
        position: absolute;
        top: 100%;
        left: 0;
        right: 0;
        background: rgba(255, 255, 255, 0.95);
        border-radius: 0 0 16px 16px;
        backdrop-filter: blur(20px);
        max-height: 200px;
        overflow-y: auto;
        z-index: 1000;
        display: none;
    `;
    
    input.parentElement.style.position = 'relative';
    input.parentElement.appendChild(suggestionsContainer);
    
    input.addEventListener('focus', () => {
        if (input.value.length === 0) {
            showSuggestions(suggestions, suggestionsContainer, input);
        }
    });
    
    input.addEventListener('input', () => {
        const value = input.value.toLowerCase();
        if (value.length > 0) {
            const filtered = suggestions.filter(s => s.toLowerCase().includes(value));
            showSuggestions(filtered, suggestionsContainer, input);
        } else {
            suggestionsContainer.style.display = 'none';
        }
    });
    
    document.addEventListener('click', (e) => {
        if (!input.parentElement.contains(e.target)) {
            suggestionsContainer.style.display = 'none';
        }
    });
}

function showSuggestions(suggestions, container, input) {
    if (suggestions.length === 0) {
        container.style.display = 'none';
        return;
    }
    
    container.innerHTML = suggestions.map(suggestion => `
        <div class="suggestion-item" style="
            padding: 0.75rem 1rem;
            cursor: pointer;
            transition: background 0.2s ease;
            color: #333;
        " onclick="selectSuggestion('${suggestion}', this)">${suggestion}</div>
    `).join('');
    
    container.style.display = 'block';
    
    // Add hover effects
    container.querySelectorAll('.suggestion-item').forEach(item => {
        item.addEventListener('mouseenter', () => {
            item.style.backgroundColor = 'rgba(139, 92, 246, 0.1)';
        });
        item.addEventListener('mouseleave', () => {
            item.style.backgroundColor = 'transparent';
        });
    });
}

function selectSuggestion(suggestion, element) {
    const input = document.getElementById('packingMessageInput');
    input.value = suggestion;
    
    const container = element.parentElement;
    container.style.display = 'none';
    
    input.focus();
}

// Initialize enhanced UI features
document.addEventListener('DOMContentLoaded', function() {
    // Add enhanced interactions after modal is opened
    const originalOpen = window.openPackingAssistant;
    window.openPackingAssistant = function() {
        if (originalOpen) originalOpen();
        
        setTimeout(() => {
            enhanceInputInteractions();
            enhanceModalAnimations();
            addSmartSuggestions();
        }, 100);
    };
});

// CSS animations (to be added to the CSS file)
const additionalCSS = `
@keyframes modalFadeIn {
    0% {
        opacity: 0;
        backdrop-filter: blur(0px);
    }
    100% {
        opacity: 1;
        backdrop-filter: blur(10px);
    }
}

@keyframes modalFadeOut {
    0% {
        opacity: 1;
        backdrop-filter: blur(10px);
    }
    100% {
        opacity: 0;
        backdrop-filter: blur(0px);
    }
}

@keyframes progressPulse {
    0% {
        box-shadow: 0 0 0 rgba(139, 92, 246, 0.4);
    }
    50% {
        box-shadow: 0 0 20px rgba(139, 92, 246, 0.8);
    }
    100% {
        box-shadow: 0 0 0 rgba(139, 92, 246, 0.4);
    }
}

@keyframes floatParticle {
    0% {
        transform: translateY(100vh) rotate(0deg);
        opacity: 0;
    }
    10% {
        opacity: 1;
    }
    90% {
        opacity: 1;
    }
    100% {
        transform: translateY(-10vh) rotate(360deg);
        opacity: 0;
    }
}

.voice-input-btn:hover {
    background: rgba(139, 92, 246, 0.3) !important;
    transform: translateY(-50%) scale(1.1) !important;
}
`;

// Add additional CSS to the page
const style = document.createElement('style');
style.textContent = additionalCSS;
document.head.appendChild(style);

// Copy AI response function
function copyAIResponse(messageDiv) {
    const messageText = messageDiv.querySelector('.message-text');
    if (!messageText) return;
    
    // Get the text content without HTML tags
    const textContent = messageText.innerText || messageText.textContent;
    
    // Copy to clipboard
    navigator.clipboard.writeText(textContent).then(() => {
        // Show success feedback
        const copyButton = messageDiv.querySelector('.copy-text-btn');
        if (copyButton) {
            const originalHTML = copyButton.innerHTML;
            const originalClass = copyButton.className;
            
            copyButton.innerHTML = `
                <i class="fas fa-check"></i>
                <span>복사완료!</span>
            `;
            copyButton.classList.add('copied');
            
            // Reset after 2 seconds
            setTimeout(() => {
                copyButton.innerHTML = originalHTML;
                copyButton.className = originalClass;
            }, 2000);
        }
        
        // Show toast notification
        showCopyToast();
    }).catch(err => {
        console.error('복사 실패:', err);
        // Fallback for older browsers
        fallbackCopyTextToClipboard(textContent, messageDiv);
    });
}

// Fallback copy method for older browsers
function fallbackCopyTextToClipboard(text, messageDiv) {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    textArea.style.position = 'fixed';
    textArea.style.left = '-999999px';
    textArea.style.top = '-999999px';
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    try {
        const successful = document.execCommand('copy');
        if (successful) {
            const copyButton = messageDiv.querySelector('.copy-text-btn');
            if (copyButton) {
                const originalHTML = copyButton.innerHTML;
                const originalClass = copyButton.className;
                
                copyButton.innerHTML = `
                    <i class="fas fa-check"></i>
                    <span>복사완료!</span>
                `;
                copyButton.classList.add('copied');
                
                setTimeout(() => {
                    copyButton.innerHTML = originalHTML;
                    copyButton.className = originalClass;
                }, 2000);
            }
            showCopyToast();
        }
    } catch (err) {
        console.error('Fallback 복사 실패:', err);
    }
    
    document.body.removeChild(textArea);
}

// Show copy success toast
function showCopyToast() {
    const toast = document.createElement('div');
    toast.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(135deg, #16a34a, #15803d);
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 12px;
        box-shadow: 0 8px 25px rgba(22, 163, 74, 0.3);
        z-index: 10000;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        animation: slideInRight 0.3s ease-out;
    `;
    
    toast.innerHTML = `
        <i class="fas fa-check-circle"></i>
        <span>답변이 클립보드에 복사되었습니다!</span>
    `;
    
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease-in';
        setTimeout(() => {
            document.body.removeChild(toast);
        }, 300);
    }, 3000);
}

// Show PDF suggestion modal
function showPDFSuggestion() {
    if (!packingConversationId) return;
    
    const suggestionModal = document.createElement('div');
    suggestionModal.id = 'pdfSuggestionModal';
    suggestionModal.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        backdrop-filter: blur(10px);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 10001;
        animation: fadeIn 0.3s ease-out;
    `;
    
    suggestionModal.innerHTML = `
        <div style="
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05));
            border-radius: 20px;
            padding: 2rem;
            max-width: 400px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(20px);
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
            animation: slideInUp 0.3s ease-out;
        ">
            <div style="
                width: 60px;
                height: 60px;
                background: linear-gradient(135deg, #dc2626, #b91c1c);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 1.5rem;
                box-shadow: 0 8px 25px rgba(220, 38, 38, 0.3);
            ">
                <i class="fas fa-file-pdf" style="color: white; font-size: 1.5rem;"></i>
            </div>
            
            <h3 style="
                color: #ffffff;
                margin: 0 0 1rem 0;
                font-size: 1.25rem;
                font-weight: 700;
            ">PDF로 저장하시겠어요?</h3>
            
            <p style="
                color: rgba(255, 255, 255, 0.8);
                margin: 0 0 2rem 0;
                line-height: 1.5;
                font-size: 0.95rem;
            ">AI가 추천한 패킹 리스트를<br>PDF 파일로 만들어드릴까요?</p>
            
            <div style="
                display: flex;
                gap: 1rem;
                justify-content: center;
            ">
                <button id="declinePDF" style="
                    background: rgba(255, 255, 255, 0.1);
                    border: 1px solid rgba(255, 255, 255, 0.2);
                    border-radius: 12px;
                    padding: 0.75rem 1.5rem;
                    color: #ffffff;
                    cursor: pointer;
                    transition: all 0.3s ease;
                    font-weight: 600;
                ">나중에</button>
                
                <button id="acceptPDF" style="
                    background: linear-gradient(135deg, #dc2626, #b91c1c);
                    border: none;
                    border-radius: 12px;
                    padding: 0.75rem 1.5rem;
                    color: #ffffff;
                    cursor: pointer;
                    transition: all 0.3s ease;
                    font-weight: 600;
                    box-shadow: 0 4px 15px rgba(220, 38, 38, 0.3);
                ">PDF 만들기</button>
            </div>
        </div>
    `;
    
    document.body.appendChild(suggestionModal);
    
    // Add event listeners
    document.getElementById('declinePDF').onclick = () => {
        closePDFSuggestion();
    };
    
    document.getElementById('acceptPDF').onclick = () => {
        closePDFSuggestion();
        downloadPDF(packingConversationId);
    };
    
    // Close on background click
    suggestionModal.onclick = (e) => {
        if (e.target === suggestionModal) {
            closePDFSuggestion();
        }
    };
    
    // Add animations CSS if not exist
    if (!document.getElementById('pdfSuggestionCSS')) {
        const style = document.createElement('style');
        style.id = 'pdfSuggestionCSS';
        style.textContent = `
            @keyframes fadeIn {
                0% { opacity: 0; }
                100% { opacity: 1; }
            }
            
            @keyframes slideInUp {
                0% {
                    transform: translateY(30px);
                    opacity: 0;
                }
                100% {
                    transform: translateY(0);
                    opacity: 1;
                }
            }
            
            @keyframes fadeOut {
                0% { opacity: 1; }
                100% { opacity: 0; }
            }
            
            @keyframes slideOutDown {
                0% {
                    transform: translateY(0);
                    opacity: 1;
                }
                100% {
                    transform: translateY(30px);
                    opacity: 0;
                }
            }
            
            #declinePDF:hover {
                background: rgba(255, 255, 255, 0.15);
                border-color: rgba(255, 255, 255, 0.3);
                transform: translateY(-2px);
            }
            
            #acceptPDF:hover {
                background: linear-gradient(135deg, #b91c1c, #991b1b);
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(220, 38, 38, 0.4);
            }
        `;
        document.head.appendChild(style);
    }
}

function closePDFSuggestion() {
    const modal = document.getElementById('pdfSuggestionModal');
    if (modal) {
        modal.style.animation = 'fadeOut 0.3s ease-out';
        modal.querySelector('div').style.animation = 'slideOutDown 0.3s ease-out';
        setTimeout(() => {
            document.body.removeChild(modal);
        }, 300);
    }
}