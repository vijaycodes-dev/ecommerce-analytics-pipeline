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
