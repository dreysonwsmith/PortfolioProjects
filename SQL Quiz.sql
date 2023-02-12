--A. Basic SQL

--1. Write a query that finds the percentage of revenue that comes from poster paper for each order. 

SELECT id, account_id,
poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd) AS poster_revenue
FROM orders
LIMIT 10;

--2. Find all the company names that start with a 'C' or 'W', and the primary contact contains 'ana' or 'Ana', but it doesn't contain 'eana'.

SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') AND (primary_poc  LIKE '%ana%' OR primary_poc LIKE '%Ana%') AND primary_poc NOT LIKE '%eana%'

--B. SQL JOINS

--1. Provide the name for each region for every order, as well as the account name and the unit price they paid for the order.

SELECT r.name region, a.name account,
(o.total_amt_usd/(o.total+0.01)) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
ORDER BY unit_price;

--2. Find all the orders that occurred in 2015.

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;

--C. SQL AGGREGATIONS

--1. What is the MEDIAN 'total_usd' spent on all orders?

MEDIAN (total number of orders = 6912, median = '3456' & '3457')
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;
Since there are 6912 orders - we want the average of the '3457' and '3456'
order amounts when ordered. This is the average of 2483.16 and 2482.55.
This gives the median of 2482.855.

--2. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?

SELECT DATE_TRUNC('month', occurred_at) order_month, SUM(o.gloss_amt_usd) sum_gloss
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--3.  We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales.
--The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales
--across all orders, and a column with top, middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table.

SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent,
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;

--D. SQL SUBQUERIES & TEMPORARY TABLES

--1. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.

WITH t1 AS (
   SELECT AVG(o.total_amt_usd) avg_all
   FROM orders o
   JOIN accounts a
   ON a.id = o.account_id),
t2 AS (
   SELECT o.account_id, AVG(o.total_amt_usd) avg_amt
   FROM orders o
   GROUP BY 1
   HAVING AVG(o.total_amt_usd) > (SELECT * FROM t1))
SELECT AVG(avg_amt)
FROM t2;

--2. For the region with the largest sales total_amt_usd, how many total orders were placed?

WITH table1 AS (
  SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
  FROM region r
  JOIN sales_reps s
  ON r.id = s.region_id
  JOIN accounts a
  ON s.id = a.sales_rep_id
  JOIN orders o
  ON a.id = o.account_id
  GROUP BY 1),
    table2 AS (
    SELECT MAX(total_amt)
    FROM table1)
    SELECT r.name region_name, COUNT(o.total) total_orders
    FROM region r
    JOIN sales_reps s
    ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
    JOIN orders o
    ON a.id = o.account_id
    GROUP BY 1
HAVING SUM(o.total_amt_usd) = (SELECT * FROM table2)

--E. SQL DATA CLEANING

--1. We would like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase),
--then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their
--first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.

WITH tab1 AS (
  SELECT LEFT(primary_poc, POSITION(' ' IN primary_poc) -1 ) first_name, RIGHT(primary_poc,
      LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) last_name, a.name comp_name
    FROM accounts a)
  SELECT first_name, last_name, CONCAT(first_name, last_name, '@',
      REPLACE(comp_name, ' ', ''), '.com') mail, CONCAT(LEFT(LOWER(first_name), 1),
  RIGHT(LOWER(first_name), 1), LEFT(LOWER(last_name), 1), RIGHT(LOWER(last_name), 1), LENGTH(first_name),
  LENGTH(last_name), REPLACE(UPPER(comp_name), ' ', '')) AS password
    FROM tab1;

--2. Look at the date column in the sf_crime_data table. Notice the date is not in the correct format. Write a query to change the date into the correct SQL date format.

--NOTE: This quiz makes use of a different dataset.

SELECT date,
(SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::date AS main_date
FROM sf_crime_data
LIMIT 10;

--F. SQL WINDOW FUNCTIONS

--1. Create and use an alias to shorten the following query. Name the alias account_year_window

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders
*/
SELECT id, account_id, total_amt_usd,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window AS max_total_amt_usd
FROM orders
WINDOWS account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))

--2. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of the amount of total_amt_usd for their orders. Your resulting table should
--have the account_id, the occurred_at time for each order, the total amount of total_amt_usd paper purchased, and one of 100 levels in a total_percentile column.

WITH total AS (
    SELECT account_id, occurred_at, SUM(total_amt_usd) total_sales
    FROM orders
    GROUP BY 1, 2)
SELECT account_id, occurred_at, total_sales,
NTILE(100) OVER (ORDER BY total_sales) AS total_percentile
FROM total
ORDER BY 1;

--F. SQL ADVANCED JOINS & PERFORMANCE TUNING

--1. Perform the same interval analysis except for the web_events table. Change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event.
--Add a column for the channel variable in both instances of the table in your query.

SELECT w1.id w1_id, w1.account_id w1_account_id, w1.channel w1_channel, w1.occurred_at w1_occurred_at,
w2.id w2_id, w2.account_id w2_account_id, w2.channel w2_channel, w2.occurred_at w2_occurred_at
FROM web_events w1
LEFT JOIN web_events w2
ON w1.account_id = w2.account_id
AND w1.occurred_at > w2.occurred_at
AND w1.occurred_at <= w2.occurred_at + INTERVAL '1 day'
ORDER BY 2, 8;
--2. Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table.
--Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. Then do a COUNT the number of times a name appears in the double_accounts table.

WITH double_accounts AS (
    SELECT *
    FROM accounts a1
    UNION ALL
    SELECT *
    FROM accounts a2)
SELECT name, COUNT(*) AS name_count
FROM double_accounts
GROUP BY 1
ORDER BY 2;

--EXTRA
--Imagine you're doing a high level reporting for Parch & Posey and you'd like to see a bunch of metrics rolled up on  a daily basis. You could use this to power a dashboard that would help run the business day to day by quickly identifying anomalies.

SELECT  DATE_TRUNC('day', o.occurred_at) AS date,
        COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
        COUNT(DISTINCT o.id) AS orders,
        COUNT(DISTINCT w.id) AS web_visits
FROM accounts a
JOIN orders o
ON o.account_id = a.id
JOIN web_events w
ON DATE_TRUNC('day', w.occurred_at) = DATE_TRUNC('day', o.occurred_at)
GROUP BY 1
ORDER BY 1 DESC;
