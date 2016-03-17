SELECT client_addr, pg_xlog_location_diff(pg_current_xlog_location(), 
	replay_location) AS bytes_diff 
	FROM public.pg_stat_repl
