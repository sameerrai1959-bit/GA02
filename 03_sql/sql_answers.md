# SQL Answers

## Q1
### Query
Count all transactions grouped by their status, with percentage of total.
```sql
SELECT status, COUNT(*) AS transaction_count,
    ROUND(COUNT(*)*100.0/30,2) AS pct_of_total
FROM transactions GROUP BY status ORDER BY transaction_count DESC;
```
### Result Summary
| status | transaction_count | pct_of_total |
|---|---|---|
| captured | 19 | 63.33% |
| failed | 7 | 23.33% |
| chargeback | 4 | 13.33% |

The majority of transactions (63.33%) are successfully captured. 13.33% resulted in chargebacks, which is a significant risk signal requiring investigation.

---

## Q2
### Query
Total captured GMV by merchant, showing only status = 'captured' rows.
```sql
SELECT merchant_id, merchant_name, gateway_region,
    ROUND(SUM(amount_usd),2) AS total_captured_gmv_usd, COUNT(*) AS captured_transactions
FROM transactions WHERE status='captured'
GROUP BY merchant_id, merchant_name, gateway_region ORDER BY total_captured_gmv_usd DESC;
```
### Result Summary
| merchant_name | gateway_region | total_captured_gmv_usd | captured_transactions |
|---|---|---|---|
| Beta Stores | APAC | 33431.00 | 7 |
| Alpha Mart | APAC | 29984.50 | 8 |
| Delta Travels | US | 10300.00 | 2 |
| City Pharma | EU | 8640.00 | 2 |

Eco Home had 0 captured GMV (all transactions ended in chargeback or failed). Beta Stores leads by captured GMV despite fewer captured transactions than Alpha Mart, indicating higher average transaction values.

---

## Q3
### Query
Top 10 merchants by captured GMV (same as Q2 in this dataset — only 5 merchants exist).
```sql
SELECT merchant_id, merchant_name, gateway_region,
    ROUND(SUM(amount_usd),2) AS total_captured_gmv_usd, COUNT(*) AS captured_transactions
FROM transactions WHERE status='captured'
GROUP BY merchant_id, merchant_name, gateway_region
ORDER BY total_captured_gmv_usd DESC LIMIT 10;
```
### Result Summary
Top merchant by captured GMV is **Beta Stores** (APAC) at USD 33,431.00, followed by **Alpha Mart** (APAC) at USD 29,984.50. Both APAC merchants significantly outperform EU and US merchants in absolute GMV.

---

## Q4
### Query
Daily GMV trend and successful transaction count per day.
```sql
SELECT transaction_date, ROUND(SUM(amount_usd),2) AS daily_gmv_usd,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status='captured' THEN 1 ELSE 0 END) AS successful_count,
    ROUND(SUM(CASE WHEN status='captured' THEN amount_usd ELSE 0 END),2) AS daily_captured_gmv
FROM transactions GROUP BY transaction_date ORDER BY transaction_date;
```
### Result Summary
| date | daily_gmv_usd | total_txns | successful_count | captured_gmv |
|---|---|---|---|---|
| 2026-03-01 | 26382.00 | 5 | 5 | 26382.00 |
| 2026-03-02 | 25049.00 | 6 | 3 | 11080.00 |
| 2026-03-03 | 18391.00 | 5 | 4 | 16031.50 |
| 2026-03-04 | 16420.00 | 5 | 4 | 13920.00 |
| 2026-03-05 | 19232.00 | 6 | 1 | 6136.00 |
| 2026-03-06 | 10606.00 | 3 | 2 | 8806.00 |

2026-03-01 had 100% success rate. 2026-03-05 was the worst day — 6 transactions but only 1 captured (user U008 had 4 failed/chargeback transactions alone that day).

---

