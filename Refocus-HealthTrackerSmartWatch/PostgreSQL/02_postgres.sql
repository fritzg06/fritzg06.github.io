-- =============================================================================
-- Author: Fritz Gerald Reyes
-- Create date: 11 Oct 2023
-- Update date: 13 Oct 2023
-- Description: Refocus Final Project (Set 1)
-- =============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ POSTGRES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*
1.	Calculate the percentage of income by state and corruption 
convictions per capita in relation to the total amount of income by 
state and corruption convictions per capita. 

Is there any observable connection between income by state and 
corruption convictions per capita?
*/


--Sum of Average Income of all states
SELECT SUM(average_income) AS sum_avg_income
FROM state_income;
/*
sum_avg_income|
--------------+
       3157304|
*/

--Group by State and aggregate by Sum of Avg Income, Calculate
--Percent of Income of USA states
CREATE TABLE tb_summary_income AS
SELECT 
	a.state_usa, 
	a.sum_avg_income, 
	(a.sum_avg_income/3157304*100) AS percent_income_usa
FROM
	(
	SELECT 
		state_usa, 
		SUM(average_income) AS sum_avg_income
	FROM state_income
	GROUP BY state_usa
	ORDER BY sum_avg_income DESC
	) a
;
--Updated Rows 50

SELECT * FROM tb_summary_income
LIMIT 10;
/*
state_usa    |sum_avg_income|percent_income_usa    |
-------------+--------------+----------------------+
Maryland     |         89392|2.83127630408728459500|
Massachusetts|         82427|2.61067670392208035700|
New Jersey   |         81740|2.58891763352531146800|
California   |         80440|2.54774326450668038300|
Connecticut  |         79287|2.51122476644630989000|
New Hampshire|         78676|2.49187281300755328000|
Hawaii       |         78084|2.47312263880829973900|
Washington   |         77338|2.44949488550991605500|
Alaska       |         76440|2.42105289829550781300|
Colorado     |         76240|2.41471837998494918400|
*/


--Sum of Convictions of all states
SELECT SUM(convictions_per_capita) AS sum_convictions
FROM corruption_convictions_per_capita;
/*
sum_convictions|
---------------+
          84.73|
*/

--Group by State and aggregate by Sum of Avg Income, Calculate
--Percent of Income of USA states
CREATE TABLE tb_summary_convictions AS
SELECT 
	b.state_usa, 
	b.sum_convictions, 
	(b.sum_convictions/84.73*100) AS percent_convictions
FROM
	(
	SELECT 
		state_usa, 
		SUM(convictions_per_capita) AS sum_convictions
	FROM corruption_convictions_per_capita
	GROUP BY state_usa
	ORDER BY sum_convictions DESC
	) b
;
--Updated Rows 50

SELECT * FROM tb_summary_convictions
LIMIT 10;
/*
state_usa    |sum_convictions|percent_convictions   |
-------------+---------------+----------------------+
Rhode Island |           8.35|9.85483299893780243100|
West Virginia|           5.64|6.65643809748613242100|
Louisiana    |           3.72|4.39041661749085329900|
Tennessee    |           3.69|4.35501003186592706200|
Oklahoma     |           3.23|3.81210905228372477300|
Arkansas     |           3.02|3.56426295290924111900|
Washington   |           2.53|2.98595538770211259300|
Mississippi  |           2.43|2.86793343561902513900|
Massachusetts|           2.27|2.67909831228608521200|
Alabama      |           2.15|2.53747196978638026700|
*/


--Inner Join the two tables 'tb_summary_income' & 
--'tb_summary_convictions' to try see a correlation between states
SELECT 
	i.state_usa,
	i.sum_avg_income,
	i.percent_income_usa,
	c.sum_convictions,
	c.percent_convictions
FROM tb_summary_income i
INNER JOIN tb_summary_convictions c
	ON i.state_usa = c.state_usa
ORDER BY i.sum_avg_income DESC;
/*
state_usa    |sum_avg_income|percent_income_usa    |sum_convictions|percent_convictions   |
-------------+--------------+----------------------+---------------+----------------------+
Maryland     |         89392|2.83127630408728459500|           1.38|1.62870293874660686900|
Massachusetts|         82427|2.61067670392208035700|           2.27|2.67909831228608521200|
New Jersey   |         81740|2.58891763352531146800|           1.90|2.24241708957866163100|
California   |         80440|2.54774326450668038300|           1.09|1.28643927770565325200|
Connecticut  |         79287|2.51122476644630989000|           2.01|2.37224123687005783100|
New Hampshire|         78676|2.49187281300755328000|           0.51|0.60191195562374601700|
Hawaii       |         78084|2.47312263880829973900|           0.43|0.50749439395727605300|
Washington   |         77338|2.44949488550991605500|           2.53|2.98595538770211259300|
Alaska       |         76440|2.42105289829550781300|           1.06|1.25103269208072701500|
Colorado     |         76240|2.41471837998494918400|           0.80|0.94417561666469963400|
*/





