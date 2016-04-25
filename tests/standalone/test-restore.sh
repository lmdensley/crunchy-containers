#!/bin/bash

source $BUILDBASE/tests/standalone/pgpass-setup

#
# test restore
#

$BUILDBASE/examples/standalone/run-restore.sh /tmp/backups/master/2*

sleep 30

psql -p 12001 -h 127.0.0.1 -U masteruser testdb -c 'select now()'

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test restore passed"
else
	echo "test restore FAILED"
	exit $rc
fi

docker stop master-restore
exit 0
