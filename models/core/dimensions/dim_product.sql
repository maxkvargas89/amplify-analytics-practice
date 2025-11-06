{{ config(
    materialized='table'
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['product']) }} AS product_key,
    product AS product_id,
    
    CASE 
        WHEN product = 'ela' THEN 'English Language Arts'
        WHEN product = 'science' THEN 'Science'
    END AS product_name,
    
    CURRENT_TIMESTAMP() AS _loaded_at

FROM (
    SELECT DISTINCT product 
    FROM {{ ref('stg_product_events_union') }}
)