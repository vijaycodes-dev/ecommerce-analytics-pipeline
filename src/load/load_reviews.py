import pandas as pd
import psycopg2
from psycopg2.extras import execute_batch
from dotenv import load_dotenv
import os

load_dotenv()

df = pd.read_csv("data/raw/olist_order_reviews_dataset.csv")

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
            row["review_id"],
            row["review_score"],
            row["review_comment_title"],
            row["review_comment_message"],
            row["review_creation_date"],
            row["review_answer_timestamp"]
        )
        for _, row in df.iterrows()
    ]

    # Batch insert
    execute_batch(
        cursor,
        """
        INSERT INTO reviews (
            review_id,
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp
        )
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT (review_id)
        DO NOTHING;
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