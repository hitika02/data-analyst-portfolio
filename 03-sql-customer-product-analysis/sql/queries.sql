-- =============================================================
-- Customer & Product Analysis — 10 business questions in SQL
-- Schema: customers(customer_id, customer_name, region, segment, signup_date)
--         products(product_id, product_name, category, unit_price)
--         orders(order_id, customer_id, product_id, order_date, quantity, line_total)
-- Real outputs for every query: see results.md
-- =============================================================

-- Q1. How much revenue have we made overall?
SELECT ROUND(SUM(line_total),2) AS total_revenue,
       COUNT(*) AS orders,
       ROUND(AVG(line_total),2) AS aov
FROM orders;

-- Q2. Which product categories bring in the most revenue?
SELECT p.category,
       ROUND(SUM(o.line_total),2) AS revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Q3. What are our top 10 products by revenue?
SELECT p.product_name,
       ROUND(SUM(o.line_total),2) AS revenue,
       SUM(o.quantity) AS units
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;

-- Q4. What does the 2025 monthly revenue trend look like?
SELECT substr(order_date,1,7) AS month,
       ROUND(SUM(line_total),2) AS revenue,
       COUNT(*) AS orders
FROM orders
WHERE order_date LIKE '2025%'
GROUP BY month
ORDER BY month;

-- Q5. Who are our top 10 customers by lifetime spend?
SELECT c.customer_name, c.segment,
       ROUND(SUM(o.line_total),2) AS lifetime_spend,
       COUNT(*) AS orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY lifetime_spend DESC
LIMIT 10;

-- Q6. Which customer segment is most valuable?
SELECT c.segment,
       COUNT(*) AS orders,
       ROUND(AVG(o.line_total),2) AS aov,
       ROUND(SUM(o.line_total),2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY revenue DESC;

-- Q7. What share of customers buy more than once? (repeat purchase rate)
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS repeat_rate_pct
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders
      GROUP BY customer_id);

-- Q8. Which regions drive revenue?
SELECT c.region,
       ROUND(SUM(o.line_total),2) AS revenue,
       COUNT(DISTINCT o.customer_id) AS customers
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY revenue DESC;

-- Q9. Which customers haven't ordered in 90 days? (churn watch list input)
SELECT COUNT(*) AS at_risk_customers
FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id FROM orders
    WHERE order_date >= date((SELECT MAX(order_date) FROM orders), '-90 days')
);

-- Q10. What is the running total of monthly revenue? (window function)
SELECT month, revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM (SELECT substr(order_date,1,7) AS month,
             ROUND(SUM(line_total),2) AS revenue
      FROM orders
      GROUP BY month)
ORDER BY month;
