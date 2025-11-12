{{ config(
    materialized='table'
) }}

-- Data mart that ranks products by event frequency over the last 30 days
-- and counts unique schools that had events for each product

WITH product_events AS (
    SELECT * FROM {{ ref('fact_product_events') }}
),

date_dimension AS (
    SELECT * FROM {{ ref('dim_date') }}
),

product_dimension AS (
    SELECT * FROM {{ ref('dim_product') }}
),

student_dimension AS (
    SELECT * FROM {{ ref('dim_student') }}
    WHERE is_current = TRUE  -- Only get current student records
),

-- Filter events to last 30 days
recent_events AS (
    SELECT
        pe.product_key,
        pe.user_key,
        pe.event_id
    FROM product_events pe
    INNER JOIN date_dimension d ON pe.date_key = d.date_key
    WHERE d.date_day >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
      AND d.date_day < CURRENT_DATE()
),

-- Join with user/student to get school information
events_with_schools AS (
    SELECT
        re.product_key,
        re.event_id,
        sd.school_id
    FROM recent_events re
    LEFT JOIN {{ ref('dim_user') }} u ON re.user_key = u.user_key
    LEFT JOIN student_dimension sd ON u.user_id = sd.student_id
),

-- Aggregate by product to get event count and unique schools
product_aggregates AS (
    SELECT
        product_key,
        COUNT(event_id) AS event_count,
        COUNT(DISTINCT school_id) AS total_schools
    FROM events_with_schools
    GROUP BY product_key
),

-- Rank products by event frequency
ranked_products AS (
    SELECT
        p.product_name,
        RANK() OVER (ORDER BY COALESCE(pa.event_count, 0) DESC) AS product_rank,
        COALESCE(pa.total_schools, 0) AS total_schools
    FROM product_dimension p
    LEFT JOIN product_aggregates pa ON p.product_key = pa.product_key
)

SELECT
    product_name,
    product_rank,
    total_schools,

    CURRENT_TIMESTAMP() AS _loaded_at

FROM ranked_products
ORDER BY product_rank
