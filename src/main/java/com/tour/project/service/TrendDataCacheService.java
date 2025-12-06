package com.tour.project.service;

import com.tour.project.dto.TrendAnalysisResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.annotation.PreDestroy;
import java.time.LocalDateTime;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 트렌드 데이터 캐싱 및 성능 최적화 서비스
 * - 메모리 기반 캐싱 시스템
 * - 자동 캐시 갱신
 * - 성능 메트릭 수집
 */
@Slf4j
@Service
public class TrendDataCacheService {
    
    // 캐시 저장소
    private final Map<String, CacheEntry> trendCache = new ConcurrentHashMap<>();
    private final Map<String, CacheEntry> mbtiCache = new ConcurrentHashMap<>();
    private final Map<String, CacheEntry> snsCache = new ConcurrentHashMap<>();
    private final Map<String, CacheEntry> personalizedCache = new ConcurrentHashMap<>();
    
    // 성능 메트릭
    private final Map<String, PerformanceMetrics> performanceMetrics = new ConcurrentHashMap<>();
    
    // 스케줄러
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(2);
    
    // 캐시 설정
    private static final Duration TREND_CACHE_TTL = Duration.ofMinutes(15);
    private static final Duration MBTI_CACHE_TTL = Duration.ofHours(2);
    private static final Duration SNS_CACHE_TTL = Duration.ofMinutes(10);
    private static final Duration PERSONALIZED_CACHE_TTL = Duration.ofMinutes(30);
    private static final int MAX_CACHE_SIZE = 1000;
    
    public TrendDataCacheService() {
        // 캐시 정리 스케줄러 시작
        startCacheCleanupScheduler();
        // 성능 메트릭 로깅 스케줄러 시작
        startPerformanceMetricsScheduler();
    }

    /**
     * 애플리케이션 종료 시 스케줄러 정리
     */
    @PreDestroy
    public void destroy() {
        log.info("TrendDataCacheService 종료 중 - 스케줄러 정리 시작");

        try {
            // 새로운 작업 수락 중지
            scheduler.shutdown();

            // 실행 중인 작업이 완료될 때까지 대기 (최대 30초)
            if (!scheduler.awaitTermination(30, TimeUnit.SECONDS)) {
                log.warn("캐시 스케줄러가 30초 내에 종료되지 않음 - 강제 종료 시도");

                // 강제 종료
                scheduler.shutdownNow();

                // 강제 종료 후 추가 대기 (최대 10초)
                if (!scheduler.awaitTermination(10, TimeUnit.SECONDS)) {
                    log.error("캐시 스케줄러 강제 종료 실패");
                }
            }

            log.info("TrendDataCacheService 스케줄러 정상 종료 완료");

        } catch (InterruptedException e) {
            log.error("캐시 스케줄러 종료 중 인터럽트 발생", e);

            // 인터럽트 발생 시 강제 종료 시도
            scheduler.shutdownNow();

            // 현재 스레드의 인터럽트 상태 복원
            Thread.currentThread().interrupt();
        }
    }
    
    /**
     * 트렌드 분석 데이터 캐시 조회/저장
     */
    public TrendAnalysisResponse getTrendAnalysis(String cacheKey) {
        CacheEntry entry = trendCache.get(cacheKey);
        if (entry != null && !entry.isExpired()) {
            recordCacheHit("trend");
            return (TrendAnalysisResponse) entry.getData();
        }
        recordCacheMiss("trend");
        return null;
    }
    
    public void cacheTrendAnalysis(String cacheKey, TrendAnalysisResponse data) {
        if (trendCache.size() >= MAX_CACHE_SIZE) {
            cleanupOldestEntries(trendCache);
        }
        trendCache.put(cacheKey, new CacheEntry(data, TREND_CACHE_TTL));
        log.debug("트렌드 데이터 캐싱 완료: {}", cacheKey);
    }
    
    /**
     * MBTI 추천 데이터 캐시 조회/저장
     */
    public Map<String, Object> getMbtiRecommendation(String mbtiType) {
        CacheEntry entry = mbtiCache.get(mbtiType);
        if (entry != null && !entry.isExpired()) {
            recordCacheHit("mbti");
            @SuppressWarnings("unchecked")
            Map<String, Object> result = (Map<String, Object>) entry.getData();
            return result;
        }
        recordCacheMiss("mbti");
        return null;
    }
    
