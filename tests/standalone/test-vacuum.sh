#!/bin/bash


echo BUILDBASE is $BUILDBASE

#
# test backup
#

$BUILDBASE/examples/standalone/run-vacuum.sh

sleep 10

docker logs crunchy-vacuum-job | grep VACUUM

rc=$?
if [ 0 -eq $rc ]; then
	echo vacuum test passed
	exit 0
else
	echo vacuum test FAILED
	exit 1
fi

exit 1
