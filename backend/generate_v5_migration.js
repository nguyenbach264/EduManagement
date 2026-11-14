const fs = require('fs');
const path = require('path');

const PROVINCES = [
  "Thành phố Hà Nội",
  "Thành phố Hồ Chí Minh",
  "Thành phố Hải Phòng",
  "Thành phố Đà Nẵng",
  "Thành phố Cần Thơ",
  "Tỉnh Hà Nam Ninh",
  "Tỉnh Hải Hưng",
  "Tỉnh Bắc Thái",
  "Tỉnh Hà Bắc",
  "Tỉnh Vĩnh Phú",
  "Tỉnh Hà Giang - Tuyên Quang",
  "Tỉnh Cao Lạng",
  "Tỉnh Lào Cai - Yên Bái",
  "Tỉnh Lai Châu - Điện Biên",
  "Tỉnh Sơn La",
  "Tỉnh Hòa Bình",
  "Tỉnh Quảng Ninh",
  "Tỉnh Thanh Hóa",
  "Tỉnh Nghệ Tĩnh",
  "Tỉnh Bình Trị Thiên",
  "Tỉnh Quảng Nam - Quảng Ngãi",
  "Tỉnh Nghĩa Bình",
  "Tỉnh Khánh Hòa - Ninh Thuận",
  "Tỉnh Bình Thuận - Lâm Đồng",
  "Tỉnh Gia Lai - Kon Tum",
  "Tỉnh Đắk Lắk - Đắk Nông",
  "Tỉnh Sông Bé",
  "Tỉnh Đồng Nai",
  "Tỉnh Tây Ninh",
  "Tỉnh Bà Rịa - Vũng Tàu",
  "Tỉnh Long An - Tiền Giang",
  "Tỉnh Bến Tre - Trà Vinh",
  "Tỉnh Vĩnh Long - Hậu Giang - Sóc Trăng",
  "Tỉnh Cà Mau - Bạc Liêu - Kiên Giang"
];

const CLASSES = [
  "D21CNTT01", "D21CNTT02", "D21KTPM01", "D21KTPM02",
  "D22ANM01", "D22ANM02", "D22DS01", "D22AI01",
  "D23NNA01", "D23NNA02", "D21QTKD01", "D22TCNH01"
];

const TEACHER_TITLES = [
  "Tiến sĩ", "Phó Giáo sư, Tiến sĩ", "Giáo sư, Tiến sĩ", "Thạc sĩ"
];

const BUILDINGS = ["Tòa nhà A1", "Tòa nhà SICT", "Tòa nhà B", "Tòa nhà Công nghệ"];
const CAMPUSES = ["Cơ sở 1 (Khu A)", "Cơ sở 2 (Khu B)"];

