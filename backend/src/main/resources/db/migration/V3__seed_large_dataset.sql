-- V3__seed_large_dataset.sql
-- Seed >= 50 rows per domain table with realistic Vietnamese university data
-- Password for all seeded accounts: '123456'
-- BCrypt hash: $2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a

-- 1. Close registration on V2 semester 20241 so only 20261 is open
UPDATE semesters SET is_register_open = FALSE WHERE id = 1;

-- 2. Departments (total 50 rows: id 1..2 from V2, 3..50 here)
INSERT INTO departments (id, code, name, phone, email, description, created_by)
SELECT
    gs,
    'DEPT' || LPAD(gs::TEXT, 2, '0'),
    CASE gs
        WHEN 3 THEN 'Khoa Cơ khí'
        WHEN 4 THEN 'Khoa Công nghệ Ô tô'
        WHEN 5 THEN 'Khoa Kinh tế'
        WHEN 6 THEN 'Khoa Kế toán - Kiểm toán'
        WHEN 7 THEN 'Khoa Ngoại ngữ'
        WHEN 8 THEN 'Khoa Công nghệ Hóa học'
        WHEN 9 THEN 'Khoa Công nghệ May & Thiết kế thời trang'
        WHEN 10 THEN 'Khoa Quản lý Kinh doanh'
        WHEN 11 THEN 'Viện Công nghệ HaUI'
        WHEN 12 THEN 'Khoa Lý luận Chính trị & Pháp luật'
        WHEN 13 THEN 'Trung tâm Giáo dục Thể chất & QP'
        WHEN 14 THEN 'Khoa Khoa học Cơ bản'
        WHEN 15 THEN 'Khoa Công nghệ Thực phẩm'
        ELSE 'Bộ môn Chuyên ngành ' || LPAD(gs::TEXT, 2, '0')
    END,
    '0243.7655.' || (120 + gs),
    'dept' || gs || '@haui.edu.vn',
    'Đơn vị đào tạo và nghiên cứu khoa học trực thuộc trường',
    'SYSTEM'
FROM generate_series(3, 50) AS gs;

-- 3. Academic Programs (total 55 rows: id 1 from V2, 2..55 here)
INSERT INTO academic_programs (id, code, name, department_id, total_credits, duration_years, description, created_by)
SELECT
    gs,
    '7480' || LPAD((200 + gs)::TEXT, 3, '0'),
    CASE gs
        WHEN 2 THEN 'Kỹ thuật Phần mềm'
        WHEN 3 THEN 'Khoa học Máy tính'
        WHEN 4 THEN 'Hệ thống Thông tin'
        WHEN 5 THEN 'An toàn Thông tin'
        WHEN 6 THEN 'Trí tuệ Nhân tạo'
        WHEN 7 THEN 'Kỹ thuật Điện tử - Viễn thông'
        WHEN 8 THEN 'Công nghệ Kỹ thuật Điều khiển & TĐH'
        WHEN 9 THEN 'Công nghệ Kỹ thuật Cơ khí'
        WHEN 10 THEN 'Công nghệ Kỹ thuật Ô tô'
        WHEN 11 THEN 'Quản trị Kinh doanh'
        WHEN 12 THEN 'Kế toán Doanh nghiệp'
        WHEN 13 THEN 'Tài chính - Ngân hàng'
        WHEN 14 THEN 'Ngôn ngữ Anh'
        WHEN 15 THEN 'Logistics & Quản lý chuỗi cung ứng'
        ELSE 'Chương trình Đào tạo Kỹ sư khóa ' || gs
    END,
    ((gs - 1) % 50) + 1,
    135 + ((gs % 5) * 5),
    CASE WHEN gs % 3 = 0 THEN 5 ELSE 4 END,
    'Chương trình đào tạo theo học chế tín chỉ chuẩn đầu ra CDIO',
    'SYSTEM'
FROM generate_series(2, 55) AS gs;

