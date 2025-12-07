<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Skeleton Screen Component --%>
<div id="skeletonScreen" class="skeleton-container" style="display: none;">
    <!-- Card Skeleton for Travel Plans -->
    <div class="skeleton-card-grid" id="skeletonCardGrid">
        <div class="row">
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="skeleton-card">
                    <div class="skeleton-image"></div>
                    <div class="skeleton-content">
                        <div class="skeleton-title"></div>
                        <div class="skeleton-text"></div>
                        <div class="skeleton-text short"></div>
                        <div class="skeleton-badges">
                            <div class="skeleton-badge"></div>
                            <div class="skeleton-badge"></div>
                        </div>
                        <div class="skeleton-footer">
                            <div class="skeleton-author"></div>
                            <div class="skeleton-button"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="skeleton-card">
                    <div class="skeleton-image"></div>
                    <div class="skeleton-content">
                        <div class="skeleton-title"></div>
                        <div class="skeleton-text"></div>
                        <div class="skeleton-text short"></div>
                        <div class="skeleton-badges">
                            <div class="skeleton-badge"></div>
                            <div class="skeleton-badge"></div>
                        </div>
                        <div class="skeleton-footer">
                            <div class="skeleton-author"></div>
                            <div class="skeleton-button"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="skeleton-card">
                    <div class="skeleton-image"></div>
                    <div class="skeleton-content">
                        <div class="skeleton-title"></div>
                        <div class="skeleton-text"></div>
                        <div class="skeleton-text short"></div>
                        <div class="skeleton-badges">
                            <div class="skeleton-badge"></div>
                            <div class="skeleton-badge"></div>
                        </div>
                        <div class="skeleton-footer">
                            <div class="skeleton-author"></div>
                            <div class="skeleton-button"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- List Skeleton for Board Posts -->
    <div class="skeleton-list" id="skeletonList" style="display: none;">
        <div class="skeleton-list-item">
            <div class="skeleton-list-image"></div>
            <div class="skeleton-list-content">
                <div class="skeleton-list-title"></div>
                <div class="skeleton-list-text"></div>
                <div class="skeleton-list-meta">
                    <div class="skeleton-meta-item"></div>
                    <div class="skeleton-meta-item"></div>
                </div>
            </div>
            <div class="skeleton-list-stats">
                <div class="skeleton-stat"></div>
                <div class="skeleton-stat"></div>
            </div>
        </div>
        <div class="skeleton-list-item">
            <div class="skeleton-list-image"></div>
            <div class="skeleton-list-content">
                <div class="skeleton-list-title"></div>
                <div class="skeleton-list-text"></div>
                <div class="skeleton-list-meta">
                    <div class="skeleton-meta-item"></div>
                    <div class="skeleton-meta-item"></div>
                </div>
            </div>
            <div class="skeleton-list-stats">
                <div class="skeleton-stat"></div>
                <div class="skeleton-stat"></div>
            </div>
        </div>
        <div class="skeleton-list-item">
            <div class="skeleton-list-image"></div>
            <div class="skeleton-list-content">
                <div class="skeleton-list-title"></div>
                <div class="skeleton-list-text"></div>
                <div class="skeleton-list-meta">
                    <div class="skeleton-meta-item"></div>
                    <div class="skeleton-meta-item"></div>
                </div>
            </div>
            <div class="skeleton-list-stats">
                <div class="skeleton-stat"></div>
                <div class="skeleton-stat"></div>
            </div>
        </div>
    </div>
</div>

<style>
/* Skeleton Screen Base Styles */
.skeleton-container {
    padding: 2rem 0;
}

.skeleton {
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 8px;
}

@keyframes loading {
    0% {
        background-position: 200% 0;
    }
    100% {
        background-position: -200% 0;
    }
}

/* Card Skeleton Styles */
.skeleton-card {
    background: white;
    border-radius: 25px;
    overflow: hidden;
    box-shadow: 0 25px 80px rgba(0,0,0,0.1);
    border: 1px solid rgba(0, 0, 0, 0.05);
    height: 100%;
}

.skeleton-image {
    width: 100%;
    height: 200px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
}

.skeleton-content {
    padding: 1.3rem;
}

.skeleton-title {
    height: 20px;
    width: 80%;
    margin-bottom: 1rem;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 4px;
}

.skeleton-text {
    height: 14px;
    margin-bottom: 0.5rem;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 4px;
}

.skeleton-text.short {
    width: 60%;
}

.skeleton-badges {
    display: flex;
    gap: 0.5rem;
    margin: 1rem 0;
}

.skeleton-badge {
    height: 24px;
    width: 60px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 12px;
}

.skeleton-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid #f0f0f0;
}

.skeleton-author {
    height: 16px;
    width: 100px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 4px;
}

.skeleton-button {
    height: 32px;
    width: 80px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 16px;
}

/* List Skeleton Styles */
.skeleton-list-item {
    background: white;
    border-radius: 15px;
    padding: 1.2rem;
    margin-bottom: 15px;
    display: flex;
    align-items: center;
    gap: 1rem;
    box-shadow: 0 5px 15px rgba(0,0,0,0.05);
    border: 1px solid rgba(0, 0, 0, 0.05);
}

.skeleton-list-image {
    width: 80px;
    height: 60px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 8px;
    flex-shrink: 0;
}

.skeleton-list-content {
    flex: 1;
    min-width: 0;
}

.skeleton-list-title {
    height: 18px;
    width: 70%;
    margin-bottom: 0.5rem;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 4px;
}

.skeleton-list-text {
    height: 14px;
    width: 90%;
    margin-bottom: 0.5rem;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 4px;
}

.skeleton-list-meta {
    display: flex;
    gap: 1rem;
}

.skeleton-meta-item {
    height: 12px;
    width: 60px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 4px;
}

.skeleton-list-stats {
    display: flex;
    align-items: center;
    gap: 0.8rem;
    flex-shrink: 0;
}

.skeleton-stat {
    height: 12px;
    width: 40px;
    background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
    background-size: 200% 100%;
    animation: loading 1.5s infinite;
    border-radius: 4px;
}

/* Responsive */
@media (max-width: 768px) {
    .skeleton-container {
        padding: 1rem 0;
    }
    
    .skeleton-content {
        padding: 1rem;
    }
    
    .skeleton-list-item {
        padding: 1rem;
    }
    
    .skeleton-list-image {
        width: 60px;
        height: 45px;
    }
}

/* Skeleton Animation Variants */
.skeleton-fast {
    animation-duration: 1s;
}

.skeleton-slow {
    animation-duration: 2s;
}

.skeleton-pulse {
    animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% {
        opacity: 0.7;
    }
    50% {
        opacity: 1;
    }
}
</style>