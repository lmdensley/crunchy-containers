#!/bin/bash

FILE=/tmp/backups/master/2*/postgresql.conf
echo $FILE is the file
if [ -f $FILE ]; then
	echo "test backup passed"
        exit 0
fi
