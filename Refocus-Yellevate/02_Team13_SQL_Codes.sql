-- =============================================================================
-- Author: Team 13
-- Create date: 9 Sep 2022
-- Update date: 24 Sep 2022
-- Description: Refocus Group Project Assignment 1
-- =============================================================================


-- =============================================================================
-- PRE-WORK
-- =============================================================================

--Create Schema (Create own end-to-end data analysis)
--Just find and replace schema to match your own schema
CREATE SCHEMA gp1
AUTHORIZATION postgres;

--To drop the table and recreate
/*
DROP TABLE gp1.invoices CASCADE;
DROP TABLE gp1.cinvoices CASCADE;
*/

--Create Table
CREATE TABLE gp1.invoices (
	country CHARACTER VARYING(13),
	customer_ID CHARACTER VARYING(10) NOT NULL,
	invoice_number NUMERIC,
	invoice_date DATE,
	due_date DATE,
	invoice_amount_usd NUMERIC,
	disputed NUMERIC,
	dispute_lost NUMERIC,
	settled_date DATE,
	days_to_settle INTEGER,
	days_late INTEGER
);

--Import CSV 
/*(Import 'Yellevate Invoices.csv' as 'invoices' table)*/

--Check number of records
SELECT COUNT(*) FROM gp1.invoices;
/*
count|
-----+
 2466|
*/

--Preview database columns
SELECT * FROM gp1.invoices
LIMIT 4;
/*
country|customer_id|invoice_number|invoice_date|due_date  |invoice_amount_usd|disputed|dispute_lost|settled_date|days_to_settle|days_late|
-------+-----------+--------------+------------+----------+------------------+--------+------------+------------+--------------+---------+
China  |0379-NEVHP |        611365|  2021-01-02|2021-02-01|              5594|       0|           0|  2021-01-15|            13|        0|
France |2621-XCLEH |    6482427308|  2020-01-13|2020-02-12|              8099|       1|           0|  2020-03-14|            61|       31|
China  |2820-XGXSB |       9231909|  2021-07-03|2021-08-02|              6588|       0|           0|  2021-07-08|             5|        0|
France |9322-YCTQO |       9888306|  2021-02-10|2021-03-12|             10592|       0|           0|  2021-03-17|            35|        5|
*/



-- =============================================================================
-- PRE-CHECKS
-- =============================================================================

--Check distinct years (determine if need a data subset based on years)
SELECT 
	DISTINCT(EXTRACT(YEAR FROM invoice_date)) AS distinct_year	
FROM gp1.invoices
ORDER BY distinct_year ASC;
/*
distinct_year|
-------------+
         2020|
         2021|
*/

--Check for misspelled country
SELECT 
	DISTINCT(country)
FROM gp1.invoices
ORDER BY country ASC;
/*
country      |
-------------+
China        |
France       |
Russia       |
Spain        |
United States|
*/

--Check for missing cases
SELECT *
FROM gp1.invoices
WHERE NOT(invoices IS NOT NULL);
/*
country|customer_id|invoice_number|invoice_date|due_date|invoice_amount_usd|disputed|dispute_lost|settled_date|days_to_settle|days_late|
-------+-----------+--------------+------------+--------+------------------+--------+------------+------------+--------------+---------+
*/

--Check for duplicates
SELECT invoice_number, customer_id
FROM gp1.invoices
GROUP BY invoice_number, customer_id
HAVING COUNT(*)>1;
/*
invoice_number|customer_id|
--------------+-----------+
*/

--Check for dispute lost but never disputed
SELECT * FROM gp1.invoices
WHERE 
	disputed = 0 AND 
	dispute_lost = 1;
/*
country|customer_id|invoice_number|invoice_date|due_date|invoice_amount_usd|disputed|dispute_lost|settled_date|days_to_settle|days_late|
-------+-----------+--------------+------------+--------+------------------+--------+------------+------------+--------------+---------+
*/

--Check if there are days_to_settle that does not match with difference of settle_date and invoice_date
SELECT 
	*
FROM 
	(SELECT 
		ABS(settled_date::DATE - invoice_date::DATE) AS date_diff
		, * 
	FROM gp1.invoices) a