    public void cacheMbtiRecommendation(String mbtiType, Map<String, Object> data) {
        if (mbtiCache.size() >= MAX_CACHE_SIZE) {
            cleanupOldestEntries(mbtiCache);
        }
        mbtiCache.put(mbtiType, new CacheEntry(data, MBTI_CACHE_TTL));
        log.debug("MBTI 추천 데이터 캐싱 완료: {}", mbtiType);
    }
    
    /**
     * SNS 분석 데이터 캐시 조회/저장
     */
    public Map<String, Object> getSnsAnalysis(String cacheKey) {
        CacheEntry entry = snsCache.get(cacheKey);
        if (entry != null && !entry.isExpired()) {
            recordCacheHit("sns");
            @SuppressWarnings("unchecked")
            Map<String, Object> result = (Map<String, Object>) entry.getData();
            return result;
        }
        recordCacheMiss("sns");
        return null;
    }
    
    public void cacheSnsAnalysis(String cacheKey, Map<String, Object> data) {
        if (snsCache.size() >= MAX_CACHE_SIZE) {
            cleanupOldestEntries(snsCache);
        }
        snsCache.put(cacheKey, new CacheEntry(data, SNS_CACHE_TTL));
        log.debug("SNS 분석 데이터 캐싱 완료: {}", cacheKey);
    }
    
    /**
     * 개인화 추천 데이터 캐시 조회/저장
     */
    public Map<String, Object> getPersonalizedRecommendation(String userId, String context) {
        String cacheKey = userId + "_" + (context != null ? context.hashCode() : "default");
        CacheEntry entry = personalizedCache.get(cacheKey);
        if (entry != null && !entry.isExpired()) {
            recordCacheHit("personalized");
            @SuppressWarnings("unchecked")
            Map<String, Object> result = (Map<String, Object>) entry.getData();
            return result;
        }
        recordCacheMiss("personalized");
        return null;
    }
    
    public void cachePersonalizedRecommendation(String userId, String context, Map<String, Object> data) {
        String cacheKey = userId + "_" + (context != null ? context.hashCode() : "default");
        if (personalizedCache.size() >= MAX_CACHE_SIZE) {
            cleanupOldestEntries(personalizedCache);
        }
        personalizedCache.put(cacheKey, new CacheEntry(data, PERSONALIZED_CACHE_TTL));
        log.debug("개인화 추천 데이터 캐싱 완료: {}", cacheKey);
    }
    
    /**
     * 캐시 통계 조회
     */
    public Map<String, Object> getCacheStatistics() {
        Map<String, Object> stats = new ConcurrentHashMap<>();
        
        // 캐시 크기
        stats.put("trendCacheSize", trendCache.size());
        stats.put("mbtiCacheSize", mbtiCache.size());
        stats.put("snsCacheSize", snsCache.size());
        stats.put("personalizedCacheSize", personalizedCache.size());
        
        // 성능 메트릭
        stats.put("performanceMetrics", performanceMetrics);
        
        // 캐시 히트율 계산
        for (String type : performanceMetrics.keySet()) {
            PerformanceMetrics metrics = performanceMetrics.get(type);
            double hitRate = metrics.getHitRate();
            stats.put(type + "HitRate", String.format("%.2f%%", hitRate * 100));
        }
        
        return stats;
    }
    
    /**
     * 특정 캐시 무효화
     */
    public void invalidateCache(String cacheType) {
        switch (cacheType.toLowerCase()) {
            case "trend":
                trendCache.clear();
                break;
            case "mbti":
                mbtiCache.clear();
                break;
            case "sns":
                snsCache.clear();
                break;
            case "personalized":
                personalizedCache.clear();
                break;
            case "all":
                trendCache.clear();
                mbtiCache.clear();
                snsCache.clear();
                personalizedCache.clear();
                break;
        }
        log.info("캐시 무효화 완료: {}", cacheType);
    }
    
    /**
     * 캐시 히트 기록
     */
    private void recordCacheHit(String cacheType) {
        performanceMetrics.computeIfAbsent(cacheType, k -> new PerformanceMetrics()).recordHit();
    }
    
    /**
     * 캐시 미스 기록
     */
    private void recordCacheMiss(String cacheType) {
        performanceMetrics.computeIfAbsent(cacheType, k -> new PerformanceMetrics()).recordMiss();
    }
    
