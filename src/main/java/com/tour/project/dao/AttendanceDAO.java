package com.tour.project.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.time.LocalDate;
import java.util.List;

@Mapper
public interface AttendanceDAO {
    
    // 출석 기록
    int recordAttendance(@Param("userId") String userId, @Param("attendanceDate") LocalDate attendanceDate);
    
    // 오늘 출석 여부 확인
    boolean hasAttendanceToday(@Param("userId") String userId, @Param("attendanceDate") LocalDate attendanceDate);
    
    // 연속 출석 일수 조회
    int getConsecutiveAttendanceDays(@Param("userId") String userId);
    
    // 월별 출석 일수 조회
    int getMonthlyAttendanceDays(@Param("userId") String userId, @Param("year") int year, @Param("month") int month);
    
    // 연간 출석 일수 조회
    int getYearlyAttendanceDays(@Param("userId") String userId, @Param("year") int year);
    
    // 총 출석 일수 조회
    int getTotalAttendanceDays(@Param("userId") String userId);
    
    // 최근 출석 날짜들 조회
    List<LocalDate> getRecentAttendanceDates(@Param("userId") String userId, @Param("limit") int limit);
    
    // 특정 기간 출석 여부 확인
    List<LocalDate> getAttendanceBetweenDates(@Param("userId") String userId, 
                                             @Param("startDate") LocalDate startDate, 
                                             @Param("endDate") LocalDate endDate);
}