// 140-credit Software Engineering (Kỹ thuật phần mềm) Curriculum - 8 Semesters
const CURRICULUM_SE = [
  // Semester 1 (18 credits)
  { code: "BAS1101", name: "Triết học Mác - Lênin", credits: 3, th: 45, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 1, prereq: [] },
  { code: "ENG1101", name: "Tiếng Anh cơ bản 1", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 1, prereq: [] },
  { code: "MAT1101", name: "Giải tích 1", credits: 3, th: 45, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 1, prereq: [] },
  { code: "MAT1102", name: "Đại số tuyến tính", credits: 3, th: 45, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 1, prereq: [] },
  { code: "CS1101", name: "Tin học đại cương", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 1, prereq: [] },
  { code: "LAW1101", name: "Pháp luật đại cương", credits: 3, th: 45, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 1, prereq: [] },

  // Semester 2 (18 credits)
  { code: "BAS1202", name: "Kinh tế chính trị Mác - Lênin", credits: 2, th: 30, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 2, prereq: ["BAS1101"] },
  { code: "ENG1202", name: "Tiếng Anh cơ bản 2", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 2, prereq: ["ENG1101"] },
  { code: "MAT1203", name: "Giải tích 2", credits: 3, th: 45, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 2, prereq: ["MAT1101"] },
  { code: "MAT1204", name: "Xác suất thống kê", credits: 3, th: 45, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 2, prereq: ["MAT1101"] },
  { code: "CS1202", name: "Nhập môn lập trình C/C++", credits: 4, th: 30, pr: 30, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 2, prereq: ["CS1101"] },
  { code: "PE1201", name: "Giáo dục thể chất 1 (Điền kinh)", credits: 3, th: 15, pr: 30, wAtt: 0.2, wMid: 0.3, wFin: 0.5, sem: 2, prereq: [] },

  // Semester 3 (18 credits)
  { code: "BAS2103", name: "Chủ nghĩa xã hội khoa học", credits: 2, th: 30, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 3, prereq: ["BAS1202"] },
  { code: "CS2103", name: "Lập trình hướng đối tượng (Java)", credits: 4, th: 30, pr: 30, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 3, prereq: ["CS1202"] },
  { code: "CS2104", name: "Cấu trúc dữ liệu và giải thuật", credits: 4, th: 30, pr: 30, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 3, prereq: ["CS1202"] },
  { code: "CS2105", name: "Kiến trúc máy tính và Hệ điều hành", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 3, prereq: [] },
  { code: "ENG2103", name: "Tiếng Anh chuyên ngành CNTT", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 3, prereq: ["ENG1202"] },
  { code: "PE2102", name: "Giáo dục thể chất 2 (Bóng chuyền)", credits: 2, th: 10, pr: 20, wAtt: 0.2, wMid: 0.3, wFin: 0.5, sem: 3, prereq: [] },

  // Semester 4 (18 credits)
  { code: "BAS2204", name: "Tư tưởng Hồ Chí Minh", credits: 2, th: 30, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 4, prereq: ["BAS2103"] },
  { code: "CS2206", name: "Cơ sở dữ liệu quan hệ (SQL & PostgreSQL)", credits: 4, th: 30, pr: 30, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 4, prereq: ["CS2104"] },
  { code: "SE2201", name: "Nhập môn Kỹ thuật phần mềm", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 4, prereq: ["CS2103"] },
  { code: "NET2201", name: "Mạng máy tính & Truyền thông", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 4, prereq: ["CS2105"] },
  { code: "SE2202", name: "Thiết kế giao diện người dùng (UI/UX)", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 4, prereq: [] },
  { code: "SE2203", name: "Lập trình Web căn bản (HTML5/CSS/JS)", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 4, prereq: ["CS2103"] },

  // Semester 5 (18 credits)
  { code: "BAS3105", name: "Lịch sử Đảng Cộng sản Việt Nam", credits: 2, th: 30, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 5, prereq: ["BAS2204"] },
  { code: "SE3104", name: "Phân tích và thiết kế hệ thống", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 5, prereq: ["CS2206"] },
  { code: "SE3105", name: "Lập trình Web nâng cao & Spring Boot", credits: 4, th: 30, pr: 30, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 5, prereq: ["SE2203"] },
  { code: "SE3106", name: "Kiến trúc phần mềm & Design Patterns", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 5, prereq: ["SE2201"] },
  { code: "SE3107", name: "Kiểm thử và đảm bảo chất lượng phần mềm", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 5, prereq: ["SE2201"] },
  { code: "SE3108", name: "Quản lý dự án phần mềm", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 5, prereq: ["SE2201"] },

  // Semester 6 (18 credits)
  { code: "SE3209", name: "Phát triển ứng dụng di động", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 6, prereq: ["CS2103"] },
  { code: "SE3210", name: "Điện toán đám mây & DevOps", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 6, prereq: ["NET2201"] },
  { code: "SE3211", name: "An toàn và bảo mật thông tin", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 6, prereq: ["NET2201"] },
  { code: "SE3212", name: "Phát triển phần mềm Agile/Scrum", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 6, prereq: ["SE3108"] },
  { code: "SE3213", name: "Dịch vụ mạng & API RESTful", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 6, prereq: ["SE3105"] },
  { code: "SE3214", name: "Trí tuệ nhân tạo ứng dụng", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 6, prereq: ["CS2104"] },

  // Semester 7 (17 credits)
  { code: "SE4115", name: "Hệ thống phân tán & Microservices", credits: 4, th: 30, pr: 30, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 7, prereq: ["SE3213"] },
  { code: "SE4116", name: "Công nghệ Dữ liệu lớn (Big Data)", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 7, prereq: ["CS2206"] },
  { code: "SE4117", name: "Chuyên đề công nghệ mới (AI/Blockchain)", credits: 3, th: 30, pr: 15, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 7, prereq: [] },
  { code: "SE4118", name: "Dự án phát triển phần mềm thực chiến (Capstone)", credits: 4, th: 15, pr: 45, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 7, prereq: ["SE3105", "SE3107"] },
  { code: "SE4119", name: "Đạo đức nghề nghiệp & Sở hữu trí tuệ", credits: 3, th: 45, pr: 0, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 7, prereq: [] },

  // Semester 8 (15 credits - CỐ ĐỊNH CHUNG TẤT CẢ CÁC NGÀNH)
  { code: "INT4900", name: "Thực tập doanh nghiệp", credits: 6, th: 0, pr: 90, wAtt: 0.2, wMid: 0.3, wFin: 0.5, sem: 8, prereq: [] },
  { code: "PRJ4950", name: "Đồ án tốt nghiệp / Khóa luận tốt nghiệp", credits: 9, th: 0, pr: 135, wAtt: 0.1, wMid: 0.3, wFin: 0.6, sem: 8, prereq: ["INT4900"] }
];

