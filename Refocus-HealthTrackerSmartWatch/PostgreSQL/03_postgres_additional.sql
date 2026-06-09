-- =============================================================================
-- Author: Fritz Gerald Reyes
-- Create date: 11 Oct 2023
-- Update date: 18 Oct 2023
-- Description: Refocus Final Project (Set 1)
-- =============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ POSTGRES / Additional Queries ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--Inner Join the two tables 'tb_summary_income' & 
--'tb_summary_convictions' to try see a correlation between states
--but create a table to be exported to CSV
CREATE TABLE tb_summary_income_convictions AS 
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
--Updated Rows 50

SELECT * FROM tb_summary_income_convictions;
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



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ POSTGRES / Additional Tasks ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* 
Q2. Create a heat map showing the relationship between population density and property prices.
*/

/*
Need to join first following tables:
-population
-property_prices
*/

CREATE TABLE tb_population_propertyprices AS
SELECT 
	p.state_usa,
	p.estimate,
	pp.avg_price,
	pp.min_price,
	pp.max_price
FROM population p
INNER JOIN property_prices pp
	ON p.state_usa = pp.state_usa;
--Updated Rows 50

SELECT * FROM tb_population_propertyprices; 
/*
state_usa     |estimate|avg_price|min_price|max_price|
--------------+--------+---------+---------+---------+
Alabama       | 4903185|  1797.50|  1200.00|  2500.00|
Alaska        |  731545|  2684.00|  2000.00|  3500.00|
Arizona       | 7278717|  2356.75|  1500.00|  4000.00|
Arkansas      | 3017804|  1499.25|  1000.00|  2500.00|
*/


/*
Q5. Use SQL to calculate the average profit for competitors in each state.
*/

--Create new table tb_competitors_profit_statev
CREATE TABLE tb_competitors_profit_state AS
SELECT state_usa, AVG(profit) AS avg_competitors_profit 
FROM competitors
GROUP BY state_usa
ORDER BY avg_competitors_profit DESC;
--Updated Rows 41

SELECT * FROM tb_competitors_profit_state;
/*
state_usa    |avg_competitors_profit|
-------------+----------------------+
Arizona      |  2942282.990000000000|
Delaware     |  2265218.990000000000|
Oklahoma     |  2242746.132857142857|
Alaska       |  1969126.590000000000|
*/


/*
Q6. Create a scatterplot that shows the correlation between property prices and state income.
*/

CREATE TABLE tb_propertyprice_stateincome AS
SELECT 
	pp.state_usa,
	pp.avg_price,
	si.average_income 
FROM property_prices pp 
INNER JOIN state_income si 
	ON pp.state_usa = si.state_usa;
--Updated Rows 50

SELECT * FROM tb_propertyprice_stateincome;
/*
state_usa     |avg_price|average_income|
--------------+---------+--------------+
Alabama       |  1797.50|         51113|
Alaska        |  2684.00|         76440|
Arizona       |  2356.75|         62283|
Arkansas      |  1499.25|         48829|
*/


/*
Q8. Use Python to calculate the average, minimum, and maximum corruption levels
for different regions of the country.
*/

--Create new table for the data set of USA States to Region (from Kaggle)
CREATE TABLE tb_state_region (
state CHARACTER VARYING (30) PRIMARY KEY NOT NULL,
state_code CHARACTER VARYING (2),
region CHARACTER VARYING (10),
division CHARACTER VARYING (20)
);
--Updated Rows 0

