# Inventory & Stock Analytics

## Business problem
A retailer stocks ~150 SKUs across three distribution centres (Toronto, Montreal,
Vancouver). Two expensive mistakes hide in the data: **stockouts** (lost sales)
and **overstock** (cash trapped on shelves). This project flags both, quantifies
them in dollars, and produces the weekly reorder report a supply-chain analyst
would actually send.

## What I did
1. **Built the inventory snapshot** (`data/inventory.csv`) — 297 SKU × warehouse
   rows with stock on hand, reorder point, lead time, average daily demand, and
   unit cost.
2. **Computed days-of-cover** per row and applied flagging rules:
   - `REORDER` — stock at or below reorder point
   - `STOCKOUT RISK` — cover below supplier lead time
   - `OVERSTOCK` — more than 90 days of cover
   - `OK` — everything else
3. **Quantified the money**: capital tied up in overstock, investment needed to
   refill reorder items.
4. **Wrote the SQL reorder report** (`sql/reorder_report.sql`) so the flags can
   be regenerated weekly straight from the warehouse system.

## Key findings
| Status | SKU × warehouse rows |
|---|---|
| OK | 188 |
| **REORDER** | **70** |
| **OVERSTOCK** | **39** |

- **$648,227.32 of capital is trapped in overstock** across 39 rows — the first
  place to look for cash.
- **$121,816.13** is needed to bring the 70 reorder-flagged rows back to a
  healthy level (2× reorder point).
- The most urgent rows have under 2 days of cover against 5–14 day lead times —
  those stock out before the next delivery even if ordered today (see
  `data/findings.json` for the top-10 list).

## Recommendation
Run the reorder report weekly (not monthly): fund the $121.8K refill from
markdowns on the overstocked SKUs, and set a rule that any SKU with cover below
lead time gets expedited — the current cycle is too slow to catch them.

## Tools
Excel (flagging logic, pivot summaries), SQL (weekly reorder report)

## Repository structure
```
├── data/
│   ├── inventory.csv              # raw snapshot: 297 rows
│   ├── inventory_with_flags.csv   # + days_of_cover and status flags
│   └── findings.json              # status counts, dollar figures, top-10 urgent
└── sql/
    └── reorder_report.sql         # weekly report queries
```

## How to reproduce
- **Excel**: open `data/inventory.csv`, add column
  `days_of_cover = stock_on_hand / avg_daily_demand`, then flag with nested IFs
  per the rules above — cross-check against `inventory_with_flags.csv`.
- **SQL**: load the CSV into SQLite and run `sql/reorder_report.sql`.

## Note on data
The dataset is synthetic, generated to demonstrate inventory analytics. All
flags, counts, and dollar figures are real computations on that data.

## What this demonstrates
Operational analytics · days-of-cover & reorder-point logic · quantifying
findings in dollars · SQL reporting — the kind of analysis behind retail
operations and master-data roles.
