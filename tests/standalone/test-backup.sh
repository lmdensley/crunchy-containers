#!/bin/bash


echo BUILDBASE is $BUILDBASE
#
# test setup
#
export PGPASSFILE=/tmp/testing-pgpass

if [ ! -f $PGPASSFILE ]; then
	echo "creating PGPASSFILE..."
	echo "*:*:*:*:masterpsw" > $PGPASSFILE
	chmod 400 $PGPASSFILE
fi


#
# test backup
#

sudo rm -rf /tmp/backups/master

$BUILDBASE/examples/standalone/run-backup.sh

sleep 20

FILE=/tmp/backups/master/2*/postgresql.conf

if [ -f $FILE ]; then
        echo "test backup passed"
	exit 0
fi

echo "test replica FAILED"
exit 1
