SELECT * FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_20210131` LIMIT 100;

SELECT TIMESTAMP_MICROS(event_timestamp) AS event_timestamp
     , user_pseudo_id
     , (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') as ga_session_id
     , event_name
     , geo.country
     , device. category as device_cetegory
     , traffic_source. source
     , traffic_source. medium
     , traffic_source. name
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*` 
 WHERE event_name IN (
    'session_start',
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_shipping_info',
    'add_payment_info',
    'purchase') AND _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
 LIMIT 100;
