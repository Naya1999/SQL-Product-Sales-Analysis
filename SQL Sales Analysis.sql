USE [sql_sales]
GO

/*
                                           SQL SALES ANALYSIS
This project aims to use sql code to draw insights from a sales database focusing on quarterly performance, popular products in store,
payment methods, and deleivery efficiency.
*/


--1. Sales Analysis Quarterly and Percentage Increase/Decrease Each Quarter:
-----------------------------------------------------------------------------------
--First hard code quarterly dates
PRINT 'Declare variables for the start and end dates of each quarter in 2023'
DECLARE @First_Quarter_Start DATE = '2023-01-01'
DECLARE @First_Quarter_End DATE = '2023-03-31'

DECLARE @Second_Quarter_Start DATE = '2023-04-01'
DECLARE @Second_Quarter_End DATE = '2023-06-30'

DECLARE @Third_Quarter_Start DATE = '2023-07-01'
DECLARE @Third_Quarter_End DATE = '2023-09-30'

DECLARE @Fourth_Quarter_Start DATE = '2023-10-01'  
DECLARE @Fourth_Quarter_End DATE = '2023-12-31'

PRINT 'Get quarterly sales from each product into 4 temp tables'
PRINT 'First Quarter'
IF OBJECT_ID ('tempdb..#First_Quarter') IS NOT NULL
	DROP TABLE #First_Quarter

SELECT o.product_id
	,p.product_name
	,SUM(quantity) as [First_Quarter]
INTO #First_Quarter
FROM orders o
INNER JOIN products p ON p.product_id = o.product_id
WHERE order_date BETWEEN @First_Quarter_Start AND @First_Quarter_End
GROUP BY p.product_name, o.product_id

PRINT 'Second Quarter'
IF OBJECT_ID ('tempdb..#Second_Quarter') IS NOT NULL
	DROP TABLE #Second_Quarter

SELECT o.product_id
	,p.product_name
	,SUM(quantity) as [Second_Quarter]
INTO #Second_Quarter
FROM orders o
INNER JOIN products p ON p.product_id = o.product_id
WHERE order_date BETWEEN @Second_Quarter_Start AND @Second_Quarter_End
GROUP BY p.product_name, o.product_id

PRINT 'Third Quarter'
IF OBJECT_ID ('tempdb..#Third_Quarter') IS NOT NULL
	DROP TABLE #Third_Quarter

SELECT o.product_id
	,p.product_name
	,SUM(quantity) as [Third_Quarter]
INTO #Third_Quarter
FROM orders o
INNER JOIN products p ON p.product_id = o.product_id
WHERE order_date BETWEEN @Third_Quarter_Start AND @Third_Quarter_End
GROUP BY p.product_name, o.product_id

PRINT 'Last Quarter'
IF OBJECT_ID ('tempdb..#Last_Quarter') IS NOT NULL
	DROP TABLE #Last_Quarter

SELECT o.product_id
	,p.product_name
	,SUM(quantity) as [Last_Quarter]
INTO #Last_Quarter
FROM orders o
INNER JOIN products p ON p.product_id = o.product_id
WHERE order_date BETWEEN @Fourth_Quarter_Start AND @Fourth_Quarter_End
GROUP BY p.product_name, o.product_id


PRINT 'Check id Sales_By_Quarter Table exists'
IF EXISTS(
	SELECT 1
	FROM sys.objects 
	WHERE name = 'Sales_By_Quarter')
DROP TABLE IF EXISTS Sales_By_Quarter

--Now create [Sales_By_Quarter] table which would hold all data from the quarterly sales data created above
PRINT ('Now get quarterly data into table')
GO
CREATE TABLE [Sales_By_Quarter] (
    [Product_ID] INT, 
    [Product_Name] NVARCHAR(150), 
    [First_Quarter] INT,
    [Second_Quarter] INT,
    [Third_Quarter] INT,
    [Last_Quarter] INT
)

