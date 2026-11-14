-- ====================================================================
-- V9: Scale students to >= 200 per department, multiple sections per course (naming [courseCode]001..010),
-- resolve timetable conflicts, and sync student transcript with curriculum (90/140 credits passed).
-- ====================================================================

-- 1. Remove non-curriculum enrollments for student 1 so transcript passed credits equals 90/140
DELETE FROM enrollments 
WHERE student_id = 1 
  AND class_section_id IN (
      SELECT cs.id FROM class_sections cs 
      WHERE cs.course_id NOT IN (
          SELECT pc.course_id FROM program_courses pc WHERE pc.program_id = 1
      )
  );

-- 2. Scale students: Ensure every department (1..15) has at least 210 students (>= 200)
DO $$
DECLARE
    dept RECORD;
    cur_cnt INT;
    needed INT;
    i INT;
    v_user_id BIGINT;
    v_fn TEXT[] := ARRAY['An', 'Bình', 'Cường', 'Dũng', 'Giang', 'Hải', 'Hùng', 'Khoa', 'Linh', 'Long', 'Nam', 'Phong', 'Phúc', 'Quân', 'Sơn', 'Thắng', 'Trung', 'Tuấn', 'Việt', 'Vy', 'Trang', 'Hương', 'Mai', 'Lan', 'Phương', 'Hà', 'Hoàng', 'Thảo', 'Nhung', 'Ngọc'];
    v_ln TEXT[] := ARRAY['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Vũ', 'Đặng', 'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương', 'Lý', 'Đinh', 'Võ'];
    v_mn TEXT[] := ARRAY['Văn', 'Thị', 'Minh', 'Đức', 'Hoàng', 'Quốc', 'Hữu', 'Tuấn', 'Thành', 'Ngọc', 'Thu', 'Anh', 'Hải', 'Xuân'];
    v_name TEXT;
    v_username TEXT;
    v_email TEXT;
    v_phone TEXT;
    v_std_code TEXT;
    v_cls TEXT;
    v_dob DATE;
    v_gender VARCHAR(10);
    v_prog_id BIGINT;
BEGIN
    FOR dept IN SELECT id, code, name FROM departments WHERE id BETWEEN 1 AND 15 ORDER BY id LOOP
        SELECT count(*) INTO cur_cnt FROM students WHERE department_id = dept.id;
        needed := 210 - cur_cnt;
        
        -- Get primary program for department
        SELECT MIN(id) INTO v_prog_id FROM academic_programs WHERE department_id = dept.id;
        IF v_prog_id IS NULL THEN
            v_prog_id := 1;
        END IF;

        IF needed > 0 THEN
            FOR i IN 1..needed LOOP
                v_name := v_ln[1 + ((dept.id * 7 + i * 3) % array_length(v_ln, 1))] || ' ' ||
                          v_mn[1 + ((dept.id * 5 + i * 2) % array_length(v_mn, 1))] || ' ' ||
                          v_fn[1 + ((dept.id * 11 + i) % array_length(v_fn, 1))];
                v_username := 'sv_' || dept.id || '_' || LPAD(i::text, 4, '0');
                
                -- avoid username collision
                WHILE EXISTS (SELECT 1 FROM users WHERE username = v_username) LOOP
                    v_username := v_username || '_' || floor(random() * 100)::text;
                END LOOP;

                v_email := v_username || '@daihoc.edu.vn';
                v_phone := '098' || LPAD(((dept.id * 10000 + i) % 10000000)::text, 7, '0');
                
                INSERT INTO users (username, password_hash, email, full_name, phone, is_active)
                VALUES (v_username, '$2a$10$sDsqkTZOSb76VFZKBrwBeO2mzRph/KUWsuiEr8VVRcW7.1esrvmam', v_email, v_name, v_phone, true)
                RETURNING id INTO v_user_id;

                INSERT INTO user_roles (user_id, role_id) VALUES (v_user_id, 3);

                v_std_code := '202' || (1 + (i % 4))::text || LPAD(dept.id::text, 2, '0') || LPAD(i::text, 4, '0');
                WHILE EXISTS (SELECT 1 FROM students WHERE student_code = v_std_code) LOOP
                    v_std_code := '202' || (1 + (i % 4))::text || LPAD(dept.id::text, 2, '0') || LPAD((i + 1000)::text, 4, '0');
                END LOOP;

                v_cls := dept.code || '-K' || (16 + (i % 4)) || '-' || ((i % 3) + 1);
                v_dob := DATE '2002-01-01' + ((dept.id * 31 + i * 17) % 1500) * INTERVAL '1 day';
                v_gender := CASE WHEN (i % 3 = 0) THEN 'Nữ' ELSE 'Nam' END;

                INSERT INTO students (user_id, student_code, department_id, program_id, cohort, class_name, academic_status, date_of_birth, gender, address, province)
                VALUES (v_user_id, v_std_code, dept.id, v_prog_id, 16 + (i % 4), v_cls, 'STUDYING', v_dob, v_gender, 'Hà Nội', 'Thành phố Hà Nội');
            END LOOP;
        END IF;
    END LOOP;
