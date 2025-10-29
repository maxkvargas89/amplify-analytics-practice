-- Test: Daily active users should be between 1 and 10
-- (For a small test dataset)

SELECT
  activity_date,
  COUNT(DISTINCT student_id) as daily_active_users
FROM {{ ref('fact_student_activity') }}
GROUP BY activity_date
HAVING 
  COUNT(DISTINCT student_id) < 1  -- Too few
  OR COUNT(DISTINCT student_id) > 10  -- Too many