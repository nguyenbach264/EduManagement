-- ==============================================================================
-- V10: CLEANUP PROGRAMS, PRUNE CAPACITY, ADD DEPT COURSES & FIX SEMESTERS
-- 1. Enforce class section capacity limits (prune excess enrollments, add CHECK)
-- 2. Populate complete grades & statistics for finished courses
-- 3. Delete mock academic programs 16 to 55
-- 4. Add comprehensive courses for all departments (2, 3, 4, 5, 6, 7, 8, 9, 10, 15)
-- 5. Standardize semester sequence: Học kỳ 1, 2, Xuân, 3, 4, Hè
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. CAPACITY LIMIT ENFORCEMENT & PRUNING EXCESS ENROLLMENTS
-- ------------------------------------------------------------------------------
-- Set section 19 max capacity to realistic 60 (was mistakenly 2)
UPDATE class_sections SET max_capacity = 60 WHERE id = 19;

-- Delete grades for excess enrollments where row_number > max_capacity
DELETE FROM grades WHERE enrollment_id IN (
    SELECT ranked.id FROM (
        SELECT e.id,
               ROW_NUMBER() OVER (PARTITION BY e.class_section_id ORDER BY e.id ASC) AS rn,
               cs.max_capacity
        FROM enrollments e
        JOIN class_sections cs ON e.class_section_id = cs.id
        WHERE e.student_id <> 1 -- Never delete test student 1
    ) ranked
    WHERE ranked.rn > ranked.max_capacity
);

-- Delete excess enrollments where row_number > max_capacity
DELETE FROM enrollments WHERE id IN (
    SELECT ranked.id FROM (
        SELECT e.id,
               ROW_NUMBER() OVER (PARTITION BY e.class_section_id ORDER BY e.id ASC) AS rn,
               cs.max_capacity
        FROM enrollments e
        JOIN class_sections cs ON e.class_section_id = cs.id
        WHERE e.student_id <> 1 -- Never delete test student 1
    ) ranked
    WHERE ranked.rn > ranked.max_capacity
);

-- Sync current_enrolled count for all sections
UPDATE class_sections cs
SET current_enrolled = (
    SELECT COUNT(*) FROM enrollments WHERE class_section_id = cs.id
);

-- Add check constraint so capacity can never be exceeded at DB level
ALTER TABLE class_sections DROP CONSTRAINT IF EXISTS chk_class_sections_capacity;
ALTER TABLE class_sections ADD CONSTRAINT chk_class_sections_capacity CHECK (current_enrolled <= max_capacity);


-- ------------------------------------------------------------------------------
-- 2. COMPLETE GRADES & STATISTICS FOR FINISHED COURSES
-- ------------------------------------------------------------------------------
-- Ensure every enrollment in finished courses has a Grade record
INSERT INTO grades (enrollment_id, is_locked, created_at, version)
SELECT e.id, true, NOW(), 0
FROM enrollments e
JOIN class_sections cs ON e.class_section_id = cs.id
WHERE (
    cs.status = 'CLOSED'
    OR cs.semester_id < 50
    OR EXISTS (
        SELECT 1 FROM class_schedules sch
        WHERE sch.class_section_id = cs.id
        GROUP BY sch.class_section_id
        HAVING MAX(sch.end_week) < 11
    )
)
AND NOT EXISTS (SELECT 1 FROM grades g WHERE g.enrollment_id = e.id)
ON CONFLICT (enrollment_id) DO NOTHING;

-- Populate realistic scores for any finished courses where total_score_10 is missing
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
      cs.status = 'CLOSED'
      OR cs.semester_id < 50
      OR EXISTS (
          SELECT 1 FROM class_schedules sch
          WHERE sch.class_section_id = cs.id
          GROUP BY sch.class_section_id
          HAVING MAX(sch.end_week) < 11
      )
  )
  AND g.total_score_10 IS NULL;

-- Compute total_score_10, letter_grade, gpa_score_4 for those newly graded records
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