let sql = `-- V5__enhanced_features_and_curriculum.sql: 140 Credits, 8 Semesters, 34 Provinces, Multi-week Schedule, Course Details, and Class Section Grades\n\n`;

// 1. ALTER TABLES
sql += `-- 1. Schema Enhancements\n`;
sql += `ALTER TABLE students ADD COLUMN IF NOT EXISTS class_name VARCHAR(50);\n`;
sql += `ALTER TABLE students ADD COLUMN IF NOT EXISTS province VARCHAR(100);\n`;
sql += `ALTER TABLE teachers ADD COLUMN IF NOT EXISTS phone VARCHAR(30);\n`;
sql += `ALTER TABLE teachers ADD COLUMN IF NOT EXISTS email VARCHAR(100);\n`;
sql += `ALTER TABLE teachers ADD COLUMN IF NOT EXISTS academic_title VARCHAR(50);\n`;
sql += `ALTER TABLE teachers ADD COLUMN IF NOT EXISTS office_address VARCHAR(150);\n`;
sql += `ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS start_week INT NOT NULL DEFAULT 1;\n`;
sql += `ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS end_week INT NOT NULL DEFAULT 15;\n`;
sql += `ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS building VARCHAR(50);\n`;
sql += `ALTER TABLE class_schedules ADD COLUMN IF NOT EXISTS campus VARCHAR(50);\n\n`;

sql += `CREATE TABLE IF NOT EXISTS course_teachers (\n`;
sql += `    course_id BIGINT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,\n`;
sql += `    teacher_id BIGINT NOT NULL REFERENCES teachers(id) ON DELETE CASCADE,\n`;
sql += `    PRIMARY KEY (course_id, teacher_id)\n`;
sql += `);\n\n`;

