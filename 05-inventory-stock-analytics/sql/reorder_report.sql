-- =============================================================
-- Weekly Inventory Reorder Report
-- Run against the current inventory snapshot. Produces the three
-- lists a supply-chain analyst needs every Monday morning.
-- =============================================================

-- 1. URGENT REORDERS: at/below reorder point, worst cover first
SELECT sku, product_name, warehouse,
       stock_on_hand, reorder_point, lead_time_days,
       ROUND(1.0 * stock_on_hand / avg_daily_demand, 1) AS days_of_cover,
       ROUND((reorder_point * 2 - stock_on_hand) * unit_cost, 2) AS refill_cost
FROM inventory
WHERE stock_on_hand <= reorder_point
ORDER BY days_of_cover ASC;

-- 2. STOCKOUT RISK: cover is shorter than the supplier lead time
--    (these stock out even if reordered today)
SELECT sku, product_name, warehouse,
       stock_on_hand, lead_time_days,
       ROUND(1.0 * stock_on_hand / avg_daily_demand, 1) AS days_of_cover
FROM inventory
WHERE stock_on_hand > reorder_point
  AND (1.0 * stock_on_hand / avg_daily_demand) < lead_time_days
ORDER BY days_of_cover ASC;

-- 3. OVERSTOCK: capital trapped on shelves (> 90 days of cover)
SELECT sku, product_name, warehouse,
       stock_on_hand,
       ROUND(1.0 * stock_on_hand / avg_daily_demand, 1) AS days_of_cover,
       ROUND(stock_on_hand * unit_cost, 2) AS capital_tied_up
FROM inventory
WHERE (1.0 * stock_on_hand / avg_daily_demand) > 90
ORDER BY capital_tied_up DESC;

-- 4. SUMMARY: status counts + dollar exposure in one row
SELECT
  SUM(CASE WHEN stock_on_hand <= reorder_point THEN 1 ELSE 0 END) AS reorder_rows,
  SUM(CASE WHEN (1.0*stock_on_hand/avg_daily_demand) > 90 THEN 1 ELSE 0 END) AS overstock_rows,
  ROUND(SUM(CASE WHEN (1.0*stock_on_hand/avg_daily_demand) > 90
            THEN stock_on_hand * unit_cost ELSE 0 END), 2) AS overstock_capital,
  ROUND(SUM(CASE WHEN stock_on_hand <= reorder_point
            THEN (reorder_point * 2 - stock_on_hand) * unit_cost ELSE 0 END), 2)
            AS reorder_investment_needed
FROM inventory;
