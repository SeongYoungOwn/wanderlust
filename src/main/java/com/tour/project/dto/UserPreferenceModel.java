package com.tour.project.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public class UserPreferenceModel {
    private Long userId;
    private Map<String, Double> destinationPreferences;
    private Map<String, Double> stylePreferences;
    private Map<String, Double> budgetPreferences;
    private Map<String, Double> durationPreferences;
    private Map<String, Double> personalizedWeights;
    private List<String> favoriteDestinations;
    private List<String> dislikedDestinations;
    private Double avgBudget;
    private Integer avgDurationDays;
    private String preferredSeasons;
    private Double collaborativeScore;
    private LocalDateTime lastUpdated;

    // Default constructor
    public UserPreferenceModel() {}

    // Constructor with userId
    public UserPreferenceModel(Long userId) {
        this.userId = userId;
    }

    // Getters and Setters
    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public Map<String, Double> getDestinationPreferences() {
        return destinationPreferences;
    }

    public void setDestinationPreferences(Map<String, Double> destinationPreferences) {
        this.destinationPreferences = destinationPreferences;
    }

    public Map<String, Double> getStylePreferences() {
        return stylePreferences;
    }

    public void setStylePreferences(Map<String, Double> stylePreferences) {
        this.stylePreferences = stylePreferences;
    }

    public Map<String, Double> getBudgetPreferences() {
        return budgetPreferences;
    }

    public void setBudgetPreferences(Map<String, Double> budgetPreferences) {
        this.budgetPreferences = budgetPreferences;
    }

    public Map<String, Double> getDurationPreferences() {
        return durationPreferences;
    }

    public void setDurationPreferences(Map<String, Double> durationPreferences) {
        this.durationPreferences = durationPreferences;
    }

    public Map<String, Double> getPersonalizedWeights() {
        return personalizedWeights;
    }

    public void setPersonalizedWeights(Map<String, Double> personalizedWeights) {
        this.personalizedWeights = personalizedWeights;
    }

    public List<String> getFavoriteDestinations() {
        return favoriteDestinations;
    }

    public void setFavoriteDestinations(List<String> favoriteDestinations) {
        this.favoriteDestinations = favoriteDestinations;
    }

    public List<String> getDislikedDestinations() {
        return dislikedDestinations;
    }

    public void setDislikedDestinations(List<String> dislikedDestinations) {
        this.dislikedDestinations = dislikedDestinations;
    }

    public Double getAvgBudget() {
        return avgBudget;
    }

    public void setAvgBudget(Double avgBudget) {
        this.avgBudget = avgBudget;
    }

    public Integer getAvgDurationDays() {
        return avgDurationDays;
    }

    public void setAvgDurationDays(Integer avgDurationDays) {
        this.avgDurationDays = avgDurationDays;
    }

    public String getPreferredSeasons() {
        return preferredSeasons;
    }

    public void setPreferredSeasons(String preferredSeasons) {
        this.preferredSeasons = preferredSeasons;
    }

    public Double getCollaborativeScore() {
        return collaborativeScore;
    }

    public void setCollaborativeScore(Double collaborativeScore) {
        this.collaborativeScore = collaborativeScore;
    }

    public LocalDateTime getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(LocalDateTime lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
}