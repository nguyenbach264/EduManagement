package com.edumanagement.modules.auth.service;

import com.edumanagement.common.exception.AppException;
import com.edumanagement.common.exception.ErrorCode;
import com.edumanagement.common.exception.ResourceNotFoundException;
import com.edumanagement.modules.auth.dto.request.ForgotPasswordDtos.*;
import com.edumanagement.modules.user.entity.User;
import com.edumanagement.modules.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String OTP_PREFIX = "edu:pwd_reset:otp:";
    private static final long OTP_EXPIRATION_SECONDS = 300; // 5 minutes
    private static final SecureRandom RANDOM = new SecureRandom();

    private final Map<String, ExpiringOtp> fallbackStore = new ConcurrentHashMap<>();
    private volatile boolean redisFallbackLogged = false;

    private record ExpiringOtp(String otp, long expiresAtMillis) {
        boolean isExpired() {
            return System.currentTimeMillis() > expiresAtMillis;
        }
    }

    private void logFallbackOnce(Exception ex) {
        if (!redisFallbackLogged) {
            redisFallbackLogged = true;
            log.warn("Redis is unavailable ({}). Using in-memory fallback for password reset OTP.", ex.getMessage());
        }
    }

    private User findUserByIdentifier(String identifier) {
        String clean = identifier.trim();
        return userRepository.findByUsername(clean)
                .or(() -> userRepository.findByEmail(clean))
                .orElseThrow(() -> new ResourceNotFoundException("Tài khoản hoặc email '" + identifier + "' không tồn tại trong hệ thống"));
    }

    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) return email;
        int atIdx = email.indexOf("@");
        String name = email.substring(0, atIdx);
        String domain = email.substring(atIdx);
        if (name.length() <= 2) {
            return name.charAt(0) + "***" + domain;
        }
        return name.substring(0, 2) + "***" + domain;
    }

    public SendOtpResponse generateAndSendOtp(SendOtpRequest request) {
        User user = findUserByIdentifier(request.getIdentifier());

        if (!user.isActive()) {
            throw new AppException(ErrorCode.FORBIDDEN, "Tài khoản này hiện đang bị khóa hoặc chưa được kích hoạt");
        }

        // Generate 6-digit OTP
        int code = 100000 + RANDOM.nextInt(900000);
        String otp = String.valueOf(code);

        String key = OTP_PREFIX + user.getUsername().toLowerCase();

        // 1. Try Redis first, fallback to memory
        try {
            redisTemplate.opsForValue().set(key, otp, OTP_EXPIRATION_SECONDS, TimeUnit.SECONDS);
            log.info("Saved OTP to Redis for user: {}", user.getUsername());
        } catch (Exception ex) {
            logFallbackOnce(ex);
            fallbackStore.put(key, new ExpiringOtp(otp, System.currentTimeMillis() + (OTP_EXPIRATION_SECONDS * 1000)));
        }

        // 2. Simulated email sending log
        log.info("================================================================================");
        log.info("📧 [SIMULATED EMAIL SERVICE] Mã OTP đặt lại mật khẩu cho tài khoản: {}", user.getUsername());
        log.info("📧 Gửi tới email: {} | Họ tên: {}", user.getEmail(), user.getFullName());
        log.info("🔑 MÃ OTP CỦA BẠN LÀ: [{}] (Hiệu lực trong 5 phút)", otp);
        log.info("================================================================================");

        return SendOtpResponse.builder()
                .message("Mã xác thực OTP đã được gửi đến hòm thư liên kết của bạn.")
                .maskedEmail(maskEmail(user.getEmail()))
                .demoOtp(otp) // Cho phép hiển thị demo để test nhanh trên giao diện
                .expiresInSeconds(OTP_EXPIRATION_SECONDS)
                .build();
    }

    @Transactional
    public void verifyOtpAndResetPassword(VerifyOtpAndResetRequest request) {
        User user = findUserByIdentifier(request.getIdentifier());
        String key = OTP_PREFIX + user.getUsername().toLowerCase();

        String cachedOtp = null;

        // 1. Check Redis first
        try {
            Object obj = redisTemplate.opsForValue().get(key);
            if (obj != null) {
                cachedOtp = obj.toString();
            }
        } catch (Exception ex) {
            logFallbackOnce(ex);
        }

        // 2. Check fallback store
        if (cachedOtp == null) {
            ExpiringOtp expiringOtp = fallbackStore.get(key);
            if (expiringOtp != null && !expiringOtp.isExpired()) {
                cachedOtp = expiringOtp.otp();
            } else if (expiringOtp != null && expiringOtp.isExpired()) {
                fallbackStore.remove(key);
            }
        }

        if (cachedOtp == null) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Mã OTP đã hết hạn hoặc chưa được tạo. Vui lòng bấm 'Gửi lại mã OTP'.");
        }

        if (!cachedOtp.equals(request.getOtp().trim())) {
            throw new AppException(ErrorCode.BAD_REQUEST, "Mã OTP không chính xác. Vui lòng kiểm tra lại.");
        }

        // 3. OTP verified successfully -> Update password
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);

        // 4. Invalidate OTP from Redis and fallback store
        try {
            redisTemplate.delete(key);
        } catch (Exception ignored) {}
        fallbackStore.remove(key);

        log.info("User {} successfully reset password using OTP verification.", user.getUsername());
    }
}
