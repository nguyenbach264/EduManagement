package com.edumanagement.modules.auth.service;

import com.edumanagement.modules.auth.dto.request.ChangePasswordRequest;
import com.edumanagement.modules.auth.dto.request.LoginRequest;
import com.edumanagement.modules.auth.dto.request.RefreshTokenRequest;
import com.edumanagement.modules.auth.dto.response.TokenResponse;
import com.edumanagement.modules.auth.dto.response.UserProfileResponse;

public interface AuthService {

    TokenResponse login(LoginRequest request);

    TokenResponse refreshToken(RefreshTokenRequest request);

    TokenResponse rotateRefreshToken(String refreshToken);

    void logout(String accessToken, String refreshToken, String username);

    void changePassword(String username, ChangePasswordRequest request);

    UserProfileResponse getCurrentUserProfile(String username);
}
