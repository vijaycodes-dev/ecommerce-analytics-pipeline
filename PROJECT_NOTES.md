# Ecommerce Analytics Pipeline – Essential Notes

## Project Structure

```text
ecommerce-analytics-pipeline/
│
├── data/
│   └── raw/
│
├── src/
│   └── load/
│       ├── load_orders.py
│       ├── load_customers.py
│       ├── load_order_items.py
│       ├── load_products.py
│
├── sql/
│   ├── schema.sql
│   └── analytics_queries.sql
│
├── .env
├── .gitignore
├── requirements.txt
└── README.md
```

## .env File

```text
DB_HOST=localhost
DB_NAME=ecommerce_db
DB_USER=postgres
DB_PASSWORD=your_password
DB_PORT=5432
```

## .gitignore

```text
.env
venv/
__pycache__/
```

## Install Dependencies

```bash
pip install pandas psycopg2-binary python-dotenv
pip freeze > requirements.txt
```

## PostgreSQL Connection

```python
import os
from dotenv import load_dotenv
import psycopg2

load_dotenv()

conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    port=os.getenv("DB_PORT")
)
```

## Orders Table

```sql
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
```

Conflict handling:

```sql
ON CONFLICT (order_id) DO NOTHING
```

## Customers Table

```sql
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
```

Conflict handling:

```sql
ON CONFLICT (customer_id) DO NOTHING
```

## Order Items Table

```sql
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
```

Conflict handling:

```sql
ON CONFLICT (order_id, order_item_id) DO NOTHING
```

## Products Table

```sql
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
```

Conflict handling:

```sql
ON CONFLICT (product_id) DO NOTHING
```

## Safe Integer Conversion

```python
def safe_int(value):
    return None if pd.isna(value) else int(value)
```

Usage:

```python
safe_int(row["product_weight_g"])
```

## ETL Pattern

```text
CSV
 ↓
Pandas
 ↓
Transform
 ↓
PostgreSQL
 ↓
Analytics SQL
```

## Analytics Queries

### Total Orders

```sql
SELECT COUNT(*)
FROM orders;
```

### Orders by Status

```sql
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
```

### Orders by State

```sql
SELECT
    c.customer_state,
    COUNT(*) AS total_orders
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;
```

### Top Product Categories

```sql
SELECT
    p.product_category_name,
    COUNT(*) AS total_items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC
LIMIT 10;
```

## Git Commands

```bash
git add .
git commit -m "Load orders, customers, order items and products"
git push
```

## Current Data Model

```text
customers
    ↓
orders
    ↓
order_items
    ↓
products
```

## Next Steps

1. Load `payments`
2. Load `reviews`
3. Load `sellers`
4. Build revenue analytics
5. Create Power BI dashboard
6. Add Airflow
7. Add AWS S3
