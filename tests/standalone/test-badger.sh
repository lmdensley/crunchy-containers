#!/bin/bash

source $BUILDBASE/tests/standalone/pgpass-setup

#
# test badger
#

$BUILDBASE/examples/standalone/run-badger.sh

sleep 10

curl http://127.0.0.1:14000/api/badgergenerate > /dev/null

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test badger passed"
else
	echo "test badger FAILED"
	exit $rc
fi

#docker stop badger-example
exit 0
