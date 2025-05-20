
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

