# Optimizing Restaurant Performance Through SQL Analysis

## Project Overview
The Restaurant Operations Analysis project evaluates sales performance, customer preferences, and pricing strategies using data from the menu_items and order_details tables. The goal is to generate actionable insights that can help optimize menu offerings, pricing structures, and overall restaurant profitability.

## Data Source
The dataset used is from Maven Dataset and include:
- `menu_items.csv` - consists of menu_item_id, item_name, category and price.
- `order_details.csv` - consists of order_details_id, order_id, order_date, order_time and item_id.

## Technology Used
- **SQL** (Data analysis & queries)

## Data Cleaning and Preparation
1. Data importation and inspection
2. Ensure column types match expected formats
3. Convert inconsistent date/time formats
     ```sql
     SELECT * FROM menu_items;
     UPDATE menu_items
     SET price = ROUND(price, 2);
     ```

     ```sql
     SELECT * FROM order_details;
     ALTER TABLE order_details
     ALTER COLUMN order_time TIME(0);
     ```

## Objectives
1. Explore the Menu items table
2. Explore the Order details table
3. Use both tables to understand how customers are reacting to the new menu

## Business Needs Addressed
1. Menu Optimization: Identify underperforming items and potential menu adjustments.
2. Pricing Strategy Improvement: Evaluate how price influences order volume and revenue.
3. Sales Growth: Use data-driven insights to increase average order value and frequency.
4. Customer Retention: Develop strategies to enhance customer loyalty and repeat purchases.

## Methodology: How Insights Were Discovered
### Data Exploration:
- Analyzed the menu_items and order_details tables to understand menu composition and order trends.
- Used SQL queries to retrieve key statistics such as order counts, item popularity, and revenue distribution.

### 1. Explore the Menu items table
- Assess the number of menu items and find number of items on the menu.
    ```sql
    SELECT * FROM menu_items;
    SELECT COUNT(*) FROM menu_items;
    /* there are 32 items on the menu */
    ```
    
- Identify the most and least expensive dishes and their respective categories.
    ```sql
    SELECT * FROM menu_items
    ORDER BY price;
    /* the least expensive item is Edamame at 5.00 while */
    ```

    ```sql
    SELECT * FROM menu_items
    ORDER BY price DESC;
    /*the most expensive item is Shrimp Scampi at 19.95 */
    ```
    
- How many Italian dishes are on the menu?
    ```sql
    SELECT COUNT(*) FROM menu_items
    WHERE category = 'Italian';
    /* 9 Italian dishes */
    ```
    
