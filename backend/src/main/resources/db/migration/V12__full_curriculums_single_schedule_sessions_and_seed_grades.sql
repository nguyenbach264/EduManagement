-- ==========================================================================
-- V12: Full realistic curriculums for all 12 majors, clean single schedules,
-- and complete student grades for analytics charts.
-- ==========================================================================


-- 1. Reassign students in non-teaching departments (12, 13, 14) to real teaching departments
UPDATE students
SET department_id = 1 + (id % 4)
WHERE department_id = 12;

UPDATE students
SET department_id = 5 + (id % 4)
WHERE department_id = 13;

UPDATE students
SET department_id = CASE WHEN id % 4 = 3 THEN 15 ELSE 9 + (id % 3) END
WHERE department_id = 14;

-- Align all student program_id to match their department BEFORE deleting old programs
UPDATE students
SET program_id = department_id
WHERE department_id <= 11;

UPDATE students
SET program_id = 12
WHERE department_id = 15;

-- Ensure any student pointing to 13, 14, 15 is safely reassigned
UPDATE students
SET program_id = 1
WHERE program_id IN (13, 14, 15);

-- Remove duplicate programs 13, 14, 15 first to free up unique code 7540101
DELETE FROM program_courses WHERE program_id IN (13, 14, 15);
DELETE FROM academic_programs WHERE id IN (13, 14, 15);

-- Program 12 is for Food Tech (Department 15)
UPDATE academic_programs 
SET code = '7540101', 
    name = 'Công nghệ Thực phẩm & Đảm bảo ATTP', 
    department_id = 15, 
    total_credits = 142 
WHERE id = 12;

