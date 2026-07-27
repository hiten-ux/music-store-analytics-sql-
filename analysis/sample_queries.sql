-- =====================================================
-- SAMPLE QUERIES – MUSIC STORE ANALYTICS


-- =====================================================
-- ⚡ QUICK BUSINESS INSIGHTS (Run these first!)
-- =====================================================
-- These queries answer the most important business questions
-- =====================================================

-- 1. What are our top 10 tracks by revenue?
SELECT track_name, artist_name, album_title, total_revenue, revenue_rank
FROM vw_top_tracks
WHERE revenue_rank <= 10;

-- 2. Which countries have the highest repeat purchase rate?
SELECT segment, repeat_rate_percent
FROM vw_repeat_purchase_rate
WHERE segment != 'Overall'
ORDER BY repeat_rate_percent DESC;

-- 3. Who are our high‑risk customers (no purchase in last 6 months)?
SELECT customer_id, first_name, last_name, country, days_since_last_purchase
FROM vw_churn_risk
WHERE churn_risk_level = 'High Risk (6+ months)'
ORDER BY days_since_last_purchase DESC;

-- 4. Monthly revenue and new customers trend
SELECT
    a.year_month,
    a.total_revenue,
    b.new_customers
FROM vw_monthly_sales a
LEFT JOIN vw_monthly_new_customers b ON a.year_month = b.acquisition_month
ORDER BY a.year_month;

-- 5. Sales agent performance ranking
SELECT first_name, last_name, customers_served, total_revenue_generated, revenue_rank
FROM vw_employee_performance
ORDER BY revenue_rank;

-- 6. Which genres keep customers coming back?
SELECT genre_name, avg_invoices_per_customer
FROM vw_repeat_genre_analysis
ORDER BY avg_invoices_per_customer DESC
LIMIT 5;

-- 7. Executive KPI Dashboard Summary
SELECT 'Total Revenue' AS KPI, CONCAT('$', FORMAT(SUM(total), 2)) AS Value FROM invoice
UNION ALL
SELECT 'Total Customers', FORMAT(COUNT(*), 0) FROM customer
UNION ALL
SELECT 'Total Invoices', FORMAT(COUNT(*), 0) FROM invoice
UNION ALL
SELECT 'Avg Invoice', CONCAT('$', FORMAT(AVG(total), 2)) FROM invoice
UNION ALL
SELECT 'Repeat Rate', CONCAT(FORMAT(
    (SELECT COUNT(DISTINCT customer_id) FROM invoice GROUP BY customer_id HAVING COUNT(*) > 1) 
    / (SELECT COUNT(DISTINCT customer_id) FROM customer) * 100, 1), '%')
UNION ALL
SELECT 'High Risk Customers', FORMAT(COUNT(*), 0) FROM vw_churn_risk
WHERE churn_risk_level = 'High Risk (6+ months)';

-- =====================================================
-- 📊 COMPLETE VIEW REFERENCE (All 18 Views)
-- =====================================================
-- Below are sample queries for each of the 18 views
-- =====================================================

-- 1. vw_monthly_sales – Revenue Trend Over Time
-- Business Question: How is revenue performing month over month?
SELECT * FROM vw_monthly_sales
ORDER BY year_month DESC
LIMIT 12;

-- 2. vw_sales_by_genre – Genre Performance
-- Business Question: Which genres drive the most revenue?
SELECT genre_name, total_revenue, revenue_percentage, total_units_sold
FROM vw_sales_by_genre
ORDER BY total_revenue DESC;

-- 3. vw_top_tracks – Best‑Selling Tracks (Detailed)
-- Business Question: Which tracks generate the most revenue and sales?
SELECT track_name, artist_name, genre_name, total_revenue, revenue_rank, quantity_rank
FROM vw_top_tracks
WHERE revenue_rank <= 10
ORDER BY revenue_rank;

-- 4. vw_top_customers – Top 10 VIP Customers
-- Business Question: Who are our top 10 customers by lifetime spend?
SELECT customer_id, first_name, last_name, country, total_spent, total_invoices, days_since_last_purchase
FROM vw_top_customers;

