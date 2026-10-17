# How to Post These Projects on GitHub

## Step 1 — Create a GitHub account (if you don't have one)
Go to github.com and sign up. Use a professional username
(e.g. `hitika-gupta` or `hitika-data`).

## Step 2 — Push as 5 separate repos (recommended)
For EACH project folder (e.g. `01-retail-master-data-quality`):

```bash
cd 01-retail-master-data-quality
git init
git add .
git commit -m "Retail master data quality audit: profiling, cleaning pipeline, SQL validation"
# create the repo on github.com (same name), then:
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/01-retail-master-data-quality.git
git push -u origin main
```

Repeat for the other four folders.

## Step 3 — Polish each repo page (5 minutes each, big payoff)
On each repo's GitHub page:
1. Click **About → ⚙️** (top right) and paste the first 1–2 lines of the README
   as the description. Add topics: `data-analysis`, `sql`, `excel`, `power-bi`, `python`.
2. For project 2 (Power BI): once you build the dashboard following
   `powerbi-guide/BUILD_GUIDE.md`, take a screenshot and add it to the README —
   repos with visuals get far more recruiter attention.
3. Pin your best 3 repos to your GitHub profile (Profile → Customize pins).

## Step 4 — Link from your resume & LinkedIn
- **Resume header:** add `github.com/YOUR-USERNAME`
- **Resume Projects section** (2 lines per project max), e.g.:
  > Retail Master Data Quality Audit | Python, SQL — Profiled 540-row product
  > master file, built repeatable cleaning pipeline (dedupe, standardization,
  > SKU validation), cut 32 category spellings to 6. github.com/…
- **LinkedIn:** add the GitHub link to your profile's Featured section, and
  mention 1 project in your About section.

## Before you post — do this
1. **Read each README fully.** You must be able to explain any project in an
   interview in 2 minutes: the business question, what you did, one finding.
2. **Run one thing yourself** (e.g. `python scripts/clean.py` in project 1, or
   a query from `sql/queries.sql` in project 3) so you've touched the work.
3. **Make it yours:** tweak a finding's wording, add one insight of your own to
   a README. Interviewers remember candidates who have opinions about their data.