WHERE a.date_diff != a.days_to_settle; 
/*
date_diff|country|customer_id|invoice_number|invoice_date|due_date|invoice_amount_usd|disputed|dispute_lost|settled_date|days_to_settle|days_late|
---------+-------+-----------+--------------+------------+--------+------------------+--------+------------+------------+--------------+---------+
*/

--Create a copy of table
CREATE TABLE gp1.cinvoices AS
SELECT * FROM gp1.invoices;





-- =============================================================================
-- DATA ANALYSIS GOALS
-- =============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* The processing time in which invoices are settled (average # of days rounded 
to a whole number) */

SELECT 
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle
FROM gp1.cinvoices;
/*
avg_days_to_settle|
------------------+
                26|
*/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* The processing time for the company to settle disputes (average # of days 
rounded to a whole number) */

SELECT 
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_dispute
FROM gp1.cinvoices
WHERE disputed = 1;
/*
avg_days_to_settle_dispute|
--------------------------+
                        36|
*/

/* Additional Info */

--Average days to settle dispute (won)
SELECT 
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_dispute_won
FROM gp1.cinvoices
WHERE dispute_lost = 0;
/*
avg_days_to_settle_dispute_won|
------------------------------+
                            26|
*/

--Average days to settle dispute (lost)
SELECT 
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_dispute_lost
FROM gp1.cinvoices
WHERE dispute_lost = 1;
/*
avg_days_to_settle_dispute_lost|
-------------------------------+
                             34|
*/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* Percentage of disputes received by the company that were lost (within two 
decimal places). */

SELECT 
	ROUND((SUM(dispute_lost) / SUM(disputed) * 100),2) AS dispute_lost_percent
FROM gp1.cinvoices;
/*
dispute_lost_percent|
--------------------+
               17.69|
*/

/* Additional Info */
SELECT * FROM gp1.cinvoices
WHERE disputed = 1 AND dispute_lost = 1;
--101 rows

SELECT * FROM gp1.cinvoices
WHERE disputed = 1;
--571 rows





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 4 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* Percentage of revenue lost from disputes (within two decimal places). */

--Calculate total revenue lost due to disputes lost
SELECT 
	SUM(invoice_amount_usd) AS revenue_lost_from_dispute
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND
	dispute_lost = 1;
/*
revenue_lost_from_dispute|
-------------------------+
                   690167|
*/

--Calculate total revenue projected
SELECT 
	SUM(invoice_amount_usd) AS revenue_projected
FROM gp1.cinvoices;
/*
revenue_projected|
-----------------+
         14770318|
*/

/* By calculation based on above 2 values:
(690167/14770318)*100 = 4.67266175311865323414160751 */

--Combine in one table the total revenue lost due to disputes lost
SELECT 
	'revenue_lost_from_dispute_lost' AS label,
	SUM(invoice_amount_usd) AS revenue_lost
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND
	dispute_lost = 1
GROUP BY dispute_lost
UNION
SELECT 
	'revenue_projected' AS label,
	SUM(invoice_amount_usd) AS revenue_projected
FROM gp1.cinvoices;
/*
label                         |revenue_lost|
------------------------------+------------+
revenue_lost_from_dispute_lost|      690167|
revenue_projected             |    14770318|
*/

--Add column as placeholder for revenue lost for lost disputes
--criteria: disputed = 1 AND dispute_lost = 1
ALTER TABLE gp1.cinvoices
ADD COLUMN revenue_lost_from_disputes_lost NUMERIC;

--Count rows to update, criteria: disputed & disputes lost
SELECT COUNT(*) 
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND
	dispute_lost = 1;
/*
count|
-----+
  101|
*/

--Update added column with values from invoice_amount_usd where 
--disputed = 1 AND dispute_lost = 1
UPDATE gp1.cinvoices
SET revenue_lost_from_disputes_lost = invoice_amount_usd
WHERE 	
	disputed = 1 AND
	dispute_lost = 1;
--Updated Rows	101

--Percentage of Revenue Lost due to Disputes Lost
SELECT 
	ROUND(
		SUM(revenue_lost_from_disputes_lost) / SUM(invoice_amount_usd) * 100,
	2) AS percent_rev_lost_disputes_lost
