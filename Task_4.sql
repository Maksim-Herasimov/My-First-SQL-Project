WITH session_start_events AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    -- Витягуємо page_path з page_location
    REGEXP_EXTRACT(
      (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'page_location'),
      r'^https?://[^/]+(/[^?#]*)'
    ) AS page_path
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
    AND event_name = 'session_start'
),
purchase_events AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE
    _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
    AND event_name = 'purchase'
),
joined_sessions AS (
  SELECT
    s.page_path,
    s.user_pseudo_id,
    s.session_id,
    IF(p.session_id IS NOT NULL, 1, 0) AS has_purchase
  FROM
    session_start_events s
  LEFT JOIN
    purchase_events p
  ON
    s.user_pseudo_id = p.user_pseudo_id
    AND s.session_id = p.session_id
  WHERE
    s.session_id IS NOT NULL
)
SELECT
  page_path,
  COUNT(DISTINCT CONCAT(user_pseudo_id, '-', session_id)) AS unique_sessions,
  COUNTIF(has_purchase = 1) AS purchases,
  SAFE_DIVIDE(COUNTIF(has_purchase = 1), COUNT(DISTINCT CONCAT(user_pseudo_id, '-', session_id))) AS conversion_rate
FROM
  joined_sessions
GROUP BY
  page_path
ORDER BY
  unique_sessions DESC