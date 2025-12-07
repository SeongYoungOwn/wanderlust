package com.tour.project.dao;

import com.tour.project.dto.EmailVerificationDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

@Mapper
@Repository
public interface EmailVerificationDAO {

    // 인증 정보 저장
    int insertVerification(EmailVerificationDTO verification);

    // 이메일과 코드로 인증 정보 조회
    EmailVerificationDTO getVerification(@Param("email") String email,
                                        @Param("code") String code);

    // 인증 상태 업데이트
    int updateVerificationStatus(@Param("email") String email,
                                @Param("code") String code);

    // 시도 횟수 증가
    int incrementAttemptCount(@Param("email") String email);

    // 이메일로 최근 인증 정보 조회
    EmailVerificationDTO getLatestVerification(@Param("email") String email);

    // 만료된 인증 정보 삭제
    int deleteExpiredVerifications();

    // 특정 이메일의 미인증 레코드 삭제
    int deleteUnverifiedByEmail(@Param("email") String email);
}