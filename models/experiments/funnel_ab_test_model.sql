-- =============================================================================
-- 📈 Funnel A/B Test Model: Created vs Sent vs Paid
-- =============================================================================
-- 🧪 Experiment Objective:
-- Compare the performance of control vs variant groups through the invoicing funnel
-- to determine if the new invoice template increases conversion to payment.
--
-- ✅ Stages Tracked:
-- 1. Created Invoice
-- 2. Sent Invoice
-- 3. Got Paid
--
-- 🔍 Metrics Output:
-- - Count of users per stage per group
-- - Drop-off at each stage
-- - Conversion rate from stage to stage
--
-- 💼 Business Value:
-- Informs product/design teams whether the new invoice template drives better
-- engagement and faster payment in FlexPay's invoicing flow.
--
-- 📂 File: models/experiments/funnel_ab_test_model.sql
-- 📅 Last Updated: 2025-04-13
-- 👤 Author: thatdataguy1786 (GitHub handle)
-- =============================================================================


WITH
	BASE_FUNNEL AS (
		SELECT
			U.USER_ID,
			U.EXPERIMENT_GROUP,
			U.SIGNUP_DATE,
			CASE
				WHEN MIN(I.ISSUE_DATE) IS NOT NULL THEN 1
				ELSE 0
			END AS CREATED_INVOICE,
			CASE
				WHEN MIN(I.SENT_DATE) IS NOT NULL THEN 1
				ELSE 0
			END AS SENT_INVOICE,
			CASE
				WHEN MIN(I.PAID_DATE) IS NOT NULL THEN 1
				ELSE 0
			END AS GOT_PAID
		FROM
			USERS U
			LEFT JOIN INVOICES I ON U.USER_ID = I.USER_ID
		GROUP BY
			U.USER_ID,
			U.EXPERIMENT_GROUP,
			U.SIGNUP_DATE
	),
	UNPIVOTED_FINAL_FUNNEL AS (
		SELECT
			EXPERIMENT_GROUP,
			'created_invoice' AS FUNNEL_STAGE,
			1 AS SORT_ORDER,
			COUNT(*) AS USER_COUNT
		FROM
			BASE_FUNNEL
		WHERE
			CREATED_INVOICE = 1
		GROUP BY
			1
		UNION ALL
		SELECT
			EXPERIMENT_GROUP,
			'sent_invoice' AS FUNNEL_STAGE,
			2 AS SORT_ORDER,
			COUNT(*) AS USER_COUNT
		FROM
			BASE_FUNNEL
		WHERE
			SENT_INVOICE = 1
		GROUP BY
			1
		UNION ALL
		SELECT
			EXPERIMENT_GROUP,
			'got_paid' AS FUNNEL_STAGE,
			3 AS SORT_ORDER,
			COUNT(*) AS USER_COUNT
		FROM
			BASE_FUNNEL
		WHERE
			GOT_PAID = 1
		GROUP BY
			1
	)
SELECT
	EXPERIMENT_GROUP,
	FUNNEL_STAGE,
	USER_COUNT,
	USER_COUNT - LAG(USER_COUNT) OVER (
		PARTITION BY
			EXPERIMENT_GROUP
		ORDER BY
			SORT_ORDER
	) AS DROP_OFF,
	ROUND(
		100 * USER_COUNT / NULLIF(
			LAG(USER_COUNT) OVER (
				PARTITION BY
					EXPERIMENT_GROUP
				ORDER BY
					SORT_ORDER
			),
			0
		),
		1
	) AS CONVERSION_RATE
FROM
	UNPIVOTED_FINAL_FUNNEL
ORDER BY
	EXPERIMENT_GROUP