Create database RetailDB;
use RetailDB;

-- 1. Time Dimension
CREATE TABLE time_dim (
    time_key VARCHAR(20) PRIMARY KEY,
    date DATETIME,
    hour INT,
    day INT,
    week VARCHAR(20),
    month INT,
    quarter VARCHAR(10),
    year INT
);

-- 2. Item Dimension
CREATE TABLE item_dim (
    item_key VARCHAR(20) PRIMARY KEY,
    item_name VARCHAR(255),
    description VARCHAR(255),
    unit_price DECIMAL(10,2),
    man_country VARCHAR(100),
    supplier VARCHAR(100),
    unit VARCHAR(50)
);

-- 3. Store Dimension
CREATE TABLE store_dim (
    store_key VARCHAR(20) PRIMARY KEY,
    division VARCHAR(100),
    district VARCHAR(100),
    upazila VARCHAR(100)
);

-- 4. Customer Dimension
CREATE TABLE customer_dim (
    customer_key VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100),
    contact_no VARCHAR(20),
    nid VARCHAR(20)
);

-- 5. Payment Dimension
CREATE TABLE payment_dim (
    payment_key VARCHAR(20) PRIMARY KEY,
    trans_type VARCHAR(50),
    bank_name VARCHAR(100)
);

-- 6. Fact Table
CREATE TABLE fact_table (
    payment_key VARCHAR(20),
    customer_key VARCHAR(20),
    time_key VARCHAR(20),
    item_key VARCHAR(20),
    store_key VARCHAR(20),
    quantity INT,
    unit VARCHAR(50),
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2)
);

SHOW VARIABLES LIKE 'secure_file_priv'; -- For fast importing Data
-- Now Direct Import the Data  "Another Way of Importing Data in Faster Way"
-- 1. Time Dim
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/time_dim_clean.csv'
INTO TABLE time_dim
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. Item Dim
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/item_dim_clean.csv'
INTO TABLE item_dim
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 3. Store Dim
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/store_dim.csv'
INTO TABLE store_dim
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 4. Customer Dim
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/customer_dim_clean.csv'
INTO TABLE customer_dim
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 5. Payment Dim
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/Trans_dim.csv'
INTO TABLE payment_dim
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 6. Fact Table (last)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/fact_table_clean.csv'
INTO TABLE fact_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- BASIC 
-- Q1. Total Revenue
SELECT SUM(total_price) AS total_revenue FROM fact_table;
--Output: 105401435.75

-- Q2. Total Orders
SELECT COUNT(*) AS total_orders FROM fact_table;
--Output: 1000000 Total Orders

-- Q3. Total Unique Customers
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM fact_table;
--Output: 9191

-- Q4. Average Order Value
SELECT AVG(total_price) AS avg_order_value FROM fact_table;
--Output: 105.401436

-- Q5. Revenue by Payment Method
SELECT p.trans_type, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN payment_dim p ON f.payment_key = p.payment_key
GROUP BY p.trans_type
ORDER BY revenue DESC;
-- card	94583038.50 , mobile 8109881.50 , cash 2708515.75

-- INTERMEDIATE
-- Q6. Top 10 Products by Revenue
SELECT i.item_name, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
GROUP BY i.item_name
ORDER BY revenue DESC
LIMIT 10;
--Output: 
--Red Bull 12oz	1305700.00
--K Cups Daily Chef Columbian Supremo	1245394.00
--K Cups Original Donut Shop Med. Roast	1188843.00
--K Cups Dunkin Donuts Medium Roast	1109760.00
--Muscle Milk Protein Shake Van. 11oz	1050924.00
--K Cups Folgers Lively Columbian	1042406.00
--Honey Packets  	1012995.00
--K Cups  Starbuck's Pike Place	995456.00
--K Cups Organic Breakfast Blend	957516.00
--K Cups - McCafe Premium Roast	956886.00

-- Q7. Revenue by Division
SELECT s.division, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN store_dim s ON f.store_key = s.store_key
GROUP BY s.division
ORDER BY revenue DESC;
--Output:
--DHAKA	40764619.75
--CHITTAGONG	19763595.00
--RAJSHAHI	12099196.00
--KHULNA	11311610.50
--RANGPUR	8429836.50
--BARISAL	7520343.75
--SYLHET	5512234.25

-- Q8. Yearly Revenue Trend
SELECT t.year, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.year
ORDER BY t.year;
--Output:
--2014	14334731.25
--2015	15095720.25
--2016	14976508.25
--2017	15015806.00
--2018	15108197.25
--2019	14949510.25
--2020	15037190.25
--2021	883772.25

