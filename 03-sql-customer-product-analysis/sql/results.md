# Query Results

_All results below are real outputs of running `sql/queries.sql` against the CSV data loaded into SQLite._

## Total revenue, orders and average order value

```sql
SELECT ROUND(SUM(line_total),2) AS total_revenue, COUNT(*) AS orders, ROUND(AVG(line_total),2) AS aov FROM orders;
```

| total_revenue | orders | aov |
| --- | --- | --- |
| 362930.64 | 1500 | 241.95 |

## Revenue by product category

```sql
SELECT p.category, ROUND(SUM(o.line_total),2) AS revenue FROM orders o JOIN products p ON o.product_id=p.product_id GROUP BY p.category ORDER BY revenue DESC;
```

| category | revenue |
| --- | --- |
| Electronics | 203272.63 |
| Sports | 80734.53 |
| Home & Kitchen | 44038.95 |
| Apparel | 20645.23 |
| Beauty | 14239.3 |

## Top 10 products by revenue

```sql
SELECT p.product_name, ROUND(SUM(o.line_total),2) AS revenue, SUM(o.quantity) AS units FROM orders o JOIN products p ON o.product_id=p.product_id GROUP BY p.product_name ORDER BY revenue DESC LIMIT 10;
```

| product_name | revenue | units |
| --- | --- | --- |
| Laptop Stand | 56313.4 | 110 |
| USB-C Charger | 51494.94 | 133 |
| Wireless Headphones | 47848.05 | 115 |
| Smart Watch | 26345.54 | 107 |
| Bluetooth Speaker | 21270.7 | 110 |
| Bicycle Helmet | 20132.48 | 83 |
| Tennis Racket | 19831.25 | 95 |
| Resistance Bands | 18144.63 | 83 |
| Yoga Mat | 18139.77 | 99 |
| Air Fryer | 13496.22 | 81 |

## Monthly revenue trend for 2025

```sql
SELECT substr(order_date,1,7) AS month, ROUND(SUM(line_total),2) AS revenue, COUNT(*) AS orders FROM orders WHERE order_date LIKE '2025%' GROUP BY month ORDER BY month;
```

| month | revenue | orders |
| --- | --- | --- |
| 2025-01 | 17848.99 | 81 |
| 2025-02 | 12493.28 | 54 |
| 2025-03 | 16579.27 | 76 |
| 2025-04 | 22756.07 | 79 |
| 2025-05 | 10286.42 | 57 |
| 2025-06 | 11364.89 | 62 |
| 2025-07 | 22429.48 | 77 |
| 2025-08 | 18289.61 | 81 |
| 2025-09 | 16994.33 | 71 |

## Top 10 customers by lifetime spend

```sql
SELECT c.customer_name, c.segment, ROUND(SUM(o.line_total),2) AS lifetime_spend, COUNT(*) AS orders FROM orders o JOIN customers c ON o.customer_id=c.customer_id GROUP BY c.customer_id ORDER BY lifetime_spend DESC LIMIT 10;
```

| customer_name | segment | lifetime_spend | orders |
| --- | --- | --- | --- |
| Meera Kim | VIP | 4936.88 | 10 |
| Riya Tremblay | VIP | 4232.23 | 9 |
| Riya Kim | Returning | 4115.25 | 9 |
| Karan Nair | VIP | 3879.32 | 8 |
| Aditya Nair | Returning | 3790.17 | 3 |
| Pooja Chen | New | 3449.34 | 8 |
| Olivia Brown | New | 3291.93 | 10 |
| Ananya Iyer | New | 3194.17 | 8 |
| Divya Iyer | VIP | 3152.67 | 7 |
| Aarav Smith | VIP | 3049.48 | 6 |

## Average order value by customer segment

```sql
SELECT c.segment, COUNT(*) AS orders, ROUND(AVG(o.line_total),2) AS aov, ROUND(SUM(o.line_total),2) AS revenue FROM orders o JOIN customers c ON o.customer_id=c.customer_id GROUP BY c.segment ORDER BY revenue DESC;
```

| segment | orders | aov | revenue |
| --- | --- | --- | --- |
| New | 804 | 217.32 | 174723.12 |
| Returning | 486 | 227.46 | 110544.29 |
| VIP | 210 | 369.82 | 77663.23 |

## Repeat purchase rate (customers with 2+ orders)

```sql
SELECT COUNT(*) AS total_customers, SUM(CASE WHEN order_count>=2 THEN 1 ELSE 0 END) AS repeat_customers, ROUND(100.0*SUM(CASE WHEN order_count>=2 THEN 1 ELSE 0 END)/COUNT(*),1) AS repeat_rate_pct FROM (SELECT customer_id, COUNT(*) AS order_count FROM orders GROUP BY customer_id);
```

| total_customers | repeat_customers | repeat_rate_pct |
| --- | --- | --- |
| 298 | 288 | 96.6 |

## Revenue by region

```sql
SELECT c.region, ROUND(SUM(o.line_total),2) AS revenue, COUNT(DISTINCT o.customer_id) AS customers FROM orders o JOIN customers c ON o.customer_id=c.customer_id GROUP BY c.region ORDER BY revenue DESC;
```

| region | revenue | customers |
| --- | --- | --- |
| Ontario | 146849.6 | 121 |
| Quebec | 83280.0 | 68 |
| Alberta | 53068.53 | 42 |
| British Columbia | 43608.87 | 41 |
| Manitoba | 36123.64 | 26 |

## Customers with no orders in the last 90 days (churn watch)

```sql
SELECT COUNT(*) AS at_risk_customers FROM customers WHERE customer_id NOT IN (SELECT customer_id FROM orders WHERE order_date >= date((SELECT MAX(order_date) FROM orders), '-90 days'));
```

| at_risk_customers |
| --- |
| 142 |

## Running monthly revenue total (window function)

```sql
SELECT month, revenue, ROUND(SUM(revenue) OVER (ORDER BY month),2) AS running_total FROM (SELECT substr(order_date,1,7) AS month, ROUND(SUM(line_total),2) AS revenue FROM orders GROUP BY month) ORDER BY month;
```

| month | revenue | running_total |
| --- | --- | --- |
| 2024-01 | 20727.36 | 20727.36 |
| 2024-02 | 17739.03 | 38466.39 |
| 2024-03 | 16763.92 | 55230.31 |
| 2024-04 | 14407.6 | 69637.91 |
| 2024-05 | 19159.11 | 88797.02 |
| 2024-06 | 13139.54 | 101936.56 |
| 2024-07 | 17532.59 | 119469.15 |
| 2024-08 | 26422.72 | 145891.87 |
| 2024-09 | 16667.83 | 162559.7 |
| 2024-10 | 18043.9 | 180603.6 |
| 2024-11 | 16336.27 | 196939.87 |
| 2024-12 | 16948.43 | 213888.3 |
| 2025-01 | 17848.99 | 231737.29 |
| 2025-02 | 12493.28 | 244230.57 |
| 2025-03 | 16579.27 | 260809.84 |

_... 6 more rows_
