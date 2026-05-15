-- =============================================================================
-- Author: Fritz Gerald Reyes
-- Create date: 27 Feb 2023
-- Update date: 27 Feb 2023
-- Description: Refocus Group Project 2 (version 1) - Pre-Checks / Cleanup
-- =============================================================================


-- =============================================================================
-- PRE-CHECKS / CLEANUP
-- =============================================================================

/* ------------------------------
users table
*/ ------------------------------

--Create copy of users table (cusers)
CREATE TABLE gp2.cusers AS
SELECT * FROM gp2.users;

SELECT * FROM gp2.cusers;

/* To drop cusers table if need to re-create
DROP TABLE gp2.cusers CASCADE;
*/

--cusers table / gender column
SELECT DISTINCT (gender) FROM gp2.cusers ORDER BY gender ASC;
/*
gender|
------+
female|
male  |
other |
      |
*/

SELECT COUNT(*) FROM gp2.cusers WHERE gender IS NULL;
--9 rows

UPDATE gp2.cusers SET gender = 'not specified' WHERE gender IS NULL;
--9 rows updated

--cusers table / position column
SELECT DISTINCT (position) FROM gp2.cusers ORDER BY "position" ASC;
/*
position                      |
------------------------------+
Admin Bisnis                  |
Apoteker                      |
Asisten Apoteker              |
Bidan                         |
Direktur Pengembangan         |
Direktur Utama                |
Dokter                        |
Finance & Accounting          |
General Manager               |
IT Spv                        |
Legal Officer                 |
Marketing Staff               |
Perawat                       |
Personal Assistance           |
Purchasing                    |
Warehouse Officer - Purchasing|
Warehouse Staff               |
                              |
*/

SELECT COUNT(*) FROM gp2.cusers WHERE position IS NULL;
--14 rows

UPDATE gp2.cusers SET position = 'not specified' WHERE position IS NULL;
--14 rows updated

