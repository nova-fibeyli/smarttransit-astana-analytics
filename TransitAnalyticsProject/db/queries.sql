
-- 1) Peek first rows
SELECT * FROM routes LIMIT 10;
SELECT * FROM trips  LIMIT 10;

-- 2) Filter + ORDER BY: recent tickets, highest fares first
SELECT ticket_id, trip_id, sold_at, fare_kzt
FROM ticket_sales
WHERE sold_at >= NOW() - INTERVAL '7 days'
ORDER BY fare_kzt DESC, sold_at DESC
LIMIT 20;

-- 3) Aggregation by route: total tickets and revenue
SELECT t.route_id,
       r.route_name,
       COUNT(*) AS tickets_count,
       SUM(ts.fare_kzt)::BIGINT AS revenue_kzt
FROM ticket_sales ts
JOIN trips t ON ts.trip_id = t.trip_id
JOIN routes r ON t.route_id = r.route_id
GROUP BY t.route_id, r.route_name
ORDER BY revenue_kzt DESC;

-- 4) Average distance per route
SELECT r.route_id, r.route_name, AVG(t.distance_km)::NUMERIC(6,2) AS avg_distance_km
FROM trips t
JOIN routes r ON t.route_id = r.route_id
GROUP BY r.route_id, r.route_name
ORDER BY avg_distance_km DESC;

-- 5) Payment method split
SELECT payment_method, COUNT(*) AS cnt, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER (),2) AS pct
FROM ticket_sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- 6) Top 10 revenue routes (month to date)
SELECT r.route_name, SUM(ts.fare_kzt) AS revenue_kzt
FROM ticket_sales ts
JOIN trips t ON ts.trip_id = t.trip_id
JOIN routes r ON t.route_id = r.route_id
WHERE DATE_TRUNC('month', ts.sold_at) = DATE_TRUNC('month', NOW())
GROUP BY r.route_name
ORDER BY revenue_kzt DESC
LIMIT 10;

-- 7) Driver productivity: tickets per driver
SELECT d.full_name, COUNT(*) AS tickets_sold
FROM ticket_sales ts
JOIN trips t ON ts.trip_id = t.trip_id
JOIN drivers d ON t.driver_id = d.driver_id
GROUP BY d.full_name
ORDER BY tickets_sold DESC
LIMIT 20;

-- 8) Peak hours (overall ticket counts by hour of day)
SELECT EXTRACT(HOUR FROM sold_at)::INT AS hour_of_day,
       COUNT(*) AS tickets
FROM ticket_sales
GROUP BY EXTRACT(HOUR FROM sold_at)
ORDER BY hour_of_day;

-- 9) Capacity utilization proxy: average tickets per trip vs bus capacity (rough proxy)
SELECT b.bus_id,
       b.capacity,
       COUNT(ts.ticket_id)::INT AS tickets_on_bus,
       ROUND(100.0*COUNT(ts.ticket_id)/NULLIF(b.capacity,0),1) AS capacity_pct
FROM trips t
JOIN buses b ON t.bus_id = b.bus_id
LEFT JOIN ticket_sales ts ON ts.trip_id = t.trip_id
GROUP BY b.bus_id, b.capacity
ORDER BY capacity_pct DESC NULLS LAST
LIMIT 20;

-- 10) On-time proxy: dwell count per stop (using stop_events sequence)
SELECT s.stop_name,
       COUNT(*) AS events
FROM stop_events se
JOIN stops s ON se.stop_id = s.stop_id
GROUP BY s.stop_name
ORDER BY events DESC
LIMIT 20;
