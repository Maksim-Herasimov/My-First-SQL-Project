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