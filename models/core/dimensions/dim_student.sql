{{
  config(
    materialized='table',
    unique_key='student_key'
  )
}}

WITH student_roster AS (
  SELECT * FROM {{ ref('stg_student_roster') }}
),

student_with_key AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['student_id', 'effective_date']) }} AS student_key,
    
    student_id,
    full_name,
    first_name,
    last_name,
    school_id,
    grade_level,
    special_education,
    ethnicity,
    
    effective_date,
    end_date,
    is_current,
    
    _loaded_at
    
  FROM student_roster
)

SELECT * FROM student_with_key