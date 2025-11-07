{{ config(
    materialized='table'
) }}

WITH events_with_date AS (
    SELECT
        f.user_key,
        f.event_timestamp,
        d.year,
        d.month,
        d.month_name
    FROM {{ ref('fact_product_events') }} f
    INNER JOIN {{ ref('dim_date') }} d ON f.date_key = d.date_key
),

user_monthly_duration AS (
    SELECT
        user_key,
        year,
        month,
        month_name,
        MIN(event_timestamp) AS first_event_timestamp,
        MAX(event_timestamp) AS last_event_timestamp,
        -- Calculate duration in seconds between first and last event for each user per month
        TIMESTAMP_DIFF(MAX(event_timestamp), MIN(event_timestamp), SECOND) AS duration_seconds
    FROM events_with_date
    GROUP BY user_key, year, month, month_name
),

monthly_avg_duration AS (
    SELECT
        year,
        month,
        month_name,
        -- Calculate average duration across all users for each month
        AVG(duration_seconds) AS avg_duration_seconds,
        AVG(duration_seconds) / 60 AS avg_duration_minutes,
        AVG(duration_seconds) / 3600 AS avg_duration_hours,
        AVG(duration_seconds) / 86400 AS avg_duration_days,
        -- Additional metrics
        COUNT(DISTINCT user_key) AS total_users,
        MIN(duration_seconds) AS min_duration_seconds,
        MAX(duration_seconds) AS max_duration_seconds,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM user_monthly_duration
    WHERE duration_seconds > 0  -- Only include users with more than one event
    GROUP BY year, month, month_name
)

SELECT
    year,
    month,
    month_name,
    avg_duration_seconds,
    avg_duration_minutes,
    avg_duration_hours,
    avg_duration_days,
    total_users,
    min_duration_seconds,
    max_duration_seconds,
    _loaded_at
FROM monthly_avg_duration
ORDER BY year, month
