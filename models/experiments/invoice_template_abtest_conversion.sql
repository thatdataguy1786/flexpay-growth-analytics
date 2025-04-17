-- invoice_template_abtest_conversion.sql
-- ---------------------------------------------------------------
-- 🧪 A/B Test Analysis: Invoice Template Conversion Rate (FlexPay)
-- ---------------------------------------------------------------
-- Goal:
## 📄 A/B Test – Conversion Rate by Invoice Template

**Objective**:  
Evaluate whether Template B led to a higher conversion rate (i.e. invoices getting paid) compared to Template A.

**Metric Tracked**:  
- Invoice-to-payment conversion rate  
  (i.e. What % of invoices were paid for each template)

**Statistical Test Used**:  
✅ 2-Proportion Z-Test  
(`statsmodels.stats.proportion.proportions_ztest` in Python)

**Results**:
- Template classic Paid: 324 / 506
- Template modern Paid: 319 / 512
- P-Value: 0.5679 → ❌ Not statistically significant

**Interpretation**:  
There is no statistically significant difference in paid conversion between the two templates. We **cannot conclude** Template B improves payment likelihood.

**Recommendation**:  
- Gather more data or test additional variants
- Consider evaluating other metrics (e.g. time to payment, satisfaction)


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
