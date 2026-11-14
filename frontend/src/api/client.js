import axios from 'axios';

export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true, // Automatically sends and receives HttpOnly cookies (accessToken, refreshToken)
});

export function getErrorMessage(error) {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data;
    if (data?.errors && typeof data.errors === 'object') {
      const firstErr = Object.values(data.errors)[0];
      if (firstErr) return firstErr;
    }
    if (data?.message) return data.message;
    return error.message;
  }
  if (error instanceof Error) return error.message;
  return 'Đã xảy ra lỗi không xác định';
}

apiClient.interceptors.request.use((config) => {
  // With HttpOnly cookies enabled, the browser manages and attaches tokens automatically.
  // Explicit headers (e.g. for API integrations) remain untouched.
  return config;
});

let isRefreshing = false;
let failedQueue = [];

const processQueue = (error) => {
  failedQueue.forEach((prom) => {
    if (error) prom.reject(error);
    else prom.resolve();
  });
  failedQueue = [];
};

apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    if (
      error.response?.status === 401 &&
      originalRequest &&
      !originalRequest._retry &&
      !originalRequest.url?.includes('/auth/login') &&
      !originalRequest.url?.includes('/auth/refresh-token')
    ) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({
            resolve: () => resolve(apiClient(originalRequest)),
            reject,
          });
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        // Send refresh token request with withCredentials: true so HttpOnly refreshToken cookie is included
        await axios.post(
          `${API_BASE_URL}/auth/refresh-token`,
          {},
          { withCredentials: true, headers: { 'Content-Type': 'application/json' } }
        );
        // Server responded with fresh HttpOnly accessToken & refreshToken cookies
        processQueue(null);
        return apiClient(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError);
        window.dispatchEvent(new CustomEvent('auth:expired'));
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }
    return Promise.reject(error);
  }
);
