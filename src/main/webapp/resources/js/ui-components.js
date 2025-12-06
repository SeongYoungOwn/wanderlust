/**
 * UI Components Integration JavaScript
 * This file provides easy-to-use functions for all UI components
 */

// UI 컴포넌트 헬퍼 함수들
const UIComponents = {
    
    /**
     * 로딩 스피너 관련 함수
     */
    loading: {
        show: function(message = '로딩 중...') {
            const spinner = document.getElementById('loadingSpinner');
            const messageEl = spinner.querySelector('.loading-message');
            if (messageEl) {
                messageEl.textContent = message;
            }
            spinner.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        },
        
        hide: function() {
            const spinner = document.getElementById('loadingSpinner');
            spinner.style.display = 'none';
            document.body.style.overflow = '';
        }
    },

    /**
     * 스켈레톤 스크린 관련 함수
     */
    skeleton: {
        showCard: function() {
            const skeleton = document.getElementById('skeletonScreen');
            const cardGrid = document.getElementById('skeletonCardGrid');
            const listView = document.getElementById('skeletonList');
            
            cardGrid.style.display = 'block';
            listView.style.display = 'none';
            skeleton.style.display = 'block';
        },
        
        showList: function() {
            const skeleton = document.getElementById('skeletonScreen');
            const cardGrid = document.getElementById('skeletonCardGrid');
            const listView = document.getElementById('skeletonList');
            
            cardGrid.style.display = 'none';
            listView.style.display = 'block';
            skeleton.style.display = 'block';
        },
        
        hide: function() {
            const skeleton = document.getElementById('skeletonScreen');
            skeleton.style.display = 'none';
        }
    },

    /**
     * Toast 메시지 관련 함수 (toast-messages.jsp에서 정의된 함수들 사용)
     */
    toast: {
        success: function(message, duration = 5000) {
            if (typeof showSuccessToast === 'function') {
                return showSuccessToast(message, duration);
            }
        },
        
        error: function(message, duration = 0) {
            if (typeof showErrorToast === 'function') {
                return showErrorToast(message, duration);
            }
        },
        
        warning: function(message, duration = 7000) {
            if (typeof showWarningToast === 'function') {
                return showWarningToast(message, duration);
            }
        },
        
        info: function(message, duration = 5000) {
            if (typeof showInfoToast === 'function') {
                return showInfoToast(message, duration);
            }
        },
        
        show: function(message, type = 'info', duration = 5000) {
            if (typeof showToast === 'function') {
                return showToast(message, type, duration);
            }
        }
    },

    /**
     * 진행률 표시 관련 함수 (progress-bar.jsp에서 정의된 함수들 사용)
     */
    progress: {
        showUpload: function(filename) {
            if (typeof showUploadProgress === 'function') {
                return showUploadProgress(filename);
            }
        },
        
        updateUpload: function(loaded, total) {
            if (typeof updateUploadProgress === 'function') {
                return updateUploadProgress(loaded, total);
            }
        },
        
        hideUpload: function() {
            if (typeof hideUploadProgress === 'function') {
                return hideUploadProgress();
            }
        },
        
        show: function(title, message) {
            if (typeof showProgress === 'function') {
                return showProgress(title, message);
            }
        },
        
        update: function(percentage, message) {
            if (typeof updateProgress === 'function') {
                return updateProgress(percentage, message);
            }
        },
        
        hide: function() {
            if (typeof hideProgress === 'function') {
                return hideProgress();
            }
        },
        
        showPage: function() {
            if (typeof showPageProgress === 'function') {
                return showPageProgress();
            }
        },
        
        completePage: function() {
            if (typeof completePageProgress === 'function') {
                return completePageProgress();
            }
        }
    },

    /**
     * AJAX 요청 헬퍼 함수
     */
    ajax: {
        /**
         * GET 요청
         */
        get: function(url, options = {}) {
            return this.request(url, { ...options, method: 'GET' });
        },

        /**
         * POST 요청
         */
        post: function(url, data, options = {}) {
            return this.request(url, { 
                ...options, 
                method: 'POST', 
                data: data,
                headers: {
                    'Content-Type': 'application/json',
                    ...options.headers
                }
            });
        },

        /**
         * 파일 업로드
         */
        upload: function(url, formData, options = {}) {
            const defaultOptions = {
                method: 'POST',
                showProgress: true,
                progressCallback: null,
                ...options
            };

            return new Promise((resolve, reject) => {
                const xhr = new XMLHttpRequest();
                
                if (defaultOptions.showProgress) {
                    UIComponents.progress.showUpload(
                        formData.get('file') ? formData.get('file').name : '파일 업로드'
                    );
                }

                xhr.upload.addEventListener('progress', function(e) {
                    if (e.lengthComputable) {
                        if (defaultOptions.showProgress) {
                            UIComponents.progress.updateUpload(e.loaded, e.total);
                        }
                        if (defaultOptions.progressCallback) {
                            defaultOptions.progressCallback(e.loaded, e.total);
                        }
                    }
                });

                xhr.addEventListener('load', function() {
                    if (defaultOptions.showProgress) {
                        UIComponents.progress.hideUpload();
                    }
                    
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            resolve(response);
                        } catch (e) {
                            resolve(xhr.responseText);
                        }
                    } else {
                        reject(new Error(`HTTP ${xhr.status}: ${xhr.statusText}`));
                    }
                });

                xhr.addEventListener('error', function() {
                    if (defaultOptions.showProgress) {
                        UIComponents.progress.hideUpload();
                    }
                    reject(new Error('네트워크 오류가 발생했습니다.'));
                });

                xhr.open(defaultOptions.method, url);
                xhr.send(formData);
            });
        },

        /**
         * 기본 AJAX 요청
         */
        request: function(url, options = {}) {
            const defaultOptions = {
                method: 'GET',
                headers: {},
                showLoading: false,
                showSkeleton: false,
                timeout: 10000,
                ...options
            };

            return new Promise((resolve, reject) => {
                const xhr = new XMLHttpRequest();
                const timeout = setTimeout(() => {
                    xhr.abort();
                    reject(new Error('요청 시간이 초과되었습니다.'));
                }, defaultOptions.timeout);

                if (defaultOptions.showLoading) {
                    UIComponents.loading.show('데이터를 불러오는 중...');
                }
                
                if (defaultOptions.showSkeleton) {
                    UIComponents.skeleton.showCard();
                }

                xhr.addEventListener('load', function() {
                    clearTimeout(timeout);
                    
                    if (defaultOptions.showLoading) {
                        UIComponents.loading.hide();
                    }
                    
                    if (defaultOptions.showSkeleton) {
                        UIComponents.skeleton.hide();
                    }
                    
                    if (xhr.status >= 200 && xhr.status < 300) {
                        try {
                            const response = JSON.parse(xhr.responseText);
                            resolve(response);
                        } catch (e) {
                            resolve(xhr.responseText);
                        }
                    } else {
                        reject(new Error(`HTTP ${xhr.status}: ${xhr.statusText}`));
                    }
                });

                xhr.addEventListener('error', function() {
                    clearTimeout(timeout);
                    
                    if (defaultOptions.showLoading) {
                        UIComponents.loading.hide();
                    }
                    
                    if (defaultOptions.showSkeleton) {
                        UIComponents.skeleton.hide();
                    }
                    
                    reject(new Error('네트워크 오류가 발생했습니다.'));
                });

                xhr.open(defaultOptions.method, url);

                // 헤더 설정
                Object.keys(defaultOptions.headers).forEach(key => {
                    xhr.setRequestHeader(key, defaultOptions.headers[key]);
                });

                // 데이터 전송
                if (defaultOptions.data) {
                    if (defaultOptions.headers['Content-Type'] === 'application/json') {
                        xhr.send(JSON.stringify(defaultOptions.data));
                    } else {
                        xhr.send(defaultOptions.data);
                    }
                } else {
                    xhr.send();
                }
            });
        }
    },

    /**
     * 폼 검증 헬퍼
     */
    validation: {
        /**
         * 필수 입력 검증
         */
        required: function(value, fieldName) {
            if (!value || value.trim() === '') {
                UIComponents.toast.warning(`${fieldName}는 필수 입력 항목입니다.`);
                return false;
            }
            return true;
        },

        /**
         * 이메일 검증
         */
        email: function(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                UIComponents.toast.warning('올바른 이메일 주소를 입력해주세요.');
                return false;
            }
            return true;
        },

        /**
         * 파일 크기 검증
         */
        fileSize: function(file, maxSizeMB) {
            const maxSizeBytes = maxSizeMB * 1024 * 1024;
            if (file.size > maxSizeBytes) {
                UIComponents.toast.warning(`파일 크기는 ${maxSizeMB}MB를 초과할 수 없습니다.`);
                return false;
            }
            return true;
        },

        /**
         * 파일 확장자 검증
         */
        fileExtension: function(file, allowedExtensions) {
            const extension = file.name.split('.').pop().toLowerCase();
            if (!allowedExtensions.includes(extension)) {
                UIComponents.toast.warning(`허용되지 않는 파일 형식입니다. (허용: ${allowedExtensions.join(', ')})`);
                return false;
            }
            return true;
        }
    },

    /**
     * 유틸리티 함수들
     */
    utils: {
        /**
         * 페이지 새로고침 (로딩 표시와 함께)
         */
        refreshPage: function() {
            UIComponents.loading.show('페이지를 새로고침하는 중...');
            window.location.reload();
        },

        /**
         * 페이지 이동 (로딩 표시와 함께)
         */
        navigateTo: function(url) {
            UIComponents.loading.show('페이지를 이동하는 중...');
            window.location.href = url;
        },

        /**
         * 클립보드에 복사
         */
        copyToClipboard: function(text) {
            navigator.clipboard.writeText(text).then(function() {
                UIComponents.toast.success('클립보드에 복사되었습니다.');
            }).catch(function() {
                UIComponents.toast.error('복사에 실패했습니다.');
            });
        },

        /**
         * 숫자 포맷팅 (천 단위 콤마)
         */
        formatNumber: function(number) {
            return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
        },

        /**
         * 날짜 포맷팅
         */
        formatDate: function(date, format = 'YYYY.MM.DD') {
            const d = new Date(date);
            const year = d.getFullYear();
            const month = String(d.getMonth() + 1).padStart(2, '0');
            const day = String(d.getDate()).padStart(2, '0');
            const hour = String(d.getHours()).padStart(2, '0');
            const minute = String(d.getMinutes()).padStart(2, '0');

            return format
                .replace('YYYY', year)
                .replace('MM', month)
                .replace('DD', day)
                .replace('HH', hour)
                .replace('mm', minute);
        },

        /**
         * 디바운스 함수
         */
        debounce: function(func, wait, immediate) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => {
                    timeout = null;
                    if (!immediate) func(...args);
                };
                const callNow = immediate && !timeout;
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
                if (callNow) func(...args);
            };
        }
    }
};

