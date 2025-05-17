-- CAC by Campaign
-- This query calculates Customer Acquisition Cost (CAC) for each individual campaign.
-- It joins users to marketing_campaigns via campaign_id, ensuring precise attribution.
-- Formula: CAC = Ad Spend / Unique Users Acquired (per campaign)
-- LEFT JOIN is used to show all campaigns, even those with 0 conversions.
-- NULLIF is used to safely handle division by zero when a campaign has no users.

SELECT 
  mc.campaign_name,
  mc.channel,
  mc.ad_spend,
  COUNT(DISTINCT u.user_id) AS users_acquired,
  ROUND(mc.ad_spend::NUMERIC / NULLIF(COUNT(DISTINCT u.user_id), 0), 2) AS cac
FROM marketing_campaigns mc
LEFT JOIN users
