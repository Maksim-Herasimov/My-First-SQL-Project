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