FROM gp1.cinvoices;
/*
percent_rev_lost_disputes_lost|
------------------------------+
                          4.67|
*/


--Post task on table revenue_lost_from_disputes_lost

/* Update cinvoices to set null values for revenue_lost_from_disputes_lost to 0 */
SELECT * FROM gp1.cinvoices
WHERE revenue_lost_from_disputes_lost IS NULL;
--2365 rows

SELECT COUNT(*) FROM gp1.cinvoices
WHERE revenue_lost_from_disputes_lost IS NULL; 
--2365

UPDATE gp1.cinvoices
SET revenue_lost_from_disputes_lost = 0
WHERE revenue_lost_from_disputes_lost IS NULL; 
--Updated Rows	2365

SELECT COUNT(*) FROM gp1.cinvoices
WHERE revenue_lost_from_disputes_lost = 0; 
/*
count|
-----+
 2365|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 5 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/* The country where the company reached the highest losses from lost disputes 
(in USD). */

--Calculate the revenue loss per country
SELECT 
	DISTINCT(country),
	SUM(revenue_lost_from_disputes_lost) AS revenue_loss
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND
	dispute_lost = 1
GROUP BY country, disputed, dispute_lost
ORDER BY revenue_loss DESC;	
/*
country      |revenue_loss|
-------------+------------+
France       |      526264|
Russia       |       81291|
China        |       42630|
United States|       22936|
Spain        |       17046|
*/

/* Additional Info */

SELECT 
	DISTINCT(country)
	, SUM (disputed) AS disputed
	, SUM(revenue_lost_from_disputes_lost) AS revenue_loss
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND
	dispute_lost = 1
GROUP BY country, disputed, dispute_lost
ORDER BY revenue_loss DESC;	
/*
country      |disputed|revenue_loss|
-------------+--------+------------+
France       |      76|      526264|
Russia       |      13|       81291|
China        |       5|       42630|
United States|       3|       22936|
Spain        |       4|       17046|
*/
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ITEM 5 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





-- =============================================================================
-- DATA EXPLORATION
-- =============================================================================

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Processing Time
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Average processing time for all invoices
SELECT
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle
FROM gp1.cinvoices;
/*
avg_days_to_settle|
------------------+
                26|
*/

--Average processing time for all disputes
SELECT
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_disputed
FROM gp1.cinvoices
WHERE disputed = 1;
/*
avg_days_to_settle_disputed|
---------------------------+
                         36|
*/

--Average processing time for lost disputes
SELECT
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_lost
FROM gp1.cinvoices
WHERE dispute_lost = 1;
/*
avg_days_to_settle_lost|
-----------------------+
                     34|
*/

--Average processing time for won disputes
SELECT
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_won
FROM gp1.cinvoices
WHERE dispute_lost = 0;
/*
avg_days_to_settle_won|
----------------------+
                    26|
*/

--Lost disputes are settled longer than those won by
SELECT 
	(SELECT
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_lost
	FROM gp1.cinvoices
	WHERE dispute_lost = 1) - 
	(SELECT
	ROUND(AVG(days_to_settle)) AS avg_days_to_settle_won
	FROM gp1.cinvoices
	WHERE dispute_lost = 0) AS diff_avg_days_to_settle_lost_won;
/*
diff_avg_days_to_settle_lost_won|
--------------------------------+
                               8|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Number of Disputes
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Total number of invoices
SELECT COUNT(*) AS count_invoices
FROM gp1.cinvoices;
/*
count_invoices|
--------------+
          2466|
*/

--Total number of disputed invoices
SELECT COUNT(*) AS count_disputed_invoices 
FROM gp1.cinvoices
WHERE disputed = 1;
/*
count_disputed_invoices|
-----------------------+
                    571|
*/

--Percent of invoices disputed
SELECT 
	ROUND(SUM(disputed) / COUNT(invoice_number) * 100,2)
	AS percent_invoices_disputed
FROM gp1.cinvoices;
/*
percent_invoices_disputed|
-------------------------+
                    23.15|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Lost Disputes
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Total disputed invoices
SELECT COUNT(*) AS count_disputed_invoices 
FROM gp1.cinvoices
WHERE disputed = 1;
/*
count_disputed_invoices|
-----------------------+
                    571|
*/

