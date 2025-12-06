package com.tour.project.dto;

import java.sql.Timestamp;

public class MemberDTO {
    private String userId;
    private String userPassword;
    private String userName;
    private String userEmail;
    private String userMbti;
    private String nickname;
    private String gender; // M: 남자, F: 여자
    private Integer age; // 나이
    private Double mannerTemperature;
    private String profileImage;
    private String bio; // 자기소개
    private String userRole; // USER: 일반사용자, ADMIN: 관리자
    private String accountStatus; // ACTIVE: 활성, SUSPENDED: 정지
    private Timestamp userRegdate;
    private Integer memberId; // 데이터베이스 자동 생성 ID
    
    public MemberDTO() {}
    
    public MemberDTO(String userId, String userPassword, String userName, String userEmail, String userMbti, String nickname, String gender, Integer age, Timestamp userRegdate) {
        this.userId = userId;
        this.userPassword = userPassword;
        this.userName = userName;
        this.userEmail = userEmail;
        this.userMbti = userMbti;
        this.nickname = nickname;
        this.gender = gender;
        this.age = age;
        this.mannerTemperature = 36.5; // 기본 매너온도
        this.userRegdate = userRegdate;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getUserPassword() {
        return userPassword;
    }
    
    public void setUserPassword(String userPassword) {
        this.userPassword = userPassword;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public String getUserEmail() {
        return userEmail;
    }
    
    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }
    
    public String getUserMbti() {
        return userMbti;
    }
    
    public void setUserMbti(String userMbti) {
        this.userMbti = userMbti;
    }
    
    public String getMbtiType() {
        return userMbti;
    }
    
    public Timestamp getUserRegdate() {
        return userRegdate;
    }
    
    public void setUserRegdate(Timestamp userRegdate) {
        this.userRegdate = userRegdate;
    }
    
    public String getNickname() {
        return nickname;
    }
    
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public Double getMannerTemperature() {
        return mannerTemperature;
    }
    
    public void setMannerTemperature(Double mannerTemperature) {
        this.mannerTemperature = mannerTemperature;
    }
    
    public String getProfileImage() {
        return profileImage;
    }
    
    public void setProfileImage(String profileImage) {
        this.profileImage = profileImage;
    }
    
    public String getBio() {
        return bio;
    }
    
    public void setBio(String bio) {
        this.bio = bio;
    }
    
    public String getUserRole() {
        return userRole;
    }
    
    public void setUserRole(String userRole) {
        this.userRole = userRole;
    }
    
    public String getAccountStatus() {
        return accountStatus;
    }
    
    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
    }
    
    public Integer getAge() {
        return age;
    }
    
    public void setAge(Integer age) {
        this.age = age;
    }

    public Integer getMemberId() {
        return memberId;
    }

    public void setMemberId(Integer memberId) {
        this.memberId = memberId;
    }

    public String getName() {
        return userName;
    }

    public String getEmail() {
        return userEmail;
    }

    public String getRole() {
        return userRole;
    }

    public void setRole(String role) {
        this.userRole = role;
    }

    @Override
    public String toString() {
        return "MemberDTO{" +
                "userId='" + userId + '\'' +
                ", userName='" + userName + '\'' +
                ", userEmail='" + userEmail + '\'' +
                ", nickname='" + nickname + '\'' +
                ", gender='" + gender + '\'' +
                ", userMbti='" + userMbti + '\'' +
                ", userRegdate=" + userRegdate +
                '}';
    }
}