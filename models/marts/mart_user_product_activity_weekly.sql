{{ config(
    materialized='table'
) }}

WITH events_last_week AS (
    SELECT
        f.user_key,
        f.product_key,
        f.event_id,
        f.event_date
    FROM {{ ref('fact_product_events') }} f
    INNER JOIN {{ ref('dim_date') }} d ON f.date_key = d.date_key
    WHERE d.date_day >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
      AND d.date_day < CURRENT_DATE()
),

user_product_summary AS (
    SELECT
        u.user_id,
        p.product_name,
        COUNT(e.event_id) AS event_count,
        MIN(e.event_date) AS first_event_date,
        MAX(e.event_date) AS last_event_date
    FROM events_last_week e
    INNER JOIN {{ ref('dim_user') }} u ON e.user_key = u.user_key
    INNER JOIN {{ ref('dim_product') }} p ON e.product_key = p.product_key
    GROUP BY 1, 2
)

SELECT
    *,
    CASE WHEN event_count > 5 THEN TRUE ELSE FALSE END AS is_active_user,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM user_product_summary