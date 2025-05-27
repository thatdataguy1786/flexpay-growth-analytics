-- ==============================================
-- 💸 Payment Churn Model – FlexPay Analytics
-- ==============================================
-- This model calculates "payment churn" based on the absence of recent payments.
-- A user is considered churned if they have not made any payment in the last 60 days.
-- Useful for tracking cash flow churn and financial health metrics.

-- Step 1️⃣: Get the latest payment_date for each user
WITH latest_payment_per_user AS (
  SELECT 
    user_id, 
    MAX(payment_date) AS latest_payment_date -- Most recent payment date
  FROM payments
  WHERE amount > 0                          -- Filter for valid (non-zero) payments
  GROUP BY user_id
),

-- Step 2️⃣: Classify users as 'churned' or 'active'
payment_churn_status AS (
  SELECT 
    user_id,
    latest_payment_date,
    DATE_PART('day', CURRENT_DATE - latest_payment_date) AS days_since_last_payment,
    CASE 
      WHEN CURRENT_DATE > latest_payment_date + INTERVAL '60 days' THEN 'churned'
      ELSE 'active'
    END AS user_status
  FROM latest_payment_per_user
)

-- Step 3️⃣: Final Output – Churn Summary Table
SELECT 
  user_status,                                  -- 'churned' or 'active'
  COUNT(*) AS user_count,                       -- Number of users in this status
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS churn_percentage -- % of total
FROM payment_churn_status
GROUP BY user_status
ORDER BY user_status;

-- ==============================================
-- 📘 README NOTES:
-- - This model assumes the `payments` table contains one row per payment made.
-- - Churn is based on absence of any payment (amount > 0) in the last 60 days.
-- - Works independently of invoice logic, purely based on actual cash flow.
-- - Use this to monitor revenue churn and predict financial health.
-- - Built for FlexPay simulated data; real data may need adjustments.
-- ==============================================
