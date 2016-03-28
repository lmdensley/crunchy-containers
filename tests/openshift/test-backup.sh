#!/bin/bash

echo BUILDBASE is $BUILDBASE
#
# test backup
#

oc login -u system:admin
oc projects openshift
oc delete pvc backup-job-pvc
oc delete pv backup-job-pv
oc delete job backup-job
oc delete pod single-master
oc delete service single-master
echo "sleeping for 20 seconds to allow any existing pods/services to terminate"

sleep 40

oc process -f $BUILDBASE/examples/openshift/master.json |  oc create -f -

echo "sleeping for 20 seconds to allow pods/services to startup"
sleep 20
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

export LOCAL_IP=`/sbin/ifconfig -a | awk '/(cast)/ { print $2 }' | cut -d':' -f2 | tail -1`

echo "local ip address is " $LOCAL_IP

psql -h $IP -U master postgres -c 'select now()'

rc=$?

echo $rc is the rc

chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE
# always delete the pod and service even on a failure

if [ 0 -eq $rc ]; then
	echo "connection test passed"
else
	echo "connection test FAILED"
	exit $rc
fi

cp backup-job.json temp-backup-job.json
cp backup-job-pv.json temp-backup-job-pv.json
sed -i "s/REPLACE_PASSWORD/$MASTERPSW/g" temp-backup-job.json
sed -i "s/REPLACE_IP_ADDRESS/$LOCAL_IP/g" temp-backup-job-pv.json

cat temp-backup-job.json
cat temp-backup-job-pv.json

oc create -f temp-backup-job-pv.json
oc create -f backup-job-pvc.json
oc create -f temp-backup-job.json

echo "sleep while backup executes"
sleep 30

oc delete pod single-master
oc delete service single-master
exit 0
