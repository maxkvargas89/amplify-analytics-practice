{{ config(
    materialized='table'
) }}

WITH unique_verbs AS (
    SELECT DISTINCT verb
    FROM {{ ref('stg_product_events_union') }}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['verb']) }} AS verb_key,
    verb AS verb_id,
    
    CURRENT_TIMESTAMP() AS _loaded_at

FROM unique_verbs