{{ config(
    materialized='table'
) }}

WITH events_timeframe AS (
    SELECT
        f.user_key,
        f.product_key,
        f.verb_key,
        f.object_key,
        f.event_id,
        d.date_day,
        d.year,
        d.month
    FROM {{ ref('fact_product_events') }} f
    INNER JOIN {{ ref('dim_date') }} d ON f.date_key = d.date_key
)

SELECT
    u.user_id,
    p.product_name,
    v.verb_id,
    o.object_id,
    e.year,
    e.month,
    COUNT(e.event_id) AS event_count,
    COUNT(DISTINCT e.date_day) AS active_days,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM events_timeframe e
INNER JOIN {{ ref('dim_user') }} u ON e.user_key = u.user_key
INNER JOIN {{ ref('dim_product') }} p ON e.product_key = p.product_key
INNER JOIN {{ ref('dim_verb') }} v ON e.verb_key = v.verb_key
INNER JOIN {{ ref('dim_object') }} o ON e.object_key = o.object_key
GROUP BY 1, 2, 3, 4, 5, 6