import React, { createContext, useContext, useEffect, useState } from 'react';
import { authApi } from '../api/services';

const AuthContext = createContext(undefined);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  const refreshProfile = async () => {
    try {
      // Browser automatically attaches HttpOnly accessToken cookie
      const profile = await authApi.getProfile();
      setUser(profile);
    } catch {
      setUser(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refreshProfile();

    const handleAuthExpired = () => {
      setUser(null);
    };

    window.addEventListener('auth:expired', handleAuthExpired);
    return () => window.removeEventListener('auth:expired', handleAuthExpired);
  }, []);

  const login = async (username, password) => {
    // Backend returns HttpOnly cookies (accessToken, refreshToken)
    await authApi.login({ username, password });
    const profile = await authApi.getProfile();
    setUser(profile);
    return profile;
  };

  const logout = async () => {
    try {
      // Backend revokes refresh token in Redis, blacklists access token, and clears HttpOnly cookies
      await authApi.logout();
    } catch {
      // Ignore network error on logout
    } finally {
      setUser(null);
    }
  };

  const hasRole = (role) => Boolean(user?.roles?.includes(role));
  const primaryRole = user?.roles?.includes('ROLE_ADMIN')
    ? 'ROLE_ADMIN'
    : user?.roles?.includes('ROLE_TEACHER')
    ? 'ROLE_TEACHER'
    : user?.roles?.includes('ROLE_STUDENT')
    ? 'ROLE_STUDENT'
    : null;

  return (
    <AuthContext.Provider
      value={{
        user,
        loading,
        isAuthenticated: Boolean(user),
        hasRole,
        primaryRole,
        login,
        logout,
        refreshProfile,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used inside AuthProvider');
  return ctx;
}
