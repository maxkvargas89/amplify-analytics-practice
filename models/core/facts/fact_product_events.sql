{{
    config(
        materialized='incremental',
        unique_key='event_id',
        on_schema_change='fail',
        partition_by={
            "field": "event_date",
            "data_type": "date",
            "granularity": "day"
        }
    )
}}

WITH events AS (
    SELECT * FROM {{ ref('stg_product_events_union') }}
    
    {% if is_incremental() %}
    WHERE event_timestamp > (SELECT MAX(event_timestamp) FROM {{ this }})
    {% endif %}
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['e.event_id']) }} AS event_key,
    
    {{ dbt_utils.generate_surrogate_key(['e.user_id']) }} AS user_key,
    {{ dbt_utils.generate_surrogate_key(['e.product']) }} AS product_key,
    {{ dbt_utils.generate_surrogate_key(['e.verb']) }} AS verb_key,
    {{ dbt_utils.generate_surrogate_key(['e.object']) }} AS object_key,
    CAST(FORMAT_DATE('%Y%m%d', e.event_date) AS INT64) AS date_key,
    
    e.event_id,
    e.event_timestamp,
    e.event_date,
    
    e._loaded_at

FROM events e