// 2. Update Students with Class Name, 34 Provinces, realistic addresses
sql += `-- 2. Populate Students with Class Name and 34 Provinces\n`;
sql += `DO $$\n`;
sql += `DECLARE\n`;
sql += `    s_rec RECORD;\n`;
sql += `    i INT := 0;\n`;
sql += `    provs TEXT[] := ARRAY[\n`;
sql += PROVINCES.map(p => `        '${p}'`).join(',\n') + `\n    ];\n`;
sql += `    classes TEXT[] := ARRAY[\n`;
sql += CLASSES.map(c => `        '${c}'`).join(',\n') + `\n    ];\n`;
sql += `BEGIN\n`;
sql += `    FOR s_rec IN SELECT id FROM students ORDER BY id LOOP\n`;
sql += `        UPDATE students SET\n`;
sql += `            class_name = classes[(i % array_length(classes, 1)) + 1],\n`;
sql += `            province = provs[(i % array_length(provs, 1)) + 1],\n`;
sql += `            gender = CASE WHEN i % 3 = 0 THEN 'Nữ' ELSE 'Nam' END,\n`;
sql += `            date_of_birth = DATE '2003-01-15' + (i * 37 % 800),\n`;
sql += `            address = CONCAT('Số ', (i * 13 % 150) + 1, ', Đường Giải Phóng, ', provs[(i % array_length(provs, 1)) + 1])\n`;
sql += `        WHERE id = s_rec.id;\n`;
sql += `        i := i + 1;\n`;
sql += `    END LOOP;\n`;
sql += `END $$;\n\n`;

// 3. Update Teachers with Phone, Email, Academic Title, Office Address
sql += `-- 3. Populate Teachers with contact & titles\n`;
sql += `DO $$\n`;
sql += `DECLARE\n`;
sql += `    t_rec RECORD;\n`;
sql += `    i INT := 0;\n`;
sql += `    titles TEXT[] := ARRAY['Tiến sĩ', 'Phó Giáo sư, Tiến sĩ', 'Giáo sư, Tiến sĩ', 'Thạc sĩ'];\n`;
sql += `BEGIN\n`;
sql += `    FOR t_rec IN SELECT t.id, u.username FROM teachers t JOIN users u ON t.user_id = u.id ORDER BY t.id LOOP\n`;
sql += `        UPDATE teachers SET\n`;
sql += `            academic_title = titles[(i % 4) + 1],\n`;
sql += `            phone = CONCAT('09', LPAD(((i * 1234567) % 90000000 + 10000000)::text, 8, '0')),\n`;
sql += `            email = CONCAT(t_rec.username, '@daihoc.edu.vn'),\n`;
sql += `            office_address = CONCAT('Phòng ', (i % 6 + 1) * 100 + (i % 8 + 1), ', Tòa nhà A1, Cơ sở 1')\n`;
sql += `        WHERE id = t_rec.id;\n`;
sql += `        i := i + 1;\n`;
sql += `    END LOOP;\n`;
sql += `END $$;\n\n`;

// 4. Insert full 140 credits curriculum courses
sql += `-- 4. Insert 140 Credits Curriculum Courses\n`;
for (const c of CURRICULUM_SE) {
  sql += `INSERT INTO courses (code, name, credits, theory_hours, practice_hours, attendance_weight, midterm_weight, final_weight, department_id, created_at, version)\n`;
  sql += `SELECT '${c.code}', '${c.name}', ${c.credits}, ${c.th}, ${c.pr}, ${c.wAtt}, ${c.wMid}, ${c.wFin}, id, CURRENT_TIMESTAMP, 0\n`;
  sql += `FROM departments WHERE code = 'FIT' OR id = 1 LIMIT 1\n`;
  sql += `ON CONFLICT (code) DO UPDATE SET\n`;
  sql += `    name = EXCLUDED.name, credits = EXCLUDED.credits, theory_hours = EXCLUDED.theory_hours, practice_hours = EXCLUDED.practice_hours,\n`;
  sql += `    attendance_weight = EXCLUDED.attendance_weight, midterm_weight = EXCLUDED.midterm_weight, final_weight = EXCLUDED.final_weight;\n\n`;
}

