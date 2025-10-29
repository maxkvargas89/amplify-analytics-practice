-- Test: No student should have mastery_rate > 1.0 or < 0

SELECT
  student_id,
  mastery_rate
FROM {{ ref('mart_student_progress') }}
WHERE 
  mastery_rate > 1.0
  OR mastery_rate < 0
  OR mastery_rate IS NULL