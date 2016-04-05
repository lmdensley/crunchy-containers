#!/bin/bash


echo BUILDBASE is $BUILDBASE
#
# test setup
#
export PGPASSFILE=/tmp/testing-pgpass

if [ ! -f $PGPASSFILE ]; then
	echo "creating PGPASSFILE..."
	echo "*:*:*:*:masterpsw" > $PGPASSFILE
	chmod 400 $PGPASSFILE
fi


#
# test replica
#

$BUILDBASE/examples/standalone/run-pg-replica.sh

sleep 60

psql -p 12002 -h 127.0.0.1 -U masteruser testdb -c 'select now()'

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test replica passed"
else
	echo "test replica FAILED"
	exit $rc
fi

#docker stop pg-replica
exit 0
