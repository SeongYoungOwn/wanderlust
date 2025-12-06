// 트렌드 분석 차트 JavaScript
// 차트 인스턴스 저장소
let trendScoreChart = null;
let categoryChart = null;

// 차트 생성 함수
function createTrendCharts(data) {
    console.log('차트 생성 시작:', data);
    
    // 기존 차트 삭제
    destroyExistingCharts();
    
    // 트렌드 점수 차트 생성
    createTrendScoreChart(data);
    
    // 카테고리별 인기도 차트 생성
    createCategoryChart(data);
}

// 기존 차트 삭제
function destroyExistingCharts() {
    if (trendScoreChart) {
        trendScoreChart.destroy();
        trendScoreChart = null;
    }
    if (categoryChart) {
        categoryChart.destroy();
        categoryChart = null;
    }
}

// 트렌드 점수 비교 차트 (막대 차트)
function createTrendScoreChart(data) {
    const canvas = document.getElementById('trendScoreChart');
    if (!canvas) {
        console.warn('trendScoreChart 캔버스를 찾을 수 없습니다.');
        return;
    }

    const ctx = canvas.getContext('2d');
    
    // 데이터 준비
    const keywords = data.trendingKeywords || [];
    const destinations = data.popularDestinations || [];
    
    const allItems = [
        ...keywords.map(k => ({ name: k.keyword, score: k.trendScore, type: '키워드' })),
        ...destinations.map(d => ({ name: d.destinationName, score: d.trendScore, type: '여행지' }))
    ].sort((a, b) => b.score - a.score).slice(0, 8); // 상위 8개만 표시

    const labels = allItems.map(item => item.name);
    const scores = allItems.map(item => item.score);
    const colors = allItems.map(item => 
        item.type === '키워드' ? 'rgba(102, 126, 234, 0.8)' : 'rgba(236, 72, 153, 0.8)'
    );

    trendScoreChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: '트렌드 점수',
                data: scores,
                backgroundColor: colors,
                borderColor: colors.map(color => color.replace('0.8', '1')),
                borderWidth: 2,
                borderRadius: 8,
                borderSkipped: false,
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    borderColor: 'rgba(102, 126, 234, 0.3)',
                    borderWidth: 1,
                    cornerRadius: 8,
                    callbacks: {
                        label: function(context) {
                            const item = allItems[context.dataIndex];
                            return `${item.type}: ${context.parsed.y.toFixed(1)}점`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    max: 10,
                    grid: {
                        color: 'rgba(0, 0, 0, 0.1)',
                    },
                    ticks: {
                        callback: function(value) {
                            return value.toFixed(1) + '점';
                        }
                    }
                },
                x: {
                    grid: {
                        display: false
                    },
                    ticks: {
                        maxRotation: 45,
                        minRotation: 0
                    }
                }
            },
            animation: {
                duration: 1500,
                easing: 'easeInOutQuart'
            }
        }
    });
}

// 카테고리별 인기도 차트 (도넛 차트)
function createCategoryChart(data) {
    const canvas = document.getElementById('categoryChart');
    if (!canvas) {
        console.warn('categoryChart 캔버스를 찾을 수 없습니다.');
        return;
    }

    const ctx = canvas.getContext('2d');
    
    // 카테고리별 데이터 집계
    const keywords = data.trendingKeywords || [];
    const categoryData = {};
    
    keywords.forEach(keyword => {
        const category = keyword.category || 'other';
        const categoryName = getCategoryName(category);
        if (!categoryData[categoryName]) {
            categoryData[categoryName] = 0;
        }
        categoryData[categoryName] += keyword.mentionCount || 0;
    });

    const labels = Object.keys(categoryData);
    const values = Object.values(categoryData);
    const colors = [
        'rgba(102, 126, 234, 0.8)',
        'rgba(236, 72, 153, 0.8)',
        'rgba(59, 130, 246, 0.8)',
        'rgba(16, 185, 129, 0.8)',
        'rgba(245, 158, 11, 0.8)',
        'rgba(239, 68, 68, 0.8)'
    ];

    categoryChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: labels,
            datasets: [{
                data: values,
                backgroundColor: colors,
                borderColor: colors.map(color => color.replace('0.8', '1')),
                borderWidth: 2,
                hoverBackgroundColor: colors.map(color => color.replace('0.8', '0.9')),
                hoverBorderWidth: 3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom',
                    labels: {
                        padding: 20,
                        usePointStyle: true,
                        font: {
                            size: 12
                        }
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.8)',
                    titleColor: '#fff',
                    bodyColor: '#fff',
                    borderColor: 'rgba(102, 126, 234, 0.3)',
                    borderWidth: 1,
                    cornerRadius: 8,
                    callbacks: {
                        label: function(context) {
                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                            const percentage = ((context.parsed / total) * 100).toFixed(1);
                            return `${context.label}: ${context.parsed.toLocaleString()}회 (${percentage}%)`;
                        }
                    }
                }
            },
            animation: {
                duration: 1500,
                easing: 'easeInOutQuart'
            },
            cutout: '60%'
        }
    });
}

// 카테고리 이름 매핑
function getCategoryName(category) {
    const categoryMap = {
        'destination': '여행지',
        'activity': '액티비티',
        'food': '음식',
        'accommodation': '숙박',
        'transport': '교통',
        'other': '기타'
    };
    return categoryMap[category] || '기타';
}