// 전역 변수로 노출
window.UIComponents = UIComponents;

// jQuery가 있으면 jQuery 플러그인으로도 등록
if (typeof jQuery !== 'undefined') {
    jQuery.fn.extend({
        showLoading: function(message) {
            UIComponents.loading.show(message);
            return this;
        },
        
        hideLoading: function() {
            UIComponents.loading.hide();
            return this;
        },
        
        showToast: function(message, type, duration) {
            UIComponents.toast.show(message, type, duration);
            return this;
        }
    });
}

// 페이지 로드 완료 이벤트
document.addEventListener('DOMContentLoaded', function() {
    // 페이지 로드 진행률 완료
    if (typeof completePageProgress === 'function') {
        completePageProgress();
    }
    
    // 전역 오류 처리
    window.addEventListener('error', function(e) {
        console.error('JavaScript Error:', e.error);
        UIComponents.toast.error('페이지에서 오류가 발생했습니다.');
    });
    
    // AJAX 오류 처리 (jQuery가 있는 경우)
    if (typeof jQuery !== 'undefined') {
        jQuery(document).ajaxError(function(event, xhr, settings) {
            console.error('AJAX Error:', xhr.status, xhr.statusText);
            if (xhr.status === 401) {
                UIComponents.toast.warning('로그인이 필요합니다.');
            } else if (xhr.status === 403) {
                UIComponents.toast.error('접근 권한이 없습니다.');
            } else if (xhr.status === 500) {
                UIComponents.toast.error('서버 오류가 발생했습니다.');
            } else {
                UIComponents.toast.error('요청 처리 중 오류가 발생했습니다.');
            }
        });
    }
});

// 브라우저 뒤로가기/앞으로가기 감지
window.addEventListener('popstate', function(e) {
    UIComponents.loading.show('페이지를 로딩하는 중...');
});

// 페이지 언로드 시 로딩 숨김
window.addEventListener('beforeunload', function(e) {
    UIComponents.loading.hide();
    UIComponents.skeleton.hide();
});