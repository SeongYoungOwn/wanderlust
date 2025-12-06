<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Toast Messages Component --%>
<div id="toastContainer" class="toast-container"></div>

<style>
/* Toast Container */
.toast-container {
    position: fixed;
    top: 100px;
    right: 20px;
    z-index: 10000;
    max-width: 350px;
    pointer-events: none;
}

/* Toast Base Styles */
.toast {
    background: white;
    border-radius: 15px;
    box-shadow: 0 15px 50px rgba(0, 0, 0, 0.15);
    border: 1px solid rgba(0, 0, 0, 0.1);
    margin-bottom: 10px;
    padding: 1rem 1.2rem;
    min-width: 300px;
    max-width: 350px;
    opacity: 0;
    transform: translateX(100%);
    transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    pointer-events: auto;
    position: relative;
    overflow: hidden;
}

.toast.show {
    opacity: 1;
    transform: translateX(0);
}

.toast.hiding {
    opacity: 0;
    transform: translateX(100%);
}

/* Toast Types */
.toast-success {
    border-left: 4px solid #22c55e;
    background: linear-gradient(135deg, #f0fdf4, #dcfce7);
}

.toast-error {
    border-left: 4px solid #ef4444;
    background: linear-gradient(135deg, #fef2f2, #fee2e2);
}

.toast-warning {
    border-left: 4px solid #f59e0b;
    background: linear-gradient(135deg, #fffbeb, #fef3c7);
}

.toast-info {
    border-left: 4px solid #3b82f6;
    background: linear-gradient(135deg, #eff6ff, #dbeafe);
}

/* Toast Content */
.toast-content {
    display: flex;
    align-items: flex-start;
    gap: 0.8rem;
}

.toast-icon {
    font-size: 1.2rem;
    margin-top: 0.1rem;
    flex-shrink: 0;
}

.toast-success .toast-icon {
    color: #22c55e;
}

.toast-error .toast-icon {
    color: #ef4444;
}

.toast-warning .toast-icon {
    color: #f59e0b;
}

.toast-info .toast-icon {
    color: #3b82f6;
}

.toast-message {
    flex: 1;
    min-width: 0;
}

.toast-title {
    font-weight: 600;
    font-size: 0.95rem;
    margin-bottom: 0.2rem;
    color: #1f2937;
}

.toast-text {
    font-size: 0.9rem;
    color: #6b7280;
    line-height: 1.4;
    word-wrap: break-word;
}

.toast-close {
    position: absolute;
    top: 0.8rem;
    right: 0.8rem;
    background: none;
    border: none;
    font-size: 1.2rem;
    color: #9ca3af;
    cursor: pointer;
    padding: 0;
    width: 20px;
    height: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    transition: all 0.2s ease;
}

.toast-close:hover {
    background: rgba(0, 0, 0, 0.1);
    color: #374151;
}

/* Progress Bar */
.toast-progress {
    position: absolute;
    bottom: 0;
    left: 0;
    height: 3px;
    background: rgba(0, 0, 0, 0.1);
    border-radius: 0 0 15px 15px;
    overflow: hidden;
}

.toast-progress-bar {
    height: 100%;
    width: 100%;
    background: currentColor;
    transform-origin: left;
    animation: toast-progress 5s linear;
}

.toast-success .toast-progress-bar {
    background: #22c55e;
}

.toast-error .toast-progress-bar {
    background: #ef4444;
}

.toast-warning .toast-progress-bar {
    background: #f59e0b;
}

.toast-info .toast-progress-bar {
    background: #3b82f6;
}

@keyframes toast-progress {
    0% {
        transform: scaleX(1);
    }
    100% {
        transform: scaleX(0);
    }
}

/* Action Buttons */
.toast-actions {
    display: flex;
    gap: 0.5rem;
    margin-top: 0.8rem;
}

.toast-action {
    padding: 0.4rem 0.8rem;
    border-radius: 8px;
    border: none;
    font-size: 0.8rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
}

.toast-action-primary {
    background: #3b82f6;
    color: white;
}

.toast-action-primary:hover {
    background: #2563eb;
}

.toast-action-secondary {
    background: #f3f4f6;
    color: #374151;
    border: 1px solid #d1d5db;
}

.toast-action-secondary:hover {
    background: #e5e7eb;
}

/* Responsive */
@media (max-width: 768px) {
    .toast-container {
        top: 80px;
        right: 10px;
        left: 10px;
        max-width: none;
    }
    
    .toast {
        min-width: auto;
        max-width: none;
        margin: 0 0 10px 0;
    }
    
    .toast-content {
        gap: 0.6rem;
    }
    
    .toast-title {
        font-size: 0.9rem;
    }
    
    .toast-text {
        font-size: 0.85rem;
    }
}

/* Hover Effects */
.toast:hover {
    transform: translateX(-5px);
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
}

.toast:hover .toast-progress-bar {
    animation-play-state: paused;
}

/* Stacking Animation */
.toast:not(:first-child) {
    margin-top: -5px;
    transform: scale(0.95) translateY(-10px);
}

.toast.show:not(:first-child) {
    transform: scale(0.95) translateY(-10px) translateX(0);
}

/* Custom Animations */
@keyframes slideInRight {
    from {
        opacity: 0;
        transform: translateX(100%);
    }
    to {
        opacity: 1;
        transform: translateX(0);
    }
}

@keyframes slideOutRight {
    from {
        opacity: 1;
        transform: translateX(0);
    }
    to {
        opacity: 0;
        transform: translateX(100%);
    }
}

.toast-slide-in {
    animation: slideInRight 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.toast-slide-out {
    animation: slideOutRight 0.3s ease-in-out;
}
</style>

<script>
/**
 * Toast 메시지 시스템
 * 사용법: showToast('메시지', 'success|error|warning|info', 지속시간, 액션들)
 */
class ToastManager {
    constructor() {
        this.container = document.getElementById('toastContainer');
        this.toasts = [];
        this.maxToasts = 5;
    }

    /**
     * Toast 메시지 표시
     * @param {string} message - 메시지 내용
     * @param {string} type - 타입 (success, error, warning, info)
     * @param {number} duration - 지속 시간 (밀리초, 0이면 자동 닫기 없음)
     * @param {Array} actions - 액션 버튼들 [{text: '확인', action: function, primary: true}]
     * @param {string} title - 제목 (선택적)
     */
    show(message, type = 'info', duration = 5000, actions = [], title = '') {
        // 최대 개수 초과시 가장 오래된 toast 제거
        if (this.toasts.length >= this.maxToasts) {
            this.remove(this.toasts[0]);
        }

        const toast = this.createToast(message, type, duration, actions, title);
        this.container.appendChild(toast);
        this.toasts.push(toast);

        // 애니메이션을 위한 지연
        setTimeout(() => {
            toast.classList.add('show');
        }, 10);

        // 자동 닫기
        if (duration > 0) {
            toast.autoCloseTimer = setTimeout(() => {
                this.remove(toast);
            }, duration);
        }

        return toast;
    }

    createToast(message, type, duration, actions, title) {
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;

        const iconMap = {
            success: 'fas fa-check-circle',
            error: 'fas fa-exclamation-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle'
        };

        let actionsHtml = '';
        if (actions.length > 0) {
            actionsHtml = '<div class="toast-actions">';
            actions.forEach(action => {
                const buttonClass = action.primary ? 'toast-action-primary' : 'toast-action-secondary';
                actionsHtml += `<button class="toast-action ${buttonClass}" onclick="(${action.action.toString()})()">${action.text}</button>`;
            });
            actionsHtml += '</div>';
        }

        toast.innerHTML = `
            <div class="toast-content">
                <div class="toast-icon">
                    <i class="${iconMap[type]}"></i>
                </div>
                <div class="toast-message">
                    ${title ? `<div class="toast-title">${title}</div>` : ''}
                    <div class="toast-text">${message}</div>
                    ${actionsHtml}
                </div>
            </div>
            <button class="toast-close" onclick="toastManager.remove(this.closest('.toast'))">
                <i class="fas fa-times"></i>
            </button>
            ${duration > 0 ? '<div class="toast-progress"><div class="toast-progress-bar"></div></div>' : ''}
        `;

        // 호버시 타이머 일시정지
        toast.addEventListener('mouseenter', () => {
            if (toast.autoCloseTimer) {
                clearTimeout(toast.autoCloseTimer);
                const progressBar = toast.querySelector('.toast-progress-bar');
                if (progressBar) {
                    progressBar.style.animationPlayState = 'paused';
                }
            }
        });

        toast.addEventListener('mouseleave', () => {
            if (duration > 0 && toast.parentElement) {
                const progressBar = toast.querySelector('.toast-progress-bar');
                if (progressBar) {
                    const remainingTime = duration * (1 - (progressBar.getBoundingClientRect().width / progressBar.parentElement.getBoundingClientRect().width));
                    progressBar.style.animationPlayState = 'running';
                    
                    toast.autoCloseTimer = setTimeout(() => {
                        this.remove(toast);
                    }, remainingTime);
                }
            }
        });

        return toast;
    }

    remove(toast) {
        if (!toast || !toast.parentElement) return;

        const index = this.toasts.indexOf(toast);
        if (index > -1) {
            this.toasts.splice(index, 1);
        }

        if (toast.autoCloseTimer) {
            clearTimeout(toast.autoCloseTimer);
        }

        toast.classList.add('hiding');
        setTimeout(() => {
            if (toast.parentElement) {
                toast.parentElement.removeChild(toast);
            }
        }, 400);
    }

    // 편의 메서드들
    success(message, duration = 5000, actions = [], title = '') {
        return this.show(message, 'success', duration, actions, title);
    }

    error(message, duration = 0, actions = [], title = '') {
        return this.show(message, 'error', duration, actions, title);
    }

    warning(message, duration = 7000, actions = [], title = '') {
        return this.show(message, 'warning', duration, actions, title);
    }

    info(message, duration = 5000, actions = [], title = '') {
        return this.show(message, 'info', duration, actions, title);
    }

    // 모든 toast 제거
    clear() {
        this.toasts.forEach(toast => this.remove(toast));
    }
}

// 전역 인스턴스 생성
const toastManager = new ToastManager();

// 전역 함수들 (하위 호환성)
function showToast(message, type = 'info', duration = 5000) {
    return toastManager.show(message, type, duration);
}

function showSuccessToast(message, duration = 5000) {
    return toastManager.success(message, duration);
}

function showErrorToast(message, duration = 0) {
    return toastManager.error(message, duration);
}

function showWarningToast(message, duration = 7000) {
    return toastManager.warning(message, duration);
}

function showInfoToast(message, duration = 5000) {
    return toastManager.info(message, duration);
}
</script>