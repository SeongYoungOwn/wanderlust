package com.tour.project.service;

import com.tour.project.dao.MemberDAO;
import com.tour.project.dto.MemberDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private MemberDAO memberDAO;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        MemberDTO member = memberDAO.getMember(username);

        if (member == null) {
            throw new UsernameNotFoundException("User not found with username: " + username);
        }

        List<SimpleGrantedAuthority> authorities = new ArrayList<>();

        // userRole에 따라 권한 설정
        if ("ADMIN".equals(member.getUserRole())) {
            authorities.add(new SimpleGrantedAuthority("ROLE_ADMIN"));
        } else {
            authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
        }

        // Spring Security User 객체 반환
        return User.builder()
                .username(member.getUserId())
                .password(member.getUserPassword())
                .authorities(authorities)
                .accountExpired(false)
                .accountLocked(!"ACTIVE".equals(member.getAccountStatus()))
                .credentialsExpired(false)
                .disabled(false)
                .build();
    }
}