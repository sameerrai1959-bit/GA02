# Spreadsheet Answers

## Cleaning Steps
1. Stripped leading/trailing whitespace from all text fields (merchant names, status, gateway_region)
2. Removed extra internal spaces from merchant names (e.g. "Alpha  Mart" → "Alpha Mart")
3. Converted all text to consistent casing before mapping to standard values
4. Removed 1 row with no transaction_id (the dataset had 30 valid rows from the raw 31 including header)
5. Standardized risk_score by stripping non-numeric prefixes ("score:", "risk-") and extracting integer values; 1 row (T011) had no risk_score and was left as blank/null
6. Filled missing gateway_region values by looking up the merchant's default_region from merchant_master.csv (affected T002, T005, T006, T008, T010, T015, T021)

## Standardization Rules

### Merchant Names
| Raw Value | Standardized |
|---|---|
| alpha mart, ALPHA MART, Alpha  Mart | Alpha Mart |
| BETA STORES, Beta  Stores, beta stores | Beta Stores |
| City Pharma | City Pharma |
| Eco Home | Eco Home |
| DELTA TRAVELS, delta travels | Delta Travels |

### Date Format
All dates standardized to `YYYY-MM-DD` (ISO 8601). No format inconsistencies found — all dates were already in this format.

### Status Values
| Raw Value | Standardized |
|---|---|
| Captured, CAPTURED, captured, Captured (trailing space) | captured |
| failed e05 timeout, FAILED e05 TIMEOUT, Failed E05 Timeout | failed |
| chargeback, chargeback (with spaces) | chargeback |

### Risk Scores
| Raw Pattern | Cleaned |
|---|---|
| score:62, score:54 | 62, 54 |
| risk-83, risk-77 | 83, 77 |
| 55, 59 (clean) | 55, 59 |
| 58 (with trailing space) | 58 |
| blank (T011) | null |

### Gateway Regions
| Raw Value | Standardized |
|---|---|
| APAC, apac, " APAC " | APAC |
| EU, eu, " EU " | EU |
| us, US | US |
| (blank) | Filled from merchant_master default_region |

## Lookup and Enrichment Logic

### Currency Conversion to USD
Formula used: `amount_usd = raw_amount × exchange_rate`

Exchange rate lookup: matched on both `transaction_date` AND `currency` from `exchange_rates.csv`.

| Currency | Rates Used |
|---|---|
| INR | 0.0119–0.012 depending on date |
| EUR | 1.07–1.09 depending on date |
| USD | 1.0 (no conversion needed) |

### Merchant Enrichment (from merchant_master.csv)
Joined on `merchant_name` (after standardization) to pull:
- `merchant_id`
- `merchant_category`
- `account_manager`
- `default_region` (used to fill blank gateway_region values)

### Flag Formulas

**high_value_flag:**
```
=IF(OR(
  AND(gateway_region="APAC", amount_usd>5000),
  AND(gateway_region="EU", amount_usd>6000),
  AND(gateway_region="US", amount_usd>7000)
), 1, 0)
```

**high_risk_flag:**
```
=IF(OR(risk_score>=70, ISNUMBER(SEARCH("chargeback",status))), 1, 0)
```

## Final Answers

- **Total raw rows:** 30 (excluding header row)
- **Total cleaned rows:** 30 (all rows were valid; no rows dropped)
- **Invalid or missing rows handled:** 1 null risk_score (T011), 7 missing gateway_region values filled from merchant default
- **Top region by GMV:** APAC (USD 116,080 total GMV)
- **Number of high value transactions:** 7
- **Number of high risk transactions:** 9
- **Top merchant by captured GMV:** Beta Stores (USD 33,431.00)

## Formula Samples

### Amount USD conversion (Excel/Google Sheets)
```
=D2 * VLOOKUP(E2, exchange_rates!$B:$C, 2, FALSE)
```
*(Where D2 = raw_amount, E2 = currency)*

If date-specific rates needed (VLOOKUP with two keys):
```
=D2 * INDEX(exchange_rates!$C:$C,
       MATCH(1, (exchange_rates!$A:$A=B2)*(exchange_rates!$B:$B=E2), 0))
```

### Merchant ID lookup
```
=VLOOKUP(C2, merchant_master!$B:$A, 1, FALSE)
```

### high_value_flag
```
=IF(OR(AND(H2="APAC",K2>5000),AND(H2="EU",K2>6000),AND(H2="US",K2>7000)),1,0)
```

### high_risk_flag
```
=IF(OR(L2>=70, ISNUMBER(SEARCH("chargeback",F2))),1,0)
```

### Merchant Risk Summary (pivot)
Pivot table on `merchant_name`, aggregating:
- COUNT of transaction_id → total_transactions
- SUM of amount_usd → total_gmv_usd
- SUM of amount_usd (filtered status=captured) → captured_gmv_usd
- AVERAGE of risk_score → avg_risk_score
- COUNTIF status="chargeback" → chargeback_count
- Calculated: chargeback_ratio_pct = chargeback_count / total_transactions × 100