--Total lost disputes
SELECT COUNT(*) AS count_disputed_invoices_lostdispute
FROM gp1.cinvoices
WHERE disputed = 1 AND dispute_lost = 1;
/*
count_disputed_invoices_lostdispute|
-----------------------------------+
                                101|
*/

--Total won disputes
SELECT COUNT(*) AS count_disputed_invoices_wondispute
FROM gp1.cinvoices
WHERE disputed = 1 AND dispute_lost = 0;
/*
count_disputed_invoices_wondispute|
----------------------------------+
                               470|
*/

--Percent of disputed invoices that were lost
SELECT 
	ROUND(
		((a.count_dispute_lost / a.count_disputes) * 100)
	,2) AS percent_invoices_disputed
FROM
	(SELECT 
		SUM(dispute_lost) AS count_dispute_lost,
		SUM(disputed) AS count_disputes
	FROM gp1.cinvoices) a;	
/*
percent_invoices_disputed|
-------------------------+
                    17.69|
*/





--Dispute Count, Lost Count
SELECT 
	country
	, COUNT(invoice_number) AS count_invoices
	, SUM(disputed) AS count_disputes
	, SUM(dispute_lost) AS count_lost
FROM gp1.cinvoices
GROUP BY country
ORDER BY country ASC;
/*
country      |count_invoices|count_disputes|count_lost|
-------------+--------------+--------------+----------+
China        |           616|            61|         5|
France       |           561|           222|        76|
Russia       |           387|           149|        13|
Spain        |           396|            59|         4|
United States|           506|            80|         3|
*/



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Lost Revenue
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Total lost revenue from lost disputes
SELECT SUM(revenue_lost_from_disputes_lost) AS total_lost_revenue
FROM gp1.cinvoices;
/*
total_lost_revenue|
------------------+
            690167|
*/

--Total revenue if all invoice payments were collected
SELECT SUM(invoice_amount_usd) AS invoice_amount
FROM gp1.cinvoices;
/*
invoice_amount|
--------------+
      14770318|
*/

--Total revenue (amount from paid invoices)
SELECT SUM(invoice_amount_usd) AS invoice_amount_paid
FROM gp1.cinvoices
WHERE dispute_lost = 0;
/*
invoice_amount_paid|
-------------------+
           14080151|
*/

--Total revenue (amount from paid invoices) - per country
SELECT 
	country
	, SUM(invoice_amount_usd) AS invoice_amount_paid
FROM gp1.cinvoices
WHERE dispute_lost = 0
GROUP BY country
ORDER BY invoice_amount_paid DESC;
/*
country      |invoice_amount_paid|
-------------+-------------------+
China        |            3962266|
France       |            3416027|
United States|            2715141|
Russia       |            2368915|
Spain        |            1617802|
*/

--Percentage of lost revenue lost from disputes
SELECT 
	ROUND(SUM(revenue_lost_from_disputes_lost) / SUM(invoice_amount_usd) * 100,	2) 
	AS percent_revenue_lost_from_lostdisputes
FROM gp1.cinvoices;
/*
percent_revenue_lost_from_lostdisputes|
--------------------------------------+
                                  4.67|
*/

--Highest lost revenue is from
SELECT 
	country
	, SUM(revenue_lost_from_disputes_lost) AS revenue_lost
FROM gp1.cinvoices
GROUP BY country
ORDER BY revenue_lost DESC
LIMIT 1;
/*
country|revenue_lost|
-------+------------+
France |      526264|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Revenue if all invoice are collected
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Revenue if all invoice are collected - per country
SELECT 
	country
	, SUM(invoice_amount_usd) AS invoice_amount
FROM gp1.cinvoices
GROUP BY country
ORDER BY invoice_amount DESC;
/*
country      |invoice_amount|
-------------+--------------+
China        |       4004896|
France       |       3942291|
United States|       2738077|
Russia       |       2450206|
Spain        |       1634848|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Revenue lost due to lost disputes
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Revenue lost due to lost disputes - per country
SELECT 
	country
	, SUM(revenue_lost_from_disputes_lost) AS revenue_lost
FROM gp1.cinvoices
GROUP BY country
ORDER BY revenue_lost DESC;
/*
country      |revenue_lost|
-------------+------------+
France       |      526264|
Russia       |       81291|
China        |       42630|
United States|       22936|
Spain        |       17046|
*/