/*
2.	Identify the states with the highest and lowest average income.
*/

--States with Highest Average Income
SELECT 
	state_usa, 
	average_income
FROM state_income
ORDER BY average_income DESC
LIMIT 10;
/*
state_usa    |average_income|
-------------+--------------+
Maryland     |         89392|
Massachusetts|         82427|
New Jersey   |         81740|
California   |         80440|
Connecticut  |         79287|
New Hampshire|         78676|
Hawaii       |         78084|
Washington   |         77338|
Alaska       |         76440|
Colorado     |         76240|
*/


--States with Lowest Average Income
SELECT * FROM
	(
	SELECT 
		state_usa, 
		average_income
	FROM state_income
	ORDER BY average_income ASC
	LIMIT 10
	) a
ORDER BY average_income DESC;
/*
state_usa     |average_income|
--------------+--------------+
Idaho         |         53545|
South Carolina|         52536|
Oklahoma      |         51424|
Alabama       |         51113|
Louisiana     |         50686|
Kentucky      |         50675|
Arkansas      |         48829|
New Mexico    |         48701|
Mississippi   |         47131|
West Virginia |         46254|
*/





/*
3.	Identify the states with the highest and lowest corruption 
conviction rates.
*/

--States with Highest Corruption Conviction per Capita
SELECT * 
FROM corruption_convictions_per_capita
ORDER BY convictions_per_capita DESC
LIMIT 10;
/*
state_usa    |convictions_per_capita|
-------------+----------------------+
Rhode Island |                  8.35|
West Virginia|                  5.64|
Louisiana    |                  3.72|
Tennessee    |                  3.69|
Oklahoma     |                  3.23|
Arkansas     |                  3.02|
Washington   |                  2.53|
Mississippi  |                  2.43|
Massachusetts|                  2.27|
Alabama      |                  2.15|
*/


--States with Lowest Corruption Conviction per Capita
SELECT * FROM 
	(
	SELECT * 
	FROM corruption_convictions_per_capita
	ORDER BY convictions_per_capita ASC
	LIMIT 10
	) a
ORDER BY convictions_per_capita DESC;
/*
state_usa    |convictions_per_capita|
-------------+----------------------+
South Dakota |                  0.87|
Colorado     |                  0.80|
Minnesota    |                  0.68|
Iowa         |                  0.58|
North Dakota |                  0.57|
Nebraska     |                  0.57|
New Hampshire|                  0.51|
Maine        |                  0.48|
Vermont      |                  0.44|
Hawaii       |                  0.43|
*/


--States with Highest Corruption Conviction Rates
SELECT 
	b.state_usa,  
	(b.sum_convictions/84.73*100) AS percent_convictions
FROM
	(
	SELECT 
		state_usa, 
		SUM(convictions_per_capita) AS sum_convictions
	FROM corruption_convictions_per_capita
	GROUP BY state_usa
	ORDER BY sum_convictions DESC
	) b
ORDER BY percent_convictions DESC
LIMIT 10;
/*
state_usa    |percent_convictions   |
-------------+----------------------+
Rhode Island |9.85483299893780243100|
West Virginia|6.65643809748613242100|
Louisiana    |4.39041661749085329900|
Tennessee    |4.35501003186592706200|
Oklahoma     |3.81210905228372477300|
Arkansas     |3.56426295290924111900|
Washington   |2.98595538770211259300|
Mississippi  |2.86793343561902513900|
Massachusetts|2.67909831228608521200|
Alabama      |2.53747196978638026700|
*/


--States with Lowest Corruption Conviction Rates
SELECT *
FROM 
	(
	SELECT 
		b.state_usa,  
		(b.sum_convictions/84.73*100) AS percent_convictions
	FROM
		(
		SELECT 
			state_usa, 
			SUM(convictions_per_capita) AS sum_convictions
		FROM corruption_convictions_per_capita
		GROUP BY state_usa
		ORDER BY sum_convictions ASC
		) b
		LIMIT 10
) c
ORDER BY c.percent_convictions DESC;
/*
state_usa    |percent_convictions   |
-------------+----------------------+
South Dakota |1.02679098312286085200|
Colorado     |0.94417561666469963400|
Minnesota    |0.80254927416499468900|
Iowa         |0.68452732208190723500|
Nebraska     |0.67272512687359848900|
North Dakota |0.67272512687359848900|
New Hampshire|0.60191195562374601700|
Maine        |0.56650536999881978000|
Vermont      |0.51929658916558479900|
Hawaii       |0.50749439395727605300|
*/

-- END OF FILE --