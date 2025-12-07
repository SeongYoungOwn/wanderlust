package com.tour.project.dao;

import com.tour.project.dto.MemberDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Mapper
@Repository
public interface MemberDAO {
    
    String getTime();
    
    int insertMember(MemberDTO member);
    
    MemberDTO getMember(String userId);
    
    MemberDTO getMemberByEmail(String userEmail);
    
    MemberDTO getMemberByName(String userName);
    
    int updateMember(MemberDTO member);
    
    int deleteMember(String userId);
    
    MemberDTO getMemberById(String userId);
    
    List<MemberDTO> getMembersByMbti(String mbtiType);
    
    // 아이디 중복 확인
    boolean isUserIdExists(String userId);
    
    // 닉네임 중복 확인
    boolean isNicknameExists(String nickname);
    
    // 닉네임으로 멤버 조회
    MemberDTO getMemberByNickname(String nickname);
    
    // 프로필 이미지 업데이트
    int updateProfileImage(@Param("userId") String userId, @Param("profileImage") String profileImage);
    
    // 모든 멤버 조회
    List<MemberDTO> getAllMembers();
    
    // 전체 활성 사용자 수 조회
    int getActiveMemberCount();
    
    // 최근 가입한 사용자들 조회 (프로필 이미지가 있는 사용자 우선, 최대 3명)
    List<MemberDTO> getRecentMembersWithProfile(@Param("limit") int limit);
    
    // 닉네임 자동완성 검색 (현재 사용자 제외)
    List<MemberDTO> searchNicknamesByQuery(@Param("query") String query, @Param("currentUserId") String currentUserId);

    // 자기소개 업데이트
    int updateBio(@Param("userId") String userId, @Param("bio") String bio);

    // 사용자 활동 통계 조회
    java.util.Map<String, Object> getUserActivityStats(@Param("userId") String userId);

    // 모든 사용자의 활동 통계 조회
    List<java.util.Map<String, Object>> getAllUsersActivityStats();

    // 이메일로 회원 찾기 (소셜 로그인용)
    MemberDTO findByEmail(String email);
}