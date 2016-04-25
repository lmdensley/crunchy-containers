#!/bin/bash


source $BUILDBASE/tests/standalone/pgpass-setup

#
# test pgpool
#

$BUILDBASE/examples/standalone/run-pgpool.sh

sleep 30

psql -p 12003 -h 127.0.0.1 -U masteruser postgres -c "insert into mastertable values  ('pgpool', 'was here')"

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test pgpool passed"
else
	echo "test pgpool FAILED"
	exit $rc
fi

exit 0
