-- =============================================================================
-- Author: Fritz Gerald Reyes
-- Create date: 11 Oct 2023
-- Update date: 11 Oct 2023
-- Description: Refocus Final Project (Set 1)
-- =============================================================================


-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRE CHECKS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SELECT VERSION();
--PostgreSQL 14.5, compiled by Visual C++ build 1914, 64-bit

-- Display the tables
SELECT table_catalog, table_schema, table_name 
FROM information_schema.TABLES
WHERE table_schema = 'public';
/*
table_catalog|table_schema|table_name                       |
-------------+------------+---------------------------------+
final_project|public      |competitors                      |
final_project|public      |corruption_convictions_per_capita|
final_project|public      |health_spending                  |
final_project|public      |population                       |
final_project|public      |property_prices                  |
final_project|public      |state_income                     |
*/

-- Check the sample data per table

SELECT * FROM competitors LIMIT 4;
/*
research_development_spent|administration|marketing_spent|state_usa |profit   |
--------------------------+--------------+---------------+----------+---------+
                  165349.2|      136897.8|       471784.1|New York  |192261.83|
                  162597.7|     151377.59|      443898.53|California|191792.06|
                 153441.51|     101145.55|      407934.54|Florida   |191050.39|
                 144372.41|     118671.85|      383199.62|New York  |182901.99|
*/

SELECT * FROM corruption_convictions_per_capita LIMIT 4;
/*
state_usa|convictions_per_capita|
---------+----------------------+
Alabama  |                  2.15|
Alaska   |                  1.06|
Arizona  |                  1.40|
Arkansas |                  3.02|
*/

SELECT * FROM health_spending LIMIT 4;
/*
state_usa|avg_spending|min_spending|max_spending|
---------+------------+------------+------------+
Alabama  |      200.50|       50.00|      500.00|
Alaska   |      300.25|      100.00|      750.00|
Arizona  |      150.00|       25.00|      300.00|
Arkansas |      175.00|       75.00|      400.00|
*/

SELECT * FROM population LIMIT 4;
/*
state_usa|estimate|
---------+--------+
Alabama  | 4903185|
Alaska   |  731545|
Arizona  | 7278717|
Arkansas | 3017804|
*/

SELECT * FROM property_prices LIMIT 4;
/*
state_usa|avg_price|min_price|max_price|
---------+---------+---------+---------+
Alabama  |  1797.50|  1200.00|  2500.00|
Alaska   |  2684.00|  2000.00|  3500.00|
Arizona  |  2356.75|  1500.00|  4000.00|
Arkansas |  1499.25|  1000.00|  2500.00|
*/

SELECT * FROM state_income LIMIT 4;
/*
state_usa|average_income|minimum_income|maximum_income|
---------+--------------+--------------+--------------+
Alabama  |         51113|         23999|         96993|
Alaska   |         76440|         35219|        134318|
Arizona  |         62283|         29466|        113589|
Arkansas |         48829|         23028|         90052|
*/

-- END OF FILE --