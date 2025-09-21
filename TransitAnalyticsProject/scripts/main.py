
"""
main.py — quick runner for SmartTransit Astana LLP dataset

Easiest path (within ~1 hour): use SQLite locally and run the demo.
Later, you can switch to PostgreSQL by setting DATABASE_URL.

Usage (Windows PowerShell):
  python -m venv .venv
  .\.venv\Scripts\Activate.ps1
  pip install pandas sqlalchemy matplotlib psycopg2-binary
  python scripts\main.py

Environment variables (optional for PostgreSQL):
  setx DATABASE_URL "postgresql+psycopg2://user:password@localhost:5432/transitdb"

If DATABASE_URL is unset, script falls back to SQLite file: data/transit.db
"""

import os
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, text
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
DB = ROOT / "db"
IMAGES = ROOT / "images"

DATABASE_URL = os.environ.get("DATABASE_URL", f"sqlite:///{(DATA / 'transit.db').as_posix()}")

def get_engine():
    # If using SQLite, ensure file exists; if not, create and populate
    engine = create_engine(DATABASE_URL)
    return engine

def create_schema_if_needed(engine):
    # For SQLite or Postgres: execute init.sql which is Postgres-flavored but works for SQLite for basic types
    with open(DB / "init.sql", "r", encoding="utf-8") as f:
        sql = f.read()
    # Split by semicolons cautiously
    for stmt in [s.strip() for s in sql.split(";") if s.strip()]:
        with engine.begin() as conn:
            try:
                conn.execute(text(stmt))
            except Exception as e:
                # SQLite may ignore some Postgres features; safe to print and continue
                print("Note:", e)

def load_csvs(engine):
    dfs = {
        "routes": pd.read_csv(DATA / "routes.csv"),
        "stops": pd.read_csv(DATA / "stops.csv"),
        "buses": pd.read_csv(DATA / "buses.csv"),
        "drivers": pd.read_csv(DATA / "drivers.csv"),
        "trips": pd.read_csv(DATA / "trips.csv"),
        "ticket_sales": pd.read_csv(DATA / "ticket_sales.csv"),
        "stop_events": pd.read_csv(DATA / "stop_events.csv"),
    }
    for name, df in dfs.items():
        df.to_sql(name, engine, if_exists="replace", index=False)
        print(f"Loaded {name} ({len(df)} rows).")

def run_sample_queries(engine):
    queries = [
        ("peek_routes", "SELECT * FROM routes LIMIT 5"),
        ("revenue_by_route", """
            SELECT r.route_name, SUM(ts.fare_kzt) AS revenue_kzt
            FROM ticket_sales ts
            JOIN trips t ON ts.trip_id = t.trip_id
            JOIN routes r ON t.route_id = r.route_id
            GROUP BY r.route_name
            ORDER BY revenue_kzt DESC
            LIMIT 10
        """),
        ("payment_split", """
            SELECT payment_method, COUNT(*) AS cnt
            FROM ticket_sales
            GROUP BY payment_method
            ORDER BY cnt DESC
        """)
    ]
    results = {}
    with engine.begin() as conn:
        for key, sql in queries:
            results[key] = pd.read_sql(text(sql), conn)
            print(f"\n== {key} ==")
            print(results[key].head(20))
    return results

def plot_overview(engine):
    with engine.begin() as conn:
        df = pd.read_sql(text("""
            SELECT r.route_name, SUM(ts.fare_kzt) AS revenue_kzt
            FROM ticket_sales ts
            JOIN trips t ON ts.trip_id = t.trip_id
            JOIN routes r ON t.route_id = r.route_id
            GROUP BY r.route_name
            ORDER BY revenue_kzt DESC
            LIMIT 10
        """), conn)
    plt.figure()
    plt.bar(df["route_name"], df["revenue_kzt"])
    plt.xticks(rotation=60, ha="right")
    plt.title("Top-10 routes by revenue (synthetic)")
    plt.tight_layout()
    out = IMAGES / "overview.png"
    plt.savefig(out)
    print(f"Saved chart to {out}")

def main():
    engine = get_engine()
    create_schema_if_needed(engine)
    load_csvs(engine)
    run_sample_queries(engine)
    plot_overview(engine)
    print("\nDone. Next: check db/queries.sql for more SQL.")

if __name__ == "__main__":
    main()
