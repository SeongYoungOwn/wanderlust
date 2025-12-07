/**
 * 모바일 유틸리티 함수 및 반응형 최적화
 */

class MobileUtils {
    
    constructor() {
        this.isMobile = this.detectMobile();
        this.isTablet = this.detectTablet();
        this.touchDevice = this.detectTouch();
        
        this.init();
    }
    
    /**
     * 초기화
     */
    init() {
        this.setupViewport();
        this.setupNavigation();
        this.setupTouchEvents();
        this.setupResponsiveCharts();
        this.setupModalOptimization();
        
        // 디바이스 정보를 body 클래스에 추가
        document.body.classList.add(
            this.isMobile ? 'mobile-device' : 'desktop-device',
            this.touchDevice ? 'touch-device' : 'no-touch'
        );
    }
    
    /**
     * 모바일 디바이스 감지
     */
    detectMobile() {
        return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ||
               window.innerWidth <= 576;
    }
    
    /**
     * 태블릿 디바이스 감지
     */
    detectTablet() {
        return /iPad|Android/i.test(navigator.userAgent) && 
               window.innerWidth > 576 && window.innerWidth <= 768;
    }
    
    /**
     * 터치 디바이스 감지
     */
    detectTouch() {
        return 'ontouchstart' in window || navigator.maxTouchPoints > 0;
    }
    
    /**
     * 뷰포트 설정
     */
    setupViewport() {
        if (!document.querySelector('meta[name="viewport"]')) {
            const viewport = document.createElement('meta');
            viewport.name = 'viewport';
            viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.head.appendChild(viewport);
        }
    }
    
    /**
     * 네비게이션 설정
     */
    setupNavigation() {
        const toggle = document.querySelector('.navbar-toggle');
        const nav = document.querySelector('.navbar-nav');
        
        if (toggle && nav) {
            toggle.addEventListener('click', () => {
                nav.classList.toggle('active');
                this.animateToggle(toggle);
            });
            
            // 외부 클릭시 메뉴 닫기
            document.addEventListener('click', (e) => {
                if (!toggle.contains(e.target) && !nav.contains(e.target)) {
                    nav.classList.remove('active');
                    this.resetToggle(toggle);
                }
            });
        }
    }
    
    /**
     * 햄버거 메뉴 애니메이션
     */
    animateToggle(toggle) {
        const spans = toggle.querySelectorAll('span');
        if (toggle.classList.contains('active')) {
            spans[0].style.transform = 'rotate(-45deg) translate(-6px, 6px)';
            spans[1].style.opacity = '0';
            spans[2].style.transform = 'rotate(45deg) translate(-6px, -6px)';
        } else {
            this.resetToggle(toggle);
        }
        toggle.classList.toggle('active');
    }
    
    /**
     * 햨버거 메뉴 리셋
     */
    resetToggle(toggle) {
        const spans = toggle.querySelectorAll('span');
        spans[0].style.transform = 'none';
        spans[1].style.opacity = '1';
        spans[2].style.transform = 'none';
        toggle.classList.remove('active');
    }
    
    /**
     * 터치 이벤트 설정
     */
    setupTouchEvents() {
        if (!this.touchDevice) return;
        
        // 카드 터치 피드백
        document.querySelectorAll('.card').forEach(card => {
            card.addEventListener('touchstart', this.handleTouchStart.bind(this));
            card.addEventListener('touchend', this.handleTouchEnd.bind(this));
        });
        
        // 버튼 터치 피드백
        document.querySelectorAll('.btn').forEach(btn => {
            btn.addEventListener('touchstart', this.handleButtonTouchStart.bind(this));
            btn.addEventListener('touchend', this.handleButtonTouchEnd.bind(this));
        });
    }
    
    /**
     * 터치 시작 핸들러
     */
    handleTouchStart(e) {
        e.currentTarget.style.transform = 'scale(0.98)';
        e.currentTarget.style.transition = 'transform 0.1s ease';
    }
    
    /**
     * 터치 종료 핸들러
     */
    handleTouchEnd(e) {
        setTimeout(() => {
            e.currentTarget.style.transform = '';
            e.currentTarget.style.transition = '';
        }, 100);
    }
    
    /**
     * 버튼 터치 시작
     */
    handleButtonTouchStart(e) {
        e.currentTarget.style.opacity = '0.8';
    }
    
    /**
     * 버튼 터치 종료
     */
    handleButtonTouchEnd(e) {
        setTimeout(() => {
            e.currentTarget.style.opacity = '';
        }, 150);
    }
    
