#!/bin/bash

source $BUILDBASE/tests/standalone/pgpass-setup

#
# test master
#

$BUILDBASE/examples/standalone/run-pg-master.sh

sleep 30

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