// 5. Link Prerequisites
sql += `-- 5. Course Prerequisites\n`;
for (const c of CURRICULUM_SE) {
  if (c.prereq && c.prereq.length > 0) {
    for (const p of c.prereq) {
      sql += `INSERT INTO course_prerequisites (course_id, prerequisite_id)\n`;
      sql += `SELECT c.id, p.id FROM courses c, courses p WHERE c.code = '${c.code}' AND p.code = '${p}'\n`;
      sql += `ON CONFLICT DO NOTHING;\n`;
    }
  }
}
sql += `\n`;

// 6. Link Program Courses for programs (Total 140 credits each, Semester 8 common)
sql += `-- 6. Link Program Courses (140 credits across 8 semesters)\n`;
sql += `UPDATE academic_programs SET total_credits = 140 WHERE id IN (1, 2, 3, 4, 5, 6);\n`;
sql += `DELETE FROM program_courses WHERE program_id IN (1, 2, 3, 4, 5, 6);\n\n`;
sql += `DO $$\n`;
sql += `DECLARE\n`;
sql += `    prog_rec RECORD;\n`;
sql += `    p_all RECORD;\n`;
sql += `BEGIN\n`;
sql += `    FOR prog_rec IN SELECT id FROM academic_programs WHERE id IN (1, 2, 3, 4, 5, 6) LOOP\n`;
for (const c of CURRICULUM_SE) {
  sql += `        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)\n`;
  sql += `        SELECT prog_rec.id, c.id, ${c.sem}, TRUE, CURRENT_TIMESTAMP, 0\n`;
  sql += `        FROM courses c WHERE c.code = '${c.code}'\n`;
  sql += `        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = EXCLUDED.semester_index;\n`;
}
sql += `    END LOOP;\n\n`;
sql += `    -- Semester 8 is common for ALL programs across the university\n`;
sql += `    FOR p_all IN SELECT id FROM academic_programs LOOP\n`;
sql += `        INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory, created_at, version)\n`;
sql += `        SELECT p_all.id, c.id, 8, TRUE, CURRENT_TIMESTAMP, 0\n`;
sql += `        FROM courses c WHERE c.code IN ('INT4900', 'PRJ4950')\n`;
sql += `        ON CONFLICT (program_id, course_id) DO UPDATE SET semester_index = 8;\n`;
sql += `    END LOOP;\n`;
sql += `END $$;\n\n`;

// 7. Link Assigned Teachers to Courses
sql += `-- 7. Course Assigned Teachers\n`;
sql += `INSERT INTO course_teachers (course_id, teacher_id)\n`;
sql += `SELECT c.id, t.id\n`;
sql += `FROM courses c\n`;
sql += `CROSS JOIN LATERAL (\n`;
sql += `    SELECT id FROM teachers ORDER BY (c.id + id) % 17 LIMIT 2\n`;
sql += `) t\n`;
sql += `ON CONFLICT DO NOTHING;\n\n`;

// 8. Update Class Schedules with multi-week formula:
// 2 TC -> 2 periods, 3 TC -> 3 periods, 4 TC -> 4 periods, 5 TC -> 5 periods
// start_week = 1, end_week = 15, building, campus
sql += `-- 8. Update Class Schedules with multi-week info & buildings\n`;
sql += `UPDATE class_schedules cs\n`;
sql += `SET start_week = 1,\n`;
sql += `    end_week = 15,\n`;
sql += `    building = CASE (cs.id % 4)\n`;
sql += `        WHEN 0 THEN 'Tòa nhà A1'\n`;
sql += `        WHEN 1 THEN 'Tòa nhà SICT'\n`;
sql += `        WHEN 2 THEN 'Tòa nhà B'\n`;
sql += `        ELSE 'Tòa nhà Công nghệ'\n`;
sql += `    END,\n`;
sql += `    campus = CASE WHEN (cs.id % 2 = 0) THEN 'Cơ sở 1 (Khu A)' ELSE 'Cơ sở 2 (Khu B)' END,\n`;
sql += `    end_period = start_period + c.credits - 1\n`;
sql += `FROM class_sections sec\n`;
sql += `JOIN courses c ON sec.course_id = c.id\n`;
sql += `WHERE cs.class_section_id = sec.id;\n\n`;