END $$;

-- 3. Standardize and generate multiple sections per course in Semester 50 (code [courseCode]001..010)
DO $$
DECLARE
    rec RECORD;
    v_c_code TEXT;
    v_sec1_id BIGINT;
    v_sec2_id BIGINT;
    v_sec3_id BIGINT;
    v_t1 BIGINT;
    v_t2 BIGINT;
    v_t3 BIGINT;
    v_std RECORD;
    v_enr_cnt INT;
    v_dow INT;
    v_start INT;
    v_end INT;
BEGIN
    -- Delete empty sections with old SEC- names if any
    DELETE FROM class_sections WHERE semester_id = 50 AND section_code LIKE 'SEC-%' AND current_enrolled = 0;
    
    -- Rename existing sections in semester 50 to [courseCode]001 if they don't already match
    FOR rec IN 
        SELECT cs.id, cs.section_code, c.code AS course_code, cs.course_id
        FROM class_sections cs
        JOIN courses c ON cs.course_id = c.id
        WHERE cs.semester_id = 50
        ORDER BY cs.id
    LOOP
        IF rec.section_code NOT LIKE (rec.course_code || '%') THEN
            IF NOT EXISTS (SELECT 1 FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '001') THEN
                UPDATE class_sections SET section_code = rec.course_code || '001' WHERE id = rec.id;
            ELSIF NOT EXISTS (SELECT 1 FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '002') THEN
                UPDATE class_sections SET section_code = rec.course_code || '002' WHERE id = rec.id;
            ELSE
                UPDATE class_sections SET section_code = rec.course_code || '003' WHERE id = rec.id;
            END IF;
        END IF;
    END LOOP;

    -- Ensure each active course in semester 50 has sections 001, 002, 003
    FOR rec IN 
        SELECT DISTINCT c.id AS course_id, c.code AS course_code, c.credits, c.department_id
        FROM courses c
        WHERE c.id IN (
            SELECT course_id FROM class_sections WHERE semester_id = 50
            UNION
            SELECT course_id FROM program_courses WHERE program_id = 1 AND semester_index = 6
        )
        ORDER BY c.code
    LOOP
        v_t1 := 1 + (rec.course_id % 15);
        v_t2 := 1 + ((rec.course_id + 3) % 15);
        v_t3 := 1 + ((rec.course_id + 7) % 15);

        -- Ensure Section 001
        IF NOT EXISTS (SELECT 1 FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '001') THEN
            INSERT INTO class_sections (course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status)
            VALUES (rec.course_id, 50, v_t1, rec.course_code || '001', 60, 0, 'OPEN')
            RETURNING id INTO v_sec1_id;
        ELSE
            SELECT id INTO v_sec1_id FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '001';
        END IF;

        -- Ensure Section 002
        IF NOT EXISTS (SELECT 1 FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '002') THEN
            INSERT INTO class_sections (course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status)
            VALUES (rec.course_id, 50, v_t2, rec.course_code || '002', 60, 0, 'OPEN')
            RETURNING id INTO v_sec2_id;
        ELSE
            SELECT id INTO v_sec2_id FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '002';
        END IF;

        -- Ensure Section 003
        IF NOT EXISTS (SELECT 1 FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '003') THEN
            INSERT INTO class_sections (course_id, semester_id, teacher_id, section_code, max_capacity, current_enrolled, status)
            VALUES (rec.course_id, 50, v_t3, rec.course_code || '003', 60, 0, 'OPEN')
            RETURNING id INTO v_sec3_id;
        ELSE
            SELECT id INTO v_sec3_id FROM class_sections WHERE semester_id = 50 AND section_code = rec.course_code || '003';
        END IF;

        -- Ensure schedules for Section 001 if missing
        IF NOT EXISTS (SELECT 1 FROM class_schedules WHERE class_section_id = v_sec1_id) THEN
            v_dow := 2 + (rec.course_id % 6);
            v_start := 1;
            v_end := 3;
            INSERT INTO class_schedules (class_section_id, day_of_week, start_period, end_period, room, start_week, end_week, building, campus)
            VALUES (v_sec1_id, v_dow, v_start, v_end, 'A1-' || (200 + (rec.course_id % 20)), 1, 15, 'Tòa nhà A1', 'Cơ sở 1');
        END IF;

        -- Ensure schedules for Section 002 if missing
        IF NOT EXISTS (SELECT 1 FROM class_schedules WHERE class_section_id = v_sec2_id) THEN
            v_dow := 2 + ((rec.course_id + 2) % 6);
            v_start := 4;
            v_end := 6;
            INSERT INTO class_schedules (class_section_id, day_of_week, start_period, end_period, room, start_week, end_week, building, campus)
            VALUES (v_sec2_id, v_dow, v_start, v_end, 'A2-' || (300 + (rec.course_id % 20)), 1, 15, 'Tòa nhà A2', 'Cơ sở 1');
        END IF;

        -- Ensure schedules for Section 003 if missing
        IF NOT EXISTS (SELECT 1 FROM class_schedules WHERE class_section_id = v_sec3_id) THEN
            v_dow := 2 + ((rec.course_id + 4) % 6);
            v_start := 7;
            v_end := 9;
            INSERT INTO class_schedules (class_section_id, day_of_week, start_period, end_period, room, start_week, end_week, building, campus)
            VALUES (v_sec3_id, v_dow, v_start, v_end, 'B1-' || (100 + (rec.course_id % 20)), 1, 15, 'Tòa nhà B1', 'Cơ sở 2');
        END IF;
    END LOOP;

    -- 4. Dedicated clean non-overlapping schedules for Program 1 Semester 6 sections (SE3209 to SE3214)
    -- Section SE3209001 (course 111): Thứ 2 (1-3)
    UPDATE class_schedules SET day_of_week = 2, start_period = 1, end_period = 3, room = 'A1-201'
    WHERE class_section_id = (SELECT id FROM class_sections WHERE semester_id = 50 AND section_code = 'SE3209001');

    -- Section SE3210001 (course 112): Thứ 3 (1-3)
    UPDATE class_schedules SET day_of_week = 3, start_period = 1, end_period = 3, room = 'A1-202'
    WHERE class_section_id = (SELECT id FROM class_sections WHERE semester_id = 50 AND section_code = 'SE3210001');

    -- Section SE3211001 (course 113): Thứ 4 (1-3)
    UPDATE class_schedules SET day_of_week = 4, start_period = 1, end_period = 3, room = 'A1-203'
    WHERE class_section_id = (SELECT id FROM class_sections WHERE semester_id = 50 AND section_code = 'SE3211001');

    -- Section SE3212001 (course 114): Thứ 5 (1-3)
    UPDATE class_schedules SET day_of_week = 5, start_period = 1, end_period = 3, room = 'A1-204'
    WHERE class_section_id = (SELECT id FROM class_sections WHERE semester_id = 50 AND section_code = 'SE3212001');

    -- Section SE3213001 (course 115): Thứ 6 (1-3)
    UPDATE class_schedules SET day_of_week = 6, start_period = 1, end_period = 3, room = 'A1-205'
    WHERE class_section_id = (SELECT id FROM class_sections WHERE semester_id = 50 AND section_code = 'SE3213001');

    -- Section SE3214001 (course 116): Thứ 7 (4-6)
    UPDATE class_schedules SET day_of_week = 7, start_period = 4, end_period = 6, room = 'A1-206'
    WHERE class_section_id = (SELECT id FROM class_sections WHERE semester_id = 50 AND section_code = 'SE3214001');

    -- 5. Reset Student 1's Semester 50 enrollments to exactly the 6 Semester 6 courses (Section 001)
    DELETE FROM enrollments 
    WHERE student_id = 1 
      AND class_section_id IN (SELECT id FROM class_sections WHERE semester_id = 50);

    FOR rec IN 
        SELECT id FROM class_sections 
        WHERE semester_id = 50 
          AND section_code IN ('SE3209001', 'SE3210001', 'SE3211001', 'SE3212001', 'SE3213001', 'SE3214001')
    LOOP
        INSERT INTO enrollments (student_id, class_section_id, status)
        VALUES (1, rec.id, 'ENROLLED');
    END LOOP;

    -- 6. Enroll students into sections in Semester 50 to fill them realistically (35..50 students each)
    FOR rec IN 
        SELECT cs.id, cs.section_code, cs.course_id, c.department_id, count(e.id) as current_cnt
        FROM class_sections cs
        JOIN courses c ON cs.course_id = c.id
        LEFT JOIN enrollments e ON e.class_section_id = cs.id
        WHERE cs.semester_id = 50
        GROUP BY cs.id, cs.section_code, cs.course_id, c.department_id
    LOOP
        v_enr_cnt := rec.current_cnt;
        IF v_enr_cnt < 35 THEN
            FOR v_std IN 
                SELECT s.id 
                FROM students s
                WHERE s.id != 1
                  AND NOT EXISTS (
                      SELECT 1 FROM enrollments e2 
                      JOIN class_sections cs2 ON e2.class_section_id = cs2.id 
                      WHERE e2.student_id = s.id AND cs2.course_id = rec.course_id AND cs2.semester_id = 50
                  )
                LIMIT (42 - v_enr_cnt)
            LOOP
                INSERT INTO enrollments (student_id, class_section_id, status)
                VALUES (v_std.id, rec.id, 'ENROLLED')
                ON CONFLICT DO NOTHING;
            END LOOP;
        END IF;
    END LOOP;

    -- 7. Update current_enrolled for all class sections in Semester 50
    UPDATE class_sections cs
    SET current_enrolled = (
        SELECT count(*) FROM enrollments e WHERE e.class_section_id = cs.id
    )
    WHERE cs.semester_id = 50;

END $$;
