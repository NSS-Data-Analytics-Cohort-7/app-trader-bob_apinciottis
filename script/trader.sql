select distinct name, a.rating as a_rating, p.rating as p_rating, a.rating+p.rating as total_rating, genres, primary_genre, p.price as play_price, a.price as a_price
from play_store_apps as p
inner join app_store_apps as a
using(name)
where p.rating >= 4.5
and a.rating >= 4.5
and p.review_count > 25000
order by total_rating desc
limit 10;
-- "PewDiePie's Tuber Simulator" "ASOS" "Cytus" "Domino's Pizza USA" "Egg, Inc." "The Guardian" "Geometry Dash Lite" "Fernanfloo" "Bible" "Five Nights at Freddy's 3"

select genres, category, avg(rating) as avg_rating
from play_store_apps
where rating is not null
group by genres, category
order by avg_rating desc;
--6 of the top 10 rated play store apps are in the family category, some type of game

select primary_genre, avg(rating) as avg_rating
from app_store_apps
where rating is not null
group by primary_genre
order by avg_rating desc;
/* "Productivity"	4.0056179775280899
"Music"	3.9782608695652174
"Photo & Video"	3.8008595988538682
"Business"	3.7456140350877193
"Health & Fitness"	3.7000000000000000 */

select content_rating, cast(avg(a.rating) as numeric) as a_rating
from app_store_apps as a
group by content_rating
order by a_rating desc;
/* "9+"	3.7695035460992908
   "4+"	3.5701556508008121
  "12+"	3.5666666666666667
  "17+"	2.7604501607717042 */
select content_rating, avg(rating) as avg_rating
from play_store_apps
group by content_rating
order by avg_rating desc;
/* "Adults only 18+" 4.3000000000000000
  "Everyone 10+" 4.2571788413098237
  "Teen" 4.2334870848708487
  "Everyone" 4.1863746630727763
  "Mature 17+" 4.1234273318872017
  "Unrated"	4.1000000000000000 */
  
 WITH price_table as 
   (SELECT DISTINCT name,
    CASE 
        WHEN money(p.price) = money(0) THEN money(1)
        ELSE money(p.price) 
    END as play_price, 
    CASE 
        WHEN money(a.price) = money(0) THEN money(1)
        ELSE money(a.price) 
    END as apple_price
    FROM play_store_apps as p
    INNER JOIN app_store_apps as a USING(name)),
    
    ad_cost AS(
     SELECT name, money(((ROUND((AVG((a.rating+p.rating)/2)/.5))+1)*12)*1000) as ad_cost
    FROM play_store_apps as p
    INNER JOIN app_store_apps as a USING(name)
    GROUP BY name
    ORDER BY ad_cost DESC),
    
    revenue AS(
    SELECT name, money(((ROUND((AVG((a.rating+p.rating)/2)/.5))+1)*12)*5000) as revenue
    FROM play_store_apps as p
    INNER JOIN app_store_apps as a USING(name)
    GROUP BY name
    ORDER BY revenue DESC)
    
SELECT DISTINCT category, SUM(((apple_price + play_price) * 10000)) as purchase_price, SUM(money(r.revenue - (((apple_price + play_price) * 10000) +a2.ad_cost))) AS profit,
 ROUND(SUM(money(r.revenue - (((apple_price + play_price) * 10000) +a2.ad_cost)))/SUM(((apple_price + play_price) * 10000))*100) as percent_return
FROM play_store_apps as p
INNER JOIN app_store_apps as a USING(name)
INNER JOIN price_table as p2 USING(name)
INNER JOIN ad_cost as a2 USING(name)
INNER JOIN revenue as r USING (name)
WHERE p.review_count >50000
and CAST(a.review_count as int)>50000
group by category
ORDER BY percent_return desc;

--Seeing which category yields the highest percent return for apps

WITH price_table as 
   (SELECT DISTINCT name,
    CASE 
        WHEN money(p.price) = money(0) THEN money(1)
        ELSE money(p.price) 
    END as play_price, 
    CASE 
        WHEN money(a.price) = money(0) THEN money(1)
        ELSE money(a.price) 
    END as apple_price
    FROM play_store_apps as p
    INNER JOIN app_store_apps as a USING(name)),
    
    ad_cost AS(
     SELECT name, money(((ROUND((AVG((a.rating+p.rating)/2)/.5))+1)*12)*1000) as ad_cost
    FROM play_store_apps as p
    INNER JOIN app_store_apps as a USING(name)
    GROUP BY name
    ORDER BY ad_cost DESC),
    
    revenue AS(
    SELECT name, money(((ROUND((AVG((a.rating+p.rating)/2)/.5))+1)*12)*5000) as revenue
    FROM play_store_apps as p
    INNER JOIN app_store_apps as a USING(name)
    GROUP BY name
    ORDER BY revenue DESC)
    
SELECT DISTINCT primary_genre, SUM(((apple_price + play_price) * 10000)) as purchase_price, SUM(money(r.revenue - (((apple_price + play_price) * 10000) +a2.ad_cost))) AS profit,
 ROUND(SUM(money(r.revenue - (((apple_price + play_price) * 10000) +a2.ad_cost)))/SUM(((apple_price + play_price) * 10000))*100) as percent_return
FROM app_store_apps as a
INNER JOIN play_store_apps as p USING(name)
INNER JOIN price_table as p2 USING(name)
INNER JOIN ad_cost as a2 USING(name)
INNER JOIN revenue as r USING (name)
WHERE p.review_count >50000
and CAST(a.review_count as int)>50000
group by primary_genre
ORDER BY percent_return desc;




 
 
  