    /**
     * 반응형 차트 설정
     */
    setupResponsiveCharts() {
        // Chart.js 반응형 설정
        if (window.Chart) {
            Chart.defaults.responsive = true;
            Chart.defaults.maintainAspectRatio = false;
            
            // 모바일에서 차트 옵션 조정
            const originalDefaults = Chart.defaults;
            if (this.isMobile) {
                Chart.defaults.plugins = Chart.defaults.plugins || {};
                Chart.defaults.plugins.legend = Chart.defaults.plugins.legend || {};
                Chart.defaults.plugins.legend.position = 'bottom';
                Chart.defaults.plugins.legend.labels = Chart.defaults.plugins.legend.labels || {};
                Chart.defaults.plugins.legend.labels.boxWidth = 12;
                Chart.defaults.plugins.legend.labels.fontSize = 10;
            }
        }
        
        // 윈도우 리사이즈 이벤트
        window.addEventListener('resize', this.debounce(() => {
            this.handleResize();
        }, 250));
    }
    
    /**
     * 리사이즈 핸들러
     */
    handleResize() {
        // 디바이스 정보 업데이트
        this.isMobile = this.detectMobile();
        this.isTablet = this.detectTablet();
        
        // 차트 리사이즈
        if (window.Chart) {
            Chart.helpers.each(Chart.instances, (instance) => {
                instance.resize();
            });
        }
        
        // 커스텀 이벤트 발생
        window.dispatchEvent(new CustomEvent('mobileResize', {
            detail: {
                isMobile: this.isMobile,
                isTablet: this.isTablet,
                width: window.innerWidth,
                height: window.innerHeight
            }
        }));
    }
    
    /**
     * 모달 최적화
     */
    setupModalOptimization() {
        // 모달이 열릴 때 스크롤 방지
        document.addEventListener('modalOpen', () => {
            if (this.isMobile) {
                document.body.style.position = 'fixed';
                document.body.style.top = `-${window.scrollY}px`;
                document.body.style.width = '100%';
            }
        });
        
        // 모달이 닫힐 때 스크롤 복원
        document.addEventListener('modalClose', () => {
            if (this.isMobile) {
                const scrollY = document.body.style.top;
                document.body.style.position = '';
                document.body.style.top = '';
                document.body.style.width = '';
                window.scrollTo(0, parseInt(scrollY || '0') * -1);
            }
        });
    }
    
    /**
     * 디바운스 함수
     */
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
    
    /**
     * 부드러운 스크롤
     */
    smoothScrollTo(element, duration = 500) {
        const targetPosition = element.getBoundingClientRect().top + window.pageYOffset;
        const startPosition = window.pageYOffset;
        const distance = targetPosition - startPosition;
        let startTime = null;
        
        function animation(currentTime) {
            if (startTime === null) startTime = currentTime;
            const timeElapsed = currentTime - startTime;
            const run = this.easeInOutQuad(timeElapsed, startPosition, distance, duration);
            window.scrollTo(0, run);
            if (timeElapsed < duration) requestAnimationFrame(animation);
        }
        
        requestAnimationFrame(animation.bind(this));
    }
    
    /**
     * 이징 함수
     */
    easeInOutQuad(t, b, c, d) {
        t /= d / 2;
        if (t < 1) return c / 2 * t * t + b;
        t--;
        return -c / 2 * (t * (t - 2) - 1) + b;
    }
    
    /**
     * 로딩 스피너 표시
     */
    showLoading(element) {
        const spinner = document.createElement('div');
        spinner.className = 'loading-spinner';
        spinner.innerHTML = '<div class="spinner"></div>';
        
        element.appendChild(spinner);
        return spinner;
    }
    
    /**
     * 로딩 스피너 제거
     */
    hideLoading(spinner) {
        if (spinner && spinner.parentNode) {
            spinner.parentNode.removeChild(spinner);
        }
    }
    
