/**
 * MBTI 매칭 프로필 이미지 경로 수정 스크립트
 * 작성일: 2025-10-21
 * 목적: /uploads/profile/ 경로를 /resources/uploads/profile/로 변환
 */

/**
 * 프로필 이미지 경로를 올바르게 변환하는 함수
 * @param {string} profileImage - 원본 프로필 이미지 경로
 * @param {string} contextPath - 컨텍스트 경로 (예: '' 또는 '/myapp')
 * @returns {string} 수정된 프로필 이미지 경로
 */
function fixProfileImagePath(profileImage, contextPath) {
    if (!profileImage || profileImage.trim() === '') {
        return '';
    }

    // 이미 http로 시작하는 절대 경로면 그대로 반환
    if (profileImage.startsWith('http://') || profileImage.startsWith('https://')) {
        return profileImage;
    }

    // 이미 contextPath가 포함되어 있으면 그대로 반환
    if (profileImage.startsWith(contextPath + '/resources/')) {
        return profileImage;
    }

    // /uploads/로 시작하면 /resources 추가
    if (profileImage.startsWith('/uploads/')) {
        return contextPath + '/resources' + profileImage;
    }

    // uploads/로 시작하면 (앞에 / 없음) /resources/ 추가
    if (profileImage.startsWith('uploads/')) {
        return contextPath + '/resources/' + profileImage;
    }

    // 기타 경로는 그대로 contextPath만 추가
    return contextPath + profileImage;
}

/**
 * 이미지 로드 실패 시 기본 아바타로 대체
 * @param {HTMLElement} imgElement - img 엘리먼트
 * @param {string} userName - 사용자 이름
 */
function handleImageError(imgElement, userName) {
    if (imgElement && userName) {
        // 이미지를 텍스트로 교체
        const firstLetter = userName.charAt(0).toUpperCase();
        imgElement.parentElement.innerHTML = firstLetter;
        imgElement.parentElement.style.fontSize = '2rem';
        imgElement.parentElement.style.fontWeight = 'bold';
    }
}

console.log('MBTI 매칭 프로필 이미지 경로 수정 스크립트 로드됨');
