-- ====================================================================
-- V8: Clean up mock departments (16..50) and sync student curriculum grades
-- ====================================================================

-- 1. Reassign FK references to departments 16..50 to department 1 (FIT)
UPDATE students SET department_id = 1 WHERE department_id BETWEEN 16 AND 50;
UPDATE teachers SET department_id = 1 WHERE department_id BETWEEN 16 AND 50;
UPDATE courses SET department_id = 1 WHERE department_id BETWEEN 16 AND 50;
UPDATE academic_programs SET department_id = 1 WHERE department_id BETWEEN 16 AND 50;

-- 2. Delete mock departments 16..50
DELETE FROM departments WHERE id BETWEEN 16 AND 50;

-- 3. Create class sections, schedules, enrollments, and grades for Curriculum Semesters 1 to 5 (courses 81 to 110)
-- Student 1 (2021600001, id=1) has completed Semesters 1 through 5 (90 credits total)
DO $$
DECLARE
    rec RECORD;
    v_sec_id BIGINT;
    v_enr1_id BIGINT;
    v_enr2_id BIGINT;
    v_enr3_id BIGINT;
    v_sem_id BIGINT;
    v_teacher_id BIGINT;
    v_tx1 NUMERIC(4,2);
    v_tx2 NUMERIC(4,2);
    v_mid NUMERIC(4,2);
    v_fin NUMERIC(4,2);
    v_tot NUMERIC(4,2);
    v_gpa4 NUMERIC(4,2);
    v_letter VARCHAR(5);
BEGIN
    FOR rec IN 
        SELECT pc.semester_index, c.id AS course_id, c.code, c.name, c.credits
        FROM program_courses pc
        JOIN courses c ON pc.course_id = c.id
        WHERE pc.program_id = 1 AND pc.semester_index BETWEEN 1 AND 5
        ORDER BY pc.semester_index, c.id
    LOOP
        -- Determine past semester
        IF rec.semester_index = 1 THEN
            v_sem_id := 41; -- 20181
            v_teacher_id := 1;
        ELSIF rec.semester_index = 2 THEN
            v_sem_id := 42; -- 20182
            v_teacher_id := 2;
        ELSIF rec.semester_index = 3 THEN
            v_sem_id := 44; -- 20191
            v_teacher_id := 3;
        ELSIF rec.semester_index = 4 THEN
            v_sem_id := 45; -- 20192
            v_teacher_id := 1;
        ELSE
            v_sem_id := 47; -- 20251
            v_teacher_id := 2;
        END IF;

        -- Create class section if not exists
        SELECT id INTO v_sec_id FROM class_sections 
        WHERE semester_id = v_sem_id AND course_id = rec.course_id LIMIT 1;

        IF v_sec_id IS NULL THEN
            INSERT INTO class_sections (course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status, created_at)
            VALUES (rec.course_id, v_sem_id, v_teacher_id, 'SEC-' || rec.code || '-01', 60, 3, 'OPEN', NOW())
            RETURNING id INTO v_sec_id;

            -- Create class schedule
            INSERT INTO class_schedules (class_section_id, day_of_week, start_period, end_period, room, start_week, end_week, building, campus, created_at)
            VALUES (v_sec_id, 2 + (rec.course_id % 6), 1 + ((rec.course_id * 2) % 6), 3 + ((rec.course_id * 2) % 6), 'P-' || (100 + (rec.course_id % 30)), 1, 15, 'Tòa A1', 'Cơ sở 1', NOW());
        END IF;

        -- Realistic scores for student 1 (GPA ~ 3.4 - 3.7)
        IF rec.credits <= 3 THEN
            -- No midterm: TX 40% (TX1 20%, TX2 20%), CK 60%
            v_tx1 := 8.5 + ((rec.course_id % 3) * 0.5); -- 8.5, 9.0, 9.5
            v_tx2 := 8.0 + ((rec.course_id % 4) * 0.5); -- 8.0, 8.5, 9.0, 9.5
            v_mid := NULL;
            v_fin := 8.0 + (((rec.course_id + 1) % 3) * 0.5); -- 8.5, 9.0, 8.0
            v_tot := ROUND((((v_tx1 + v_tx2) / 2.0) * 0.4 + v_fin * 0.6), 1);
        ELSE
            -- >= 4 TC: TX 20%, GK 30%, CK 50%
            v_tx1 := 9.0;
            v_tx2 := 8.5;
            v_mid := 8.0 + ((rec.course_id % 2) * 0.5);
            v_fin := 8.5;
            v_tot := ROUND((((v_tx1 + v_tx2) / 2.0) * 0.2 + v_mid * 0.3 + v_fin * 0.5), 1);
        END IF;

        -- Grade letter & GPA4
        IF v_tot >= 9.0 THEN
            v_letter := 'A+'; v_gpa4 := 4.0;
        ELSIF v_tot >= 8.5 THEN
            v_letter := 'A'; v_gpa4 := 3.7;
        ELSIF v_tot >= 8.0 THEN
            v_letter := 'B+'; v_gpa4 := 3.5;
        ELSIF v_tot >= 7.0 THEN
            v_letter := 'B'; v_gpa4 := 3.0;
        ELSIF v_tot >= 6.5 THEN
            v_letter := 'C+'; v_gpa4 := 2.5;
        ELSIF v_tot >= 5.5 THEN
            v_letter := 'C'; v_gpa4 := 2.0;
        ELSIF v_tot >= 5.0 THEN
            v_letter := 'D+'; v_gpa4 := 1.5;
        ELSIF v_tot >= 4.0 THEN
            v_letter := 'D'; v_gpa4 := 1.0;
        ELSE
            v_letter := 'F'; v_gpa4 := 0.0;
        END IF;

        -- Enroll student 1
        SELECT id INTO v_enr1_id FROM enrollments WHERE student_id = 1 AND class_section_id = v_sec_id;
        IF v_enr1_id IS NULL THEN
            INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, created_at)
            VALUES (1, v_sec_id, NOW() - INTERVAL '1 year', 'ENROLLED', NOW() - INTERVAL '1 year')
            RETURNING id INTO v_enr1_id;
        END IF;

        -- Grade for student 1
        IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = v_enr1_id) THEN
            INSERT INTO grades (enrollment_id, regular_score_1, regular_score_2, attendance_score, midterm_score, final_score, total_score_10, gpa_score_4, letter_grade, is_locked, created_at)
            VALUES (v_enr1_id, v_tx1, v_tx2, v_tx1, v_mid, v_fin, v_tot, v_gpa4, v_letter, TRUE, NOW() - INTERVAL '1 year');
        ELSE
            UPDATE grades SET
                regular_score_1 = v_tx1,
                regular_score_2 = v_tx2,
                attendance_score = v_tx1,
                midterm_score = v_mid,
                final_score = v_fin,
                total_score_10 = v_tot,
                gpa_score_4 = v_gpa4,
                letter_grade = v_letter,
                is_locked = TRUE
            WHERE enrollment_id = v_enr1_id;
        END IF;

        -- Enroll student 2 (peer student)
        SELECT id INTO v_enr2_id FROM enrollments WHERE student_id = 2 AND class_section_id = v_sec_id;
        IF v_enr2_id IS NULL THEN
            INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, created_at)
            VALUES (2, v_sec_id, NOW() - INTERVAL '1 year', 'ENROLLED', NOW() - INTERVAL '1 year')
            RETURNING id INTO v_enr2_id;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = v_enr2_id) THEN
            INSERT INTO grades (enrollment_id, regular_score_1, regular_score_2, attendance_score, midterm_score, final_score, total_score_10, gpa_score_4, letter_grade, is_locked, created_at)
            VALUES (v_enr2_id, 8.0, 8.0, 8.0, CASE WHEN rec.credits >= 4 THEN 7.5 ELSE NULL END, 8.0, 8.0, 3.5, 'B+', TRUE, NOW() - INTERVAL '1 year');
        END IF;

        -- Enroll student 3 (peer student)
        SELECT id INTO v_enr3_id FROM enrollments WHERE student_id = 3 AND class_section_id = v_sec_id;
        IF v_enr3_id IS NULL THEN
            INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, created_at)
            VALUES (3, v_sec_id, NOW() - INTERVAL '1 year', 'ENROLLED', NOW() - INTERVAL '1 year')
            RETURNING id INTO v_enr3_id;
        END IF;
        IF NOT EXISTS (SELECT 1 FROM grades WHERE enrollment_id = v_enr3_id) THEN
            INSERT INTO grades (enrollment_id, regular_score_1, regular_score_2, attendance_score, midterm_score, final_score, total_score_10, gpa_score_4, letter_grade, is_locked, created_at)
            VALUES (v_enr3_id, 9.0, 9.0, 9.0, CASE WHEN rec.credits >= 4 THEN 9.0 ELSE NULL END, 9.0, 9.0, 4.0, 'A+', TRUE, NOW() - INTERVAL '1 year');
        END IF;

    END LOOP;
