CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);



CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2),

    PRIMARY KEY (order_id, order_item_id)
);



CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght BIGINT,
    product_description_lenght BIGINT,
    product_photos_qty BIGINT,
    product_weight_g BIGINT,
    product_length_cm BIGINT,
    product_height_cm BIGINT,
    product_width_cm BIGINT
);



CREATE TABLE IF NOT EXISTS payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10,2),

    PRIMARY KEY (order_id, payment_sequential),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


CREATE TABLE IF NOT EXISTS reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

ALTER TABLE reviews
ADD PRIMARY KEY (review_id);

CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);


CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC(10,8),
    geolocation_lng NUMERIC(11,8),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);


CREATE TABLE geolocation_unique AS
SELECT
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS latitude,
    AVG(geolocation_lng) AS longitude,
    MIN(geolocation_city) AS city,
    MIN(geolocation_state) AS state
FROM geolocation
GROUP BY geolocation_zip_code_prefix;




CREATE TABLE IF NOT EXISTS category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);





-- Add relationships:

ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id)
REFERENCES products(product_id);

ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_seller
FOREIGN KEY (seller_id)
REFERENCES sellers(seller_id);

ALTER TABLE payments
ADD CONSTRAINT fk_payments_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);

ALTER TABLE reviews
ADD CONSTRAINT fk_reviews_order
FOREIGN KEY (order_id)
REFERENCES orders(order_id);


	-- Indexes are used to speed up database queries.
	-- Think of an index like the index at the back of a book.
	
	-- Without an index: PostgreSQL reads every row one by one to find the data.
	-- With an index: PostgreSQL jumps directly to the matching rows.
	
-- Create indexes: Without indexes, PostgreSQL repeatedly scans tables during joins.

CREATE INDEX idx_orders_customer
ON orders(customer_id);

CREATE INDEX idx_order_items_product
ON order_items(product_id);

CREATE INDEX idx_payments_order
ON payments(order_id);

CREATE INDEX idx_orders_purchase_date
ON orders(order_purchase_timestamp);