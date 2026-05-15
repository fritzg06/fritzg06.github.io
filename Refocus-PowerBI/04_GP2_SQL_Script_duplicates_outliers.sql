-- =============================================================================
-- Author: Fritz Gerald Reyes
-- Create date: 14 Mar 2023
-- Update date: 
-- Description: Refocus Group Project 2 (version 1) - Exploratory Data Analysis
-- =============================================================================


-- =============================================================================
-- DUPLICATES CHECK
-- =============================================================================

/* 
-- Tables from previous steps 
*/
SELECT * FROM gp2.cusers;
SELECT * FROM gp2.u2_cschedules;
SELECT * FROM gp2.cpayroll;
SELECT * FROM gp2.cattendance;
SELECT * FROM gp2.u_cleaverequest;



/* ------------------------------
cusers table - check for duplicates
*/ ------------------------------

SELECT user_id, first_name, last_name, gender, date_birth, date_hire, date_leave, employment, "position", "location", department, created_at
FROM gp2.cusers
GROUP BY user_id, first_name, last_name, gender, date_birth, date_hire, date_leave, employment, "position", "location", department, created_at
HAVING COUNT(*)>1;
--none



/* ------------------------------
cpayroll table - check for duplicates
*/ ------------------------------

SELECT user_id, first_name, last_name, date_start, date_end, ctc, net_pay, gross_pay, data_salary_basic_rate, data_salary_basic_type, currency, status, created_at 
FROM gp2.cpayroll
GROUP BY user_id, first_name, last_name, date_start, date_end, ctc, net_pay, gross_pay, data_salary_basic_rate, data_salary_basic_type, currency, status, created_at
HAVING COUNT(*)>1;
--none



/* ------------------------------
cattendance table - check for duplicates
*/ ------------------------------

SELECT user_id, first_name, last_name, "location", date, time, timezone, "case", "source" 
FROM gp2.cattendance
GROUP BY user_id, first_name, last_name, "location", date, time, timezone, "case", "source"
HAVING COUNT(*)>1;
/*
user_id|first_name|last_name|location     |date      |time    |timezone|case|source  |
-------+----------+---------+-------------+----------+--------+--------+----+--------+
74054  |          |         |not specified|2021-12-15|14:59:24|+08:00  |IN  |mobile  |
75952  |          |         |not specified|2021-11-14|07:16:40|+08:00  |IN  |mobile  |
84541  |          |         |Clinic       |2022-05-14|08:26:53|+08:00  |IN  |mobile  |
74042  |          |         |not specified|2022-09-13|17:11:34|+08:00  |OUT |mobile  |
74465  |          |         |not specified|2021-12-20|13:49:47|+08:00  |IN  |mobile  |
88348  |          |         |not specified|2022-08-30|08:00:00|+08:00  |IN  |frontend|
84541  |          |         |Clinic       |2022-05-19|08:34:31|+08:00  |IN  |mobile  |
74054  |          |         |not specified|2022-01-26|22:01:34|+08:00  |OUT |mobile  |
74042  |          |         |Office       |2022-04-26|17:09:54|+08:00  |OUT |mobile  |
74054  |          |         |not specified|2021-11-27|14:53:53|+08:00  |IN  |mobile  |
83893  |          |         |not specified|2022-01-22|08:00:17|+08:00  |IN  |mobile  |
83893  |          |         |not specified|2022-01-29|07:56:03|+08:00  |IN  |mobile  |
74465  |          |         |not specified|2021-12-08|15:09:48|+08:00  |OUT |mobile  |
74054  |          |         |not specified|2022-09-11|22:00:00|+08:00  |OUT |frontend|
75218  |          |         |Nu Orange    |2022-05-13|15:54:10|+08:00  |IN  |mobile  |
84509  |          |         |not specified|2022-01-06|16:16:09|+08:00  |OUT |mobile  |
84541  |          |         |Clinic       |2022-04-22|15:33:00|+08:00  |IN  |mobile  |
83902  |          |         |Gunung Catur |2022-10-11|22:00:00|+08:00  |OUT |frontend|
120696 |          |         |Nu Orange    |2022-08-09|07:59:39|+08:00  |IN  |mobile  |
83893  |          |         |not specified|2022-01-22|08:00:19|+08:00  |IN  |mobile  |
74050  |          |         |Clinic       |2022-04-30|14:59:02|+08:00  |IN  |mobile  |
75848  |          |         |Clinic       |2021-11-28|15:27:51|+08:00  |IN  |mobile  |
84541  |          |         |Clinic       |2022-05-11|08:29:37|+08:00  |IN  |mobile  |
74054  |          |         |not specified|2022-04-12|07:59:44|+08:00  |IN  |mobile  |
74054  |          |         |not specified|2022-01-12|07:57:43|+08:00  |IN  |mobile  |
74054  |          |         |not specified|2022-05-18|14:35:11|+08:00  |IN  |mobile  |
84541  |          |         |Clinic       |2022-04-23|15:32:35|+08:00  |IN  |mobile  |
87864  |          |         |Clinic       |2022-04-27|15:27:21|+08:00  |OUT |mobile  |
146182 |          |         |Gunung Catur |2022-09-22|15:00:00|+08:00  |IN  |frontend|
*/
--29 rows

