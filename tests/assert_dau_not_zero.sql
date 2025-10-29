-- Test: Today's DAU should not be 0
-- (Catches upstream pipeline failures)

WITH today_dau AS (
  SELECT COUNT(DISTINCT student_id) as dau
  FROM {{ ref('fact_student_activity') }}
  WHERE activity_date = CURRENT_DATE()
)

SELECT *
FROM today_dau
WHERE dau = 0  -- Fail if no activity today