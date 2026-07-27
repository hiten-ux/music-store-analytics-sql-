USE music_db;

-- 1. Master invoice detail (drill‑down ready)
CREATE VIEW vw_invoice_detail AS
SELECT
    i.invoice_id,
    i.invoice_date,
    c.customer_id,
    c.first_name AS customer_first_name,
    c.last_name AS customer_last_name,
    c.country AS customer_country,
    c.support_rep_id,
    e.first_name AS rep_first_name,
    e.last_name AS rep_last_name,
    i.billing_country,
    i.total AS invoice_total,
    il.invoice_line_id,
    t.name AS track_name,
    t.unit_price AS track_unit_price,
    il.quantity,
    (il.unit_price * il.quantity) AS line_total,
    g.name AS genre_name,
    a.name AS artist_name,
    al.title AS album_title
FROM invoice i
JOIN customer c ON i.customer_id = c.customer_id
LEFT JOIN employee e ON c.support_rep_id = e.employee_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id;

-- 2. Monthly sales trend
CREATE VIEW vw_monthly_sales AS
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS yearmonth,
    COUNT(DISTINCT invoice_id) AS invoice_count,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_invoice_value,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM invoice
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY DATE_FORMAT(invoice_date, '%Y-%m');

-- 3. Revenue by genre (with percentage)
CREATE VIEW vw_sales_by_genre AS
SELECT
    g.name AS genre_name,
    COUNT(DISTINCT i.invoice_id) AS invoice_count,
    SUM(il.quantity) AS total_units_sold,
    SUM(il.unit_price * il.quantity) AS total_revenue,
    ROUND(SUM(il.unit_price * il.quantity) / (SELECT SUM(il2.unit_price * il2.quantity) FROM invoice_line il2) * 100, 2) AS revenue_percentage
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC;

-- 4. Revenue by country
CREATE VIEW vw_sales_by_country AS
SELECT
    billing_country,
    COUNT(DISTINCT invoice_id) AS invoice_count,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_invoice_value,
    COUNT(DISTINCT customer_id) AS customer_count
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

-- 5. Customer lifetime value (CLV) + recency
CREATE VIEW vw_customer_lifetime_value AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country,
    c.support_rep_id,
    COUNT(DISTINCT i.invoice_id) AS total_invoices,
    SUM(i.total) AS total_spent,
    AVG(i.total) AS avg_invoice,
    MAX(i.invoice_date) AS last_purchase_date,
    DATEDIFF(CURDATE(), MAX(i.invoice_date)) AS days_since_last_purchase,
    RANK() OVER (ORDER BY SUM(i.total) DESC) AS spending_rank
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country, c.support_rep_id
ORDER BY total_spent DESC;

-- 6. Top 10 customers
CREATE VIEW vw_top_customers AS
SELECT *
FROM vw_customer_lifetime_value
WHERE total_spent IS NOT NULL
ORDER BY total_spent DESC
LIMIT 10;

-- 7. Top tracks (revenue & quantity)
CREATE VIEW vw_top_tracks AS
SELECT
    t.track_id,
    t.name AS track_name,
    a.name AS artist_name,
    al.title AS album_title,
    g.name AS genre_name,
    COUNT(DISTINCT il.invoice_id) AS purchase_count,
    SUM(il.quantity) AS total_quantity_sold,
    SUM(il.unit_price * il.quantity) AS total_revenue,
    RANK() OVER (ORDER BY SUM(il.unit_price * il.quantity) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY SUM(il.quantity) DESC) AS quantity_rank
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY t.track_id, t.name, a.name, al.title, g.name
ORDER BY total_revenue DESC;

-- 8. Sales agent performance
CREATE VIEW vw_employee_performance AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.title,
    COUNT(DISTINCT c.customer_id) AS customers_served,
    COUNT(DISTINCT i.invoice_id) AS invoices_handled,
    SUM(i.total) AS total_revenue_generated,
    AVG(i.total) AS avg_invoice_value,
    RANK() OVER (ORDER BY SUM(i.total) DESC) AS revenue_rank
FROM employee e
LEFT JOIN customer c ON e.employee_id = c.support_rep_id
LEFT JOIN invoice i ON c.customer_id = i.customer_id
WHERE e.title LIKE '%Sales%'
GROUP BY e.employee_id, e.first_name, e.last_name, e.title
ORDER BY total_revenue_generated DESC;

-- 9. Daily revenue with rolling 7‑day average and cumulative sum
CREATE VIEW vw_sales_trend AS
SELECT
    invoice_date,
    total AS daily_revenue,
    SUM(total) OVER (ORDER BY invoice_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7_day_total,
    AVG(total) OVER (ORDER BY invoice_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7_day_avg,
    SUM(total) OVER (ORDER BY invoice_date) AS cumulative_revenue
FROM invoice
ORDER BY invoice_date;

-- 10. Album performance ranking
CREATE VIEW vw_album_performance AS
SELECT
    al.album_id,
    al.title AS album_title,
    a.name AS artist_name,
    COUNT(DISTINCT t.track_id) AS track_count,
    SUM(il.quantity) AS total_units_sold,
    SUM(il.unit_price * il.quantity) AS total_revenue,
    RANK() OVER (ORDER BY SUM(il.unit_price * il.quantity) DESC) AS revenue_rank
FROM album al
JOIN artist a ON al.artist_id = a.artist_id
LEFT JOIN track t ON al.album_id = t.album_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY al.album_id, al.title, a.name
ORDER BY total_revenue DESC;

-- 11. High‑level invoice summary (year/quarter/month)
CREATE VIEW vw_invoice_summary AS
SELECT
    YEAR(invoice_date) AS year,
    QUARTER(invoice_date) AS quarter,
    MONTH(invoice_date) AS month,
    COUNT(*) AS invoice_count,
    SUM(total) AS total_revenue,
    AVG(total) AS avg_revenue
FROM invoice
GROUP BY YEAR(invoice_date), QUARTER(invoice_date), MONTH(invoice_date)
ORDER BY year, quarter, month;

-- 12. Artist total revenue
CREATE VIEW vw_artist_revenue AS
SELECT
    a.artist_id,
    a.name AS artist_name,
    COUNT(DISTINCT al.album_id) AS album_count,
    SUM(il.quantity) AS total_units_sold,
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY a.artist_id, a.name
ORDER BY total_revenue DESC;


-- 13. Repeat Purchase Rate (overall and by country)
CREATE VIEW vw_repeat_purchase_rate AS
SELECT
    'Overall' AS segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT customer_id) * 100, 2) AS repeat_rate_percent
