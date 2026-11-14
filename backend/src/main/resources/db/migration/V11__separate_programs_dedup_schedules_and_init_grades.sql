-- ==============================================================================
-- V11: SEPARATE PROGRAMS, DEDUPLICATE SCHEDULES, INIT ALL GRADES
-- 1. Align academic_programs to match departments 1..15
-- 2. Deduplicate class_schedules and add unique constraint
-- 3. Initialize Grade records for ALL enrollments across the entire database
-- 4. Populate complete grades for section 188 (LP6013009003) & all finished sections
-- 5. Map shared general education courses into all programs
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ALIGN ACADEMIC PROGRAMS & STUDENTS
-- ------------------------------------------------------------------------------
UPDATE academic_programs SET name = 'Công nghệ Thông tin', code = '7480201', department_id = 1, total_credits = 140 WHERE id = 1;
UPDATE academic_programs SET name = 'Kỹ thuật Điện tử - Viễn thông', code = '7510302', department_id = 2, total_credits = 140 WHERE id = 2;
UPDATE academic_programs SET name = 'Công nghệ Kỹ thuật Cơ khí', code = '7510201', department_id = 3, total_credits = 140 WHERE id = 3;
UPDATE academic_programs SET name = 'Công nghệ Kỹ thuật Ô tô', code = '7510205', department_id = 4, total_credits = 140 WHERE id = 4;
UPDATE academic_programs SET name = 'Kinh tế & Tài chính Doanh nghiệp', code = '7310101', department_id = 5, total_credits = 130 WHERE id = 5;
UPDATE academic_programs SET name = 'Kế toán & Kiểm toán Doanh nghiệp', code = '7340301', department_id = 6, total_credits = 130 WHERE id = 6;
UPDATE academic_programs SET name = 'Ngôn ngữ Anh Thương mại', code = '7220201', department_id = 7, total_credits = 130 WHERE id = 7;
UPDATE academic_programs SET name = 'Công nghệ Kỹ thuật Hóa học', code = '7510401', department_id = 8, total_credits = 140 WHERE id = 8;
UPDATE academic_programs SET name = 'Công nghệ May & Thiết kế Thời trang', code = '7540204', department_id = 9, total_credits = 140 WHERE id = 9;
UPDATE academic_programs SET name = 'Quản trị Kinh doanh & Chuỗi cung ứng', code = '7340101', department_id = 10, total_credits = 130 WHERE id = 10;
UPDATE academic_programs SET name = 'Kỹ thuật Robot & Tự động hóa', code = '7510209', department_id = 11, total_credits = 140 WHERE id = 11;
UPDATE academic_programs SET name = 'Công nghệ Thực phẩm & Đảm bảo ATTP', code = '7540101', department_id = 15, total_credits = 140 WHERE id = 15;

-- Assign every student to their department's official primary academic program
UPDATE students SET program_id = department_id WHERE department_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15);

-- Map shared general education courses into all programs (Semesters 1-3)
INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory)
SELECT p.id, c.id, 1, true
FROM academic_programs p
CROSS JOIN courses c
WHERE p.id IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15)
  AND c.code IN ('BAS1101', 'ENG1101', 'MAT1101', 'LAW1101')
ON CONFLICT (program_id, course_id) DO NOTHING;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory)
SELECT p.id, c.id, 2, true
FROM academic_programs p
CROSS JOIN courses c
WHERE p.id IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15)
  AND c.code IN ('BAS1202', 'ENG1202', 'MAT1204', 'PE1201')
ON CONFLICT (program_id, course_id) DO NOTHING;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory)
SELECT p.id, c.id, 3, true
FROM academic_programs p
CROSS JOIN courses c
WHERE p.id IN (2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 15)
  AND c.code IN ('BAS2103', 'BAS2204', 'BAS3105', 'PE2102')
ON CONFLICT (program_id, course_id) DO NOTHING;


-- ------------------------------------------------------------------------------
-- 2. DEDUPLICATE CLASS SCHEDULES & ADD CONSTRAINT
-- ------------------------------------------------------------------------------
DELETE FROM class_schedules a USING class_schedules b
WHERE a.id > b.id
  AND a.class_section_id = b.class_section_id
  AND a.day_of_week = b.day_of_week
  AND a.start_period = b.start_period
  AND a.end_period = b.end_period;

-- Clean room strings that start with repeated "Phòng Phòng"
UPDATE class_schedules
SET room = REGEXP_REPLACE(room, '^Phòng\s+', '')
WHERE room LIKE 'Phòng Phòng%';

