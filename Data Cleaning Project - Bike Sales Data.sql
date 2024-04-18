/*

Data Cleaning Project - Bike Sales Data 

*/

SELECT * 
FROM bike_sales_db.`uncleaned bike sales data`;

----------------------------------------------------------------------------------------------------------------

-- Standardise date format

SELECT 
	`Date`, 
	DATE_FORMAT(STR_TO_DATE(`Date`, '%d/%m/%Y'), '%Y-%m-%d') as `Date-fixed`
FROM bike_sales_db.`uncleaned bike sales data`;

UPDATE bike_sales_db.`uncleaned bike sales data`
SET `Date` = DATE_FORMAT(STR_TO_DATE(`Date`, '%d/%m/%Y'), '%Y-%m-%d');

SET SQL_SAFE_UPDATES = 0;

SELECT 
	`Date`, 
    DAY(`Date`) as `Day-fixed`, 
    MONTHNAME(`Date`) as `Month-fixed`, 
    YEAR(`Date`) as `Year-fixed`
FROM bike_sales_db.`uncleaned bike sales data`;

ALTER TABLE bike_sales_db.`uncleaned bike sales data`
ADD COLUMN `Day-fixed` INT AFTER `Day`,
ADD COLUMN `Month-fixed` VARCHAR(20) AFTER `Month`,
ADD COLUMN `Year-fixed` INT AFTER `Year`;

UPDATE bike_sales_db.`uncleaned bike sales data`
SET `Day-fixed` = DAY(`Date`),
    `Month-fixed` = MONTHNAME(`Date`),
    `Year-fixed` = YEAR(`Date`);
    
----------------------------------------------------------------------------------------------------------------

-- Alter Age_Group from 'Adult(35-64)' to 'Adult' and other corresponding groups

Select Distinct(Age_Group), Count(Age_Group)
From bike_sales_db.`uncleaned bike sales data`
Group by Age_Group
order by 2;

Select Age_Group,
 CASE When Age_Group = 'Adults (35-64)' THEN 'Adults'
	  When Age_Group = 'Young Adults (25-34)' THEN 'Young Adults'
	  When Age_Group = 'Youth (<25)' THEN 'Youth'
	  ELSE Age_Group
	  END as `Age_Group-fixed`
From bike_sales_db.`uncleaned bike sales data`;

ALTER TABLE bike_sales_db.`uncleaned bike sales data`
ADD COLUMN `Age_Group-fixed` VARCHAR(20) AFTER `Age_Group`;

UPDATE bike_sales_db.`uncleaned bike sales data`
SET `Age_Group-fixed` = CASE When Age_Group = 'Adults (35-64)' THEN 'Adults'
	   When Age_Group = 'Young Adults (25-34)' THEN 'Young Adults'
       When Age_Group = 'Youth (<25)' THEN 'Youth'
	   ELSE Age_Group
	   END;
       
----------------------------------------------------------------------------------------------------------------

-- Breaking out Product_Description into individual columns (Model, Colour, Size)

SELECT 
	Product_Description, 
    CASE WHEN Product_Description LIKE 'Mountain-400%' THEN '400'
		 ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(Product_Description, '-', -1), ' ', 1)
		 END AS Model,
    CASE WHEN Product_Description LIKE 'Mountain-400%' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(Product_Description, '-', -1), ',', 1)
		 ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(Product_Description, ',', 1), ' ', -1)
		 END AS Colour,
    SUBSTRING_INDEX(Product_Description, ',', -1) AS Size
FROM bike_sales_db.`uncleaned bike sales data`;

ALTER TABLE bike_sales_db.`uncleaned bike sales data`
ADD COLUMN `Model-fixed` VARCHAR(10) AFTER Product_Description,
ADD COLUMN `Colour-fixed` VARCHAR(20) AFTER `Model-fixed`,
ADD COLUMN `Size-fixed` VARCHAR(10) AFTER `Colour-fixed`;