-- Clean up empty closed dummy sections from early migrations (sections 113 to 120)
DELETE FROM class_schedules WHERE class_section_id BETWEEN 113 AND 120;
DELETE FROM class_sections WHERE id BETWEEN 113 AND 120 AND current_enrolled = 0;


-- ------------------------------------------------------------------------------
-- 3. DELETE MOCK ACADEMIC PROGRAMS 16 TO 55
-- ------------------------------------------------------------------------------
-- Reassign students in mock programs to their genuine department primary program (1..15)
UPDATE students
SET program_id = department_id
WHERE program_id BETWEEN 16 AND 55;

-- Remove program courses linked to mock programs 16..55
DELETE FROM program_courses WHERE program_id BETWEEN 16 AND 55;

-- Delete mock academic programs 16..55
DELETE FROM academic_programs WHERE id BETWEEN 16 AND 55;


-- ------------------------------------------------------------------------------
-- 4. CONSTRUCT COURSES FOR ALL DEPARTMENTS
-- ------------------------------------------------------------------------------
INSERT INTO courses (id, code, name, credits, theory_hours, practice_hours,
                     attendance_weight, midterm_weight, final_weight, department_id, created_at, version)
VALUES
-- Khoa Điện tử (FEE, department 2)
(301, 'EE1101', 'Mạch điện và linh kiện điện tử', 3, 30, 30, 0.40, 0.00, 0.60, 2, NOW(), 0),
(302, 'EE1202', 'Kỹ thuật điện tử số', 3, 30, 30, 0.40, 0.00, 0.60, 2, NOW(), 0),
(303, 'EE2103', 'Vi điều khiển & Hệ thống nhúng', 4, 45, 30, 0.20, 0.30, 0.50, 2, NOW(), 0),
(304, 'EE2204', 'Xử lý tín hiệu số (DSP)', 3, 30, 30, 0.40, 0.00, 0.60, 2, NOW(), 0),
(305, 'EE3105', 'Hệ thống thông tin quang', 3, 45, 0, 0.40, 0.00, 0.60, 2, NOW(), 0),
(306, 'EE3206', 'Trường điện từ và Anten', 3, 45, 0, 0.40, 0.00, 0.60, 2, NOW(), 0),
(307, 'EE4107', 'Thiết kế vi mạch tích hợp (VLSI)', 4, 45, 30, 0.20, 0.30, 0.50, 2, NOW(), 0),
(308, 'EE4208', 'Kỹ thuật cảm biến và Đo lường thông minh', 3, 30, 30, 0.40, 0.00, 0.60, 2, NOW(), 0),

-- Khoa Cơ khí (department 3)
(311, 'ME1101', 'Hình họa & Vẽ kỹ thuật cơ khí', 3, 30, 30, 0.40, 0.00, 0.60, 3, NOW(), 0),
(312, 'ME1202', 'Sức bền vật liệu và Cơ học kết cấu', 4, 45, 30, 0.20, 0.30, 0.50, 3, NOW(), 0),
(313, 'ME2103', 'Nguyên lý máy và Chi tiết máy', 4, 45, 30, 0.20, 0.30, 0.50, 3, NOW(), 0),
(314, 'ME2204', 'Công nghệ chế tạo máy', 4, 45, 30, 0.20, 0.30, 0.50, 3, NOW(), 0),
(315, 'ME3105', 'Thiết kế & Mô phỏng CAD/CAM/CNC', 3, 30, 30, 0.40, 0.00, 0.60, 3, NOW(), 0),
(316, 'ME3206', 'Dung sai lắp ghép & Đo lường kỹ thuật', 3, 45, 0, 0.40, 0.00, 0.60, 3, NOW(), 0),
(317, 'ME4107', 'Công nghệ hàn và Biến dạng kim loại', 3, 30, 30, 0.40, 0.00, 0.60, 3, NOW(), 0),
(318, 'ME4208', 'Tự động hóa quá trình sản xuất cơ khí', 3, 30, 30, 0.40, 0.00, 0.60, 3, NOW(), 0),

