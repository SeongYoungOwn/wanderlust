package com.tour.project.dto;

public class MbtiCompatibilityDTO {
    private int compatibilityId;
    private String mbtiType1;
    private String mbtiType2;
    private int compatibilityScore;
    private String synergyDescription;
    private String recommendedDestinations;
    private String travelStyleBalance;
    private String createdDate;
    
    public MbtiCompatibilityDTO() {}
    
    public MbtiCompatibilityDTO(String mbtiType1, String mbtiType2, int compatibilityScore, 
                               String synergyDescription, String recommendedDestinations, 
                               String travelStyleBalance) {
        this.mbtiType1 = mbtiType1;
        this.mbtiType2 = mbtiType2;
        this.compatibilityScore = compatibilityScore;
        this.synergyDescription = synergyDescription;
        this.recommendedDestinations = recommendedDestinations;
        this.travelStyleBalance = travelStyleBalance;
    }
    
    public int getCompatibilityId() {
        return compatibilityId;
    }
    
    public void setCompatibilityId(int compatibilityId) {
        this.compatibilityId = compatibilityId;
    }
    
    public String getMbtiType1() {
        return mbtiType1;
    }
    
    public void setMbtiType1(String mbtiType1) {
        this.mbtiType1 = mbtiType1;
    }
    
    public String getMbtiType2() {
        return mbtiType2;
    }
    
    public void setMbtiType2(String mbtiType2) {
        this.mbtiType2 = mbtiType2;
    }
    
    public int getCompatibilityScore() {
        return compatibilityScore;
    }
    
    public void setCompatibilityScore(int compatibilityScore) {
        this.compatibilityScore = compatibilityScore;
    }
    
    public String getSynergyDescription() {
        return synergyDescription;
    }
    
    public void setSynergyDescription(String synergyDescription) {
        this.synergyDescription = synergyDescription;
    }
    
    public String getRecommendedDestinations() {
        return recommendedDestinations;
    }
    
    public void setRecommendedDestinations(String recommendedDestinations) {
        this.recommendedDestinations = recommendedDestinations;
    }
    
    public String getTravelStyleBalance() {
        return travelStyleBalance;
    }
    
    public void setTravelStyleBalance(String travelStyleBalance) {
        this.travelStyleBalance = travelStyleBalance;
    }
    
    public String getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(String createdDate) {
        this.createdDate = createdDate;
    }
    
    @Override
    public String toString() {
        return "MbtiCompatibilityDTO{" +
                "compatibilityId=" + compatibilityId +
                ", mbtiType1='" + mbtiType1 + '\'' +
                ", mbtiType2='" + mbtiType2 + '\'' +
                ", compatibilityScore=" + compatibilityScore +
                ", synergyDescription='" + synergyDescription + '\'' +
                ", recommendedDestinations='" + recommendedDestinations + '\'' +
                ", travelStyleBalance='" + travelStyleBalance + '\'' +
                ", createdDate='" + createdDate + '\'' +
                '}';
    }
}