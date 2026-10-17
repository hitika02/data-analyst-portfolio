# E-commerce Sales Performance Dashboard (Power BI)

## Business problem
An online retailer needed one trustworthy view of sales performance: How much
are we selling? Which categories and regions drive it? Which channel converts
best? Is growth real or seasonal noise? This project builds that view from
2,000 orders across 21 months.

## What I did
1. **Prepared the dataset** (`data/ecommerce_orders.csv`) — 2,000 orders,
   Jan 2024 – Sep 2025, with order date, customer, product, category, quantity,
   price, region, and channel.
2. **Designed the Power BI data model** — single clean fact table
   (`ecommerce_orders`), a proper date table, and documented DAX measures
   (see `powerbi-guide/BUILD_GUIDE.md`).
3. **Built a one-page executive dashboard**: KPI cards → trend → breakdowns,
   with slicers for year, category, region, and channel.
4. **Wrote up the insights** the dashboard surfaces (below) — every number was
   computed from the data, not estimated.

## Key findings
- **$566,320.52** total revenue · **2,000** orders · **$283.16** average order value · **871** customers
- **Electronics is 58% of revenue** ($329,999.65) — the business is concentrated;
  Beauty contributes just 3% ($18,100.88) and deserves a growth plan or a rethink.
- **Ontario drives 46% of revenue** ($259,661.26); Manitoba is only 7%.
- **Website (46%) and Mobile App (37%)** together are 83% of revenue —
  In-Store Pickup is a fulfillment option, not a sales engine.
- **November 2024 was the peak month** ($34,915.43) — holiday seasonality is real
  and should drive inventory planning.
- Recent momentum is choppy: Jul +49.1% → Aug −20.5% → Sep +14.2% month-over-month,
  worth investigating rather than celebrating the September bounce alone.

## Recommendation
Protect Electronics supply and promos into Q4 (it funds the business), and run a
targeted experiment to lift Beauty — e.g. bundling with best-selling Electronics
accessories — before deciding whether the category earns its shelf space.

## Tools
Power BI (data modeling, DAX, visualization), Excel (data prep checks)

## Repository structure
```
├── data/
│   ├── ecommerce_orders.csv   # 2,000 orders, Jan 2024 – Sep 2025
│   └── findings.json          # KPI numbers backing this README
└── powerbi-guide/
    └── BUILD_GUIDE.md         # step-by-step: model, DAX measures, visuals
```

## How to reproduce
1. Open Power BI Desktop → Get Data → Text/CSV → `data/ecommerce_orders.csv`
2. Follow `powerbi-guide/BUILD_GUIDE.md` (measures + visual layout, ~1 hour)
3. Verify your KPI cards match the numbers in `data/findings.json`

## Note on data
The dataset is synthetic, generated to demonstrate a realistic dashboard build.
All KPIs and findings are real computations on that data.

## What this demonstrates
KPI design · Power BI data modeling & DAX · dashboard storytelling for
non-technical stakeholders · turning analysis into a recommendation.
