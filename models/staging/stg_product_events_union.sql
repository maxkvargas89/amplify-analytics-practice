{{ config(
    materialized='view'
) }}

SELECT * FROM {{ ref('stg_product_events_ela') }}
UNION ALL
SELECT * FROM {{ ref('stg_product_events_science') }}