FROM (
    SELECT customer_id, COUNT(DISTINCT invoice_id) AS purchase_count
    FROM invoice
    GROUP BY customer_id
) AS customer_purchases

UNION ALL

SELECT
    country AS segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
    ROUND(SUM(CASE WHEN purchase_count > 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT customer_id) * 100, 2) AS repeat_rate_percent
FROM (
    SELECT c.country, c.customer_id, COUNT(DISTINCT i.invoice_id) AS purchase_count
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.country, c.customer_id
) AS country_purchases
GROUP BY country
ORDER BY repeat_rate_percent DESC;

-- 14. Customer Segmentation (RFM‑based: Recency, Frequency, Monetary)
CREATE VIEW vw_customer_segmentation AS
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        COUNT(DISTINCT i.invoice_id) AS frequency,
        SUM(i.total) AS monetary,
        DATEDIFF(CURDATE(), MAX(i.invoice_date)) AS recency_days,
        CASE
            WHEN COUNT(DISTINCT i.invoice_id) IS NULL THEN 'Inactive'
            WHEN COUNT(DISTINCT i.invoice_id) = 1 AND DATEDIFF(CURDATE(), MAX(i.invoice_date)) > 180 THEN 'Churned'
            WHEN COUNT(DISTINCT i.invoice_id) = 1 AND DATEDIFF(CURDATE(), MAX(i.invoice_date)) <= 180 THEN 'One‑Time Buyer'
            WHEN COUNT(DISTINCT i.invoice_id) BETWEEN 2 AND 5 THEN 'Regular'
            WHEN COUNT(DISTINCT i.invoice_id) > 5 THEN 'Loyal'
        END AS frequency_segment,
        CASE
            WHEN SUM(i.total) IS NULL THEN 'None'
            WHEN SUM(i.total) < 50 THEN 'Low Spender'
            WHEN SUM(i.total) BETWEEN 50 AND 150 THEN 'Medium Spender'
            ELSE 'High Spender'
        END AS monetary_segment
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT
    customer_id,
    first_name,
    last_name,
    country,
    frequency,
    monetary,
    recency_days,
    CONCAT(frequency_segment, ' / ', monetary_segment) AS customer_segment
FROM customer_metrics
ORDER BY monetary DESC;

-- 15. Sales by Media Type
CREATE VIEW vw_sales_by_media_type AS
SELECT
    mt.name AS media_type_name,
    COUNT(DISTINCT i.invoice_id) AS invoice_count,
    SUM(il.quantity) AS total_units_sold,
    SUM(il.unit_price * il.quantity) AS total_revenue,
    ROUND(SUM(il.unit_price * il.quantity) / (SELECT SUM(il2.unit_price * il2.quantity) FROM invoice_line il2) * 100, 2) AS revenue_percentage
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY mt.media_type_id, mt.name
ORDER BY total_revenue DESC;

-- 16. Monthly New Customers (acquisition)
CREATE VIEW vw_monthly_new_customers AS
WITH first_purchase AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_purchase_date
    FROM invoice
    GROUP BY customer_id
)
SELECT
    DATE_FORMAT(first_purchase_date, '%Y-%m') AS acquisition_month,
    COUNT(customer_id) AS new_customers
FROM first_purchase
GROUP BY DATE_FORMAT(first_purchase_date, '%Y-%m')
ORDER BY acquisition_month;

-- 17. Customer Churn Risk (customers with no purchase in last 90 days)
CREATE VIEW vw_churn_risk AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.country,
    MAX(i.invoice_date) AS last_purchase_date,
    DATEDIFF(CURDATE(), MAX(i.invoice_date)) AS days_since_last_purchase,
    CASE
        WHEN MAX(i.invoice_date) IS NULL THEN 'Never Purchased'
        WHEN DATEDIFF(CURDATE(), MAX(i.invoice_date)) > 180 THEN 'High Risk (6+ months)'
        WHEN DATEDIFF(CURDATE(), MAX(i.invoice_date)) > 90 THEN 'Medium Risk (3‑6 months)'
        ELSE 'Low Risk (0‑3 months)'
    END AS churn_risk_level
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY days_since_last_purchase DESC;

-- 18. Repeat Purchase Analysis by Genre (to see which genres drive repeat purchases)
CREATE VIEW vw_repeat_genre_analysis AS
SELECT
    g.name AS genre_name,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(DISTINCT i.invoice_id) AS total_invoices,
    ROUND(COUNT(DISTINCT i.invoice_id) / COUNT(DISTINCT c.customer_id), 2) AS avg_invoices_per_customer,
    SUM(il.quantity) AS units_sold
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.genre_id, g.name
ORDER BY avg_invoices_per_customer DESC;






#Quick Queries to get immediate insights:
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