END $$;

-- 4. Create class sections in active semester 50 for Semester 6 courses (111..116) and enroll student 1
DO $$
DECLARE
    rec RECORD;
    v_sec_id BIGINT;
    v_enr_id BIGINT;
BEGIN
    FOR rec IN 
        SELECT pc.semester_index, c.id AS course_id, c.code, c.name, c.credits
        FROM program_courses pc
        JOIN courses c ON pc.course_id = c.id
        WHERE pc.program_id = 1 AND pc.semester_index = 6
        ORDER BY c.id
    LOOP
        SELECT id INTO v_sec_id FROM class_sections 
        WHERE semester_id = 50 AND course_id = rec.course_id LIMIT 1;

        IF v_sec_id IS NULL THEN
            INSERT INTO class_sections (course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status, created_at)
            VALUES (rec.course_id, 50, 1 + (rec.course_id % 3), '20261-' || rec.code || '-01', 60, 1, 'OPEN', NOW())
            RETURNING id INTO v_sec_id;

            INSERT INTO class_schedules (class_section_id, day_of_week, start_period, end_period, room, start_week, end_week, building, campus, created_at)
            VALUES (v_sec_id, 2 + (rec.course_id % 6), 7, 9, 'A2-' || (200 + (rec.course_id % 20)), 1, 15, 'Tòa A2', 'Cơ sở 1', NOW());
        END IF;

        SELECT id INTO v_enr_id FROM enrollments WHERE student_id = 1 AND class_section_id = v_sec_id;
        IF v_enr_id IS NULL THEN
            INSERT INTO enrollments (student_id, class_section_id, enrolled_at, status, created_at)
            VALUES (1, v_sec_id, NOW(), 'ENROLLED', NOW());
        END IF;
    END LOOP;
END $$;
