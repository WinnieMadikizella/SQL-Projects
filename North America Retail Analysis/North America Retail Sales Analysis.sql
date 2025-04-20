USE North_America_Sales;

SELECT * FROM sales_retail;

--spilt into fact and dimension tables
-- to create a DimCustmer table from the sales_retail table
SELECT * INTO DimCustomer
FROM
	(SELECT Customer_ID, Customer_Name, Segment
	FROM sales_retail) AS DimC;

SELECT * FROM DimCustomer;

--remove duplicates from DimCustomer table
WITH CTE_DimC
AS
	(SELECT Customer_ID, Customer_Name, Segment, 
	ROW_NUMBER() OVER(PARTITION BY Customer_ID, Customer_Name, Segment
	ORDER BY Customer_ID ASC) AS row_num
	FROM DimCustomer)
DELETE FROM CTE_DimC
WHERE row_num > 1;

SELECT * FROM DimCustomer;

-- to create a DimLocation table from the sales_retail table
SELECT * INTO DimLocation
FROM
	(SELECT Postal_Code, Country, City, State, Region
	FROM sales_retail) AS DimL;

SELECT * FROM DimLocation;

--remove duplicates from DimLocation table
WITH CTE_DimL
AS
	(SELECT Postal_Code, Country, City, State, Region, 
	ROW_NUMBER() OVER(PARTITION BY Postal_Code, Country, City, State, Region
	ORDER BY Postal_Code ASC) AS row_num
	FROM DimLocation)
DELETE FROM CTE_DimL
WHERE row_num > 1;

SELECT * FROM DimLocation;

-- to create a DimProduct table from the sales_retail table
SELECT * INTO DimProduct
FROM
	(SELECT Product_ID, Category, Sub_Category, Product_Name
	FROM sales_retail) AS DimP;

SELECT * FROM DimProduct;

--remove duplicates from DimProduct table
WITH CTE_DimP
AS
	(SELECT Product_ID, Category, Sub_Category, Product_Name, 
	ROW_NUMBER() OVER(PARTITION BY Product_ID, Category, Sub_Category, Product_Name
	ORDER BY Product_ID ASC) AS row_num
	FROM DimProduct)
DELETE FROM CTE_DimP
WHERE row_num > 1;

SELECT * FROM DimProduct;

SELECT * FROM DimCalendar;
-- check the data types of the columns in DimCalendar table
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'DimCalendar';

-- cahnge data type
ALTER TABLE DimCalendar 
ALTER COLUMN Quarter_Q NVARCHAR(10);  -- change from money 

ALTER TABLE DimCalendar 
ALTER COLUMN Quarter_Year VARCHAR(10);  -- reduce unnecessary storage

ALTER TABLE DimCalendar 
ALTER COLUMN Week_of_Year_W VARCHAR(10);

ALTER TABLE DimCalendar 
ALTER COLUMN Day_Name VARCHAR(20);

ALTER TABLE DimCalendar 
ALTER COLUMN Day_Name VARCHAR(20);

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'DimCalendar';

ALTER TABLE DimCalendar DROP COLUMN Date;

-- to create a SalesFact table from the sales_retail table
SELECT * INTO OrdersFacttable
FROM
	(SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code, 
	Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit
	FROM sales_retail) AS OrderFact;

SELECT * FROM OrdersFacttable;

--remove duplicates from OrdersFacttable
WITH CTE_OrderFact
AS
	(SELECT Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, Postal_Code, 
	Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit, 
	ROW_NUMBER() OVER(PARTITION BY Order_ID, Order_Date, Ship_Date, Ship_Mode, Customer_ID, 
	Postal_Code, Retail_Sales_People, Product_ID, Returned, Sales, Quantity, Discount, Profit
	ORDER BY Order_ID ASC) AS row_num
	FROM OrdersFacttable)
DELETE FROM CTE_OrderFact
WHERE row_num > 1;

SELECT * FROM OrdersFacttable;


