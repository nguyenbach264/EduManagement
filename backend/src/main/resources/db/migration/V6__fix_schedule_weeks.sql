-- V6: Fix end_week based on credits and weekly periods, and add 4-component grading (TX1, TX2, GK, CK)

-- 1. Add regular_score_1 and regular_score_2 to grades table
ALTER TABLE grades ADD COLUMN IF NOT EXISTS regular_score_1 NUMERIC(4,2);
ALTER TABLE grades ADD COLUMN IF NOT EXISTS regular_score_2 NUMERIC(4,2);

-- Populate regular_score_1 and regular_score_2 from existing attendance_score
UPDATE grades
SET regular_score_1 = COALESCE(attendance_score, 8.5),
    regular_score_2 = CASE 
        WHEN attendance_score IS NOT NULL THEN GREATEST(0.0, LEAST(10.0, attendance_score + ((id % 5) - 2) * 0.5))
        ELSE 8.0
    END
WHERE regular_score_1 IS NULL;

-- 2. Recalculate end_week for all class_schedules based on total periods (credits * 15)
-- and total periods per week for that class section (sum of end_period - start_period + 1)
WITH section_weekly_periods AS (
    SELECT 
        class_section_id,
        GREATEST(1, SUM(end_period - start_period + 1)) AS weekly_periods
    FROM class_schedules
    GROUP BY class_section_id
)
UPDATE class_schedules cs
SET end_week = cs.start_week + GREATEST(1, CAST(CEIL((c.credits * 15.0) / swp.weekly_periods) AS INT)) - 1
FROM class_sections sec
JOIN courses c ON sec.course_id = c.id
JOIN section_weekly_periods swp ON swp.class_section_id = sec.id
WHERE cs.class_section_id = sec.id;

-- Cap end_week to valid semester bounds (max 52 weeks in academic year)
UPDATE class_schedules
SET end_week = LEAST(end_week, 52);
