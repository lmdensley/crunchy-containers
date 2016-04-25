#!/bin/bash

source $BUILDBASE/tests/standalone/pgpass-setup

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

echo "test backup FAILED"
exit 1
