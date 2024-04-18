/*

Supermarket Sales Data Exploration

*/

SELECT * 
FROM supermarket_db.supermarket_sales_cleaned_data;

----------------------------------------------------------------------------------------------------------------

-- Check data type of all fields

DESCRIBE supermarket_db.supermarket_sales_cleaned_data;

----------------------------------------------------------------------------------------------------------------

-- Select Data that will be used

SELECT 
	City, 
    `Customer type`, 
    Gender, 
    `Product line`, 
    `Unit price`, 
    Quantity, 
    Total, 
    `Date`, 
    Payment, 
    cogs, 
    Rating
FROM supermarket_db.supermarket_sales_cleaned_data;

----------------------------------------------------------------------------------------------------------------

-- Rank city branch performance based on total number of sales

SELECT City, Count(City) as total_orders
FROM supermarket_db.supermarket_sales_cleaned_data
GROUP BY City 
ORDER BY total_orders DESC;

----------------------------------------------------------------------------------------------------------------

-- Show which gender generates more sales

SELECT Gender, Count(Gender) as `Total Sales`
FROM supermarket_db.supermarket_sales_cleaned_data
GROUP BY Gender 
ORDER BY `Total Sales` DESC;

----------------------------------------------------------------------------------------------------------------

-- Show which customer type generates more sales

SELECT `Customer type`, Count(`Customer type`) as `Total Sales`
FROM supermarket_db.supermarket_sales_cleaned_data
GROUP BY `Customer type` 
ORDER BY `Total Sales` DESC;

----------------------------------------------------------------------------------------------------------------

-- Show the maximumn, minimun, and average rating of each product line

SELECT 
	`Product line`, 
	MAX(CONVERT(Rating, double)) as `Highest Rating`, 
	MIN(CONVERT(Rating, double)) as `Lowest Rating`, 
	ROUND(AVG(CONVERT(Rating, double)),2) as `Average Rating`
FROM supermarket_db.supermarket_sales_cleaned_data
GROUP BY `Product line`;

----------------------------------------------------------------------------------------------------------------

-- Show the quarterly financial summary of the supermarket

SELECT 
	ROUND(SUM(CONVERT(`Tax 5%`, double)),2) as Tax, 
	ROUND(SUM(CONVERT(Total, double)),2) as Revenue, 
    ROUND(SUM(CONVERT(cogs, double)),2) as COGS, 
    ROUND(SUM(CONVERT(`gross income`, double)),2) as `Gross Income`
FROM supermarket_db.supermarket_sales_cleaned_data;

----------------------------------------------------------------------------------------------------------------

-- Top 5 sales at each city branch

SELECT * 
FROM (
	SELECT 
		`Invoice ID`, 
        City, 
        `Product line`, 
        Total as Revenue, 
        ROW_NUMBER() OVER (PARTITION BY City ORDER BY CAST(Total as double) DESC) as `Rank`
    FROM supermarket_db.supermarket_sales_cleaned_data) as ranked_sales
WHERE `Rank` <=5;

----------------------------------------------------------------------------------------------------------------

-- Show revenue of each product line from highest to lowest

SELECT  
	`Product line`,
    ROUND(SUM(CAST(Total as double)),2) as `Revenue`,
    ROUND(SUM(CAST(Total as double))/ (SELECT SUM(CAST(Total as double)) FROM supermarket_db.supermarket_sales_cleaned_data) *100, 2) as `Percentage`
FROM 
	supermarket_db.supermarket_sales_cleaned_data
GROUP BY `Product line`
ORDER BY Revenue DESC;

----------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualisations

Create View `QuarterSummary` as
SELECT 
	`Product line` as `Product Line`,
    COUNT(Quantity) as `Total Orders`,
    ROUND(SUM(CONVERT(`Tax 5%`, double)),2) as Tax, 
	ROUND(SUM(CONVERT(Total, double)),2) as Revenue, 
    ROUND(SUM(CONVERT(cogs, double)),2) as COGS, 
    ROUND(SUM(CONVERT(`gross income`, double)),2) as `Gross Income`,
    ROUND(SUM(CAST(Total as double))/ (SELECT SUM(CAST(Total as double)) FROM supermarket_db.supermarket_sales_cleaned_data) *100, 2) as `Percentage`
FROM supermarket_db.supermarket_sales_cleaned_data
GROUP BY `Product line`;

    