-- Q9. Monthly Revenue Trend
SELECT t.month, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.month
ORDER BY t.month;
--Output:
--1	 9042244.00
--2	 8073877.50
--3	 8939152.00
--4	 8504634.75
--5	 9078002.50
--6	 8556853.00
--7	 9046580.00
--8	 8929475.25
--9	 8724326.50
--10 8902783.75
--11 8680026.00
--12 8923480.50

-- Q10. Top 10 Suppliers by Revenue
SELECT i.supplier, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
GROUP BY i.supplier
ORDER BY revenue DESC
LIMIT 10;
--Output:
--DENIMACH LTD	13337300.50
--Indo Count Industries Ltd	13159323.25
--BIGSO AB	11369622.00
--CHROMADURLIN S.A.S	10976287.50
--Friedola 1888 GmbH	10957102.25
--Bolsius Boxmeer	10458204.00
--MAESA SAS	9892983.50
--NINGBO SEDUNO IMP & EXP CO.LTD	9463861.50
--HARDFORD AB	9416792.25
--CHERRY GROUP CO.,LTD	5992661.00

-- Q11. Revenue by Quarter
SELECT t.quarter, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.quarter
ORDER BY revenue DESC;
--Output:
--Q3	26700381.75
--Q4	26506290.25
--Q2	26139490.25
--Q1	26055273.50

-- Q12. Top 10 Customers by Spending
SELECT c.name, SUM(f.total_price) AS total_spent
FROM fact_table f
JOIN customer_dim c ON f.customer_key = c.customer_key
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 10;
--pooja	    2109800.75
--jyoti	    1331696.25
--neha	    996121.00
--sunita	915543.75
--poonam	914285.25
--priyanka	819243.25
--seema	    813087.75
--suman	    748327.25
--komal	    698672.75
--mamta	    688649.50

-- Q13. Peak Hour Analysis
SELECT t.hour, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.hour
ORDER BY revenue DESC
LIMIT 5;
--Output:
--14	4576237.50
--19	4548869.00
--17	4497724.50
--13	4475946.00
--9	    4472149.75

-- Q14. Revenue by Manufacturing Country
SELECT i.man_country, SUM(f.total_price) AS revenue
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
GROUP BY i.man_country
ORDER BY revenue DESC
LIMIT 10;
--Output:
--Bangladesh	13337300.50
--India	        13159323.25
--Lithuania	    11369622.00
--poland	    10976287.50
--Germany	    10957102.25
--Netherlands	10458204.00
--United States	9892983.50
--Cambodia	    9463861.50
--Finland	    9416792.25
--China	        5992661.00


--ADVANCED
-- Q15. Rank Products by Revenue (Window Function)
SELECT 
    item_name,
    revenue,
    RANK() OVER(ORDER BY revenue DESC) AS rank_no
FROM (
    SELECT i.item_name, SUM(f.total_price) AS revenue
    FROM fact_table f
    JOIN item_dim i ON f.item_key = i.item_key
    GROUP BY i.item_name
) AS subquery;
--Output:
--Red Bull 12oz	1305700.00	1
--K Cups Daily Chef Columbian Supremo	1245394.00	2
--K Cups Original Donut Shop Med. Roast	1188843.00	3
--K Cups Dunkin Donuts Medium Roast	1109760.00	4
--Muscle Milk Protein Shake Van. 11oz	1050924.00	5
--K Cups Folgers Lively Columbian	1042406.00	6
--Honey Packets  	1012995.00	7
--K Cups  Starbuck's Pike Place	995456.00	8
--K Cups Organic Breakfast Blend	957516.00	9
--K Cups - McCafe Premium Roast	956886.00	10
--Red Bull Sugar Free 8.4 oz	933720.00	11
--Red Bull 8.4 oz	929240.00	12
--Monster Original Green 16 oz	920880.00	13
--Monster Zero Ultra 16 oz	912160.00	14
--Monster Zero Ultra Variety 16 oz	912000.00	15
--Monster Lo-Carb 16 oz	892240.00	16
--Red Bull 16oz	839160.00	17
--M&M Peanut Candy 1.7 oz	773360.00	18      ..etc 


-- Q16. Yearly Revenue with Running Total (CTE)
WITH yearly AS (
    SELECT t.year, SUM(f.total_price) AS yearly_revenue
    FROM fact_table f
    JOIN time_dim t ON f.time_key = t.time_key
    GROUP BY t.year
)
SELECT 
    year,
    yearly_revenue,
    SUM(yearly_revenue) OVER(ORDER BY year) AS running_total