--table to show invoice amount, revenue lost per country
SELECT 
	country
	, SUM(invoice_amount_usd) AS invoice_amount
	, SUM(revenue_lost_from_disputes_lost) AS revenue_lost
	, (SUM(invoice_amount_usd) - SUM(revenue_lost_from_disputes_lost)) AS margin
	, ROUND(((SUM(invoice_amount_usd) - SUM(revenue_lost_from_disputes_lost)) / SUM(invoice_amount_usd) * 100),2) AS percent_revenue_collected
	, ROUND((SUM(revenue_lost_from_disputes_lost) / SUM(invoice_amount_usd) * 100),2) AS percent_revenue_loss
FROM gp1.cinvoices
GROUP BY country
ORDER BY country ASC;
/*
country      |invoice_amount|revenue_lost|margin |percent_revenue_collected|percent_revenue_loss|
-------------+--------------+------------+-------+-------------------------+--------------------+
China        |       4004896|       42630|3962266|                    98.94|                1.06|
France       |       3942291|      526264|3416027|                    86.65|               13.35|
Russia       |       2450206|       81291|2368915|                    96.68|                3.32|
Spain        |       1634848|       17046|1617802|                    98.96|                1.04|
United States|       2738077|       22936|2715141|                    99.16|                0.84|
*/

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Chronic Disputers
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--The average disputes per customer (excluding those without recorded disputes)
SELECT 
	ROUND(AVG(a.count_disputes),2) AS avg_dispute_count
FROM 
	(SELECT 
		customer_id
		, COUNT(disputed) count_disputes
	FROM gp1.cinvoices
	WHERE disputed != 0
	GROUP BY customer_id) a;
/*	
avg_dispute_count|
-----------------+
             7.51|
*/

--No. of customers who have disputed more than one invoice
SELECT 
	COUNT(a.count_disputed) AS count_customer_disputed_gt_1
FROM
	(SELECT 
		customer_id
		, COUNT(disputed) AS count_disputed
	FROM gp1.cinvoices
	WHERE disputed = 1
	GROUP BY customer_id
	ORDER BY count_disputed DESC) a
WHERE a.count_disputed > 1;
/*
count_customer_disputed_gt_1|
----------------------------+
                          67|
*/

--Of the 67 customers who have disputed more than one invoice, majority are from
SELECT 
	a.country
	, COUNT(a.customer_id) AS count_customers
FROM 
	(SELECT 
		country
		, customer_id
		, COUNT(disputed) AS count_disputed
	FROM gp1.cinvoices
	WHERE disputed = 1
	GROUP BY country, customer_id
	ORDER BY count_disputed DESC) a
WHERE a.count_disputed > 1
GROUP BY a.country
ORDER BY count_customers DESC;
/*
country      |count_customers|
-------------+---------------+
France       |             20|
United States|             15|
Russia       |             12|
Spain        |             11|
China        |              9|
*/

--No. of customers who have disputed more than average (7.51)
SELECT 
	COUNT(a.count_disputed) AS count_customer_disputed_gt_avg
FROM
	(SELECT 
		customer_id
		, COUNT(disputed) AS count_disputed
	FROM gp1.cinvoices
	WHERE disputed = 1
	GROUP BY customer_id
	ORDER BY count_disputed DESC) a
WHERE a.count_disputed > 7.51;
/*
count_customer_disputed_gt_avg|
------------------------------+
                            27|
*/

--Of the 27 customers who have disputed more than the average, majority are from
SELECT 
	a.country
	, COUNT(a.customer_id) AS count_customers
FROM 
	(SELECT 
		country
		, customer_id
		, COUNT(disputed) AS count_disputed
	FROM gp1.cinvoices
	WHERE disputed = 1
	GROUP BY country, customer_id
	ORDER BY count_disputed DESC) a
