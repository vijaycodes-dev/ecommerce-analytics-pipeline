import pandas as pd

orders = pd.read_csv("data/raw/olist_orders_dataset.csv")

print("Rows:", len(orders))
print("\nColumns:")
print(orders.columns.tolist())

print("\nFirst 5 Rows:")
print(orders.head())