--Import CSV Data states.csv (https://www.kaggle.com/datasets/omer2040/usa-states-to-region/)

--View the state & region table
SELECT * FROM tb_state_region;
/*
state               |state_code|region   |division          |
--------------------+----------+---------+------------------+
Alaska              |AK        |West     |Pacific           |
Alabama             |AL        |South    |East South Central|
Arkansas            |AR        |South    |West South Central|
Arizona             |AZ        |West     |Mountain          |
*/

/*Join the two tables / Create a table for the Join 
corruption_convictions_per_capita
tb_state_region
*/
CREATE TABLE tb_corruption_region AS
	(
	SELECT * 
	FROM corruption_convictions_per_capita a
	LEFT JOIN tb_state_region b
		ON a.state_usa = b.state
	);
--Updated Rows 50

SELECT * FROM tb_corruption_region;
/*
state_usa     |convictions_per_capita|state         |state_code|region   |division          |
--------------+----------------------+--------------+----------+---------+------------------+
Alabama       |                  2.15|Alabama       |AL        |South    |East South Central|
Alaska        |                  1.06|Alaska        |AK        |West     |Pacific           |
Arizona       |                  1.40|Arizona       |AZ        |West     |Mountain          |
Arkansas      |                  3.02|Arkansas      |AR        |South    |West South Central|
*/


/*
Q10. Use SQL to create a new dataset that only includes
states with a population above a certain threshold.
*/

--View sample data from population table
SELECT * FROM population
ORDER BY estimate DESC
LIMIT 4;
/*
state_usa |estimate|
----------+--------+
California|39512223|
Texas     |28995881|
Florida   |21477737|
New York  |19453561|
*/

--Determine the average population value across all states

SELECT MIN(estimate) AS min_population
FROM population;
/*
min_population|
--------------+
        578759|
*/

SELECT MAX(estimate) AS max_population
FROM population;
/*
max_population|
--------------+
      39512223|
*/

SELECT AVG(estimate) AS avg_population
FROM population;
/*
avg_population      |
--------------------+
6436069.078431372549|
*/

--We will use the avg_population as the threshold
CREATE TABLE tb_population_gt_avg AS
SELECT * FROM population
WHERE estimate > 
	(SELECT AVG(estimate) AS avg_population FROM population)
ORDER BY estimate DESC;
--Updated Rows 17

SELECT * FROM tb_population_gt_avg;
/*
state_usa     |estimate|
--------------+--------+
California    |39512223|
Texas         |28995881|
Florida       |21477737|
New York      |19453561|
Pennsylvania  |12801989|
Illinois      |12671821|
Ohio          |11689100|
Georgia       |10617423|
North Carolina|10488084|
Michigan      | 9986857|
New Jersey    | 8882190|
Virginia      | 8535519|
Washington    | 7614893|
Arizona       | 7278717|
Massachusetts | 6892503|
Tennessee     | 6829174|
Indiana       | 6732219|
*/


/*
Q11. Use SQL to calculate the total healthcare spending for each state 
and compare the results to the state's population.
*/

/*
SQL Join for the following tables:
-health_spending
-population
*/
CREATE TABLE tb_spending_population AS
SELECT 
	hs.state_usa, 
	hs.avg_spending,
	p.estimate
FROM health_spending hs
JOIN population p 
	ON hs.state_usa = p.state_usa;
--Updated Rows 50

SELECT * FROM tb_spending_population;
/*
state_usa     |avg_spending|estimate|
--------------+------------+--------+
Alabama       |      200.50| 4903185|
Alaska        |      300.25|  731545|
Arizona       |      150.00| 7278717|
Arkansas      |      175.00| 3017804|
*/


/*
Q15. Use SQL to calculate the total profit for competitors in each state 
and compare the results to the state's population.
*/

/*
Join the following tables & create a new table - tb_competitors_population
-competitors
-population
*/
CREATE TABLE tb_competitors_population AS
SELECT
	a.state_usa,
	a.profit,
	b.estimate,
	a.research_development_spent,
	a.administration,
	a.marketing_spent 
FROM competitors a
JOIN population b
	ON a.state_usa = b.state_usa;
--Updated Rows 271

SELECT * FROM tb_competitors_population;
/*
state_usa    |profit    |estimate|research_development_spent|administration|marketing_spent|
-------------+----------+--------+--------------------------+--------------+---------------+
New York     | 192261.83|19453561|                  165349.2|      136897.8|       471784.1|
California   | 191792.06|39512223|                  162597.7|     151377.59|      443898.53|
Florida      | 191050.39|21477737|                 153441.51|     101145.55|      407934.54|
New York     | 182901.99|19453561|                 144372.41|     118671.85|      383199.62|
*/

--Group by State / Sum Profit / Sum Population
CREATE TABLE tb_agg_competitors_population AS
SELECT 
	state_usa,
	SUM(profit) AS sum_profit,
	SUM(estimate) AS sum_estimate_population
FROM tb_competitors_population
GROUP BY state_usa
ORDER BY state_usa ASC;
--Updated Rows 41

SELECT * FROM tb_agg_competitors_population;
/*
state_usa    |sum_profit |sum_estimate_population|
-------------+-----------+-----------------------+
Alabama      | 5692296.95|               24515925|
Alaska       | 9845632.95|                3657725|
Arizona      | 2942282.99|                7278717|
Arkansas     | 1487917.98|                6035608|
*/



-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ POSTGRES / Additional Questions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/*
Q2. Which state has the highest population density, and how does this impact property prices?
*/

SELECT * FROM tb_population_propertyprices LIMIT 1; 
/*
state_usa|estimate|avg_price|min_price|max_price|
---------+--------+---------+---------+---------+
Alabama  | 4903185|  1797.50|  1200.00|  2500.00|
*/


-- END OF FILE --