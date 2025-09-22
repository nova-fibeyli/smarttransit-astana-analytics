# smarttransit-astana-analytics
## SmartTransit Astana Analytics is a demo project that takes real-like bus route data, loads it into a database, and runs quick analytics. It shows how routes, buses, drivers, stops, and ticket sales connect together, and gives a simple overview chart of the system. The point is to practice end-to-end data handling — from CSV files -> SQL schema -> queries -> visual output - in a way that feels like a real urban transit company.

![Overview chart](images/overview.png)
![ERM](_route id route name mode.png)

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
```
setx DATABASE_URL "postgresql+psycopg2://postgres:<YOUR_PASSWORD>@localhost:5432/transitdb"
```
# then restart PowerShell, activate venv again:

In my case cose was:
(


1. Load schema
\i 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/db/init.sql'

2. Import CSV data
\copy routes       FROM 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/data/routes.csv'       CSV HEADER;
\copy stops        FROM 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/data/stops.csv'        CSV HEADER;
\copy buses        FROM 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/data/buses.csv'        CSV HEADER;
\copy drivers      FROM 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/data/drivers.csv'      CSV HEADER;
\copy trips        FROM 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/data/trips.csv'        CSV HEADER;
\copy ticket_sales FROM 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/data/ticket_sales.csv' CSV HEADER;
\copy stop_events  FROM 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/data/stop_events.csv'  CSV HEADER;

3. Run prepared queries
\i 'C:/Users/Fanta/Downloads/TransitAnalyticsProject/TransitAnalyticsProject/db/queries.sql'

4. Verify tables
\dt
SELECT COUNT(*) FROM routes;
SELECT COUNT(*) FROM ticket_sales;
)
python .\scripts\main.py
