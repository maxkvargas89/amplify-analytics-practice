{{
  config(
    materialized='incremental',
    unique_key='progress_key',
    on_schema_change='fail'
  )
}}

WITH source AS (
  SELECT * FROM {{ source('raw_data', 'student_learning_progress') }}
  
  {% if is_incremental() %}
    WHERE progress_date > (SELECT MAX(progress_date) FROM {{ this }})
  {% endif %}
),

progress_with_key AS (
  SELECT
    {{ dbt_utils.generate_surrogate_key(['student_id', 'learning_unit_id', 'progress_date']) }} AS progress_key,
    
    student_id,
    learning_unit_id,
    progress_date,
    mastery_status,
    attempts_count,
    accuracy_rate,
    
    mastery_status = 'mastered' AS is_mastered,
    mastery_status = 'in_progress' AS is_in_progress,
    mastery_status = 'not_started' AS is_not_started,
    
    CURRENT_TIMESTAMP() AS _loaded_at
    
  FROM source
)

SELECT * FROM progress_with_key