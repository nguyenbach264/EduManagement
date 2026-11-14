-- V5__enhanced_features_and_curriculum.sql: 140 Credits, 8 Semesters, 34 Provinces, Multi-week Schedule, Course Details, and Class Section Grades

-- 1. Schema Enhancements
ALTER TABLE students ADD COLUMN IF NOT EXISTS class_name VARCHAR(50);
ALTER TABLE students ADD COLUMN IF NOT EXISTS province VARCHAR(100);
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS phone VARCHAR(30);
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS email VARCHAR(100);
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS academic_title VARCHAR(50);
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS office_address VARCHAR(150);
ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS start_week INT NOT NULL DEFAULT 1;
ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS end_week INT NOT NULL DEFAULT 15;
ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS building VARCHAR(50);
ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS campus VARCHAR(50);

CREATE TABLE IF NOT EXISTS course_teachers (
    course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id BIGINT NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,
    PRIMARY KEY (course_id, teacher_id)
);

-- 2. Populate Students with Class Name and 34 Provinces
DO $$
DECLARE
    s_rec RECORD;
    i INT := 0;
    provs TEXT[] := ARRAY[
        'Thành phố Hà Nội',
        'Thành phố Hồ Chí Minh',
        'Thành phố Hải Phòng',
        'Thành phố Đà Nẵng',
        'Thành phố Cần Thơ',
        'Tỉnh Hà Nam Ninh',
        'Tỉnh Hải Hưng',
        'Tỉnh Bắc Thái',
        'Tỉnh Hà Bắc',
        'Tỉnh Vĩnh Phú',
        'Tỉnh Hà Giang - Tuyên Quang',
        'Tỉnh Cao Lạng',
        'Tỉnh Lào Cai - Yên Bái',
        'Tỉnh Lai Châu - Điện Biên',
        'Tỉnh Sơn La',
        'Tỉnh Hòa Bình',
        'Tỉnh Quảng Ninh',
        'Tỉnh Thanh Hóa',
        'Tỉnh Nghệ Tĩnh',
        'Tỉnh Bình Trị Thiên',
        'Tỉnh Quảng Nam - Quảng Ngãi',
        'Tỉnh Nghĩa Bình',
        'Tỉnh Khánh Hòa - Ninh Thuận',
        'Tỉnh Bình Thuận - Lâm Đồng',
        'Tỉnh Gia Lai - Kon Tum',
        'Tỉnh Đắk Lắk - Đắk Nông',
        'Tỉnh Sông Bé',
        'Tỉnh Đồng Nai',
        'Tỉnh Tây Ninh',
        'Tỉnh Bà Rịa - Vũng Tàu',
        'Tỉnh Long An - Tiền Giang',
        'Tỉnh Bến Tre - Trà Vinh',
        'Tỉnh Vĩnh Long - Hậu Giang - Sóc Trăng',
        'Tỉnh Cà Mau - Bạc Liêu - Kiên Giang'
    ];
    classes TEXT[] := ARRAY[
        'D21CNTT01',
        'D21CNTT02',
        'D21KTPM01',
        'D21KTPM02',
        'D22ANM01',
        'D22ANM02',
        'D22DS01',
        'D22AI01',
        'D23NNA01',
        'D23NNA02',
        'D21QTKD01',
        'D22TCNH01'
    ];
BEGIN
    FOR s_rec IN SELECT id FROM students ORDER BY id LOOP
        UPDATE students SET
            class_name = classes[(i % array_length(classes, 1)) + 1],
            province = provs[(i % array_length(provs, 1)) + 1],
            gender = CASE WHEN i % 3 = 0 THEN 'Nữ' ELSE 'Nam' END,
            date_of_birth = DATE '2003-01-15' + (i * 37 % 800),
            address = CONCAT('Số ', (i * 13 % 150) + 1, ', Đường Giải Phóng, ', provs[(i % array_length(provs, 1)) + 1])
        WHERE id = s_rec.id;
        i := i + 1;
    END LOOP;
END $$;

