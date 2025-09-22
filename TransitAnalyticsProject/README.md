
# SmartTransit Astana LLP — Urban Transit Analytics


---

## Что внутри репозитория

```
TransitAnalyticsProject/
├─ data/                 # CSV (синтетика): 7 таблиц, 60k+ строк продаж билетов
├─ db/
│   ├─ init.sql          # схема БД (PostgreSQL‑стиль), пойдёт и для SQLite
│   └─ queries.sql       # 10+ SQL запросов по темам
├─ images/
│   └─ overview.png      # скрин с топ‑10 маршрутов по выручке (синтетика)
└─ scripts/
    └─ main.py           # быстрый запуск: создать БД, залить CSV, выполнить SQL, построить график
```

## ER‑диаграмма (словами)

```mermaid
erDiagram
  routes ||--o{ trips : "has"
  buses  ||--o{ trips : "serves"
  drivers||--o{ trips : "operates"
  trips  ||--o{ ticket_sales : "generates"
  trips  ||--o{ stop_events  : "stops at"
  stops  ||--o{ stop_events  : "observed in"

  routes {
    int route_id PK
    text route_name
    text mode
  }
  buses {
    int bus_id PK
    text plate_number
    int capacity
    boolean in_service
  }
  drivers {
    int driver_id PK
    text full_name
    date hire_date
  }
  trips {
    int trip_id PK
    int route_id FK
    int bus_id FK
    int driver_id FK
    timestamp start_time
    timestamp end_time
    numeric distance_km
  }
  ticket_sales {
    int ticket_id PK
    int trip_id FK
    timestamp sold_at
    text payment_method
    numeric fare_kzt
    text passenger_type
  }
  stops {
    int stop_id PK
    text stop_name
    numeric lat
    numeric lon
  }
  stop_events {
    int trip_id FK
    int stop_id FK
    int sequence
    timestamp arrival_time
    timestamp departure_time
  }
```

- `routes (route_id, route_name, mode)`  
- `stops (stop_id, stop_name, lat, lon)`  
- `buses (bus_id, plate_number, capacity, in_service)`  
- `drivers (driver_id, full_name, hire_date)`  
- `trips (trip_id, route_id → routes, bus_id → buses, driver_id → drivers, start_time, end_time, distance_km)`  
- `ticket_sales (ticket_id, trip_id → trips, sold_at, payment_method, fare_kzt, passenger_type)`  
- `stop_events (trip_id → trips, stop_id → stops, sequence, arrival_time, departure_time)` — PK по (trip_id, stop_id, sequence)

Связи: `routes 1‑N trips`, `buses 1‑N trips`, `drivers 1‑N trips`, `trips 1‑N ticket_sales`, `trips 1‑N stop_events`, `stops 1‑N stop_events`.

\
