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
export PGPASSFILE=/tmp/single-master-pgpass
chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE
echo "sleeping for 20 seconds to allow any existing pods/services to terminate"

sleep 40

oc process -f $BUILDBASE/examples/openshift/master.json |  oc create -f -

echo "sleeping for 20 seconds to allow pods/services to startup"
sleep 20
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

export LOCAL_IP=`ifconfig | grep inet | head -1 | xargs | cut -f2 -d' '`

echo "local ip address is " $LOCAL_IP

cp backup-job.json /tmp/temp-backup-job.json
cp backup-job-pv.json /tmp/temp-backup-job-pv.json
sed -i "s/REPLACE_PASSWORD/$MASTERPSW/g" /tmp/temp-backup-job.json
sed -i "s/REPLACE_IP_ADDRESS/$LOCAL_IP/g" /tmp/temp-backup-job-pv.json

cat /tmp/temp-backup-job.json
cat /tmp/temp-backup-job-pv.json

# clear out any previous backups
sudo rm -rf /nfsfileshare/single-master

oc create -f /tmp/temp-backup-job-pv.json
oc create -f backup-job-pvc.json
oc create -f /tmp/temp-backup-job.json

echo "sleep while backup executes"
sleep 30

oc delete pod single-master
oc delete service single-master
oc delete job backup-job
oc delete pvc backup-job-pvc
oc delete pv backup-job-pv

sudo find /nfsfileshare/single-master/ -name "postgresql.conf"
rc=$?
echo "final rc is " $rc
if [ 0 -eq $rc ]; then
	echo "backup test passed"
else
	echo "backup test FAILED"
	exit $rc
fi
exit 0