-- 3. Populate Teachers with contact & titles
DO $$
DECLARE
    t_rec RECORD;
    i INT := 0;
    titles TEXT[] := ARRAY['Tiến sĩ', 'Phó Giáo sư, Tiến sĩ', 'Giáo sư, Tiến sĩ', 'Thạc sĩ'];
BEGIN
    FOR t_rec IN SELECT t.id, u.username FROM teachers t JOIN users u ON t.user_id = u.id ORDER BY t.id LOOP
        UPDATE teachers SET
            academic_title = titles[(i % 4) + 1],
            phone = CONCAT('09', LPAD(((i * 1234567) % 90000000 + 10000000)::text, 8, '0')),
            email = CONCAT(t_rec.username, '@daihoc.edu.vn'),
            office_address = CONCAT('Phòng ', (i % 6 + 1) * 100 + (i % 8 + 1), ', Tòa nhà A1, Cơ sở 1')
        WHERE id = t_rec.id;
        i := i + 1;
    END LOOP;
END $$;

-- 4. Insert 140 Credits Curriculum Courses
INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'BAS1101', 'Triết học Mác - Lênin', 3, 45, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'ENG1101', 'Tiếng Anh cơ bản 1', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'MAT1101', 'Giải tích 1', 3, 45, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'MAT1102', 'Đại số tuyến tính', 3, 45, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'CS1101', 'Tin học đại cương', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'LAW1101', 'Pháp luật đại cương', 3, 45, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'BAS1202', 'Kinh tế chính trị Mác - Lênin', 2, 30, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'ENG1202', 'Tiếng Anh cơ bản 2', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'MAT1203', 'Giải tích 2', 3, 45, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'MAT1204', 'Xác suất thống kê', 3, 45, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'CS1202', 'Nhập môn lập trình C/C++', 4, 30, 30, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'PE1201', 'Giáo dục thể chất 1 (Điền kinh)', 3, 15, 30, 0.2, 0.3, 0.5, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'BAS2103', 'Chủ nghĩa xã hội khoa học', 2, 30, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'CS2103', 'Lập trình hướng đối tượng (Java)', 4, 30, 30, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'CS2104', 'Cấu trúc dữ liệu và giải thuật', 4, 30, 30, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'CS2105', 'Kiến trúc máy tính và Hệ điều hành', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'ENG2103', 'Tiếng Anh chuyên ngành CNTT', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'PE2102', 'Giáo dục thể chất 2 (Bóng chuyền)', 2, 10, 20, 0.2, 0.3, 0.5, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'BAS2204', 'Tư tưởng Hồ Chí Minh', 2, 30, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'CS2206', 'Cơ sở dữ liệu quan hệ (SQL & PostgreSQL)', 4, 30, 30, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE2201', 'Nhập môn Kỹ thuật phần mềm', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'NET2201', 'Mạng máy tính & Truyền thông', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE2202', 'Thiết kế giao diện người dùng (UI/UX)', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE2203', 'Lập trình Web căn bản (HTML5/CSS/JS)', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'BAS3105', 'Lịch sử Đảng Cộng sản Việt Nam', 2, 30, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3104', 'Phân tích và thiết kế hệ thống', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3105', 'Lập trình Web nâng cao & Spring Boot', 4, 30, 30, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3106', 'Kiến trúc phần mềm & Design Patterns', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3107', 'Kiểm thử và đảm bảo chất lượng phần mềm', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3108', 'Quản lý dự án phần mềm', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3209', 'Phát triển ứng dụng di động', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3210', 'Điện toán đám mây & DevOps', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3211', 'An toàn và bảo mật thông tin', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3212', 'Phát triển phần mềm Agile/Scrum', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3213', 'Dịch vụ mạng & API RESTful', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE3214', 'Trí tuệ nhân tạo ứng dụng', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE4115', 'Hệ thống phân tán & Microservices', 4, 30, 30, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE4116', 'Công nghệ Dữ liệu lớn (Big Data)', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE4117', 'Chuyên đề công nghệ mới (AI/Blockchain)', 3, 30, 15, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE4118', 'Dự án phát triển phần mềm thực chiến (Capstone)', 4, 15, 45, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'SE4119', 'Đạo đức nghề nghiệp & Sở hữu trí tuệ', 3, 45, 0, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'INT4900', 'Thực tập doanh nghiệp', 6, 0, 90, 0.2, 0.3, 0.5, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
SELECT 'PRJ4950', 'Đồ án tốt nghiệp / Khóa luận tốt nghiệp', 9, 0, 135, 0.1, 0.3, 0.6, id, CURRENT_TIMESTAMP, 0
FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,
    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;

