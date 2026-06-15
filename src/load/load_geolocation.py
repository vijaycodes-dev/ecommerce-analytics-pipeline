import pandas as pd
import psycopg2
from psycopg2.extras import execute_batch
from dotenv import load_dotenv
import os

load_dotenv()

df = pd.read_csv("data/raw/olist_geolocation_dataset.csv")

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
            row["geolocation_zip_code_prefix"],
            row["geolocation_lat"],
            row["geolocation_lng"],
            row["geolocation_city"],
            row["geolocation_state"]        )
        for _, row in df.iterrows()
    ]

    # Batch insert
    execute_batch(
        cursor,
        """
        INSERT INTO geolocation (
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
        )
        VALUES (%s, %s, %s, %s, %s)
        """,
        records,
        page_size=1000
    )

    # Save changes
    conn.commit()

    print(f"Successfully loaded {len(records)} records into reviews table.")

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