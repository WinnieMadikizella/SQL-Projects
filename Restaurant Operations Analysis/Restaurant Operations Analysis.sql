USE restaurant_data;

-- selecting the menu_items table
SELECT * FROM menu_items;

UPDATE menu_items
SET price = ROUND(price, 2);

--selecting the order_details table
SELECT * FROM order_details;

ALTER TABLE order_details 
ALTER COLUMN order_time TIME(0);


-- OBJECTIVE 1: EXPLORE THE MENU ITEMS TABLE
-- view menu items table and find number of items on the menu
SELECT * FROM menu_items;

SELECT COUNT(*) FROM menu_items;
/* there are 32 items on the menu */

-- least and most expensive items on the menu
SELECT * FROM menu_items
ORDER BY price;
/* the least expensive item is Edamame at 5.00 */

SELECT * FROM menu_items
ORDER BY price DESC;
/*the most expensive item is Shrimp Scampi at 19.95 */

-- how many Italian dishes are on the menu?
SELECT COUNT(*) FROM menu_items
WHERE category = 'Italian';
/* 9 Italian dishes */

-- the least and most expensive Italian dishes on the menu
SELECT * FROM menu_items
WHERE category = 'Italian'
ORDER BY price;
/* the least expensive Italian dish on the menu is Spaghetti at 14.50 */

SELECT * FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC;
/* the most expensive is Shrimp Scampi at 19.95 */

-- number of dishes in each category
SELECT category, COUNT(menu_item_id) AS num_dishes
FROM menu_items
GROUP BY category;
/* America - 6, Asian - 8, Italian and Mexican each 9 */

-- average dish price within each category
SELECT category, AVG(price) AS avg_price
FROM menu_items
GROUP BY category;
/* Italian dishes are the most expensive at 16.75 while American dishes the least expensive at
10.07 */


-- OBJECTIVE 2: EXPLORE THE ORDER DETAILS TABLE
-- view the order details table, what is the date range of the table?
SELECT * FROM order_details;

SELECT MIN(order_date), MAX(order_date)
FROM order_details;
/* date range January 01, 2023 to March 31, 2023 */

-- how many orders were made within this date range?
SELECT * FROM order_details;

SELECT COUNT(DISTINCT order_id) 
FROM order_details;
/* 5370 unique orders were made during this period */

-- how many items were ordered within this date range?
SELECT COUNT(*) FROM order_details;
/* 12234 iitems ordered during this period */

-- which orders had the most number of items?
SELECT order_id, COUNT(item_id) AS num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items DESC;
/* the order_id with the most number of items at 14 are 1957, 330, 443, 3473, 2675, 4305, 440 */

-- how many orders had more than 12 items?
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


-- OBJECTIVE 3: USE BOTH TABLES TO UNDERSTAND HOW CUSTOMERS ARE REACTING TO THE NEW MENU

-- combine the menu_items and the order_details into a single table
SELECT * FROM menu_items;
SELECT * FROM order_details;

-- use LEFT JOIN to join the two tables on item_id to keep all the information in the order_details table
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id;

-- what were the least and most ordered items?
SELECT item_name, COUNT(order_details_id) AS num_orders_bought
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY item_name
ORDER BY COUNT(order_details_id);
/* the least ordered item was Chicken Tacos - 123 orders */

SELECT item_name, COUNT(order_details_id) AS num_orders_bought
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY item_name
ORDER BY COUNT(order_details_id) DESC;
/*the most ordered item was Hamburger - 622 orders*/

-- what categories were they in?
SELECT item_name, category, COUNT(order_details_id) AS num_orders_bought
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY item_name, category
ORDER BY COUNT(order_details_id);
/* the Chicken Tacos are in Mexican category while Hamburger in American Category */

-- what were the top 5 orders that spent the most money?
SELECT TOP 5 order_id, SUM(price) AS total_spend
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY SUM(price) DESC;
/* the top 5 orders that spent the most are 440 at 192.15, 2075 at 191.05, 1957 at 190.10, 330 at
189.70 and 2675 at 185.10 */

-- view the details of the highest spent order, what insights can you gather from the results?
SELECT *
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id = 440;

SELECT category, COUNT(item_id) AS num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id = 440
GROUP BY category;

SELECT item_name, SUM(price) AS total_spend
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id = 440
GROUP BY item_name
ORDER BY SUM(price) DESC;

/* Italian dishes were the most popular at 8 items, while the rest were at 2 items each. */

-- view the details of the TOP 5 highest spent orders, what insights can you gather from the results?

SELECT TOP 5 order_id, SUM(price) AS total_spend
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
GROUP BY order_id
ORDER BY SUM(price) DESC;

SELECT category, COUNT(item_id) AS num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY category;
/* the top 5 spend orders are ordering more Italian food at 26 items and the least ordered is the 
American food at 10 items */

SELECT order_id, category, COUNT(item_id) AS num_items
FROM order_details od
LEFT JOIN menu_items mi
	ON od.item_id = mi.menu_item_id
WHERE order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY order_id, category;
/* Italian food seems to be the most popular choice among customers */