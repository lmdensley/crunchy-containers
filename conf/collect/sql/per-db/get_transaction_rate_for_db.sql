SELECT current_database(), datname, now(), 
	xact_commit + xact_rollback, xact_rollback 
	FROM pg_stat_database WHERE datname = current_database()
