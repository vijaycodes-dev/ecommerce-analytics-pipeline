import pandas as pd
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

# Read CSV
df = pd.read_csv("data/raw/olist_products_dataset.csv")

df = df.where(pd.notnull(df), None)
numeric_cols = [
    "product_name_lenght",
    "product_description_lenght",
    "product_photos_qty",
    "product_weight_g",
    "product_length_cm",
    "product_height_cm",
    "product_width_cm"
]

for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")
    df[col] = df[col].astype(object)
    df[col] = df[col].where(pd.notnull(df[col]), None)
    
#print(df[numeric_cols].max())
    
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
try:
    # Insert rows
    for _, row in df.iterrows():
        cursor.execute("""
            INSERT INTO products (
                product_id,
                product_category_name,
                product_name_lenght,
                product_description_lenght,
                product_photos_qty,
                product_weight_g,
                product_length_cm,
                product_height_cm,
                product_width_cm
            )
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
            ON CONFLICT (product_id) DO NOTHING
        """, (
            row["product_id"],
            row["product_category_name"],
            None if pd.isna(row["product_name_lenght"]) else int(row["product_name_lenght"]),
            None if pd.isna(row["product_description_lenght"]) else int(row["product_description_lenght"]),
            None if pd.isna(row["product_photos_qty"]) else int(row["product_photos_qty"]),
            None if pd.isna(row["product_weight_g"]) else int(row["product_weight_g"]),
            None if pd.isna(row["product_length_cm"]) else int(row["product_length_cm"]),
            None if pd.isna(row["product_height_cm"]) else int(row["product_height_cm"]),
            None if pd.isna(row["product_width_cm"]) else int(row["product_width_cm"])
        ))

    conn.commit()
    print(f"Loaded {len(df)} records")

except Exception as e:
    conn.rollback()
    print("Failed row:")
    print(row)
    raise e

finally:
    cursor.close()
    conn.close()