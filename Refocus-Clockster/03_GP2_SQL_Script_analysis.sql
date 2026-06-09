-- =============================================================================
-- Author: Fritz Gerald Reyes
-- Create date: 27 Feb 2023
-- Update date: 16 Mar 2023
-- Description: Refocus Group Project 2 (version 1) - Exploratory Data Analysis
-- =============================================================================


-- =============================================================================
-- EXPLORATORY DATA ANALYSIS
-- =============================================================================

/* ------------------------------
SELECT the "c" tables
*/ ------------------------------
SELECT * FROM gp2.cusers;
SELECT * FROM gp2.cschedules;
SELECT * FROM gp2.cpayroll;
SELECT * FROM gp2.cattendance;
SELECT * FROM gp2.cleaverequest;

/* ----------------------------------------
Exploratory Data Analysis - cusers
*/ ----------------------------------------

SELECT * FROM gp2.cusers;

--Stats on cusers

SELECT COUNT(*) FROM  
	(SELECT DISTINCT (user_id) FROM gp2.cusers) AS u;
--77 user_id (users or employees)

SELECT gender, COUNT(gender) 
FROM gp2.cusers
GROUP BY gender
ORDER BY gender ASC;
/*
gender       |count|
-------------+-----+
female       |   46|
male         |   20|
not specified|    9|
other        |    2|
*/

SELECT employment, COUNT(employment) 
FROM gp2.cusers
GROUP BY employment
ORDER BY employment ASC;
/*
employment|count|
----------+-----+
full_time |   76|
part_time |    1|
*/

SELECT position, COUNT(position) 
FROM gp2.cusers
GROUP BY position
ORDER BY count DESC;
/*
position                      |count|
------------------------------+-----+
Doctor                        |   24|
not specified                 |   14|
Nurse                         |   11|
Pharmacist Assistant          |    9|
Pharmacist                    |    4|
Warehouse Staff               |    2|
Business Admins               |    2|
Personal Assistance           |    1|
Finance & Accounting          |    1|
Midwife                       |    1|
General Manager               |    1|
Legal Officer                 |    1|
Development Director          |    1|
IT Supervisor                 |    1|
Marketing Staff               |    1|
Purchasing                    |    1|
President Director            |    1|
Warehouse Officer - Purchasing|    1|
*/

SELECT location, COUNT(location) 
FROM gp2.cusers
GROUP BY location
ORDER BY count DESC;
/*
location    |count|
------------+-----+
Clinic      |   38|
Office      |   25|
Nu Orange   |    6|
Celuk       |    4|
Gunung Catur|    4|
*/

SELECT department, COUNT(department) 
FROM gp2.cusers
GROUP BY department
ORDER BY count DESC;
/*
department    |count|
--------------+-----+
Medical       |   36|
Support Centre|   14|
Pharmacy      |   14|
not specified |   10|
PBF           |    3|
*/



/* ----------------------------------------
Exploratory Data Analysis - cschedules
*/ ----------------------------------------

SELECT * FROM gp2.cschedules;