## Q5
### Query
Merchants with chargeback ratio above 1%.
```sql
SELECT merchant_id, merchant_name, COUNT(*) AS total_transactions,
    SUM(CASE WHEN status='chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
    ROUND(SUM(CASE WHEN status='chargeback' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS chargeback_ratio_pct
FROM transactions GROUP BY merchant_id, merchant_name
HAVING chargeback_ratio_pct > 1 ORDER BY chargeback_ratio_pct DESC;
```
### Result Summary
| merchant_name | total_txns | chargeback_count | chargeback_ratio_pct |
|---|---|---|---|
| Eco Home | 2 | 1 | 50.00% |
| Delta Travels | 4 | 1 | 25.00% |
| Alpha Mart | 11 | 1 | 9.09% |
| Beta Stores | 11 | 1 | 9.09% |

All 5 merchants (except City Pharma) exceed the 1% chargeback threshold. Eco Home at 50% is extremely high risk. Even the two largest merchants (Alpha Mart and Beta Stores) are at 9.09%, well above typical industry threshold of 1%.

---

## Q6
### Query
Regions with average risk score above 50 AND more than 20 transactions.
```sql
SELECT gateway_region, COUNT(*) AS transaction_count,
    ROUND(AVG(risk_score),2) AS avg_risk_score,
    SUM(CASE WHEN status='chargeback' THEN 1 ELSE 0 END) AS chargeback_count
FROM transactions WHERE risk_score IS NOT NULL
GROUP BY gateway_region HAVING AVG(risk_score)>50 AND COUNT(*)>20 ORDER BY avg_risk_score DESC;
```
### Result Summary
| gateway_region | transaction_count | avg_risk_score | chargeback_count |
|---|---|---|---|
| APAC | 21 | 65.48 | 2 |

Only APAC meets both criteria (avg risk > 50 AND > 20 transactions). EU and US regions have fewer than 20 transactions. APAC's average risk score of 65.48 is concerning and warrants closer monitoring.

---

## Q7
### Query
Users with 3 or more failed or chargeback transactions on the same day.
```sql
SELECT user_id, transaction_date, COUNT(*) AS fail_or_chargeback_count
FROM transactions WHERE status IN ('failed','chargeback')
GROUP BY user_id, transaction_date HAVING COUNT(*)>=3 ORDER BY fail_or_chargeback_count DESC;
```
### Result Summary
| user_id | transaction_date | fail_or_chargeback_count |
|---|---|---|
| U008 | 2026-03-05 | 4 |

User **U008** had 4 failed/chargeback transactions on 2026-03-05 alone (T016, T017, T018, T019). This pattern is a strong fraud signal and the account should be reviewed immediately. This user appears across multiple merchants (Beta Stores and Alpha Mart) on the same day.

---

## Q8
### Query
Chargeback count, unique users affected, and total chargeback amount by merchant.
```sql
SELECT merchant_id, merchant_name, gateway_region,
    COUNT(*) AS chargeback_count,
    COUNT(DISTINCT user_id) AS unique_affected_users,
    ROUND(SUM(amount_usd),2) AS total_chargeback_amount_usd,
    ROUND(AVG(amount_usd),2) AS avg_chargeback_amount_usd
FROM transactions WHERE status='chargeback'
GROUP BY merchant_id, merchant_name, gateway_region ORDER BY total_chargeback_amount_usd DESC;
```
### Result Summary
| merchant_name | chargeback_count | unique_users | total_chargeback_usd | avg_chargeback_usd |
|---|---|---|---|---|
| Eco Home | 1 | 1 | 6649.00 | 6649.00 |
| Alpha Mart | 1 | 1 | 5400.00 | 5400.00 |
| Delta Travels | 1 | 1 | 2500.00 | 2500.00 |
| Beta Stores | 1 | 1 | 1711.00 | 1711.00 |

Total chargeback exposure across all merchants is **USD 16,260.00**. Eco Home has the highest single chargeback amount at USD 6,649 — which is also 100% of their GMV since they had no captured transactions. Each chargeback involves a different user, suggesting these are individual customer disputes rather than a coordinated fraud pattern.
