-- MRR (Monthly Recurring Revenue) – SCD Type 2 Conceptual Model
-- This model assumes the `subscriptions` table follows an SCD Type 2 format,
-- where each plan change or cancellation results in a new row with updated start and end dates.
-- The model calculates active monthly MRR by assigning users to calendar months
-- based on their subscription periods and plan pricing.

-- Step 1: Create a monthly calendar from Jan 2024 to Dec 2025
WITH calendar_months AS (
  SELECT generate_series (
    DATE '2024-01-01',
    DATE '2025-12-01',
    INTERVAL '1 month'
  ) AS month_start
),

-- Step 2: Create a record of all user-plan-month combinations where the user was active
-- This uses a CROSS JOIN between each subscription and each calendar month,
-- filtering for the months when the plan was active.
active_user_months AS (
  SELECT 
    s.user_id,
    s.plan_type,
    cm.month_start
  FROM calendar_months cm 
  CROSS JOIN subscriptions s
  WHERE cm.month_start BETWEEN s.start_date AND COALESCE(s.end_date, CURRENT_DATE)
),

-- Step 3: Simulate a plan pricing dimension table (plan_type → monthly_mrr)
plan_prices AS (
  SELECT 'Free' AS plan_type, 0 AS monthly_mrr
  UNION ALL
  SELECT 'Pro', 200
  UNION ALL
  SELECT 'Business', 400
),

-- Step 4: Join plan pricing to user-plan-month records
-- This gives us the revenue impact of each active user-plan in each month.
semi AS (
  SELECT 
    aum.*,
    pp.monthly_mrr 
  FROM active_user_months aum 
  JOIN plan_prices pp 
    ON aum.plan_type = pp.plan_type
)

-- Step 5: Final aggregation
-- Group by month to calculate:
-- - total active users
-- - total MRR
-- - ARPU (average revenue per user)
SELECT 
  month_start,
  COUNT(user_id) AS total_users,
  SUM(monthly_mrr) AS total_monthly_mrr,
  ROUND(SUM(monthly_mrr) / NULLIF(COUNT(user_id), 0), 2) AS arpu_month
FROM semi
GROUP BY month_start
ORDER BY month_start;

