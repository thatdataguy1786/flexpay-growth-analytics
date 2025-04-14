-- cohort_retention_model.sql
-- ----------------------------------------------
-- 📊 Weekly Cohort Retention Analysis for FlexPay
-- ----------------------------------------------
-- Goal:
-- Measure 30-day user retention using behavioral signals.
-- Day 0 = First sent invoice date (sent_date).
-- Retention = User sends another invoice within a specific weekly bucket after Day 0.
--
-- Why sent_date?
-- - It captures true product engagement (user actively using the product)
-- - Unlike issue_date (intent-only) or paid_date (client-dependent), sent_date reflects execution.
--
-- Retention Bands:
-- - Day 1–7
-- - Day 8–14
-- - Day 15–21
-- - Day 22–30
--
-- Output includes:
-- - Weekly cohort start date
-- - Users in each cohort
-- - Count of users retained per band
-- - % of users retained per band (rounded to 1 decimal)
--
-- Analyst Notes:
-- This model can feed dashboards or be used to compare cohorts pre/post product feature changes.
-- Could be extended for Day 60/90, product segmentation, or experiment group filtering.

WITH first_sent_date AS (
  SELECT
    user_id,
    MIN(sent_date) AS day0
  FROM invoices
  GROUP BY user_id
),

retained_users AS (
  SELECT
    i.user_id,
    f.day0,
    MIN(i.sent_date) AS second_sent
  FROM invoices i
  JOIN first_sent_date f ON i.user_id = f.user_id
  WHERE i.sent_date > f.day0
    AND i.sent_date <= f.day0 + INTERVAL '30 days'
  GROUP BY i.user_id, f.day0
),

final_users AS (
  SELECT
    f.user_id,
    f.day0,
    DATE_TRUNC('week', f.day0) AS cohort_week,
    r.second_sent
  FROM first_sent_date f
  LEFT JOIN retained_users r ON f.user_id = r.user_id
)

SELECT
  cohort_week,
  COUNT(user_id) AS users_in_cohort,

  COUNT(CASE 
    WHEN second_sent > day0 AND second_sent <= day0 + INTERVAL '7 days' 
    THEN 1 END) AS retained_day_1_7,
  
  ROUND(100.0 * COUNT(CASE 
    WHEN second_sent > day0 AND second_sent <= day0 + INTERVAL '7 days' 
    THEN 1 END) / COUNT(user_id), 1) AS pct_retained_1_7,

  COUNT(CASE 
    WHEN second_sent > day0 + INTERVAL '7 days' AND second_sent <= day0 + INTERVAL '14 days' 
    THEN 1 END) AS retained_day_8_14,

  ROUND(100.0 * COUNT(CASE 
    WHEN second_sent > day0 + INTERVAL '7 days' AND second_sent <= day0 + INTERVAL '14 days' 
    THEN 1 END) / COUNT(user_id), 1) AS pct_retained_8_14,

  COUNT(CASE 
    WHEN second_sent > day0 + INTERVAL '14 days' AND second_sent <= day0 + INTERVAL '21 days' 
    THEN 1 END) AS retained_day_15_21,

  ROUND(100.0 * COUNT(CASE 
    WHEN second_sent > day0 + INTERVAL '14 days' AND second_sent <= day0 + INTERVAL '21 days' 
    THEN 1 END) / COUNT(user_id), 1) AS pct_retained_15_21,

  COUNT(CASE 
    WHEN second_sent > day0 + INTERVAL '21 days' AND second_sent <= day0 + INTERVAL '30 days' 
    THEN 1 END) AS retained_day_22_30,

  ROUND(100.0 * COUNT(CASE 
    WHEN second_sent > day0 + INTERVAL '21 days' AND second_sent <= day0 + INTERVAL '30 days' 
    THEN 1 END) / COUNT(user_id), 1) AS pct_retained_22_30

FROM final_users
GROUP BY cohort_week
ORDER BY cohort_week;
