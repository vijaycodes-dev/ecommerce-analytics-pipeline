import pandas as pd
import psycopg2
from psycopg2.extras import execute_batch
from dotenv import load_dotenv
import os

load_dotenv()

df = pd.read_csv("data/raw/olist_order_payments_dataset.csv")

# Replace NaN with None for PostgreSQL NULL values
df = df.where(pd.notnull(df), None)

try:
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT")
    )

    cursor = conn.cursor()

    # Convert DataFrame rows into tuples
    records = [
        (
            row["order_id"],
            row["payment_sequential"],
            row["payment_type"],
            row["payment_installments"],
            row["payment_value"]
        )
        for _, row in df.iterrows()
    ]

    # Batch insert
    execute_batch(
        cursor,
        """
        INSERT INTO payments (
            order_id,
            payment_sequential,
            payment_type,
            payment_installments,
            payment_value
        )
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (order_id, payment_sequential)
        DO NOTHING;
        """,
        records,
        page_size=1000
    )

    # Save changes
    conn.commit()

    print(f"Successfully loaded {len(records)} records into payments table.")

except Exception as e:
    if conn:
        conn.rollback()
    print("Error:", e)

finally:
    if 'cursor' in locals():
        cursor.close()

    if 'conn' in locals():
        conn.close()

    print("Database connection closed.")