-- 5. vw_customer_segmentation – Customer Segment Distribution
-- Business Question: How are our customers distributed across segments?
SELECT customer_segment, COUNT(*) AS customer_count
FROM vw_customer_segmentation
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- 6. vw_churn_risk – High‑Risk Customers (Full List)
-- Business Question: Which customers are at risk of churning?
SELECT customer_id, first_name, last_name, country, days_since_last_purchase
FROM vw_churn_risk
WHERE churn_risk_level = 'High Risk (6+ months)'
ORDER BY days_since_last_purchase DESC;

-- 7. vw_repeat_purchase_rate – Repeat Purchase Rate (All Countries)
-- Business Question: What percentage of customers make repeat purchases?
SELECT * FROM vw_repeat_purchase_rate
ORDER BY repeat_rate_percent DESC;

-- 8. vw_employee_performance – Sales Agent Performance (All Agents)
-- Business Question: Which sales agents are generating the most revenue?
SELECT first_name, last_name, customers_served, total_revenue_generated, revenue_rank
FROM vw_employee_performance
ORDER BY revenue_rank;

-- 9. vw_album_performance – Top Albums by Revenue
-- Business Question: Which albums generate the most revenue?
SELECT album_title, artist_name, total_revenue, revenue_rank
FROM vw_album_performance
WHERE revenue_rank <= 10
ORDER BY revenue_rank;

-- 10. vw_artist_revenue – Artist Revenue Ranking
-- Business Question: Which artists generate the most revenue?
SELECT artist_name, total_revenue, total_units_sold, album_count
FROM vw_artist_revenue
ORDER BY total_revenue DESC
LIMIT 10;

-- 11. vw_sales_by_country – Geographic Revenue Distribution
-- Business Question: Which countries are our best‑performing markets?
SELECT billing_country, total_revenue, customer_count, invoice_count
FROM vw_sales_by_country
ORDER BY total_revenue DESC;

-- 12. vw_sales_trend – Daily Sales with Rolling Averages
-- Business Question: How is revenue trending day by day?
SELECT invoice_date, daily_revenue, rolling_7_day_avg, cumulative_revenue
FROM vw_sales_trend
ORDER BY invoice_date DESC
LIMIT 30;

-- 13. vw_sales_by_media_type – Revenue by Media Format
-- Business Question: Which media formats are most popular?
SELECT media_type_name, total_revenue, revenue_percentage
FROM vw_sales_by_media_type
ORDER BY total_revenue DESC;

-- 14. vw_monthly_new_customers – New Customer Acquisition
-- Business Question: How many new customers are we acquiring each month?
SELECT * FROM vw_monthly_new_customers
ORDER BY acquisition_month DESC;

-- 15. vw_repeat_genre_analysis – Genre Loyalty Analysis
-- Business Question: Which genres have the most loyal customers?
SELECT genre_name, total_customers, avg_invoices_per_customer
FROM vw_repeat_genre_analysis
ORDER BY avg_invoices_per_customer DESC;

-- 16. vw_invoice_summary – High‑Level Invoice Summary
-- Business Question: What are revenue and invoice metrics by year, quarter, month?
SELECT year, quarter, month, invoice_count, total_revenue, avg_revenue
FROM vw_invoice_summary
ORDER BY year DESC, quarter DESC, month DESC;

-- 17. vw_invoice_detail – Master Invoice Detail (Sample)
-- Business Question: What is the complete picture of every sale?
SELECT invoice_id, customer_first_name, customer_last_name, track_name, genre_name, line_total
FROM vw_invoice_detail
ORDER BY invoice_date DESC
LIMIT 20;

-- 18. vw_customer_lifetime_value – Detailed Customer Lifetime Value
-- Business Question: Who are our most valuable customers, and when did they last purchase?
SELECT customer_id, first_name, last_name, country, total_spent, total_invoices, days_since_last_purchase, spending_rank
FROM vw_customer_lifetime_value
WHERE total_spent IS NOT NULL
ORDER BY spending_rank
LIMIT 20;
