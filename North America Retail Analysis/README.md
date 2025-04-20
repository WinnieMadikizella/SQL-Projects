# North-America-Retail-Analysis--SQL

## Project Overview
This project involves analyzing sales data for North America Retail, a major retail company operating across multiple locations. As a data analyst, the goal was to transform raw sales data into a structured data warehouse using a star schema design and perform analysis to answer key business questions that can drive strategic decisions. North America Retail offers a diverse range of products to different customer segments with a focus on excellent customer service and shopping experience. This analysis aims to uncover insights on profitability, performance, product delivery, and customer behavior to identify improvement areas and suggest strategies to boost efficiency.


## Project Objectives
### Data Integration and Normalization:
Transform the raw dataset into a star schema, consisting of:
- One fact table: OrdersFactTable
- Multiple dimension tables: DimCustomers, DimProducts, DimCalendar, and DimLocation

Ensure data consistency and accuracy by:
- Removing redundant information
- Using unique keys for dimensions

## Key Business Questions Answered
This analysis seeks to address several key business questions:
1. What was the average delivery time for different product subcategories?
2. What was the average delivery time for each customer segment?
3. What are the top 5 fastest and slowest delivered products?
4. Which product subcategory generates the most profit?
5. Which customer segment generates the most profit?
6. Who are the top 5 customers contributing the most profit?
7. What is the total number of products categorized by subcategory?

## Tools Used
SQL Server

## Data Transformation Process
This project was implemented using SQL Server with various SQL techniques including:
1. Creating dimension tables (DimCustomers, DimProducts, DimCalendar, DimLocation) from the sales_retail dataset.
2. Removing duplicates using CTE and ROW_NUMBER().
3. Data type standardization in DimCalendar.
4. Creating the OrdersFactTable and linking it to dimension tables.
5. Assigning surrogate keys for uniqueness(e.g., ProductKey for DimProduct).
6. Established relationships between fact and dimension tables.
7. Conducting exploratory data analysis (EDA) to answer the key business questions.
8. JOIN operations.
9. Aggregation functions.
10. Date calculations (DATEDIFF).

## Dataset and Schema Transformation
The dataset has been transformed into a star schema format:
### Fact Table: OrdersFactTable
Contains transactional data such as order details, customer information, product IDs, delivery dates, sales, discounts, and profit.
### Dimension Tables:
- DimCustomers: Contains unique customer details such as Customer ID, Name, and Segment.
- DimLocation: Contains geographic details including Postal Code, Country, City, State, and Region.
- DimProducts: Contains product details, including Product ID, Category, Subcategory, and Product Name.
- DimCalendar: Stores date-related attributes such as Quarter, Year, and Week of the Year.

## Exploratory Data Analysis (EDA)
### 1. What was the average delivery time for different product subcategories?
```sql
SELECT * FROM OrdersFacttable;
SELECT * FROM DimProduct;
-- average delivery days for each subcategory
SELECT dp.Sub_Category, AVG(DATEDIFF(DAY, oft.Order_Date,oft.Ship_Date)) AS AvgDeliveryDays
FROM OrdersFacttable AS oft
LEFT JOIN DimProduct AS dp
	ON oft.ProductKey = dp.ProductKey
GROUP BY Sub_Category;
/* the average delivery days for chairs and bookcases subcategories is 32 days each, furnishings 
subcategory is 34 days and the tables subcategory 36 days */
```
### 2. What was the average delivery time for each customer segment?
```sql
SELECT * FROM OrdersFacttable;
SELECT * FROM DimCustomer;

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
```
### 3. What are the top 5 fastest and slowest delivered products?
```sql
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
```
### 4. Which product subcategory generates the most profit?
```sql
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
``` 
### 5. Which customer segment generates the most profit?
```sql
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
```
### 6. Who are the top 5 customers contributing the most profit?
```sql
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
```
### 7. What is the total number of products categorized by subcategory?
```
SELECT *
FROM DimProduct;

SELECT Sub_Category, COUNT(Product_Name) AS TotalProducts
FROM DimProduct
GROUP BY Sub_Category;
/* the total number of products by subcategory are 48, 87, 186 and 34 for Bookcases, Chairs,
Furnishings and Tables respectively */
```

## Insights & Recommendations 
## Key Insights:
### 1. Delivery Performance:
- Product Subcategories: Tables have the longest average delivery time (36 days), followed by Furnishings (34 days), while Chairs and Bookcases both average 32 days.
- Customer Segments: Corporate customers experience the longest delivery times (35 days), followed by Consumers (34 days), with the Home Office having the fastest deliveries (31 days).
- Delivery Extremes: There's a huge variance in delivery times:
   - Some products (primarily bookcases) are delivered instantly (0 days).
   - Several products take 214 days to deliver (over 7 months).
 
### 2. Profitability:
- Product Profitability: Chairs are the most profitable subcategory, generating $36,471.10 in profit.
- Segment Profitability: The Consumer segment drives the highest profit at $35,427.03.
- Customer Value: The top five customers (Laura Armstrong, Joe Elijah, Seth Vernon, Quincy Jones, and Maria Etezadi) each generate over $800 in profit, with the top customer contributing $1,156.17.

### 3. Product Portfolio:
- Product Distribution: Furnishings have the largest number of products (186), followed by Chairs (87), Bookcases (48), and Tables (34).

## Recommendations:
### 1. Optimize Delivery Operations:
- Investigate and address the extreme delivery delays (214 days) as these likely lead to customer dissatisfaction.
- Implement the successful delivery processes used for bookcases across other product categories.
- Create a specialized delivery process for Corporate customers to reduce their above-average delivery times.

### 2. Focus on High-Value Areas:
- Invest in expanding the Chair subcategory since it generates the highest profit.
- Develop targeted marketing and loyalty programs for the Consumer segment.
- Create a VIP program for the top 5 customers to increase their retention and lifetime value.

### 3. Product Portfolio Optimization:
- Evaluate if the large number of Furnishings products (186) is justified by their profitability.
- Consider expanding the Tables category (only 34 products) but with improved delivery processes.

### 4. Performance Metrics:
- Implement delivery time KPIs with targets for each product category and customer segment.
- Track profit margins across segments and subcategories for continuous optimization.

### 5. Customer Experience Improvements:
- Set realistic delivery expectations for customers based on their segment and product choices.
- Offer expedited shipping options for high-value customers and segments.

## Conclusion
This project successfully structured the sales data into a star schema, enabling efficient data retrieval and analysis. The insights derived from the analysis provide actionable recommendations for improving business performance, optimizing inventory management, and enhancing customer satisfaction. Addressing delivery delays and investing in profitable product segments will enhance revenue and customer loyalty.