-- Khoa Công nghệ Ô tô (department 4)
(321, 'AU1101', 'Nguyên lý động cơ đốt trong', 4, 45, 30, 0.20, 0.30, 0.50, 4, NOW(), 0),
(322, 'AU1202', 'Kết cấu và tính toán khung gầm ô tô', 4, 45, 30, 0.20, 0.30, 0.50, 4, NOW(), 0),
(323, 'AU2103', 'Hệ thống điện & Điện tử ô tô', 4, 45, 30, 0.20, 0.30, 0.50, 4, NOW(), 0),
(324, 'AU2204', 'Lý thuyết chuyển động & Khí động học ô tô', 3, 45, 0, 0.40, 0.00, 0.60, 4, NOW(), 0),
(325, 'AU3105', 'Chẩn đoán kỹ thuật ô tô hiện đại', 3, 30, 30, 0.40, 0.00, 0.60, 4, NOW(), 0),
(326, 'AU3206', 'Công nghệ kiểm định & Bảo dưỡng ô tô', 3, 30, 30, 0.40, 0.00, 0.60, 4, NOW(), 0),
(327, 'AU4107', 'Công nghệ xe điện và Hybrid thông minh', 3, 30, 30, 0.40, 0.00, 0.60, 4, NOW(), 0),
(328, 'AU4208', 'Hệ thống an toàn chủ động ô tô (ADAS)', 3, 45, 0, 0.40, 0.00, 0.60, 4, NOW(), 0),

-- Khoa Kinh tế (department 5)
(331, 'EC1101', 'Kinh tế vi mô nâng cao', 3, 45, 0, 0.40, 0.00, 0.60, 5, NOW(), 0),
(332, 'EC1202', 'Kinh tế vĩ mô nâng cao', 3, 45, 0, 0.40, 0.00, 0.60, 5, NOW(), 0),
(333, 'EC2103', 'Kinh tế phát triển và Hội nhập', 3, 45, 0, 0.40, 0.00, 0.60, 5, NOW(), 0),
(334, 'EC2204', 'Kinh tế quốc tế & Thương mại tự do', 3, 45, 0, 0.40, 0.00, 0.60, 5, NOW(), 0),
(335, 'EC3105', 'Quản trị tài chính doanh nghiệp', 3, 45, 0, 0.40, 0.00, 0.60, 5, NOW(), 0),
(336, 'EC3206', 'Kinh tế lượng ứng dụng (R/Stata)', 3, 30, 30, 0.40, 0.00, 0.60, 5, NOW(), 0),
(337, 'EC4107', 'Lập và Thẩm định dự án đầu tư', 3, 45, 0, 0.40, 0.00, 0.60, 5, NOW(), 0),
(338, 'EC4208', 'Kinh tế công cộng và Chính sách thuế', 3, 45, 0, 0.40, 0.00, 0.60, 5, NOW(), 0),

-- Khoa Kế toán - Kiểm toán (department 6)
(341, 'AC1101', 'Nguyên lý kế toán đại cương', 3, 45, 0, 0.40, 0.00, 0.60, 6, NOW(), 0),
(342, 'AC1202', 'Kế toán tài chính doanh nghiệp 1', 4, 45, 30, 0.20, 0.30, 0.50, 6, NOW(), 0),
(343, 'AC2103', 'Kế toán tài chính doanh nghiệp 2', 4, 45, 30, 0.20, 0.30, 0.50, 6, NOW(), 0),
(344, 'AC2204', 'Kế toán chi phí & Quản trị doanh nghiệp', 3, 45, 0, 0.40, 0.00, 0.60, 6, NOW(), 0),
(345, 'AC3105', 'Kiểm toán căn bản và Thực hành', 3, 30, 30, 0.40, 0.00, 0.60, 6, NOW(), 0),
(346, 'AC3206', 'Kế toán thuế & Khai báo hải quan', 3, 30, 30, 0.40, 0.00, 0.60, 6, NOW(), 0),
(347, 'AC4107', 'Hệ thống thông tin kế toán (ERP/MISA)', 3, 30, 30, 0.40, 0.00, 0.60, 6, NOW(), 0),
(348, 'AC4208', 'Phân tích báo cáo tài chính chuyên sâu', 3, 45, 0, 0.40, 0.00, 0.60, 6, NOW(), 0),

