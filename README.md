## This is my first project created with the support of GoIT school.

# :chart_with_upwards_trend: Ecommerce Behavior Lab

### This project was created using data from the training database provided as part of the course. The source of information is advertising campaigns in Google Ads and Facebook Ads, as well as behavioral data from Google Analytics 4 in BigQuery. 

:raising_hand: My name is Maxim, and I specialize in data analytics, specifically working with PostgreSQL, BigQuery, and Looker Studio.
 The topic of my work is the creation of interactive dashboards based on two different data sources: Google Ads and Facebook Ads marketing campaigns, as well as behavioral data from Google Analytics 4. The goal of the project is to demonstrate the full cycle of working with data: from preparation and processing in SQL to visualization and forming business conclusions.
 
For the robot, I used two data sets:

:heavy_minus_sign:Marketing data from Google Ads and Facebook Ads campaigns, including information on costs, ROMI, reach, duration of impressions, and campaign effectiveness.
  
:heavy_minus_sign:GA4 behavioral data, which included information about user devices, geography, event types, traffic sources, and conversion actions.

Data processing was performed in PostgreSQL and BigQuery using SQL queries for aggregations, filtering, metric calculations, and intermediate table construction.

Key tasks and analytics
 
 :heavy_minus_sign:Aggregations were performed to calculate average, minimum, and maximum costs, as well as ROMI by date.
 
 :heavy_minus_sign:A comparison was made of the effectiveness of campaigns in terms of coverage, duration of impressions, and value to the company.

<details>
<summary>Query 1.1 PostgeSQL</summary>

 ```bash
  with ads as (
select ad_date
      , 'Facebook' as media_source
      , coalesce(spend,0) as spend
  from facebook_ads_basic_daily
 union all
select ad_date
      , 'Google' as media_source
      , coalesce(spend,0) as spend
  from google_ads_basic_daily
  )
select ad_date
     , media_source
     , ROUND(AVG(spend),2) as avg_spend, ROUND(MAX(spend),2) as max_spend, ROUND(MIN(spend),2) as min_spend
  from ads
 group by ad_date, media_source
```    
</details>

<details>
<summary>Query 1.2 PostgeSQL</summary>

 ```bash
  with ads as(
select ad_date
     , spend 
     , value
  from facebook_ads_basic_daily
 union all 
select ad_date
     , spend 
     , value
  from google_ads_basic_daily 
  )
select ad_date
     , CASE
         WHEN SUM(spend) > 0
         THEN ROUND(((SUM(value) - SUM(spend)::numeric) / SUM(spend))*100, 2)
         ELSE 0
       END AS romi
  from ads
 group by ad_date 
 order by romi desc
 limit 5
```
</details>

 <details>
<summary>Query 1.3 PostgeSQL</summary>

 ```bash
  with ads as(
select date(date_trunc('week', ad_date)) as week_date
     , fc.campaign_name
     , value
  from facebook_ads_basic_daily as fa
  left join facebook_campaign as fc
    on fa.campaign_id = fc.campaign_id
 union all 
select date(date_trunc('week', ad_date)) as week_date
     , campaign_name 
     , value
  from google_ads_basic_daily 
  )
select week_date
     , campaign_name
     , sum(value) as value
  from ads
 where campaign_name is not null
 group by week_date, campaign_name
 order by value desc 
 limit 1
```
</details>

<details>
<summary>Query 1.4 PostgeSQL</summary>

 ```bash
  with ads as(
select date(date_trunc('month', ad_date)) as month_date
     , fc.campaign_name
     , sum(reach) as reach
  from facebook_ads_basic_daily as fa
  left join facebook_campaign as fc
    on fa.campaign_id = fc.campaign_id
 group by month_date, campaign_name 
 union all 
select date(date_trunc('month', ad_date)) as month_date
     , campaign_name 
     , sum(reach) as reach
  from google_ads_basic_daily 
 group by month_date, campaign_name 
  ), reach_per_month as(
select month_date
     , campaign_name
     , sum(reach) as reach
     , LAG(sum(reach), 1) OVER (PARTITION BY campaign_name ORDER BY month_date) as diff
     , ABS(sum(reach) - LAG(sum(reach), 1) OVER (PARTITION BY campaign_name ORDER BY month_date)) AS cur_prev_diff 
  from ads 
 where campaign_name is not null 
 group by month_date, campaign_name 
)     
select month_date
     , campaign_name
     , reach
     , diff
     , cur_prev_diff 
  from reach_per_month
 where diff is not null
 order by cur_prev_diff desc
 limit 1
 ```
</details>

<details>
<summary>Query 1.5 PostgeSQL</summary>

 ```bash
with ads as(
select ad_date
     , fa.adset_name
  from facebook_ads_basic_daily as fabd
  left join facebook_adset as fa
    on fabd.adset_id = fa.adset_id
 where ad_date is not null
 union all 
select ad_date
     , adset_name 
  from google_ads_basic_daily
 where ad_date is not null)
 , filtered AS (
  SELECT 
    adset_name,
    ad_date
  FROM ads
),
numbered AS (
  SELECT 
    adset_name,
    ad_date,
    ROW_NUMBER() OVER (PARTITION BY adset_name ORDER BY ad_date) AS rn
  FROM filtered
),
grouped AS (
  SELECT 
    adset_name,
    ad_date,
    rn,
    ad_date - rn * INTERVAL '1 day' AS grp_key
  FROM numbered
),
sequences AS (
  SELECT 
    adset_name,
    MIN(ad_date) AS start_date,
    MAX(ad_date) AS end_date,
    COUNT(grp_key) AS duration_days
  FROM grouped
  GROUP BY adset_name, grp_key
)
SELECT 
  adset_name,
  start_date,
  end_date,
  duration_days
FROM sequences
order by duration_days desc
LIMIT 1;
```
</details>
 
:heavy_minus_sign:For behavioral data, a conversion funnel was constructed from the start of the session to the purchase.

<details>
 <summary>Query 2 BigQuery</summary>
 
```bash
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
 ```
</details>

<details>
<summary>Query 3 BigQuery</summary>
 
```bash
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
```
</details>

 <details>
 <summary>Query 4 BigQuery</summary>

  ```bash
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
```
</details>

:heavy_minus_sign:The structure of the queries was modular: first, basic samples were formed, then metrics were calculated, and finally, data was prepared for visualization.
