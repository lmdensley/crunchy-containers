#!/bin/bash


echo BUILDBASE is $BUILDBASE
cleanup() {
$BUILDBASE/examples/openshift/watchtest/delete.sh
echo "sleeping while cleaning up any leftovers..."
sleep 30
}

#
# test setup
#
cleanup


## create container
$BUILDBASE/examples/openshift/watchtest/run.sh

echo "sleep for 30 while the container starts up..."
sleep 30
echo "deleting the master which triggers the failover..."
oc delete pod ms-master
sleep 30
PODNAME=`oc get pod -l name=ms-slave --no-headers | cut -f1 -d' '`
echo $PODNAME " is the pgpool pod name"
export IP=`oc describe pod $PODNAME | grep IP | cut -f2 -d':' `
echo $IP " is the IP address"

export PGPASSFILE=/tmp/master-slave-pgpass
echo "using pgpassfile from master-slave test case...."

echo "should be able to insert into original slave after failover..."
echo "wait for the slave to restart as a new master...."
sleep 30

psql -h $IP -U testuser userdb -c "insert into testtable values ('watch','fromwatch', now())"

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test watch passed"
else
	echo "test watch FAILED"
	exit $rc
fi

echo "performing cleanup..."
cleanup

exit 0
