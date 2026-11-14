package com.edumanagement.modules.auth.service;

import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.common.exception.ResourceNotFoundException;
import com.edumanagement.modules.auth.dto.request.ChangePasswordRequest;
import com.edumanagement.modules.auth.dto.request.LoginRequest;
import com.edumanagement.modules.auth.dto.request.RefreshTokenRequest;
import com.edumanagement.modules.auth.dto.response.TokenResponse;
import com.edumanagement.modules.auth.dto.response.UserProfileResponse;
import com.edumanagement.modules.student.entity.Student;
import com.edumanagement.modules.student.entity.Teacher;
import com.edumanagement.modules.student.repository.StudentRepository;
import com.edumanagement.modules.student.repository.TeacherRepository;
import com.edumanagement.modules.user.entity.User;
import com.edumanagement.modules.user.repository.UserRepository;
import com.edumanagement.security.JwtTokenProvider;
import com.edumanagement.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final TokenBlacklistService tokenBlacklistService;
    private final UserRepository userRepository;
    private final StudentRepository studentRepository;
    private final TeacherRepository teacherRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.jwt.access-token-expiration-ms}")
    private long accessTokenExpirationMs;

    @Override
    public TokenResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );

        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        String accessToken = tokenProvider.generateAccessToken(userPrincipal);
        String refreshToken = tokenProvider.generateRefreshToken(userPrincipal.getUsername());

        return TokenResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .expiresIn(accessTokenExpirationMs / 1000)
                .username(userPrincipal.getUsername())
                .fullName(userPrincipal.getFullName())
                .roles(userPrincipal.getAuthorities().stream()
                        .map(a -> a.getAuthority())
                        .collect(Collectors.toList()))
                .build();
    }

    @Override
    public TokenResponse rotateRefreshToken(String refreshToken) {
        if (!org.springframework.util.StringUtils.hasText(refreshToken) || !tokenProvider.validateToken(refreshToken)) {
            throw new AppException(ErrorCode.TOKEN_REVOKED, "Refresh token không hợp lệ hoặc đã hết hạn");
        }

        String username;
        try {
            username = tokenProvider.getUsernameFromToken(refreshToken);
        } catch (Exception ex) {
            throw new AppException(ErrorCode.TOKEN_REVOKED, "Refresh token không hợp lệ");
        }

        // Reuse detection: verify that this refresh token is the currently active one for this user
        if (!tokenBlacklistService.isValidRefreshToken(username, refreshToken)) {
            // Potential token replay: revoke stored token to protect account
            tokenBlacklistService.deleteRefreshToken(username);
            throw new AppException(ErrorCode.TOKEN_REVOKED, "Phiên đăng nhập không hợp lệ hoặc token đã được sử dụng trước đó. Vui lòng đăng nhập lại.");
        }

        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User", "username", username));

        if (!user.isActive()) {
            throw new AppException(ErrorCode.FORBIDDEN, "Tài khoản đã bị vô hiệu hóa");
        }

        UserPrincipal userPrincipal = UserPrincipal.create(user);
        String newAccessToken = tokenProvider.generateAccessToken(userPrincipal);
        // Rotate: generates a new refresh token and saves it in tokenBlacklistService, overwriting the old one
        String newRefreshToken = tokenProvider.generateRefreshToken(user.getUsername());

        return TokenResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .expiresIn(accessTokenExpirationMs / 1000)
                .username(user.getUsername())
                .fullName(user.getFullName())
                .roles(user.getRoles().stream().map(r -> r.getName().name()).collect(Collectors.toList()))
                .build();
    }

    @Override
    public TokenResponse refreshToken(RefreshTokenRequest request) {
        if (request == null || !org.springframework.util.StringUtils.hasText(request.getRefreshToken())) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Refresh token không được để trống");
        }
        return rotateRefreshToken(request.getRefreshToken());
    }

    @Override
    public void logout(String accessToken, String refreshToken, String username) {
        if (org.springframework.util.StringUtils.hasText(accessToken)) {
            long remainingTimeMs = tokenProvider.getRemainingExpirationMs(accessToken);
            if (remainingTimeMs > 0) {
                tokenBlacklistService.blacklistToken(accessToken, remainingTimeMs);
            }
        }

        String targetUser = username;
        if (!org.springframework.util.StringUtils.hasText(targetUser) && org.springframework.util.StringUtils.hasText(refreshToken)) {
            try {
                targetUser = tokenProvider.getUsernameFromToken(refreshToken);
            } catch (Exception ignored) {}
        }
        if (!org.springframework.util.StringUtils.hasText(targetUser) && org.springframework.util.StringUtils.hasText(accessToken)) {
            try {
                targetUser = tokenProvider.getUsernameFromToken(accessToken);
            } catch (Exception ignored) {}
        }

        if (org.springframework.util.StringUtils.hasText(targetUser)) {
            tokenBlacklistService.deleteRefreshToken(targetUser);
        }
    }

    @Override
    @Transactional
    public void changePassword(String username, ChangePasswordRequest request) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User", "username", username));

        if (!passwordEncoder.matches(request.getCurrentPassword(), user.getPassword())) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Mật khẩu hiện tại không chính xác");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // Revoke existing refresh token to force re-login on other devices
        tokenBlacklistService.deleteRefreshToken(username);
    }

    @Override
    @Transactional(readOnly = true)
    public UserProfileResponse getCurrentUserProfile(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User", "username", username));

        UserProfileResponse.UserProfileResponseBuilder builder = UserProfileResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .roles(user.getRoles().stream().map(r -> r.getName().name()).collect(Collectors.toList()));

        studentRepository.findByUserId(user.getId()).ifPresent(s -> {
            builder.studentCode(s.getStudentCode());
            builder.cohort(s.getCohort());
            builder.academicStatus(s.getStatus().name());
            builder.dateOfBirth(s.getDateOfBirth());
            builder.gender(s.getGender());
            builder.address(s.getAddress());
            builder.className(s.getClassName());
            builder.province(s.getProvince());
            if (s.getDepartment() != null) {
                builder.departmentId(s.getDepartment().getId());
                builder.departmentName(s.getDepartment().getName());
                builder.departmentCode(s.getDepartment().getCode());
            }
            if (s.getAcademicProgram() != null) {
                builder.programId(s.getAcademicProgram().getId());
                builder.programName(s.getAcademicProgram().getName());
                builder.programCode(s.getAcademicProgram().getCode());
            }
        });

        teacherRepository.findByUserId(user.getId()).ifPresent(t -> {
            builder.teacherCode(t.getTeacherCode());
            builder.academicRank(t.getAcademicRank());
            builder.academicTitle(t.getAcademicTitle());
            builder.officeAddress(t.getOfficeAddress());
            if (t.getPhone() != null) builder.phone(t.getPhone());
            if (t.getEmail() != null) builder.email(t.getEmail());
            if (t.getDepartment() != null) {
                builder.departmentName(t.getDepartment().getName());
                builder.departmentCode(t.getDepartment().getCode());
            }
        });

        return builder.build();
    }
}
