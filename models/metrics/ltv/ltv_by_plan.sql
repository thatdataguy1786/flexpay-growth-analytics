-- Historical LTV by Subscription Plan (Flat Snapshot)
-- Calculates average LTV by plan type based on the user's current or latest subscription.
-- Assumes one row per user in the subscriptions table (no time-based history).
-- Formula: LTV = Total Revenue per Plan / Unique Paying Users per Plan

SELECT 
  s.plan_type,
  COUNT(DISTINCT p.user_id) AS paying_users,
  SUM(p.amount) AS total_revenue,
  ROUND(SUM(p.amount)::NUMERIC / NULLIF(COUNT(DISTINCT p.user_id), 0), 2) AS avg_ltv
FROM payments p
JOIN subscriptions s ON p.user_id = s.user_id
GROUP BY s.plan_type
ORDER BY avg_ltv DESC;

