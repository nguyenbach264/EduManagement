package com.edumanagement.modules.auth.controller;

import com.edumanagement.common.dto.ApiResponse;
import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.modules.auth.dto.request.ChangePasswordRequest;
import com.edumanagement.modules.auth.dto.request.ForgotPasswordDtos.*;
import com.edumanagement.modules.auth.dto.request.LoginRequest;
import com.edumanagement.modules.auth.dto.request.RefreshTokenRequest;
import com.edumanagement.modules.auth.dto.response.TokenResponse;
import com.edumanagement.modules.auth.dto.response.UserProfileResponse;
import com.edumanagement.modules.auth.service.AuthService;
import com.edumanagement.modules.auth.service.PasswordResetService;
import com.edumanagement.security.JwtTokenProvider;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Các API xác thực tài khoản, cấp và xoay vòng token (Access Token, Refresh Token, HttpOnly Cookie)")
public class AuthController {

    private final AuthService authService;
    private final PasswordResetService passwordResetService;
    private final JwtTokenProvider tokenProvider;

    private ResponseCookie createAccessTokenCookie(String accessToken, long maxAgeSeconds) {
        return ResponseCookie.from("accessToken", accessToken != null ? accessToken : "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(maxAgeSeconds)
                .sameSite("Lax")
                .build();
    }

    private ResponseCookie createRefreshTokenCookie(String refreshToken, long maxAgeSeconds) {
        return ResponseCookie.from("refreshToken", refreshToken != null ? refreshToken : "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(maxAgeSeconds)
                .sameSite("Lax")
                .build();
    }

    @PostMapping("/login")
    @Operation(summary = "Đăng nhập hệ thống", description = "Xác thực username/password và trả về HttpOnly Cookies (accessToken, refreshToken)")
    public ResponseEntity<ApiResponse<TokenResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletResponse response) {
        TokenResponse tokenResponse = authService.login(request);

        ResponseCookie accessCookie = createAccessTokenCookie(
                tokenResponse.getAccessToken(),
                tokenProvider.getAccessTokenExpirationMs() / 1000
        );
        ResponseCookie refreshCookie = createRefreshTokenCookie(
                tokenResponse.getRefreshToken(),
                tokenProvider.getRefreshTokenExpirationMs() / 1000
        );
        response.addHeader(HttpHeaders.SET_COOKIE, accessCookie.toString());
        response.addHeader(HttpHeaders.SET_COOKIE, refreshCookie.toString());

        return ResponseEntity.ok(ApiResponse.ok("Đăng nhập thành công", tokenResponse));
    }

    @PostMapping("/refresh-token")
    @Operation(summary = "Làm mới Access Token & Xoay vòng Refresh Token (Token Rotation)", description = "Sử dụng Refresh Token từ HttpOnly Cookie (hoặc body) để cấp Access Token mới và xoay vòng Refresh Token")
    public ResponseEntity<ApiResponse<TokenResponse>> refreshToken(
            @CookieValue(name = "refreshToken", required = false) String cookieRefreshToken,
            @RequestBody(required = false) RefreshTokenRequest request,
            HttpServletResponse response) {

        String token = cookieRefreshToken;
        if (!StringUtils.hasText(token) && request != null) {
            token = request.getRefreshToken();
        }

        if (!StringUtils.hasText(token)) {
            throw new AppException(ErrorCode.UNAUTHORIZED, "Refresh token không được để trống");
        }

        TokenResponse tokenResponse = authService.rotateRefreshToken(token);

        ResponseCookie accessCookie = createAccessTokenCookie(
                tokenResponse.getAccessToken(),
                tokenProvider.getAccessTokenExpirationMs() / 1000
        );
        ResponseCookie refreshCookie = createRefreshTokenCookie(
                tokenResponse.getRefreshToken(),
                tokenProvider.getRefreshTokenExpirationMs() / 1000
        );
        response.addHeader(HttpHeaders.SET_COOKIE, accessCookie.toString());
        response.addHeader(HttpHeaders.SET_COOKIE, refreshCookie.toString());

        return ResponseEntity.ok(ApiResponse.ok("Làm mới token thành công", tokenResponse));
    }

    @PostMapping("/logout")
    @Operation(summary = "Đăng xuất", description = "Đưa Access Token vào Redis Blacklist, vô hiệu hóa Refresh Token và xóa cả hai HttpOnly Cookies")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestHeader(value = HttpHeaders.AUTHORIZATION, required = false) String authHeader,
            @CookieValue(name = "accessToken", required = false) String cookieAccessToken,
            @CookieValue(name = "refreshToken", required = false) String cookieRefreshToken,
            @AuthenticationPrincipal UserDetails userDetails,
            HttpServletResponse response) {

        String accessToken = null;
        if (StringUtils.hasText(authHeader) && authHeader.startsWith("Bearer ")) {
            accessToken = authHeader.substring(7);
        } else if (StringUtils.hasText(cookieAccessToken)) {
            accessToken = cookieAccessToken;
        }

        String username = userDetails != null ? userDetails.getUsername() : null;
        authService.logout(accessToken, cookieRefreshToken, username);

        // Clear both HttpOnly cookies
        ResponseCookie clearAccessCookie = createAccessTokenCookie("", 0);
        ResponseCookie clearRefreshCookie = createRefreshTokenCookie("", 0);
        response.addHeader(HttpHeaders.SET_COOKIE, clearAccessCookie.toString());
        response.addHeader(HttpHeaders.SET_COOKIE, clearRefreshCookie.toString());

        return ResponseEntity.ok(ApiResponse.ok("Đăng xuất thành công", null));
    }

    @GetMapping("/profile")
    @Operation(summary = "Lấy thông tin cá nhân", description = "Lấy hồ sơ chi tiết của người dùng đang đăng nhập")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getProfile(@AuthenticationPrincipal UserDetails userDetails) {
        UserProfileResponse response = authService.getCurrentUserProfile(userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PutMapping("/change-password")
    @Operation(summary = "Đổi mật khẩu", description = "Đổi mật khẩu tài khoản hiện tại")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(userDetails.getUsername(), request);
        return ResponseEntity.ok(ApiResponse.ok("Đổi mật khẩu thành công", null));
    }

    @PostMapping("/forgot-password/send-otp")
    @Operation(summary = "Quên mật khẩu - Bước 1: Gửi mã OTP xác thực qua Email", description = "Tạo mã OTP 6 số lưu vào Redis với thời hạn 5 phút và mô phỏng gửi email")
    public ResponseEntity<ApiResponse<SendOtpResponse>> sendForgotPasswordOtp(
            @Valid @RequestBody SendOtpRequest request) {
        SendOtpResponse response = passwordResetService.generateAndSendOtp(request);
        return ResponseEntity.ok(ApiResponse.ok(response));
    }

    @PostMapping("/forgot-password/verify-and-reset")
    @Operation(summary = "Quên mật khẩu - Bước 2: Xác nhận mã OTP từ Redis và Đặt lại mật khẩu mới")
    public ResponseEntity<ApiResponse<Void>> verifyOtpAndResetPassword(
            @Valid @RequestBody VerifyOtpAndResetRequest request) {
        passwordResetService.verifyOtpAndResetPassword(request);
        return ResponseEntity.ok(ApiResponse.ok("Mật khẩu của bạn đã được đặt lại thành công. Vui lòng đăng nhập với mật khẩu mới.", null));
    }
}
