SELECT oid, relname FROM pg_class WHERE relkind = 'r' 
AND relname NOT LIKE 'pg_%' AND relname NOT LIKE 'sql_%'
