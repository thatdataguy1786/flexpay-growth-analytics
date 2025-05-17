-- CAC by Channel
-- This query calculates Customer Acquisition Cost (CAC) per marketing channel.
-- It joins users to campaigns using campaign_id to ensure accurate attribution.
-- Formula: CAC = Total Ad Spend / Unique Users Acquired (per channel)
-- Uses NULLIF to prevent division by zero.

SELECT 
  mc.channel,
  SUM(mc.ad_spend) AS total_spend,
  COUNT(DISTINCT u.user_id) AS total_users,
  ROUND(SUM(mc.ad_spend)::NUMERIC / NULLIF(COUNT(DISTINCT u.user_id), 0), 2) AS cac
FROM marketing_campaigns mc
JOIN users u ON mc.campaign_id = u.campaign_id
GROUP BY mc.channel
ORDER BY cac;