- The least and most expensive Italian dishes on the menu
    ```sql
    SELECT * FROM menu_items
    WHERE category = 'Italian'
    ORDER BY price;
    /* the least expensive Italian dish on the menu is Spaghetti at 14.50 */
    ```

    ```sql
    SELECT * FROM menu_items
    WHERE category = 'Italian'
    ORDER BY price DESC;
    /* the most expensive is Shrimp Scampi at 19.95 */
    
- Number of dishes in each category
    ```sql
    SELECT category, COUNT(menu_item_id) AS num_dishes
    FROM menu_items
    GROUP BY category;
    /* America - 6, Asian - 8, Italian and Mexican each 9 */
    ```
    
- Average dish price within each category
    ```sql
    SELECT category, AVG(price) AS avg_price
    FROM menu_items
    GROUP BY category;
    /* Italian dishes are the most expensive at 16.75 while American dishes the least expensive at 10.07 */
    ```

### 2. Explore the Order details table
-   View the order details table, what is the date range of the table?
    ```sql
    SELECT * FROM order_details;
    SELECT MIN(order_date), MAX(order_date)
    FROM order_details;
    /* date range January 01, 2023 to March 31, 2023 */
    ```

- How many orders were made within this date range?
    ```sql
    SELECT * FROM order_details;
    SELECT COUNT(DISTINCT order_id)
    FROM order_details;
    /* 5370 unique orders were made during this period */
    ```

- How many items were ordered within this date range?
    ```sql
    SELECT COUNT(*) FROM order_details;
    /* 12234 iitems ordered during this period */
    ```
    
- Which orders had the most number of items?
    ```sql
    SELECT order_id, COUNT(item_id) AS num_items
    FROM order_details
    GROUP BY order_id
    ORDER BY num_items DESC;
    /* the order_id with the most number of items at 14 are 1957, 330, 443, 3473, 2675, 4305, 440 */
    ```
- How many orders had more than 12 items?
    ```sql
    -- count items per order filtering orders with more than 12
    SELECT order_id, COUNT(item_id) AS num_items
    FROM order_details
    GROUP BY order_id
    HAVING COUNT(item_id) > 12;
    -- count number of orders with more than 12 items
    SELECT COUNT(*)
    FROM
      (SELECT order_id, COUNT(item_id) AS num_items
      FROM order_details
      GROUP BY order_id
      HAVING COUNT(item_id) > 12) AS num_orders;
    /* 20 orders had more than 12 items */
    ```

### 3. Use both tables to understand how customers are reacting to the new menu
- Combine the menu_items and the order_details into a single table
    ```sql
    SELECT * FROM menu_items;
    SELECT * FROM order_details;
    -- use LEFT JOIN to join the two tables on item_id to keep all the information in the order_details table
    SELECT *
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id;
    ```
    
- What were the least and most ordered items?
    ```sql
    SELECT item_name, COUNT(order_details_id) AS num_orders_bought
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    GROUP BY item_name
    ORDER BY COUNT(order_details_id);
    /* the least ordered item was Chicken Tacos - 123 orders */
    ```

    ```sql
    SELECT item_name, COUNT(order_details_id) AS num_orders_bought
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    GROUP BY item_name
    ORDER BY COUNT(order_details_id) DESC;
    /*the most ordered item was Hamburger - 622 orders*/
    ```
- What categories were they in?
  ```sql
  SELECT item_name, category, COUNT(order_details_id) AS num_orders_bought
  FROM order_details od
  LEFT JOIN menu_items mi
	  ON od.item_id = mi.menu_item_id
  GROUP BY item_name, category
  ORDER BY COUNT(order_details_id);
  /* the Chicken Tacos are in Mexican category while Hamburger in American Category */
  ```
  
- What were the top 5 orders that spent the most money?
    ```sql
    SELECT TOP 5 order_id, SUM(price) AS total_spend
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    GROUP BY order_id
    ORDER BY SUM(price) DESC;
    /* the top 5 orders that spent the most are 440 at 192.15, 2075 at 191.05, 1957 at 190.10, 330 at 189.70 and 2675 at 185.10 */
    ```
- View the details of the highest spent order, what insights can you gather from the results?
    ```sql
    SELECT *
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    WHERE order_id = 440;
    ```

    ```sql
    SELECT category, COUNT(item_id) AS num_items
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    WHERE order_id = 440
    GROUP BY category;
    ```

    ```sql
    SELECT item_name, SUM(price) AS total_spend
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    WHERE order_id = 440
    GROUP BY item_name
    ORDER BY SUM(price) DESC;
    /* Italian dishes were the most popular at 8 items, while the rest were at 2 items each. */
    ```
- View the details of the TOP 5 highest spent orders, what insights can you gather from the results?
    ```sql
    SELECT TOP 5 order_id, SUM(price) AS total_spend
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    GROUP BY order_id
    ORDER BY SUM(price) DESC;
    ```

    ```sql
    SELECT category, COUNT(item_id) AS num_items
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    WHERE order_id IN (440, 2075, 1957, 330, 2675)
    GROUP BY category;
    /* the top 5 spend orders are ordering more Italian food at 26 items and the least ordered is the American food at 10 items */
    ```
    ```sql
    SELECT order_id, category, COUNT(item_id) AS num_items
    FROM order_details od
    LEFT JOIN menu_items mi
      ON od.item_id = mi.menu_item_id
    WHERE order_id IN (440, 2075, 1957, 330, 2675)
    GROUP BY order_id, category;
    /* Italian food seems to be the most popular choice among customers */
    ```

# 📊 Key Insights & Recommendations
## Key Insights
### 1. Menu Composition & Pricing
- Italian dishes are the most expensive (average $16.75) while American dishes are the cheapest (average $10.07).
- The menu is relatively balanced across categories (American: 6, Asian: 8, Italian: 9, Mexican: 9) with 32 menu items.
- The price range spans from $5.00 (Edamame) to $19.95 (Shrimp Scampi).

### 2. Customer Behavior
- High volume: 5,370 unique orders with 12,234 total items over just 3 months.
- Popularity disconnect: Despite being the priciest category, Italian dishes dominated the highest-spending orders.
- The American category shows an interesting pattern - contains both the most ordered item (Hamburger: 622 orders) but is the least represented in high-value orders.

### 3. Order Patterns
- Most orders are moderate in size, but 20 orders had more than 12 items.
- The highest-spending order (#440) had 14 items totaling $192.15, with a heavy preference for Italian dishes.

## Recommendations
### 1. Menu Optimization
- Revitalize the Mexican category - Chicken Tacos was the least ordered item (123 orders), suggesting it needs improvement or replacement.
- Consider premium pricing for popular items like the Hamburger - its high volume suggests price elasticity.
  
### 2. Customer Experience Strategy
- Create Italian-focused combo deals or family meals based on their popularity in high-value orders.
- Develop a loyalty program targeted at those big-spending customers (over $180 per order).

### 3. Revenue Growth Opportunities
- Introduce more premium American options to capitalize on popularity while increasing the average price point.
- Consider seasonal menu rotations focusing on the Asian category, which seems middle-of-road in both pricing and ordering frequency.

### 4. Operational Efficiency
- Review staffing during peak hours based on order volume data.
- Streamline kitchen operations for most popular items to improve throughput.
