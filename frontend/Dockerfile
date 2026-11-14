# ==============================================================================
# Multi-stage Dockerfile for EduManagement Frontend (React + Vite + Tailwind CSS)
# Stage 1: Build static assets using Node.js 22 Alpine
# Stage 2: Serve optimized assets with Nginx Alpine
# ==============================================================================

# ----------------- STAGE 1: Build Environment -----------------
FROM node:22-alpine AS builder

WORKDIR /app

# Install dependencies using clean install
COPY package.json package-lock.json ./
RUN npm ci --no-audit --prefer-offline

# Copy source code and build production bundle
COPY . .
RUN npm run build

# ----------------- STAGE 2: Production Nginx Server -----------------
FROM nginx:1.27-alpine AS runner

# Remove default Nginx HTML & configs
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html/*

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled SPA static assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose HTTP port
EXPOSE 80

# Health check using lightweight wget against /health endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://localhost/health || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
