# Power BI Build Guide — E-commerce Sales Dashboard

Estimated build time: ~1 hour in Power BI Desktop (free).

## 1. Load the data
- **Get Data → Text/CSV** → `data/ecommerce_orders.csv`
- In Power Query: set `order_date` to **Date** type, `quantity` to Whole Number,
  `unit_price` / `line_total` to Decimal. Remove no rows — the file is clean.

## 2. Add a date table (for time intelligence)
- **Modeling → New Table**:
```dax
DateTable = CALENDAR(DATE(2024,1,1), DATE(2025,12,31))
```
- Add columns: `Year = YEAR(DateTable[Date])`, `Month = FORMAT(DateTable[Date],"yyyy-mm")`,
  `MonthName = FORMAT(DateTable[Date],"mmm yyyy")`
- Create a relationship: `DateTable[Date]` → `ecommerce_orders[order_date]` (single direction).

## 3. DAX measures
```dax
Total Revenue = SUM(ecommerce_orders[line_total])

Total Orders = COUNTROWS(ecommerce_orders)

Avg Order Value = DIVIDE([Total Revenue], [Total Orders])

Unique Customers = DISTINCTCOUNT(ecommerce_orders[customer_id])

Revenue LY (same months last year) =
    CALCULATE([Total Revenue], SAMEPERIODLASTYEAR(DateTable[Date]))

YoY Growth % =
    DIVIDE([Total Revenue] - [Revenue LY], [Revenue LY])

Revenue YTD = TOTALYTD([Total Revenue], DateTable[Date])

Electronics Share % =
    DIVIDE(
        CALCULATE([Total Revenue], ecommerce_orders[category] = "Electronics"),
        [Total Revenue]
    )
```

## 4. Page layout (one page, top → bottom)
1. **KPI cards (top row):** Total Revenue · Total Orders · Avg Order Value · Unique Customers
2. **Line chart:** Revenue by Month (`DateTable[Month]`), add [Revenue LY] as a second line for YoY context
3. **Bar chart:** Revenue by Category (sorted descending — Electronics will dominate)
4. **Donut chart:** Revenue by Channel
5. **Table or filled map:** Revenue by Region
6. **Slicers (top):** Year · Category · Region · Channel

## 5. Formatting checklist
- Currency: $ en-CA, 0 decimals on cards, 2 on tables
- Title each visual as a takeaway, not a label: e.g. "Electronics drives 58% of revenue"
  instead of "Revenue by Category"
- Add one **text box** with the 3 key insights + 1 recommendation from the README —
  a dashboard without a written takeaway is just decoration

## 6. Verify
Your KPI cards should read: **$566,320.52 · 2,000 orders · $283.16 AOV · 871 customers**.
If they match `data/findings.json`, the model is correct.
