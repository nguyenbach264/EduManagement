package com.edumanagement.modules.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

public class ForgotPasswordDtos {

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SendOtpRequest {
        @NotBlank(message = "Vui lòng nhập Mã sinh viên, Tên đăng nhập hoặc Email")
        private String identifier;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SendOtpResponse {
        private String message;
        private String maskedEmail;
        private String demoOtp; // Hiển thị mã OTP mô phỏng để thuận tiện kiểm thử
        private long expiresInSeconds;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class VerifyOtpAndResetRequest {
        @NotBlank(message = "Vui lòng nhập Mã sinh viên, Tên đăng nhập hoặc Email")
        private String identifier;

        @NotBlank(message = "Vui lòng nhập mã OTP 6 số")
        @Size(min = 6, max = 6, message = "Mã OTP gồm đúng 6 chữ số")
        private String otp;

        @NotBlank(message = "Mật khẩu mới không được để trống")
        @Size(min = 6, message = "Mật khẩu mới tối thiểu 6 ký tự")
        private String newPassword;
    }
}