    /**
     * 토스트 알림 표시
     */
    showToast(message, type = 'info', duration = 3000) {
        const toast = document.createElement('div');
        toast.className = `toast toast-${type}`;
        toast.innerHTML = `
            <div class="toast-content">
                <span class="toast-message">${message}</span>
                <button class="toast-close">&times;</button>
            </div>
        `;
        
        // 토스트 스타일
        Object.assign(toast.style, {
            position: 'fixed',
            top: this.isMobile ? '20px' : '80px',
            right: '20px',
            zIndex: '9999',
            padding: '15px 20px',
            borderRadius: '8px',
            color: 'white',
            fontSize: this.isMobile ? '14px' : '16px',
            maxWidth: this.isMobile ? 'calc(100vw - 40px)' : '400px',
            boxShadow: '0 4px 20px rgba(0, 0, 0, 0.3)',
            transform: 'translateX(100%)',
            transition: 'transform 0.3s ease'
        });
        
        // 타입별 색상
        const colors = {
            success: '#4CAF50',
            error: '#f44336',
            warning: '#FF9800',
            info: '#2196F3'
        };
        
        toast.style.background = colors[type] || colors.info;
        
        document.body.appendChild(toast);
        
        // 애니메이션
        setTimeout(() => {
            toast.style.transform = 'translateX(0)';
        }, 100);
        
        // 닫기 버튼
        const closeBtn = toast.querySelector('.toast-close');
        closeBtn.addEventListener('click', () => {
            this.hideToast(toast);
        });
        
        // 자동 제거
        if (duration > 0) {
            setTimeout(() => {
                this.hideToast(toast);
            }, duration);
        }
        
        return toast;
    }
    
    /**
     * 토스트 제거
     */
    hideToast(toast) {
        toast.style.transform = 'translateX(100%)';
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 300);
    }
    
    /**
     * 진동 피드백 (지원 기기에서)
     */
    vibrate(pattern = 100) {
        if ('vibrate' in navigator) {
            navigator.vibrate(pattern);
        }
    }
    
    /**
     * 네트워크 상태 확인
     */
    getNetworkInfo() {
        const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
        
        return {
            online: navigator.onLine,
            effectiveType: connection ? connection.effectiveType : 'unknown',
            downlink: connection ? connection.downlink : 'unknown',
            rtt: connection ? connection.rtt : 'unknown'
        };
    }
    
    /**
     * 배터리 정보 (지원 기기에서)
     */
    async getBatteryInfo() {
        if ('getBattery' in navigator) {
            try {
                const battery = await navigator.getBattery();
                return {
                    level: Math.round(battery.level * 100),
                    charging: battery.charging,
                    chargingTime: battery.chargingTime,
                    dischargingTime: battery.dischargingTime
                };
            } catch (e) {
                return null;
            }
        }
        return null;
    }
}

/**
 * 차트 반응형 헬퍼
 */
class ResponsiveChartHelper {
    
    static getResponsiveOptions(isMobile = false) {
        return {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: isMobile ? 'bottom' : 'top',
                    labels: {
                        boxWidth: isMobile ? 12 : 16,
                        fontSize: isMobile ? 10 : 12,
                        padding: isMobile ? 10 : 15
                    }
                },
                tooltip: {
                    mode: 'index',
                    intersect: false,
                    titleFont: {
                        size: isMobile ? 12 : 14
                    },
                    bodyFont: {
                        size: isMobile ? 10 : 12
                    }
                }
            },
            scales: {
                x: {
                    ticks: {
                        maxRotation: isMobile ? 45 : 0,
                        font: {
                            size: isMobile ? 10 : 12
                        }
                    }
                },
                y: {
                    ticks: {
                        font: {
                            size: isMobile ? 10 : 12
                        }
                    }
                }
            },
            interaction: {
                mode: 'nearest',
                axis: 'x',
                intersect: false
            }
        };
    }
    
    static createResponsiveChart(ctx, config, isMobile = false) {
        // 기본 옵션과 반응형 옵션 병합
        const responsiveOptions = this.getResponsiveOptions(isMobile);
        config.options = { ...config.options, ...responsiveOptions };
        
        return new Chart(ctx, config);
    }
}

// 전역 변수로 MobileUtils 인스턴스 생성
let mobileUtils;

// DOM이 로드되면 초기화
document.addEventListener('DOMContentLoaded', () => {
    mobileUtils = new MobileUtils();
    
    // 전역 객체에 추가 (다른 스크립트에서 사용 가능)
    window.MobileUtils = MobileUtils;
    window.ResponsiveChartHelper = ResponsiveChartHelper;
    window.mobileUtils = mobileUtils;
});

// CSS 로딩 확인 및 추가
function ensureMobileCSS() {
    if (!document.querySelector('link[href*="mobile-responsive.css"]')) {
        const link = document.createElement('link');
        link.rel = 'stylesheet';
        link.href = '/css/mobile-responsive.css';
        document.head.appendChild(link);
    }
}

// 즉시 CSS 로딩 확인
ensureMobileCSS();