    /**
     * 오래된 엔트리 정리
     */
    private void cleanupOldestEntries(Map<String, CacheEntry> cache) {
        if (cache.size() < MAX_CACHE_SIZE) return;
        
        cache.entrySet().removeIf(entry -> entry.getValue().isExpired());
        
        // 여전히 크기가 크면 가장 오래된 것들 제거
        if (cache.size() >= MAX_CACHE_SIZE) {
            cache.entrySet().stream()
                .sorted(Map.Entry.<String, CacheEntry>comparingByValue((a, b) -> 
                    a.getCreatedAt().compareTo(b.getCreatedAt())))
                .limit(cache.size() - MAX_CACHE_SIZE + 100) // 여유 공간 확보
                .map(Map.Entry::getKey)
                .forEach(cache::remove);
        }
    }
    
    /**
     * 캐시 정리 스케줄러 시작
     */
    private void startCacheCleanupScheduler() {
        scheduler.scheduleAtFixedRate(() -> {
            try {
                cleanupExpiredEntries();
            } catch (Exception e) {
                log.error("캐시 정리 중 오류 발생", e);
            }
        }, 5, 5, TimeUnit.MINUTES);
    }
    
    /**
     * 성능 메트릭 로깅 스케줄러 시작
     */
    private void startPerformanceMetricsScheduler() {
        scheduler.scheduleAtFixedRate(() -> {
            try {
                logPerformanceMetrics();
            } catch (Exception e) {
                log.error("성능 메트릭 로깅 중 오류 발생", e);
            }
        }, 10, 10, TimeUnit.MINUTES);
    }
    
    /**
     * 만료된 엔트리 정리
     */
    private void cleanupExpiredEntries() {
        int removedCount = 0;
        
        removedCount += trendCache.entrySet().removeIf(entry -> entry.getValue().isExpired()) ? 1 : 0;
        removedCount += mbtiCache.entrySet().removeIf(entry -> entry.getValue().isExpired()) ? 1 : 0;
        removedCount += snsCache.entrySet().removeIf(entry -> entry.getValue().isExpired()) ? 1 : 0;
        removedCount += personalizedCache.entrySet().removeIf(entry -> entry.getValue().isExpired()) ? 1 : 0;
        
        if (removedCount > 0) {
            log.debug("만료된 캐시 엔트리 {} 개 정리 완료", removedCount);
        }
    }
    
    /**
     * 성능 메트릭 로깅
     */
    private void logPerformanceMetrics() {
        for (Map.Entry<String, PerformanceMetrics> entry : performanceMetrics.entrySet()) {
            String type = entry.getKey();
            PerformanceMetrics metrics = entry.getValue();
            
            log.info("캐시 성능 메트릭 [{}] - 히트율: {:.2f}%, 총 요청: {}, 히트: {}, 미스: {}",
                type, metrics.getHitRate() * 100, metrics.getTotalRequests(), 
                metrics.getHits(), metrics.getMisses());
        }
    }
    
    /**
     * 캐시 엔트리 클래스
     */
    private static class CacheEntry {
        private final Object data;
        private final LocalDateTime createdAt;
        private final LocalDateTime expiresAt;
        
        public CacheEntry(Object data, Duration ttl) {
            this.data = data;
            this.createdAt = LocalDateTime.now();
            this.expiresAt = createdAt.plus(ttl);
        }
        
        public Object getData() {
            return data;
        }
        
        public LocalDateTime getCreatedAt() {
            return createdAt;
        }
        
        public boolean isExpired() {
            return LocalDateTime.now().isAfter(expiresAt);
        }
    }
    
    /**
     * 성능 메트릭 클래스
     */
    private static class PerformanceMetrics {
        private long hits = 0;
        private long misses = 0;
        
        public synchronized void recordHit() {
            hits++;
        }
        
        public synchronized void recordMiss() {
            misses++;
        }
        
        public synchronized long getHits() {
            return hits;
        }
        
        public synchronized long getMisses() {
            return misses;
        }
        
        public synchronized long getTotalRequests() {
            return hits + misses;
        }
        
        public synchronized double getHitRate() {
            long total = getTotalRequests();
            return total > 0 ? (double) hits / total : 0.0;
        }
    }
}