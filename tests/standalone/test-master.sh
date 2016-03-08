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
# test master
#

$BUILDBASE/examples/standalone/run-pg-master.sh

sleep 10

psql -p 12000 -h 127.0.0.1 -U masteruser testdb -c 'select now()'

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test master passed"
else
	echo "test master FAILED"
	exit $rc
fi

exit 0
