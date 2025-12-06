<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Progress Bar Component --%>
<div id="progressBarContainer" class="progress-container" style="display: none;">
    <!-- File Upload Progress -->
    <div id="uploadProgress" class="progress-modal" style="display: none;">
        <div class="progress-modal-content">
            <div class="progress-header">
                <h5 class="progress-title">
                    <i class="fas fa-upload me-2"></i>파일 업로드 중...
                </h5>
                <button type="button" class="progress-close" onclick="hideUploadProgress()">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <div class="progress-body">
                <div class="progress-info">
                    <span class="progress-filename">파일명.jpg</span>
                    <span class="progress-percentage">0%</span>
                </div>
                <div class="progress-bar-wrapper">
                    <div class="progress-bar upload-progress">
                        <div class="progress-fill" style="width: 0%"></div>
                        <div class="progress-glow"></div>
                    </div>
                </div>
                <div class="progress-details">
                    <small class="progress-size">0 KB / 0 KB</small>
                    <small class="progress-speed">0 KB/s</small>
                </div>
            </div>
        </div>
    </div>

    <!-- General Progress Bar -->
    <div id="generalProgress" class="progress-overlay" style="display: none;">
        <div class="progress-overlay-content">
            <div class="progress-icon">
                <i class="fas fa-cog fa-spin"></i>
            </div>
            <h5 class="progress-title">처리 중...</h5>
            <div class="progress-bar-wrapper">
                <div class="progress-bar general-progress">
                    <div class="progress-fill" style="width: 0%"></div>
                    <div class="progress-stripes"></div>
                </div>
            </div>
            <div class="progress-percentage">0%</div>
            <p class="progress-message">잠시만 기다려 주세요...</p>
        </div>
    </div>

    <!-- Page Loading Progress -->
    <div id="pageLoadProgress" class="page-progress" style="display: none;">
        <div class="page-progress-bar">
            <div class="page-progress-fill"></div>
        </div>
    </div>
</div>

<style>
/* Progress Container */
.progress-container {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 9999;
    pointer-events: none;
}

.progress-container.show {
    pointer-events: auto;
}

/* Progress Modal (for file uploads) */
.progress-modal {
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background: white;
    border-radius: 20px;
    box-shadow: 0 25px 80px rgba(0, 0, 0, 0.3);
    border: 1px solid rgba(0, 0, 0, 0.1);
    min-width: 400px;
    max-width: 500px;
    z-index: 10001;
    pointer-events: auto;
}

.progress-modal-content {
    padding: 0;
}

.progress-header {
    padding: 1.5rem 1.5rem 1rem 1.5rem;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.progress-title {
    margin: 0;
    color: #1f2937;
    font-weight: 600;
    font-size: 1.1rem;
}

.progress-close {
    background: none;
    border: none;
    font-size: 1.2rem;
    color: #9ca3af;
    cursor: pointer;
    padding: 0.2rem;
    border-radius: 50%;
    transition: all 0.2s ease;
}

.progress-close:hover {
    background: #f3f4f6;
    color: #374151;
}

.progress-body {
    padding: 1rem 1.5rem 1.5rem 1.5rem;
}

.progress-info {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
}

.progress-filename {
    font-weight: 600;
    color: #374151;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex: 1;
    margin-right: 1rem;
}

.progress-percentage {
    font-weight: 700;
    color: #3b82f6;
    font-size: 1.1rem;
}

.progress-details {
    display: flex;
    justify-content: space-between;
    margin-top: 0.5rem;
    color: #6b7280;
}

/* Progress Overlay (for general operations) */
.progress-overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(5px);
    display: flex;
    justify-content: center;
    align-items: center;
    pointer-events: auto;
}

.progress-overlay-content {
    background: white;
    border-radius: 20px;
    padding: 2.5rem 2rem;
    box-shadow: 0 25px 80px rgba(0, 0, 0, 0.2);
    border: 1px solid rgba(0, 0, 0, 0.1);
    text-align: center;
    min-width: 300px;
}

