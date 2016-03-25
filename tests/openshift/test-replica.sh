#!/bin/bash


echo BUILDBASE is $BUILDBASE

#
# test master slave replication
#

oc login -u system:admin
oc projects openshift
oc delete pod ms-master ms-slave
oc delete service ms-master ms-slave

export SLEEP=60
echo "sleeping for " $SLEEP " seconds to allow any existing pods/services to terminate"
sleep $SLEEP
oc process -f $BUILDBASE/examples/openshift/master-slave.json |  oc create -f -

echo "sleeping for " $SLEEP " seconds to allow pods/services to startup"
sleep $SLEEP
export MASTERIP=`oc describe pod ms-master | grep IP | cut -f2 -d':' `
export SLAVEIP=`oc describe pod ms-slave | grep IP | cut -f2 -d':' `
echo $MASTERIP " is the master IP address"
echo $SLAVEIP " is the slave IP address"
export MASTERPSW=`oc describe pod ms-master | grep MASTER_PASSWORD | cut -f2 -d':' | xargs`
echo "["$MASTERPSW"] is the master password"

export PGPASSFILE=/tmp/master-slave-pgpass
chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE

echo "creating PGPASSFILE..."
echo "*:*:*:*:"$MASTERPSW > $PGPASSFILE
chmod 400 $PGPASSFILE


psql -h $MASTERIP -U master postgres -c 'select now()'

rc=$?

echo $rc is the master rc

psql -h $SLAVEIP -U master postgres -c 'select now()'

slaverc=$?
echo $slaverc is the slave rc

resultrc=0

if [ 0 -eq $rc ]; then
	echo "test master slave master test passed"
else
	echo "test master slave master test FAILED"
	resultrc=2
fi
if [ 0 -eq $slaverc ]; then
	echo "test master slave slave test passed"
else
	echo "test master slave slave test FAILED"
	resultrc=2
fi
chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE
# always delete the pod and service even on a failure
oc delete pod ms-master ms-slave
oc delete service ms-master ms-slave

exit $resultrc

