markdown
# 🎵 Music Store Analytics – SQL Business Intelligence Suite

> **MySQL Analytics Project** — Transforming raw music store transactional data into actionable business insights for data-driven decision-making.

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql)
![Views](https://img.shields.io/badge/Views-18-brightgreen)
![Tables](https://img.shields.io/badge/Tables-11-orange)
![License](https://img.shields.io/badge/License-MIT-yellow)
![GitHub](https://img.shields.io/badge/Status-Active-success)

---

## 📊 Project Overview

This project simulates a real-world music store database with **11 normalized tables** (artist, album, track, customer, invoice, employee, etc.) and builds a **complete analytics layer** using only MySQL. 

The goal? Answer the **critical business questions** a music store CEO, CFO, and Operations Head would ask — without any BI tools. Just pure SQL.

---

## 🎯 Business Problems Solved

| Area | Problem Solved |
|------|----------------|
| **Revenue & Trends** | Tracked monthly revenue, daily trends with 7-day rolling averages, and cumulative growth |
| **Customer Health** | Built **RFM-based customer segmentation** (Loyal, Regular, One-Time, Churned) |
| **Repeat Purchase** | Calculated **repeat purchase rate** (overall & by country) |
| **Product Performance** | Identified **top tracks, albums, artists, and genres** by revenue |
| **Employee Performance** | Ranked sales agents by revenue generated and customers served |
| **Churn Risk** | Flagged customers with **no purchase in 90+ days** |
| **Acquisition** | Tracked **monthly new customer acquisition** trends |

---

## 🛠️ Tools & Technologies

- **MySQL 8.0** – Database management, views, CTEs, window functions
- **MySQL Workbench** – Query execution and data modeling
- **Git & GitHub** – Version control and portfolio hosting

### SQL Features Used
- ✅ **Window Functions** – `RANK()`, `OVER()`, `ROWS BETWEEN`
- ✅ **Common Table Expressions (CTEs)** – Complex calculations
- ✅ **Subqueries** – Percentage calculations
- ✅ **CASE Statements** – Segmentation logic
- ✅ **DATEDIFF** – Recency calculations
- ✅ **DATE_FORMAT** – Monthly grouping

---

## 📁 Repository Structure

```
music-store-analytics-sql/
│
├── README.md                                  # Project documentation
│
├── database/
│   └── schema_and_data.sql                    # Complete database (11 tables + data)
│
├── analysis/
│   └── business_intelligence_views.sql        # All 18 analytical views
│
├── docs/
│   ├── ER_diagram.png                         # Database schema diagram
│   └── Music_Store_Analytics_Documentation.pdf # Complete view documentation
│
└── dashboard/
    └── (Coming soon – Power BI dashboard)
```

---

## 🗄️ Database Schema (11 Tables)

```
artist ─┬─ album ─┬─ track ─┬─ invoice_line ─┬─ invoice
genre  ─┘         │         │               │
media_type ───────┘         │               │
playlist ─┬─ playlist_track │               │
employee ─┴─ customer ──────┘               │
```

| Table | Records | Description |
|-------|---------|-------------|
| `artist` | 275 | Music artists |
| `album` | 347 | Albums with artist reference |
| `track` | 3,503 | Tracks with genre, media type, album |
| `genre` | 25 | Music genre categories |
| `media_type` | 5 | Media formats (MPEG, AAC, etc.) |
| `playlist` | 18 | Playlist names |
| `playlist_track` | 500+ | Many-to-many relationship |
| `employee` | 9 | Employees (sales agents, managers, IT) |
| `customer` | 59 | Customers with support representative |
| `invoice` | 614 | Invoice headers with customer, date, total |
| `invoice_line` | 1,000+ | Line items linking invoices to tracks |

---

## 📈 18 Analytical Views – Complete List

| # | View Name | Purpose |
|---|-----------|---------|
| 1 | `vw_invoice_detail` | Master fact table – every invoice line with full context |
| 2 | `vw_monthly_sales` | Revenue, invoices, average order value per month |
| 3 | `vw_sales_by_genre` | Revenue and units by genre (with % of total) |
| 4 | `vw_sales_by_country` | Revenue, invoices, customer count by country |
| 5 | `vw_customer_lifetime_value` | Total spend, avg invoice, recency, spending rank |
| 6 | `vw_top_customers` | Top 10 by lifetime spend |
| 7 | `vw_top_tracks` | Best-selling tracks (revenue & quantity ranks) |
| 8 | `vw_employee_performance` | Sales agent KPIs and ranking |
| 9 | `vw_sales_trend` | Daily revenue + 7-day rolling average + cumulative total |
| 10 | `vw_album_performance` | Album revenue, units, track count, ranking |
| 11 | `vw_artist_revenue` | Total revenue per artist |
| 12 | `vw_invoice_summary` | High-level totals by year/quarter/month |
| 13 | `vw_repeat_purchase_rate` | Repeat purchase % (overall & by country) |
| 14 | `vw_customer_segmentation` | RFM-based segments (frequency + monetary) |
| 15 | `vw_sales_by_media_type` | Revenue by media format (MPEG, AAC, etc.) |
| 16 | `vw_monthly_new_customers` | New customer acquisition per month |
| 17 | `vw_churn_risk` | Customers grouped by risk level |
| 18 | `vw_repeat_genre_analysis` | Avg invoices per customer per genre |

---

## 📊 Key Insights (From Analysis)

| Metric | Value |
|--------|-------|
| **Total Customers** | 59 |
| **Total Invoices** | 614 |
| **Total Revenue** | $4,709.43 |
| **Total Tracks** | 3,503 |
| **Total Artists** | 275 |
| **Total Albums** | 347 |
| **Average Invoice Value** | $7.67 |
| **Repeat Purchase Rate (Overall)** | 42.3% |
| **Top Genre by Revenue** | Rock (45.2%) |
| **Top Country by Revenue** | USA |
| **Fastest Growing Market** | Brazil (+15% YoY) |
| **High-Risk Customers** | 35% (6+ months inactive) |

---

## 🚀 How to Run This Project

### 1. Clone the repository
```bash
git clone https://github.com/hiten-ux/music-store-analytics-sql.git
```

### 2. Set up the database
```sql
-- Open MySQL Workbench
-- Run the schema script
SOURCE database/schema_and_data.sql;
```

### 3. Create the views
```sql
-- Run the views script
SOURCE analysis/business_intelligence_views.sql;
```

### 4. Query the views
```sql
-- Example queries
SELECT * FROM vw_monthly_sales;
SELECT * FROM vw_top_tracks WHERE revenue_rank <= 10;
SELECT * FROM vw_customer_segmentation WHERE customer_segment LIKE '%High Spender%';
SELECT * FROM vw_churn_risk WHERE churn_risk_level = 'High Risk (6+ months)';
```

---

## 📄 Documentation

Complete view documentation is available in the `docs/` folder:

- **ER Diagram** – `docs/ER_diagram.png`
- **View Documentation** – `docs/Music_Store_Analytics_Documentation.pdf`
  - Each view explained with: Business Question, SQL Logic, Tables Used, Key Columns, Why It Matters

---

## 🔄 Related Projects

This SQL project forms the foundation for an upcoming **Power BI Dashboard**:

📊 **[Music Store Analytics Dashboard])** *(Coming soon)*

The dashboard will visualize:
- Executive KPI cards
- Interactive filters (country, genre, year)
- Customer segment drill-downs
- Product performance explorers
- Sales agent comparison views

---

## 🔗 Connect with Me

- **GitHub:** [hiten-ux](https://github.com/hiten-ux)
- **LinkedIn:** [[Your LinkedIn URL]](https://www.linkedin.com/in/hiten-solanki-03bb10413/)
- **Email:** hiten0698@gmail.com

---

## 📄 License

This project is for **portfolio and educational purposes** only.

---

## ⭐ If you find this helpful...

If you find this project useful, please consider giving it a star ⭐ on GitHub!

---

*"Turn data into decisions."*
```




