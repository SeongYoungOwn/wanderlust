<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Loading Spinner Component --%>
<div id="loadingSpinner" class="loading-overlay" style="display: none;">
    <div class="loading-spinner">
        <div class="loading-container">
            <div class="spinner">
                <div class="spinner-ring"></div>
                <div class="spinner-ring"></div>
                <div class="spinner-ring"></div>
            </div>
            <div class="loading-text">
                <span class="loading-message">로딩 중...</span>
                <div class="loading-dots">
                    <span>.</span><span>.</span><span>.</span>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
/* Loading Spinner Styles */
.loading-overlay {
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
    z-index: 9999;
    transition: opacity 0.3s ease;
}

.loading-spinner {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

.loading-container {
    background: white;
    border-radius: 20px;
    padding: 2rem;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
    border: 1px solid rgba(102, 126, 234, 0.1);
    text-align: center;
    min-width: 200px;
}

.spinner {
    position: relative;
    width: 60px;
    height: 60px;
    margin: 0 auto 1.5rem auto;
}

.spinner-ring {
    position: absolute;
    width: 100%;
    height: 100%;
    border: 3px solid transparent;
    border-top: 3px solid #667eea;
    border-radius: 50%;
    animation: spin 1.2s linear infinite;
}

.spinner-ring:nth-child(1) {
    animation-delay: 0s;
    border-top-color: #667eea;
}

.spinner-ring:nth-child(2) {
    animation-delay: -0.4s;
    border-top-color: #764ba2;
    width: 80%;
    height: 80%;
    top: 10%;
    left: 10%;
}

.spinner-ring:nth-child(3) {
    animation-delay: -0.8s;
    border-top-color: #ff6b6b;
    width: 60%;
    height: 60%;
    top: 20%;
    left: 20%;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

.loading-text {
    color: #2d3748;
    font-weight: 600;
    font-size: 1rem;
}

.loading-message {
    display: block;
    margin-bottom: 0.5rem;
}

.loading-dots {
    display: inline-block;
    font-size: 1.5rem;
    font-weight: bold;
    color: #667eea;
}

.loading-dots span {
    animation: blink 1.4s linear infinite;
}

.loading-dots span:nth-child(1) {
    animation-delay: 0s;
}

.loading-dots span:nth-child(2) {
    animation-delay: 0.2s;
}

.loading-dots span:nth-child(3) {
    animation-delay: 0.4s;
}

@keyframes blink {
    0%, 80%, 100% {
        opacity: 0;
    }
    40% {
        opacity: 1;
    }
}

/* Responsive */
@media (max-width: 768px) {
    .loading-container {
        padding: 1.5rem;
        min-width: 150px;
    }
    
    .spinner {
        width: 50px;
        height: 50px;
    }
    
    .loading-text {
        font-size: 0.9rem;
    }
}
</style>