FROM yearly;
--Output:
--2014	14334731.25	14334731.25
--2015	15095720.25	29430451.50
--2016	14976508.25	44406959.75
--2017	15015806.00	59422765.75
--2018	15108197.25	74530963.00
--2019	14949510.25	89480473.25
--2020	15037190.25	104517663.50
--2021	883772.25	105401435.75


-- Q17. Top Product Per Division (ROW_NUMBER + PARTITION BY)
WITH division_products AS (
    SELECT 
        s.division,
        i.item_name,
        SUM(f.total_price) AS revenue,
        ROW_NUMBER() OVER(PARTITION BY s.division ORDER BY SUM(f.total_price) DESC) AS rn
    FROM fact_table f
    JOIN item_dim i ON f.item_key = i.item_key
    JOIN store_dim s ON f.store_key = s.store_key
    GROUP BY s.division, i.item_name
)
SELECT division, item_name, revenue
FROM division_products
WHERE rn = 1;
--Output:
--BARISAL	    Red Bull 12oz	95205.00
--CHITTAGONG	Red Bull 12oz	246510.00
--DHAKA	        Red Bull 12oz	510895.00
--KHULNA	    Red Bull 12oz	139645.00
--RAJSHAHI	    Red Bull 12oz	148885.00
--RANGPUR	    K Cups Daily Chef Columbian Supremo	101866.00
--SYLHET	    K Cups Daily Chef Columbian Supremo	69165.00

-- Q18. Above Average Revenue Orders
SELECT 
    f.item_key,
    i.item_name,
    f.total_price
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
WHERE f.total_price > (
    SELECT AVG(total_price) FROM fact_table
)
LIMIT 10;
--Output:
--I00131	Paper Bowls 20 oz Ultra Strong	112.00
--I00058	Premier Protein Shake Choc. 11oz	110.00
--I00133	Clear Plastic Cups 9oz	150.00
--I00065	G2 Lo Calorie Variety 20 oz	160.00
--I00125	Pure White Sugar Packets	135.00
--I00155	Doritos Nacho Cheese 1 oz	153.00
--I00078	Pure Leaf Sweet Tea 8.5oz	136.00
--I00079	Pure Leaf Unsweetened Tea 18.5oz	170.00
--I00111	K Cups Hot Cocoa	128.00
--I00033	La Croix Sparkling Grapefruit 12 oz	112.00

-- Q19. Revenue Growth YoY (LAG Function)
WITH yearly AS (
    SELECT t.year, SUM(f.total_price) AS revenue
    FROM fact_table f
    JOIN time_dim t ON f.time_key = t.time_key
    GROUP BY t.year
)
SELECT 
    year,
    revenue,
    LAG(revenue) OVER(ORDER BY year) AS prev_year_revenue,
    ROUND((revenue - LAG(revenue) OVER(ORDER BY year)) / 
    LAG(revenue) OVER(ORDER BY year) * 100, 2) AS yoy_growth_pct
FROM yearly;
--Output:
--2014	14334731.25		
--2015	15095720.25	14334731.25	5.31
--2016	14976508.25	15095720.25	-0.79
--2017	15015806.00	14976508.25	0.26
--2018	15108197.25	15015806.00	0.62
--2019	14949510.25	15108197.25	-1.05
--2020	15037190.25	14949510.25	0.59
--2021	883772.25	15037190.25	-94.12

--STORED PROCEDURES
-- SP1. Top Products
DELIMITER //
CREATE PROCEDURE TopProducts()
BEGIN
    SELECT i.item_name, SUM(f.total_price) AS revenue
    FROM fact_table f
    JOIN item_dim i ON f.item_key = i.item_key
    GROUP BY i.item_name
    ORDER BY revenue DESC
    LIMIT 10;
END //
DELIMITER ;
CALL TopProducts();

-- SP2. Division Revenue Report
DELIMITER //
CREATE PROCEDURE DivisionRevenue()
BEGIN
    SELECT s.division, SUM(f.total_price) AS revenue
    FROM fact_table f
    JOIN store_dim s ON f.store_key = s.store_key
    GROUP BY s.division
    ORDER BY revenue DESC;
END //
DELIMITER ;
CALL DivisionRevenue();

-- SP3. Yearly Revenue Report
DELIMITER //
CREATE PROCEDURE YearlyRevenue()
BEGIN
    SELECT t.year, SUM(f.total_price) AS revenue
    FROM fact_table f
    JOIN time_dim t ON f.time_key = t.time_key
    GROUP BY t.year
    ORDER BY t.year;
END //
DELIMITER ;
CALL YearlyRevenue();