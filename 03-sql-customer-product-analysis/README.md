# SQL Customer & Product Analysis

## Business problem
Given three normalized tables — customers, products, orders — answer the
questions a business stakeholder would actually ask: How much are we making?
What sells? Who are our best customers? Are we keeping them? Where is growth
coming from?

## What I did
1. **Designed a clean relational schema**: `customers` (300) → `orders` (1,500)
   → `products` (25), with proper foreign keys.
2. **Wrote 10 business-driven SQL queries** (`sql/queries.sql`) — each starts
   from a question, not from the syntax. Covers aggregations, JOINs, GROUP BY,
   conditional aggregation, subqueries, and a window function.
3. **Ran every query** (SQLite) and published the real outputs in
   `sql/results.md` — no hand-written "expected" results.

## Key findings
- **$362,930.64** total revenue · **1,500** orders · **$241.95** average order value
- **Top product: Laptop Stand** — $56,313.40 revenue from just 110 units
  (high-ticket items punch above their weight)
- **Ontario leads every region**: $146,849.60 from 121 customers
- **96.6% of customers placed 2+ orders** — a strong repeat base, so retention
  marketing should outperform acquisition spend here
- **VIP customers** were deliberately modeled as Electronics-heavy buyers, and
  the segment query confirms they carry the highest AOV — the segmentation logic holds

## Sample query
```sql
-- Repeat purchase rate (customers with 2+ orders)
SELECT COUNT(*) AS total_customers,
       SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END) AS repeat_customers,
       ROUND(100.0 * SUM(CASE WHEN order_count >= 2 THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS repeat_rate_pct
FROM (SELECT customer_id, COUNT(*) AS order_count
      FROM orders GROUP BY customer_id);
```

## Tools
SQL (SQLite-compatible — runs in DB Browser, DBeaver, or any SQLite client)

## Repository structure
```
├── data/
│   ├── customers.csv   # 300 customers: region, segment, signup date
│   ├── products.csv    # 25 products: category, unit price
│   └── orders.csv      # 1,500 orders: customer, product, date, qty, total
└── sql/
    ├── queries.sql     # 10 business questions as SQL
    └── results.md      # real query outputs
```

## How to reproduce
```bash
sqlite3 analysis.db
.read schema_and_load.sql   -- (or import the CSVs in DB Browser for SQLite)
.read sql/queries.sql
```
Compare your outputs with `sql/results.md`.

## Note on data
The dataset is synthetic, generated to demonstrate SQL analysis on a realistic
relational schema. All query results are real outputs.

## What this demonstrates
Translating business questions into SQL · JOINs & aggregations · conditional
logic · subqueries · window functions (running totals) · documenting results.
