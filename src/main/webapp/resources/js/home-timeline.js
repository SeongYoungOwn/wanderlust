// Timeline data - Exact copy from 타임라인.html
const events = [
    {
        year: "Step 1",
        title: "회원가입 & MBTI 설정",
        subtitle: "시작하기",
        description: "로그인 및 회원가입을 하고 여행 MBTI 테스트를 통해 당신의 여행 성향을 설정하세요."
    },
    {
        year: "Step 2",
        title: "AI 추천 서비스 이용",
        subtitle: "맞춤 추천",
        description: "매칭 시작을 눌러 동반자 추천을 받거나 여행계획, 준비물, 음악 등 AI 추천을 받아보세요."
    },
    {
        year: "Step 3",
        title: "여행계획 등록",
        subtitle: "계획 공유",
        description: "나만의 여행계획을 등록하고 동행을 원하는 여행자들과 연결되세요."
    },
    {
        year: "Step 4",
        title: "동행자 매칭 & 채팅",
        subtitle: "소통하기",
        description: "매칭된 동행자와 채팅을 통해 세부 계획을 조율하고 여행 준비를 함께 하세요."
    },
    {
        year: "Step 5",
        title: "여행 완료 & 평가",
        subtitle: "신뢰도 구축",
        description: "즐거운 여행을 마친 후 서로의 매너를 평가하여 신뢰도를 쌓고 더 좋은 매칭을 받으세요."
    }
];

// Generate timeline events - Exact copy from 타임라인.html
function generateTimelineEvents() {
    const container = document.getElementById('timelineEvents');

    events.forEach((event, index) => {
        const eventElement = document.createElement('div');
        eventElement.className = 'timeline-event';
        eventElement.innerHTML =
            '<div class="timeline-dot" data-index="' + index + '"></div>' +
            '<div class="timeline-card parallax" data-index="' + index + '">' +
                '<div class="timeline-date">' +
                    '<svg class="timeline-icon" fill="currentColor" viewBox="0 0 20 20">' +
                        '<path d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zM4 8h12v8H4V8z"/>' +
                    '</svg>' +
                    event.year +
                '</div>' +
                '<h3 class="timeline-card-title">' + event.title + '</h3>' +
                '<p class="timeline-card-subtitle">' + event.subtitle + '</p>' +
                '<p class="timeline-card-description">' + event.description + '</p>' +
            '</div>';
        container.appendChild(eventElement);
    });
}

// Scroll progress functionality - Section-aware version
function updateScrollProgress() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    const windowHeight = window.innerHeight;

    // Get the ai-features section
    const aiSection = document.getElementById('ai-features');
    if (!aiSection) return;

    const timelineContent = document.querySelector('#ai-features .timeline-content');
    if (!timelineContent) return;

    // Get section boundaries
    const sectionRect = aiSection.getBoundingClientRect();
    const sectionTop = aiSection.offsetTop;
    const sectionHeight = aiSection.offsetHeight;

    // Calculate scroll progress for this section
    // Start when section enters viewport, end when it leaves
    const scrollStart = sectionTop - windowHeight;
    const scrollEnd = sectionTop + sectionHeight;
    const scrollRange = scrollEnd - scrollStart;

    // Calculate progress (0 to 1)
    let scrollProgress = (scrollTop - scrollStart) / scrollRange;
    scrollProgress = Math.max(0, Math.min(1, scrollProgress));

    // Update progress line
    const progressLine = document.getElementById('progressLine');
    const contentHeight = timelineContent.offsetHeight;
    if (progressLine) {
        progressLine.style.height = (scrollProgress * contentHeight) + 'px';
    }

    // Update comet position
    const comet = document.getElementById('comet');
    if (comet) {
        comet.style.top = (scrollProgress * contentHeight) + 'px';
    }

    // Update active dots
    const dots = document.querySelectorAll('#ai-features .timeline-dot');
    const activeIndex = Math.floor(scrollProgress * events.length);

    dots.forEach((dot, index) => {
        if (index <= activeIndex) {
            dot.classList.add('active');
            dot.style.borderColor = 'var(--primary)';
            dot.style.backgroundColor = 'var(--background)';
        } else {
            dot.classList.remove('active');
            dot.style.borderColor = 'var(--border)';
            dot.style.backgroundColor = 'var(--card-bg)';
        }
    });

    // Parallax effect for cards
    const cards = document.querySelectorAll('#ai-features .timeline-card');
    cards.forEach((card, index) => {
        const rect = card.getBoundingClientRect();
        const centerY = windowHeight / 2;
        const cardCenterY = rect.top + rect.height / 2;
        const distance = (cardCenterY - centerY) / windowHeight;
        const parallaxOffset = distance * 20; // Adjust intensity
        card.style.transform = 'translateY(' + parallaxOffset + 'px)';
    });
}

// Smooth scroll behavior - Exact copy from 타임라인.html
function smoothScroll() {
    let ticking = false;

    function requestTick() {
        if (!ticking) {
            window.requestAnimationFrame(updateScrollProgress);
            ticking = true;
            setTimeout(() => { ticking = false; }, 100);
        }
    }

    window.addEventListener('scroll', requestTick);
}

// Initialize - Exact copy from 타임라인.html
document.addEventListener('DOMContentLoaded', () => {
    // generateTimelineEvents(); // 정적으로 이미 추가했으므로 비활성화
    updateScrollProgress();
    smoothScroll();

    // Intersection Observer for fade-in animations
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, {
        threshold: 0.1
    });

    document.querySelectorAll('.fade-in-up').forEach(el => {
        observer.observe(el);
    });
});

// Update on resize - Exact copy from 타임라인.html
window.addEventListener('resize', updateScrollProgress);