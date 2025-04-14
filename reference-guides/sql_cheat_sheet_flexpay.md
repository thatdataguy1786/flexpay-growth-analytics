
# 📘 FlexPay SQL Cheat Sheet
Your personal reference guide for all key SQL patterns, tied to real-world SaaS analytics.

---

## 🧱 Basic Syntax Blocks

### ✅ Common Clauses
```sql
SELECT column1, column2
FROM table_name
WHERE condition
GROUP BY column
HAVING COUNT(*) > 1
ORDER BY column DESC;
```

### ✅ JOIN Logic
```sql
-- Get all users and their invoices (even if no invoices)
SELECT u.user_id, i.invoice_id
FROM users u
LEFT JOIN invoices i ON u.user_id = i.user_id;
```

---

## 🧠 Window Functions

### 🎯 RANKING by Channel
```sql
RANK() OVER (ORDER BY SUM(amount) DESC) AS channel_rank
```

### 🧮 Running Total of Revenue
```sql
SUM(amount) OVER (
  ORDER BY payment_date
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS running_revenue
```

### 🔮 Future Lifetime Value
```sql
SUM(amount) OVER (
  PARTITION BY user_id
  ORDER BY payment_date
  ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
) AS future_ltv
```

---

## 🧩 Conditional Logic

### 🧠 CASE WHEN Example
```sql
CASE 
  WHEN amount >= 1000 THEN 'High'
  WHEN amount >= 500 THEN 'Medium'
  ELSE 'Low'
END AS invoice_segment
```

### 🎯 Churn Flag
```sql
CASE 
  WHEN last_active_date < CURRENT_DATE - INTERVAL '30 days' THEN 1
  ELSE 0
END AS is_churned
```

---

## 🔁 CTEs for Multi-Step Logic

### 💡 Highest Invoice Per User
```sql
WITH ranked AS (
  SELECT *,
    RANK() OVER (PARTITION BY user_id ORDER BY amount DESC) AS rank
  FROM invoices
)
SELECT * FROM ranked WHERE rank = 1;
```

---

## 📊 Funnel + A/B Test Examples

### 🔬 Base Funnel CTE
```sql
WITH base_funnel AS (
  SELECT
    u.user_id,
    u.experiment_group,
    CASE WHEN MIN(i.issue_date) IS NOT NULL THEN 1 ELSE 0 END AS created_invoice,
    CASE WHEN MIN(i.sent_date) IS NOT NULL THEN 1 ELSE 0 END AS sent_invoice,
    CASE WHEN MIN(i.paid_date) IS NOT NULL THEN 1 ELSE 0 END AS got_paid
  FROM users u
  LEFT JOIN invoices i ON u.user_id = i.user_id
  GROUP BY u.user_id, u.experiment_group
)
```

---

## 📆 Date Calculations

### 📅 Last 7 Days Revenue (Correlated Subquery)
```sql
SELECT
  dr1.payment_date,
  (
    SELECT SUM(daily_total)
    FROM daily_revenue dr2
    WHERE dr2.payment_date BETWEEN dr1.payment_date - INTERVAL '6 days' AND dr1.payment_date
  ) AS rolling_7_day_sum
FROM daily_revenue dr1
```

---

## ✅ QUALIFY Statement

### 🔍 Use After Window Functions
```sql
SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY payment_date DESC) AS rn
  FROM payments
) t
QUALIFY rn = 1;
```

---

_Last updated: SQL Hour 8_
