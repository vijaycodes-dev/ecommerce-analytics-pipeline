-- ===================================
-- E-commerce Analytics Queries
-- ===================================

-- Total Orders
SELECT COUNT(*)
FROM orders;

-- Total Customers
SELECT COUNT(*)
FROM customers;

-- Orders by Status
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Orders by State
SELECT
    c.customer_state,
    COUNT(*) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- Total order_items
SELECT COUNT(*)
FROM order_items;


SELECT COUNT(*)
FROM products;
SELECT *
FROM products;


SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'products'
ORDER BY ordinal_position;


-- Which product categories sell the most?
SELECT
    p.product_category_name,
    COUNT(*) AS total_items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC
LIMIT 10;

-- Revenue by State

SELECT
    c.customer_state,
    SUM(oi.price) AS revenue
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- Monthly Revenue Trend 
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    SUM(oi.price) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;


-- Average Order Value
SELECT
    ROUND(AVG(order_total), 2) AS avg_order_value
FROM (
    SELECT
        order_id,
        SUM(price) AS order_total
    FROM order_items
    GROUP BY order_id
) t;


-- Delivery Time Analysis
SELECT
    AVG(
        order_delivered_customer_date
        - order_purchase_timestamp
    ) AS avg_delivery_time
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


SELECT * FROM payments;
SELECT * FROM geolocation;


-- Total Revenue
SELECT
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;


--Monthly Revenue
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;


-- Top Product Categories
SELECT
    ct.product_category_name_english,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name =
       ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY items_sold DESC
LIMIT 10;



-- Revenue by State
SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- Average Review Score
SELECT
    AVG(review_score) AS avg_rating
FROM reviews;










-- 1. Total Revenue
SELECT
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;

-- 2. Revenue by Month
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

This is ideal for a Power BI line chart.

-- 3. Revenue by State

SELECT
    c.customer_state,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- Useful for a map or bar chart.
------------------------------------------------------------------------------------
-- 4. Top 10 Product Categories
-- Using English category names:

SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name =
       ct.product_category_name
GROUP BY category
ORDER BY items_sold DESC
LIMIT 10;

------------------------------------------------------------
-- 5. Top 10 Sellers by Revenue

SELECT
    s.seller_id,
    s.seller_state,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM sellers s
JOIN order_items oi
    ON s.seller_id = oi.seller_id
JOIN payments p
    ON oi.order_id = p.order_id
GROUP BY
    s.seller_id,
    s.seller_state
ORDER BY revenue DESC
LIMIT 10;

=--------------------------------------------------------------------------------------------------------------------------------------------------------
6. Average Review Score by Category
SELECT
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS category,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM reviews r
JOIN orders o
    ON r.order_id = o.order_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name =
       ct.product_category_name
GROUP BY category
ORDER BY avg_review_score DESC;

----------------------------------------------------------------------------------------------
-- 7. Delivery Time Analysis

SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        ),
        2
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- Delivery by state:

SELECT
    c.customer_state,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    o.order_delivered_customer_date
                    - o.order_purchase_timestamp
                )
            ) / 86400
        ),
        2
    ) AS avg_delivery_days
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;


--------------------------------------------------------------------------------------------------

8. Customer Distribution Map using Geolocation

SELECT
    g.latitude,
    g.longitude,
    COUNT(*) AS customer_count
FROM customers c
JOIN geolocation_unique g
    ON c.customer_zip_code_prefix =
       g.geolocation_zip_code_prefix
GROUP BY
    g.latitude,
    g.longitude;

-- For state-wise distribution:

SELECT
    customer_state,
    COUNT(*) AS customers
FROM customers
GROUP BY customer_state
ORDER BY customers DESC;
