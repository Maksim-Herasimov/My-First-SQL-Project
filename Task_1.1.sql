
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