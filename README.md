# QuickPay FinTech Operations Case Study

## Student Details

* **Student Name:** Col Sameer Rai
* **Student ID:** 
* **GitHub Repository:** https://github.com/sameerrai1959-bit/GA02

## Assignment Overview

This repository contains the complete solution for the Masai Graded Assignment: QuickPay FinTech Operations Case Study. It covers data cleaning, SQL analysis, Python reconciliation, JSON normalization, and a Looker Studio dashboard.

## Tools Used

* **Part 1 (Spreadsheet):** Python (pandas, openpyxl) + Excel / Google Sheets
* **Part 2 (SQL):** SQLite / standard SQL
* **Part 3 \& 4 (Python):** Python 3, pandas, Jupyter Notebook
* **Part 5 (Dashboard):** Google Looker Studio

## Repository Structure

```
quickpay/
├── README.md
├── 01\_data/
│   ├── raw/
│   │   ├── transactions\_raw.csv
│   │   ├── merchant\_master.csv
│   │   ├── users.csv
│   │   ├── ledger.csv
│   │   ├── gateway.csv
│   │   ├── exchange\_rates.csv
│   │   └── api\_response\_sample.json
│   └── processed/
│       ├── cleaned\_transactions.csv
│       ├── merchant\_risk\_summary.csv
│       ├── missing\_in\_gateway.csv
│       ├── missing\_in\_ledger.csv
│       ├── amount\_mismatches.csv
│       ├── status\_mismatches.csv
│       ├── reconciliation\_report.csv
│       ├── api\_normalized.csv
│       ├── daily\_summary.csv
│       ├── payment\_method\_breakdown.csv
│       ├── region\_breakdown.csv
│       └── merchant\_performance\_summary.csv
├── 02\_spreadsheet/
│   ├── spreadsheet\_workbook.xlsx
│   └── spreadsheet\_answers.md
├── 03\_sql/
│   ├── analysis\_queries.sql
│   └── sql\_answers.md
├── 04\_python/
│   ├── fintech\_pipeline.ipynb
│   └── summary\_metrics.json
└── 05\_visualization/
    └── dashboard\_link.txt
```

## How to Run

### Part 1 — Data Cleaning

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
`05\_visualization/dashboard\_link.txt`

## Key Findings

* **Total GMV:** USD 116,080 across 30 transactions
* **Captured GMV:** USD 82,356
* **Chargeback rate:** 13.33% (4 out of 30 transactions)
* **High risk transactions:** 9
* **High value transactions:** 7
* **Fraud alert:** User U008 had 4 failed/chargeback transactions on 2026-03-05
* **Top merchant by GMV:** Beta Stores (APAC) — USD 33,431 captured
* **Reconciliation issues found:** 6 (2 missing in gateway, 1 missing in ledger, 2 amount mismatches, 1 status mismatch)

