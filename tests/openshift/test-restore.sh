#!/bin/bash


echo BUILDBASE is $BUILDBASE
cleanup() {
sudo rm -rf /nfsfileshare/single-master
$BUILDBASE/examples/openshift/master-restore/delete.sh
$BUILDBASE/examples/openshift/backup-job/delete.sh
oc delete service single-master
oc delete pod single-master
echo "sleeping while cleaning up any leftovers..."
sleep 30
}

#
# test setup
#
cleanup



## create container
oc process -f $BUILDBASE/examples/openshift/master.json | oc create -f -

echo "sleep for 30 while the container starts up..."
sleep 30

## create backup
$BUILDBASE/examples/openshift/backup-job/run.sh
sleep 30

# set the backup to a known and stable name
sudo mv /nfsfilesystem/single-master/2* /nfsfilesystem/single-master/2016-03-28-12-09-28
## create restored container
$BUILDBASE/examples/openshift/master-restore/run.sh

export IP=`oc describe pod master-restore | grep IP | cut -f2 -d':' `
echo $IP " is the IP address"
export MASTERPSW=`oc describe pod master-restore | grep MASTER_PASSWORD | cut -f2 -d':' | xargs`
echo "["$MASTERPSW"] is the master password"

export PGPASSFILE=/tmp/master-restore-pgpass
chmod 777 $PGPASSFILE
/usr/bin/rm $PGPASSFILE

echo "creating PGPASSFILE..."
echo "*:*:*:*:"$MASTERPSW > $PGPASSFILE
chmod 400 $PGPASSFILE

oc describe pod master-restore | grep IPAddress

psql -h $IP -U master testdb -c 'select now()'

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test restore passed"
else
	echo "test restore FAILED"
	exit $rc
fi

echo "performing cleanup..."
cleanup

exit 0
