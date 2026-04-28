-- QuickPay FinTech Operations - SQL Business Analysis
-- All queries assume a table named: transactions
-- Columns: transaction_id, transaction_date, merchant_id, merchant_name,
--          merchant_category, gateway_region, raw_amount, currency,
--          exchange_rate, amount_usd, status, risk_score,
--          payment_method, user_id, high_value_flag, high_risk_flag

-- Q1
-- Count transactions by status
SELECT
    status,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM transactions
GROUP BY status
ORDER BY transaction_count DESC;

-- Q2
-- Calculate total captured GMV by merchant
SELECT
    merchant_id,
    merchant_name,
    gateway_region,
    ROUND(SUM(amount_usd), 2) AS total_captured_gmv_usd,
    COUNT(*) AS captured_transactions
FROM transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name, gateway_region
ORDER BY total_captured_gmv_usd DESC;

-- Q3
-- Show top 10 merchants by captured GMV
SELECT
    merchant_id,
    merchant_name,
    gateway_region,
    ROUND(SUM(amount_usd), 2) AS total_captured_gmv_usd,
    COUNT(*) AS captured_transactions
FROM transactions
WHERE status = 'captured'
GROUP BY merchant_id, merchant_name, gateway_region
ORDER BY total_captured_gmv_usd DESC
LIMIT 10;

-- Q4
-- Show daily GMV and successful transaction count
SELECT
    transaction_date,
    ROUND(SUM(amount_usd), 2) AS daily_gmv_usd,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status = 'captured' THEN 1 ELSE 0 END) AS successful_count,
    ROUND(SUM(CASE WHEN status = 'captured' THEN amount_usd ELSE 0 END), 2) AS daily_captured_gmv
FROM transactions
GROUP BY transaction_date
ORDER BY transaction_date;

-- Q5
-- Find merchants with chargeback ratio above 1%
SELECT
    merchant_id,
    merchant_name,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count,
    ROUND(
        SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS chargeback_ratio_pct
FROM transactions
GROUP BY merchant_id, merchant_name
HAVING chargeback_ratio_pct > 1
ORDER BY chargeback_ratio_pct DESC;

-- Q6
-- Find regions with average risk score above 50 and more than 20 transactions
SELECT
    gateway_region,
    COUNT(*) AS transaction_count,
    ROUND(AVG(risk_score), 2) AS avg_risk_score,
    SUM(CASE WHEN status = 'chargeback' THEN 1 ELSE 0 END) AS chargeback_count
FROM transactions
WHERE risk_score IS NOT NULL
GROUP BY gateway_region
HAVING AVG(risk_score) > 50 AND COUNT(*) > 20
ORDER BY avg_risk_score DESC;

-- Q7
-- Find users with 3 or more failed or chargeback transactions on the same day
SELECT
    user_id,
    transaction_date,
    COUNT(*) AS fail_or_chargeback_count,
    GROUP_CONCAT(transaction_id) AS transaction_ids
FROM transactions
WHERE status IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date
HAVING COUNT(*) >= 3
ORDER BY fail_or_chargeback_count DESC;

-- Q8
-- Show chargeback count, unique affected users, and chargeback amount by merchant
SELECT
    merchant_id,
    merchant_name,
    gateway_region,
    COUNT(*) AS chargeback_count,
    COUNT(DISTINCT user_id) AS unique_affected_users,
    ROUND(SUM(amount_usd), 2) AS total_chargeback_amount_usd,
    ROUND(AVG(amount_usd), 2) AS avg_chargeback_amount_usd
FROM transactions
WHERE status = 'chargeback'
GROUP BY merchant_id, merchant_name, gateway_region
ORDER BY total_chargeback_amount_usd DESC;