-- Khoa Ngoại ngữ (department 7)
(351, 'EN1101', 'Ngữ âm và Âm vị học tiếng Anh', 3, 30, 30, 0.40, 0.00, 0.60, 7, NOW(), 0),
(352, 'EN1202', 'Cú pháp và Ngữ pháp học ứng dụng', 3, 45, 0, 0.40, 0.00, 0.60, 7, NOW(), 0),
(353, 'EN2103', 'Kỹ năng Biên dịch tiếng Anh thương mại', 3, 30, 30, 0.40, 0.00, 0.60, 7, NOW(), 0),
(354, 'EN2204', 'Kỹ năng Phiên dịch tiếng Anh thực hành', 3, 30, 30, 0.40, 0.00, 0.60, 7, NOW(), 0),
(355, 'EN3105', 'Tiếng Anh giao tiếp trong kinh doanh quốc tế', 3, 30, 30, 0.40, 0.00, 0.60, 7, NOW(), 0),
(356, 'EN3206', 'Văn minh và Đất nước học Anh - Mỹ', 3, 45, 0, 0.40, 0.00, 0.60, 7, NOW(), 0),
(357, 'EN4107', 'Phương pháp giảng dạy tiếng Anh (TESOL)', 3, 30, 30, 0.40, 0.00, 0.60, 7, NOW(), 0),
(358, 'EN4208', 'Giao tiếp liên văn hóa toàn cầu', 3, 45, 0, 0.40, 0.00, 0.60, 7, NOW(), 0),

-- Khoa Công nghệ Hóa học (department 8)
(361, 'CH1101', 'Hóa học vô cơ & Phân tích định lượng', 4, 45, 30, 0.20, 0.30, 0.50, 8, NOW(), 0),
(362, 'CH1202', 'Hóa hữu cơ ứng dụng & Cơ chế phản ứng', 4, 45, 30, 0.20, 0.30, 0.50, 8, NOW(), 0),
(363, 'CH2103', 'Hóa lý và Hóa keo thực nghiệm', 3, 30, 30, 0.40, 0.00, 0.60, 8, NOW(), 0),
(364, 'CH2204', 'Quá trình & Thiết bị công nghệ hóa học', 4, 45, 30, 0.20, 0.30, 0.50, 8, NOW(), 0),
(365, 'CH3105', 'Công nghệ lọc hóa dầu và Khí đốt', 3, 45, 0, 0.40, 0.00, 0.60, 8, NOW(), 0),
(366, 'CH3206', 'Công nghệ tổng hợp hữu cơ & Hóa dược', 3, 30, 30, 0.40, 0.00, 0.60, 8, NOW(), 0),
(367, 'CH4107', 'Xử lý nước thải và Chất thải công nghiệp', 3, 30, 30, 0.40, 0.00, 0.60, 8, NOW(), 0),
(368, 'CH4208', 'An toàn hóa chất và Quản lý phòng thí nghiệm', 3, 45, 0, 0.40, 0.00, 0.60, 8, NOW(), 0),

-- Khoa Công nghệ May & Thiết kế thời trang (department 9)
(371, 'FA1101', 'Vật liệu dệt may & Kiểm nghiệm xơ sợi', 3, 30, 30, 0.40, 0.00, 0.60, 9, NOW(), 0),
(372, 'FA1202', 'Mỹ thuật trang phục và Vẽ phác thảo', 3, 30, 30, 0.40, 0.00, 0.60, 9, NOW(), 0),
(373, 'FA2103', 'Thiết kế mẫu rập 2D/3D (Gerber)', 4, 45, 30, 0.20, 0.30, 0.50, 9, NOW(), 0),
(374, 'FA2204', 'Kỹ thuật may công nghiệp căn bản', 3, 30, 30, 0.40, 0.00, 0.60, 9, NOW(), 0),
(375, 'FA3105', 'Thiết kế bộ sưu tập thời trang ứng dụng', 4, 45, 30, 0.20, 0.30, 0.50, 9, NOW(), 0),
(376, 'FA3206', 'Quản lý chất lượng sản phẩm may chuyền', 3, 45, 0, 0.40, 0.00, 0.60, 9, NOW(), 0),
(377, 'FA4107', 'Định mức kinh tế kỹ thuật may công nghiệp', 3, 45, 0, 0.40, 0.00, 0.60, 9, NOW(), 0),
(378, 'FA4208', 'Dự báo xu hướng & Tiếp thị thời trang', 3, 45, 0, 0.40, 0.00, 0.60, 9, NOW(), 0),

