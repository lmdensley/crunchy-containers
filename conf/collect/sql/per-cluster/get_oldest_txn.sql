SELECT datname, now(), xact_start 
	FROM pg_stat_activity WHERE xact_start IS NOT NULL 
	ORDER BY xact_start ASC LIMIT 1
