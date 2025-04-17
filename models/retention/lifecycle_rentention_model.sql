-- ===============================================
-- 🧠 Lifecycle Segmentation Model
-- ===============================================

-- 📌 Business Value:
-- Classifies FlexPay users into meaningful lifecycle buckets 
-- (e.g., new, activated, power users, churned, resurrected) 
-- based on invoice activity — enabling targeted lifecycle interventions.

-- 🔍 Use Case:
-- Helps Growth, Product, and Lifecycle Marketing teams:
-- → Identify power users for feature upsells or testimonials
-- → Detect churned users for winback campaigns
-- → Track activation milestones across cohorts

-- 🧮 Classification Logic:
-- - new: User has signed up but hasn't sent any invoice
-- - activated: User sent their first invoice (but <5 total sent)
-- - power user: User has sent ≥5 invoices
-- - churned: User hasn't sent an invoice in the last 30 days
-- - resurrected: Was previously churned but sent an invoice again recently

-- 📁 File: models/retention/lifecycle_segmentation_model.sql
-- 🕒 Last Updated: 2025-04-17
-- ✍️ Author: thatdataguy1786 (GitHub)
-- ===============================================


WITH
	INVOICE_AT_USER_LEVEL AS (
		SELECT
			USER_ID,
			COUNT(INVOICE_ID) AS TOTAL_INVOICES_SENT,
			MAX(SENT_DATE) AS LAST_SENT_DATE,
			SUM(AMOUNT) AS TOTAL_PAID
		FROM
			INVOICES I
		GROUP BY
			1
		ORDER BY
			USER_ID
	),
	BASE_LIFECYCLE_METRICS AS (
		SELECT
			U.USER_ID,
			U.SIGNUP_DATE,
			IUL.TOTAL_INVOICES_SENT,
			IUL.LAST_SENT_DATE,
			IUL.TOTAL_PAID,
			CURRENT_DATE - IUL.LAST_SENT_DATE AS DAYS_SINCE_LAST_SENT
		FROM
			USERS U
			LEFT JOIN INVOICE_AT_USER_LEVEL IUL ON U.USER_ID = IUL.USER_ID
	)
SELECT
	*,
	CASE
		WHEN LAST_SENT_DATE IS NULL THEN 'new'
		WHEN TOTAL_INVOICES_SENT = 1
		AND DAYS_SINCE_LAST_SENT <= 30 THEN 'activated'
		WHEN TOTAL_INVOICES_SENT >= 3
		AND TOTAL_PAID > 500
		AND DAYS_SINCE_LAST_SENT <= 30 THEN 'power user'
		WHEN DAYS_SINCE_LAST_SENT > 60 THEN 'churned'
		WHEN DAYS_SINCE_LAST_SENT <= 30
		AND SIGNUP_DATE + INTERVAL '60 DAYS' < LAST_SENT_DATE THEN 'resurrected'
		ELSE 'other'
	END AS USER_STATUS
FROM
	BASE_LIFECYCLE_METRICS