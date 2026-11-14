# Hướng dẫn Triển khai & Cấu hình Production (Deployment Guide)

Tài liệu này hướng dẫn chi tiết quy trình đưa hệ thống **EduManagement** lên môi trường Production với Docker, Docker Compose và các tiêu chuẩn kiểm soát mã nguồn Git.

---

## 1. Danh mục Quản lý Git (What to Push vs Ignore)

Hệ thống đã được thiết lập sẵn các file `.gitignore` đa tầng (`root`, `backend`, `frontend`) theo chuẩn bảo mật và hiệu năng.

### ✅ Những gì BẮT BUỘC đẩy lên Git (Tracked in Git):
1. **Source Code:**
   - Backend: Toàn bộ mã nguồn Java trong `backend/src/main/java`, tài nguyên cấu hình `backend/src/main/resources` (bao gồm các migration Flyway trong `db/migration/`, `application.yml`, `application-dev.yml`, `application-prod.yml`).
   - Frontend: Toàn bộ mã nguồn React trong `frontend/src/`, `frontend/index.html`, `frontend/vite.config.js`, `frontend/tailwind.config.js`, `frontend/postcss.config.js`.
2. **Quản lý dependencies:**
   - `backend/pom.xml` (Maven dependencies).
   - `frontend/package.json` và `frontend/package-lock.json` (đảm bảo môi trường `npm ci` đồng nhất phiên bản).
3. **Cấu hình Container & Reverse Proxy:**
   - `docker-compose.yml` (root).
   - `backend/Dockerfile`, `backend/.dockerignore`.
   - `frontend/Dockerfile`, `frontend/.dockerignore`, `frontend/nginx.conf`.
4. **Mẫu biến môi trường & Tài liệu:**
   - `.env.example` (chứa các biến mẫu, KHÔNG chứa mật khẩu thật).
   - `README.md`, `DEPLOYMENT.md`.
   - Tất cả các file `.gitignore` (`.gitignore`, `backend/.gitignore`, `frontend/.gitignore`).

### ❌ Những gì TUYỆT ĐỐI KHÔNG đẩy lên Git (Ignored in Git):
1. **File bí mật và môi trường thật:**
   - `.env`, `.env.local`, `.env.*.local`, các khóa SSL `*.pem`, `*.key`.
2. **Build artifacts & Dependencies đã tải về:**
   - `backend/target/`, `*.jar`, `*.war`.
   - `frontend/node_modules/`, `frontend/dist/`, `.vite/`.
3. **Dữ liệu Database & Cache runtime:**
   - `postgres_data/`, `redis_data/`, file dump database cục bộ.
4. **File logs & chẩn đoán:**
   - `*.log`, `logs/`, `npm-debug.log*`.
5. **Cấu hình cá nhân của IDE:**
   - `.idea/`, `.vscode/` (ngoại trừ các file cấu hình khuyến nghị), file `.iml`.
6. **File tạm của hệ điều hành:**
   - `.DS_Store`, `Thumbs.db`.

---

## 2. Chuẩn bị Môi trường Production

### Yêu cầu hệ thống:
- Hệ điều hành: Linux (Ubuntu 22.04 LTS / Debian 12 / RHEL 9) hoặc Windows Server / macOS có Docker.
- Docker Engine >= 24.0
- Docker Compose >= 2.20

### Bước 1: Khởi tạo file môi trường `.env`
Sao chép từ file mẫu `.env.example`:
```bash
cp .env.example .env
```
Mở file `.env` và cập nhật các thông số bảo mật:
- `POSTGRES_PASSWORD`: Mật khẩu cơ sở dữ liệu mạnh (tối thiểu 16 ký tự).
- `REDIS_PASSWORD`: Mật khẩu Redis cache.
- `JWT_SECRET`: Chuỗi khóa ký JWT có độ dài >= 64 ký tự hex. Bạn có thể sinh bằng lệnh:
  ```bash
  openssl rand -hex 64
  ```

---

## 3. Khởi chạy Hệ thống với Docker Compose

### Khởi tạo và chạy nền toàn bộ dịch vụ:
```bash
docker compose up -d --build
```

### Kiểm tra trạng thái và Healthcheck các container:
```bash
docker compose ps
```
Cả 4 container sẽ đạt trạng thái `Up (healthy)`:
- `edumanagement-postgres`: CSDL PostgreSQL 16 (Healthcheck qua `pg_isready`).
- `edumanagement-redis`: In-memory Cache & Blacklist Refresh Token (Healthcheck qua `redis-cli ping`).
- `edumanagement-backend`: Spring Boot 3.3.5 / Java 21 Temurin (Healthcheck qua Spring Actuator `/api/v1/actuator/health`).
- `edumanagement-frontend`: Nginx Alpine serving React SPA & Reverse Proxy `/api/` (Healthcheck qua `/health`).

### Xem log hệ thống:
```bash
# Xem log toàn bộ hệ thống
docker compose logs -f

# Xem log riêng Backend
docker compose logs -f backend

# Xem log riêng Frontend
docker compose logs -f frontend
```

---

## 4. Kiểm tra Sau Triển khai (Post-Deployment Verification)

1. **Giao diện Web:** Truy cập qua trình duyệt tại `http://<IP-HOAC-DOMAIN>/` (mặc định port 80).
2. **API Backend:** Truy cập endpoint kiểm tra sức khỏe `http://<IP-HOAC-DOMAIN>/api/v1/actuator/health`. Phản hồi chuẩn:
   ```json
   {"status":"UP"}
   ```
3. **Database Migration:** Flyway tự động phát hiện và thực thi các migration từ `V1` đến `V13` khi container backend khởi động lần đầu, không cần chạy script thủ công.

---

## 5. Dừng & Khởi động lại Hệ thống

```bash
# Dừng toàn bộ dịch vụ (giữ nguyên dữ liệu trong Docker Volumes)
docker compose stop

# Khởi động lại dịch vụ
docker compose start

# Tắt và giải phóng container (dữ liệu postgres_data và redis_data vẫn được giữ an toàn)
docker compose down

# Khi cần cập nhật code mới từ Git:
git pull origin main
docker compose up -d --build
```

---

## 6. Sao lưu & Phục hồi Cơ sở Dữ liệu (Backup & Restore)

### Sao lưu tự động vào file `.sql`:
```bash
docker exec -t edumanagement-postgres pg_dump -U postgres edumanagement > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Phục hồi cơ sở dữ liệu từ file backup:
```bash
cat backup_file.sql | docker exec -i edumanagement-postgres psql -U postgres -d edumanagement
```
