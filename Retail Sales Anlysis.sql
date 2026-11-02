
CREATE DATABASE retail_sales;
USE retail_sales;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    quantity INT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

SELECT *
FROM customers;

SELECT *
FROM products;

SELECT *
FROM orders;

 -- Data Validation
-- 1. Display the number of records in customers, products, and orders.
SELECT COUNT(*) AS number_of_customers
FROM customers;

SELECT COUNT(*) AS number_of_products
FROM products;

SELECT COUNT(*) AS number_of_orders
FROM orders;


-- 2. Show all customers, sorted by customer_id.
SELECT *
FROM customers
ORDER BY customer_id ASC;


-- 3. Display product names, categories, and prices from highest to lowest price
SELECT product_name,
       category,
       price
FROM products
ORDER BY price DESC;       

-- 4. List all orders placed during March 2026.
SELECT *
FROM orders
WHERE order_date>='2026-03-01'
AND order_date<'2026-04-01';

-- 5. Find orders where quantity is zero or negative, and check whether any customer or product references are missing
SELECT *
FROM orders
WHERE quantity <= 0 OR quantity IS NULL;

-- Check missing customer references
SELECT o.*
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


--  Check missing product references
SELECT o.*
FROM orders o
LEFT JOIN products p
    ON o.product_id = p.product_id
WHERE p.product_id IS NULL;

--  Sales Analysis 
-- 6.Calculate total revenue across all orders. Revenue per order line = quantity × product price.
SELECT
SUM(o.quantity*p.price) AS revenue
FROM orders o 
INNER JOIN products p 
ON o.product_id = p.product_id;

-- 7.Find the total quantity of products sold.
SELECT SUM(o.quantity) AS total_quantity
FROM products p 
INNER JOIN 
orders o 
ON p.product_id = o.product_id;

-- 8.Display monthly revenue in chronological order.
SELECT DATE_FORMAT(o.order_date,'%Y-%m')AS month,
 SUM(o.quantity*p.price) AS monthly_revenue
FROM orders o 
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY  DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY month ASC;

-- 9.Show total revenue and units sold for each category.
SELECT p.category,
SUM(o.quantity*p.price) AS total_revenue,
SUM(o.quantity) AS total_units_sold
FROM orders o 
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 10.Rank products by total revenue, from highest to lowest.
WITH CTE_Product_Revenue AS (
SELECT p.product_id, p.product_name,
SUM(o.quantity*p.price) AS total_revenue
FROM products p
INNER JOIN 
orders o 
ON p.product_id = o.product_id
GROUP BY p.product_name,p.product_id
),
CTE_Product_Ranking AS (
SELECT product_id ,product_name,
total_revenue,
DENSE_RANK() OVER( ORDER BY total_revenue DESC) AS rn 
FROM CTE_Product_Revenue
)
SELECT product_id,product_name,
total_revenue,
rn
FROM CTE_Product_Ranking
ORDER BY total_revenue DESC;

-- 11. Calculate the average revenue per order line.
SELECT AVG(o.quantity*p.price) AS average_revenue
FROM orders o 
INNER JOIN 
products p 
ON o.product_id = p.product_id;

-- 12.Identify the month with the highest total revenue
WITH CTE_Monthly_Revenue AS (
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
SUM(o.quantity*p.price) AS total_revenue
FROM orders o 
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
),
CTE_Best_Sales_Month AS (
SELECT month,
total_revenue,
DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS rn 
FROM CTE_Monthly_Revenue
)
SELECT month,
total_revenue,
rn
FROM CTE_Best_Sales_Month
WHERE rn = 1;

-- Customer & Product Analysis

-- 13. Display the five customers with the highest total spending.
WITH CTE_Customer_Spending AS (
SELECT c.customer_id,
       c.customer_name,
SUM(o.quantity*p.price) AS total_spending
FROM customers c 
INNER JOIN 
orders o 
ON c.customer_id = o.customer_id
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY c.customer_id,
         c.customer_name
),
CTE_Top_Customers AS (
SELECT customer_id,
customer_name,
total_spending,
DENSE_RANK() OVER(ORDER BY total_spending DESC) AS rn 
FROM CTE_Customer_Spending
)
SELECT customer_id,
customer_name,
total_spending
FROM CTE_Top_Customers
WHERE rn<=5
ORDER BY total_spending DESC;

-- 14. Find customers who placed more than one order.
SELECT c.customer_id,
       c.customer_name,
COUNT(o.order_id) AS total_orders
FROM customers c 
INNER JOIN 
orders o 
ON c.customer_id = o.customer_id
GROUP BY c.customer_id,
         c.customer_name
HAVING COUNT(o.order_id)>1
ORDER BY total_orders DESC;         

