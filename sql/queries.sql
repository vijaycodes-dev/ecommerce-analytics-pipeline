-- ===================================
-- E-commerce Analytics Queries
-- ===================================

-- ===================================
-- Basic Statistics
-- ===================================

-- Total Orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Total Customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Total Order Items
SELECT COUNT(*) AS total_order_items
FROM order_items;

-- Total Products
SELECT COUNT(*) AS total_products
FROM products;

-- ===================================
-- Order Analytics
-- ===================================

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

-- ===================================
-- Revenue Analytics
-- ===================================

-- Total Revenue
SELECT
ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments;

-- Revenue by Month
SELECT
DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
ROUND(SUM(p.payment_value), 2) AS revenue
FROM orders o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

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

-- ===================================
-- Product Analytics
-- ===================================

-- Top 10 Product Categories
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

-- Top 10 Sellers by Revenue
SELECT
s.seller_id,
s.seller_state,
ROUND(SUM(oi.price), 2) AS revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
GROUP BY
s.seller_id,
s.seller_state
ORDER BY revenue DESC
LIMIT 10;

-- ===================================
-- Review Analytics
-- ===================================

-- Average Review Score
SELECT
ROUND(AVG(review_score), 2) AS avg_rating
FROM reviews;

-- Average Review Score by Category
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

-- ===================================
-- Delivery Analytics
-- ===================================

-- Average Delivery Time (Days)
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

-- Delivery Time by State
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

-- ===================================
-- Customer & Geolocation Analytics
-- ===================================

-- Customer Distribution by State
SELECT
customer_state,
COUNT(*) AS customers
FROM customers
GROUP BY customer_state
ORDER BY customers DESC;

-- Customer Distribution Map
SELECT
g.geolocation_lat,
g.geolocation_lng,
COUNT(*) AS customer_count
FROM customers c
JOIN geolocation_unique g
ON c.customer_zip_code_prefix =
g.geolocation_zip_code_prefix
GROUP BY
g.geolocation_lat,
g.geolocation_lng;

-- ===================================
-- Payment Analytics
-- ===================================

-- Revenue by Payment Type
SELECT
payment_type,
ROUND(SUM(payment_value), 2) AS revenue
FROM payments
GROUP BY payment_type
ORDER BY revenue DESC;

-- Payment Method Usage
SELECT
payment_type,
COUNT(*) AS usage_count
FROM payments
GROUP BY payment_type
ORDER BY usage_count DESC;
