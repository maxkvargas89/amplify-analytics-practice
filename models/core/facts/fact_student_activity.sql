{{
  config(
    materialized='incremental',
    unique_key='activity_key',
    on_schema_change='fail'
  )
}}

WITH student_events AS (
  SELECT * FROM {{ ref('stg_student_events') }}
  
  {% if is_incremental() %}
    WHERE event_date > (SELECT MAX(activity_date) FROM {{ this }})
  {% endif %}
),

daily_activity AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['student_id', 'event_date']) }} AS activity_key,
    
    student_id,
    event_date AS activity_date,
    school_id,
    
    -- Activity metrics
    COUNT(*) AS total_events,
    COUNT(DISTINCT learning_unit_id) AS unique_units_accessed,
    
    -- Event type breakdown
    COUNTIF(event_type = 'lesson_start') AS lesson_starts,
    COUNTIF(event_type = 'lesson_complete') AS lesson_completes,
    COUNTIF(event_type = 'problem_attempt') AS problem_attempts,
    COUNTIF(event_type = 'help_requested') AS help_requests,
    
    -- Problem attempt metrics (only for problem_attempt events)
    COUNTIF(event_type = 'problem_attempt' AND problem_correct = TRUE) AS problems_correct,
    SAFE_DIVIDE(
      COUNTIF(event_type = 'problem_attempt' AND problem_correct = TRUE),
      COUNTIF(event_type = 'problem_attempt')
    ) AS accuracy_rate,
    
    AVG(CASE WHEN event_type = 'problem_attempt' THEN problem_time_seconds END) AS avg_problem_time_seconds,
    
    -- Engagement indicators
    TIMESTAMP_DIFF(MAX(event_timestamp), MIN(event_timestamp), MINUTE) AS session_duration_minutes,
    
    -- Metadata
    MIN(event_timestamp) AS first_activity_timestamp,
    MAX(event_timestamp) AS last_activity_timestamp,
    CURRENT_TIMESTAMP() AS _loaded_at
    
  FROM student_events
  GROUP BY student_id, event_date, school_id
)

SELECT * FROM daily_activity