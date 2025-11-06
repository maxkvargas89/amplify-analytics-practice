{{ config(
    materialized='table'
) }}

WITH unique_objects AS (
    SELECT DISTINCT object
    FROM {{ ref('stg_product_events_union') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['object']) }} AS object_key,
    object AS object_id,
    
    CURRENT_TIMESTAMP() AS _loaded_at

FROM unique_objects
