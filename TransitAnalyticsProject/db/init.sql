
-- PostgreSQL schema for SmartTransit Astana LLP dataset

CREATE TABLE IF NOT EXISTS routes (
  route_id     INTEGER PRIMARY KEY,
  route_name   TEXT NOT NULL,
  mode         TEXT CHECK (mode IN ('bus','trolleybus')) NOT NULL
);

CREATE TABLE IF NOT EXISTS stops (
  stop_id      INTEGER PRIMARY KEY,
  stop_name    TEXT NOT NULL,
  lat          NUMERIC(9,6),
  lon          NUMERIC(9,6)
);

CREATE TABLE IF NOT EXISTS buses (
  bus_id       INTEGER PRIMARY KEY,
  plate_number TEXT NOT NULL,
  capacity     INTEGER CHECK (capacity > 0),
  in_service   BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS drivers (
  driver_id    INTEGER PRIMARY KEY,
  full_name    TEXT NOT NULL,
  hire_date    DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS trips (
  trip_id      INTEGER PRIMARY KEY,
  route_id     INTEGER NOT NULL REFERENCES routes(route_id),
  bus_id       INTEGER NOT NULL REFERENCES buses(bus_id),
  driver_id    INTEGER NOT NULL REFERENCES drivers(driver_id),
  start_time   TIMESTAMP NOT NULL,
  end_time     TIMESTAMP NOT NULL,
  distance_km  NUMERIC(6,2) CHECK (distance_km >= 0)
);

CREATE TABLE IF NOT EXISTS ticket_sales (
  ticket_id      INTEGER PRIMARY KEY,
  trip_id        INTEGER NOT NULL REFERENCES trips(trip_id),
  sold_at        TIMESTAMP NOT NULL,
  payment_method TEXT CHECK (payment_method IN ('cash','card','qr')) NOT NULL,
  fare_kzt       NUMERIC(6,0) CHECK (fare_kzt >= 0),
  passenger_type TEXT CHECK (passenger_type IN ('adult','student','senior')) NOT NULL
);

CREATE TABLE IF NOT EXISTS stop_events (
  trip_id        INTEGER NOT NULL REFERENCES trips(trip_id),
  stop_id        INTEGER NOT NULL REFERENCES stops(stop_id),
  sequence       INTEGER NOT NULL,
  arrival_time   TIMESTAMP NOT NULL,
  departure_time TIMESTAMP NOT NULL,
  PRIMARY KEY (trip_id, stop_id, sequence)
);
