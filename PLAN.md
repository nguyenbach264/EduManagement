# 🎓 EduManagement - Core Academic & Credit Registration System

> **Dự án Intern Fullstack (Solo 1-2 tháng)** | **Tech Stack: Java Spring Boot 3 + React (TypeScript) + PostgreSQL + Redis + Docker**  
> **Mục tiêu:** Tập trung giải quyết triệt để 3 bài toán lõi có sức nặng kỹ thuật cao nhất: **Auth/RBAC (6), Đăng ký tín chỉ & Lịch học - Xử lý Concurrency (5), Quản lý Sinh viên & Điểm - GPA (4)**.  
> **Phạm vi giao diện:** Cổng dịch vụ đào tạo nội bộ xoay quanh **3 Actors: Admin, Teacher, Student** (Loại bỏ hoàn toàn CMS tin tức, trang công cộng, landing page râu ria).

---

## Mục lục

1. [Định vị bài toán & 3 Trụ cột cốt lõi](#1-định-vị-bài-toán--3-trụ-cột-cốt-lõi)
2. [Phạm vi hệ thống theo 3 Actors](#2-phạm-vi-hệ-thống-theo-3-actors)
3. [Kiến trúc hệ thống & Xử lý kỹ thuật chuyên sâu](#3-kiến-trúc-hệ-thống--xử-lý-kỹ-thuật-chuyên-sâu)
4. [Thiết kế Database (ERD chuẩn hóa)](#4-thiết-kế-database-erd-chuẩn-hóa)
5. [Thiết kế API RESTful (Chi tiết theo Actors)](#5-thiết-kế-api-restful-chi-tiết-theo-actors)
6. [Thiết kế Frontend Portal (Giao diện 3 Roles)](#6-thiết-kế-frontend-portal-giao-diện-3-roles)
7. [Kế hoạch triển khai 6 tuần (Solo Timeline)](#7-kế-hoạch-triển-khai-6-tuần-solo-timeline)
8. [Điểm nhấn kỹ thuật ăn điểm phỏng vấn & Cách viết CV](#8-điểm-nhấn-kỹ-thuật-ăn-điểm-phỏng-vấn--cách-viết-cv)
9. [Master Prompt cho AI hỗ trợ Code](#9-master-prompt-cho-ai-hỗ-trợ-code)

---

## 1. Định vị bài toán & 3 Trụ cột cốt lõi

Thay vì làm một website thông tin chung chung (CMS/News/Landing Page), hệ thống định hình là **Cổng thông tin đào tạo và đăng ký học tập trực tuyến** (tương tự phân hệ `qldt.haui.edu.vn` và hệ thống Portal sinh viên/giảng viên).

Dự án tập trung giải quyết 3 bài toán xương sống trong hệ thống giáo dục đại học:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   3 BÀI TOÁN KỸ THUẬT NỀN TẢNG                         │
├───────────────────┬────────────────────────────┬───────────────────────┤
│  🔐 BÀI TOÁN 6    │       ⚡ BÀI TOÁN 5        │     📊 BÀI TOÁN 4     │
│   Auth & RBAC     │  Đăng ký Tín chỉ & TKB     │    Sinh viên & Điểm   │
├───────────────────┼────────────────────────────┼───────────────────────┤
│ • JWT + Rotation  │ • Tranh chấp slot (Race    │ • Quản lý hồ sơ SV    │
│ • RBAC 3 Actors   │   condition)               │ • Quy chế tín chỉ     │
│ • Method Security │ • Ràng buộc tiên quyết     │ • Bảng điểm chi tiết  │
│ • Blacklist Redis │ • Kiểm tra trùng lịch học  │ • Công thức GPA tích  │
│                   │ • Giới hạn max/min tín chỉ │   lũy thang 10 & 4    │
│                   │ • Pessimistic/Redis Lock   │ • Import/Export Excel │
│                   │                            │ • Xuất phiếu điểm PDF │
└───────────────────┴────────────────────────────┴───────────────────────┘
```

---

## 2. Phạm vi hệ thống theo 3 Actors

Loại bỏ hoàn toàn các trang blog, bài viết, giới thiệu. Toàn bộ ứng dụng bắt đầu từ **Màn hình Đăng nhập duy nhất** và điều hướng đến Dashboard theo quyền hạn:

### 2.1. Phân quyền chi tiết (RBAC)

| Chức năng | Admin (Phòng Đào tạo) | Teacher (Giảng viên) | Student (Sinh viên) |
|---|:---:|:---:|:---:|
| **Quản lý Tài khoản & Phân quyền** | Toàn quyền (CRUD) | Chỉ xem cá nhân | Chỉ xem cá nhân |
| **Quản lý Khoa / Ngành / CTĐT** | Toàn quyền (CRUD) | Xem thông tin | Xem CTĐT ngành mình |
| **Quản lý Môn học & Tiên quyết** | Toàn quyền (CRUD) | Xem thông tin | Tra cứu điều kiện môn |
| **Mở Lớp học phần & Lập TKB** | Toàn quyền cấu hình | Xem lớp được phân công | Xem lớp mở đăng ký |
| **Đăng ký / Hủy Lớp học phần** | Can thiệp / Ép ghi danh | ❌ | **Tự đăng ký / hủy môn** |
| **Nhập & Khóa Điểm học phần** | Quản trị / Mở khóa | **Nhập / Sửa / Nộp điểm** | ❌ (Chỉ xem) |
| **Bảng điểm & Tính GPA** | Xem toàn trường / Export | Xem bảng điểm lớp dạy | **Xem bảng điểm cá nhân** |
| **Import / Export dữ liệu** | Excel SV, Điểm, Môn học | Excel Điểm lớp dạy | Export PDF bảng điểm |

---

## 3. Kiến trúc hệ thống & Xử lý kỹ thuật chuyên sâu

### 3.1. Sơ đồ kiến trúc tổng thể

```
                           ┌────────────────────────┐
                           │      Nginx Proxy       │
                           │       (Port 80)        │
                           └───────────┬────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    ▼                                     ▼
        ┌───────────────────────┐             ┌───────────────────────┐
        │ React TypeScript SPA  │             │   Spring Boot 3 API   │
        │   (Vite + Ant Design) │             │     (Java 17 / 21)    │
        │      (Port 3000)      │             │      (Port 8080)      │
        └───────────────────────┘             └───────────┬───────────┘
                                                          │
                                     ┌────────────────────┼───────────────────┐
                                     ▼                    ▼                   ▼
                           ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
                           │  PostgreSQL 16   │ │      Redis       │ │  Storage (Local/ │
                           │ (Relational Data)│ │ (Lock/Blacklist/ │ │   MinIO S3)      │
                           │   (Port 5432)    │ │  Cache Session)  │ │ (Excel/PDF files)│
                           └──────────────────┘ └──────────────────┘ └──────────────────┘
```

### 3.2. Điểm nhấn giải quyết Concurrency trong Đăng ký môn (Bài toán 5)

Vấn đề thực tế tại các trường đại học: Khi cổng đăng ký mở lúc 8h00, hàng ngàn sinh viên cùng tranh chấp một số lớp học phần có slot giới hạn (ví dụ: lớp tối đa 60 sinh viên, còn lại đúng 1 chỗ nhưng có 50 sinh viên nhấn Đăng ký cùng 1 giây).

**Giải pháp triển khai trong dự án:**
1. **Level 1 - Database Constraint & Pessimistic Locking:**
   - Sử dụng `SELECT ... FOR UPDATE` trên bảng `class_sections` trong transaction để khóa dòng dữ liệu lớp học phần trong tích tắc kiểm tra `current_enrolled < max_enrolled`.
2. **Level 2 (Nâng cao - Sức nặng CV): Distributed Lock với Redis Redisson:**
   - Acquire lock theo `class_section_id` trước khi bước vào logic kiểm tra lịch và ghi danh.
   - Giúp giảm áp lực lock trực tiếp trên PostgreSQL, tránh deadlocks ở DB connection pool.
3. **Optimistic Locking:**
   - Trường `@Version private Long version;` trên entity `ClassSection` để phòng ngừa lost updates.

### 3.3. Thuật toán kiểm tra điều kiện Đăng ký tín chỉ

Mỗi request đăng ký lớp học phần (`POST /api/v1/student/enrollments`) phải vượt qua chuỗi kiểm tra nghiêm ngặt (Chain of Validation):
1. **Trạng thái đợt đăng ký:** Đợt đăng ký hiện tại có đang mở (Open) và đúng đối tượng khóa/ngành hay không?
2. **Kiểm tra môn tiên quyết (Prerequisites):** Sinh viên đã hoàn thành và đạt (điểm tổng kết $\ge 4.0/10$) môn tiên quyết của môn này trong các kỳ trước chưa?
3. **Kiểm tra trùng môn/đã đăng ký:** Sinh viên đã đăng ký lớp học phần khác của cùng môn này trong kỳ chưa? (Tránh học trùng).
4. **Kiểm tra giới hạn tín chỉ kỳ học:** Tổng số tín chỉ sau khi cộng thêm môn này có nằm trong khoảng $[MinCredits, MaxCredits]$ (ví dụ: 12 - 25 tín chỉ) không?
5. **Kiểm tra trùng thời khóa biểu (Schedule Collision Check):** Lớp học phần đăng ký có bị trùng thứ, tiết học hoặc phòng học với bất kỳ lớp nào sinh viên đã đăng ký thành công trong kỳ không?
6. **Kiểm tra sĩ số (Slot Availability):** Lớp còn chỗ trống hay không (kèm cơ chế concurrency lock ở mục 3.2).

---

## 4. Thiết kế Database (ERD chuẩn hóa)

### 4.1. Quan hệ giữa các bảng (Loại bỏ CMS râu ria)

```
       ┌──────────────┐             ┌──────────────┐
       │    roles     │             │    users     │
       ├──────────────┤             ├──────────────┤
       │ id (PK)      │◄──┐     ┌───┤ id (PK)      │
       │ name         │   │     │   │ username     │
       └──────────────┘   │     │   │ password     │
                          │     │   │ email        │
       ┌──────────────┐   │     │   │ full_name    │
       │  user_roles  │   │     │   │ phone        │
       ├──────────────┤   │     │   │ is_active    │
       │ user_id (FK) ├───┼─────┘   └───────┬──────┘
       │ role_id (FK) ├───┘                 │
       └──────────────┘         ┌───────────┴───────────┐
                                │ 1:1                   │ 1:1
                                ▼                       ▼
                     ┌──────────────────────┐┌──────────────────────┐
                     │       students       ││       teachers       │
                     ├──────────────────────┤├──────────────────────┤
                     │ id (PK)              ││ id (PK)              │
                     │ user_id (FK, Unique) ││ user_id (FK, Unique) │
                     │ student_code (Unique)││ teacher_code (Unique)│
                     │ department_id (FK)   ││ department_id (FK)   │
                     │ program_id (FK)      ││ academic_rank        │
                     │ cohort (Khóa: 2021)  │└──────────┬───────────┘
                     │ academic_status      │           │
                     └──────────┬───────────┘           │
                                │                       │
 ┌──────────────────────────────┼───────────────────────┼──────────────────────────────┐
 │ ACADEMIC STRUCTURE           │                       │                              │
 │                              ▼                       │                              ▼
 │ ┌──────────────────┐   ┌──────────────────────┐      │                    ┌──────────────────┐
 │ │   departments    │   │  academic_programs   │      │                    │  class_sections  │
 │ ├──────────────────┤   ├──────────────────────┤      │                    ├──────────────────┤
 │ │ id (PK)          │◄──┤ id (PK)              │      │                    │ id (PK)          │
 │ │ code             │   │ department_id (FK)   │      │                    │ course_id (FK)   │
 │ │ name             │   │ code                 │      │                    │ semester_id (FK) │
 │ └────────┬─────────┘   │ name                 │      │                    │ teacher_id (FK)  │
 │          │             │ total_credits        │      │                    │ section_code     │
 │          ▼             └──────────┬───────────┘      │                    │ max_capacity     │
 │ ┌──────────────────┐              │                  │                    │ current_enrolled │
 │ │     courses      │              │                  │                    │ room             │
 │ ├──────────────────┤              │                  │                    │ day_of_week      │
 │ │ id (PK)          │              │                  │                    │ start_period     │
 │ │ department_id(FK)│              ▼                  │                    │ end_period       │
 │ │ code (Unique)    │   ┌──────────────────────┐      │                    │ status           │
 │ │ name             │   │   program_courses    │      │                    │ version (Lock)   │
 │ │ credits          │   ├──────────────────────┤      │                    └─────────┬────────┘
 │ │ theory_hours     │   │ program_id (FK)      │      │                              │
 │ │ practice_hours   │   │ course_id (FK)       │      │                              │
 │ └────────┬─────────┘   │ semester_index (1-8) │      │                              │
 │          │             │ is_compulsory (Bắt   │      │                              │
 │          │             │  buộc / Tự chọn)     │      │                              │
 │          │             └──────────────────────┘      │                              │
 └──────────┼───────────────────────────────────────────┼──────────────────────────────┘
            │                                           │                              │
            ▼                                           ▼                              ▼
 ┌──────────────────────┐                     ┌──────────────────┐           ┌──────────────────┐
 │ course_prerequisites │                     │   enrollments    │           │    semesters     │
 ├──────────────────────┤                     ├──────────────────┤           ├──────────────────┤
 │ course_id (FK)       │                     │ id (PK)          │           │ id (PK)          │
 │ prerequisite_id (FK) │                     │ student_id (FK)  │           │ code (20241)     │
 └──────────────────────┘                     │ class_section(FK)│           │ name (HK1 24-25) │
                                              │ enrolled_at      │           │ start_date       │
                                              │ status           │           │ end_date         │
                                              └────────┬─────────┘           │ is_register_open │
                                                       │                     └──────────────────┘
                                                       ▼
                                              ┌──────────────────┐
                                              │      grades      │
                                              ├──────────────────┤
                                              │ id (PK)          │
                                              │ enrollment_id(FK)│
                                              │ attendance_score │ (Chuyên cần: 10%)
                                              │ midterm_score    │ (Giữa kỳ: 30%)
                                              │ final_score      │ (Cuối kỳ: 60%)
                                              │ total_score_10   │ (Tự động tính)
                                              │ gpa_score_4      │ (Quy đổi thang 4)
                                              │ letter_grade     │ (A+, A, B, C, F..)
                                              │ is_locked        │ (GV đã nộp/khóa)
                                              └──────────────────┘
```

### 4.2. Logic tính điểm & Xếp loại theo Quy chế Đào tạo Tín chỉ

$$\text{Điểm tổng kết (10)} = (\text{Chuyên cần} \times 0.1) + (\text{Giữa kỳ} \times 0.3) + (\text{Cuối kỳ} \times 0.6)$$

| Điểm hệ 10 | Điểm chữ | Điểm hệ 4 | Đánh giá |
|:---:|:---:|:---:|:---|
| $9.0 - 10.0$ | **A+** | **4.0** | Xuất sắc |
| $8.5 - 8.9$  | **A**  | **3.7** | Giỏi |
| $8.0 - 8.4$  | **B+** | **3.5** | Khá giỏi |
| $7.0 - 7.9$  | **B**  | **3.0** | Khá |
| $6.5 - 6.9$  | **C+** | **2.5** | Trung bình khá |
| $5.5 - 6.4$  | **C**  | **2.0** | Trung bình |
| $5.0 - 5.4$  | **D+** | **1.5** | Trung bình yếu |
| $4.0 - 4.9$  | **D**  | **1.0** | Yếu (Đạt) |
| $< 4.0$      | **F**  | **0.0** | Không đạt (Phải học lại) |

$$\text{GPA (Kỳ / Tích lũy)} = \frac{\sum (\text{Điểm hệ 4}_i \times \text{Số tín chỉ}_i)}{\sum \text{Số tín chỉ}_i}$$

---

## 5. Thiết kế API RESTful (Chi tiết theo Actors)

Base URL: `/api/v1`

### 5.1. Authentication & Common (`/auth`, `/users`)
- `POST /auth/login` → Đăng nhập, trả về Access Token (15p) + Refresh Token (7 ngày trong Cookie HttpOnly) + User Role profile.
- `POST /auth/refresh-token` → Cấp Access Token mới khi token cũ hết hạn.
- `POST /auth/logout` → Thu hồi token (đẩy JTI vào Redis Blacklist với TTL tương ứng).
- `GET /auth/profile` → Trả về thông tin cá nhân và role permissions của người dùng hiện tại.
- `PUT /auth/change-password` → Đổi mật khẩu tài khoản.

---

### 5.2. Admin Portal APIs (`/admin/*` - Quyền: `ROLE_ADMIN`)

#### Quản lý Học vụ & Danh mục
- `GET/POST /admin/departments` → CRUD Khoa/Viện đào tạo.
- `GET/POST/PUT /admin/programs` → CRUD Chương trình đào tạo.
- `POST /admin/programs/{id}/courses` → Gán môn học vào khung chương trình theo kỳ (1-8).
- `GET/POST/PUT/DELETE /admin/courses` → CRUD Môn học, cấu hình số tín chỉ và môn tiên quyết.
- `GET/POST/PUT /admin/semesters` → Quản lý học kỳ, bật/tắt cổng đăng ký tín chỉ (`is_register_open`).

#### Quản lý Người dùng & Sinh viên
- `GET /admin/students` → Danh sách sinh viên (phân trang, search mã/tên, filter khoa/khóa/trạng thái).
- `POST /admin/students` → Tạo hồ sơ sinh viên kèm tài khoản đăng nhập mặc định.
- `POST /admin/students/import-excel` → Import hàng loạt hồ sơ sinh viên từ file Excel template (Apache POI).
- `GET/POST/PUT /admin/teachers` → Quản lý danh sách giảng viên.

#### Quản lý Lớp học phần & Điểm
- `GET/POST/PUT/DELETE /admin/class-sections` → Lập lớp học phần (gán GV, phòng, thứ, tiết, max slot).
- `POST /admin/class-sections/{id}/force-enroll` → Phòng đào tạo ép ghi danh sinh viên vào lớp.
- `DELETE /admin/class-sections/{id}/force-drop/{studentId}` → Hủy ghi danh sinh viên.
- `PUT /admin/grades/{gradeId}/unlock` → Mở quyền sửa điểm cho giảng viên khi có khiếu nại.
- `GET /admin/reports/gpa-statistics` → Thống kê phổ điểm, tỷ lệ sinh viên cảnh cáo học vụ theo kỳ.

---

### 5.3. Teacher Portal APIs (`/teacher/*` - Quyền: `ROLE_TEACHER`)
- `GET /teacher/classes` → Danh sách các lớp học phần được phân công giảng dạy trong học kỳ.
- `GET /teacher/classes/{sectionId}/students` → Danh sách sinh viên trong lớp học phần kèm bảng điểm hiện tại.
- `PUT /teacher/classes/{sectionId}/grades` → Cập nhật điểm thành phần (chuyên cần, giữa kỳ, cuối kỳ) theo lô (Batch update).
- `POST /teacher/classes/{sectionId}/grades/lock` → Khóa sổ điểm (chốt điểm, sinh viên và giảng viên không thể sửa trừ khi Admin mở khóa).
- `GET /teacher/classes/{sectionId}/export-excel` → Xuất bảng điểm lớp ra file Excel chính thức.

---

### 5.4. Student Portal APIs (`/student/*` - Quyền: `ROLE_STUDENT`)

#### Đăng ký tín chỉ & Thời khóa biểu
- `GET /student/registration/available-classes` → Lấy danh sách lớp học phần đang mở đăng ký trong kỳ (kèm filter môn, trạng thái còn chỗ/hết chỗ).
- `POST /student/registration/enroll` → **Đăng ký vào lớp học phần** (Thực hiện chuỗi validate và lock concurrency).  
  *Body:* `{ "classSectionId": 123 }`
- `POST /student/registration/drop` → **Hủy đăng ký lớp học phần**.  
  *Body:* `{ "classSectionId": 123 }`
- `GET /student/schedule` → Lấy thời khóa biểu học tập của sinh viên trong kỳ (dạng bảng tuần hoặc lịch học).

#### Kết quả học tập & Bảng điểm
- `GET /student/curriculum` → Khung chương trình đào tạo của ngành mình: môn đã học, môn chưa học, tiến độ tích lũy tín chỉ.
- `GET /student/grades` → Tra cứu điểm theo từng học kỳ: điểm thành phần, điểm chữ, GPA kỳ, GPA tích lũy.
- `GET /student/grades/export-pdf` → Tải về phiếu điểm tích lũy chính thức định dạng PDF (iTextPDF).

---

## 6. Thiết kế Frontend Portal (Giao diện 3 Roles)

### 6.1. Cấu trúc Routing sạch sẽ (Không trang public râu ria)

```
/login                     ───▶ Trang Đăng nhập duy nhất
/                          ───▶ Tự động redirect về Portal tương ứng dựa trên User Role

/admin/ (ROLE_ADMIN)
├── /dashboard             ───▶ Thống kê sinh viên, giảng viên, lớp học phần, tỷ lệ đăng ký
├── /departments-programs  ───▶ Quản lý Khoa & Chương trình khung đào tạo
├── /courses               ───▶ Quản lý Môn học & Điều kiện tiên quyết
├── /classes               ───▶ Quản lý Mở lớp học phần & Phân công lịch dạy
├── /students              ───▶ Quản lý Danh sách SV & Import Excel
└── /academic-records      ───▶ Tra cứu học bạ SV, bảng điểm, mở khóa điểm

/teacher/ (ROLE_TEACHER)
├── /dashboard             ───▶ Lịch dạy hôm nay & Thông báo học vụ
├── /my-classes            ───▶ Danh sách lớp học phần giảng dạy
├── /grade-entry/:id       ───▶ Bảng nhập điểm tương tác (Inline Edit) + Nộp điểm
└── /profile               ───▶ Thông tin giảng viên

/student/ (ROLE_STUDENT)
├── /dashboard             ───▶ Tóm tắt tín chỉ, GPA tích lũy, môn học trong kỳ
├── /registration          ───▶ GIAO DIỆN ĐĂNG KÝ TÍN CHỈ TRỰC TUYẾN
├── /timetable             ───▶ Thời khóa biểu tương tác dạng tuần
├── /academic-results      ───▶ Bảng điểm chi tiết từng kỳ & Nút xuất PDF
└── /curriculum-progress   ───▶ Tiến độ hoàn thành chương trình đào tạo
```

### 6.2. Wireframe 2 màn hình quan trọng nhất

#### Màn hình 1: Đăng ký Tín chỉ Trực tuyến (Student Registration)
```
┌────────────────────────────────────────────────────────────────────────┐
│ ĐĂNG KÝ HỌC PHẦN - HỌC KỲ 1 (2024 - 2025)     [Đang mở: Còn 02 ngày]   │
├────────────────────────────────────────────────────────────────────────┤
│ Tín chỉ đã chọn: [16 / Max 24]  |  Số môn: 5                           │
├────────────────────────────────────────────────────────────────────────┤
│ 🔍 Lọc môn theo CTĐT: [Tất cả ▾]   Mã/Tên môn: [Nhập tìm kiếm...]       │
│                                                                        │
│ LỚP HỌC PHẦN ĐANG MỞ:                                                  │
│ ┌──────┬──────────────────┬────┬───────────┬─────────┬───────┬───────┐ │
│ │Mã lớp│ Tên môn học      │TC  │ Lịch học  │ Sĩ số   │ Trạng │Thao   │ │
│ │      │                  │    │           │         │ thái  │ tác   │ │
│ ├──────┼──────────────────┼────┼───────────┼─────────┼───────┼───────┤ │
│ │IT4010│ Công nghệ Web    │ 3  │ Thứ 2 (1-3)│ 58/60   │Còn chỗ│[ĐKÝ]  │ │
│ │IT4020│ Hệ điều hành     │ 3  │ Thứ 4 (4-6)│ 60/60   │  HẾT  │[ĐẦY]  │ │
│ │IT4080│ Cơ sở dữ liệu    │ 3  │ Thứ 2 (1-3)│ 45/60   │TRÙNG  │[TRÙNG]│ │
│ └──────┴──────────────────┴────┴───────────┴─────────┴───────┴───────┘ │
│                                                                        │
│ CÁC LỚP BẠN ĐÃ ĐĂNG KÝ THÀNH CÔNG TRONG KỲ:                           │
│ ┌──────┬──────────────────┬────┬───────────┬──────────────┬──────────┐ │
│ │IT4010│ Công nghệ Web    │ 3  │ Thứ 2 (1-3)│ GV: TS. Nam  │  [HỦY]   │ │
│ │BS1010│ Giải tích 1      │ 4  │ Thứ 5 (7-9)│ GV: ThS. Mai │  [HỦY]   │ │
│ └──────┴──────────────────┴────┴───────────┴──────────────┴──────────┘ │
└────────────────────────────────────────────────────────────────────────┘
```

#### Màn hình 2: Bảng nhập điểm học phần (Teacher Grade Entry)
```
┌────────────────────────────────────────────────────────────────────────┐
│ LỚP HỌC PHẦN: IT4010.01 - Công nghệ Web | Học kỳ: 1 (2024-2025)        │
│ Sĩ số: 60  |  Trạng thái: [ Đang mở cập nhật ]                         │
├────────────────────────────────────────────────────────────────────────┤
│ [📥 Nhập từ Excel]   [📤 Xuất Excel]   [🔒 Khóa sổ & Nộp điểm]          │
│                                                                        │
│ ┌───┬──────────┬──────────────┬──────┬──────┬──────┬──────┬────┬─────┐ │
│ │STT│ Mã SV    │ Họ và tên    │CC 10%│GK 30%│CK 60%│Tổng10│Chữ │Hệ 4 │ │
│ ├───┼──────────┼──────────────┼──────┼──────┼──────┼──────┼────┼─────┤ │
│ │ 1 │ 20216001 │ Nguyễn Văn A │ 9.0  │ 8.0  │ 8.5  │ 8.4  │ B+ │ 3.5 │ │
│ │ 2 │ 20216002 │ Trần Thị B   │ 10.0 │ 9.0  │ 9.5  │ 9.4  │ A+ │ 4.0 │ │
│ │ 3 │ 20216003 │ Lê Hoàng C   │ 6.0  │ 4.0  │ 3.0  │ 3.6  │ F  │ 0.0 │ │
│ └───┴──────────┴──────────────┴──────┴──────┴──────┴──────┴────┴─────┘ │
│                                         [ Lưu nháp ]   [ Hủy bỏ ]      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Kế hoạch triển khai 6 tuần (Solo Timeline)

```
Tuần 1 │██████████│ Setup dự án, Docker Dev, Security & RBAC 3 Actors
Tuần 2 │██████████│ Quản lý Đào tạo: Khoa, Môn học, CTĐT, Tiên quyết
Tuần 3 │██████████│ Quản lý Sinh viên, Giảng viên & Import Excel
Tuần 4 │██████████│ Đăng ký Tín chỉ, Xử lý Trùng lịch & Concurrency Lock
Tuần 5 │██████████│ Quản lý Điểm, Tính GPA, Khóa điểm & Xuất PDF
Tuần 6 │██████████│ Docker Compose Fullstack, CI/CD, Test & Đóng gói CV
```

### Chi tiết công việc từng tuần:

#### Tuần 1: Setup Foundation & Security RBAC (3 Roles)
- [ ] Khởi tạo Spring Boot 3 + Maven (Java 17/21) và React 18 + Vite + TypeScript.
- [ ] Thiết lập `docker-compose.dev.yml` chạy PostgreSQL 16 và Redis.
- [ ] Flyway Migration: Tạo bảng `users`, `roles`, `user_roles`. Seed 3 tài khoản mặc định: `admin`, `teacher1`, `student1`.
- [ ] Cấu hình Spring Security 6 + JWT Authentication (AccessToken + RefreshToken).
- [ ] Endpoint `/auth/login`, `/auth/refresh-token`, `/auth/logout` (Redis token blacklist).
- [ ] Frontend: Cài đặt Ant Design, Axios interceptor tự động refresh token, cấu hình React Router với `ProtectedRoute` theo Role.
- [ ] Màn hình Đăng nhập duy nhất, đăng nhập xong điều hướng đúng Dashboard theo vai trò.

#### Tuần 2: Core Academic Structure (Khoa, Môn, Khung CTĐT)
- [ ] Migration: Bảng `departments`, `courses`, `course_prerequisites`, `academic_programs`, `program_courses`.
- [ ] Backend: CRUD Khoa, Môn học kèm danh sách môn tiên quyết (Self-referencing table).
- [ ] Backend: Thiết kế cấu trúc Khung chương trình đào tạo theo từng kỳ học (1-8).
- [ ] Frontend Admin: Quản lý danh mục Môn học (Giao diện chọn môn tiên quyết dạng Select đa chọn).
- [ ] Frontend Student: Màn hình xem Khung CTĐT của ngành mình học.

#### Tuần 3: Quản lý Hồ sơ Sinh viên, Giảng viên & Import Excel
- [ ] Migration: Bảng `students`, `teachers`, `semesters`.
- [ ] Backend: CRUD Sinh viên và Giảng viên (tự động tạo user account kèm vai trò).
- [ ] Backend: Xây dựng service Import danh sách sinh viên từ file Excel bằng Apache POI (kiểm tra validate định dạng, trùng mã sinh viên).
- [ ] Frontend Admin: Quản lý sinh viên (Bảng dữ liệu phân trang, lọc theo khoa/khóa, Modal Import file Excel có preview trước khi lưu).
- [ ] Frontend Student & Teacher: Trang xem/đổi thông tin cá nhân.

#### Tuần 4: Trọng tâm kỹ thuật - Đăng ký Tín chỉ & Concurrency Lock
- [ ] Migration: Bảng `class_sections`, `enrollments`. Cột `version` (Optimistic lock).
- [ ] Backend: Quản lý mở Lớp học phần (phòng, lịch thứ/tiết, giảng viên phụ trách, sĩ số tối đa).
- [ ] Backend: **Validation Service cho Đăng ký học phần:**
  - Kiểm tra môn tiên quyết đã qua chưa.
  - Kiểm tra trùng thời khóa biểu giữa các lớp đã đăng ký.
  - Kiểm tra giới hạn tín chỉ min/max của học kỳ.
- [ ] Backend: **Cơ chế chống Race Condition khi đăng ký slot cuối:**
  - Triển khai `SELECT ... FOR UPDATE` (Pessimistic Locking) trong Transaction hoặc Redis Distributed Lock (Redisson).
- [ ] Frontend Student: Màn hình Đăng ký tín chỉ trực quan (Lọc lớp mở, nút Đăng ký/Hủy môn, hiển thị trực quan lớp bị trùng giờ hoặc hết chỗ).
- [ ] Frontend Student: Thời khóa biểu dạng lưới (Timetable Grid: Thứ 2 đến Chủ nhật, Tiết 1-12).

#### Tuần 5: Quản lý Điểm số, Thuật toán GPA & Xuất PDF
- [ ] Migration: Bảng `grades`.
- [ ] Backend: Service nhập điểm thành phần, công thức tự động tính điểm tổng kết 10, quy đổi thang 4 và điểm chữ.
- [ ] Backend: Thuật toán tính điểm trung bình học kỳ (GPA) và tích lũy (CPA).
- [ ] Backend: Tính năng Khóa điểm (`is_locked`) - Giảng viên đã nộp điểm thì chỉ có Admin mới mở khóa được.
- [ ] Backend: Xuất bảng điểm lớp ra file Excel; Xuất phiếu điểm cá nhân ra file PDF chuẩn văn bản (iTextPDF).
- [ ] Frontend Teacher: Giao diện Nhập điểm trực tiếp trên bảng (Editable Table), nút Lưu tạm và Nộp điểm.
- [ ] Frontend Student: Bảng tra cứu điểm theo kỳ, GPA, trạng thái Đạt/Học lại. Nút tải Bảng điểm PDF.

#### Tuần 6: Hạ tầng DevOps, Kiểm thử & Đóng gói CV
- [ ] Viết Unit Test & Integration Test (JUnit 5 + Mockito + Testcontainers kiểm thử DB PostgreSQL).
- [ ] Viết test mô phỏng Concurrency (dùng 20 thread đồng thời đăng ký 1 slot môn học để chứng minh không bao giờ bị oversold).
- [ ] Viết multi-stage `Dockerfile` cho Backend Spring Boot (chạy non-root user) và Frontend React (Nginx alpine).
- [ ] Thiết lập `docker-compose.yml` hoàn chỉnh: 1 lệnh `docker compose up -d` là chạy toàn bộ hệ thống (App, DB, Redis, Nginx).
- [ ] Thiết lập GitHub Actions CI Pipeline: Tự động chạy test và build image khi push code.
- [ ] Tạo Swagger/OpenAPI UI đầy đủ documentations.
- [ ] Soạn thảo README chuyên nghiệp và quay video demo 3-5 phút phục vụ nhà tuyển dụng.

---

## 8. Điểm nhấn kỹ thuật ăn điểm phỏng vấn & Cách viết CV

### 8.1. Các câu hỏi phỏng vấn bạn sẽ tự tin trả lời xuất sắc từ dự án này:

1. **"Làm sao em giải quyết tình trạng 100 sinh viên cùng tranh chấp 1 slot môn học cuối cùng?"**
   - *Trả lời:* "Em thiết kế bảng `class_sections` có kiểm soát concurrency. Em áp dụng Pessimistic Locking (`SELECT FOR UPDATE`) kết hợp `@Transactional(isolation = Isolation.REPEATABLE_READ)` để lock bản ghi lớp học phần trong thời gian kiểm tra `current_enrolled < max_capacity` và tăng số lượng. Em cũng đã viết integration test dùng `ExecutorService` bắn 20 concurrent requests để chứng thực không bao giờ bị over-enrollment."
2. **"Em xử lý phân quyền 3 Actors như thế nào?"**
   - *Trả lời:* "Em dùng Spring Security với Stateless JWT. Các API nhạy cảm được bảo vệ bằng Method Security `@PreAuthorize("hasRole('ADMIN')")` hoặc `@PreAuthorize("hasRole('TEACHER')")`. Ở phía dữ liệu, sinh viên chỉ được query dữ liệu gắn với `student_id` của chính họ lấy từ Security Context, ngăn chặn hoàn toàn lỗi IDOR."
3. **"Thuật toán kiểm tra trùng lịch học hoạt động ra sao?"**
   - *Trả lời:* "Mỗi lớp học phần có cấu trúc `day_of_week`, `start_period`, `end_period`. Khi sinh viên nhấn đăng ký, hệ thống query toàn bộ các lớp sinh viên đã đăng ký trong kỳ, kiểm tra điều kiện giao nhau giữa 2 khoảng thời gian: `existing.day == new.day AND Math.max(existing.start, new.start) <= Math.min(existing.end, new.end)`. Nếu giao nhau thì lập tức trả về lỗi kèm thông tin lớp bị xung đột."

### 8.2. Mẫu trình bày dự án chuyên nghiệp trên CV (Resume Bullets)

```markdown
**EduManagement - Hệ thống Đăng ký Tín chỉ & Quản lý Đào tạo Đại học**
*Solo Project | Spring Boot 3, React (TypeScript), PostgreSQL, Redis, Docker, GitHub Actions*
- Thiết kế và phát triển hệ thống quản lý đào tạo tín chỉ cho 3 nhóm đối tượng: Quản trị viên, Giảng viên, Sinh viên.
- Xử lý bài toán Concurrency trong đợt cao điểm đăng ký tín chỉ bằng Pessimistic Locking và Transaction Management, đảm bảo tính toàn vẹn dữ liệu (chống over-enrollment khi nhiều sinh viên tranh chấp 1 slot).
- Xây dựng module kiểm tra điều kiện học vụ phức tạp: validate môn tiên quyết (self-referencing graph), kiểm tra trùng thời khóa biểu (interval overlap algorithm), và ràng buộc giới hạn tín chỉ theo kỳ.
- Triển khai thuật toán tính điểm tổng kết và GPA thang 4 tự động theo quy chế tín chỉ; hỗ trợ nộp/khóa điểm học phần và xuất phiếu điểm PDF qua iTextPDF.
- Triển khai import hàng loạt hồ sơ sinh viên từ Excel với Apache POI, xử lý transaction batching tối ưu tốc độ đọc ghi.
- Đóng gói toàn bộ hệ thống bằng Docker Compose (4 services: Spring Boot, React, Postgres, Redis) và thiết lập CI Pipeline tự động test với GitHub Actions.
```

---

## 9. Master Prompt cho AI hỗ trợ Code

> **Hướng dẫn:** Sử dụng prompt dưới đây cho các công cụ AI (như Claude, ChatGPT, Antigravity) khi bạn bắt tay vào code bất kỳ module nào để AI hiểu tường tận toàn bộ bối cảnh và sinh code chính xác 100%.

```markdown
Bạn là Kiến trúc sư phần mềm kiêm Senior Fullstack Developer (Java Spring Boot + React TypeScript). Bạn đang đồng hành cùng tôi phát triển dự án "EduManagement" - Cổng Đăng ký Tín chỉ & Quản lý Điểm Đại học (Không làm CMS/trang tin tức).

1. TỔNG QUAN HỆ THỐNG:
- 3 Actors chính: ADMIN (Phòng đào tạo), TEACHER (Giảng viên), STUDENT (Sinh viên).
- Công nghệ Backend: Java 17+, Spring Boot 3.x, Spring Security 6 (JWT + Redis Blacklist), Spring Data JPA, PostgreSQL 16, Redis, Flyway, MapStruct, Apache POI, iTextPDF.
- Công nghệ Frontend: React 18, TypeScript, Vite, Ant Design (antd), React Router v6, TanStack Query (React Query v5), Axios, Zustand.
- Hạ tầng: Docker, Docker Compose, GitHub Actions.

2. CÁC MODULE NGHIỆP VỤ CỐT LÕI:
- Module Auth & RBAC: Đăng nhập tập trung một cửa, cấp phát JWT (Access Token 15p, Refresh Token 7d trong HttpOnly Cookie), phân quyền Role-based ở API và Route.
- Module Học vụ & Đào tạo: Khoa, Môn học, Môn tiên quyết (self-reference), Khung CTĐT theo kỳ học (1-8).
- Module Sinh viên & Giảng viên: Hồ sơ sinh viên, hồ sơ giảng viên, Import danh sách SV từ Excel bằng Apache POI.
- Module Lớp học phần & Đăng ký tín chỉ: Mở lớp học phần, kiểm tra điều kiện đăng ký (tiên quyết, trùng lịch học, min/max tín chỉ). Xử lý chống RACE CONDITION / OVER-ENROLLMENT bằng Pessimistic Lock (SELECT FOR UPDATE) hoặc Redis Lock.
- Module Điểm số & GPA: Bảng điểm lớp, giáo viên nhập điểm (chuyên cần 10%, giữa kỳ 30%, cuối kỳ 60%), tự động tính điểm tổng kết, quy đổi thang 4 và điểm chữ. Tính GPA tích lũy, cơ chế khóa sổ điểm, xuất bảng điểm PDF/Excel.

3. NGUYÊN TẮC CODE CHUẨN MỰC:
- Backend:
  + Áp dụng kiến trúc Clean/Layered: Controller -> Service -> Repository.
  + Luôn sử dụng DTO cho Request/Response, không để lộ Entity. Dùng MapStruct.
  + Global Exception Handling bằng @RestControllerAdvice, trả về format chuẩn { success: boolean, message: string, data: any, errors: any, timestamp: string }.
  + Validation đầu vào bằng Jakarta Bean Validation (@NotNull, @Min, @Pattern...).
  + Method security: @PreAuthorize("hasRole('ADMIN')") rõ ràng.
- Frontend:
  + TypeScript strict mode, định nghĩa type/interface rõ ràng cho mọi request/response.
  + Tổ chức module theo tính năng (features/modules), tách riêng service gọi axios.
  + Quản lý server state bằng React Query (useQuery, useMutation).
  + Giao diện Ant Design gọn gàng, hỗ trợ trải nghiệm người dùng tối ưu (Loading state, Notification, Modal confirm).

Khi tôi yêu cầu implement một chức năng cụ thể, hãy viết code hoàn chỉnh, không dùng code giả lập (placeholder), kèm theo giải thích ngắn gọn về luồng xử lý và logic nghiệp vụ.
```

---

*File này là kim chỉ nam duy nhất xuyên suốt quá trình thực hiện dự án. Tiến độ và các quyết định kỹ thuật sẽ được đối chiếu trực tiếp theo tài liệu này.*
