{{
  config(
    materialized='table'
  )
}}

WITH student_activity AS (
  SELECT * FROM {{ ref('fact_student_activity') }}
),

learning_progress AS (
  SELECT * FROM {{ ref('fact_learning_progress') }}
),

students AS (
  SELECT * FROM {{ ref('dim_student') }}
  WHERE is_current = TRUE  -- Only current student records (handles transfers)
),

schools AS (
  SELECT * FROM {{ ref('dim_school') }}
),

learning_units AS (
  SELECT * FROM {{ ref('dim_learning_unit') }}
),

dates AS (
  SELECT * FROM {{ ref('dim_date') }}
),

-- Aggregate student activity over time
student_activity_summary AS (
  SELECT
    student_id,
    COUNT(DISTINCT activity_date) AS days_active,
    SUM(total_events) AS total_events_all_time,
    AVG(accuracy_rate) AS avg_accuracy_rate,
    SUM(lesson_completes) AS total_lessons_completed,
    SUM(problem_attempts) AS total_problems_attempted,
    MIN(activity_date) AS first_active_date,
    MAX(activity_date) AS last_active_date,
    DATE_DIFF(MAX(activity_date), MIN(activity_date), DAY) + 1 AS days_since_first_activity
    
  FROM student_activity
  GROUP BY student_id
),

-- Aggregate learning progress
student_progress_summary AS (
  SELECT
    student_id,
    COUNT(DISTINCT learning_unit_id) AS total_units_attempted,
    COUNTIF(is_mastered) AS units_mastered,
    COUNTIF(is_in_progress) AS units_in_progress,
    SAFE_DIVIDE(COUNTIF(is_mastered), COUNT(DISTINCT learning_unit_id)) AS mastery_rate,
    AVG(accuracy_rate) AS avg_unit_accuracy
    
  FROM learning_progress
  GROUP BY student_id
),

-- Recent activity (last 7 days)
recent_activity AS (
  SELECT
    student_id,
    COUNT(DISTINCT activity_date) AS days_active_last_7,
    SUM(total_events) AS events_last_7,
    AVG(accuracy_rate) AS accuracy_last_7
    
  FROM student_activity
  WHERE activity_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  GROUP BY student_id
),

-- Combine everything
final AS (
  SELECT
    -- Student identifiers
    s.student_id,
    s.full_name,
    s.grade_level,
    
    -- School context
    s.school_id,
    sch.school_name,
    sch.school_type,
    sch.poverty_level,
    
    -- Student attributes
    s.special_education,
    s.ethnicity,
    
    -- Overall activity metrics
    COALESCE(sa.days_active, 0) AS days_active,
    COALESCE(sa.total_events_all_time, 0) AS total_events,
    sa.avg_accuracy_rate,
    COALESCE(sa.total_lessons_completed, 0) AS lessons_completed,
    COALESCE(sa.total_problems_attempted, 0) AS problems_attempted,
    sa.first_active_date,
    sa.last_active_date,
    sa.days_since_first_activity,
    
    -- Learning progress metrics
    COALESCE(sp.total_units_attempted, 0) AS units_attempted,
    COALESCE(sp.units_mastered, 0) AS units_mastered,
    COALESCE(sp.units_in_progress, 0) AS units_in_progress,
    sp.mastery_rate,
    sp.avg_unit_accuracy,
    
    -- Recent activity (engagement indicator)
    COALESCE(ra.days_active_last_7, 0) AS days_active_last_7,
    COALESCE(ra.events_last_7, 0) AS events_last_7,
    ra.accuracy_last_7,
    
    -- Engagement classification
    CASE
      WHEN COALESCE(ra.days_active_last_7, 0) >= 5 THEN 'highly_engaged'
      WHEN COALESCE(ra.days_active_last_7, 0) >= 3 THEN 'moderately_engaged'
      WHEN COALESCE(ra.days_active_last_7, 0) >= 1 THEN 'low_engagement'
      ELSE 'inactive'
    END AS engagement_level,
    
    -- Progress classification (relative to grade-level expectations)
    CASE
      WHEN sp.mastery_rate >= 0.8 THEN 'on_track'
      WHEN sp.mastery_rate >= 0.5 THEN 'needs_support'
      ELSE 'at_risk'
    END AS progress_status,
    
    -- Activation status (has student completed first lesson?)
    COALESCE(sa.total_lessons_completed, 0) > 0 AS is_activated,
    
    CURRENT_TIMESTAMP() AS _loaded_at
    
  FROM students s
  LEFT JOIN schools sch ON s.school_id = sch.school_id
  LEFT JOIN student_activity_summary sa ON s.student_id = sa.student_id
  LEFT JOIN student_progress_summary sp ON s.student_id = sp.student_id
  LEFT JOIN recent_activity ra ON s.student_id = ra.student_id
)

SELECT * FROM final