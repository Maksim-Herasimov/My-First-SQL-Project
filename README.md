## This is my first project created with the support of GoIT school.

# :chart_with_upwards_trend: Ecommerce Behavior Lab

### This project was created using data from the training database provided as part of the course. The source of information is advertising campaigns in Google Ads and Facebook Ads, as well as behavioral data from Google Analytics 4 in BigQuery. 

:raising_hand: My name is Maxim, and I specialize in data analytics, specifically working with PostgreSQL, BigQuery, and Looker Studio.
 The topic of my work is the creation of interactive dashboards based on two different data sources: Google Ads and Facebook Ads marketing campaigns, as well as behavioral data from Google Analytics 4. The goal of the project is to demonstrate the full cycle of working with data: from preparation and processing in SQL to visualization and forming business conclusions.
 
For the robot, I used two data sets:

-Marketing data from Google Ads and Facebook Ads campaigns, including information on costs, ROMI, reach, duration of impressions, and campaign effectiveness.
  
-GA4 behavioral data, which included information about user devices, geography, event types, traffic sources, and conversion actions.

Data processing was performed in PostgreSQL and BigQuery using SQL queries for aggregations, filtering, metric calculations, and intermediate table construction.

Key tasks and analytics
 -Aggregations were performed to calculate average, minimum, and maximum costs, as well as ROMI by date.

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
 -A comparison was made of the effectiveness of campaigns in terms of coverage, duration of impressions, and value to the company.
 
 -For behavioral data, a conversion funnel was constructed from the start of the session to the purchase.

 :white_check_mark:[BigQuery Task 2](./Task_2.sql)

 :white_check_mark:[BigQuery Task 3](./Task_3.sql)

  :white_check_mark:[BigQuery Task 4](./Task_4.sql)
 
 -The structure of the queries was modular: first, basic samples were formed, then metrics were calculated, and finally, data was prepared for visualization.
