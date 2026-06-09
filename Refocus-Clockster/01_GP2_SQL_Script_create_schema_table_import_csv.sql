-- =============================================================================
-- Author: Fritz Gerald Reyes
-- Create date: 22 Feb 2023
-- Update date: 25 Feb 2023
-- Description: Refocus Group Project 2 (version 1) - Pre-Work
-- =============================================================================


-- =============================================================================
-- PRE-WORK
-- =============================================================================

--Create Schema
CREATE SCHEMA gp2
AUTHORIZATION postgres;

--To drop the table and recreate
/*
DROP TABLE gp2.attendance CASCADE;
DROP TABLE gp2.leaverequest CASCADE;
DROP TABLE gp2.payroll CASCADE;
DROP TABLE gp2.schedules CASCADE;
DROP TABLE gp2.users CASCADE;
*/

--Create Table
CREATE TABLE gp2.attendance (
	user_id CHARACTER VARYING(6) NOT NULL,
	first_name CHARACTER VARYING(20),
	last_name CHARACTER VARYING(20),
	location CHARACTER VARYING(20),
	date DATE,
	time TIME WITHOUT TIME ZONE,
	timezone CHARACTER VARYING(6),
	"case" CHARACTER VARYING(5),
	source CHARACTER VARYING(8)
);

CREATE TABLE gp2.leaverequest (
	user_id CHARACTER VARYING(16),
	first_name CHARACTER VARYING(20),
	last_name CHARACTER VARYING(20),
	type CHARACTER VARYING(10),
	leave_type CHARACTER VARYING(12),
	dates DATE ARRAY,
	time_start TIME WITHOUT TIME ZONE,
	time_end TIME WITHOUT TIME ZONE,
	timezone CHARACTER VARYING(6),
	status CHARACTER VARYING(8),
	created_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE gp2.payroll (
	user_id CHARACTER VARYING(6),
	first_name CHARACTER VARYING(20),
	last_name CHARACTER VARYING(20),
	date_start DATE,
	date_end DATE,
	ctc DOUBLE PRECISION,
	net_pay DOUBLE PRECISION,
	gross_pay DOUBLE PRECISION,
	data_salary_basic_rate INTEGER,
	data_salary_basic_type CHARACTER VARYING(7),
	currency CHARACTER VARYING(8),
	status CHARACTER VARYING(8),
	created_at TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE gp2.schedules (
	"type" CHARACTER VARYING(5),
	dates DATE ARRAY,
	time_start TIME WITHOUT TIME ZONE,
	time_end TIME WITHOUT TIME ZONE,
	timezone CHARACTER VARYING(6),
	time_planned INTEGER,
	break_time INTEGER,
	leave_type CHARACTER VARYING(16),
	user_id CHARACTER VARYING(50) ARRAY
);

CREATE TABLE gp2.users (
	user_id CHARACTER VARYING(6),
	first_name CHARACTER VARYING(20),
	last_name CHARACTER VARYING(20),
	gender CHARACTER VARYING(16),
	date_birth DATE,
	date_hire DATE,
	date_leave DATE,
	employment CHARACTER VARYING(12),
	position CHARACTER VARYING(50),
	location CHARACTER VARYING(20),
	department CHARACTER VARYING(20),
	created_at TIMESTAMP WITHOUT TIME ZONE
);

--Import CSV Files (Need to run PgAdmin as Administrator to avoid error 'Columns')
--NOTE: Some CSV files need to be fixed or cleaned up before import to PostgreSQL
/*
Import attendance.csv to gp2.attendance
Import leave_requests_fix.csv to gp2.leaverequest
Import payroll.csv to gp2.payroll
Import schedules_fix2a.csv to gp2.schedules
Import users.csv to gp2.users
*/


--Post Cleanup after import

--attendance table / first_name and last_name
SELECT * FROM gp2.attendance WHERE first_name = '""';
SELECT * FROM gp2.attendance WHERE last_name = '""';

UPDATE gp2.attendance SET first_name = '' where first_name = '""';
UPDATE gp2.attendance SET last_name = '' where last_name = '""';

--users table / first_name and last_name
SELECT * FROM gp2.users WHERE first_name = '""';
SELECT * FROM gp2.users WHERE last_name = '""';

UPDATE gp2.users SET first_name = '' where first_name = '""';
UPDATE gp2.users SET last_name = '' where last_name = '""';


--To delete values from tables if need to re-import
/*
--DELETE FROM gp2.attendance;
--DELETE FROM gp2.leaverequest;
--DELETE FROM gp2.payroll;
--DELETE FROM gp2.schedules;
--DELETE FROM gp2.users;
*/


--SELECT queries on tables
SELECT * FROM gp2.attendance;
SELECT * FROM gp2.leaverequest;
SELECT * FROM gp2.payroll;
SELECT * FROM gp2.schedules;
SELECT * FROM gp2.users;