--Translate the position to english (use https://translate.google.com)
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Admin Bisnis';
--2 rows
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Apoteker';
--4 rows
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Asisten Apoteker';
--9 rows
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Bidan';
--1 row
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Direktur Pengembangan';
--1 row
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Direktur Utama';
--1 row
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Dokter';
--24 rows
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'IT Spv';
--1 row
SELECT COUNT (*) FROM gp2.cusers WHERE position = 'Perawat';
--11 rows

UPDATE gp2.cusers SET position = 'Business Admins' WHERE position = 'Admin Bisnis';
--2 rows updated
UPDATE gp2.cusers SET position = 'Pharmacist' WHERE position = 'Apoteker';
--4 rows updated
UPDATE gp2.cusers SET position = 'Pharmacist Assistant' WHERE position = 'Asisten Apoteker';
--9 rows updated
UPDATE gp2.cusers SET position = 'Midwife' WHERE position = 'Bidan';
--1 row updated
UPDATE gp2.cusers SET position = 'Development Director' WHERE position = 'Direktur Pengembangan';
--1 row updated
UPDATE gp2.cusers SET position = 'President Director' WHERE position = 'Direktur Utama';
--1 row updated
UPDATE gp2.cusers SET position = 'Doctor' WHERE position = 'Dokter';
--24 rows updated
UPDATE gp2.cusers SET position = 'IT Supervisor' WHERE position = 'IT Spv';
--1 row updated
UPDATE gp2.cusers SET position = 'Nurse' WHERE position = 'Perawat';
--11 rows updated


--cusers table / location column
SELECT DISTINCT (location) FROM gp2.cusers ORDER BY location ASC;
/*
location    |
------------+
Celuk       |
Clinic      |
Gunung Catur|
Nu Orange   |
Office      |
*/
--no duplicates / typos to fix

--cusers table / department column
SELECT DISTINCT (department) FROM gp2.cusers ORDER BY department ASC;
/*
department    |
--------------+
Medical       |
PBF           |
Pharmacy      |
Support Centre|
              |
*/

SELECT COUNT(*) FROM gp2.cusers WHERE department IS NULL;
--10 rows

UPDATE gp2.cusers SET department = 'not specified' WHERE department IS NULL;
--10 rows updated

--cusers table / employment column
SELECT DISTINCT (employment) FROM gp2.cusers ORDER BY employment ASC;
/*
employment|
----------+
part_time |
          |
*/

SELECT COUNT(*) FROM gp2.cusers WHERE employment IS NULL;
--76 rows

--Assumption: blanks in employment will be considered as full_time
UPDATE gp2.cusers SET employment = 'full_time' WHERE employment IS NULL;
--76 rows updated


/* ------------------------------
schedules table
*/ ------------------------------

--Create copy of schedules table (cschedules)
CREATE TABLE gp2.cschedules AS
SELECT * FROM gp2.schedules;

SELECT * FROM gp2.cschedules;

/* To drop cschedules table if need to re-create
DROP TABLE gp2.cschedules CASCADE;
*/

SELECT * FROM gp2.cschedules;

SELECT DISTINCT (type) FROM gp2.cschedules ORDER BY type;
/*
type |
-----+
fake |
free |
leave|
work |
*/
--no duplicates / typos to fix

SELECT DISTINCT (leave_type) FROM gp2.cschedules ORDER BY leave_type;
/*
leave_type  |
------------+
annual      |
compensatory|
day_off     |
sick        |
special     |
unpaid      |
            |
*/

SELECT COUNT(*) FROM gp2.cschedules WHERE leave_type IS NULL;
--3164 rows

UPDATE gp2.cschedules SET leave_type = 'not specified' WHERE leave_type IS NULL;
--3164 rows updated


/* ------------------------------
payroll table
*/ ------------------------------

--Create copy of payroll table (cpayroll)
CREATE TABLE gp2.cpayroll AS
SELECT * FROM gp2.payroll;

SELECT * FROM gp2.cpayroll;

/* To drop cpayroll table if need to re-create
DROP TABLE gp2.cpayroll CASCADE;
*/

SELECT DISTINCT (data_salary_basic_type) FROM gp2.cpayroll ORDER BY data_salary_basic_type ASC;
/*
data_salary_basic_type|
----------------------+
daily                 |
hourly                |
monthly               |
*/

SELECT DISTINCT (currency) FROM gp2.cpayroll ORDER BY currency ASC;
/*
currency|
--------+
IDR     |
        |
*/

SELECT COUNT(*) FROM gp2.cpayroll WHERE currency IS NULL;
--96 rows

--Assumption: blanks in currency will also be considered as IDR
UPDATE gp2.cpayroll SET currency = 'IDR' WHERE currency IS NULL;
--96 rows updated

SELECT DISTINCT (status) FROM gp2.cpayroll ORDER BY status;
/*
status  |
--------+
approved|
draft   |
*/

SELECT COUNT(*) FROM gp2.cpayroll WHERE ctc IS NULL;
--96 rows

SELECT COUNT(*) FROM gp2.cpayroll WHERE net_pay IS NULL;
--96 rows

SELECT COUNT(*) FROM gp2.cpayroll WHERE gross_pay IS NULL;
--96 rows

SELECT COUNT(*) FROM gp2.cpayroll WHERE data_salary_basic_rate IS NULL;
--0 rows


/* ------------------------------
attendance table
*/ ------------------------------

--Create copy of attendance table (cattendance)
CREATE TABLE gp2.cattendance AS
SELECT * FROM gp2.attendance;

SELECT * FROM gp2.cattendance;

/* To drop cattendance table if need to re-create
DROP TABLE gp2.cattendance CASCADE;
*/

SELECT DISTINCT (location) FROM gp2.cattendance ORDER BY location;
/*
location     |
-------------+
Celuk        |
Clinic       |
Gunung Catur |
Nu Orange    |
Office       |
OSADHA BELEGA|
             |
*/

SELECT COUNT(*) FROM gp2.cattendance WHERE location = 'OSADHA BELEGA';
--360 rows

UPDATE gp2.cattendance SET location = 'Osadha Belega' WHERE location = 'OSADHA BELEGA';
--360 rows updated

SELECT COUNT(*) FROM gp2.cattendance WHERE location IS NULL;
--3625 rows

UPDATE gp2.cattendance SET location = 'not specified' WHERE location IS NULL;
--3625 rows updated

SELECT DISTINCT ("case") FROM gp2.cattendance ORDER BY "case";
/*
case |
-----+
BREAK|
IN   |
OUT  | 
*/

SELECT DISTINCT (source) FROM gp2.cattendance ORDER BY source;
/*
source  |
--------+
frontend|
mobile  |
*/

SELECT COUNT(*) FROM gp2.cattendance WHERE date IS NULL;
--0 rows

SELECT COUNT(*) FROM gp2.cattendance WHERE time IS NULL;
--0 rows

SELECT COUNT(*) FROM gp2.cattendance WHERE timezone IS NULL;
--0 rows


/* ------------------------------
leaverequest table
*/ ------------------------------

--Create copy of leaverequest table (cleaverequest)
CREATE TABLE gp2.cleaverequest AS
SELECT * FROM gp2.leaverequest;

SELECT * FROM gp2.cleaverequest;

/* To drop cleaverequest table if need to re-create
DROP TABLE gp2.cleaverequest CASCADE;
*/

SELECT COUNT(*) FROM gp2.cleaverequest WHERE user_id IS NULL;
--2 rows

UPDATE gp2.cleaverequest SET user_id = 'not specified' WHERE user_id IS NULL;
--2 rows updated

SELECT DISTINCT (type) FROM gp2.cleaverequest ORDER BY type ASC;
/*
type |
-----+
leave|
*/

SELECT DISTINCT (leave_type) FROM gp2.cleaverequest ORDER BY leave_type ASC;
/*
leave_type  |
------------+
annual      |
compensatory|
day_off     |
sick        |
special     |
unpaid      |
*/

SELECT DISTINCT (status) FROM gp2.cleaverequest ORDER BY status ASC;
/*
status  |
--------+
accepted|
pending |
rejected|
*/



/* ------------------------------
SELECT the "c" tables
*/ ------------------------------
SELECT * FROM gp2.cusers;
SELECT * FROM gp2.cschedules;
SELECT * FROM gp2.cpayroll;
SELECT * FROM gp2.cattendance;
SELECT * FROM gp2.cleaverequest;


