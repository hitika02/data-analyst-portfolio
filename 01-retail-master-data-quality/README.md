# Retail Master Data Quality Audit & Cleansing

## Business problem
A retail product master file with **540 records** had inconsistent product names
("Coca-Cola Classic 500ml" vs "coca-cola classic 500ml"), 32 different spellings
of just 6 categories, invalid SKUs, and missing/negative prices. Dirty master
data like this breaks reporting, causes duplicate listings, and produces wrong
prices at checkout. The goal: profile the data, apply documented cleaning rules,
and release a validated file with a full audit trail.

## What I did
1. **Profiled the raw data** (`data/product_master_raw.csv`) — counted duplicates,
   nulls, invalid formats, and out-of-domain values before touching anything.
2. **Built a repeatable cleaning pipeline** (`scripts/clean.py`, pure Python):
   - Deduplicated exact duplicate rows (kept first occurrence)
   - Standardized product names against a golden-record reference list
   - Mapped 32 raw category spellings → 6 canonical categories
   - Validated SKUs against the `SKU-######` pattern; repaired fixable ones,
     quarantined the rest as `INVALID` instead of silently dropping them
   - Imputed NULL/zero/negative prices with the category median and flagged them
3. **Validated the output** with `sql/validation.sql` — 7 checks (duplicates,
   nulls, SKU format, price sanity, category domain, quarantine review,
   row-count reconciliation).

## Key findings (real outputs of the pipeline)
| Metric | Before | After |
|---|---|---|
| Total rows | 540 | 500 (40 exact duplicates removed) |
| Distinct category values | 32 spellings | 6 canonical |
| Product names standardized | — | 125 |
| Categories standardized | — | 101 |
| Invalid SKU formats | 45 | 24 quarantined, 20 repaired |
| Missing/zero/negative prices | 47 | 47 imputed with category median, flagged |

Every cleaned row carries `sku_flag` and `price_flag` columns, so a data steward
can see exactly which values were repaired, imputed, or quarantined — no silent fixes.

## Tools
Python (pandas-style cleaning with the csv module), SQL (validation checks), Excel (spot-checks)

## Repository structure
```
├── data/
│   ├── product_master_raw.csv      # raw file, as received
│   ├── product_master_clean.csv    # cleaned file + audit flags
│   └── findings.json               # profiling numbers
├── scripts/
│   └── clean.py                    # repeatable cleaning pipeline
└── sql/
    └── validation.sql              # 7 post-cleaning validation checks
```

## How to reproduce
```bash
python scripts/clean.py
# Raw rows: 540 -> Clean rows: 500  (plus a per-rule report)
```

## Note on data
The dataset is synthetic, generated to demonstrate a realistic master-data
quality workflow. The profiling numbers, cleaning rules, and validation checks
are real and reproducible.

## What this demonstrates
Data profiling · data cleansing & standardization · validation rule design ·
audit-trail thinking · SQL data-quality checks — the core of Master Data /
Data Quality analyst work.
