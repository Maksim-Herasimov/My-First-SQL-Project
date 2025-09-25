## This is my first project created with the support of GoIT school.

# :chart_with_upwards_trend: Ecommerce Behavior Lab

### This project was created using data from the training database provided as part of the course. The source of information is advertising campaigns in Google Ads and Facebook Ads, as well as behavioral data from Google Analytics 4 in BigQuery. 

:raising_hand: My name is Maxim, and I specialize in data analytics, specifically working with PostgreSQL, BigQuery, and Looker Studio.
 The topic of my work is the creation of interactive dashboards based on two different data sources: Google Ads and Facebook Ads marketing campaigns, as well as behavioral data from Google Analytics 4. The goal of the project is to demonstrate the full cycle of working with data: from preparation and processing in SQL to visualization and forming business conclusions.
 
For the robot, I used two data sets:

-Marketing data from Google Ads and Facebook Ads campaigns, including information on costs, ROMI, reach, duration of impressions, and campaign effectiveness.
<details>
<summary>Task 1</summary>
  [task_1_1](.My-First-SQL-Project/Task_1.1)
</details>
-GA4 behavioral data, which included information about user devices, geography, event types, traffic sources, and conversion actions.

Data processing was performed in PostgreSQL and BigQuery using SQL queries for aggregations, filtering, metric calculations, and intermediate table construction.

Key tasks and analytics
 -Aggregations were performed to calculate average, minimum, and maximum costs, as well as ROMI by date.
 
 -A comparison was made of the effectiveness of campaigns in terms of coverage, duration of impressions, and value to the company.
 
 -For behavioral data, a conversion funnel was constructed from the start of the session to the purchase.
 
 -The structure of the queries was modular: first, basic samples were formed, then metrics were calculated, and finally, data was prepared for visualization.
