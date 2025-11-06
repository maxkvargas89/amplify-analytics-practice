{{ config(
    materialized='table'
) }}

WITH unique_users AS (
    SELECT DISTINCT
        user_id
    FROM {{ ref('stg_product_events_union') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['user_id']) }} AS user_key,
    user_id,
    
    CURRENT_TIMESTAMP() AS _loaded_at

FROM unique_users