-- Post-cleaning validation checks for product_master_clean.csv
-- Run these after clean.py. Every check should return 0 rows (or the
-- expected domain) before the data is released to downstream users.
-- SQLite / DuckDB / any ANSI-compatible engine.

-- 1. Duplicate check: no two rows should share all business attributes
SELECT product_name, category, brand, sku, unit_price, status, COUNT(*) AS n
FROM product_master_clean
GROUP BY product_name, category, brand, sku, unit_price, status
HAVING COUNT(*) > 1;

-- 2. Null check: business-critical columns must be populated
SELECT
  SUM(CASE WHEN product_name IS NULL OR product_name = '' THEN 1 ELSE 0 END) AS null_names,
  SUM(CASE WHEN category     IS NULL OR category     = '' THEN 1 ELSE 0 END) AS null_categories,
  SUM(CASE WHEN sku          IS NULL OR sku          = '' THEN 1 ELSE 0 END) AS null_skus,
  SUM(CASE WHEN unit_price   IS NULL THEN 1 ELSE 0 END)                      AS null_prices
FROM product_master_clean;

-- 3. SKU format check: must match SKU-###### (INVALID rows are quarantined, not released)
SELECT product_id, sku
FROM product_master_clean
WHERE sku NOT GLOB 'SKU-[0-9][0-9][0-9][0-9][0-9][0-9]'
  AND sku <> 'INVALID';

-- 4. Price sanity: no zero or negative prices in the released file
SELECT product_id, product_name, unit_price
FROM product_master_clean
WHERE unit_price <= 0;

-- 5. Category domain check: only canonical values allowed
SELECT DISTINCT category
FROM product_master_clean
WHERE category NOT IN
  ('Beverages','Snacks','Dairy','Frozen','Household','Personal Care');

-- 6. Quarantine review: rows needing a data steward's eyes
SELECT product_id, product_name, sku, sku_flag, unit_price, price_flag
FROM product_master_clean
WHERE sku_flag = 'invalid' OR price_flag = 'imputed';

-- 7. Reconciliation: clean row count + quarantine count = raw row count
SELECT
  (SELECT COUNT(*) FROM product_master_clean)                       AS clean_rows,
  (SELECT COUNT(*) FROM product_master_clean WHERE sku_flag='invalid') AS quarantined_skus;
