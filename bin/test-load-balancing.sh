#!/bin/bash
/bin/rm -f ./mypgpass
echo "*:*:*:master:MClNo2g5N8Hu" >> ./mypgpass
export PGPASSFILE=./mypgpass
chmod 400 ./mypgpass

for i in `seq 1 10`;
do
	psql -h pg-slave-rc.pgproject.svc.cluster.local -U master userdb -c 'select inet_server_addr()'
done    
