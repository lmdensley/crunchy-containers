SELECT current_database(), relname, now(), last_vacuum, last_autovacuum 
	FROM pg_stat_user_tables