PRINT 'Insert quarterly sales data into Sales_By_Quarter Table'
	INSERT INTO [Sales_By_Quarter] (
				[Product_ID]
				,[Product_Name]
				,[First_Quarter]
				,[Second_Quarter]
				,[Third_Quarter]
				,[Last_Quarter] 
				)
	SELECT p.product_id as [Product_ID]
		,lq.product_name as [Product_Name]
		,COALESCE(First_Quarter,0) as [First_Quarter] --If value is null, replace with 0
		,COALESCE(Second_Quarter,0) as [Second_Quarter] --If value is null, replace with 0
		,COALESCE(Third_Quarter,0) as [Third_Quarter] --If value is null, replace with 0
		,COALESCE(Last_Quarter,0) as [Last_Quarter] --If value is null, replace with 0
	FROM  products p
	FULL JOIN #Last_Quarter lq ON lq.product_id = p.product_id
	FULL JOIN #Third_Quarter tq ON tq.product_id = lq.product_id
	FULL JOIN  #Second_Quarter sq ON lq.product_id = sq.product_id
	FULL JOIN #First_Quarter fq ON fq.product_id = sq.product_id 
	WHERE ISNULL(NULLIF(lq.product_name,''),'') > '' --Do not include null values


CREATE CLUSTERED INDEX clix_sales_product_name ON Sales_By_Quarter(Product_ID)
GO

SELECT * FROM [Sales_By_Quarter]

/*
The percentage change is calculated with the formula (b - a) / a * 100
*/
PRINT 'Now get total quarter sales by summing all product sales in a quarter'
PRINT 'And Get the percentage difference of sales by quarter to quarter'
	SELECT SUM([First_Quarter]) as [First Quarter Total] --add all product sales made
			,CASE WHEN SUM([First_Quarter]) <> SUM([Second_Quarter]) --when the sum of first quarter is not the same as second quarter
			THEN (SUM(CAST([Second_Quarter] as FLOAT)) - SUM([First_Quarter])) / SUM([First_Quarter])  * 100 -- Find the difference of both sums divide it by the first quarter and multiply by 100 to get Perc_Difference
			END as Perc_Difference
		,SUM([Second_Quarter]) as [Second Quarter Total] --Repeat the same procedure for next quarters
			,CASE WHEN  SUM([Second_Quarter]) <> SUM([Third_Quarter])
			THEN ROUND((SUM(CAST([Third_Quarter] as FLOAT)) - SUM([Second_Quarter])) / SUM([Second_Quarter])  * 100,2)
			END as Perc_Difference
		,SUM([Third_Quarter]) as [Third Quarter Total]
			,CASE WHEN SUM([Third_Quarter]) <> SUM([Last_Quarter]) 
			THEN ROUND(((SUM(CAST([Last_Quarter] AS FLOAT)) - SUM([Third_Quarter])) / SUM([Third_Quarter])) * 100, 2)
			END AS Perc_Difference
		,SUM([Last_Quarter]) as [Last Quarter Total]
	FROM Sales_By_Quarter



--2. Most Purchased/Popular Product (Top 5):
----------------------------------------------------------------------------------
SELECT TOP 5 Product_ID
	,Product_Name
	,First_Quarter
	,Second_Quarter
	,Third_Quarter
	,Last_Quarter
	,First_Quarter + Second_Quarter + Third_Quarter + Last_Quarter as [Total]
FROM Sales_By_Quarter
ORDER BY [Total] DESC


--3. Create a Function for Number of Sales Made for a Particular Product:
----------------------------------------------------------------------------------
IF EXISTS (
	SELECT 1
	FROM sys.objects
	WHERE name = 'usp_sales_made'
)
DROP FUNCTION usp_sales_made
GO

CREATE FUNCTION usp_sales_made (@Product_Name VARCHAR(100))
RETURNS TABLE
AS
RETURN 
	SELECT Product_ID
		,Product_Name
		,First_Quarter
		,Second_Quarter
		,Third_Quarter
		,Last_Quarter
		,First_Quarter + Second_Quarter + Third_Quarter + Last_Quarter as [Total]
	FROM Sales_By_Quarter
	WHERE Product_Name = @Product_Name
