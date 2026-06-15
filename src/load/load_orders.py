import pandas as pd
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Read CSV
df = pd.read_csv("data/raw/olist_orders_dataset.csv")

# Convert date columns
date_cols = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]

for col in date_cols:
    df[col] = pd.to_datetime(df[col], errors="coerce")
    
for col in date_cols:
    df[col] = df[col].astype(object)
    df[col] = df[col].where(df[col].notna(), None)

# Connect to PostgreSQL
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    port=os.getenv("DB_PORT")
)

cursor = conn.cursor()

# Insert rows
for _, row in df.iterrows():
    cursor.execute("""
        INSERT INTO orders (
            order_id,
            customer_id,
            order_status,
            order_purchase_timestamp,
            order_approved_at,
            order_delivered_carrier_date,
            order_delivered_customer_date,
            order_estimated_delivery_date
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        ON CONFLICT (order_id) DO NOTHING
    """, (
        row["order_id"],
        row["customer_id"],
        row["order_status"],
        row["order_purchase_timestamp"],
        row["order_approved_at"],
        row["order_delivered_carrier_date"],
        row["order_delivered_customer_date"],
        row["order_estimated_delivery_date"]
    ))

conn.commit()

print(f"Loaded {len(df)} records")

cursor.close()
conn.close()