-- Khoa Quản lý Kinh doanh (department 10)
(381, 'BA1101', 'Quản trị học đại cương', 3, 45, 0, 0.40, 0.00, 0.60, 10, NOW(), 0),
(382, 'BA1202', 'Quản trị Marketing căn bản', 3, 45, 0, 0.40, 0.00, 0.60, 10, NOW(), 0),
(383, 'BA2103', 'Quản trị nguồn nhân lực hiện đại', 3, 45, 0, 0.40, 0.00, 0.60, 10, NOW(), 0),
(384, 'BA2204', 'Quản trị chuỗi cung ứng và Vận hành', 3, 45, 0, 0.40, 0.00, 0.60, 10, NOW(), 0),
(385, 'BA3105', 'Hành vi người tiêu dùng và Tâm lý học thị trường', 3, 45, 0, 0.40, 0.00, 0.60, 10, NOW(), 0),
(386, 'BA3206', 'Khởi sự kinh doanh & Đổi mới sáng tạo', 3, 45, 0, 0.40, 0.00, 0.60, 10, NOW(), 0),
(387, 'BA4107', 'Quản trị chiến lược doanh nghiệp', 3, 45, 0, 0.40, 0.00, 0.60, 10, NOW(), 0),
(388, 'BA4208', 'Thương mại điện tử và Digital Marketing', 3, 30, 30, 0.40, 0.00, 0.60, 10, NOW(), 0),

-- Khoa Công nghệ Thực phẩm (department 15)
(391, 'FD1101', 'Hóa sinh học thực phẩm dinh dưỡng', 3, 45, 0, 0.40, 0.00, 0.60, 15, NOW(), 0),
(392, 'FD1202', 'Vi sinh vật học thực phẩm & An toàn vệ sinh', 4, 45, 30, 0.20, 0.30, 0.50, 15, NOW(), 0),
(393, 'FD2103', 'Quá trình & Thiết bị chế biến thực phẩm', 4, 45, 30, 0.20, 0.30, 0.50, 15, NOW(), 0),
(394, 'FD2204', 'Công nghệ chế biến sữa và Đồ uống', 3, 30, 30, 0.40, 0.00, 0.60, 15, NOW(), 0),
(395, 'FD3105', 'Công nghệ chế biến thịt và Thủy sản', 3, 30, 30, 0.40, 0.00, 0.60, 15, NOW(), 0),
(396, 'FD3206', 'Đánh giá cảm quan và Thử nếm thực phẩm', 3, 30, 30, 0.40, 0.00, 0.60, 15, NOW(), 0),
(397, 'FD4107', 'Quản lý chất lượng thực phẩm HACCP/ISO 22000', 3, 45, 0, 0.40, 0.00, 0.60, 15, NOW(), 0),
(398, 'FD4208', 'Công nghệ bao bì và Kỹ thuật bảo quản thực phẩm', 3, 45, 0, 0.40, 0.00, 0.60, 15, NOW(), 0)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    credits = EXCLUDED.credits,
    theory_hours = EXCLUDED.theory_hours,
    practice_hours = EXCLUDED.practice_hours,
    department_id = EXCLUDED.department_id,
    attendance_weight = EXCLUDED.attendance_weight,
    midterm_weight = EXCLUDED.midterm_weight,
    final_weight = EXCLUDED.final_weight;

SELECT setval('courses_id_seq', (SELECT MAX(id) FROM courses));

