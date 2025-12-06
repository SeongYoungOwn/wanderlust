package com.tour.project.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ReviewDTO {
    private int reviewId;
    private String reviewerId;
    private String reviewedUserId;
    private int travelPlanId;
    private int rating;
    private String reviewContent;
    private String reviewType;
    private Date createdAt;
    private Date updatedAt;

    // Join fields for display
    private String reviewerName;
    private String reviewerImage;
    private String reviewedUserName;
    private String reviewedUserImage;
    private String travelTitle;
    private Date reviewDate;
}