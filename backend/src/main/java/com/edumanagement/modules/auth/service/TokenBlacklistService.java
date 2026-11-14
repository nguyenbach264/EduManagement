package com.edumanagement.modules.auth.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class TokenBlacklistService {

    private final RedisTemplate<String, Object> redisTemplate;
    private static final String BLACKLIST_PREFIX = "token:blacklist:";
    private static final String REFRESH_PREFIX = "token:refresh:";

    private final Map<String, ExpiringValue> fallbackStore = new ConcurrentHashMap<>();
    private volatile boolean redisFallbackLogged = false;

    private record ExpiringValue(String value, long expiresAtMillis) {
        boolean isExpired() {
            return System.currentTimeMillis() > expiresAtMillis;
        }
    }

    private void logFallbackOnce(Exception ex) {
        if (!redisFallbackLogged) {
            redisFallbackLogged = true;
            log.warn("Redis is unavailable ({}). Using in-memory token store fallback.", ex.getMessage());
        }
    }

    public void blacklistToken(String token, long remainingTimeMs) {
        if (remainingTimeMs <= 0) {
            return;
        }
        String key = BLACKLIST_PREFIX + token;
        try {
            redisTemplate.opsForValue().set(key, "revoked", remainingTimeMs, TimeUnit.MILLISECONDS);
        } catch (Exception ex) {
            logFallbackOnce(ex);
            fallbackStore.put(key, new ExpiringValue("revoked", System.currentTimeMillis() + remainingTimeMs));
        }
    }

    public boolean isBlacklisted(String token) {
        String key = BLACKLIST_PREFIX + token;
        try {
            return Boolean.TRUE.equals(redisTemplate.hasKey(key));
        } catch (Exception ex) {
            logFallbackOnce(ex);
            ExpiringValue entry = fallbackStore.get(key);
            if (entry == null) {
                return false;
            }
            if (entry.isExpired()) {
                fallbackStore.remove(key);
                return false;
            }
            return true;
        }
    }

    public void saveRefreshToken(String username, String refreshToken, long durationMs) {
        String key = REFRESH_PREFIX + username;
        try {
            redisTemplate.opsForValue().set(key, refreshToken, durationMs, TimeUnit.MILLISECONDS);
        } catch (Exception ex) {
            logFallbackOnce(ex);
            fallbackStore.put(key, new ExpiringValue(refreshToken, System.currentTimeMillis() + durationMs));
        }
    }

    public boolean isValidRefreshToken(String username, String refreshToken) {
        String key = REFRESH_PREFIX + username;
        try {
            Object stored = redisTemplate.opsForValue().get(key);
            return stored != null && stored.toString().equals(refreshToken);
        } catch (Exception ex) {
            logFallbackOnce(ex);
            ExpiringValue entry = fallbackStore.get(key);
            if (entry == null || entry.isExpired()) {
                fallbackStore.remove(key);
                return false;
            }
            return entry.value().equals(refreshToken);
        }
    }

    public void deleteRefreshToken(String username) {
        String key = REFRESH_PREFIX + username;
        try {
            redisTemplate.delete(key);
        } catch (Exception ex) {
            logFallbackOnce(ex);
            fallbackStore.remove(key);
        }
    }
}