-- Map newly added courses to academic programs (programs 2, 3, 4, 5, 6, 7, 8, 9, 10, 15)
DELETE FROM program_courses WHERE course_id BETWEEN 301 AND 398;

INSERT INTO program_courses (program_id, course_id, semester_index, is_compulsory)
VALUES
-- Program 2 (Kỹ thuật Điện tử - Viễn thông / Khoa Điện tử)
(2, 301, 1, true), (2, 302, 2, true), (2, 303, 3, true), (2, 304, 4, true),
(2, 305, 5, false), (2, 306, 6, false), (2, 307, 7, true), (2, 308, 8, true),

-- Program 3 (Công nghệ Kỹ thuật Cơ khí)
(3, 311, 1, true), (3, 312, 2, true), (3, 313, 3, true), (3, 314, 4, true),
(3, 315, 5, true), (3, 316, 6, false), (3, 317, 7, false), (3, 318, 8, true),

-- Program 4 (Công nghệ Kỹ thuật Ô tô)
(4, 321, 1, true), (4, 322, 2, true), (4, 323, 3, true), (4, 324, 4, true),
(4, 325, 5, true), (4, 326, 6, false), (4, 327, 7, true), (4, 328, 8, false),

-- Program 5 (Kinh tế)
(5, 331, 1, true), (5, 332, 2, true), (5, 333, 3, true), (5, 334, 4, true),
(5, 335, 5, true), (5, 336, 6, true), (5, 337, 7, true), (5, 338, 8, false),

-- Program 6 (Kế toán Doanh nghiệp)
(6, 341, 1, true), (6, 342, 2, true), (6, 343, 3, true), (6, 344, 4, true),
(6, 345, 5, true), (6, 346, 6, true), (6, 347, 7, true), (6, 348, 8, false),

-- Program 7 (Ngôn ngữ Anh)
(7, 351, 1, true), (7, 352, 2, true), (7, 353, 3, true), (7, 354, 4, true),
(7, 355, 5, true), (7, 356, 6, false), (7, 357, 7, true), (7, 358, 8, false),

-- Program 8 (Công nghệ Kỹ thuật Hóa học)
(8, 361, 1, true), (8, 362, 2, true), (8, 363, 3, true), (8, 364, 4, true),
(8, 365, 5, false), (8, 366, 6, true), (8, 367, 7, true), (8, 368, 8, false),

-- Program 9 (Công nghệ May & Thiết kế thời trang)
(9, 371, 1, true), (9, 372, 2, true), (9, 373, 3, true), (9, 374, 4, true),
(9, 375, 5, true), (9, 376, 6, true), (9, 377, 7, true), (9, 378, 8, false),

-- Program 10 (Quản lý Kinh doanh)
(10, 381, 1, true), (10, 382, 2, true), (10, 383, 3, true), (10, 384, 4, true),
(10, 385, 5, true), (10, 386, 6, true), (10, 387, 7, true), (10, 388, 8, false),

-- Program 15 (Công nghệ Thực phẩm)
(15, 391, 1, true), (15, 392, 2, true), (15, 393, 3, true), (15, 394, 4, true),
(15, 395, 5, true), (15, 396, 6, true), (15, 397, 7, true), (15, 398, 8, false)
ON CONFLICT (program_id, course_id) DO NOTHING;

