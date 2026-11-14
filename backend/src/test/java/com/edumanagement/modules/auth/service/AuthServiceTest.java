package com.edumanagement.modules.auth.service;

import com.edumanagement.common.constant.RoleEnum;
import com.edumanagement.modules.auth.dto.request.LoginRequest;
import com.edumanagement.modules.auth.dto.response.TokenResponse;
import com.edumanagement.modules.user.entity.Role;
import com.edumanagement.modules.user.entity.User;
import com.edumanagement.modules.user.repository.UserRepository;
import com.edumanagement.security.JwtTokenProvider;
import com.edumanagement.security.UserPrincipal;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private JwtTokenProvider tokenProvider;

    @Mock
    private TokenBlacklistService tokenBlacklistService;

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthServiceImpl authService;

    @Test
    @DisplayName("Đăng nhập đúng tài khoản và mật khẩu -> Trả về Access Token & Refresh Token")
    void testLoginSuccess() {
        LoginRequest request = LoginRequest.builder()
                .username("student1")
                .password("123456")
                .build();

        Role studentRole = Role.builder().name(RoleEnum.ROLE_STUDENT).build();
        User user = User.builder()
                .username("student1")
                .fullName("Nguyễn Văn An")
                .email("an@sv.haui.edu.vn")
                .password("encoded_pass")
                .active(true)
                .roles(Set.of(studentRole))
                .build();
        user.setId(3L);

        UserPrincipal principal = UserPrincipal.create(user);
        Authentication auth = new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(auth);
        when(tokenProvider.generateAccessToken(principal)).thenReturn("mock_access_token");
        when(tokenProvider.generateRefreshToken("student1")).thenReturn("mock_refresh_token");

        TokenResponse response = authService.login(request);

        assertNotNull(response);
        assertEquals("mock_access_token", response.getAccessToken());
        assertEquals("mock_refresh_token", response.getRefreshToken());
        assertEquals("student1", response.getUsername());
        assertTrue(response.getRoles().contains("ROLE_STUDENT"));
    }
}
