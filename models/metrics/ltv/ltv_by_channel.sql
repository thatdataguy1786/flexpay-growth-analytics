-- Historical LTV by Acquisition Channel
-- Calculates average LTV by acquisition source (e.g., referral, Google Ads, email).
-- Uses payments and users table, joined on user_id.
-- Formula: LTV = Total Revenue per Channel / Unique Paying Users per Channel

SELECT
	MC.CHANNEL,
	SUM(AMOUNT) AS TOTAL_AMOUNT,
	COUNT(DISTINCT P.USER_ID) AS TOTAL_USERS,
	ROUND(
		SUM(P.AMOUNT) / NULLIF(COUNT(DISTINCT P.USER_ID), 0),
		2
	) AS AVG_LTV
FROM
	PAYMENTS P
	LEFT JOIN USERS U ON P.USER_ID = U.USER_ID
	JOIN MARKETING_CAMPAIGNS MC ON U.CAMPAIGN_ID = MC.CAMPAIGN_ID GROUP BY
	MC.CHANNEL
