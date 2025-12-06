package com.tour.project.dto;

public class TravelMbtiQuestionDTO {
    private int questionId;
    private String questionText;
    private String optionA;
    private String optionB;
    private String dimension;
    private int questionOrder;
    
    public TravelMbtiQuestionDTO() {}
    
    public TravelMbtiQuestionDTO(int questionId, String questionText, String optionA, String optionB, 
                                String dimension, int questionOrder) {
        this.questionId = questionId;
        this.questionText = questionText;
        this.optionA = optionA;
        this.optionB = optionB;
        this.dimension = dimension;
        this.questionOrder = questionOrder;
    }
    
    public int getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }
    
    public String getQuestionText() {
        return questionText;
    }
    
    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }
    
    public String getOptionA() {
        return optionA;
    }
    
    public void setOptionA(String optionA) {
        this.optionA = optionA;
    }
    
    public String getOptionB() {
        return optionB;
    }
    
    public void setOptionB(String optionB) {
        this.optionB = optionB;
    }
    
    public String getDimension() {
        return dimension;
    }
    
    public void setDimension(String dimension) {
        this.dimension = dimension;
    }
    
    public int getQuestionOrder() {
        return questionOrder;
    }
    
    public void setQuestionOrder(int questionOrder) {
        this.questionOrder = questionOrder;
    }
    
    @Override
    public String toString() {
        return "TravelMbtiQuestionDTO{" +
                "questionId=" + questionId +
                ", questionText='" + questionText + '\'' +
                ", optionA='" + optionA + '\'' +
                ", optionB='" + optionB + '\'' +
                ", dimension='" + dimension + '\'' +
                ", questionOrder=" + questionOrder +
                '}';
    }
}