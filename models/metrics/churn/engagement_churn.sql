-- ==============================================
-- 📈 Engagement Churn Model – FlexPay Analytics
-- ==============================================
-- A user is considered churned if they have not sent or paid an invoice
-- in the last 60 days. This combines `sent_date` from invoices and `paid_date` 
-- for a comprehensive engagement metric.

WITH latest_sent AS (
  SELECT user_id, MAX(sent_date) AS latest_sent_date
  FROM invoices
  WHERE sent_date IS NOT NULL
  GROUP BY user_id
),

latest_paid AS (
  SELECT user_id, MAX(paid_date) AS latest_paid_date
  FROM invoices
  WHERE paid_date IS NOT NULL
  GROUP BY user_id
),

latest_engagement_per_user AS (
  SELECT 
    COALESCE(s.user_id, p.user_id) AS user_id,
    GREATEST(COALESCE(s.latest_sent_date, '1900-01-01'), COALESCE(p.latest_paid_date, '1900-01-01')) AS latest_engagement_date
  FROM latest_sent s
  FULL OUTER JOIN latest_paid p ON s.user_id = p.user_id
),

user_status AS (
  SELECT 
    user_id,
    latest_engagement_date,
    CASE 
      WHEN latest_engagement_date < CURRENT_DATE - INTERVAL '60 days' THEN 'churned'
      ELSE 'active'
    END AS user_status
  FROM latest_engagement_per_user
)

SELECT 
  COUNT(*) FILTER (WHERE user_status = 'churned') AS churned_users,
  COUNT(*) FILTER (WHERE user_status = 'active') AS active_users,
  COUNT(*) AS total_users,
  ROUND(
    COUNT(*) FILTER (WHERE user_status = 'churned') * 100.0 / NULLIF(COUNT(*), 0),
    2
  ) AS churned_percentage
FROM user_status;

