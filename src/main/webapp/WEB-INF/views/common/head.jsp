<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<!-- Bootstrap 5 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- Font Awesome -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Bootstrap 5 JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.js"></script>

<!-- 공통 CSS 변수 -->
<style>
:root {
    /* Light theme colors */
    --bg-primary: #fdfbf7;
    --bg-secondary: #ffffff;
    --bg-card: #ffffff;
    --bg-header-gradient: linear-gradient(135deg, #ff6b6b 0%, #4ecdc4 100%);
    --text-primary: #1f2937;
    --text-secondary: #6b7280;
    --text-muted: #9ca3af;
    --accent-primary: #ff6b6b;
    --accent-secondary: #4ecdc4;
    --border-color: #e5e7eb;
    --shadow-sm: rgba(0, 0, 0, 0.05);
    --shadow-md: rgba(0, 0, 0, 0.1);
    --shadow-lg: rgba(0, 0, 0, 0.15);
}
</style>

<!-- 욕설 필터링 JavaScript -->
<script>
// 욕설 리스트 (JavaScript용)
const profanityList = [
    // 일반적인 욕설
    '시발', '시팔', '씨발', '씨팔', '시바', '씨바', 
    '개새끼', '개색끼', '개새키', '개색키',
    '병신', '병딱', '븅신', '븅딱',
    '새끼', '색끼', '새키', '색키',
    '지랄', '지럴', '지롤',
    '꺼져', '꺼저', '꺼졍',
    '엿먹어', '엿머거', '엿먹엇',
    '좆', '좇', '촛',
    '닥쳐', '닥쵸', '닥처',
    '미친', '미쳤', '미침',
    '바보', '멍청이', '등신',
    '죽어', '죽어라', '뒤져', '뒈져',
    '꼴값', '꼴통',
    
    // 변형된 표현들
    'ㅅㅂ', 'ㅆㅂ', 'ㅅㅂㄹㅁ',
    'ㅂㅅ', 'ㅂㅇㅅ',
    'ㄱㅅㅋ', 'ㄱㅅㄲ',
    'ㅈㄹ', 'ㅈㄹㄹ',
    'ㅁㅊ', 'ㅁㅊㄴ',
    
    // 특수문자로 변형된 표현
    's!발', '시8',
    '개색끼',
    '병신',
    '새끼',
    
    // 영어 욕설
    'fuck', 'shit', 'damn', 'bitch', 'asshole',
    'stupid', 'idiot', 'moron',
    
    // 기타 부적절한 표현
    '똥', '오줌', '방귀',
    '죽음', '자살', '살인'
];

// 문자 치환 매핑
const charSubstitutions = {
    '0': 'o', '3': 'e', '4': 'a', '5': 's', '7': 't', '8': 'b',
    '@': 'a', '!': 'i', '$': 's', '-': '', '_': '', ' ': ''
};

// 텍스트 정규화
function normalizeText(text) {
    let normalized = text.toLowerCase().replace(/\s+/g, '');
    // * 문자 먼저 제거
    normalized = normalized.replace(/\*/g, '');

    for (let [key, value] of Object.entries(charSubstitutions)) {
        // 특수문자를 이스케이프 처리
        const escapedKey = key.replace(/[\\^$.*+?()[\]{}|]/g, '\\$&');
        normalized = normalized.replace(new RegExp(escapedKey, 'g'), value);
    }
    return normalized;
}

// 욕설 검사 함수
function containsProfanity(text) {
    if (!text || text.trim() === '') return false;
    
    const cleanText = text.toLowerCase().replace(/\s+/g, '');
    const normalizedText = normalizeText(text);
    
    // 직접 매칭 검사
    for (let profanity of profanityList) {
        if (cleanText.includes(profanity.toLowerCase()) || 
            normalizedText.includes(profanity.toLowerCase())) {
            return true;
        }
    }
    
    // 패턴 매칭 (최소 2글자 이상만 체크)
    if (normalizedText.length >= 2) {
        if (/(시|씨)[8bㅂㅃ팔발바빨]+/.test(normalizedText)) return true;
        if (/(병|븅)[신딱ㅅㅄ]+/.test(normalizedText)) return true;
        if (/개[새색]+[끼키ㅋㅇ]+/.test(normalizedText)) return true;
    }

    return false;
}

// 경고 메시지 표시
function showProfanityWarning() {
    // Bootstrap Alert 사용
    const alertHtml =
        '<div class="alert alert-danger alert-dismissible fade show position-fixed" ' +
             'style="top: 80px; right: 20px; z-index: 9999; min-width: 300px;" role="alert">' +
            '<i class="fas fa-exclamation-triangle me-2"></i>' +
            '<strong>욕설 경고!</strong> 욕설을 입력하셨습니다. 다시 입력해주세요.' +
            '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
        '</div>';
    
    // 기존 경고 제거
    $('.alert-danger').remove();
    
    // 새 경고 추가
    $('body').append(alertHtml);
    
    // 5초 후 자동 제거
    setTimeout(() => {
        $('.alert-danger').fadeOut();
    }, 5000);
}

// DOM 로드 완료 후 실행
$(document).ready(function() {
    // 모든 텍스트 입력 필드에 실시간 검사 적용
    $(document).on('input', 'input[type="text"], textarea', function() {
        const text = $(this).val();
        const $element = $(this);
        
        if (containsProfanity(text)) {
            // 욕설 감지 시 스타일 변경
            $element.addClass('border-danger');
            $element.removeClass('border-success');
            
            // 툴팁으로 경고 표시
            $element.attr('title', '욕설이 감지되었습니다');
            
            // 경고 메시지 표시 (너무 자주 뜨지 않도록 제한)
            if (!$element.data('warning-shown')) {
                showProfanityWarning();
                $element.data('warning-shown', true);
                
                // 3초 후 다시 경고 가능하도록 설정
                setTimeout(() => {
                    $element.removeData('warning-shown');
                }, 3000);
            }
        } else {
            // 정상 텍스트일 때 스타일 복원
            $element.removeClass('border-danger');
            $element.addClass('border-success');
            $element.removeAttr('title');
        }
    });
    
    // 폼 제출 시 최종 검사
    $(document).on('submit', 'form', function(e) {
        let hasProfanity = false;
        
        $(this).find('input[type="text"], textarea').each(function() {
            const text = $(this).val();
            if (containsProfanity(text)) {
                hasProfanity = true;
                $(this).addClass('border-danger').focus();
                return false; // 첫 번째 욕설 필드에서 중단
            }
        });
        
        if (hasProfanity) {
            e.preventDefault();
            showProfanityWarning();
            return false;
        }
    });
});
</script>