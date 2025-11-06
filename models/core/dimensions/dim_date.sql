{{
  config(
    materialized='table'
  )
}}

WITH date_spine AS (
  SELECT 
    DATE_ADD('2023-01-01', INTERVAL day_offset DAY) AS date_day
  FROM UNNEST(GENERATE_ARRAY(0, 364)) AS day_offset
),

date_attributes AS (
  SELECT
    CAST(FORMAT_DATE('%Y%m%d', date_day) AS INT64) AS date_key,

    date_day,
    
    EXTRACT(YEAR FROM date_day) AS year,
    EXTRACT(MONTH FROM date_day) AS month,
    EXTRACT(DAY FROM date_day) AS day_of_month,
    EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
    FORMAT_DATE('%A', date_day) AS day_name,
    FORMAT_DATE('%B', date_day) AS month_name,
    EXTRACT(QUARTER FROM date_day) AS quarter,
    
    CASE 
      WHEN EXTRACT(MONTH FROM date_day) >= 8 THEN EXTRACT(YEAR FROM date_day)
      ELSE EXTRACT(YEAR FROM date_day) - 1
    END AS school_year,
    
    -- Semester (Fall = Aug-Dec, Spring = Jan-May, Summer = Jun-Jul)
    CASE
      WHEN EXTRACT(MONTH FROM date_day) BETWEEN 8 AND 12 THEN 'Fall'
      WHEN EXTRACT(MONTH FROM date_day) BETWEEN 1 AND 5 THEN 'Spring'
      ELSE 'Summer'
    END AS semester,
    
    -- Is this a school day? (Mon-Fri, excluding major holidays)
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN FALSE  -- Weekend (Sunday=1, Saturday=7)
      -- Exclude major holidays (Thanksgiving, Winter Break, New Year's)
      WHEN date_day IN (
        '2024-11-28', '2024-11-29',  -- Thanksgiving
        '2024-12-23', '2024-12-24', '2024-12-25', '2024-12-26', '2024-12-27', '2024-12-30', '2024-12-31',  -- Winter break
        '2025-01-01'  -- New Year's
      ) THEN FALSE
      ELSE TRUE
    END AS is_school_day,
    
    -- Week of school year (starting from first day of school)
    DATE_DIFF(
      date_day, 
      DATE('2024-08-15'),  -- First day of school in our data
      WEEK
    ) + 1 AS week_of_school_year
    
  FROM date_spine
)

SELECT * FROM date_attributes