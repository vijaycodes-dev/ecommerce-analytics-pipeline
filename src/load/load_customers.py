import pandas as pd
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Read CSV
df = pd.read_csv("data/raw/olist_customers_dataset.csv")

df = df.where(pd.notnull(df), None)

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
        INSERT INTO customers (
                customer_id, 
                customer_unique_id,	
                customer_zip_code_prefix, 
                customer_city, 
                customer_state
        )
        VALUES (%s,%s,%s,%s,%s)
        ON CONFLICT (customer_id) DO NOTHING
    """, (
        row["customer_id"],
        row["customer_unique_id"],
        row["customer_zip_code_prefix"],
        row["customer_city"],
        row["customer_state"]
    ))

conn.commit()

print(f"Loaded {len(df)} records")

cursor.close()
conn.close()