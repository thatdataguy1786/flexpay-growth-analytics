-- =============================
-- INVOICE CHURN MODEL
-- =============================

-- ==============================================
-- 📊 Invoice Churn Model – FlexPay Analytics
-- ==============================================
-- This model calculates "invoice churn" based on paid recurring invoices.
-- A user is considered churned if they previously paid a recurring invoice
-- but has not paid one in the last 60 days.
-- Useful for tracking cash-related churn and building reactivation campaigns.

-- Step 1️⃣: Filter invoices to get only 'recurring' type and 'Paid' status

WITH paid_recurring_invoices AS (
  -- CTE 1: Filter only 'recurring' and 'paid' invoices
  SELECT 
    user_id, 
    paid_date
  FROM invoices
  WHERE status = 'Paid'
    AND invoice_type = 'recurring'
    AND paid_date IS NOT NULL
),

-- Step 2️⃣: Get the latest paid_date for each user
latest_invoice_per_user AS (
  -- CTE 2: Get the latest paid_date for each user
  SELECT 
    user_id,
    MAX(paid_date) AS latest_paid_date
  FROM paid_recurring_invoices
  GROUP BY user_id
),


-- Step 3️⃣: Classify users as 'churned' or 'active'
invoice_churn_status AS (
  -- CTE 3: Classify users as churned or active based on 60-day gap
  SELECT 
    user_id,
    latest_paid_date,
    DATE_PART('day', CURRENT_DATE - latest_paid_date) AS days_since_last_paid,
    CASE 
      WHEN CURRENT_DATE > latest_paid_date + INTERVAL '60 days' THEN 'churned'
      ELSE 'active'
    END AS user_status
  FROM latest_invoice_per_user
)

-- Step 4️⃣: Final Output – Churn Summary Table
SELECT 
  user_status,
  COUNT(*) AS user_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS churn_percentage
FROM invoice_churn_status
GROUP BY user_status
ORDER BY user_status;
-- ==============================================
-- 📘 README NOTES:
-- - This model assumes the `invoices` table has accurate `paid_date` values.
-- - Churn is based on absence of 'recurring' invoice payments in the last 60 days.
-- - Payment failures or one-time invoices are ignored.
-- - Use this to monitor revenue decay and plan reactivation campaigns.
-- - Built for FlexPay simulated data; real data may need adjustments.
-- ==============================================