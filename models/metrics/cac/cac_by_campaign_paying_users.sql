-- CAC for Paying (Active) Users by Campaign
-- This query calculates the Customer Acquisition Cost (CAC) at the campaign level,
-- but filters only for users who have an active paid subscription (Pro or Business).
-- Joins marketing_campaigns to users via campaign_id, and users to subscriptions via user_id.
-- Only active subscriptions (is_active = true) are included to reflect real paying customers.
-- Formula: CAC = Total Ad Spend / Unique Paying Users per Campaign
-- NULLIF is used to avoid division-by-zero errors when no users converted.

SELECT
  mc.campaign_name,
  mc.channel,
  SUM(mc.ad_spend),
  COUNT(DISTINCT u.user_id) AS total_users_acquired,
  ROUND(
    SUM(mc.ad_spend) / NULLIF(COUNT(DISTINCT u.user_id), 0),
    2
  ) AS cac
FROM marketing_campaigns mc
LEFT JOIN users u ON mc.campaign_id = u.campaign_id
JOIN subscriptions s ON u.user_id = s.user_id
WHERE s.plan_type IN ('Business', 'Pro')
  AND s.is_active = 'true'
GROUP BY mc.channel, mc.campaign_name
ORDER BY cac;
