# Marketing Campaign Performance Analysis (Excel)

## Business problem
Four marketing channels (Email, Social, Search, Display) ran monthly campaigns
for 21 months. Total spend: **$201,376.17**. Which channels actually earn their
budget? Where should the next dollar go? This project builds the channel
scorecard and the reallocation recommendation — the exact analysis behind a
media performance dashboard.

## What I did
1. **Built the campaign dataset** (`data/campaigns.csv`) — 84 campaigns with
   spend, impressions, clicks, conversions, and revenue (at a documented
   $120 average order value).
2. **Computed funnel metrics per campaign**: CTR, CPC, CPA, ROAS.
3. **Aggregated to a channel scorecard** and ranked channels by efficiency.
4. **Wrote the budget recommendation** with the numbers to back it.

## Key findings
| Channel | Spend | Revenue | ROAS | CPA | CTR |
|---|---|---|---|---|---|
| **Email** | $27,911 | $285,360 | **10.22** | $11.74 | 2.79% |
| **Search** | $75,852 | $703,440 | **9.27** | $12.94 | 3.60% |
| Display | $40,317 | $190,920 | 4.74 | $25.34 | 0.73% |
| Social | $57,296 | $204,720 | 3.57 | $33.59 | 1.16% |
| **Blended** | **$201,376** | **$1,384,440** | **6.87** | — | — |

- **Email is the efficiency king** (10.22x ROAS, $11.74 CPA) but gets the
  smallest budget — classic underinvestment in the best channel.
- **Search drives the most absolute revenue** ($703,440) at strong efficiency —
  the workhorse.
- **Social is the problem child**: highest CPA ($33.59), lowest ROAS (3.57x),
  nearly 3x the CPA of Email.
- Display has reach (highest impressions) but weak conversion — a branding
  channel being judged (and funded) like a performance channel.

## Recommendation
Shift ~20% of Social's budget into Email and Search for one quarter and measure
incremental ROAS. Cap Display at a fixed brand-awareness budget with separate
KPIs instead of letting it compete with performance channels on ROAS.

## Tools
Excel (pivot tables, calculated fields — the whole analysis rebuilds in ~30 min),
CSV data

## Repository structure
```
└── data/
    ├── campaigns.csv    # 84 campaigns, 2024-01 to 2025-09
    └── findings.json    # channel scorecard numbers
```

## How to reproduce (Excel)
1. Open `data/campaigns.csv` → Insert → PivotTable
2. Rows: `channel` · Values: Sum of `spend`, Sum of `revenue`, Sum of `clicks`,
   Sum of `impressions`, Sum of `conversions`
3. Add calculated fields: `ROAS = revenue/spend`, `CPA = spend/conversions`,
   `CTR = clicks/impressions`
4. Sort by ROAS descending — your table should match the one above

## Note on data & assumptions
Dataset is synthetic. Revenue assumes a **$120 average order value**, documented
in `data/findings.json` — change the assumption and the ROAS figures update
transparently.

## What this demonstrates
Marketing funnel metrics (CTR/CPC/CPA/ROAS) · channel comparison · Excel pivot
analysis · budget reallocation reasoning — directly relevant to media/analytics
roles.
