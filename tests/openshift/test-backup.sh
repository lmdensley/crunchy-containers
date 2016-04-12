#!/bin/bash

echo BUILDBASE is $BUILDBASE
#
# test backup
#

oc login -u system:admin
oc projects openshift

echo "cleaning up any leftovers...."

export PGPASSFILE=/tmp/single-master-pgpass

cleanup() {
$BUILDBASE/examples/openshift/backup-job/delete.sh
# clear out any previous backups
sudo rm -rf /nfsfileshare/single-master
oc delete pod single-master
oc delete service single-master
chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE
}

cleanup
echo "sleeping for 40 seconds to allow any existing pods/services to terminate"

sleep 40

echo "creating single-master pod..."
oc process -f $BUILDBASE/examples/openshift/master.json |  oc create -f -

echo "sleeping for 40 seconds to allow pods/services to startup"
sleep 40

export IP=`oc describe pod single-master | grep IP | cut -f2 -d':' `
echo $IP " is the IP address"
export MASTERPSW=`oc describe pod single-master | grep MASTER_PASSWORD | cut -f2 -d':' | xargs`
echo "["$MASTERPSW"] is the master password"

echo "creating PGPASSFILE..."
echo "*:*:*:*:"$MASTERPSW > $PGPASSFILE
chmod 400 $PGPASSFILE

psql -h $IP -U master postgres -c 'select now()'

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "connection test passed"
else
	echo "connection test FAILED"
	exit $rc
fi

export IPADDRESS=`hostname --ip-address`

echo "local ip address is " $IPADDRESS

$BUILDBASE/examples/openshift/backup-job/run.sh

echo "sleep while backup executes"
sleep 30

sudo find /nfsfileshare/single-master/ -name "postgresql.conf"
rc=$?
echo "final rc is " $rc
if [ 0 -eq $rc ]; then
	echo "backup test passed"
else
	echo "backup test FAILED"
	exit $rc
fi

cleanup
exit 0
