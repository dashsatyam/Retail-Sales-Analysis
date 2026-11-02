# Retail Sales Analysis | MySQL Portfolio Project

**Presented by:** Satyam Dash  
**Database:** MySQL (`retail_sales`)  
**SQL environment:** MySQL Workbench  
**Project level:** Beginner to Advanced

## Project Overview

Retail Sales Analysis is a business-focused SQL portfolio project. It uses three related tables — `customers`, `products`, and `orders` — to explore retail transactions, calculate sales metrics, and answer practical business questions.

The project contains 30 SQL questions, progressing from basic data validation to advanced analysis and management-level KPIs. The SQL queries and their corresponding MySQL Workbench output screenshots are presented in the accompanying PowerPoint.

## Project Objectives

- Validate the structure and quality of retail data.
- Calculate total revenue and units sold.
- Analyse monthly and category-wise sales performance.
- Identify high-spending customers and high-performing products.
- Examine customer purchasing behaviour.
- Prepare business KPIs and management summaries.

## Database Schema

| Table | Main columns | Purpose |
|---|---|---|
| `customers` | `customer_id`, `customer_name`, `city`, `state` | Customer details |
| `products` | `product_id`, `product_name`, `category`, `price` | Product catalogue and prices |
| `orders` | `order_id`, `customer_id`, `product_id`, `order_date`, `quantity` | Customer purchase records |

### Table relationships

- `customers.customer_id` identifies each customer.
- `products.product_id` identifies each product.
- `orders.customer_id` links an order to a customer.
- `orders.product_id` links an order to a product.

## Revenue Calculation

Revenue per order line is calculated as:

```sql
orders.quantity * products.price
```

The `orders` table is joined to `products` using `product_id`. It is joined to `customers` using `customer_id`.

## Project Sections

| Level | Focus | Questions |
|---|---|---:|
| 1 | Data Validation & SQL Basics | 1–5 |
| 2 | Sales Analysis | 6–12 |
| 3 | Customer & Product Analysis | 13–18 |
| 4 | Advanced SQL | 19–25 |
| 5 | Business Case Studies | 26–30 |

## SQL Concepts Practised

- `SELECT`, `WHERE`, `ORDER BY`
- Aggregate functions: `SUM()`, `AVG()`, `COUNT()`
- `GROUP BY` and `HAVING`
- `INNER JOIN` and `LEFT JOIN`
- NULL handling and `COALESCE()`
- Subqueries and Common Table Expressions (CTEs)
- Window functions and ranking
- Running totals and cumulative revenue
- Month-over-month revenue comparison
- Revenue contribution percentages
- Date-based analysis and KPI calculations


## How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Open the SQL script in MySQL Workbench.
3. Create or select the `retail_sales` database.
4. Create the `customers`, `products`, and `orders` tables.
5. Import the corresponding CSV datasets.
6. Run the data-validation queries.
7. Execute the analysis queries and review the results.


## Results and Business Insights

The project includes MySQL Workbench result screenshots for the 30 query tasks in the presentation. Examples of reported results include:

- Total revenue: **81,876.00**
- Total units sold: **124**
- Number of orders: **50**
- Number of customers who purchased: **15**
- Average revenue per order: **1,637.52**
- Highest-revenue category shown: **Electronics**
- Highest-revenue product shown: **Bluetooth Speaker**

These values reflect the outputs supplied for this project. They should be interpreted using the definitions and date coverage of the underlying dataset.

## Learning Outcomes

By completing this project, I practised:

- Translating business questions into SQL queries.
- Joining related tables to analyse transactions.
- Summarising data using aggregate functions.
- Applying CTEs and window functions.
- Checking data quality and handling customers or products with no matching transactions.
- Presenting query results in a business-focused format.

## Author

**Satyam Dash**  
B.Tech — Computer Science and Engineering  
Aspiring Data Analyst | MIS Executive

---

*This project was created for SQL practice, portfolio development, and demonstrating business-oriented data analysis skills.*