ALTER TABLE class_schedules DROP CONSTRAINT IF EXISTS uq_class_schedules_slot;
ALTER TABLE class_schedules ADD CONSTRAINT uq_class_schedules_slot UNIQUE (class_section_id, day_of_week, start_period, end_period);


-- ------------------------------------------------------------------------------
-- 3. INITIALIZE GRADE RECORDS FOR ALL ENROLLMENTS IN DATABASE
-- ------------------------------------------------------------------------------
INSERT INTO grades (enrollment_id, is_locked, created_at, version)
SELECT e.id, false, NOW(), 0
FROM enrollments e
WHERE NOT EXISTS (SELECT 1 FROM grades g WHERE g.enrollment_id = e.id)
ON CONFLICT (enrollment_id) DO NOTHING;


-- ------------------------------------------------------------------------------
-- 4. POPULATE COMPLETE GRADES & STATISTICS FOR SECTION 188 & ALL FINISHED CLASSES
-- ------------------------------------------------------------------------------
-- Specifically for section 188 (LP6013009003) and other sections taught by teacher1 or finished
UPDATE grades g
SET regular_score_1 = ROUND((7.0 + (MOD(g.enrollment_id * 7, 26) / 10.0))::numeric, 1),
    regular_score_2 = ROUND((7.0 + (MOD(g.enrollment_id * 11, 26) / 10.0))::numeric, 1),
    midterm_score = CASE WHEN c.credits >= 4 THEN ROUND((6.5 + (MOD(g.enrollment_id * 13, 31) / 10.0))::numeric, 1) ELSE NULL END,
    final_score = ROUND((6.5 + (MOD(g.enrollment_id * 17, 34) / 10.0))::numeric, 1),
    is_locked = true
FROM enrollments e
JOIN class_sections cs ON e.class_section_id = cs.id
JOIN courses c ON cs.course_id = c.id
WHERE g.enrollment_id = e.id
  AND (
      cs.id = 188
      OR cs.status = 'CLOSED'
      OR cs.semester_id < 50
      OR EXISTS (
          SELECT 1 FROM class_schedules sch
          WHERE sch.class_section_id = cs.id
          GROUP BY sch.class_section_id
          HAVING MAX(sch.end_week) < 11
      )
  )
  AND g.total_score_10 IS NULL;

-- Compute total_score_10, letter_grade, gpa_score_4
UPDATE grades g
SET total_score_10 = sub.total,
    gpa_score_4 = sub.gpa,
    letter_grade = sub.letter
FROM (
    SELECT g2.id AS gid,
           calc.total,
           CASE
               WHEN calc.total >= 9.0 THEN 4.0
               WHEN calc.total >= 8.5 THEN 3.7
               WHEN calc.total >= 8.0 THEN 3.5
               WHEN calc.total >= 7.0 THEN 3.0
               WHEN calc.total >= 6.5 THEN 2.5
               WHEN calc.total >= 5.5 THEN 2.0
               WHEN calc.total >= 5.0 THEN 1.5
               WHEN calc.total >= 4.0 THEN 1.0
               ELSE 0.0
           END AS gpa,
           CASE
               WHEN calc.total >= 9.0 THEN 'A+'
               WHEN calc.total >= 8.5 THEN 'A'
               WHEN calc.total >= 8.0 THEN 'B+'
               WHEN calc.total >= 7.0 THEN 'B'
               WHEN calc.total >= 6.5 THEN 'C+'
               WHEN calc.total >= 5.5 THEN 'C'
               WHEN calc.total >= 5.0 THEN 'D+'
               WHEN calc.total >= 4.0 THEN 'D'
               ELSE 'F'
           END AS letter
    FROM grades g2
    JOIN enrollments e ON g2.enrollment_id = e.id
    JOIN class_sections cs ON e.class_section_id = cs.id
    JOIN courses c ON cs.course_id = c.id
    CROSS JOIN LATERAL (
        SELECT CASE
            WHEN c.credits >= 4 THEN
                ROUND((((g2.regular_score_1 + g2.regular_score_2) / 2.0) * 0.2 + g2.midterm_score * 0.3 + g2.final_score * 0.5)::numeric, 1)
            ELSE
                ROUND((((g2.regular_score_1 + g2.regular_score_2) / 2.0) * 0.4 + g2.final_score * 0.6)::numeric, 1)
        END AS total
    ) calc
    WHERE g2.total_score_10 IS NULL
      AND g2.final_score IS NOT NULL
) sub
WHERE g.id = sub.gid;
