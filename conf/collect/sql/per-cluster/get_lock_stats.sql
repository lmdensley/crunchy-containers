SELECT locktype, granted, count(*) FROM pg_locks GROUP BY locktype, granted