// 9. Ensure complete class grades for student1's enrolled sections
sql += `-- 9. Ensure full class grades for class sections\n`;
sql += `DO $$\n`;
sql += `DECLARE\n`;
sql += `    sec_rec RECORD;\n`;
sql += `    stu_rec RECORD;\n`;
sql += `    e_id BIGINT;\n`;
sql += `    att NUMERIC(4,2);\n`;
sql += `    mid NUMERIC(4,2);\n`;
sql += `    fin NUMERIC(4,2);\n`;
sql += `    tot NUMERIC(4,2);\n`;
sql += `    gpa NUMERIC(4,2);\n`;
sql += `    let VARCHAR(5);\n`;
sql += `BEGIN\n`;
sql += `    -- For all sections that have enrollments, ensure 20-30 students are enrolled and graded\n`;
sql += `    FOR sec_rec IN SELECT DISTINCT class_section_id FROM enrollments LIMIT 10 LOOP\n`;
sql += `        FOR stu_rec IN SELECT id FROM students WHERE id NOT IN (SELECT student_id FROM enrollments WHERE class_section_id = sec_rec.class_section_id) LIMIT 25 LOOP\n`;
sql += `            INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, version)\n`;
sql += `            VALUES (stu_rec.id, sec_rec.class_section_id, CURRENT_TIMESTAMP, 'ENROLLED', 0)\n`;
sql += `            RETURNING id INTO e_id;\n`;
sql += `            \n`;
sql += `            att := (80 + (e_id * 7 % 21))::numeric / 10.0; -- 8.0 to 10.0\n`;
sql += `            mid := (60 + (e_id * 13 % 38))::numeric / 10.0; -- 6.0 to 9.7\n`;
sql += `            fin := (55 + (e_id * 17 % 43))::numeric / 10.0; -- 5.5 to 9.7\n`;
sql += `            tot := ROUND(att * 0.10 + mid * 0.30 + fin * 0.60, 2);\n`;
sql += `            \n`;
sql += `            IF tot >= 8.5 THEN let := 'A'; gpa := 4.0;\n`;
sql += `            ELSIF tot >= 8.0 THEN let := 'B+'; gpa := 3.5;\n`;
sql += `            ELSIF tot >= 7.0 THEN let := 'B'; gpa := 3.0;\n`;
sql += `            ELSIF tot >= 6.5 THEN let := 'C+'; gpa := 2.5;\n`;
sql += `            ELSIF tot >= 5.5 THEN let := 'C'; gpa := 2.0;\n`;
sql += `            ELSIF tot >= 5.0 THEN let := 'D+'; gpa := 1.5;\n`;
sql += `            ELSIF tot >= 4.0 THEN let := 'D'; gpa := 1.0;\n`;
sql += `            ELSE let := 'F'; gpa := 0.0;\n`;
sql += `            END IF;\n`;
sql += `            \n`;
sql += `            INSERT INTO grades (enrollment_id, attendance_score, midterm_score, final_score, total_score_10, gpa_score_4, letter_grade, is_locked, version)\n`;
sql += `            VALUES (e_id, att, mid, fin, tot, gpa, let, TRUE, 0)\n`;
sql += `            ON CONFLICT (enrollment_id) DO NOTHING;\n`;
sql += `        END LOOP;\n`;
sql += `    END LOOP;\n`;
sql += `END $$;\n`;

const targetPath = path.join(__dirname, 'src', 'main', 'resources', 'db', 'migration', 'V5__enhanced_features_and_curriculum.sql');
fs.writeFileSync(targetPath, sql, 'utf8');
console.log('Successfully generated:', targetPath);