--Sampling
SELECT * FROM gp2.cattendance
WHERE user_id = '74054' AND date = '2021-12-15' AND time = '14:59:24';
/*
user_id|first_name|last_name|location     |date      |time    |timezone|case|source|
-------+----------+---------+-------------+----------+--------+--------+----+------+
74054  |          |         |not specified|2021-12-15|14:59:24|+08:00  |IN  |mobile|
74054  |          |         |not specified|2021-12-15|14:59:24|+08:00  |IN  |mobile|
*/

--Check how many rows total
SELECT * FROM gp2.cattendance;
--12635 rows

SELECT COUNT(*) FROM gp2.cattendance;
--12635 rows

--Check how many rows if we use distinct
SELECT DISTINCT * FROM gp2.cattendance;
--12604 rows

--Create new table for deduplicated cattendance table
CREATE TABLE gp2.dedup_cattendance AS
SELECT DISTINCT * FROM gp2.cattendance;
--12604 rows updated

--Select deduplicated cattendance table
SELECT * FROM gp2.dedup_cattendance;
--12604 rows



/* ------------------------------
u2_cschedules table - check for duplicates
*/ ------------------------------

SELECT type, dates, time_start, time_end, timezone, time_planned, break_time, leave_type, user_id 
FROM gp2.u2_cschedules 
GROUP BY type, dates, time_start, time_end, timezone, time_planned, break_time, leave_type, user_id
HAVING COUNT(*)>1;
--16471 rows

--Check how many rows total
SELECT COUNT(*) FROM gp2.u2_cschedules;
--195189 rows

--Check how many rows if we use distinct
SELECT DISTINCT * FROM gp2.u2_cschedules; 
--26147 rows

--Create new table for deduplicated cattendance table
CREATE TABLE gp2.dedup_u2_cschedules AS
SELECT DISTINCT * FROM gp2.u2_cschedules;
--26147 rows updated

--Select deduplicated cattendance table
SELECT * FROM gp2.dedup_u2_cschedules;
--26147 rows



/* ------------------------------
u_cleaverequest table - check for duplicates
*/ ------------------------------

SELECT * FROM gp2.u_cleaverequest;

SELECT user_id, first_name, last_name, type, leave_type, dates, time_start, time_end, timezone, status, created_at
FROM gp2.u_cleaverequest 
GROUP BY user_id, first_name, last_name, type, leave_type, dates, time_start, time_end, timezone, status, created_at
HAVING COUNT(*)>1;
--none



/* ------------------------------
Updated Tables
*/ ------------------------------

SELECT * FROM gp2.cusers;
--77 rows

SELECT * FROM gp2.cpayroll;
--348 rows

SELECT * FROM gp2.u_cleaverequest;
--92 rows

SELECT * FROM gp2.dedup_cattendance;
--12604 rows

SELECT * FROM gp2.dedup_u2_cschedules;
--26147 rows