-- 15. For every customer, show order count, total units purchased, and total spending, including customers with no orders.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.quantity), 0) AS total_units_purchased,
    COALESCE(SUM(o.quantity * p.price), 0) AS total_spending
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
LEFT JOIN products p
    ON o.product_id = p.product_id
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY c.customer_id;

-- 16. Identify the product or products with the highest total units sold.
WITH CTE_Product_Units_Sold AS (
SELECT p.product_id,
       p.product_name,
SUM(o.quantity) AS total_units_sold
FROM products p 
INNER JOIN 
orders o 
ON p.product_id = o.product_id
GROUP BY p.product_id,
p.product_name
),
CTE_Best_Selling_Product AS (
SELECT product_id,
product_name,
total_units_sold,
RANK() OVER(ORDER BY total_units_sold DESC) AS rn 
FROM CTE_Product_Units_Sold
)
SELECT product_id,
product_name,
total_units_sold
FROM CTE_Best_Selling_Product
WHERE rn = 1;       

-- 17.Calculate total revenue for each customer state.
SELECT c.state,
SUM(o.quantity*p.price) AS total_revenue
FROM customers c 
INNER JOIN 
orders o 
ON c.customer_id = o.customer_id
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY c.state
ORDER BY total_revenue DESC;

-- 18. Find products that have no matching records in the orders table
SELECT p.product_id,
p.product_name
FROM products p
LEFT JOIN 
orders o 
ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- Advanced SQL
-- 19. Rank products by revenue within each category using a window function.
WITH CTE_Product_Revenue AS (
SELECT p.product_id,p.category,
       p.product_name,
SUM(o.quantity*p.price) AS total_revenue
FROM products p 
INNER JOIN 
orders o 
ON p.product_id = o.product_id
GROUP BY p.product_id,p.category,
         p.product_name,
         p.product_id
),
CTE_Category_Product_Ranking AS (
SELECT product_id,category,
product_name,
total_revenue,
RANK() OVER(PARTITION BY category ORDER BY total_revenue DESC) AS rn 
FROM CTE_Product_Revenue
)    
SELECT product_id,category,
product_name,
total_revenue,
rn
FROM CTE_Category_Product_Ranking
ORDER BY category,rn;
  

-- 20.Show monthly revenue and cumulative revenue over time.
WITH CTE_monthly_revenue AS (
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
SUM(o.quantity*p.price) AS monthly_revenue
FROM orders o 
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
)
SELECT month,
monthly_revenue,
SUM(monthly_revenue) OVER(ORDER BY month ASC) AS cumulative_revenue
FROM CTE_monthly_revenue
ORDER BY month ASC;

-- 21.For each month, show revenue, previous month's revenue, and the difference.
WITH CTE_mom AS (
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
SUM(o.quantity*p.price) AS monthly_revenue
FROM orders o 
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
),
CTE_previous_month_revenue AS (
SELECT month,
monthly_revenue,
LAG(monthly_revenue) OVER(ORDER BY month ASC) AS previous_month_revenue
FROM CTE_mom
)
SELECT month,
monthly_revenue,
previous_month_revenue,
ROUND((monthly_revenue-previous_month_revenue),2) AS revenue_difference
FROM CTE_previous_month_revenue
ORDER BY month ASC;

-- 22.Calculate each product category's percentage of total revenue.
WITH CTE_revenue_contribution AS (
SELECT p.category,
SUM(o.quantity*p.price) AS total_revenue
FROM products p 
INNER JOIN 
orders o 
ON p.product_id = o.product_id
GROUP BY p.category
)
SELECT category,
total_revenue,
ROUND(100.0*total_revenue/SUM(total_revenue) OVER(),2) AS revenue_contribution_percentage
FROM CTE_revenue_contribution
ORDER BY revenue_contribution_percentage DESC;

-- 23.Find the product with the second-highest total revenue; handle ties appropriately.
WITH CTE_second_highest_revenue AS (
SELECT p.product_id,
       p.product_name,
SUM(o.quantity*p.price) AS total_revenue
FROM products p 
INNER JOIN 
orders o 
ON p.product_id =o.product_id
GROUP BY 
p.product_id,
p.product_name
),
CTE_rank AS (
SELECT product_id,
product_name,
total_revenue,
DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS rn 
FROM CTE_second_highest_revenue
)
SELECT product_id,
product_name,
total_revenue
FROM CTE_rank
WHERE rn = 2;