WHERE a.count_disputed > 7.51
GROUP BY a.country
ORDER BY count_customers DESC;
/*
country      |count_customers|
-------------+---------------+
Russia       |             11|
France       |             10|
United States|              4|
China        |              1|
Spain        |              1|
*/

--Total revenue lost from chronic disputers
SELECT 
	a.country
	, COUNT(a.customer_id) AS count_customers
	, SUM(a.revenue_lost) AS revenue_lost 
FROM 
	(SELECT 
		country
		, customer_id
		, COUNT(disputed) AS count_disputed
		, SUM(revenue_lost_from_disputes_lost) AS revenue_lost
	FROM gp1.cinvoices
	WHERE disputed = 1
	GROUP BY country, customer_id
	ORDER BY count_disputed DESC) a
WHERE a.count_disputed > 7.51
GROUP BY a.country
ORDER BY revenue_lost DESC;
/*
country      |count_customers|revenue_lost|
-------------+---------------+------------+
France       |             10|      444481|
Russia       |             11|       81291|
China        |              1|       18564|
Spain        |              1|        1494|
United States|              4|           0|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Late Payments
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Number of invoices that were not disputed
SELECT 
	COUNT(*) AS invoices_not_disputed
FROM gp1.cinvoices
WHERE disputed = 0;
/*
invoices_not_disputed|
---------------------+
                 1895|
*/

--Number of non-disputed invoices that are paid late
SELECT 
	COUNT(*) AS invoices_not_disputed_non_late
FROM gp1.cinvoices
WHERE disputed = 0 AND days_late > 0;
/*
invoices_not_disputed_non_late|
------------------------------+
                           492|
*/



--Invoices settled on time (within 30 days)
SELECT 
	ROUND(AVG(days_to_settle),2) AS avg_days_to_settle_nondisputed
FROM gp1.cinvoices
WHERE disputed = 0 AND days_late = 0;
/*
avg_days_to_settle_nondisputed|
------------------------------+
                         18.62|
*/



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Dispute Rate by Country
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Disputes Rate by Country (nondisputed)
SELECT 
	country
	, COUNT(disputed) AS nondisputed
FROM gp1.cinvoices
WHERE disputed = 0
GROUP BY country
ORDER BY nondisputed DESC;
/*
country      |nondisputed|
-------------+-----------+
China        |        555|
United States|        426|
France       |        339|
Spain        |        337|
Russia       |        238|
*/

--Disputes Rate by Country (disputed)
SELECT 
	country
	, COUNT(disputed) AS disputed
FROM gp1.cinvoices
WHERE disputed = 1
GROUP BY country
ORDER BY disputed DESC;
/*
country      |disputed|
-------------+--------+
France       |     222|
Russia       |     149|
United States|      80|
China        |      61|
Spain        |      59|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Disputes Lost by Country (disputed invoices)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Disputes Won by Country (disputed invoices)
SELECT 
	country	
	, COUNT(dispute_lost) AS disputewon
FROM gp1.cinvoices
WHERE disputed = 1 AND dispute_lost = 0
GROUP BY country
ORDER BY disputewon DESC;
/*
country      |disputewon|
-------------+----------+
France       |       146|
Russia       |       136|
United States|        77|
China        |        56|
Spain        |        55|
*/

--Disputes Lost by Country (disputed invoices)
SELECT 
	country	
	, COUNT(dispute_lost) AS disputelost
FROM gp1.cinvoices
WHERE disputed = 1 AND dispute_lost = 1
GROUP BY country
ORDER BY disputelost DESC;
/*
country      |disputelost|
-------------+-----------+
France       |         76|
Russia       |         13|
China        |          5|
Spain        |          4|
United States|          3|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Customers in France where we lost the disputes
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Count of Invoice Number where we won disputes in France
SELECT 
	customer_id
	, COUNT(invoice_number) AS invoice_dispute_won
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND 
	country = 'France' AND
	dispute_lost = 0
GROUP BY customer_id
ORDER BY invoice_dispute_won DESC;
/*
customer_id|invoice_dispute_won|
-----------+-------------------+
3448-OWJOT |                 15|
6048-QPZCF |                 15|
7600-OISKG |                 14|
9725-EZTEJ |                 13|
9771-QTLGZ |                 13|
8389-TCXFQ |                 11|
4632-QZOKX |                  9|
2621-XCLEH |                  7|
5284-DJOZO |                  6|
4640-FGEJI |                  6|
9117-LYRCE |                  5|
5573-KSOIA |                  5|
5164-VMYWJ |                  5|
0783-PEPYR |                  5|
9758-AIEIK |                  4|
8976-AMJEO |                  4|
7938-EVASK |                  3|
1447-YZKCL |                  2|
4092-ZAVRG |                  2|
4651-PMEXQ |                  2|
*/

