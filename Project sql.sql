CREATE DATABASE Project;
USE Project;

CREATE TABLE Inventory_Forecasting(
	Date DATE,
    Store_ID varchar(15),
    ProductID varchar(15),
    Category varchar(50),
    Region varchar(15),
    Inventory_Level INT,
    Units_Sold INT,
    Units_ordered INT, 
    Demand_Forecast Float,
    Price Decimal(10,2),
    Discount INT,
    Weather_Condition varchar(15),
    Holiday_Promotion Boolean,
    Competitor_Pricing Decimal(10,2),
    Seasonality varchar(15)
);

SHOW global variables LIKE 'local_infile';
SET global local_infile = 1;

LOAD DATA LOCAL INFILE 'C:/forecasting.csv'
INTO table inventory_forecasting
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines;

Select * FROM inventory_forecasting
limit 5;

-- 	Stock level Calulations across stores 
-- For Total Stock per Product per Store and Stock Distribution of Each Product Across Stores we use join 
SELECT 
  f.`Store_ID`,
  f.`ProductID`,
  SUM(f.`Inventory_Level`) AS stock_in_store,
  total.total_stock_across_all_stores
FROM inventory_forecasting f

JOIN (
    SELECT 
      `ProductID`,
      SUM(`Inventory_Level`) AS total_stock_across_all_stores
    FROM inventory_forecasting
    GROUP BY `ProductID`
) AS total
  ON f.`ProductID` = total.`ProductID`

GROUP BY f.`Store_ID`, f.`ProductID`, total.total_stock_across_all_stores
ORDER BY f.`ProductID`, stock_in_store DESC;
-- Total Inventory Across ALL Stores(Per Product)
SELECT 
  `ProductID`,
  SUM(`Inventory_Level`) AS total_inventory_across_all_stores
FROM inventory_forecasting
GROUP BY `ProductID`
ORDER BY total_inventory_across_all_stores DESC;



SELECT 
  `ProductID`,
  SUM(`Inventory_Level`) AS total_inventory_across_all_stores
FROM inventory_forecasting
GROUP BY `ProductID`
ORDER BY total_inventory_across_all_stores DESC;


-- dectecting low inventory based on reorder points
SELECT*
FROM inventory_forecasting 
WHERE Inventory_Level < 30
ORDER BY Inventory_Level ASC
LIMIT 15;

-- Reorder Point Estimation using trends
-- Daily Demand * Lead Time = Reorder Point
SELECT 
	Store_ID, ProductID,		-- Data for every product for each store
    ROUND(Avg(Units_Sold),2) AS avg_daily_sales,
    ROUND(Avg(Units_Sold)*7) AS reorder_point_estimate		-- we are taking lead time 7 days
FROM inventory_forecasting
GROUP BY Store_ID, ProductID
ORDER BY Store_ID, reorder_point_estimate DESC;  

-- finding minimum and maximum turnover firstly
SELECT 
  MIN(turnover_ratio) AS min_turnover,
  MAX(turnover_ratio) AS max_turnover
FROM (
    SELECT 
        `Store_ID`,
        `ProductID`,
        ROUND(SUM(`Units_Sold`) / NULLIF(AVG(`Inventory_Level`), 0), 2) AS turnover_ratio
    FROM inventory_forecasting
    WHERE `Units_Sold` > 0 AND `Inventory_Level` > 0
    GROUP BY `Store_ID`, `ProductID`
) AS turnover_sub;


-- Inventory Turnover Analysis(Total sales/avg inventory)
SELECT 
    `Store_ID`,
    `ProductID`,
    SUM(`Units_Sold`) AS total_sales,
    AVG(`Inventory_Level`) AS avg_inventory,
    ROUND(SUM(`Units_Sold`)/ NULLIF(AVG(`Inventory_Level`), 0), 2) AS turnover_ratio,

	-- Fast-Selling vs Slow-moving Products
	CASE 
        WHEN ROUND(SUM(`Units_Sold`) / NULLIF(AVG(`Inventory_Level`), 0), 2) > 500 THEN 'FAST-Selling'
        WHEN ROUND(SUM(`Units_Sold`) / NULLIF(AVG(`Inventory_Level`), 0), 2) BETWEEN 480 AND 500 THEN 'Moderate'
        ELSE 'SLOW-Moving'
    END AS Product_Movement

FROM inventory_forecasting
WHERE `Units_Sold` > 0 AND `Inventory_Level`> 0
GROUP BY `Store_ID`, `ProductID`
ORDER BY turnover_ratio DESC;

-- STOCK Adjustments to reduce holding costs with using Common Table Expression
WITH dailysales_cte AS (
    SELECT
        `Store_ID`,
        `ProductID`,
        ROUND(SUM(`Units_Sold`) / 30, 2) AS daily_sales
    FROM inventory_forecasting
    WHERE `Units_Sold` > 0
    GROUP BY `Store_ID`, `ProductID`
)

SELECT 
    i.`Store_ID`,
    i.`ProductID`,
    ROUND(AVG(i.`Inventory_Level`), 2) AS avg_inventory,
    d.daily_sales,
    ROUND(d.daily_sales * 7) AS target_stock_1week, 
    ROUND(AVG(i.`Inventory_Level`) - (d.daily_sales * 7)) AS suggested_reduction

FROM inventory_forecasting i
JOIN (
    SELECT
        `Store_ID`,
        `ProductID`,
        ROUND(SUM(`Units_Sold`) / 30, 2) AS daily_sales
    FROM inventory_forecasting
    WHERE `Units_Sold` > 0
    GROUP BY `Store_ID`, `ProductID`
) d
    ON i.`Store_ID` = d.`Store_ID` AND i.`ProductID` = d.`ProductID`

WHERE i.`Inventory_Level` > 0
GROUP BY i.`Store_ID`, i.`ProductID`, d.daily_sales
ORDER BY suggested_reduction DESC;
-- as we can see we are already out of stock so we can use reorder stock command 

/* Supplier performance inconsistensies		
since we don't have any supplier-level delivery data column so we can't do this 
we can do this by assuming safetey stock by our own. */

-- Forecast demand trends based on seasonal/cyclical data
SELECT DISTINCT `Date` FROM inventory_forecasting LIMIT 10;

SELECT 
  CAST(`Date` AS CHAR) AS raw_date,
  LENGTH(CAST(`Date` AS CHAR)) AS length_of_date
FROM inventory_forecasting
WHERE CAST(`Date` AS CHAR) != '0'
LIMIT 10;










 
