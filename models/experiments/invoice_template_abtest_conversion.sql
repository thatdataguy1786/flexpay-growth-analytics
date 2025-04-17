-- invoice_template_abtest_conversion.sql
-- ---------------------------------------------------------------
-- 🧪 A/B Test Analysis: Invoice Template Conversion Rate (FlexPay)
-- ---------------------------------------------------------------
-- Goal:
-- Evaluate whether Template B results in a higher invoice-to-payment conversion rate than Template A.

-- Metric:
-- Conversion Rate = (# Paid Invoices) / (Total Invoices Sent)
-- Grouped by: invoice_template ('Template A' vs 'Template B')

-- Tables Used:
-- - invoices: invoice_id, user_id, invoice_template, sent_date
-- - payments: invoice_id, payment_date

-- Logic:
-- 1. Filter to invoices using 'Template A' or 'Template B'
-- 2. Join with payments table to identify paid invoices
-- 3. Label each invoice as paid (1) or unpaid (0)
-- 4. Aggregate by template: total invoices, paid invoices, conversion rate

-- Note:
-- You can export the output of this query and calculate Z-test p-value using Excel or Python (scipy.stats.proportions_ztest)
-- Optionally, calculate 95% Confidence Intervals in SQL if needed for visualization or dashboarding.

WITH base_invoices AS (
  SELECT
    invoice_id,
    invoice_template,
    sent_date
  FROM invoices
  WHERE invoice_template IN ('Template A', 'Template B')
    AND sent_date IS NOT NULL
),

paid_invoices AS (
  SELECT DISTINCT invoice_id
  FROM payments
  WHERE payment_date IS NOT NULL
),

labeled AS (
  SELECT
    b.invoice_template,
    b.invoice_id,
    CASE WHEN p.invoice_id IS NOT NULL THEN 1 ELSE 0 END AS is_paid
  FROM base_invoices b
  LEFT JOIN paid_invoices p ON b.invoice_id = p.invoice_id
)

SELECT
  invoice_template,
  COUNT(*) AS total_invoices,
  SUM(is_paid) AS paid_invoices,
  ROUND(SUM(is_paid) * 1.0 / COUNT(*), 4) AS conversion_rate
FROM labeled
GROUP BY invoice_template
ORDER BY invoice_template;
