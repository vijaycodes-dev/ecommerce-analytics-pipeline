import pandas as pd
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Read CSV
df = pd.read_csv("data/raw/olist_order_items_dataset.csv")

date_cols = [
    "shipping_limit_date"
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
        INSERT INTO order_items (
                order_id, 
                order_item_id,	
                product_id, 
                seller_id, 
                shipping_limit_date,
                price,
                freight_value
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s)
        ON CONFLICT (order_id,order_item_id) DO NOTHING
    """, (
        row["order_id"],
        row["order_item_id"],
        row["product_id"],
        row["seller_id"],
        row["shipping_limit_date"],
        row["price"],
        row["freight_value"]
    ))

conn.commit()

print(f"Loaded {len(df)} records")

cursor.close()
conn.close()