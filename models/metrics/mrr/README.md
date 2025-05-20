
# 📊 Monthly Recurring Revenue (MRR) – Conceptual SCD-Based Model

This SQL model calculates Monthly Recurring Revenue (MRR) using the **assumption** that the `subscriptions` table follows a **Slowly Changing Dimension (SCD Type 2)** structure. While the actual dataset uses a flat snapshot (one row per user), this model was written to reflect **best practices** in real-world SaaS analytics.

---

## ✅ Model Objective

> To calculate total MRR, active users, and ARPU per month by joining a monthly calendar with time-aware subscription data and plan pricing rules.

---

## 🧠 Core Logic

### Step-by-step breakdown:

1. **`calendar_months`**  
   Generates a list of monthly periods between `2024-01-01` and `2025-12-01` using `generate_series()`.

2. **`active_user_months`**  
   Performs a `CROSS JOIN` between calendar months and all subscription rows. Filters rows where the user was active in that month using:
WHERE month_start BETWEEN s.start_date AND COALESCE(s.end_date, CURRENT_DATE)
3. **`plan_prices`**  
Simulates a lookup table for monthly plan pricing:
- Free: $0
- Pro: $200
- Business: $400

4. **`semi`**  
Joins plan prices to the monthly active user set, assigning each user their corresponding `monthly_mrr`.

5. **Final SELECT**  
Aggregates data by `month_start` to calculate:
- `total_users`
- `total_monthly_mrr`
- `ARPU_month` (Average Revenue per User)

---

## 📎 Sample Output

| month_start | total_users | total_monthly_mrr | arpu_month |
|-------------|-------------|-------------------|------------|
| 2024-01-01  | 89          | 18,400            | 206.74     |
| 2024-02-01  | 104         | 22,000            | 211.54     |

---

## ⚠️ Assumptions

- The `subscriptions` table is modeled as an **SCD Type 2** table (one row per plan period).
- `end_date` is `NULL` if a plan is still active.
- Plan prices are **hardcoded** for this model and may not reflect actual monetization logic.
- The current dataset is **flat**, so this model is **conceptual** and may not produce results until the schema is adapted.

---

## 🧠 Why This Matters

In a real SaaS environment, this model would support:

- Revenue forecasting
- Retention and churn analysis
- Upgrade/downgrade detection
- Accurate LTV:CAC reporting

---

> This conceptual model demonstrates SQL modeling for time-aware billing analytics, even when real data constraints exist.