-- 4. Courses (total 80 rows: id 1..5 from V2, 6..80 here)
INSERT INTO courses (id, code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES
(6, 'IT6100003', 'Thiết kế đồ họa 2D', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(7, 'IT6039002', 'Thiết kế Web', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(8, 'LP6013009', 'Lịch sử Đảng Cộng sản Việt Nam', 2, 30, 0, 0.10, 0.30, 0.60, 12, 'SYSTEM'),
(9, 'PE6003004', 'Bóng chuyền 1', 1, 0, 30, 0.20, 0.30, 0.50, 13, 'SYSTEM'),
(10, 'IT6121004', 'Thực tập cơ sở ngành', 3, 0, 90, 0.20, 0.30, 0.50, 1, 'SYSTEM'),
(11, 'FL6343019', 'Tiếng Anh Công nghệ thông tin 1', 3, 45, 0, 0.10, 0.30, 0.60, 7, 'SYSTEM'),
(12, 'LP6004006', 'Tư tưởng Hồ Chí Minh', 2, 30, 0, 0.10, 0.30, 0.60, 12, 'SYSTEM'),
(13, 'IT6044002', 'Ứng dụng thuật toán', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(14, 'IT6071002', 'Phát triển dự án công nghệ thông tin', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(15, 'IT6094004', 'Trí tuệ nhân tạo', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(16, 'PE6032002', 'Cầu mây 2', 1, 0, 30, 0.20, 0.30, 0.50, 13, 'SYSTEM'),
(17, 'IT3050', 'Mạng máy tính', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(18, 'IT3070', 'Hệ điều hành', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(19, 'IT4050', 'An toàn và bảo mật thông tin', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(20, 'IT4080', 'Kiến trúc phần mềm', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM');

INSERT INTO courses (id, code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
SELECT
    gs,
    'CS' || LPAD((1000 + gs)::TEXT, 4, '0'),
    CASE gs % 10
        WHEN 0 THEN 'Lập trình Java nâng cao ' || gs
        WHEN 1 THEN 'Phân tích thiết kế hệ thống ' || gs
        WHEN 2 THEN 'Học máy và Khai phá dữ liệu ' || gs
        WHEN 3 THEN 'Điện toán đám mây ' || gs
        WHEN 4 THEN 'Xử lý ảnh số ' || gs
        WHEN 5 THEN 'Lập trình thiết bị di động ' || gs
        WHEN 6 THEN 'Kiểm thử và đảm bảo chất lượng PM ' || gs
        WHEN 7 THEN 'Toán rời rạc ' || gs
        WHEN 8 THEN 'Xác suất thống kê ' || gs
        ELSE 'Hệ quản trị cơ sở dữ liệu ' || gs
    END,
    2 + (gs % 3),
    30,
    CASE WHEN gs % 2 = 0 THEN 30 ELSE 15 END,
    0.10,
    0.30,
    0.60,
    ((gs - 1) % 50) + 1,
    'SYSTEM'
FROM generate_series(21, 80) AS gs;

-- 5. Course Prerequisites (total 55 rows: 2 from V2, 53 here, DAG without cycles)
INSERT INTO course_prerequisites (course_id, prerequisite_id)
VALUES
(13, 2),  -- Ứng dụng thuật toán <- CTDL & GT
(14, 3),  -- Phát triển dự án CNTT <- CSDL
(15, 2),  -- Trí tuệ nhân tạo <- CTDL & GT
(19, 17), -- An toàn thông tin <- Mạng máy tính
(20, 4);  -- Kiến trúc PM <- Công nghệ Web nâng cao

INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT gs, gs - 5
FROM generate_series(26, 73) AS gs
ON CONFLICT DO NOTHING;

-- 6. Program Courses (total ~160 rows, program 1 has 20 courses across semesters 1..8)
INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
VALUES
(1, 1, 1, true, 'SYSTEM'),
(1, 5, 1, true, 'SYSTEM'),
(1, 9, 1, true, 'SYSTEM'),
(1, 2, 2, true, 'SYSTEM'),
(1, 11, 2, true, 'SYSTEM'),
(1, 16, 2, false, 'SYSTEM'),
(1, 3, 3, true, 'SYSTEM'),
(1, 7, 3, true, 'SYSTEM'),
(1, 12, 3, true, 'SYSTEM'),
(1, 17, 4, true, 'SYSTEM'),
(1, 18, 4, true, 'SYSTEM'),
(1, 6, 4, false, 'SYSTEM'),
(1, 4, 5, true, 'SYSTEM'),
(1, 8, 5, true, 'SYSTEM'),
(1, 13, 5, true, 'SYSTEM'),
(1, 10, 6, true, 'SYSTEM'),
(1, 14, 6, true, 'SYSTEM'),
(1, 15, 6, false, 'SYSTEM'),
(1, 19, 7, true, 'SYSTEM'),
(1, 20, 7, true, 'SYSTEM');

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT
    ((gs - 1) % 54) + 2,
    ((gs * 3) % 75) + 1,
    ((gs - 1) % 8) + 1,
    (gs % 4 <> 0),
    'SYSTEM'
FROM generate_series(1, 150) AS gs
ON CONFLICT (program_id, course_id) DO NOTHING;

-- 7. Semesters (total 50 rows: id 1 from V2, 2..50 here; id 50 is 20261 OPEN)
INSERT INTO semesters (id, code, name, academic_year, semester_number, start_date, end_date, is_register_open, min_credits, max_credits, created_by)
SELECT
    gs,
    CASE gs
        WHEN 47 THEN '20251'
        WHEN 48 THEN '20252'
        WHEN 49 THEN '20253'
        WHEN 50 THEN '20261'
        ELSE (2005 + ((gs - 2) / 3))::TEXT || (((gs - 2) % 3) + 1)::TEXT
    END,
    CASE gs
        WHEN 47 THEN 'Học kỳ 1 năm học 2025 - 2026'
        WHEN 48 THEN 'Học kỳ 2 năm học 2025 - 2026'
        WHEN 49 THEN 'Học kỳ Hè năm học 2025 - 2026'
        WHEN 50 THEN 'Học kỳ 1 năm học 2026 - 2027'
        ELSE 'Học kỳ ' || (((gs - 2) % 3) + 1) || ' năm học ' || (2005 + ((gs - 2) / 3)) || ' - ' || (2006 + ((gs - 2) / 3))
    END,
    CASE gs
        WHEN 47 THEN '2025-2026'
        WHEN 48 THEN '2025-2026'
        WHEN 49 THEN '2025-2026'
        WHEN 50 THEN '2026-2027'
        ELSE (2005 + ((gs - 2) / 3)) || '-' || (2006 + ((gs - 2) / 3))
    END,
    CASE WHEN gs >= 47 THEN CASE gs WHEN 47 THEN 1 WHEN 48 THEN 2 WHEN 49 THEN 3 ELSE 1 END ELSE (((gs - 2) % 3) + 1) END,
    DATE '2024-01-01' + ((gs - 40) * 120),
    DATE '2024-04-30' + ((gs - 40) * 120),
    (gs = 50),
    12,
    24,
    'SYSTEM'
FROM generate_series(2, 50) AS gs;

-- 8. Users & Roles (total 160 users: id 1..3 from V2, 4..57 teachers, 58..160 students)
INSERT INTO users (id, username, password_hash, email, full_name, phone, is_active, created_by)
SELECT
    gs,
    'teacher' || (gs - 2),
    '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a',
    'gv' || LPAD((gs - 2)::TEXT, 3, '0') || '@haui.edu.vn',
    (ARRAY['TS. Trần Minh ', 'ThS. Lê Thị ', 'PGS.TS. Phạm Văn ', 'TS. Hoàng Anh ', 'ThS. Vũ Thu ', 'TS. Đặng Quốc ', 'ThS. Bùi Ngọc '])[1 + (gs % 7)]
    || (ARRAY['Tuấn', 'Lan', 'Hùng', 'Hương', 'Dũng', 'Mai', 'Cường', 'Trang', 'Sơn', 'Hà'])[1 + (gs % 10)],
    '098' || LPAD((1000000 + gs)::TEXT, 7, '0'),
    true,
    'SYSTEM'
FROM generate_series(4, 57) AS gs;

INSERT INTO users (id, username, password_hash, email, full_name, phone, is_active, created_by)
SELECT
    gs,
    '202160' || LPAD((gs - 56)::TEXT, 4, '0'),
    '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a',
    'sv' || LPAD((gs - 56)::TEXT, 4, '0') || '@sv.haui.edu.vn',
    (ARRAY['Nguyễn ', 'Trần ', 'Lê ', 'Phạm ', 'Hoàng ', 'Vũ ', 'Đặng ', 'Bùi ', 'Đỗ ', 'Ngô '])[1 + (gs % 10)]
    || (ARRAY['Văn ', 'Thị ', 'Minh ', 'Ngọc ', 'Hoàng ', 'Đức ', 'Thanh ', 'Quang '])[1 + (gs % 8)]
    || (ARRAY['An', 'Bình', 'Cường', 'Dương', 'Hà', 'Hải', 'Khánh', 'Linh', 'Long', 'Nam', 'Phương', 'Thảo', 'Trung', 'Uyên'])[1 + (gs % 14)],
    '091' || LPAD((2000000 + gs)::TEXT, 7, '0'),
    true,
    'SYSTEM'
FROM generate_series(58, 160) AS gs;

INSERT INTO user_roles (user_id, role_id)
SELECT gs, 2 FROM generate_series(4, 57) AS gs;

INSERT INTO user_roles (user_id, role_id)
SELECT gs, 3 FROM generate_series(58, 160) AS gs;

-- 9. Teachers (total 55 rows: id 1 from V2, 2..55 here)
INSERT INTO teachers (id, user_id, teacher_code, department_id, academic_rank, created_by)
SELECT
    gs - 2,
    gs,
    'GV' || LPAD((gs - 2)::TEXT, 3, '0'),
    ((gs - 3) % 50) + 1,
    (ARRAY['Tiến sĩ', 'Thạc sĩ', 'Phó Giáo sư', 'Giáo sư'])[1 + (gs % 4)],
    'SYSTEM'
FROM generate_series(4, 57) AS gs;

-- 10. Students (total 104 rows: id 1 from V2, 2..104 here)
INSERT INTO students (id, user_id, student_code, department_id, program_id, cohort, academic_status, date_of_birth, gender, address, created_by)
SELECT
    gs - 56,
    gs,
    '202160' || LPAD((gs - 56)::TEXT, 4, '0'),
    CASE WHEN gs <= 85 THEN 1 ELSE ((gs - 56) % 50) + 1 END,
    CASE WHEN gs <= 85 THEN 1 ELSE ((gs - 56) % 55) + 1 END,
    2021 + (gs % 5),
    CASE WHEN gs % 19 = 0 THEN 'WARNING' ELSE 'STUDYING' END,
    DATE '2003-01-15' + ((gs % 365) * 2),
    CASE WHEN gs % 3 = 0 THEN 'Nữ' ELSE 'Nam' END,
    'Quận Bắc Từ Liêm, Hà Nội',
    'SYSTEM'
FROM generate_series(58, 160) AS gs;

-- 11. Class Sections (total 120 rows: id 1..2 from V2, 3..120 here)
-- Active semester 20261 (semester_id = 50): id 3..32 (30 open/full sections)
INSERT INTO class_sections (id, course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status, created_by)
VALUES
(3,  6,  50, 1, '20261IT6100003', 60, 0, 'OPEN', 'SYSTEM'),
(4,  7,  50, 1, '20261IT6039002', 60, 0, 'OPEN', 'SYSTEM'),
(5,  8,  50, 2, '20261LP6013009', 80, 0, 'OPEN', 'SYSTEM'),
(6,  9,  50, 3, '20261PE6003004', 45, 0, 'OPEN', 'SYSTEM'),
(7,  10, 50, 1, '20261IT6121004', 50, 0, 'OPEN', 'SYSTEM'),
(8,  11, 50, 4, '20261FL6343019', 45, 0, 'OPEN', 'SYSTEM'),
(9,  12, 50, 2, '20261LP6004006', 80, 0, 'OPEN', 'SYSTEM'),
(10, 13, 50, 1, '20261IT6044002', 60, 0, 'OPEN', 'SYSTEM'),
(11, 14, 50, 5, '20261IT6071002', 60, 0, 'OPEN', 'SYSTEM'),
(12, 15, 50, 6, '20261IT6094004', 60, 0, 'OPEN', 'SYSTEM'),
(13, 16, 50, 3, '20261PE6032002', 45, 0, 'OPEN', 'SYSTEM'),
(14, 17, 50, 1, '20261IT3050001', 60, 0, 'OPEN', 'SYSTEM'),
(15, 18, 50, 7, '20261IT3070001', 60, 0, 'OPEN', 'SYSTEM'),
(16, 19, 50, 8, '20261IT4050001', 60, 0, 'OPEN', 'SYSTEM'),
(17, 20, 50, 1, '20261IT4080001', 60, 0, 'OPEN', 'SYSTEM'),
(18, 4,  50, 1, '20261IT4010001', 60, 0, 'OPEN', 'SYSTEM'),
(19, 2,  50, 9, '20261IT2010001', 2,  0, 'OPEN', 'SYSTEM'), -- Lớp nhỏ để test hết chỗ (2/2)
(20, 5,  50, 10, '20261BS1010001', 60, 0, 'OPEN', 'SYSTEM');

-- More sections in 20261 (id 21..32) and past semesters 47, 48, 49, 1 (id 33..120)
INSERT INTO class_sections (id, course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status, created_by)
SELECT
    gs,
    ((gs - 1) % 75) + 1,
    CASE
        WHEN gs <= 32 THEN 50
        WHEN gs <= 60 THEN 48
        WHEN gs <= 90 THEN 47
        ELSE 1
    END,
    ((gs - 1) % 55) + 1,
    'SEC-' || gs || '-' || LPAD(((gs % 20) + 1)::TEXT, 2, '0'),
    60,
    0,
    CASE WHEN gs <= 32 THEN 'OPEN' ELSE 'CLOSED' END,
    'SYSTEM'
FROM generate_series(21, 120) AS gs;

-- 12. Class Schedules (total 160+ rows: id 1..3 from V2, 4..160+ here)
-- Detailed schedule matching the reference image for sections 3..13 (Sáng 1-6, Chiều 7-12, Tối 13-15)
INSERT INTO class_schedules (id, class_section_id, day_of_week, start_period, end_period, room, created_by)
VALUES
-- Section 3: Thiết kế đồ họa 2D -> Thứ 2 sáng (4,5,6)
(4,  3,  2, 4,  6,  '305 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 4: Thiết kế Web -> Thứ 3 sáng (4,5,6)
(5,  4,  3, 4,  6,  'Phòng Thực hành SICT_79 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 5: Lịch sử Đảng -> Thứ 6 sáng (3,4)
(6,  5,  6, 3,  4,  'Khu A - Phòng Lý thuyết tạm 23 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 6: Bóng chuyền 1 -> Thứ 7 sáng (1,2,3,4)
(7,  6,  7, 1,  4,  'Sân thể dục 1 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 7: Thực tập cơ sở ngành -> CN sáng (1-6) & CN chiều (7-12)
(8,  7,  8, 1,  6,  'Phòng thực hành Khoa CNTT 04 (Cơ sở 1 - Khu A)', 'SYSTEM'),
(9,  7,  8, 7,  12, 'Phòng thực hành Khoa CNTT 11 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 8: Tiếng Anh CNTT 1 -> Thứ 2 chiều (9,10) & Thứ 5 chiều (9,10)
(10, 8,  2, 9,  10, '208 (Cơ sở 1 - Khu A)', 'SYSTEM'),
(11, 8,  5, 9,  10, '208 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 9: Tư tưởng HCM -> Thứ 3 chiều (7,8,9,10)
(12, 9,  3, 7,  10, '502 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 10: Ứng dụng thuật toán -> Thứ 4 chiều (7-10) & Thứ 7 chiều (7-10)
(13, 10, 4, 7,  10, '804 (Cơ sở 1 - Khu A)', 'SYSTEM'),
(14, 10, 7, 7,  10, '804 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 11: Phát triển dự án CNTT -> Thứ 3 chiều (7,8,9) (trùng lịch 9 để test trùng lịch nếu ĐK)
(15, 11, 3, 7,  9,  '304 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 12: Trí tuệ nhân tạo -> Thứ 4 chiều (7,8,9) (trùng 10 nếu đã ĐK 10)
(16, 12, 4, 7,  9,  '304 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 13: Cầu mây 2 -> Thứ 6 chiều (8,9,10,11)
(17, 13, 6, 8,  11, 'GDTC B 109 - Cầu mây (Cơ sở 2 - Khu B)', 'SYSTEM'),
-- Section 14: Mạng máy tính -> Thứ 4 sáng (1,2,3) (Sáng trống, rất dễ đăng ký test!)
(18, 14, 4, 1,  3,  'A1-302 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 15: Hệ điều hành -> Thứ 5 sáng (1,2,3)
(19, 15, 5, 1,  3,  'A2-401 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 16: An toàn thông tin -> Thứ 2 tối (13,14,15) (Test ca Tối & thiếu tiên quyết IT3050)
(20, 16, 2, 13, 15, 'PM-A102 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 17: Kiến trúc PM -> Thứ 5 tối (13,14,15) (Test ca Tối)
(21, 17, 5, 13, 15, 'A1-505 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 18: Công nghệ Web nâng cao -> Thứ 3 tối (13,14,15)
(22, 18, 3, 13, 15, 'PM-B203 (Cơ sở 2 - Khu B)', 'SYSTEM'),
-- Section 19: CTDL & GT (lớp 2 chỗ để test FULL) -> Thứ 6 tối (13,14,15)
(23, 19, 6, 13, 15, 'A1-201 (Cơ sở 1 - Khu A)', 'SYSTEM'),
-- Section 20: Giải tích 1 -> Thứ 4 tối (13,14,15)
(24, 20, 4, 13, 15, 'A2-101 (Cơ sở 1 - Khu A)', 'SYSTEM');

-- Schedules for sections 21..120 (including multiple sessions & ca Tối)
INSERT INTO class_schedules (id, class_section_id, day_of_week, start_period, end_period, room, created_by)
SELECT
    24 + gs,
    20 + gs,
    2 + (gs % 7),
    CASE gs % 3
        WHEN 0 THEN 1
        WHEN 1 THEN 7
        ELSE 13
    END,
    CASE gs % 3
        WHEN 0 THEN 3
        WHEN 1 THEN 10
        ELSE 15
    END,
    (ARRAY['A1-302 (Cơ sở 1 - Khu A)', 'A2-204 (Cơ sở 1 - Khu A)', 'PM-B203 (Cơ sở 2 - Khu B)', '502 (Cơ sở 1 - Khu A)', '804 (Cơ sở 1 - Khu A)'])[1 + (gs % 5)],
    'SYSTEM'
FROM generate_series(1, 100) AS gs;

INSERT INTO class_schedules (id, class_section_id, day_of_week, start_period, end_period, room, created_by)
SELECT
    124 + gs,
    20 + gs,
    2 + ((gs + 2) % 7),
    CASE WHEN gs % 2 = 0 THEN 4 ELSE 9 END,
    CASE WHEN gs % 2 = 0 THEN 6 ELSE 11 END,
    'Phòng Thực hành CNTT ' || LPAD((gs % 15 + 1)::TEXT, 2, '0') || ' (Cơ sở 1 - Khu A)',
    'SYSTEM'
FROM generate_series(1, 40) AS gs;

-- 13. Enrollments (total 350+ rows)
-- A) Past semesters for student1 (id=1): đã học qua IT1010, IT3010, BS1010, IT2010 (học cải thiện 2 lần!)
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, created_by)
VALUES
(1, 1,  NOW() - INTERVAL '300 days', 'ENROLLED', 'SYSTEM'), -- IT4010 ở HK 20241
(1, 2,  NOW() - INTERVAL '300 days', 'ENROLLED', 'SYSTEM'), -- IT3010 ở HK 20241 (Đạt tiên quyết cho IT4010!)
(1, 61, NOW() - INTERVAL '220 days', 'ENROLLED', 'SYSTEM'),
(1, 62, NOW() - INTERVAL '220 days', 'ENROLLED', 'SYSTEM'),
(1, 33, NOW() - INTERVAL '120 days', 'ENROLLED', 'SYSTEM'),
(1, 34, NOW() - INTERVAL '120 days', 'ENROLLED', 'SYSTEM'),
-- B) Active semester 20261 (50) for student1: đăng ký 6 lớp (15 TC), phủ Sáng/Chiều/Tối giống ảnh mẫu!
(1, 3,  NOW() - INTERVAL '2 days', 'ENROLLED', 'SYSTEM'), -- Thiết kế đồ họa 2D (T2 sáng)
(1, 4,  NOW() - INTERVAL '2 days', 'ENROLLED', 'SYSTEM'), -- Thiết kế Web (T3 sáng)
(1, 5,  NOW() - INTERVAL '2 days', 'ENROLLED', 'SYSTEM'), -- Lịch sử Đảng (T6 sáng)
(1, 8,  NOW() - INTERVAL '2 days', 'ENROLLED', 'SYSTEM'), -- Tiếng Anh CNTT 1 (T2, T5 chiều)
(1, 9,  NOW() - INTERVAL '2 days', 'ENROLLED', 'SYSTEM'), -- Tư tưởng HCM (T3 chiều)
(1, 17, NOW() - INTERVAL '2 days', 'ENROLLED', 'SYSTEM'), -- Kiến trúc PM (T5 tối)
-- C) Fill section 19 (max_capacity = 2) with student 2 and 3 so it shows as HẾT CHỖ!
(2, 19, NOW() - INTERVAL '3 days', 'ENROLLED', 'SYSTEM'),
(3, 19, NOW() - INTERVAL '3 days', 'ENROLLED', 'SYSTEM');

-- D) Bulk enrollments for students 2..104 across sections 3..120 (creating ~350 rows total)
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, created_by)
SELECT
    ((gs - 1) % 103) + 2,
    CASE WHEN gs <= 120 THEN 3 + (gs % 15) ELSE 33 + (gs % 80) END,
    NOW() - ((gs % 180) || ' days')::INTERVAL,
    'ENROLLED',
    'SYSTEM'
FROM generate_series(1, 360) AS gs
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Ensure teacher1 (section 3, 4, 7, 10, 14, 17, 18) has plenty of students for grade entry
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, created_by)
SELECT s_id, sec_id, NOW() - INTERVAL '5 days', 'ENROLLED', 'SYSTEM'
FROM generate_series(2, 20) AS s_id
CROSS JOIN (VALUES (3), (4), (7), (10), (14)) AS secs(sec_id)
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Sync current_enrolled on all class_sections
UPDATE class_sections cs
SET current_enrolled = (
    SELECT COUNT(*) FROM enrollments e WHERE e.class_section_id = cs.id AND e.status = 'ENROLLED'
);

-- 14. Grades (1:1 with every enrollment)
INSERT INTO grades (enrollment_id, attendance_score, midterm_score, final_score, total_score_10, gpa_score_4, letter_grade, is_locked, created_by)
SELECT
    e.id,
    CASE
        WHEN cs.semester_id <> 50 THEN ROUND((7.0 + ((e.id % 30) * 0.1))::NUMERIC, 2)
        WHEN cs.id IN (3, 4) THEN ROUND((8.0 + ((e.id % 20) * 0.1))::NUMERIC, 2)
        ELSE NULL
    END,
    CASE
        WHEN cs.semester_id <> 50 THEN ROUND((6.5 + ((e.id % 35) * 0.1))::NUMERIC, 2)
        WHEN cs.id IN (3, 4) THEN ROUND((7.5 + ((e.id % 25) * 0.1))::NUMERIC, 2)
        ELSE NULL
    END,
    CASE
        WHEN cs.semester_id <> 50 THEN ROUND((5.5 + ((e.id % 45) * 0.1))::NUMERIC, 2)
        WHEN cs.id IN (3, 4) THEN ROUND((7.0 + ((e.id % 30) * 0.1))::NUMERIC, 2)
        ELSE NULL
    END,
    NULL,
    NULL,
    NULL,
    CASE
        WHEN cs.semester_id <> 50 THEN true
        WHEN cs.id = 4 THEN true
        ELSE false
    END,
    'SYSTEM'
FROM enrollments e
JOIN class_sections cs ON cs.id = e.class_section_id
ON CONFLICT (enrollment_id) DO NOTHING;

-- Compute total_score_10, letter_grade, gpa_score_4 consistently for all rows that have component scores
UPDATE grades g
SET total_score_10 = ROUND((g.attendance_score * c.attendance_weight + g.midterm_score * c.midterm_weight + g.final_score * c.final_weight)::NUMERIC, 2)
FROM enrollments e
JOIN class_sections cs ON cs.id = e.class_section_id
JOIN courses c ON c.id = cs.course_id
WHERE g.enrollment_id = e.id
  AND g.attendance_score IS NOT NULL
  AND g.midterm_score IS NOT NULL
  AND g.final_score IS NOT NULL;

UPDATE grades
SET letter_grade = CASE
        WHEN total_score_10 >= 9.0 THEN 'A+'
        WHEN total_score_10 >= 8.5 THEN 'A'
        WHEN total_score_10 >= 8.0 THEN 'B+'
        WHEN total_score_10 >= 7.0 THEN 'B'
        WHEN total_score_10 >= 6.5 THEN 'C+'
        WHEN total_score_10 >= 5.5 THEN 'C'
        WHEN total_score_10 >= 5.0 THEN 'D+'
        WHEN total_score_10 >= 4.0 THEN 'D'
        ELSE 'F'
    END,
    gpa_score_4 = CASE
        WHEN total_score_10 >= 9.0 THEN 4.0
        WHEN total_score_10 >= 8.5 THEN 3.7
        WHEN total_score_10 >= 8.0 THEN 3.5
        WHEN total_score_10 >= 7.0 THEN 3.0
        WHEN total_score_10 >= 6.5 THEN 2.5
        WHEN total_score_10 >= 5.5 THEN 2.0
        WHEN total_score_10 >= 5.0 THEN 1.5
        WHEN total_score_10 >= 4.0 THEN 1.0
        ELSE 0.0
    END
WHERE total_score_10 IS NOT NULL;

-- Make sure student1 passed IT1010 (prereq) via section 61 if needed or make section 2 have high passing grade
UPDATE grades g
SET attendance_score = 9.0, midterm_score = 8.5, final_score = 8.5, total_score_10 = 8.55, gpa_score_4 = 3.7, letter_grade = 'A', is_locked = true
FROM enrollments e
WHERE g.enrollment_id = e.id AND e.student_id = 1 AND e.class_section_id IN (1, 2);

-- 15. Sync all PostgreSQL sequences
SELECT setval('roles_id_seq', COALESCE((SELECT MAX(id) FROM roles), 1));
SELECT setval('users_id_seq', COALESCE((SELECT MAX(id) FROM users), 1));
SELECT setval('departments_id_seq', COALESCE((SELECT MAX(id) FROM departments), 1));
SELECT setval('academic_programs_id_seq', COALESCE((SELECT MAX(id) FROM academic_programs), 1));
SELECT setval('courses_id_seq', COALESCE((SELECT MAX(id) FROM courses), 1));
SELECT setval('program_courses_id_seq', COALESCE((SELECT MAX(id) FROM program_courses), 1));
SELECT setval('semesters_id_seq', COALESCE((SELECT MAX(id) FROM semesters), 1));
SELECT setval('teachers_id_seq', COALESCE((SELECT MAX(id) FROM teachers), 1));
SELECT setval('students_id_seq', COALESCE((SELECT MAX(id) FROM students), 1));
SELECT setval('class_sections_id_seq', COALESCE((SELECT MAX(id) FROM class_sections), 1));
SELECT setval('class_schedules_id_seq', COALESCE((SELECT MAX(id) FROM class_schedules), 1));
SELECT setval('enrollments_id_seq', COALESCE((SELECT MAX(id) FROM enrollments), 1));
SELECT setval('grades_id_seq', COALESCE((SELECT MAX(id) FROM grades), 1));
