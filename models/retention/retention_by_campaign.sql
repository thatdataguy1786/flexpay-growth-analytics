-- FLEXPAY - Retention by Campaign SQL Model
-- ------------------------------------------------------
-- GOAL: Understand how many users brought in by each campaign were "retained" (engaged 30+ days)
-- This is a core SaaS metric used in marketing ROI, lifecycle modeling, and cohort analysis.

-- STEP 1: Get the last payment date for every user
-- Why? This tells us their last known activity in the FlexPay app (used as a proxy for "active")
WITH
	LAST_PAYMENT_DATE AS (
		SELECT
			USER_ID,
			MAX(PAYMENT_DATE) AS LAST_PAYMENT_DATE
		FROM
			PAYMENTS
		GROUP BY
			1
	),
-- STEP 2: Join with user data to compute total number of days between signup and last activity
-- Why? It helps us measure how long each user stayed active after they signed up.
	USER_LIFETIME_DAYS AS (
		SELECT
			LPD.USER_ID,
			LPD.LAST_PAYMENT_DATE,
			U.SIGNUP_DATE,
			U.CAMPAIGN_ID,
			LAST_PAYMENT_DATE - SIGNUP_DATE AS DAYS_ACTIVE
		FROM
			LAST_PAYMENT_DATE LPD
			JOIN USERS U ON LPD.USER_ID = U.USER_ID
	)

-- STEP 3: Use CASE WHEN logic to classify each user as "active" or "churned"
-- Retained users are those who stayed engaged for 30+ days
,
	USER_RETENTION_LABELS AS (
		SELECT
			ULD.USER_ID,
			ULD.LAST_PAYMENT_DATE,
			ULD.SIGNUP_DATE,
			ULD.CAMPAIGN_ID,
			ULD.DAYS_ACTIVE,
			CASE
				WHEN DAYS_ACTIVE >= 30 THEN 'active'
				ELSE 'churned'
			END AS RETENTION_STATUS
		FROM
			USER_LIFETIME_DAYS ULD
	)

-- STEP 4: Join with campaign metadata and count users per retention bucket
-- Why? This gives us campaign-level retention rates we can analyze in dashboards or reporting.
SELECT
	MC.CAMPAIGN_NAME,
	URL.RETENTION_STATUS,
	COUNT(URL.USER_ID) AS USER_COUNT
FROM
	USER_RETENTION_LABELS URL
	JOIN MARKETING_CAMPAIGNS MC ON URL.CAMPAIGN_ID = MC.CAMPAIGN_ID
GROUP BY
	MC.CAMPAIGN_NAME,
	URL.RETENTION_STATUS
ORDER BY
	MC.CAMPAIGN_NAME,
	URL.RETENTION_STATUS
