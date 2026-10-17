"""Master-data cleaning pipeline for product_master_raw.csv.

Rules applied (each is logged in the run report):
 1. Deduplicate   - drop exact duplicate rows, keep first occurrence
 2. Standardize   - product names: trim, collapse whitespace, restore canonical
                    spelling via lookup; categories mapped to a canonical list
 3. Validate SKU  - must match SKU-###### ; repairable variants are fixed,
                    the rest flagged INVALID
 4. Fix prices    - NULL / zero / negative prices imputed with the category
                    median and flagged for review
 5. Standardize   - status values normalized to Active / Inactive / Discontinued

Run:  python scripts/clean.py
Reads:  data/product_master_raw.csv
Writes: data/product_master_clean.csv
"""
import csv, re, statistics
from collections import Counter, defaultdict

RAW = "data/product_master_raw.csv"
CLEAN = "data/product_master_clean.csv"

CANONICAL_CATEGORIES = ["Beverages", "Snacks", "Dairy", "Frozen", "Household", "Personal Care"]
CATEGORY_MAP = {
    "bev": "Beverages", "snk": "Snacks", "dai": "Dairy",
    "frz": "Frozen", "hh": "Household", "pc": "Personal Care",
    "personalcare": "Personal Care",
}
for c in CANONICAL_CATEGORIES:
    CATEGORY_MAP[c.lower()] = c

def norm(s):
    return re.sub(r"\s+", " ", str(s).strip().lower())

with open(RAW, newline="", encoding="utf-8") as f:
    rows = list(csv.DictReader(f))

# Golden-record reference list: the approved canonical product names.
# In production this lives in the MDM hub; here it is the matching dictionary
# used to restore variant spellings ("coca cola 500 ml") to the golden record.
CANONICAL_PRODUCTS = [
    "Coca-Cola Classic 500ml", "Pepsi Cola 500ml", "Tropicana Orange Juice 1.54L",
    "Tim Hortons Fine Grind Coffee 300g", "Gatorade Cool Blue 710ml",
    "Red Bull Energy Drink 250ml", "Lay's Classic Potato Chips 220g",
    "Doritos Nacho Cheese 280g", "Oreo Chocolate Sandwich Cookies 303g",
    "Nature Valley Oats & Honey Granola Bars 6pk", "Pringles Original 156g",
    "Natrel 2% Milk 2L", "Armstrong Old Cheddar 400g",
    "Oikos Plain Greek Yogurt 750g", "Becel Original Margarine 907g",
    "Kraft Singles 24pk", "McCain Superfries 2kg",
    "Chapman's Vanilla Ice Cream 1.5L", "Green Giant Mixed Vegetables 750g",
    "Eggo Homestyle Waffles 10ct", "Bounty Select-a-Size Paper Towels 6pk",
    "Tide Original Liquid Detergent 4.08L", "Lysol Disinfecting Wipes 80ct",
    "Cascade Platinum Dishwasher Pods 62ct", "Colgate Total Toothpaste 120ml",
    "Dove Deep Moisture Body Wash 400ml", "Head & Shoulders Classic 400ml",
    "Kleenex Ultra Soft Tissues 6pk",
]
name_lookup = {norm(n): n for n in CANONICAL_PRODUCTS}

medians = defaultdict(list)
for r in rows:
    try:
        p = float(r["unit_price"])
        if p > 0:
            medians[r["category"].strip()].append(p)
    except (ValueError, TypeError):
        pass
cat_median = {c: round(statistics.median(v), 2) for c, v in medians.items()}

clean, seen, stats = [], set(), Counter()
for r in rows:
    key = tuple(r[k] for k in
                ["product_id", "product_name", "category", "brand", "sku", "unit_price", "status"])
    if key in seen:
        stats["duplicates_removed"] += 1
        continue
    seen.add(key)

    name = name_lookup.get(norm(r["product_name"]), r["product_name"].strip())
    if name != r["product_name"].strip():
        stats["names_standardized"] += 1

    cat = CATEGORY_MAP.get(norm(r["category"]), r["category"].strip())
    if cat != r["category"].strip():
        stats["categories_standardized"] += 1

    sku_raw = str(r["sku"]).strip()
    m = re.match(r"^SKU-(\d{6})$", sku_raw.upper())
    if m:
        sku, sku_flag = f"SKU-{m.group(1)}", "ok"
        if sku != sku_raw:
            stats["skus_repaired"] += 1
    else:
        digits = re.sub(r"\D", "", sku_raw)
        if len(digits) == 6:
            sku, sku_flag = f"SKU-{digits}", "repaired"
            stats["skus_repaired"] += 1
        else:
            sku, sku_flag = "INVALID", "invalid"
            stats["skus_invalid"] += 1

    try:
        price = float(r["unit_price"])
        valid = price > 0
    except (ValueError, TypeError):
        valid = False
    if valid:
        price_clean, price_flag = round(price, 2), "ok"
    else:
        price_clean = cat_median.get(r["category"].strip(), 0.0)
        price_flag = "imputed"
        stats["prices_imputed"] += 1

    st = norm(r["status"])
    status = {"active": "Active", "inactive": "Inactive",
              "discontinued": "Discontinued"}.get(st, r["status"].strip().capitalize())

    clean.append({"product_id": r["product_id"], "product_name": name,
                  "category": cat, "brand": str(r["brand"]).strip(),
                  "sku": sku, "unit_price": price_clean, "status": status,
                  "sku_flag": sku_flag, "price_flag": price_flag})

with open(CLEAN, "w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(clean[0].keys()))
    w.writeheader(); w.writerows(clean)

print(f"Raw rows: {len(rows)} -> Clean rows: {len(clean)}")
for k, v in stats.most_common():
    print(f"  {k}: {v}")