--Count of Invoice Number where we lost disputes in France
SELECT 
	customer_id
	, COUNT(invoice_number) AS invoice_dispute_lost
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND 
	country = 'France' AND
	dispute_lost = 1
GROUP BY customer_id
ORDER BY invoice_dispute_lost DESC;
/*
customer_id|invoice_dispute_lost|
-----------+--------------------+
3448-OWJOT |                  12|
9725-EZTEJ |                  11|
4632-QZOKX |                   8|
7600-OISKG |                   8|
9771-QTLGZ |                   8|
8389-TCXFQ |                   6|
4640-FGEJI |                   5|
9117-LYRCE |                   4|
4092-ZAVRG |                   3|
5573-KSOIA |                   2|
5164-VMYWJ |                   2|
5284-DJOZO |                   2|
6048-QPZCF |                   2|
6833-ETVHD |                   1|
0783-PEPYR |                   1|
1447-YZKCL |                   1|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Customers in France where we lost the disputes & revenue lost
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Customers in France where we lost the disputes & revenue lost
SELECT
	customer_id
	, SUM(revenue_lost_from_disputes_lost) AS revenue_lost
	, COUNT(disputed) AS disputed 
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND
	dispute_lost = 1 AND
	country = 'France'
GROUP BY customer_id
ORDER BY disputed DESC;
/*
customer_id|revenue_lost|disputed|
-----------+------------+--------+
3448-OWJOT |       81783|      12|
9725-EZTEJ |       88124|      11|
4632-QZOKX |       42486|       8|
7600-OISKG |       49426|       8|
9771-QTLGZ |       43770|       8|
8389-TCXFQ |       43067|       6|
4640-FGEJI |       41762|       5|
9117-LYRCE |       24249|       4|
4092-ZAVRG |       19912|       3|
5573-KSOIA |       18478|       2|
5164-VMYWJ |       21307|       2|
5284-DJOZO |       14904|       2|
6048-QPZCF |       14910|       2|
6833-ETVHD |        8506|       1|
0783-PEPYR |        7287|       1|
1447-YZKCL |        6293|       1|
*/

--Customers in France where we lost the disputes & dispute count

SELECT 
	customer_id
	, COUNT(disputed) AS disputed
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND 
	country = 'France'
GROUP BY customer_id
ORDER BY disputed DESC;
/*
customer_id|disputed|
-----------+--------+
3448-OWJOT |      27|
9725-EZTEJ |      24|
7600-OISKG |      22|
9771-QTLGZ |      21|
8389-TCXFQ |      17|
6048-QPZCF |      17|
4632-QZOKX |      17|
4640-FGEJI |      11|
9117-LYRCE |       9|
5284-DJOZO |       8|
5164-VMYWJ |       7|
5573-KSOIA |       7|
2621-XCLEH |       7|
0783-PEPYR |       6|
4092-ZAVRG |       5|
8976-AMJEO |       4|
9758-AIEIK |       4|
1447-YZKCL |       3|
7938-EVASK |       3|
4651-PMEXQ |       2|
6833-ETVHD |       1|
*/





-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Customers in France and their disputes data
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Customers in France and their disputes data (nondisputed)
SELECT 
	customer_id
	, COUNT(disputed) AS nondisputed 
FROM gp1.cinvoices
WHERE 
	disputed = 0 AND
	country = 'France'