UPDATE bike_sales_db.`uncleaned bike sales data`
SET 
    `Model-fixed` = CASE WHEN Product_Description LIKE 'Mountain-400%' THEN '400'
		 ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(Product_Description, '-', -1), ' ', 1)
		 END,
    `Colour-fixed` = CASE WHEN Product_Description LIKE 'Mountain-400%' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(Product_Description, '-', -1), ',', 1)
		 ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(Product_Description, ',', 1), ' ', -1)
		 END,
    `Size-fixed` = SUBSTRING_INDEX(Product_Description, ',', -1);
    
----------------------------------------------------------------------------------------------------------------

-- Adding new financial columns for further calculation 
SHOW COLUMNS FROM bike_sales_db.`uncleaned bike sales data`;

ALTER TABLE bike_sales_db.`uncleaned bike sales data`
ADD COLUMN `Unit_Cost_fixed` DOUBLE,
ADD COLUMN `Unit_Price_fixed` DOUBLE,
ADD COLUMN `Profit_fixed` DOUBLE,
ADD COLUMN `Revenue_fixed` DOUBLE;

ALTER TABLE bike_sales_db.`uncleaned bike sales data`
ADD COLUMN `Cost_fixed` DOUBLE AFTER `Profit_fixed`;

UPDATE bike_sales_db.`uncleaned bike sales data`
SET `Unit_Cost_fixed` = CAST(REPLACE(REPLACE(Unit_Cost, '$', ''), ',', '') AS DECIMAL(10,2)),
	`Unit_Price_fixed` = CAST(REPLACE(REPLACE(Unit_Price, '$', ''), ',', '') AS DECIMAL(10,2)),
	`Profit_fixed` = CAST(REPLACE(REPLACE(Profit, '$', ''), ',', '') AS DECIMAL(10,2)),
    `Cost_fixed` = CAST(REPLACE(REPLACE(Cost, '$', ''), ',', '') AS DECIMAL(10,2)),
	`Revenue_fixed` = CAST(REPLACE(REPLACE(Revenue, '$', ''), ',', '') AS DECIMAL(10,2));

-- Check if there are any missing values, and have found 2 rows consist of missing values

SELECT `Unit_Cost_fixed`, `Unit_Price_fixed`, `Cost_fixed`, `Profit_fixed`, `Revenue_fixed`
FROM bike_sales_db.`uncleaned bike sales data`
WHERE `Unit_Cost_fixed` = 0 OR `Unit_Price_fixed` = 0 OR `Cost_fixed` = 0 OR `Profit_fixed` = 0 OR `Revenue_fixed` = 0;

-- Fixed the two missing value records

UPDATE bike_sales_db.`uncleaned bike sales data`
SET
    `Cost_fixed` = IF(`Cost_fixed` = 0, `Revenue_fixed` - `Profit_fixed`, `Cost_fixed`),
    `Revenue_fixed` = IF(`Revenue_fixed` = 0, `Profit_fixed` + `Cost_fixed`, `Revenue_fixed`)
WHERE `Unit_Cost_fixed` = 0 OR `Unit_Price_fixed` = 0 OR `Cost_fixed` = 0 OR `Profit_fixed` = 0 OR `Revenue_fixed` = 0;
    
UPDATE bike_sales_db.`uncleaned bike sales data`
SET
    `Unit_Cost_fixed` = IF(`Unit_Cost_fixed` = 0, `Cost_fixed` / Order_Quantity, `Unit_Cost_fixed`),
    `Unit_Price_fixed` = IF(`Unit_Price_fixed` = 0,  `Revenue_fixed`/ Order_Quantity, `Unit_Price_fixed`)
WHERE `Unit_Cost_fixed` = 0 OR `Unit_Price_fixed` = 0 OR `Cost_fixed` = 0 OR `Profit_fixed` = 0 OR `Revenue_fixed` = 0;
    
----------------------------------------------------------------------------------------------------------------

-- Delete unused columns

ALTER TABLE your_table_name
DROP COLUMN `Day`, 
DROP COLUMN `Month`,
DROP COLUMN `Year`,
DROP COLUMN `Age_Group`,
DROP COLUMN `Unit_Cost`,
DROP COLUMN `Unit_Price`,
DROP COLUMN `Profit`,
DROP COLUMN `Cost`,
DROP COLUMN `Revenue`;


