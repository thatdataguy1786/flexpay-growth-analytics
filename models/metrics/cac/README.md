# 📊 FlexPay Growth Analytics – CAC Models

This folder contains SQL models that calculate **Customer Acquisition Cost (CAC)** for a simulated SaaS product called **FlexPay**. FlexPay is a mobile-first invoicing and payments platform for freelancers and SMBs.

These models help measure the **cost-efficiency of different marketing efforts**, using accurate user-to-campaign attribution via `campaign_id`.

---

## 📌 What is CAC?

**Customer Acquisition Cost (CAC)** is the average amount spent on marketing to acquire one user (or paying user). It is critical for understanding **marketing efficiency**, **budget allocation**, and **scalability** of acquisition channels.

**Formula:**  
CAC = Total Ad Spend / Number of Users Acquired


---

## 📁 SQL Models Included

### 1. `cac_by_channel.sql`

- Calculates CAC per **marketing channel** (e.g., Google Ads, Email, Affiliates)
- Joins `users` to `marketing_campaigns` via `campaign_id`
- Uses `DISTINCT` on `user_id` to avoid double counting
- Uses `NULLIF` to prevent divide-by-zero errors

### 2. `cac_by_campaign.sql`

- Provides CAC per **individual marketing campaign**
- Uses a `LEFT JOIN` to include campaigns with **zero conversions**
- Useful for understanding which campaigns had poor or strong performance

### 3. `cac_paying_users.sql`

- Calculates CAC using **only users who converted to paid plans**
- Filters `subscriptions` for active paid tiers (`Pro`, `Business`)
- Offers a more realistic view of cost per monetized user

---

## 🧠 Insights These Models Enable

- Which channels bring in the **cheapest users**?
- Which campaigns are **wasting spend** with low conversions?
- What’s the **true CAC** when only counting **paying customers**?
- Are we getting ROI from **Google Ads vs Email**?

---

## 🔧 Schema Assumptions

- `users` table includes `campaign_id` for attribution
- `subscriptions` table has `plan_type` and `is_active` to filter paying users
- `marketing_campaigns` includes `channel`, `campaign_name`, and `ad_spend`

---

## 📍 Next Steps

- Model LTV, MRR, and Churn using connected payment + subscription tables
- Visualize CAC trends and outliers using Tableau or Python (optional)
- Build LTV:CAC ratio reports for acquisition ROI

---

> Built with 💡 using SQL + FlexPay simulated dataset.

