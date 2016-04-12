#!/bin/bash


echo BUILDBASE is $BUILDBASE
#
# test setup
#

#
# test master
#

oc login -u system:admin
oc projects openshift
oc delete pod single-master
oc delete service single-master
echo "sleeping for 20 seconds to allow any existing pods/services to terminate"
sleep 40
oc process -f $BUILDBASE/examples/openshift/master.json |  oc create -f -

echo "sleeping for 40 seconds to allow pods/services to startup"
sleep 40
export IP=`oc describe pod single-master | grep IP | cut -f2 -d':' `
echo $IP " is the IP address"
export MASTERPSW=`oc describe pod single-master | grep MASTER_PASSWORD | cut -f2 -d':' | xargs`
echo "["$MASTERPSW"] is the master password"

export PGPASSFILE=/tmp/single-master-pgpass
chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE

echo "creating PGPASSFILE..."
echo "*:*:*:*:"$MASTERPSW > $PGPASSFILE
chmod 400 $PGPASSFILE

psql -h $IP -U master postgres -c 'select now()'

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test master passed"
else
	echo "test master FAILED"
	exit $rc
fi
chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE
# always delete the pod and service even on a failure
oc delete pod single-master
oc delete service single-master

exit 0
