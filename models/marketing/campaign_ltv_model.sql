
--Campaign LTV & ROI Analysis----
--“Which marketing campaigns drive the highest-value users, and what’s their cost-effectiveness?”



-- ===============================================
-- Campaign LTV and ROI Analysis Model
-- FlexPay (Fictional Fintech SaaS Platform)
-- ===============================================

-- ❓ Objective:
-- Identify which marketing campaigns deliver the highest LTV users
-- and assess their cost-effectiveness using ROI metrics.

-- Metrics Calculated:
-- - Total Revenue per Campaign
-- - Number of Users Acquired
-- - Average LTV per User
-- - Cost per Acquisition (CPA)
-- - Return on Ad Spend (ROAS)
-- - Click-through Rate (CTR)
-- - Cost per Click (CPC)

-- ===============================================
-- Step 1: Calculate LTV per User
WITH
	USER_LTV AS (
		SELECT
			U.USER_ID,
			U.CAMPAIGN_ID,
			SUM(P.AMOUNT) AS LIFETIME_VALUE
		FROM
			USERS U
			JOIN PAYMENTS P ON U.USER_ID = P.USER_ID
		GROUP BY
			U.USER_ID,
			U.CAMPAIGN_ID
	),
-- ===============================================
-- Step 2: Aggregate Metrics at the Campaign Level	
	CAMPAIGN_METRICS AS (
		SELECT
			CAMPAIGN_ID,
			COUNT(USER_ID) AS USER_COUNT,
			SUM(LIFETIME_VALUE) AS TOTAL_REVENUE
		FROM
			USER_LTV
		GROUP BY
			1
	)
-- ===============================================
-- Step 3: Join with Marketing Campaign Metadata	
SELECT
	MC.CAMPAIGN_NAME,
	MC.CLICKS,
	MC.IMPRESSIONS,
	MC.AD_SPEND,
	MC.CHANNEL,
	CM.*,
	CM.TOTAL_REVENUE / MC.AD_SPEND AS ROAS,
	MC.AD_SPEND / CM.USER_COUNT as CPA,
	MC.CLICKS::NUMERIC / MC.IMPRESSIONS AS CTR,
	MC.AD_SPEND / MC.CLICKS AS CPC
FROM
	MARKETING_CAMPAIGNS MC
	JOIN CAMPAIGN_METRICS CM ON MC.CAMPAIGN_ID = CM.CAMPAIGN_ID
ORDER BY ROAS DESC;