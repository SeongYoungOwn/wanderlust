/**
 * 게시판 좋아요/싫어요 기능 개선 스크립트
 * - 중복 클릭 방지
 * - 버튼 비활성화 처리
 * 작성일: 2025-10-21
 */

// 중복 클릭 방지를 위한 플래그
let isLikeProcessing = false;
let isDislikeProcessing = false;

/**
 * 좋아요 토글 (중복 클릭 방지 적용)
 */
function toggleLikeFixed(boardId, contextPath) {
    // 이미 처리 중이면 무시
    if (isLikeProcessing) {
        console.log('좋아요 처리 중...');
        return;
    }

    isLikeProcessing = true;
    const likeBtn = document.getElementById('likeBtn');

    // 버튼 비활성화
    if (likeBtn) {
        likeBtn.disabled = true;
        likeBtn.style.opacity = '0.6';
    }

    fetch(contextPath + '/like/toggle', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'boardId=' + boardId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateLikeButton(data.isLiked, data.likeCount);
            updateDislikeButton(data.isDisliked, data.dislikeCount);

            // 헤더의 좋아요 카운트도 업데이트
            const likeCountHeader = document.getElementById('likeCountHeader');
            if (likeCountHeader) {
                likeCountHeader.textContent = data.likeCount;
            }
        } else {
            alert(data.message || '좋아요 처리 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('좋아요 처리 오류:', error);
        alert('좋아요 처리 중 오류가 발생했습니다.');
    })
    .finally(() => {
        // 처리 완료 후 다시 활성화 (300ms 딜레이)
        setTimeout(() => {
            isLikeProcessing = false;
            if (likeBtn) {
                likeBtn.disabled = false;
                likeBtn.style.opacity = '1';
            }
        }, 300);
    });
}

/**
 * 싫어요 토글 (중복 클릭 방지 적용)
 */
function toggleDislikeFixed(boardId, contextPath) {
    // 이미 처리 중이면 무시
    if (isDislikeProcessing) {
        console.log('싫어요 처리 중...');
        return;
    }

    isDislikeProcessing = true;
    const dislikeBtn = document.getElementById('dislikeBtn');

    // 버튼 비활성화
    if (dislikeBtn) {
        dislikeBtn.disabled = true;
        dislikeBtn.style.opacity = '0.6';
    }

    fetch(contextPath + '/like/dislike/toggle', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'boardId=' + boardId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            updateLikeButton(data.isLiked, data.likeCount);
            updateDislikeButton(data.isDisliked, data.dislikeCount);

            // 헤더의 좋아요 카운트도 업데이트
            const likeCountHeader = document.getElementById('likeCountHeader');
            if (likeCountHeader) {
                likeCountHeader.textContent = data.likeCount;
            }
        } else {
            alert(data.message || '싫어요 처리 중 오류가 발생했습니다.');
        }
    })
    .catch(error => {
        console.error('싫어요 처리 오류:', error);
        alert('싫어요 처리 중 오류가 발생했습니다.');
    })
    .finally(() => {
        // 처리 완료 후 다시 활성화 (300ms 딜레이)
        setTimeout(() => {
            isDislikeProcessing = false;
            if (dislikeBtn) {
                dislikeBtn.disabled = false;
                dislikeBtn.style.opacity = '1';
            }
        }, 300);
    });
}

/**
 * 좋아요 버튼 UI 업데이트
 */
function updateLikeButton(isLiked, likeCount) {
    const likeBtn = document.getElementById('likeBtn');
    const likeBtnCount = document.getElementById('likeBtnCount');

    if (likeBtn) {
        if (isLiked) {
            likeBtn.classList.add('btn-like-active');
            likeBtn.classList.remove('btn-outline-danger');
        } else {
            likeBtn.classList.remove('btn-like-active');
            likeBtn.classList.add('btn-outline-danger');
        }
    }

    if (likeBtnCount) {
        likeBtnCount.textContent = likeCount;
    }
}

/**
 * 싫어요 버튼 UI 업데이트
 */
function updateDislikeButton(isDisliked, dislikeCount) {
    const dislikeBtn = document.getElementById('dislikeBtn');
    const dislikeBtnCount = document.getElementById('dislikeBtnCount');

    if (dislikeBtn) {
        if (isDisliked) {
            dislikeBtn.classList.add('btn-dislike-active');
            dislikeBtn.classList.remove('btn-outline-warning');
        } else {
            dislikeBtn.classList.remove('btn-dislike-active');
            dislikeBtn.classList.add('btn-outline-warning');
        }
    }

    if (dislikeBtnCount) {
        dislikeBtnCount.textContent = dislikeCount;
    }
}

console.log('좋아요/싫어요 중복 클릭 방지 스크립트 로드됨');
