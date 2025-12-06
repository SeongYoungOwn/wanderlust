package com.tour.project.dto;

public class TravelMbtiResultDTO {
    private String mbtiType;
    private String typeName;
    private String typeDescription;
    private String travelStyle;
    private String recommendedDestinations;
    private String travelTips;
    private String bestTravelSeason;
    
    public TravelMbtiResultDTO() {}
    
    public TravelMbtiResultDTO(String mbtiType, String typeName, String typeDescription, 
                              String travelStyle, String recommendedDestinations, 
                              String travelTips, String bestTravelSeason) {
        this.mbtiType = mbtiType;
        this.typeName = typeName;
        this.typeDescription = typeDescription;
        this.travelStyle = travelStyle;
        this.recommendedDestinations = recommendedDestinations;
        this.travelTips = travelTips;
        this.bestTravelSeason = bestTravelSeason;
    }
    
    public String getMbtiType() {
        return mbtiType;
    }
    
    public void setMbtiType(String mbtiType) {
        this.mbtiType = mbtiType;
    }
    
    public String getTypeName() {
        return typeName;
    }
    
    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }
    
    public String getTypeDescription() {
        return typeDescription;
    }
    
    public void setTypeDescription(String typeDescription) {
        this.typeDescription = typeDescription;
    }
    
    public String getTravelStyle() {
        return travelStyle;
    }
    
    public void setTravelStyle(String travelStyle) {
        this.travelStyle = travelStyle;
    }
    
    public String getRecommendedDestinations() {
        return recommendedDestinations;
    }
    
    public void setRecommendedDestinations(String recommendedDestinations) {
        this.recommendedDestinations = recommendedDestinations;
    }
    
    public String getTravelTips() {
        return travelTips;
    }
    
    public void setTravelTips(String travelTips) {
        this.travelTips = travelTips;
    }
    
    public String getBestTravelSeason() {
        return bestTravelSeason;
    }
    
    public void setBestTravelSeason(String bestTravelSeason) {
        this.bestTravelSeason = bestTravelSeason;
    }
    
    @Override
    public String toString() {
        return "TravelMbtiResultDTO{" +
                "mbtiType='" + mbtiType + '\'' +
                ", typeName='" + typeName + '\'' +
                ", typeDescription='" + typeDescription + '\'' +
                ", travelStyle='" + travelStyle + '\'' +
                ", recommendedDestinations='" + recommendedDestinations + '\'' +
                ", travelTips='" + travelTips + '\'' +
                ", bestTravelSeason='" + bestTravelSeason + '\'' +
                '}';
    }
}