-- Create Open Class Sections in Semester 50 for these departments so students can register
INSERT INTO class_sections (id, section_code, course_id, semester_id, teacher_id, max_capacity, current_enrolled, status, created_at, version)
VALUES
(301, 'EE1101001', 301, 50, 2, 60, 0, 'OPEN', NOW(), 0),
(302, 'EE1101002', 301, 50, 52, 60, 0, 'OPEN', NOW(), 0),
(311, 'ME1101001', 311, 50, 3, 60, 0, 'OPEN', NOW(), 0),
(312, 'ME1101002', 311, 50, 53, 60, 0, 'OPEN', NOW(), 0),
(321, 'AU1101001', 321, 50, 4, 60, 0, 'OPEN', NOW(), 0),
(322, 'AU1101002', 321, 50, 54, 60, 0, 'OPEN', NOW(), 0),
(331, 'EC1101001', 331, 50, 5, 60, 0, 'OPEN', NOW(), 0),
(332, 'EC1101002', 331, 50, 55, 60, 0, 'OPEN', NOW(), 0),
(341, 'AC1101001', 341, 50, 6, 60, 0, 'OPEN', NOW(), 0),
(351, 'EN1101001', 351, 50, 7, 60, 0, 'OPEN', NOW(), 0),
(361, 'CH1101001', 361, 50, 8, 60, 0, 'OPEN', NOW(), 0),
(371, 'FA1101001', 371, 50, 9, 60, 0, 'OPEN', NOW(), 0),
(381, 'BA1101001', 381, 50, 10, 60, 0, 'OPEN', NOW(), 0),
(391, 'FD1101001', 391, 50, 15, 60, 0, 'OPEN', NOW(), 0)
ON CONFLICT (id) DO UPDATE SET
    section_code = EXCLUDED.section_code,
    course_id = EXCLUDED.course_id,
    semester_id = EXCLUDED.semester_id,
    teacher_id = EXCLUDED.teacher_id,
    max_capacity = EXCLUDED.max_capacity,
    status = EXCLUDED.status;

SELECT setval('class_sections_id_seq', (SELECT MAX(id) FROM class_sections));

-- Add schedules for these class sections
INSERT INTO class_schedules (class_section_id, day_of_week, start_period, end_period, room, building, campus, start_week, end_week)
VALUES
(301, 2, 1, 3, 'P. Điện tử 101', 'Nhà B1', 'Cơ sở 1', 1, 15),
(302, 4, 7, 9, 'P. Điện tử 102', 'Nhà B1', 'Cơ sở 1', 1, 15),
(311, 3, 1, 3, 'Xưởng Cơ khí 1', 'Nhà C1', 'Cơ sở 1', 1, 15),
(312, 5, 7, 9, 'Xưởng Cơ khí 2', 'Nhà C1', 'Cơ sở 1', 1, 15),
(321, 2, 7, 10, 'Xưởng Ô tô 1', 'Nhà D1', 'Cơ sở 2', 1, 15),
(322, 4, 1, 4, 'Xưởng Ô tô 2', 'Nhà D1', 'Cơ sở 2', 1, 15),
(331, 3, 7, 9, 'P. Học 201', 'Nhà A2', 'Cơ sở 1', 1, 15),
(332, 6, 1, 3, 'P. Học 202', 'Nhà A2', 'Cơ sở 1', 1, 15),
(341, 2, 4, 6, 'P. Học 301', 'Nhà A2', 'Cơ sở 1', 1, 15),
(351, 3, 4, 6, 'P. Ngoại ngữ 401', 'Nhà A3', 'Cơ sở 1', 1, 15),
(361, 4, 7, 10, 'Phòng thí nghiệm Hóa 1', 'Nhà E1', 'Cơ sở 1', 1, 15),
(371, 5, 1, 3, 'Xưởng May thời trang 1', 'Nhà F1', 'Cơ sở 2', 1, 15),
(381, 6, 4, 6, 'P. Học 402', 'Nhà A2', 'Cơ sở 1', 1, 15),
(391, 5, 4, 6, 'Phòng thí nghiệm Thực phẩm', 'Nhà E2', 'Cơ sở 1', 1, 15)
ON CONFLICT DO NOTHING;

-- Enroll representative students of each department into their department section (30 students per section)
-- Fee: section 301, students from dept 2
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 301, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 2 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Mech: section 311, students from dept 3
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 311, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 3 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Auto: section 321, students from dept 4
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 321, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 4 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Econ: section 331, students from dept 5
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 331, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 5 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Acc: section 341, students from dept 6
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 341, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 6 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Lang: section 351, students from dept 7
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 351, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 7 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Chem: section 361, students from dept 8
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 361, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 8 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Fashion: section 371, students from dept 9
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 371, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 9 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Business: section 381, students from dept 10
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 381, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 10 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Food: section 391, students from dept 15
INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status)
SELECT s.id, 391, NOW(), 'ENROLLED'
FROM students s WHERE s.department_id = 15 ORDER BY s.id LIMIT 30
ON CONFLICT (student_id, class_section_id) DO NOTHING;