-- 5. Course Prerequisites
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'BAS1202' AND p.code = 'BAS1101'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'ENG1202' AND p.code = 'ENG1101'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'MAT1203' AND p.code = 'MAT1101'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'MAT1204' AND p.code = 'MAT1101'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'CS1202' AND p.code = 'CS1101'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'BAS2103' AND p.code = 'BAS1202'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'CS2103' AND p.code = 'CS1202'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'CS2104' AND p.code = 'CS1202'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'ENG2103' AND p.code = 'ENG1202'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'BAS2204' AND p.code = 'BAS2103'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'CS2206' AND p.code = 'CS2104'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE2201' AND p.code = 'CS2103'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'NET2201' AND p.code = 'CS2105'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE2203' AND p.code = 'CS2103'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'BAS3105' AND p.code = 'BAS2204'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3104' AND p.code = 'CS2206'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3105' AND p.code = 'SE2203'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3106' AND p.code = 'SE2201'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3107' AND p.code = 'SE2201'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3108' AND p.code = 'SE2201'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3209' AND p.code = 'CS2103'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3210' AND p.code = 'NET2201'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3211' AND p.code = 'NET2201'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3212' AND p.code = 'SE3108'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3213' AND p.code = 'SE3105'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE3214' AND p.code = 'CS2104'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE4115' AND p.code = 'SE3213'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE4116' AND p.code = 'CS2206'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE4118' AND p.code = 'SE3105'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'SE4118' AND p.code = 'SE3107'
ON CONFLICT DO NOTHING;
INSERT INTO course_prerequisites (course_id, prerequisite_id)
SELECT c.id, p.id FROM courses c, courses p WHERE c.code = 'PRJ4950' AND p.code = 'INT4900'
ON CONFLICT DO NOTHING;

-- 6. Link Program Courses (140 credits across 8 semesters)
UPDATE academic_programs SET total_credits = 140 WHERE id IN (1, 2, 3, 4, 5, 6);
DELETE FROM program_courses WHERE program_id IN (1, 2, 3, 4, 5, 6);

DO $$
DECLARE
    prog_rec RECORD;
    p_all RECORD;
BEGIN
    FOR prog_rec IN SELECT id FROM academic_programs WHERE id IN (1, 2, 3, 4, 5, 6) LOOP
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 1, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'BAS1101'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 1, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'ENG1101'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 1, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'MAT1101'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 1, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'MAT1102'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 1, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'CS1101'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 1, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'LAW1101'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 2, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'BAS1202'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 2, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'ENG1202'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 2, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'MAT1203'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 2, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'MAT1204'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 2, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'CS1202'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 2, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'PE1201'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 3, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'BAS2103'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 3, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'CS2103'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 3, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'CS2104'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 3, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'CS2105'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 3, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'ENG2103'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 3, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'PE2102'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 4, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'BAS2204'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 4, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'CS2206'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 4, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE2201'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 4, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'NET2201'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 4, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE2202'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 4, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE2203'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 5, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'BAS3105'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 5, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3104'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 5, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3105'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 5, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3106'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 5, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3107'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 5, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3108'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 6, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3209'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 6, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3210'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 6, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3211'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 6, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3212'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 6, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3213'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 6, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE3214'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 7, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE4115'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 7, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE4116'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 7, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE4117'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 7, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE4118'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 7, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'SE4119'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 8, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'INT4900'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT prog_rec.id, c.id, 8, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code = 'PRJ4950'
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;
    END LOOP;

    -- Semester 8 is common for ALL programs across the university
    FOR p_all IN SELECT id FROM academic_programs LOOP
        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)
        SELECT p_all.id, c.id, 8, TRUE, CURRENT_TIMESTAMP, 0
        FROM courses c WHERE c.code IN ('INT4900', 'PRJ4950')
        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = 8;
    END LOOP;