-- 24. Find customers whose total spending is greater than the average customer spending.
WITH CTE_Customer_Spending AS (
SELECT c.customer_id,
       c.customer_name,
COALESCE(SUM(o.quantity*p.price),0)AS total_spending
FROM customers c 
LEFT JOIN 
orders o 
ON c.customer_id = o.customer_id
LEFT JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY 
c.customer_id,
c.customer_name
),
CTE_Average_Customer_Spending AS (
SELECT customer_id,
       customer_name,
       total_spending,
AVG(total_spending) OVER() AS average_total_spending
FROM CTE_Customer_Spending
)
SELECT customer_id,
customer_name,
total_spending
FROM CTE_Average_Customer_Spending
WHERE total_spending>average_total_spending;       

-- 25.Use a CTE to calculate revenue per product, then return products whose revenue is above the average product revenue
WITH CTE_revenue_per_product AS (
SELECT p.product_id,
       p.product_name,
COALESCE(SUM(o.quantity*p.price),0) AS total_revenue
FROM products p 
LEFT JOIN 
orders o 
ON p.product_id = o.product_id
GROUP BY p.product_id,
p.product_name
),
CTE_avg_product_revenue AS (
SELECT product_id,
product_name,
total_revenue,
AVG(total_revenue) OVER() AS average_product_revenue
FROM CTE_revenue_per_product
)
SELECT product_id,
product_name,
total_revenue,
average_product_revenue
FROM CTE_avg_product_revenue
WHERE total_revenue>average_product_revenue;       


-- Business Case Studies 
-- 26.Create a monthly summary containing order count, units sold, revenue, and average revenue per order line.
WITH CTE_monthly_kpi_report AS (
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS month,
COUNT(o.order_id) AS total_orders,
SUM(o.quantity) AS total_unit_sold,
SUM(o.quantity*p.price) AS total_revenue,
AVG(o.quantity*p.price) AS average_revenue_per_order_line
FROM orders o 
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
)

SELECT month,
total_orders,
total_unit_sold,
total_revenue,
average_revenue_per_order_line
FROM CTE_monthly_kpi_report;


-- 27.Show each customer's spending and percentage contribution to total revenue.
WITH CTE_revenue_contribution AS (
SELECT c.customer_id,
       c.customer_name,
SUM(o.quantity*p.price) AS total_spending
FROM customers c 
INNER JOIN 
orders o 
ON c.customer_id = o.customer_id
INNER JOIN 
products p 
ON o.product_id = p.product_id
GROUP BY c.customer_id,
         c.customer_name
)
SELECT customer_id,
customer_name,
total_spending,
ROUND(100.0*total_spending/SUM(total_spending) OVER(),2) AS revenue_contribution_percentage
FROM CTE_revenue_contribution
ORDER BY total_spending DESC;

-- 28.Compare categories by revenue and units sold, and identify the strongest category.
WITH CTE_category_performance AS (
SELECT p.category,
SUM(o.quantity*p.price) AS total_revenue,
SUM(o.quantity) AS total_units_sold
FROM products p 
INNER JOIN 
orders o 
ON p.product_id = o.product_id
GROUP BY p.category
),
CTE_ranked AS (
SELECT category,
total_revenue,
total_units_sold,
DENSE_RANK() OVER(ORDER BY total_revenue DESC) AS rn 
FROM CTE_category_performance
)
SELECT category,
total_revenue,
total_units_sold,
rn
FROM CTE_ranked
ORDER BY rn;

-- 29.Create a single result containing total revenue, total units sold, number of orders, number of customers who purchased,
-- and average revenue per order.
SELECT SUM(o.quantity*p.price) AS total_revenue,
SUM(o.quantity) AS total_units_sold,
COUNT(DISTINCT o.order_id) AS total_number_of_orders,
COUNT(DISTINCT c.customer_id) AS number_of_customer,
ROUND(SUM(o.quantity * p.price) / COUNT(DISTINCT o.order_id),2) AS average_revenue_per_order
FROM customers c 
INNER JOIN 
orders o 
ON c.customer_id = o.customer_id
INNER JOIN 
products p 
ON o.product_id = p.product_id;

--  30.Identify customers who have placed orders in at least 3 different months.

WITH CTE_Customer_Purchase_Analysis AS (
    SELECT
        c.customer_id,
        c.customer_name,
COUNT(DISTINCT o.order_id) AS total_orders,
COUNT(DISTINCT DATE_FORMAT(o.order_date, '%Y-%m')) AS distinct_purchase_months,
SUM(o.quantity * p.price) AS total_spending
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
INNER JOIN products p
ON o.product_id = p.product_id
GROUP BY
c.customer_id,
c.customer_name
)
SELECT
customer_id,
customer_name,
total_orders,
distinct_purchase_months,
total_spending
FROM CTE_Customer_Purchase_Analysis
WHERE distinct_purchase_months >= 3
ORDER BY total_spending DESC;