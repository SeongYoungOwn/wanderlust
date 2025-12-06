package com.tour.project.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class UserHistoryDTO {
    private Long userId;
    private List<TravelPlanDTO> pastTravels;
    private Map<String, Integer> destinationHistory;
    private Map<String, Integer> styleHistory;
    private Map<Long, Double> planRatings;
    private Map<String, Integer> clickHistory;
    private List<Long> favoriteUsers;
    private Double avgRating;
    private Integer totalTrips;
    private Integer successfulMatches;
    private LocalDateTime lastActivityDate;
    private List<String> searchKeywords;

    // Default constructor
    public UserHistoryDTO() {}

    // Constructor with userId
    public UserHistoryDTO(Long userId) {
        this.userId = userId;
    }

    // Getters and Setters
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public List<TravelPlanDTO> getPastTravels() {
        return pastTravels;
    }

    public void setPastTravels(List<TravelPlanDTO> pastTravels) {
        this.pastTravels = pastTravels;
    }

    public Map<String, Integer> getDestinationHistory() {
        return destinationHistory;
    }

    public void setDestinationHistory(Map<String, Integer> destinationHistory) {
        this.destinationHistory = destinationHistory;
    }

    public Map<String, Integer> getStyleHistory() {
        return styleHistory;
    }

    public void setStyleHistory(Map<String, Integer> styleHistory) {
        this.styleHistory = styleHistory;
    }

    public Map<Long, Double> getPlanRatings() {
        return planRatings;
    }

    public void setPlanRatings(Map<Long, Double> planRatings) {
        this.planRatings = planRatings;
    }

    public Map<String, Integer> getClickHistory() {
        return clickHistory;
    }

    public void setClickHistory(Map<String, Integer> clickHistory) {
        this.clickHistory = clickHistory;
    }

    public List<Long> getFavoriteUsers() {
        return favoriteUsers;
    }

    public void setFavoriteUsers(List<Long> favoriteUsers) {
        this.favoriteUsers = favoriteUsers;
    }

    public Double getAvgRating() {
        return avgRating;
    }

    public void setAvgRating(Double avgRating) {
        this.avgRating = avgRating;
    }

    public Integer getTotalTrips() {
        return totalTrips;
    }

    public void setTotalTrips(Integer totalTrips) {
        this.totalTrips = totalTrips;
    }

    public Integer getSuccessfulMatches() {
        return successfulMatches;
    }

    public void setSuccessfulMatches(Integer successfulMatches) {
        this.successfulMatches = successfulMatches;
    }

    public LocalDateTime getLastActivityDate() {
        return lastActivityDate;
    }

    public void setLastActivityDate(LocalDateTime lastActivityDate) {
        this.lastActivityDate = lastActivityDate;
    }

    public List<String> getSearchKeywords() {
        return searchKeywords;
    }

    public void setSearchKeywords(List<String> searchKeywords) {
        this.searchKeywords = searchKeywords;
    }
}