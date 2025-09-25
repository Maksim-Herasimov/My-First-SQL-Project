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
   