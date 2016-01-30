#!/bin/bash -x

#
# start the backup job
#
# the service looks for the following env vars to be set by
# the cpm-admin that provisioned us
#
# /pgdata is a volume that gets mapped into this container
# $BACKUP_HOST host we are connecting to
# $BACKUP_USER pg user we are connecting with
# $BACKUP_PASS pg user password we are connecting with
# $BACKUP_PORT pg port we are connecting to
#

env

BACKUPBASE=/pgdata/$BACKUP_HOST
if [ ! -d "$BACKUPBASE" ]; then
	echo "creating BACKUPBASE directory..."
	mkdir -p $BACKUPBASE
fi

TS=`date +%Y-%m-%d:%H:%M:%S`
BACKUP_PATH=$BACKUPBASE/$TS
mkdir $BACKUP_PATH


export PGPASSFILE=/tmp/pgpass

echo "*:*:*:"$BACKUP_USER":"$BACKUP_PASS  >> $PGPASSFILE

chmod 600 $PGPASSFILE

chown postgres:postgres $PGPASSFILE

cat $PGPASSFILE

pg_basebackup --xlog --pgdata $BACKUP_PATH --host=$BACKUP_HOST --port=$BACKUP_PORT -U $BACKUP_USER

chown -R postgres:postgres $BACKUP_PATH

echo "backup has ended!"
