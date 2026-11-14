-- V2__seed_data.sql: Sample seed data

-- 1. Insert Roles
INSERT INTO roles (id, name, description) VALUES
(1, 'ROLE_ADMIN', 'Quản trị viên / Phòng đào tạo'),
(2, 'ROLE_TEACHER', 'Giảng viên'),
(3, 'ROLE_STUDENT', 'Sinh viên');

-- 2. Insert Users (Password: 123456)
-- BCrypt for '123456': $2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a
INSERT INTO users (id, username, password_hash, email, full_name, phone, is_active, created_by) VALUES
(1, 'admin', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a', 'admin@haui.edu.vn', 'Quản trị viên Đào tạo', '0912345678', true, 'SYSTEM'),
(2, 'teacher1', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a', 'nam.ts@haui.edu.vn', 'TS. Nguyễn Văn Nam', '0987654321', true, 'SYSTEM'),
(3, 'student1', '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a', 'an.nv@sv.haui.edu.vn', 'Nguyễn Văn An', '0901234567', true, 'SYSTEM');

-- Map Roles
INSERT INTO user_roles (user_id, role_id) VALUES
(1, 1), -- admin -> ROLE_ADMIN
(2, 2), -- teacher1 -> ROLE_TEACHER
(3, 3); -- student1 -> ROLE_STUDENT

-- 3. Departments
INSERT INTO departments (id, code, name, phone, email, description, created_by) VALUES
(1, 'FIT', 'Khoa Công nghệ Thông tin', '0243.7655.121', 'fit@haui.edu.vn', 'Đào tạo kỹ sư CNTT, KTPM, KHMT', 'SYSTEM'),
(2, 'FEE', 'Khoa Điện tử', '0243.7655.122', 'fee@haui.edu.vn', 'Đào tạo kỹ sư Điện tử viễn thông', 'SYSTEM');

-- 4. Academic Programs
INSERT INTO academic_programs (id, code, name, department_id, total_credits, duration_years, description, created_by) VALUES
(1, '7480201', 'Công nghệ Thông tin', 1, 150, 4, 'Chương trình đào tạo kỹ sư Công nghệ thông tin', 'SYSTEM');

-- 5. Courses (Linh hoạt trọng số điểm)
INSERT INTO courses (id, code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by) VALUES
(1, 'IT1010', 'Nhập môn Lập trình C/C++', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(2, 'IT2010', 'Cấu trúc dữ liệu và giải thuật', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(3, 'IT3010', 'Cơ sở dữ liệu', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(4, 'IT4010', 'Công nghệ Web nâng cao', 3, 30, 30, 0.10, 0.30, 0.60, 1, 'SYSTEM'),
(5, 'BS1010', 'Giải tích 1', 3, 45, 0, 0.10, 0.30, 0.60, 1, 'SYSTEM');

-- 6. Course Prerequisites (CTDL&GT cần Nhập môn Lập trình, CN Web cần CSDL)
INSERT INTO course_prerequisites (course_id, prerequisite_id) VALUES
(2, 1), -- IT2010 cần IT1010
(4, 3); -- IT4010 cần IT3010

-- 7. Semesters
INSERT INTO semesters (id, code, name, academic_year, semester_number, start_date, end_date, is_register_open, min_credits, max_credits, created_by) VALUES
(1, '20241', 'Học kỳ 1 năm học 2024 - 2025', '2024-2025', 1, '2024-09-01', '2025-01-15', true, 12, 24, 'SYSTEM');

-- 8. Teachers & Students
INSERT INTO teachers (id, user_id, teacher_code, department_id, academic_rank, created_by) VALUES
(1, 2, 'GV001', 1, 'Tiến sĩ', 'SYSTEM');

INSERT INTO students (id, user_id, student_code, department_id, program_id, cohort, academic_status, date_of_birth, gender, created_by) VALUES
(1, 3, '2021600001', 1, 1, 2021, 'STUDYING', '2003-05-15', 'Nam', 'SYSTEM');

-- 9. Class Sections & Schedules
INSERT INTO class_sections (id, course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status, created_by) VALUES
(1, 4, 1, 1, 'IT4010.01', 60, 0, 'OPEN', 'SYSTEM'),
(2, 3, 1, 1, 'IT3010.01', 60, 0, 'OPEN', 'SYSTEM');

-- Lịch học (Tách bảng class_schedules)
INSERT INTO class_schedules (id, class_section_id, day_of_week, start_period, end_period, room, created_by) VALUES
(1, 1, 2, 1, 3, 'A1-302', 'SYSTEM'), -- Lớp Web học Thứ 2 tiết 1-3
(2, 1, 5, 7, 9, 'PM-B203', 'SYSTEM'), -- Lớp Web học thêm Thứ 5 tiết 7-9 (phòng máy)
(3, 2, 4, 4, 6, 'A2-105', 'SYSTEM'); -- Lớp CSDL học Thứ 4 tiết 4-6

SELECT setval('roles_id_seq', (SELECT MAX(id) FROM roles));
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('departments_id_seq', (SELECT MAX(id) FROM departments));
SELECT setval('academic_programs_id_seq', (SELECT MAX(id) FROM academic_programs));
SELECT setval('courses_id_seq', (SELECT MAX(id) FROM courses));
SELECT setval('semesters_id_seq', (SELECT MAX(id) FROM semesters));
SELECT setval('teachers_id_seq', (SELECT MAX(id) FROM teachers));
SELECT setval('students_id_seq', (SELECT MAX(id) FROM students));
SELECT setval('class_sections_id_seq', (SELECT MAX(id) FROM class_sections));
SELECT setval('class_schedules_id_seq', (SELECT MAX(id) FROM class_schedules));