GO

SELECT * FROM dbo.usp_sales_made('Guitar Stand')


--4. Most Used Payment Method:
------------------------------------------------------------------------------------
SELECT payment_method_desc
	,COUNT(payment_method_desc) as My_Count
FROM orders o
INNER JOIN payment_methods pm ON o.payment_method_id = pm.payment_method_id
GROUP BY payment_method_desc
ORDER BY My_Count DESC



--5. Delivery and Order Fulfillment Analysis:
------------------------------------------------------------------------------------
SELECT AVG(days_to_delivery) as Average_delivery_Period
	,MAX(days_to_delivery) as Longest_delivery_Period
	,MIN(days_to_delivery) as Shortest_delivery_Period
FROM
(
	SELECT  FORMAT(o.order_date, 'yyyy-MM-dd') as [Order_date]
		,d.ord_delivery_Date
		,DATEDIFF(day,FORMAT(o.order_date, 'yyyy-MM-dd'),ord_delivery_Date) as days_to_delivery
	FROM orders o
	INNER JOIN Order_Delivery d ON o.order_id = d.orderID
)X

--5 b How many order have taken over the average delivery period (3 days)
WITH delayed_deliveries
AS (
SELECT order_id
	,o.product_id
	,o.quantity
	,product_name
	,DATEDIFF(day,FORMAT(o.order_date, 'yyyy-MM-dd'),ord_delivery_Date) as days_to_delivery
FROM orders o
INNER JOIN Order_Delivery d ON o.order_id = d.orderID
INNER JOIN products p ON p.product_id = o.product_id
)
SELECT count(product_name) as no_of_orders_delayed
FROM delayed_deliveries
WHERE days_to_delivery > 3

--Out of 850 deliveries 283 have been delayed

--6. Customer with the Most Purchases:
----------------------------------------------------------------------------------------------------
WITH CTE
AS (
SELECT c.customer_id
	,forename + ' ' + surname as [Customer_name]
	,quantity
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
)
SELECT [Customer_name]
	,SUM(quantity) as Products_bought
FROM CTE
GROUP BY customer_id,[Customer_name]
ORDER BY Products_bought DESC


--7. Customer days till next order:
----------------------------------------------------------------------------------------------------
WITH CTE
AS (
SELECT c.customer_id
	,forename + ' ' + surname as [Customer_name]
	,quantity
	,order_date
	,LEAD(order_date,1) OVER (PARTITION BY forename + ' ' + surname ORDER BY order_date) as [Next_Purchase_Date]
FROM orders o
INNER JOIN customers c ON c.customer_id = o.customer_id
)
SELECT [Customer_name]
	,order_date
	,[Next_Purchase_Date]
	,CASE WHEN [Next_Purchase_Date] IS NULL THEN 0 
	ELSE
	DATEDIFF(day,order_date,[Next_Purchase_Date]) 
	END as days_till_next_order
FROM CTE


--8. How many customers repurchased within 30 days after their first purchase:
WITH CTE_Repurchases 
AS (
    SELECT 
        c.customer_id
        ,forename + ' ' + surname as [Customer_name]
        ,quantity
        ,order_date
        ,LEAD(order_date, 1) OVER (PARTITION BY c.customer_id ORDER BY order_date) as [Next_Purchase_Date]
    FROM orders o
    INNER JOIN customers c ON c.customer_id = o.customer_id
)
SELECT COUNT(retained_customers_within_30_days) as no_of_retained_customers_within_30_days
FROM (
	SELECT 
		[Customer_name]
		,MIN(order_date) as first_purchase_date
		,MIN([Next_Purchase_Date]) next_purchase_after_first
		,CASE WHEN DATEDIFF(DAY, MIN(order_date), MIN([Next_Purchase_Date])) <= 30 THEN 1 ELSE 0 END as retained_customers_within_30_days
	FROM CTE_Repurchases 
	GROUP BY [Customer_name]
) X
WHERE retained_customers_within_30_days = 1
