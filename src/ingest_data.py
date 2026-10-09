import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

load_dotenv()

url = URL.create(
    drivername="postgresql+psycopg",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    port=int(os.getenv("DB_PORT")),
    database=os.getenv("DB_NAME"),
)

engine = create_engine(url)

project_folder = Path(__file__).resolve().parents[1]
raw_folder = project_folder / "data" / "raw"

files = {
    "customers": "customers.csv",
    "products": "products.csv",
    "sales_reps": "sales_reps.csv",
    "subscriptions": "subscriptions.csv",
    "invoices": "invoices.csv",
    "opportunities": "opportunities.csv",
}

for table_name, file_name in files.items():
    csv_file = raw_folder / file_name

    df = pd.read_csv(csv_file)

    df.to_sql(
        table_name,
        engine,
        schema="raw",
        if_exists="replace",
        index=False,
    )

    print(f"{file_name} loaded successfully")