-- create the ERD
-- confirm the duplicate
SELECT * FROM DimProduct
WHERE Product_ID = 'FUR-FU-10004091';
-- confirms same Product_ID is assigned to two products

/* now add a surrogate key called ProductKey to serve as the unique identifier for the 
DimProduct table */
ALTER TABLE DimProduct
ADD ProductKey INT IDENTITY(1,1) PRIMARY KEY;

SELECT * FROM DimProduct;

-- add the ProductKey to the OrdersFacttable
ALTER TABLE OrdersFacttable
ADD ProductKey INT;

SELECT * FROM OrdersFacttable;

--linking the two tables - DimProduct and OrdersFacttable
UPDATE OrdersFacttable
SET ProductKey = DimProduct.ProductKey
FROM OrdersFacttable
JOIN DimProduct
	ON OrdersFacttable.Product_ID = DimProduct.Product_ID;

SELECT * FROM OrdersFacttable;

-- drop Product_ID in the OrdersFacttable and DimProduct table
ALTER TABLE DimProduct
DROP COLUMN Product_ID;

SELECT * FROM DimProduct;

ALTER TABLE OrdersFacttable
DROP COLUMN Product_ID;

SELECT * FROM OrdersFacttable;

SELECT * FROM OrdersFacttable
WHERE Order_ID = 'CA-2014-102652';
-- two items with the same Order_ID

-- add a unique identifier to the OrdersFacttable
-- Add the ROW_ID column as NOT NULL
ALTER TABLE OrdersFacttable 
ADD ROW_ID INT NOT NULL DEFAULT 0;

WITH CTE AS (
    SELECT ROW_ID, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
    FROM OrdersFacttable)
UPDATE CTE SET ROW_ID = RowNum;

-- Add primary key constraint 
ALTER TABLE OrdersFacttable
ADD CONSTRAINT PK_OrdersFacttable_ROW_ID PRIMARY KEY (ROW_ID);

-- Exploratory data analysis
--The goal of your analysis is to answer key business questions such as:

-- What was the Average delivery days for different product subcategory?
SELECT * FROM OrdersFacttable;
SELECT * FROM DimProduct;

-- delivery days for each subcategory
SELECT dp.Sub_Category, DATEDIFF(DAY, oft.Order_Date,oft.Ship_Date) AS DeliveryDays
FROM OrdersFacttable AS oft
LEFT JOIN DimProduct AS dp
	ON oft.ProductKey = dp.ProductKey;

-- average delivery days for each subcategory
SELECT dp.Sub_Category, AVG(DATEDIFF(DAY, oft.Order_Date,oft.Ship_Date)) AS AvgDeliveryDays
FROM OrdersFacttable AS oft
LEFT JOIN DimProduct AS dp
	ON oft.ProductKey = dp.ProductKey
GROUP BY Sub_Category;
/* the average delivery days for chairs and bookcases subcategories is 32 days each, furnishings 
subcategory is 34 days and tables subcategory 36 days */

-- What was the Average delivery days for each segment?
SELECT * FROM OrdersFacttable;
SELECT * FROM DimCustomer;

-- delivery days for each segment
SELECT dm.Segment, DATEDIFF(DAY, oft.Order_Date,oft.Ship_Date) AS DeliveryDays
FROM OrdersFacttable AS oft
LEFT JOIN DimCustomer AS dm
	ON oft.Customer_ID = dm.Customer_ID;

-- average delivery days for each segment
SELECT dm.Segment, AVG(DATEDIFF(DAY, oft.Order_Date,oft.Ship_Date)) AS AvgDeliveryDays
FROM OrdersFacttable AS oft
LEFT JOIN DimCustomer AS dm
	ON oft.Customer_ID = dm.Customer_ID
GROUP BY Segment
ORDER BY AvgDeliveryDays;
/* the average delivery days for each segment is:
Home Office - 31 days
Consumer - 34 days
Corporate - 35 days */

-- What are the Top 5 Fastest delivered products and Top 5 slowest delivered products?
SELECT * FROM OrdersFacttable;
SELECT * FROM DimProduct;