END $$;

-- 7. Course Assigned Teachers
INSERT INTO course_teachers (course_id, teacher_id)
SELECT c.id, t.id
FROM courses c
CROSS JOIN LATERAL (
    SELECT id FROM teachers ORDER BY (c.id + id) % 17 LIMIT 2
) t
ON CONFLICT DO NOTHING;

-- 8. Update Class Schedules with multi-week info & buildings
UPDATE class_schedules cs
SET start_week = 1,
    end_week = 15,
    building = CASE (cs.id % 4)
        WHEN 0 THEN 'Tòa nhà A1'
        WHEN 1 THEN 'Tòa nhà SICT'
        WHEN 2 THEN 'Tòa nhà B'
        ELSE 'Tòa nhà Công nghệ'
    END,
    campus = CASE WHEN (cs.id % 2 = 0) THEN 'Cơ sở 1 (Khu A)' ELSE 'Cơ sở 2 (Khu B)' END,
    end_period = start_period + c.credits - 1
FROM class_sections sec
JOIN courses c ON sec.course_id = c.id
WHERE cs.class_section_id = sec.id;

-- 9. Ensure full class grades for class sections
DO $$
DECLARE
    sec_rec RECORD;
    stu_rec RECORD;
    e_id BIGINT;
    att NUMERIC(4,2);
    mid NUMERIC(4,2);
    fin NUMERIC(4,2);
    tot NUMERIC(4,2);
    gpa NUMERIC(4,2);
    let VARCHAR(5);
BEGIN
    -- For all sections that have enrollments, ensure 20-30 students are enrolled and graded
    FOR sec_rec IN SELECT DISTINCT class_section_id FROM enrollments LIMIT 10 LOOP
        FOR stu_rec IN SELECT id FROM students WHERE id NOT IN (SELECT student_id FROM enrollments WHERE class_section_id = sec_rec.class_section_id) LIMIT 25 LOOP
            INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, version)
            VALUES (stu_rec.id, sec_rec.class_section_id, CURRENT_TIMESTAMP, 'ENROLLED', 0)
            RETURNING id INTO e_id;
            
            att := (80 + (e_id * 7 % 21))::numeric / 10.0; -- 8.0 to 10.0
            mid := (60 + (e_id * 13 % 38))::numeric / 10.0; -- 6.0 to 9.7
            fin := (55 + (e_id * 17 % 43))::numeric / 10.0; -- 5.5 to 9.7
            tot := ROUND(att * 0.10 + mid * 0.30 + fin * 0.60, 2);
            
            IF tot >= 8.5 THEN let := 'A'; gpa := 4.0;
            ELSIF tot >= 8.0 THEN let := 'B+'; gpa := 3.5;
            ELSIF tot >= 7.0 THEN let := 'B'; gpa := 3.0;
            ELSIF tot >= 6.5 THEN let := 'C+'; gpa := 2.5;
            ELSIF tot >= 5.5 THEN let := 'C'; gpa := 2.0;
            ELSIF tot >= 5.0 THEN let := 'D+'; gpa := 1.5;
            ELSIF tot >= 4.0 THEN let := 'D'; gpa := 1.0;
            ELSE let := 'F'; gpa := 0.0;
            END IF;
            
            INSERT INTO grades (enrollment_id, attendance_score, midterm_score, final_score, total_score_10, gpa_score_4, letter_grade, is_locked, version)
            VALUES (e_id, att, mid, fin, tot, gpa, let, TRUE, 0)
            ON CONFLICT (enrollment_id) DO NOTHING;
        END LOOP;
    END LOOP;
END $$;
