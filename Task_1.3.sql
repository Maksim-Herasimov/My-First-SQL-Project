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