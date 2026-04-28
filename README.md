# QuickPay FinTech Operations Case Study

## Student Details

* **Student Name:** Col Sameer Rai
* **Student ID:** BITSoM_FTAI_2601064
* **GitHub Repository:** https://github.com/sameerrai1959-bit/GA02

## Assignment Overview

This repository contains the complete solution for the Masai Graded Assignment: QuickPay FinTech Operations Case Study. It covers data cleaning, SQL analysis, Python reconciliation, JSON normalizatioNNNNn, and a Looker Studio dashboardDDDD.

## Tools Used

* **Part 1 (Spreadsheet):** Python (pandas, openpyxl) + Excel / Google Sheets
* **Part 2 (SQL):** SQLite / standard SQL
* **Part 3 \& 4 (Python):** Python 3, pandas, Jupyter Notebook
* **Part 5 (Dashboard):** Google Looker St

## How to Run

### Part 1 — Data Clg

Open `02\_spreadsheet/spreadsheet\_workbook.xlsx` in Excel or Google Sheets.
The workbook contains:

* Sheet 1: Raw Transactions
* Sheet 2: Cleaned Transactions (with flags)
* Sheet 3: Merchant Risk Summary

### Part 2 — SQL

Open `03\_sql/analysis\_queries.sql` in any SQL editor.
Load `01\_data/processed/cleaned\_transactions.csv` as a table named `transactions`.
All 8 queries are labeled Q1 through Q8.

### Part 3 \& 4 — Python Notebook

```bash
pip install pandas openpyxl jupyter
jupyter notebook 04\_python/fintech\_pipeline.ipynb
```

Run all cells in order. The notebook will:

* Reconcile ledger.csv vs gateway.csv
* Generate all processed output CSVs
* Normalize the JSON API response
* Save summary\_metrics.json

### Part 5 — Dashboard

See the public Looker Studio dashboard link in:
`05_visualization/dashboard_link.txt`

## Key Findings

* **Total GMV:** USD 116,080 across 30 transactions
* **Captured GMV:** USD 82,356
* **Chargeback rate:** 13.33% (4 out of 30 transactions)
* **High risk transactions:** 9
* **High value transactions:** 7
* **Fraud alert:** User U008 had 4 failed/chargeback transactions on 2026-03-05
* **Top merchant by GMV:** Beta Stores (APAC) — USD 33,431 captured
* **Reconciliation issues found:** 6 (2 missing in gateway, 1 missing in ledger, 2 amount mismatches, 1 status mismatch)