.progress-icon {
    font-size: 2.5rem;
    color: #3b82f6;
    margin-bottom: 1rem;
}

.progress-message {
    color: #6b7280;
    margin: 0.5rem 0 0 0;
    font-size: 0.95rem;
}

/* Progress Bar Base Styles */
.progress-bar-wrapper {
    position: relative;
    margin: 1rem 0;
}

.progress-bar {
    width: 100%;
    height: 8px;
    background: #f3f4f6;
    border-radius: 10px;
    overflow: hidden;
    position: relative;
    box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.1);
}

.progress-fill {
    height: 100%;
    background: linear-gradient(135deg, #3b82f6, #1d4ed8);
    border-radius: 10px;
    transition: width 0.3s ease;
    position: relative;
    overflow: hidden;
}

/* Upload Progress Styles */
.upload-progress .progress-fill {
    background: linear-gradient(135deg, #22c55e, #16a34a);
}

.progress-glow {
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
    animation: glow 2s infinite;
}

@keyframes glow {
    0% {
        left: -100%;
    }
    100% {
        left: 100%;
    }
}

/* General Progress Styles */
.general-progress {
    height: 6px;
}

.general-progress .progress-fill {
    background: linear-gradient(135deg, #6366f1, #4f46e5);
}

.progress-stripes {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: repeating-linear-gradient(
        45deg,
        transparent,
        transparent 10px,
        rgba(255, 255, 255, 0.1) 10px,
        rgba(255, 255, 255, 0.1) 20px
    );
    animation: stripes 1s linear infinite;
}

@keyframes stripes {
    0% {
        background-position: 0 0;
    }
    100% {
        background-position: 20px 0;
    }
}

/* Page Loading Progress */
.page-progress {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 3px;
    z-index: 10002;
    pointer-events: none;
}

.page-progress-bar {
    width: 100%;
    height: 100%;
    background: #f3f4f6;
}

.page-progress-fill {
    height: 100%;
    width: 0%;
    background: linear-gradient(135deg, #f59e0b, #d97706);
    box-shadow: 0 0 10px rgba(245, 158, 11, 0.5);
    transition: width 0.3s ease;
    position: relative;
    overflow: hidden;
}

.page-progress-fill::after {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.6), transparent);
    animation: pageGlow 1.5s infinite;
}

@keyframes pageGlow {
    0% {
        left: -100%;
    }
    100% {
        left: 100%;
    }
}

/* Responsive */
@media (max-width: 768px) {
    .progress-modal {
        min-width: 320px;
        margin: 0 20px;
        max-width: calc(100% - 40px);
    }
    
    .progress-header,
    .progress-body {
        padding: 1rem;
    }
    
    .progress-overlay-content {
        margin: 0 20px;
        padding: 2rem 1.5rem;
        min-width: auto;
    }
    
    .progress-filename {
        font-size: 0.9rem;
    }
    
    .progress-details {
        font-size: 0.8rem;
    }
}

/* Animation Classes */
.progress-fade-in {
    animation: fadeIn 0.3s ease;
}

.progress-fade-out {
    animation: fadeOut 0.3s ease;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: scale(0.9);
    }
    to {
        opacity: 1;
        transform: scale(1);
    }
}

@keyframes fadeOut {
    from {
        opacity: 1;
        transform: scale(1);
    }
    to {
        opacity: 0;
        transform: scale(0.9);
    }
}

/* Success State */
.progress-success .progress-fill {
    background: linear-gradient(135deg, #22c55e, #16a34a);
}

.progress-success .progress-icon {
    color: #22c55e;
}

.progress-success .progress-percentage {
    color: #22c55e;
}

/* Error State */
.progress-error .progress-fill {
    background: linear-gradient(135deg, #ef4444, #dc2626);
}

.progress-error .progress-icon {
    color: #ef4444;
}

.progress-error .progress-percentage {
    color: #ef4444;
}
</style>

<script>
/**
 * 진행률 표시 관리자
 */
class ProgressManager {
    constructor() {
        this.container = document.getElementById('progressBarContainer');
        this.activeProgress = null;
        this.uploadStartTime = null;
        this.lastLoaded = 0;
    }

    /**
     * 파일 업로드 진행률 표시
     */
    showUploadProgress(filename = '파일 업로드') {
        const modal = document.getElementById('uploadProgress');
        const filenameEl = modal.querySelector('.progress-filename');
        const percentageEl = modal.querySelector('.progress-percentage');
        const fillEl = modal.querySelector('.progress-fill');
        const sizeEl = modal.querySelector('.progress-size');
        const speedEl = modal.querySelector('.progress-speed');

        filenameEl.textContent = filename;
        percentageEl.textContent = '0%';
        fillEl.style.width = '0%';
        sizeEl.textContent = '0 KB / 0 KB';
        speedEl.textContent = '0 KB/s';

        this.container.style.display = 'block';
        this.container.classList.add('show');
        modal.style.display = 'block';
        modal.classList.add('progress-fade-in');
        
        this.activeProgress = 'upload';
        this.uploadStartTime = Date.now();
        this.lastLoaded = 0;
    }

    /**
     * 업로드 진행률 업데이트
     */
    updateUploadProgress(loaded, total) {
        if (this.activeProgress !== 'upload') return;

        const modal = document.getElementById('uploadProgress');
        const percentage = Math.round((loaded / total) * 100);
        const percentageEl = modal.querySelector('.progress-percentage');
        const fillEl = modal.querySelector('.progress-fill');
        const sizeEl = modal.querySelector('.progress-size');
        const speedEl = modal.querySelector('.progress-speed');

        // 진행률 업데이트
        percentageEl.textContent = `${percentage}%`;
        fillEl.style.width = `${percentage}%`;

        // 파일 크기 정보
        const loadedMB = (loaded / (1024 * 1024)).toFixed(1);
        const totalMB = (total / (1024 * 1024)).toFixed(1);
        sizeEl.textContent = `${loadedMB} MB / ${totalMB} MB`;

        // 속도 계산
        const currentTime = Date.now();
        const timeDiff = (currentTime - this.uploadStartTime) / 1000;
        const speed = timeDiff > 0 ? (loaded / timeDiff) / 1024 : 0;
        speedEl.textContent = speed > 1024 ? 
            `${(speed / 1024).toFixed(1)} MB/s` : 
            `${speed.toFixed(0)} KB/s`;

        // 완료 처리
        if (percentage >= 100) {
            setTimeout(() => {
                modal.classList.add('progress-success');
                setTimeout(() => {
                    this.hideUploadProgress();
                }, 1500);
            }, 500);
        }
    }

    /**
     * 업로드 진행률 숨기기
     */
    hideUploadProgress() {
        const modal = document.getElementById('uploadProgress');
        modal.classList.add('progress-fade-out');
        
        setTimeout(() => {
            modal.style.display = 'none';
            modal.classList.remove('progress-fade-in', 'progress-fade-out', 'progress-success', 'progress-error');
            this.container.style.display = 'none';
            this.container.classList.remove('show');
            this.activeProgress = null;
        }, 300);
    }

    /**
     * 일반적인 진행률 표시
     */
    showProgress(title = '처리 중...', message = '잠시만 기다려 주세요...') {
        const overlay = document.getElementById('generalProgress');
        const titleEl = overlay.querySelector('.progress-title');
        const messageEl = overlay.querySelector('.progress-message');
        const fillEl = overlay.querySelector('.progress-fill');
        const percentageEl = overlay.querySelector('.progress-percentage');

        titleEl.textContent = title;
        messageEl.textContent = message;
        fillEl.style.width = '0%';
        percentageEl.textContent = '0%';

        this.container.style.display = 'block';
        this.container.classList.add('show');
        overlay.style.display = 'flex';
        overlay.classList.add('progress-fade-in');
        
        this.activeProgress = 'general';
    }

    /**
     * 일반 진행률 업데이트
     */
    updateProgress(percentage, message = null) {
        if (this.activeProgress !== 'general') return;

        const overlay = document.getElementById('generalProgress');
        const fillEl = overlay.querySelector('.progress-fill');
        const percentageEl = overlay.querySelector('.progress-percentage');
        const messageEl = overlay.querySelector('.progress-message');

        fillEl.style.width = `${percentage}%`;
        percentageEl.textContent = `${Math.round(percentage)}%`;
        
        if (message) {
            messageEl.textContent = message;
        }

        // 완료 처리
        if (percentage >= 100) {
            setTimeout(() => {
                overlay.classList.add('progress-success');
                setTimeout(() => {
                    this.hideProgress();
                }, 1000);
            }, 500);
        }
    }

    /**
     * 일반 진행률 숨기기
     */
    hideProgress() {
        const overlay = document.getElementById('generalProgress');
        overlay.classList.add('progress-fade-out');
        
        setTimeout(() => {
            overlay.style.display = 'none';
            overlay.classList.remove('progress-fade-in', 'progress-fade-out', 'progress-success', 'progress-error');
            this.container.style.display = 'none';
            this.container.classList.remove('show');
            this.activeProgress = null;
        }, 300);
    }

    /**
     * 페이지 로딩 진행률 표시
     */
    showPageProgress() {
        const pageProgress = document.getElementById('pageLoadProgress');
        const fillEl = pageProgress.querySelector('.page-progress-fill');
        
        fillEl.style.width = '0%';
        pageProgress.style.display = 'block';
        
        // 시뮬레이션된 로딩
        let progress = 0;
        const interval = setInterval(() => {
            progress += Math.random() * 20;
            if (progress > 90) progress = 90;
            
            fillEl.style.width = `${progress}%`;
            
            if (progress >= 90) {
                clearInterval(interval);
            }
        }, 200);

        return interval;
    }

    /**
     * 페이지 로딩 진행률 완료
     */
    completePageProgress() {
        const pageProgress = document.getElementById('pageLoadProgress');
        const fillEl = pageProgress.querySelector('.page-progress-fill');
        
        fillEl.style.width = '100%';
        
        setTimeout(() => {
            pageProgress.style.display = 'none';
            fillEl.style.width = '0%';
        }, 500);
    }

    /**
     * 에러 상태 표시
     */
    showError(message = '오류가 발생했습니다') {
        if (this.activeProgress === 'upload') {
            const modal = document.getElementById('uploadProgress');
            modal.classList.add('progress-error');
            modal.querySelector('.progress-message').textContent = message;
        } else if (this.activeProgress === 'general') {
            const overlay = document.getElementById('generalProgress');
            overlay.classList.add('progress-error');
            overlay.querySelector('.progress-message').textContent = message;
        }
    }
}

// 전역 인스턴스 생성
const progressManager = new ProgressManager();

// 편의 함수들
function showUploadProgress(filename) {
    return progressManager.showUploadProgress(filename);
}

function updateUploadProgress(loaded, total) {
    return progressManager.updateUploadProgress(loaded, total);
}

function hideUploadProgress() {
    return progressManager.hideUploadProgress();
}

function showProgress(title, message) {
    return progressManager.showProgress(title, message);
}

function updateProgress(percentage, message) {
    return progressManager.updateProgress(percentage, message);
}

function hideProgress() {
    return progressManager.hideProgress();
}

function showPageProgress() {
    return progressManager.showPageProgress();
}

function completePageProgress() {
    return progressManager.completePageProgress();
}

// 페이지 로드 시 자동 진행률 표시
document.addEventListener('DOMContentLoaded', function() {
    // 페이지 로딩 진행률 자동 표시
    const pageLoadInterval = showPageProgress();
    
    window.addEventListener('load', function() {
        clearInterval(pageLoadInterval);
        completePageProgress();
    });
});
</script>