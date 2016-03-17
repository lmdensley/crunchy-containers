SELECT current_database() as db_name, relname as table_name, 
           idx_scan as index_hit, seq_scan as index_miss 
	           FROM pg_stat_user_tables