-- 2. Insert comprehensive specialized courses for all departments
-- --- Department 2 (EE) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE1101', 'Nhập môn Kỹ thuật Điện tử - Viễn thông', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE1202', 'Vật lý ứng dụng & Bán dẫn', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE1203', 'Mạch điện 1 & Mô phỏng PSpice', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2104', 'Kỹ thuật điện tử tương tự', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2105', 'Kỹ thuật số & Thiết kế Logic', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2106', 'Mạch điện 2 & Phân tích miền tần số', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2107', 'Lý thuyết tín hiệu & Hệ thống', 3, 45, 0, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2208', 'Kỹ thuật Vi xử lý & Vi điều khiển ARM', 4, 30, 60, 0.2, 0.3, 0.5, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2209', 'Kỹ thuật đo lường & Cảm biến thông minh', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2210', 'Trường điện từ & Kỹ thuật siêu cao tần', 3, 45, 0, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2211', 'Thiết kế mạch in PCB với Altium Designer', 3, 15, 60, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE2212', 'Kỹ thuật truyền số liệu & Mã hóa kênh', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3113', 'Xử lý tín hiệu số DSP & Ứng dụng', 4, 30, 60, 0.2, 0.3, 0.5, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3114', 'Cơ sở Kỹ thuật Viễn thông & Điều chế số', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3115', 'Kỹ thuật Anten và Truyền sóng vô tuyến', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3116', 'Hệ thống thông tin quang (FTTH/DWDM)', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3117', 'Hệ thống nhúng và IoT ứng dụng', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3218', 'Mạng thông tin di động 4G/5G/6G', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3219', 'Thiết kế vi mạch VLSI & Ngôn ngữ Verilog', 4, 30, 60, 0.2, 0.3, 0.5, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3220', 'Mạng truyền thông máy tính & An toàn mạng viễn thông', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3221', 'Kỹ thuật chuyển mạch & Định tuyến NGN/IMS', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE3222', 'Xử lý tiếng nói và hình ảnh số', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE4123', 'Đồ án Kỹ thuật Điện tử - Viễn thông', 3, 0, 90, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE4124', 'Mạng cảm biến không dây WSN & Thành phố thông minh', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE4125', 'Quản trị mạng viễn thông & Dịch vụ đám mây viễn thông', 3, 30, 30, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE4126', 'Thực tập tốt nghiệp Kỹ sư Điện tử - Viễn thông', 5, 0, 150, 0.4, 0.3, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE4227', 'Đồ án tốt nghiệp Kỹ sư Điện tử - Viễn thông', 8, 0, 240, 0.4, 0.3, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EE4228', 'Chuyên đề Công nghệ Viễn thông tiên tiến', 3, 45, 0, 0.4, 0, 0.6, 2, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 3 (ME) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME1101', 'Hình họa & Vẽ kỹ thuật cơ khí', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME1202', 'Cơ học lý thuyết (Tĩnh học & Động lực học)', 3, 45, 0, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME1203', 'Vật liệu học và Nhiệt luyện kim loại', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2104', 'Sức bền vật liệu 1', 3, 45, 0, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2105', 'Dung sai lắp ghép và Kỹ thuật đo cơ khí', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2106', 'Nguyên lý máy & Cơ cấu cơ khí', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2107', 'Mô hình hóa 3D CAD với SolidWorks', 3, 15, 60, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2208', 'Chi tiết máy & Truyền động cơ khí', 4, 45, 30, 0.2, 0.3, 0.5, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2209', 'Đồ án Chi tiết máy', 2, 0, 60, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2210', 'Kỹ thuật Thủy lực và Khí nén công nghiệp', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2211', 'Công nghệ kim loại & Gia công biến dạng', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME2212', 'An toàn lao động và Môi trường công nghiệp', 2, 30, 0, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3113', 'Công nghệ Chế tạo máy 1 (Cắt gọt kim loại)', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3114', 'Máy công cụ và Trung tâm gia công CNC', 4, 30, 60, 0.2, 0.3, 0.5, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3115', 'Lập trình gia công CAM & Mastercam', 3, 15, 60, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3116', 'Công nghệ Hàn và Kỹ thuật ghép nối kim loại', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3117', 'Đồ án Công nghệ Chế tạo máy', 2, 0, 60, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3218', 'Công nghệ Chế tạo máy 2 & Đồ gá công nghiệp', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3219', 'Thiết kế khuôn mẫu và Dập định hình', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3220', 'Tự động hóa sản xuất và Dây chuyền FMS/CIM', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3221', 'Bảo trì, chẩn đoán kỹ thuật máy công nghiệp', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME3222', 'Quản trị sản xuất và Kiểm soát chất lượng cơ khí', 3, 45, 0, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME4123', 'Đồ án chuyên ngành Công nghệ Cơ khí', 3, 0, 90, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME4124', 'Công nghệ in 3D và Sản xuất bồi đắp kim loại', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME4125', 'Hệ thống cơ điện tử trong nhà máy thông minh', 3, 30, 30, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME4126', 'Thực tập tốt nghiệp Kỹ sư Cơ khí', 5, 0, 150, 0.4, 0.3, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME4227', 'Đồ án tốt nghiệp Kỹ sư Công nghệ Cơ khí', 8, 0, 240, 0.4, 0.3, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ME4228', 'Chuyên đề Tối ưu hóa kết cấu cơ khí', 3, 45, 0, 0.4, 0, 0.6, 3, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 4 (AU) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU1101', 'Nhập môn Công nghệ Kỹ thuật Ô tô', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU1202', 'Vẽ kỹ thuật ô tô & CAD chuyên ngành', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU1203', 'Nhiệt động lực học & Động học chất lưu', 3, 45, 0, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2104', 'Nguyên lý & Kết cấu Động cơ đốt trong 1', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2105', 'Kết cấu khung gầm ô tô & Hệ thống treo', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2106', 'Vật liệu mới và Công nghệ vật liệu ô tô', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2107', 'Cơ học ô tô & Động lực học chuyển động', 3, 45, 0, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2208', 'Nguyên lý & Kết cấu Động cơ đốt trong 2', 4, 30, 60, 0.2, 0.3, 0.5, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2209', 'Hệ thống truyền lực ô tô (Hộp số, Ly hợp, Vi sai)', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2210', 'Hệ thống lái, phanh an toàn và Cân bằng điện tử', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2211', 'Hệ thống điện và điện tử ô tô cơ bản', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU2212', 'Khí thải ô tô và Công nghệ xử lý ô nhiễm', 2, 30, 0, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3113', 'Hệ thống phun xăng và Đánh lửa điện tử EFI/GDI', 4, 30, 60, 0.2, 0.3, 0.5, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3114', 'Điện tử thân xe & Mạng giao tiếp CAN-Bus ô tô', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3115', 'Lý thuyết dao động ô tô & Tiện nghi âm học NVH', 3, 45, 0, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3116', 'Chẩn đoán kỹ thuật và Kiểm định ô tô', 4, 30, 60, 0.2, 0.3, 0.5, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3117', 'Đồ án Kết cấu Động cơ & Khung gầm ô tô', 2, 0, 60, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3218', 'Công nghệ Xe điện (EV) và Xe Hybrid (HEV/PHEV)', 4, 45, 30, 0.2, 0.3, 0.5, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3219', 'Pin ô tô điện & Hệ thống quản lý pin BMS', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3220', 'Thiết kế và Tính toán kết cấu ô tô', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3221', 'Công nghệ Bảo dưỡng & Sửa chữa ô tô hiện đại', 3, 15, 60, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU3222', 'Hệ thống hỗ trợ lái nâng cao ADAS & Xe tự hành', 3, 30, 30, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU4123', 'Đồ án chuyên ngành Công nghệ Ô tô', 3, 0, 90, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU4124', 'Quản trị Dịch vụ sau bán hàng & Xưởng dịch vụ ô tô', 3, 45, 0, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU4125', 'An toàn chủ động và Thử nghiệm va chạm ô tô', 3, 45, 0, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU4126', 'Thực tập tốt nghiệp Kỹ sư Công nghệ Ô tô', 5, 0, 150, 0.4, 0.3, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU4227', 'Đồ án tốt nghiệp Kỹ sư Công nghệ Kỹ thuật Ô tô', 8, 0, 240, 0.4, 0.3, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AU4228', 'Chuyên đề Công nghệ Ô tô thông minh', 3, 45, 0, 0.4, 0, 0.6, 4, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 5 (EC) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC1101', 'Kinh tế vi mô 1', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC1202', 'Kinh tế vĩ mô 1', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC1203', 'Nguyên lý Thống kê kinh tế', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2104', 'Kinh tế vi mô 2 (Trung cấp)', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2105', 'Kinh tế vĩ mô 2 (Trung cấp)', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2106', 'Lý thuyết Tài chính Tiền tệ', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2107', 'Toán kinh tế & Tối ưu hóa tài chính', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2208', 'Tài chính doanh nghiệp 1', 4, 45, 30, 0.2, 0.3, 0.5, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2209', 'Kinh tế lượng căn bản (Econometrics)', 4, 30, 60, 0.2, 0.3, 0.5, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2210', 'Thị trường tài chính và Định chế tài chính', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2211', 'Quản trị Tài chính quốc tế', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC2212', 'Luật kinh tế & Pháp luật tài chính', 2, 30, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3113', 'Tài chính doanh nghiệp 2 & Tái cấu trúc', 4, 45, 30, 0.2, 0.3, 0.5, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3114', 'Đầu tư tài chính và Phân tích chứng khoán', 3, 30, 30, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3115', 'Định giá tài sản và Doanh nghiệp', 3, 30, 30, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3116', 'Nghiệp vụ Ngân hàng thương mại', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3117', 'Phân tích Dữ liệu Tài chính với R/Python', 3, 15, 60, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3218', 'Quản trị rủi ro tài chính & Công cụ phái sinh', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3219', 'Thẩm định dự án đầu tư phát triển', 3, 30, 30, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3220', 'Thuế và Kế hoạch hóa thuế doanh nghiệp', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3221', 'Tài chính hành vi và Tâm lý thị trường', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC3222', 'Mô hình tài chính với Excel nâng cao', 3, 15, 60, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC4123', 'Đồ án phân tích tài chính doanh nghiệp', 3, 0, 90, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC4124', 'Fintech và Công nghệ trong tài chính ngân hàng', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC4125', 'Quản lý quỹ đầu tư và Danh mục tài sản', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC4126', 'Thực tập tốt nghiệp Kinh tế & Tài chính', 5, 0, 150, 0.4, 0.3, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC4227', 'Khóa luận tốt nghiệp Kinh tế & Tài chính', 8, 0, 240, 0.4, 0.3, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EC4228', 'Chuyên đề Tài chính doanh nghiệp hiện đại', 3, 45, 0, 0.4, 0, 0.6, 5, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 6 (AC) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC1101', 'Nguyên lý Kế toán', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC1202', 'Kế toán tài chính 1 (Tài sản ngắn hạn & dài hạn)', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC1203', 'Thống kê kinh doanh trong kế toán', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2104', 'Kế toán tài chính 2 (Nợ phải trả & Vốn chủ)', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2105', 'Kế toán chi phí sản xuất & Giá thành', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2106', 'Hệ thống thông tin kế toán (AIS)', 3, 30, 30, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2107', 'Luật Thuế và Thực hành khai báo thuế', 3, 30, 30, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2208', 'Kế toán tài chính 3 (Doanh thu & Báo cáo)', 4, 45, 30, 0.2, 0.3, 0.5, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2209', 'Kiểm toán căn bản & Đạo đức nghề nghiệp', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2210', 'Kế toán quản trị 1 (Ra quyết định ngắn hạn)', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2211', 'Thực hành kế toán máy trên phần mềm MISA/Fast', 3, 15, 60, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC2212', 'Kế toán công và Đơn vị hành chính sự nghiệp', 2, 30, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3113', 'Kiểm toán Báo cáo tài chính 1', 4, 45, 30, 0.2, 0.3, 0.5, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3114', 'Kế toán quản trị 2 (Định giá & Ngân sách)', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3115', 'Phân tích Báo cáo tài chính doanh nghiệp', 3, 30, 30, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3116', 'Chuẩn mực kế toán quốc tế IFRS/IAS', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3117', 'Đồ án mô phỏng hoạt động kế toán doanh nghiệp', 2, 0, 60, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3218', 'Kiểm toán Báo cáo tài chính 2', 4, 45, 30, 0.2, 0.3, 0.5, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3219', 'Kiểm toán nội bộ và Quản trị rủi ro DN', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3220', 'Kế toán tài chính quốc tế và Giao dịch ngoại tệ', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3221', 'Kiểm soát nội bộ trong doanh nghiệp', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC3222', 'Phân tích dữ liệu kế toán và kiểm toán với Excel/Power BI', 3, 15, 60, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC4123', 'Đồ án chuyên ngành Kế toán - Kiểm toán', 3, 0, 90, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC4124', 'Kiểm toán hoạt động và Kiểm toán tuân thủ', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC4125', 'Gian lận kế toán và Pháp y kế toán (Forensic)', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC4126', 'Thực tập tốt nghiệp Kế toán - Kiểm toán', 5, 0, 150, 0.4, 0.3, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC4227', 'Khóa luận tốt nghiệp Kế toán - Kiểm toán', 8, 0, 240, 0.4, 0.3, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('AC4228', 'Chuyên đề Kế toán quản trị chiến lược', 3, 45, 0, 0.4, 0, 0.6, 6, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 7 (EN) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN1101', 'Ngữ âm và Âm vị học tiếng Anh', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN1202', 'Ngữ pháp tiếng Anh nâng cao 1', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN1203', 'Kỹ năng Đọc học thuật tiếng Anh 1', 3, 30, 30, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2104', 'Ngữ pháp tiếng Anh nâng cao 2', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2105', 'Kỹ năng Viết luận học thuật tiếng Anh 1', 3, 30, 30, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2106', 'Kỹ năng Nghe - Nói nâng cao 1', 3, 15, 60, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2107', 'Dẫn luận ngôn ngữ học (Linguistics)', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2208', 'Kỹ năng Viết học thuật tiếng Anh 2', 3, 30, 30, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2209', 'Kỹ năng Nghe - Nói nâng cao 2', 3, 15, 60, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2210', 'Tiếng Anh thương mại căn bản', 4, 45, 30, 0.2, 0.3, 0.5, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2211', 'Văn hóa các nước nói tiếng Anh (Anh - Mỹ)', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN2212', 'Ngữ nghĩa học & Ngữ dụng học tiếng Anh', 2, 30, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3113', 'Lý thuyết & Kỹ thuật Biên dịch Anh - Việt', 4, 30, 60, 0.2, 0.3, 0.5, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3114', 'Lý thuyết & Kỹ thuật Phiên dịch Anh - Việt', 4, 30, 60, 0.2, 0.3, 0.5, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3115', 'Thư tín và Hợp đồng thương mại bằng tiếng Anh', 3, 30, 30, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3116', 'Giao tiếp kinh doanh đa văn hóa', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3117', 'Tiếng Anh tài chính - ngân hàng', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3218', 'Biên dịch chuyên ngành kinh tế & thương mại', 4, 30, 60, 0.2, 0.3, 0.5, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3219', 'Phiên dịch hội thảo và đàm phán thương mại', 4, 30, 60, 0.2, 0.3, 0.5, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3220', 'Tiếng Anh Logistics và Xuất nhập khẩu', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3221', 'Thuyết trình và Đàm phán kinh doanh bằng tiếng Anh', 3, 15, 60, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN3222', 'Tiếng Anh Marketing và Quảng cáo số', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN4123', 'Đồ án Biên - Phiên dịch thương mại', 3, 0, 90, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN4124', 'Tiếng Anh Quản trị nhân sự & Pháp lý kinh doanh', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN4125', 'Phương pháp nghiên cứu ngôn ngữ ứng dụng', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN4126', 'Thực tập tốt nghiệp Ngôn ngữ Anh Thương mại', 5, 0, 150, 0.4, 0.3, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN4227', 'Khóa luận tốt nghiệp Ngôn ngữ Anh Thương mại', 8, 0, 240, 0.4, 0.3, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('EN4228', 'Chuyên đề Ngôn ngữ học ứng dụng trong kinh doanh', 3, 45, 0, 0.4, 0, 0.6, 7, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 8 (CH) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH1101', 'Hóa học đại cương & vô cơ', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH1202', 'Hóa học hữu cơ 1', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH1203', 'Hóa lý và Hóa keo 1 (Nhiệt động học)', 3, 45, 0, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2104', 'Hóa học hữu cơ 2', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2105', 'Hóa học phân tích định tính & định lượng', 4, 30, 60, 0.2, 0.3, 0.5, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2106', 'Hóa lý và Hóa keo 2 (Động học & Điện hóa)', 3, 45, 0, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2107', 'Vẽ kỹ thuật và CAD ngành công nghệ hóa học', 3, 15, 60, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2208', 'Quá trình và Thiết bị công nghệ hóa học 1 (Thủy lực - Cơ học)', 4, 45, 30, 0.2, 0.3, 0.5, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2209', 'Hóa phân tích dụng cụ và Quang phổ', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2210', 'Kỹ thuật Phản ứng hóa học & Động học', 3, 45, 0, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2211', 'Công nghệ các hợp chất vô cơ cơ bản', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH2212', 'An toàn hóa chất và Phòng chống cháy nổ', 2, 30, 0, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3113', 'Quá trình và Thiết bị công nghệ hóa học 2 (Truyền nhiệt - Truyền khối)', 4, 45, 30, 0.2, 0.3, 0.5, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3114', 'Đồ án Quá trình & Thiết bị công nghệ hóa học', 2, 0, 60, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3115', 'Công nghệ Tổng hợp hữu cơ và Hóa dầu', 4, 45, 30, 0.2, 0.3, 0.5, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3116', 'Công nghệ Vật liệu Polyme và Compozit', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3117', 'Kỹ thuật Điện hóa và Chống ăn mòn kim loại', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3218', 'Công nghệ Hóa dược và Mỹ phẩm thiên nhiên', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3219', 'Công nghệ Vật liệu Silicat, Gốm sứ & Xi măng', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3220', 'Tự động hóa và Đo lường trong nhà máy hóa chất', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3221', 'Công nghệ Xử lý chất thải và Nước thải công nghiệp hóa chất', 3, 30, 30, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH3222', 'Mô phỏng quy trình hóa học với Aspen Plus/HYSYS', 3, 15, 60, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH4123', 'Đồ án chuyên ngành Công nghệ Hóa học', 3, 0, 90, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH4124', 'Công nghệ Năng lượng tái tạo và Nhiên liệu sinh học', 3, 45, 0, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH4125', 'Quản lý chất lượng & Đảm bảo an toàn nhà máy hóa chất', 3, 45, 0, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH4126', 'Thực tập tốt nghiệp Kỹ sư Hóa học', 5, 0, 150, 0.4, 0.3, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH4227', 'Đồ án tốt nghiệp Kỹ sư Công nghệ Kỹ thuật Hóa học', 8, 0, 240, 0.4, 0.3, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('CH4228', 'Chuyên đề Công nghệ Hóa học xanh', 3, 45, 0, 0.4, 0, 0.6, 8, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 9 (FA) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA1101', 'Lịch sử Mỹ thuật và Trang phục thế giới', 3, 45, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA1202', 'Hình họa và Kỹ thuật phác thảo dáng người', 3, 15, 60, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA1203', 'Vật liệu dệt may & Kiểm tra chất lượng xơ sợi', 3, 30, 30, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2104', 'Nguyên lý Thiết kế thời trang & Bảng phối màu', 3, 30, 30, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2105', 'Công nghệ may căn bản và Đường may công nghiệp', 4, 15, 90, 0.2, 0.3, 0.5, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2106', 'Vẽ kỹ thuật trang phục & Bản vẽ thông số', 3, 15, 60, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2107', 'Thiết kế mẫu rập 2D cơ bản (Áo, Váy, Quần)', 3, 15, 60, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2208', 'Thiết kế mẫu rập nâng cao & Biến kiểu trang phục', 4, 15, 90, 0.2, 0.3, 0.5, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2209', 'Công nghệ may công nghiệp áo sơ mi & quần âu', 4, 15, 90, 0.2, 0.3, 0.5, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2210', 'Ứng dụng Tin học trong thiết kế thời trang (Photoshop/Illustrator)', 3, 15, 60, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2211', 'Công nghệ dệt và Kỹ thuật nhuộm - in vải', 3, 30, 30, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA2212', 'Nhân trắc học và Định chuẩn cỡ số may mặc', 2, 30, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3113', 'Thiết kế mẫu rập trên máy tính Gerber Accumark', 4, 15, 90, 0.2, 0.3, 0.5, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3114', 'Công nghệ may áo khoác jacket và Veston 1', 4, 15, 90, 0.2, 0.3, 0.5, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3115', 'Tổ chức và Cân bằng chuyền may công nghiệp', 3, 30, 30, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3116', 'Định mức kinh tế - kỹ thuật trong sản xuất may', 3, 45, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3117', 'Đồ án Thiết kế trang phục thường nhật (Ready-to-Wear)', 2, 0, 60, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3218', 'Thiết kế mẫu rập 3D ảo và Fitting với CLO 3D', 4, 15, 90, 0.2, 0.3, 0.5, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3219', 'Công nghệ may Veston cao cấp & Trang phục dạ hội', 4, 15, 90, 0.2, 0.3, 0.5, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3220', 'Quản lý chất lượng sản phẩm may mặc (AQL/ISO)', 3, 45, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3221', 'Marketing thời trang và Dự báo xu hướng (Trend Forecasting)', 3, 45, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA3222', 'Quản trị chuỗi cung ứng ngành dệt may toàn cầu', 3, 45, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA4123', 'Đồ án Thiết kế bộ sưu tập thời trang', 3, 0, 90, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA4124', 'Kỹ thuật may trang phục thể thao & Đồ lót cao cấp', 3, 15, 60, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA4125', 'Quản trị thương hiệu và Bán lẻ thời trang hiện đại', 3, 45, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA4126', 'Thực tập tốt nghiệp Doanh nghiệp May & Thời trang', 5, 0, 150, 0.4, 0.3, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA4227', 'Đồ án tốt nghiệp Công nghệ May & Thiết kế Thời trang', 8, 0, 240, 0.4, 0.3, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FA4228', 'Chuyên đề Phát triển thời trang bền vững (Sustainable Fashion)', 3, 45, 0, 0.4, 0, 0.6, 9, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 10 (BA) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA1101', 'Quản trị học căn bản', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA1202', 'Marketing căn bản', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA1203', 'Hành vi khách hàng và Tâm lý tiêu dùng', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2104', 'Quản trị Nguồn nhân lực', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2105', 'Hành vi tổ chức (Organizational Behavior)', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2106', 'Pháp luật trong kinh doanh thương mại', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2107', 'Quản trị Tác nghiệp doanh nghiệp', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2208', 'Quản trị Chuỗi cung ứng căn bản (SCM)', 4, 45, 30, 0.2, 0.3, 0.5, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2209', 'Quản trị Logistics & Vận tải hàng hóa', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2210', 'Nghiên cứu thị trường và Phân tích dữ liệu kinh doanh', 4, 30, 60, 0.2, 0.3, 0.5, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2211', 'Quản trị Bán hàng và Kênh phân phối', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA2212', 'Giao tiếp và Đàm phán trong kinh doanh quốc tế', 2, 30, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3113', 'Quản trị Chiến lược doanh nghiệp', 4, 45, 30, 0.2, 0.3, 0.5, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3114', 'Quản trị Kho hàng và Trung tâm phân phối (DC)', 3, 30, 30, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3115', 'Quản trị Thu mua và Quản lý nhà cung cấp', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3116', 'Thương mại điện tử và Kinh doanh số', 3, 30, 30, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3117', 'Đồ án Quản trị chuỗi cung ứng thực tế', 2, 0, 60, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3218', 'Hệ thống hoạch định tài nguyên doanh nghiệp ERP (SAP/Odoo)', 4, 30, 60, 0.2, 0.3, 0.5, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3219', 'Logistics Quốc tế và Thủ tục Hải quan xuất nhập khẩu', 4, 45, 30, 0.2, 0.3, 0.5, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3220', 'Quản trị Dự án và Đổi mới sáng tạo', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3221', 'Quản trị Chất lượng toàn diện (TQM/Lean/Six Sigma)', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA3222', 'Digital Marketing & Tối ưu hóa chuyển đổi', 3, 30, 30, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA4123', 'Đồ án Kế hoạch kinh doanh & Khởi nghiệp', 3, 0, 90, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA4124', 'Quản trị rủi ro và Khủng hoảng trong chuỗi cung ứng', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA4125', 'Quản trị chuỗi cung ứng xanh và Phát triển bền vững', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA4126', 'Thực tập tốt nghiệp Quản trị Kinh doanh & Chuỗi cung ứng', 5, 0, 150, 0.4, 0.3, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA4227', 'Khóa luận tốt nghiệp Quản trị Kinh doanh & Chuỗi cung ứng', 8, 0, 240, 0.4, 0.3, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('BA4228', 'Chuyên đề Lãnh đạo và Quản trị biến đổi', 3, 45, 0, 0.4, 0, 0.6, 10, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 11 (ROB) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB1101', 'Nhập môn Kỹ thuật Robot & Cơ điện tử', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB1202', 'Kỹ thuật điện & Thiết kế mạch điện tử Robot', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB1203', 'Lập trình C/C++ cho Hệ thống nhúng Robot', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2104', 'Cơ sở Robot công nghiệp & Cấu trúc tay máy', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2105', 'Lý thuyết Điều khiển tự động 1 (Tuyến tính)', 3, 45, 0, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2106', 'Cảm biến và Kỹ thuật đo lường thông minh', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2107', 'Thiết kế cơ khí Robot với CAD 3D', 3, 15, 60, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2208', 'Động học và Động lực học Robot', 4, 45, 30, 0.2, 0.3, 0.5, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2209', 'Cơ cấu chấp hành và Truyền động Robot (Servo/Stepper)', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2210', 'Hệ điều khiển Logic lập trình PLC & Màn hình HMI', 4, 30, 60, 0.2, 0.3, 0.5, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2211', 'Hệ thống Khí nén và Thủy lực điều khiển số', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB2212', 'An toàn và Tiêu chuẩn trong hệ thống Robot', 2, 30, 0, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3113', 'Lập trình và Vận hành Robot công nghiệp (ABB/KUKA)', 4, 30, 60, 0.2, 0.3, 0.5, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3114', 'Thị giác máy tính và Xử lý ảnh cho Robot (OpenCV)', 4, 30, 60, 0.2, 0.3, 0.5, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3115', 'Lý thuyết Điều khiển tự động 2 (Phi tuyến & Số)', 3, 45, 0, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3116', 'Hệ thống SCADA và Thu thập dữ liệu IoT công nghiệp', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3117', 'Đồ án Thiết kế Tay máy Robot công nghiệp', 2, 0, 60, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3218', 'Hệ điều hành Robot chuyên dụng ROS/ROS2', 4, 30, 60, 0.2, 0.3, 0.5, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3219', 'Robot tự hành AGV/AMR và Bản đồ hóa SLAM', 4, 30, 60, 0.2, 0.3, 0.5, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3220', 'Trí tuệ nhân tạo & Học tăng cường cho Robot', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3221', 'Mô phỏng Robot trên nền tảng Gazebo và MATLAB', 3, 15, 60, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB3222', 'Tích hợp dây chuyền tự động hóa và Robot hàn/gắp', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB4123', 'Đồ án chuyên ngành Kỹ thuật Robot & Tự động hóa', 3, 0, 90, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB4124', 'Robot cộng tác (Cobot) và Tương tác Người - Máy (HRI)', 3, 30, 30, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB4125', 'Điều khiển thích nghi và Điều khiển bền vững', 3, 45, 0, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB4126', 'Thực tập tốt nghiệp Kỹ sư Robot & Tự động hóa', 5, 0, 150, 0.4, 0.3, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB4227', 'Đồ án tốt nghiệp Kỹ sư Robot & Tự động hóa', 8, 0, 240, 0.4, 0.3, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('ROB4228', 'Chuyên đề Công nghệ Robot thông minh thế hệ mới', 3, 45, 0, 0.4, 0, 0.6, 11, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;
-- --- Department 15 (FD) ---

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD1101', 'Nhập môn Khoa học và Công nghệ Thực phẩm', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD1202', 'Hóa sinh học thực phẩm căn bản', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD1203', 'Vi sinh vật học thực phẩm 1', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2104', 'Vi sinh vật học thực phẩm 2 & Lên men', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2105', 'Hóa học và Hóa lý thực phẩm', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2106', 'Phân tích thực phẩm định tính & định lượng', 4, 30, 60, 0.2, 0.3, 0.5, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2107', 'Dinh dưỡng người và Vệ sinh an toàn thực phẩm', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2208', 'Quá trình và Thiết bị công nghệ thực phẩm 1', 4, 45, 30, 0.2, 0.3, 0.5, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2209', 'Đánh giá cảm quan thực phẩm và Thị hiếu người dùng', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2210', 'Phụ gia thực phẩm và Chất bổ trợ chế biến', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2211', 'Độc chất học thực phẩm và Kiểm soát ô nhiễm', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD2212', 'Luật an toàn thực phẩm và Tiêu chuẩn Codex', 2, 30, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3113', 'Quá trình và Thiết bị công nghệ thực phẩm 2', 4, 45, 30, 0.2, 0.3, 0.5, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3114', 'Đồ án Quá trình và Thiết bị thực phẩm', 2, 0, 60, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3115', 'Công nghệ Chế biến lương thực và Rau quả', 4, 45, 30, 0.2, 0.3, 0.5, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3116', 'Công nghệ Chế biến sữa và Sản phẩm từ sữa', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3117', 'Công nghệ Chế biến dầu thực vật và Chất béo', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3218', 'Công nghệ Chế biến thịt, trứng và Thủy hải sản', 4, 45, 30, 0.2, 0.3, 0.5, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3219', 'Công nghệ Sản xuất đồ uống và Sản phẩm lên men (Bia, Rượu, Nước ngọt)', 4, 45, 30, 0.2, 0.3, 0.5, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3220', 'Hệ thống Quản lý chất lượng & ATTP (HACCP/ISO 22000)', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3221', 'Công nghệ Bao gói và Bảo quản thực phẩm tiên tiến', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD3222', 'Phát triển sản phẩm thực phẩm mới (New Product Development)', 3, 30, 30, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD4123', 'Đồ án chuyên ngành Công nghệ Thực phẩm', 3, 0, 90, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD4124', 'Công nghệ sinh học trong chế biến và bảo quản thực phẩm', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD4125', 'Quản lý chuỗi cung ứng thực phẩm an toàn (From Farm to Fork)', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD4126', 'Thực tập tốt nghiệp Kỹ sư Công nghệ Thực phẩm', 5, 0, 150, 0.4, 0.3, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD4227', 'Đồ án tốt nghiệp Kỹ sư Công nghệ Thực phẩm', 8, 0, 240, 0.4, 0.3, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_by)
VALUES ('FD4228', 'Chuyên đề Công nghệ Thực phẩm chức năng', 3, 45, 0, 0.4, 0, 0.6, 15, 'SYSTEM')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight,
    department_id = EXCLUDED.department_id;

-- 3. Link courses to program_courses for all 12 degree programs
DELETE FROM program_courses WHERE program_id BETWEEN 2 AND 12;

-- Link courses to Program 1 (Major Dept 1)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 1, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 2 (Major Dept 2)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'EE1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'EE1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'EE1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EE2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EE2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EE2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EE2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EE2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EE2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EE2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EE2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EE2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EE3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EE3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EE3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EE3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EE3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EE3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EE3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EE3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EE3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EE3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EE4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EE4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EE4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EE4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'EE4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 2, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'EE4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 3 (Major Dept 3)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ME1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ME1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ME1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ME2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ME2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ME2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ME2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ME2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ME2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ME2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ME2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ME2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ME3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ME3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ME3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ME3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ME3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ME3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ME3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ME3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ME3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ME3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ME4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ME4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ME4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ME4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'ME4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 3, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'ME4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 4 (Major Dept 4)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'AU1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'AU1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'AU1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AU2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AU2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AU2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AU2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AU2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AU2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AU2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AU2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AU2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AU3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AU3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AU3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AU3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AU3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AU3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AU3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AU3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AU3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AU3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AU4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AU4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AU4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AU4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'AU4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 4, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'AU4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 5 (Major Dept 5)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'EC1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'EC1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'EC1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EC2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EC2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EC2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EC2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EC2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EC2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EC2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EC2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EC2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EC3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EC3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EC3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EC3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EC3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EC3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EC3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EC3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EC3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EC3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EC4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EC4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EC4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EC4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'EC4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 5, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'EC4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 6 (Major Dept 6)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'AC1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'AC1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'AC1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AC2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AC2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AC2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'AC2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AC2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AC2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AC2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AC2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'AC2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AC3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AC3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AC3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AC3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'AC3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AC3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AC3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AC3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AC3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'AC3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AC4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AC4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AC4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'AC4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'AC4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 6, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'AC4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 7 (Major Dept 7)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'EN1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'EN1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'EN1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EN2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EN2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EN2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'EN2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EN2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EN2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EN2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EN2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'EN2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EN3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EN3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EN3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EN3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'EN3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EN3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EN3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EN3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EN3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'EN3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EN4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EN4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EN4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'EN4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'EN4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 7, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'EN4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 8 (Major Dept 8)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'CH1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'CH1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'CH1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'CH2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'CH2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'CH2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'CH2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'CH2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'CH2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'CH2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'CH2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'CH2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'CH3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'CH3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'CH3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'CH3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'CH3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'CH3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'CH3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'CH3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'CH3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'CH3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'CH4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'CH4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'CH4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'CH4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'CH4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 8, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'CH4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 9 (Major Dept 9)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'FA1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'FA1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'FA1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FA2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FA2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FA2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FA2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FA2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FA2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FA2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FA2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FA2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FA3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FA3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FA3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FA3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FA3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FA3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FA3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FA3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FA3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FA3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FA4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FA4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FA4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FA4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'FA4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 9, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'FA4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 10 (Major Dept 10)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BA1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BA1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BA1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BA2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BA2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BA2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BA2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BA2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BA2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BA2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BA2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BA2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BA3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BA3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BA3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BA3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BA3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'BA3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'BA3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'BA3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'BA3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'BA3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'BA4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'BA4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'BA4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'BA4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'BA4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 10, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'BA4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 11 (Major Dept 11)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ROB1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ROB1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ROB1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'ROB2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'ROB3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ROB4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ROB4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ROB4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'ROB4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'ROB4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 11, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'ROB4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
-- Link courses to Program 12 (Major Dept 15)

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'LAW1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'PE1201'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'BAS1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'ENG1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'PE2102'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2103'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'MAT1204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'BAS2204'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'BAS3105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 1, true, 'SYSTEM'
FROM courses WHERE code = 'FD1101'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'FD1202'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 2, true, 'SYSTEM'
FROM courses WHERE code = 'FD1203'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FD2104'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FD2105'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FD2106'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 3, true, 'SYSTEM'
FROM courses WHERE code = 'FD2107'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FD2208'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FD2209'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FD2210'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FD2211'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 4, true, 'SYSTEM'
FROM courses WHERE code = 'FD2212'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FD3113'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FD3114'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FD3115'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FD3116'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 5, true, 'SYSTEM'
FROM courses WHERE code = 'FD3117'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FD3218'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FD3219'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FD3220'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FD3221'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 6, true, 'SYSTEM'
FROM courses WHERE code = 'FD3222'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FD4123'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FD4124'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FD4125'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 7, true, 'SYSTEM'
FROM courses WHERE code = 'FD4126'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'FD4227'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_by)
SELECT 12, id, 8, true, 'SYSTEM'
FROM courses WHERE code = 'FD4228'
ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;

-- 4. Point 3: Ensure each class section has EXACTLY ONE weekly session (remove duplicate/overlapping sessions)
DELETE FROM class_schedules a
WHERE a.id NOT IN (
    SELECT min(b.id)
    FROM class_schedules b
    GROUP BY b.class_section_id
);

-- 5. Point 5: Initialize and populate grades for all enrollments in finished/closed/past sections
INSERT INTO grades (enrollment_id, is_locked, created_by)
SELECT e.id, false, 'SYSTEM'
FROM enrollments e
WHERE NOT EXISTS (SELECT 1 FROM grades g WHERE g.enrollment_id = e.id);

DO $$
DECLARE
    rec RECORD;
    v_seed BIGINT;
    v_base NUMERIC(4,2);
    v_tx1 NUMERIC(4,2);
    v_tx2 NUMERIC(4,2);
    v_mid NUMERIC(4,2);
    v_fin NUMERIC(4,2);
    v_avg_tx NUMERIC(4,2);
    v_total NUMERIC(4,2);
    v_gpa NUMERIC(3,2);
    v_letter VARCHAR(5);
    v_passed BOOLEAN;
BEGIN
    FOR rec IN
        SELECT g.id as grade_id, e.id as enrollment_id, cs.id as section_id, c.credits, c.attendance_weight, c.midterm_weight, c.final_weight
        FROM grades g
        JOIN enrollments e ON g.enrollment_id = e.id
        JOIN class_sections cs ON e.class_section_id = cs.id
        JOIN courses c ON cs.course_id = c.id
        JOIN semesters sem ON cs.semester_id = sem.id
        WHERE g.total_score_10 IS NULL
          AND (sem.is_register_open = false OR cs.status = 'CLOSED' OR cs.id IN (188, 187, 5, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 151, 152, 153, 154, 155, 156))
    LOOP
        v_seed := (rec.enrollment_id * 31 + rec.section_id * 17);
        v_base := 7.0 + ((ABS(v_seed) % 26) / 10.0);
        
        v_tx1 := LEAST(10.0, ROUND(v_base, 1));
        v_tx2 := LEAST(10.0, ROUND(v_base + (((v_seed % 5) - 2) * 0.2), 1));
        v_avg_tx := ROUND((v_tx1 + v_tx2) / 2.0, 2);
        v_fin := LEAST(10.0, ROUND(v_base + (((v_seed % 7) - 3) * 0.2), 1));
        
        IF rec.credits >= 4 THEN
            v_mid := LEAST(10.0, ROUND(v_base + (((v_seed % 5) - 2) * 0.2), 1));
            v_total := ROUND((v_avg_tx * 0.20 + v_mid * 0.30 + v_fin * 0.50), 1);
        ELSE
            v_mid := NULL;
            v_total := ROUND((v_avg_tx * 0.40 + v_fin * 0.60), 1);
        END IF;

        IF v_total >= 9.0 THEN v_letter := 'A+'; v_gpa := 4.0;
        ELSIF v_total >= 8.5 THEN v_letter := 'A'; v_gpa := 3.7;
        ELSIF v_total >= 8.0 THEN v_letter := 'B+'; v_gpa := 3.5;
        ELSIF v_total >= 7.0 THEN v_letter := 'B'; v_gpa := 3.0;
        ELSIF v_total >= 6.5 THEN v_letter := 'C+'; v_gpa := 2.5;
        ELSIF v_total >= 5.5 THEN v_letter := 'C'; v_gpa := 2.0;
        ELSIF v_total >= 5.0 THEN v_letter := 'D+'; v_gpa := 1.5;
        ELSIF v_total >= 4.0 THEN v_letter := 'D'; v_gpa := 1.0;
        ELSE v_letter := 'F'; v_gpa := 0.0;
        END IF;
        
        v_passed := (v_total >= 4.0);

        UPDATE grades
        SET regular_score_1 = v_tx1,
            regular_score_2 = v_tx2,
            attendance_score = v_avg_tx,
            midterm_score = v_mid,
            final_score = v_fin,
            total_score_10 = v_total,
            gpa_score_4 = v_gpa,
            letter_grade = v_letter,
            is_locked = true
        WHERE id = rec.grade_id;
    END LOOP;
END $$;
