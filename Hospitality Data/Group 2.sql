Create database Group2;
-- 1. KPI’s Total Revenue Generated , Total revenue Realized , Total Bookings , Total Checked Out, Total Cancelled Bookings
SELECT 
    CONCAT(ROUND(SUM(revenue_generated)/1000000, 2), ' M') AS `Total Revenue Generated`,
    CONCAT(ROUND(SUM(revenue_realized)/1000000, 2), ' M') AS `Total Revenue Realized`,
    CONCAT(ROUND(COUNT(booking_id)/1000, 2), ' K') AS `Total Bookings`,
    CONCAT(ROUND(COUNT(CASE WHEN booking_status = 'Checked Out' THEN booking_id END)/1000, 2), ' K') AS `Total Succesfull Bookings`,
    CONCAT(ROUND(COUNT(CASE WHEN booking_status = 'Cancelled' THEN booking_id END)/1000, 2), ' K') AS `Total Cancelled Booking`
FROM fact_bookings;

-- 2. Booking Status
SELECT  
  COUNT(CASE WHEN booking_status = 'Cancelled' THEN 1 END) AS total_cancelled_bookings,
  COUNT(CASE WHEN booking_status = 'Checked Out' THEN 1 END) AS total_checked_out,
  COUNT(CASE WHEN booking_status = 'No Show' THEN 1 END) AS total_no_show_bookings
FROM fact_bookings;

-- 3. Total Successful Bookings By category
SELECT dh.category, SUM(fa.successful_bookings) AS total_successful_bookings
FROM fact_aggregated_bookings fa 
INNER JOIN dim_hotels dh ON fa.property_id = dh.property_id
GROUP BY dh.category;

-- 4. Day Type wise Total Revenue & Total succesfull Bookings ***********
select d.day_type,
CONCAT(ROUND(SUM(fb.revenue_realized)/1000000, 2), ' M') AS `Total Revenue Realized`, 
CONCAT(ROUND(COUNT(CASE WHEN fb.booking_status = 'Checked Out' THEN fb.booking_id END)/1000, 2), ' K') AS `Total Succesfull Bookings`
from dim_date d join fact_bookings fb on fb.check_in_date=d.date group by d.day_type;

-- 5. City Wise Total Revenue
SELECT city,
CONCAT(ROUND(SUM(fb.revenue_realized)/1000000, 2), ' M') AS `Total Revenue Realized`, 
DENSE_RANK() OVER (ORDER BY SUM(fb.revenue_realized) DESC) AS `Revenue Rank`
FROM dim_hotels h JOIN fact_bookings fb ON fb.property_id = h.property_id GROUP BY city;

-- 6. Booking platform wise Total Revenue
SELECT booking_platform,
CONCAT(ROUND(SUM(revenue_realized)/1000000, 2), ' M') AS `Total Revenue` FROM fact_bookings
GROUP BY booking_platform
ORDER BY SUM(revenue_realized) DESC;

-- 7. Week wise total Bookings and Total Revenue  *****
WITH weekly_data AS ( SELECT d.wn,
SUM(fb.revenue_realized) AS total_revenue FROM dim_date d
JOIN fact_bookings fb ON fb.check_in_date = d.date GROUP BY d.wn)
SELECT wn,
CONCAT(ROUND(total_revenue / 1000000, 2), ' M') AS `Total Revenue Realized`, CONCAT(ROUND(
(total_revenue - LAG(total_revenue) OVER (ORDER BY wn))
/ NULLIF(LAG(total_revenue) OVER (ORDER BY wn), 0) * 100,	2), ' %') AS `WoW % Change in Revenue`FROM weekly_data;

-- 8. Revenue by property name and city where rating > 3
select dh.property_name,dh.city,fb.revenue_realized,fb.ratings_given from dim_hotels dh inner join fact_bookings fb
on dh.property_id=fb.property_id where fb.ratings_given > 3;

-- 9. Room Catgory Wise Total Capacity 
SELECT 
    room_category,
    CONCAT(ROUND(SUM(capacity)/1000, 2), ' K') AS `Total Capacity`
FROM fact_aggregated_bookings 
GROUP BY room_category;

-- 10. week wise total Bookings and Total Revenue *****
select d.wn,
CONCAT(ROUND(SUM(fb.revenue_realized)/1000000, 2), ' M') AS `Total Revenue Realized`,
CONCAT(ROUND(COUNT(CASE WHEN fb.booking_status = 'Checked Out' THEN fb.booking_id END)/1000, 2), ' K') AS `Total Succesfull Bookings`
from dim_date as d
join
fact_bookings fb
On
fb.check_in_date = d.date
group by d.wn;

-- 11. Hotel wise Total Revenue
SELECT
h.property_name,
CONCAT(ROUND(SUM(fb.revenue_realized)/1000000, 2), ' M') AS `Total Revenue Realized`,
CONCAT(ROUND(COUNT(CASE WHEN fb.booking_status = 'Checked Out' THEN fb.booking_id END)/1000, 2), ' K') AS `Total Succesfull Bookings`,
DENSE_RANK() OVER (ORDER BY SUM(fb.revenue_realized) DESC) AS `Revenue Rank`
FROM dim_hotels h
JOIN fact_bookings fb ON fb.property_id = h.property_id GROUP BY h.property_name;

-- 12. Top 5 hotels by revenue
SELECT distinct dh.property_name, dh.city,fb.revenue_realized
FROM dim_hotels dh INNER JOIN fact_bookings fb ON dh.property_id = fb.property_id ORDER BY fb.revenue_realized DESC LIMIT 5;