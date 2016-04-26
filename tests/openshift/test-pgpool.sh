#!/bin/bash


echo BUILDBASE is $BUILDBASE
cleanup() {
$BUILDBASE/examples/openshift/pgpool/delete.sh
echo "sleeping while cleaning up any leftovers..."
sleep 30
}

#
# test setup
#
cleanup


## create container
$BUILDBASE/examples/openshift/pgpool/run.sh

echo "sleep for 30 while the container starts up..."
sleep 30

PODNAME=`oc get pod -l name=pgpool-rc --no-headers | cut -f1 -d' '`
echo $PODNAME " is the pgpool pod name"
export IP=`oc describe pod $PODNAME | grep IP | cut -f2 -d':' `
echo $IP " is the IP address"

export PGPASSFILE=/tmp/master-slave-pgpass
echo "using pgpassfile from master-slave test case...."

psql -h $IP -U testuser userdb -c 'select now()'

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test pgpool passed"
else
	echo "test pgpool FAILED"
	exit $rc
fi

#echo "performing cleanup..."
#cleanup

exit 0
