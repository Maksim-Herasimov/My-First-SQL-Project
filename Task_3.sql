WITH base_events AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    user_pseudo_id,
    -- Витягуємо session_id з event_params
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    event_name,
    traffic_source.name AS campaign,
    traffic_source.medium AS medium,
    traffic_source.source AS source
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    event_name IN (
      'session_start',
      'add_to_cart',
      'begin_checkout',
      'purchase'
    )
     GROUP BY
    event_date, source, medium, campaign, user_pseudo_id, session_id, event_name
),
session_flags AS (
  SELECT
    event_date,
    source,
    medium,
    campaign,
    event_name,
    CONCAT(CAST(user_pseudo_id AS STRING), '-', CAST(session_id AS STRING)) AS user_session_id,
  FROM
    base_events
  WHERE
    session_id IS NOT NULL
  GROUP BY
    event_date, source, medium, campaign,  event_name, user_session_id
)
SELECT
  event_date,
  source,
  medium,
  campaign,
  count(distinct user_session_id) as user_sessions_count,
  count(distinct case when event_name = 'add_to_cart' then user_session_id end) as visit_to_cart,
  count(distinct case when event_name = 'begin_checkout' then user_session_id end) as visit_to_checkout,
  count(distinct case when event_name = 'purchase' then user_session_id end) as visit_to_purchase,
FROM
  session_flags
GROUP BY
  event_date, source, medium, campaign
ORDER BY
  event_date, source, medium, campaign