package com.tour.project.controller;

import com.tour.project.service.TrendDataCacheService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 캐시 관리 컨트롤러
 * - 캐시 성능 모니터링
 * - 캐시 무효화
 * - 시스템 성능 최적화
 */
@Slf4j
@RestController
@RequestMapping("/api/cache")
@RequiredArgsConstructor
public class CacheManagementController {
    
    private final TrendDataCacheService cacheService;
    
    /**
     * 캐시 통계 조회
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getCacheStatistics() {
        
        try {
            Map<String, Object> stats = cacheService.getCacheStatistics();
            
            log.info("캐시 통계 조회 완료");
            
            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            log.error("캐시 통계 조회 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "통계 조회에 실패했습니다."));
        }
    }
    
    /**
     * 특정 캐시 무효화
     */
    @PostMapping("/invalidate/{cacheType}")
    public ResponseEntity<Map<String, Object>> invalidateCache(@PathVariable String cacheType) {
        
        try {
            cacheService.invalidateCache(cacheType);
            
            log.info("캐시 무효화 완료: {}", cacheType);
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", cacheType + " 캐시가 무효화되었습니다."
            ));
            
        } catch (Exception e) {
            log.error("캐시 무효화 실패: {}", cacheType, e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "캐시 무효화에 실패했습니다."));
        }
    }
    
    /**
     * 전체 캐시 무효화
     */
    @PostMapping("/invalidate/all")
    public ResponseEntity<Map<String, Object>> invalidateAllCaches() {
        
        try {
            cacheService.invalidateCache("all");
            
            log.info("전체 캐시 무효화 완료");
            
            return ResponseEntity.ok(Map.of(
                "status", "success",
                "message", "모든 캐시가 무효화되었습니다."
            ));
            
        } catch (Exception e) {
            log.error("전체 캐시 무효화 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("status", "error", "message", "캐시 무효화에 실패했습니다."));
        }
    }
    
    /**
     * 성능 최적화 정보 조회
     */
    @GetMapping("/performance")
    public ResponseEntity<Map<String, Object>> getPerformanceInfo() {
        
        try {
            Map<String, Object> stats = cacheService.getCacheStatistics();
            
            // 성능 분석 및 권장사항 생성
            Map<String, Object> performance = Map.of(
                "cacheStats", stats,
                "recommendations", generatePerformanceRecommendations(stats),
                "systemInfo", getSystemInfo()
            );
            
            return ResponseEntity.ok(performance);
            
        } catch (Exception e) {
            log.error("성능 정보 조회 실패", e);
            return ResponseEntity.internalServerError()
                .body(Map.of("error", "성능 정보 조회에 실패했습니다."));
        }
    }
    
    /**
     * 성능 권장사항 생성
     */
    private Map<String, Object> generatePerformanceRecommendations(Map<String, Object> stats) {
        // 간단한 성능 분석 로직
        Map<String, Object> recommendations = new java.util.HashMap<>();
        
        // 히트율 분석
        @SuppressWarnings("unchecked")
        Map<String, Object> metrics = (Map<String, Object>) stats.get("performanceMetrics");
        
        if (metrics != null) {
            for (String cacheType : metrics.keySet()) {
                String hitRateKey = cacheType + "HitRate";
                if (stats.containsKey(hitRateKey)) {
                    String hitRateStr = (String) stats.get(hitRateKey);
                    double hitRate = Double.parseDouble(hitRateStr.replace("%", ""));
                    
                    if (hitRate < 50) {
                        recommendations.put(cacheType + "_recommendation", 
                            "캐시 히트율이 낮습니다 (" + hitRateStr + "). TTL 증가를 고려해보세요.");
                    } else if (hitRate > 90) {
                        recommendations.put(cacheType + "_recommendation", 
                            "우수한 캐시 성능입니다 (" + hitRateStr + ").");
                    }
                }
            }
        }
        
        // 캐시 크기 분석
        int totalCacheSize = (Integer) stats.get("trendCacheSize") + 
                           (Integer) stats.get("mbtiCacheSize") + 
                           (Integer) stats.get("snsCacheSize") + 
                           (Integer) stats.get("personalizedCacheSize");
        
        if (totalCacheSize > 800) {
            recommendations.put("size_recommendation", 
                "캐시 크기가 큽니다 (" + totalCacheSize + "개). 정리 주기를 단축하는 것을 고려해보세요.");
        }
        
        return recommendations;
    }
    
    /**
     * 시스템 정보 조회
     */
    private Map<String, Object> getSystemInfo() {
        Runtime runtime = Runtime.getRuntime();
        
        return Map.of(
            "totalMemory", runtime.totalMemory() / 1024 / 1024 + " MB",
            "freeMemory", runtime.freeMemory() / 1024 / 1024 + " MB",
            "maxMemory", runtime.maxMemory() / 1024 / 1024 + " MB",
            "availableProcessors", runtime.availableProcessors(),
            "timestamp", java.time.LocalDateTime.now()
        );
    }
}