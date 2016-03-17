SELECT current_database(), now(), sum(heap_blks_read), sum(heap_blks_hit) 
           FROM pg_statio_user_tables
