# 📊 Churn Modeling – FlexPay Analytics

This directory contains SQL models for identifying churn in FlexPay, a simulated fintech SaaS product. Three churn types are covered, each with its own logic and use case.

---

## 🔄 1️⃣ Invoice Churn

### 📘 Definition
A user is considered "churned" if they previously paid a recurring invoice but has not paid one in the last 60 days.

### 📈 Business Value
- Tracks revenue loss due to non-payment of recurring invoices.
- Useful for reactivation campaigns and forecasting cash flow issues.

### 🧠 Key Logic
- Filter `invoices` for `invoice_type = 'recurring'` and `status = 'Paid'`.
- Get the latest `paid_date` per user.
- Classify users as 'churned' if last paid date > 60 days ago.

---

## 💸 2️⃣ Payment Churn

### 📘 Definition
A user is considered "churned" if they have not made any payment in the last 60 days.

### 📈 Business Value
- Tracks cash flow churn directly.
- Supports financial reporting and retention analysis.

### 🧠 Key Logic
- Filter `payments` table for valid (non-zero) payments.
- Get the latest `payment_date` per user.
- Classify users as 'churned' if last payment > 60 days ago.

---

## 📉 3️⃣ Engagement Churn

### 📘 Definition
A user is considered "churned" if they have not engaged with FlexPay (sent or paid an invoice) in the last 60 days.

### 📈 Business Value
- Captures product engagement drop-off before cash flow churn.
- Supports early intervention, feature usage analysis, and marketing campaigns.

### 🧠 Key Logic
- Use `invoices` table:
  - `sent_date` to track invoice creation.
  - `paid_date` to track invoice payment.
- Get the latest engagement date using:
MAX(COALESCE(paid_date, sent_date))

- Classify users as 'churned' if latest engagement > 60 days ago.

---

## ⚠️ Notes and Assumptions
- The models assume accurate `paid_date`, `sent_date`, and `payment_date` values.
- Engagement churn does not track logins or other in-app actions due to data limitations.
- Invoice and Payment churn do not track failed payments or overdue invoices.

---

## 📂 Models Included
- `invoice_churn_model.sql`
- `payment_churn_model.sql`
- `engagement_churn_model.sql`

---

> Built for FlexPay simulated data; real production data may require adjustments.

