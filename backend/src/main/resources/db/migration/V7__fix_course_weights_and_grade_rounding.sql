-- V7__fix_course_weights_and_grade_rounding.sql
-- 1. Cập nhật trọng số theo tín chỉ của môn học:
--    - Môn từ 3 tín chỉ trở xuống (credits <= 3): Không có giữa kỳ (midterm_weight = 0), TX 40% (TX1 20%, TX2 20%), Cuối kỳ 60% (nằm trong khoảng 50% - 70%)
--    - Môn từ 4 tín chỉ trở lên (credits >= 4): Có giữa kỳ, TX 20% (TX1 10%, TX2 10%), Giữa kỳ 30%, Cuối kỳ 50% (nằm trong khoảng 50% - 70%)

UPDATE courses
SET attendance_weight = 0.40,
    midterm_weight = 0.00,
    final_weight = 0.60
WHERE credits <= 3;

UPDATE courses
SET attendance_weight = 0.20,
    midterm_weight = 0.30,
    final_weight = 0.50
WHERE credits >= 4;

-- 2. Cập nhật lại toàn bộ điểm các môn đã có trong hệ thống:
--    - Môn <= 3 tín chỉ: không tính điểm giữa kỳ, tính lại tổng kết theo trọng số mới, làm tròn 1 chữ số thập phân
UPDATE grades g
SET midterm_score = NULL,
    total_score_10 = ROUND((COALESCE(g.attendance_score, 0) * 0.40 + COALESCE(g.final_score, 0) * 0.60)::NUMERIC, 1)
FROM enrollments e
JOIN class_sections cs ON e.class_section_id = cs.id
JOIN courses c ON cs.course_id = c.id
WHERE g.enrollment_id = e.id AND c.credits <= 3 AND g.final_score IS NOT NULL;

--    - Môn >= 4 tín chỉ: có điểm giữa kỳ, tính lại tổng kết theo trọng số mới, làm tròn 1 chữ số thập phân
UPDATE grades g
SET total_score_10 = ROUND((COALESCE(g.attendance_score, 0) * 0.20 + COALESCE(g.midterm_score, 0) * 0.30 + COALESCE(g.final_score, 0) * 0.50)::NUMERIC, 1)
FROM enrollments e
JOIN class_sections cs ON e.class_section_id = cs.id
JOIN courses c ON cs.course_id = c.id
WHERE g.enrollment_id = e.id AND c.credits >= 4 AND g.final_score IS NOT NULL;

-- 3. Cập nhật lại letter_grade và gpa_score_4 theo thang điểm chuẩn Bộ GD&ĐT dựa trên total_score_10 đã làm tròn 1 chữ số thập phân
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
