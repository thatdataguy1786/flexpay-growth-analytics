# 💰 Customer Lifetime Value (LTV) Models – FlexPay

This folder contains SQL models to calculate **historical Customer Lifetime Value (LTV)** for the FlexPay SaaS product using real payment behavior.

LTV tells us how much revenue a user has generated **to date**, and helps answer questions like:

> "Which channels and plans bring in the most valuable users?"

---

## 📦 Models Included

### 1. `ltv_by_channel.sql`

- Calculates average LTV per **acquisition channel** (e.g., Google Ads, Referral, Email)
- Joins `payments` to `users` using `user_id`
- Formula:  
  `LTV = Total Revenue per Channel / Unique Paying Users from that Channel`

### 2. `ltv_by_plan.sql`

- Calculates average LTV per **subscription plan** (Pro, Business, Free)
- Joins `payments` to `subscriptions` using `user_id`
- **Assumes a flat snapshot** — one row per user in `subscriptions`, reflecting their current or most recent plan
- Formula:  
  `LTV = Total Revenue per Plan / Unique Paying Users in that Plan`

---

## ⚠️ Assumptions & Limitations

- This is **historical LTV** based on actual payments — no predictive modeling.
- Plan attribution in `ltv_by_plan.sql` reflects a **flat subscription table**:
  - Revenue is attributed based on the **latest plan** for each user
  - Payments made before switching plans may be misattributed
- This approach is accurate enough for reporting, but not time-aware

📌 To improve this later, convert `subscriptions` into an **SCD Type 2 table** with `start_date` / `end_date` for each plan change.

---

## 🧠 Insights These Models Can Drive

- What channels bring in users who spend the most over time?
- Which plans retain high-value users?
- How does LTV vary by acquisition source?

---

> Built using PostgreSQL + FlexPay simulated dataset as part of a growth analytics portfolio.