GROUP BY customer_id
ORDER BY nondisputed DESC;
/*
customer_id|nondisputed|
-----------+-----------+
6833-ETVHD |         32|
5164-VMYWJ |         24|
4640-FGEJI |         24|
8976-AMJEO |         23|
5284-DJOZO |         22|
1447-YZKCL |         20|
9322-YCTQO |         19|
4651-PMEXQ |         19|
7938-EVASK |         18|
7245-CKNCN |         17|
5573-KSOIA |         17|
9758-AIEIK |         17|
4092-ZAVRG |         16|
8389-TCXFQ |         16|
0783-PEPYR |         15|
9117-LYRCE |         14|
6048-QPZCF |         13|
2621-XCLEH |          8|
9725-EZTEJ |          2|
7600-OISKG |          1|
9771-QTLGZ |          1|
3448-OWJOT |          1|
*/

--Customers in France and their disputes data (disputed)
SELECT 
	customer_id
	, COUNT(disputed) AS disputed 
FROM gp1.cinvoices
WHERE 
	disputed = 1 AND
	country = 'France'
GROUP BY customer_id
ORDER BY disputed DESC;
/*
customer_id|disputed|
-----------+--------+
3448-OWJOT |      27|
9725-EZTEJ |      24|
7600-OISKG |      22|
9771-QTLGZ |      21|
8389-TCXFQ |      17|
6048-QPZCF |      17|
4632-QZOKX |      17|
4640-FGEJI |      11|
9117-LYRCE |       9|
5284-DJOZO |       8|
5164-VMYWJ |       7|
5573-KSOIA |       7|
2621-XCLEH |       7|
0783-PEPYR |       6|
4092-ZAVRG |       5|
8976-AMJEO |       4|
9758-AIEIK |       4|
1447-YZKCL |       3|
7938-EVASK |       3|
4651-PMEXQ |       2|
6833-ETVHD |       1|
*/

--Customers in France and their invoices
SELECT 
	customer_id
	, COUNT(disputed) AS invoices 
FROM gp1.cinvoices
WHERE 
	country = 'France'
GROUP BY customer_id
ORDER BY invoices DESC;
/*
customer_id|invoices|
-----------+--------+
4640-FGEJI |      35|
6833-ETVHD |      33|
8389-TCXFQ |      33|
5164-VMYWJ |      31|
5284-DJOZO |      30|
6048-QPZCF |      30|
3448-OWJOT |      28|
8976-AMJEO |      27|
9725-EZTEJ |      26|
5573-KSOIA |      24|
9117-LYRCE |      23|
1447-YZKCL |      23|
7600-OISKG |      23|
9771-QTLGZ |      22|
0783-PEPYR |      21|
7938-EVASK |      21|
4651-PMEXQ |      21|
9758-AIEIK |      21|
4092-ZAVRG |      21|
9322-YCTQO |      19|
7245-CKNCN |      17|
4632-QZOKX |      17|
2621-XCLEH |      15|
*/

--Revenue Lost for Chronic Disputers in France
SELECT 
	a.customer_id	
	, a.country
	, SUM(a.disputed_count) AS disputed_count
	, SUM(a.revenue_lost_from_disputes_lost) AS revenue_lost_from_disputes_lost
FROM 
	(SELECT 
		customer_id 
		, country
		, SUM(disputed) AS disputed_count
		, SUM(revenue_lost_from_disputes_lost) AS revenue_lost_from_disputes_lost
	FROM gp1.cinvoices
	WHERE 
		disputed = 1 AND
		country = 'France' 
	GROUP BY customer_id, country
	ORDER BY revenue_lost_from_disputes_lost DESC) a
WHERE a.disputed_count > 7.51
GROUP BY a.customer_id, a.country
ORDER BY revenue_lost_from_disputes_lost DESC;
/*
customer_id|country|disputed_count|revenue_lost_from_disputes_lost|
-----------+-------+--------------+-------------------------------+
9725-EZTEJ |France |            24|                          88124|
3448-OWJOT |France |            27|                          81783|
7600-OISKG |France |            22|                          49426|
9771-QTLGZ |France |            21|                          43770|
8389-TCXFQ |France |            17|                          43067|
4632-QZOKX |France |            17|                          42486|
4640-FGEJI |France |            11|                          41762|
9117-LYRCE |France |             9|                          24249|
6048-QPZCF |France |            17|                          14910|
5284-DJOZO |France |             8|                          14904|
*/