-- top 5 fastest delivered products
SELECT TOP 5 (dp.Product_Name), DATEDIFF(DAY, oft.Order_Date,oft.Ship_Date) AS DeliveryDays
FROM OrdersFacttable AS oft
LEFT JOIN DimProduct AS dp
	ON oft.ProductKey = dp.ProductKey
ORDER BY 2;
/* top 5 fastest delivered products have 0 delivery days each: 
- Sauder Camden County Barrister Bookcase, Planked Cherry Finish
- Sauder Inglewood Library Bookcases
- O'Sullivan 2-Shelf Heavy-Duty Bookcases
- O'Sullivan Plantations 2-Door Library in Landvery Oak	
- O'Sullivan Plantations 2-Door Library in Landvery Oak */

-- top 5 slowest delivered products
SELECT TOP 5 (dp.Product_Name), DATEDIFF(DAY, oft.Order_Date,oft.Ship_Date) AS DeliveryDays
FROM OrdersFacttable AS oft
LEFT JOIN DimProduct AS dp
	ON oft.ProductKey = dp.ProductKey
ORDER BY 2 DESC;
/* top 5 slowest delivered products have 214 delivery days each:
- Bush Mission Pointe Library	214
- Hon Multipurpose Stacking Arm Chairs	214
- Global Ergonomic Managers Chair	214
- Tensor Brushed Steel Torchiere Floor Lamp	214
- Howard Miller 11-1/2" Diameter Brentwood Wall Clock */

-- Which product Subcategory generate most profit?
SELECT * FROM OrdersFacttable;
SELECT * FROM DimProduct;

SELECT dp.Sub_Category, SUM(oft.Profit) AS TotalProfit
FROM OrdersFacttable AS oft
LEFT JOIN DimProduct AS dp
	ON oft.ProductKey = dp.ProductKey
WHERE oft.Profit > 0
ORDER BY dp.Sub_Category;

-- handle NULL values
SELECT COALESCE(dp.Sub_Category, 'Unknown') AS Sub_Category, 
       ROUND(SUM(oft.Profit),2) AS TotalProfit
FROM OrdersFacttable AS oft
LEFT JOIN DimProduct AS dp 
    ON oft.ProductKey = dp.ProductKey
WHERE oft.Profit > 0
GROUP BY dp.Sub_Category
ORDER BY 2 ASC;
/* the subcategory chairs generate the highest profit with a total of $36,471.10 */ 

-- Which segment generates the most profit?
SELECT * FROM OrdersFacttable;
SELECT * FROM DimCustomer;

SELECT dm.Segment, ROUND(SUM(oft.Profit),2) AS TotalProfit
FROM OrdersFacttable AS oft
LEFT JOIN DimCustomer AS dm
	ON oft.Customer_ID = dm.Customer_ID
WHERE oft.Profit > 0
GROUP BY dm.Segment
ORDER BY 2 DESC;
/* the Consumer segment generates the highest profit at $35,427.03 */

-- Which Top 5 customers made the most profit?
SELECT * FROM OrdersFacttable;
SELECT * FROM DimCustomer;

SELECT TOP 5 (dm.Customer_Name), ROUND(SUM(oft.Profit),2) AS TotalProfit
FROM OrdersFacttable AS oft
LEFT JOIN DimCustomer AS dm
	ON oft.Customer_ID = dm.Customer_ID
WHERE oft.Profit > 0
GROUP BY dm.Customer_Name
ORDER BY 2 DESC;
/* the top 5 customers with the most profits are:
- Laura Armstrong - $1156.17
- Joe Elijah - $1121.60
- Seth Vernon - $1047.14
- Quincy Jones - $1013.13
- Maria Etezadi - $822.65 */

-- What is the total number of products by Subcategory?
SELECT *
FROM DimProduct;

SELECT Sub_Category, COUNT(Product_Name) AS TotalProducts
FROM DimProduct
GROUP BY Sub_Category;
/* the total number of products by subcategory are 48, 87, 186 and 34 for Bookcases, Chairs,
Furnishings and Tables respectively */


