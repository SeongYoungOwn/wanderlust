package com.tour.project.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private LoginSuccessHandler loginSuccessHandler;

    @Autowired
    private LoginFailureHandler loginFailureHandler;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()  // 개발 단계에서 CSRF 비활성화 (프로덕션에서는 활성화 권장)
            .authorizeHttpRequests(authorize -> authorize
                .antMatchers(
                    "/",
                    "/home",
                    "/member/login",
                    "/member/signup",
                    "/member/register",
                    "/member/api/**",
                    "/api/mobile/**",
                    "/css/**",
                    "/js/**",
                    "/images/**",
                    "/resources/**",
                    "/uploads/**",
                    "/error"
                ).permitAll()
                .antMatchers("/admin/**").hasRole("ADMIN")
                .anyRequest().permitAll()
            )
            .formLogin(form -> form
                .loginPage("/member/login")
                .loginProcessingUrl("/member/login")
                .usernameParameter("userId")  // 폼에서 사용하는 필드 이름
                .passwordParameter("userPassword")  // 폼에서 사용하는 필드 이름
                .successHandler(loginSuccessHandler)
                .failureHandler(loginFailureHandler)
                .permitAll()
            )
            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout=true")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
