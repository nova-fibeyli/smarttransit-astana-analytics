# smarttransit-astana-analytics
Quick start

1. Create & activate venv
```
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

2. Install dependencies
```
pip install pandas sqlalchemy matplotlib psycopg2-binary
```

3. Run the quick script
```
python .\scripts\main.py
```

4. Open PowerShell and run:
```
psql -U postgres -h localhost -d transitdb -f db\init.sql

\copy routes       FROM 'data/routes.csv'       WITH (FORMAT csv, HEADER true);
\copy stops        FROM 'data/stops.csv'        WITH (FORMAT csv, HEADER true);
\copy buses        FROM 'data/buses.csv'        WITH (FORMAT csv, HEADER true);
\copy drivers      FROM 'data/drivers.csv'      WITH (FORMAT csv, HEADER true);
\copy trips        FROM 'data/trips.csv'        WITH (FORMAT csv, HEADER true);
\copy ticket_sales FROM 'data/ticket_sales.csv' WITH (FORMAT csv, HEADER true);
\copy stop_events  FROM 'data/stop_events.csv'  WITH (FORMAT csv, HEADER true);

psql -U postgres -h localhost -d transitdb -f db\queries.sql
```

To make the Python script talk to Postgres instead of SQLite, set an env variable:
```
setx DATABASE_URL "postgresql+psycopg2://postgres:<YOUR_PASSWORD>@localhost:5432/transitdb"
```

then restart PowerShell, activate venv again:
```
python .\scripts\main.py
```

setx DATABASE_URL "postgresql+psycopg2://postgres:<YOUR_PASSWORD>@localhost:5432/transitdb"
# then restart PowerShell, activate venv again:
python .\scripts\main.py