-- Sync current_enrolled for newly populated sections
UPDATE class_sections cs
SET current_enrolled = (SELECT COUNT(*) FROM enrollments WHERE class_section_id = cs.id)
WHERE cs.id >= 300;

-- ------------------------------------------------------------------------------
-- 5. STANDARDIZE SEMESTERS CYCLE: Học kỳ 1, 2, Xuân, 3, 4, Hè
-- ------------------------------------------------------------------------------
-- Delete unused mock semesters (those without any sections)
DELETE FROM semesters
WHERE id NOT IN (SELECT DISTINCT semester_id FROM class_sections)
  AND id <> 50;

-- Temporarily randomize codes to avoid duplicate unique constraint conflicts during renumbering
UPDATE semesters SET code = 'TMP_' || id WHERE id IN (1, 41, 42, 44, 45, 47, 48, 50);

-- Update recent and active semesters to strictly follow the required order and durations:
-- 1, 2, 3, 4 are main terms (4 months each)
-- Xuân, Hè are supplementary terms (2 months each)
UPDATE semesters SET
    code = '20241',
    name = 'Học kỳ 1 năm học 2024 - 2025',
    academic_year = '2024-2025',
    semester_number = 1,
    start_date = '2024-09-01',
    end_date = '2024-12-31',
    min_credits = 12,
    max_credits = 24,
    is_register_open = false
WHERE id = 1;

UPDATE semesters SET
    code = '20242',
    name = 'Học kỳ 2 năm học 2024 - 2025',
    academic_year = '2024-2025',
    semester_number = 2,
    start_date = '2025-01-01',
    end_date = '2025-04-30',
    min_credits = 12,
    max_credits = 24,
    is_register_open = false
WHERE id = 41;

UPDATE semesters SET
    code = '2024X',
    name = 'Học kỳ Xuân năm học 2024 - 2025',
    academic_year = '2024-2025',
    semester_number = 3,
    start_date = '2025-05-01',
    end_date = '2025-06-30',
    min_credits = 6,
    max_credits = 14,
    is_register_open = false
WHERE id = 42;

UPDATE semesters SET
    code = '20251',
    name = 'Học kỳ 3 năm học 2025 - 2026',
    academic_year = '2025-2026',
    semester_number = 4,
    start_date = '2025-07-01',
    end_date = '2025-10-31',
    min_credits = 12,
    max_credits = 24,
    is_register_open = false
WHERE id = 44;

UPDATE semesters SET
    code = '20252',
    name = 'Học kỳ 4 năm học 2025 - 2026',
    academic_year = '2025-2026',
    semester_number = 5,
    start_date = '2025-11-01',
    end_date = '2026-02-28',
    min_credits = 12,
    max_credits = 24,
    is_register_open = false
WHERE id = 45;

UPDATE semesters SET
    code = '2025H',
    name = 'Học kỳ Hè năm học 2025 - 2026',
    academic_year = '2025-2026',
    semester_number = 6,
    start_date = '2026-03-01',
    end_date = '2026-04-30',
    min_credits = 6,
    max_credits = 14,
    is_register_open = false
WHERE id = 47;

UPDATE semesters SET
    code = '20261',
    name = 'Học kỳ 1 năm học 2026 - 2027',
    academic_year = '2026-2027',
    semester_number = 1,
    start_date = '2026-05-01',
    end_date = '2026-08-31',
    min_credits = 12,
    max_credits = 24,
    is_register_open = false
WHERE id = 48;

-- Semester 50: The currently active registration semester
UPDATE semesters SET
    code = '20262',
    name = 'Học kỳ 2 năm học 2026 - 2027',
    academic_year = '2026-2027',
    semester_number = 2,
    start_date = '2026-09-01',
    end_date = '2026-12-31',
    min_credits = 12,
    max_credits = 24,
    is_register_open = true
WHERE id = 50;
