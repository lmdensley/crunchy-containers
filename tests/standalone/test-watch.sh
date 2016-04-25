#!/bin/bash

source $BUILDBASE/tests/standalone/pgpass-setup

#
# test watch
#

$BUILDBASE/examples/standalone/run-watch.sh

sleep 20

echo "stopping master..."
docker stop master

sleep 20

echo "testing slave is new master..."

# should be able to insert now that failover has occurred

psql -p 12002 -h 127.0.0.1 -U masteruser postgres -c "insert into mastertable values ('watch', 'was here')"

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test watch passed"
else
	echo "test watch FAILED"
	exit $rc
fi

exit 0