--UNNEST cschedules (https://www.w3resource.com/PostgreSQL/postgresql_unnest-function.php)
SELECT * FROM gp2.cschedules;

--UNNEST user_id first
SELECT type, dates, time_start, time_end, timezone, time_planned, break_time, leave_type, UNNEST(user_id) AS user_id FROM gp2.cschedules;

--create new table that unnest user_id
CREATE TABLE gp2.u_cschedules AS
SELECT type, dates, time_start, time_end, timezone, time_planned, break_time, leave_type, UNNEST(user_id) AS user_id FROM gp2.cschedules;

SELECT * FROM gp2.u_cschedules;

--UNNEST the dates next
SELECT type, UNNEST(dates) AS dates, time_start, time_end, timezone, time_planned, break_time, leave_type, user_id FROM gp2.u_cschedules;

--create new table that unnest the dates
CREATE TABLE gp2.u2_cschedules AS
SELECT type, UNNEST(dates) AS dates, time_start, time_end, timezone, time_planned, break_time, leave_type, user_id FROM gp2.u_cschedules;

SELECT * FROM gp2.u2_cschedules;

/* if need to re-create the gp2.u_cschedules
DROP TABLE gp2.u_cschedules CASCADE;
DROP TABLE gp2.u2_cschedules CASCADE;
*/

--select u2_cschedules
SELECT * FROM gp2.u2_cschedules;

--fix the user_id by removing single quote (') character
SELECT COUNT (*) FROM gp2.u2_cschedules;
--195189 rows

--select query with temporary column user_id2 that does not contain the single quote
SELECT *, LEFT(SUBSTRING(user_id, 2, 10),-1) AS user_id2  FROM gp2.u2_cschedules;

--add column user_id2
ALTER TABLE gp2.u2_cschedules
ADD COLUMN user_id2 CHARACTER VARYING(16);

--update user_id2 with user_id without single quote
UPDATE gp2.u2_cschedules SET user_id2 = LEFT(SUBSTRING(user_id, 2, 10),-1);
--195189 rows updated

--select u2_cschedules to check added column user_id2
SELECT * FROM gp2.u2_cschedules;

--drop column user_id because it contains user_id with single quote
ALTER TABLE gp2.u2_cschedules
DROP COLUMN user_id;

--rename column user_id2 to user_id
ALTER TABLE gp2.u2_cschedules
RENAME COLUMN user_id2 TO user_id;

--select u_cschedules to check column user_id and that it does not have single quote
SELECT * FROM gp2.u2_cschedules;

--type & count
SELECT type, COUNT(type) AS count_type
FROM gp2.u2_cschedules
GROUP BY type
ORDER BY count_type DESC;
/*
type |count_type|
-----+----------+
work |    178904|
free |     13054|
leave|      3108|
fake |       123|
*/

--leave_type & count
SELECT leave_type, COUNT(leave_type) AS count_leave_type
FROM gp2.u2_cschedules
GROUP BY leave_type
ORDER BY count_leave_type DESC;
/*
leave_type   |count_leave_type|
-------------+----------------+
not specified|          192081|
day_off      |            2962|
sick         |              49|
compensatory |              38|
unpaid       |              35|
annual       |              21|
special      |               3|
*/

--break_time & count
SELECT break_time, COUNT(break_time) AS count_break_time
FROM gp2.u2_cschedules
GROUP BY break_time
ORDER BY count_break_time DESC;
/*
break_time|count_break_time|
----------+----------------+
      3600|          165123|
         0|           26329|
        60|             460|
      7200|               1|
          |               0|
*/

--time_planned & count
SELECT time_planned, COUNT(time_planned) AS count_time_planned
FROM gp2.u2_cschedules
GROUP BY time_planned
ORDER BY count_time_planned DESC;
/*
time_planned|count_time_planned|
------------+------------------+
       28800|            164526|
        7200|             12629|
       25200|              5489|
       32400|              5283|
           0|              3007|
       21600|              1628|
       18000|              1255|
       25140|               458|
       36000|               297|
       48600|                49|
       50400|                44|
       27000|                37|
       46800|                29|
       14400|                14|
       45000|                 4|
       39600|                 3|
       19800|                 2|
       35940|                 1|
       23400|                 1|
         300|                 1|
       43200|                 1|
            |                 0|
*/

--user_id & count
SELECT user_id, COUNT(user_id) AS count_user_id
FROM gp2.u2_cschedules
GROUP BY user_id
ORDER BY count_user_id DESC;
/*
user_id|count_user_id|
-------+-------------+
155509 |        11263|
146182 |        11049|
146166 |        11048|
157837 |        11003|
159207 |        11002|
157916 |        11001|
125721 |        11001|
125744 |        10996|
159217 |        10981|
160306 |        10974|
132484 |        10974|
138225 |        10974|
125748 |        10971|
126082 |        10971|
129675 |        10966|
83902  |         2019|
74135  |         1964|
74062  |         1960|
74138  |         1960|
74025  |         1960|
74027  |         1960|
88348  |         1819|
74042  |         1135|
88347  |         1093|
88357  |         1041|
75218  |         1004|
74053  |          835|
74049  |          815|
84509  |          730|
84699  |          730|
79738  |          604|
128325 |          553|
79765  |          507|
74461  |          469|
74054  |          458|
74556  |          457|
83885  |          436|
74052  |          426|
74465  |          424|
83888  |          405|
74050  |          396|
83884  |          389|
74639  |          376|
120694 |          289|
120696 |          286|
87864  |          265|
90711  |          251|
120666 |          238|
84541  |          208|
90377  |          183|
83893  |          173|
75952  |          170|
74044  |          156|
90710  |          120|
92930  |          115|
91338  |          111|
90862  |          110|
83894  |          102|
75963  |           68|
84932  |           37|
75848  |           31|
75986  |           29|
84490  |           25|
121592 |           25|
84517  |           18|
85877  |           16|
75983  |           12|
75955  |           12|
93607  |           12|
75839  |           10|
75914  |            9|
75834  |            6|
74745  |            3|
*/



/* COUNTER CHECKS */
SELECT * FROM gp2.cschedules;
/*
For user_id = '74465'
dates are
2021-11-05
2021-11-10
2021-11-18
2021-11-25
2021-11-30
*/

SELECT DISTINCT (dates) FROM gp2.u2_cschedules 
WHERE 
	user_id = '74465' AND 
	leave_type = 'day_off' 
ORDER BY dates ASC;

SELECT * FROM gp2.u2_cschedules 
WHERE 
	dates IN ('2021-11-05', '2021-11-10', '2021-11-18', '2021-11-25', '2021-11-30') AND 
	user_id = '74465';
/* COUNTER CHECKS */



/* ----------------------------------------
Exploratory Data Analysis - cpayroll
*/ ----------------------------------------

SELECT * FROM gp2.cpayroll;

--Stats on cpayroll

SELECT DISTINCT (status), COUNT (status)
FROM gp2.cpayroll
GROUP BY status
ORDER BY count DESC;
/*
status  |count|
--------+-----+
approved|  343|
draft   |    5|
*/

SELECT DISTINCT (data_salary_basic_type), COUNT (data_salary_basic_type)
FROM gp2.cpayroll
GROUP BY data_salary_basic_type
ORDER BY count DESC;
/*
data_salary_basic_type|count|
----------------------+-----+
monthly               |  199|
daily                 |  129|
hourly                |   20|
*/



/* ----------------------------------------
Exploratory Data Analysis - cattendance
*/ ----------------------------------------

SELECT * FROM gp2.cattendance;

--Stats on cattendance

SELECT DISTINCT (source), COUNT (source) 
FROM gp2.cattendance
GROUP BY SOURCE
ORDER BY count DESC;
/*
source  |count|
--------+-----+
mobile  |12075|
frontend|  560|
*/

SELECT DISTINCT ("case"), COUNT ("case") 
FROM gp2.cattendance
GROUP BY "case"
ORDER BY count DESC;
/*
case |count|
-----+-----+
IN   | 6545|
OUT  | 6083|
BREAK|    7|
*/

SELECT DISTINCT (location), COUNT (location) 
FROM gp2.cattendance
GROUP BY location
ORDER BY count DESC;
/*
location     |count|
-------------+-----+
not specified| 3625|
Clinic       | 3533|
Nu Orange    | 2380|
Office       | 1439|
Gunung Catur | 1274|
Osadha Belega|  360|
Celuk        |   24|
*/



/* ----------------------------------------
Exploratory Data Analysis - cleaverequest
*/ ----------------------------------------

SELECT * FROM gp2.cleaverequest;

--Stats on cleaverequest

SELECT DISTINCT (status), COUNT (status)
FROM gp2.cleaverequest
GROUP BY status
ORDER BY COUNT DESC;
/*
status  |count|
--------+-----+
accepted|   49|
pending |    1|
rejected|    1|
*/

--UNNEST cleaverequest, below are the specified columns
SELECT user_id, first_name, last_name, type, leave_type, dates, time_start, time_end, timezone, status, created_at 
FROM gp2.cleaverequest;

--UNNEST dates
SELECT user_id, first_name, last_name, type, leave_type, UNNEST(dates) AS dates, time_start, time_end, timezone, status, created_at 
FROM gp2.cleaverequest;

--create new table that unnest dates
CREATE TABLE gp2.u_cleaverequest AS
SELECT user_id, first_name, last_name, type, leave_type, UNNEST(dates) AS dates, time_start, time_end, timezone, status, created_at 
FROM gp2.cleaverequest;

SELECT * FROM gp2.u_cleaverequest;

/* if need to re-create the gp2.u_cleaverequest
DROP TABLE gp2.u_cleaverequest CASCADE;
*/

--leave_type by count
SELECT leave_type, COUNT(leave_type) AS count_leave_type
FROM gp2.u_cleaverequest
GROUP BY leave_type
ORDER BY count_leave_type DESC;
/*
leave_type  |count_leave_type|
------------+----------------+
compensatory|              33|
sick        |              26|
day_off     |              13|
annual      |               9|
unpaid      |               8|
special     |               3|
*/

--leave_type is 'sick', user_id
SELECT user_id, COUNT(leave_type) AS count_leave_type
FROM gp2.u_cleaverequest
WHERE leave_type = 'sick'
GROUP BY user_id, leave_type
ORDER BY count_leave_type DESC;
/*
user_id|count_leave_type|
-------+----------------+
74049  |              15|
88357  |               8|
74044  |               2|
74054  |               1|
*/

--leave_type is 'sick', user_id, status=accepted
SELECT user_id, COUNT(leave_type) AS count_leave_type
FROM gp2.u_cleaverequest
WHERE 
	leave_type = 'sick' AND
	status = 'accepted'
GROUP BY user_id, leave_type
ORDER BY count_leave_type DESC;
/*
user_id|count_leave_type|
-------+----------------+
74049  |              15|
88357  |               2|
74044  |               2|
74054  |               1|
*/

--leave_type is 'unpaid', user_id
SELECT user_id, COUNT(leave_type) AS count_leave_type
FROM gp2.u_cleaverequest
WHERE leave_type = 'unpaid'
GROUP BY user_id, leave_type
ORDER BY count_leave_type DESC;
/*
user_id|count_leave_type|
-------+----------------+
88357  |               7|
74465  |               1|
*/

--leave_type is 'unpaid', user_id, status=accepted
SELECT user_id, COUNT(leave_type) AS count_leave_type
FROM gp2.u_cleaverequest
WHERE 
	leave_type = 'unpaid' AND
	status = 'accepted'
GROUP BY user_id, leave_type
ORDER BY count_leave_type DESC;
/*
user_id|count_leave_type|
-------+----------------+
88357  |               7|
74465  |               1|
*/



/* 
-- Updated Tables 
*/
SELECT * FROM gp2.cusers;
SELECT * FROM gp2.u2_cschedules;
SELECT * FROM gp2.cpayroll;
SELECT * FROM gp2.cattendance;
SELECT * FROM gp2.u_cleaverequest;

--list the tables in schema gp2
SELECT table_name FROM information_schema.TABLES
WHERE table_schema = 'gp2'
ORDER BY table_name;
/*
table_name     |
---------------+
attendance     |
cattendance    |
cleaverequest  |
cpayroll       |
cschedules     |
cusers         |
leaverequest   |
payroll        |
schedules      |
u2_cschedules  |
u_cleaverequest|
u_cschedules   |
users          |
*/

SELECT table_name FROM information_schema.TABLES
WHERE 
	table_schema = 'gp2' AND
	table_name IN ('cusers', 'cpayroll', 'cattendance', 'u2_cschedules', 'u_cleaverequest')
ORDER BY table_name;
/*
table_name     |
---------------+
cattendance    |
cpayroll       |
cusers         |
u2_cschedules  |
u_cleaverequest|
*/



