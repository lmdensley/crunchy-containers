#!/bin/bash -x

# Copyright 2015 Crunchy Data Solutions, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# start pg, will initdb if /pgdata is empty as a way to bootstrap
#

source /opt/cpm/bin/setenv.sh

function check_for_overrides() {
	if [ -f /pgconf/postgresql.conf ]; then
        	echo "pgconf postgresql.conf is being used"
#		cp /pgconf/postgresql.conf $PGDATA
	fi
	if [ -f /pgconf/pg_hba.conf ]; then
        	echo "pgconf pg_hba.conf is being used"
#		cp /pgconf/pg_hba.conf $PGDATA
	fi
}

function fill_conf_file() {
	if [[ -v TEMP_BUFFERS ]]; then
		echo "overriding TEMP_BUFFERS setting to " + $TEMP_BUFFERS
	else
		TEMP_BUFFERS=8MB
	fi
	if [[ -v MAX_CONNECTIONS ]]; then
		echo "overriding MAX_CONNECTIONS setting to " + $MAX_CONNECTIONS
	else
		MAX_CONNECTIONS=100
	fi
	if [[ -v SHARED_BUFFERS ]]; then
		echo "overriding SHARED_BUFFERS setting to " + $SHARED_BUFFERS
	else
		SHARED_BUFFERS=128MB
	fi
	if [[ -v WORK_MEM ]]; then
		echo "overriding WORK_MEM setting to " + $WORK_MEM
	else
		WORK_MEM=4MB
	fi
	if [[ -v MAX_WAL_SENDERS ]]; then
		echo "overriding MAX_WAL_SENDERS setting to " + $MAX_WAL_SENDERS
	else
		MAX_WAL_SENDERS=6
	fi

	cp /opt/cpm/conf/postgresql.conf.template /tmp/postgresql.conf
	sed -i "s/TEMP_BUFFERS/$TEMP_BUFFERS/g" /tmp/postgresql.conf
	sed -i "s/MAX_CONNECTIONS/$MAX_CONNECTIONS/g" /tmp/postgresql.conf
	sed -i "s/SHARED_BUFFERS/$SHARED_BUFFERS/g" /tmp/postgresql.conf
	sed -i "s/MAX_WAL_SENDERS/$MAX_WAL_SENDERS/g" /tmp/postgresql.conf
	sed -i "s/WORK_MEM/$WORK_MEM/g" /tmp/postgresql.conf
}

function initialize_replica() {
cd /tmp  
cat >> ".pgpass" <<-EOF
*:*:*:*:${PG_MASTER_PASSWORD}
EOF
chmod 0600 .pgpass
export PGPASSFILE=/tmp/.pgpass
rm -rf $PGDATA/*
chmod 0700 $PGDATA

echo "sleeping 30 seconds to give the master time to start up before performing the initial backup...."
sleep 30

pg_basebackup -x --no-password --pgdata $PGDATA --host=$PG_MASTER_HOST --port=$PG_MASTER_PORT -U $PG_MASTER_USER

# PostgreSQL recovery configuration.
cp /opt/cpm/conf/pgrepl-recovery.conf /tmp
sed -i "s/PG_MASTER_USER/$PG_MASTER_USER/g" /tmp/pgrepl-recovery.conf
sed -i "s/PG_MASTER_HOST/$PG_MASTER_HOST/g" /tmp/pgrepl-recovery.conf
sed -i "s/PG_MASTER_PORT/$PG_MASTER_PORT/g" /tmp/pgrepl-recovery.conf
cp /tmp/pgrepl-recovery.conf $PGDATA/recovery.conf
}

#
# the initial start of postgres will create the database
#
function initialize_master() {
if [ ! -f $PGDATA/postgresql.conf ]; then
        echo "pgdata is empty and id is..."
	id
	mkdir -p $PGDATA
	initdb -D $PGDATA  > /tmp/initdb.log &> /tmp/initdb.err

	echo "overlay pg config with your settings...."
	cp /tmp/postgresql.conf $PGDATA
	cp /opt/cpm/conf/pg_hba.conf /tmp
	sed -i "s/PG_MASTER_USER/$PG_MASTER_USER/g" /tmp/pg_hba.conf
	cp /tmp/pg_hba.conf $PGDATA

	check_for_overrides
        echo "starting db" >> /tmp/start-db.log
	if [ -f /pgconf/postgresql.conf ]; then
        	echo "pgconf postgresql.conf is being used with PGDATA=" $PGDATA
		postgres -c config_file=/pgconf/postgresql.conf -c hba_file=/pgconf/pg_hba.conf -D $PGDATA &
	else
        	echo "normal postgresql.conf is being used"
		pg_ctl -D $PGDATA start
	fi

        sleep 3

        echo "loading setup.sql" >> /tmp/start-db.log
	cp /opt/cpm/bin/setup.sql /tmp
	sed -i "s/PG_MASTER_USER/$PG_MASTER_USER/g" /tmp/setup.sql
	sed -i "s/PG_MASTER_PASSWORD/$PG_MASTER_PASSWORD/g" /tmp/setup.sql
	sed -i "s/PG_USER/$PG_USER/g" /tmp/setup.sql
	sed -i "s/PG_PASSWORD/$PG_PASSWORD/g" /tmp/setup.sql
	sed -i "s/PG_DATABASE/$PG_DATABASE/g" /tmp/setup.sql
	sed -i "s/PG_ROOT_PASSWORD/$PG_ROOT_PASSWORD/g" /tmp/setup.sql

        psql -U postgres < /tmp/setup.sql
	pg_ctl -D $PGDATA stop
fi
}

#
# clean up any old pid file that might have remained
# during a bad shutdown of the container/postgres
#
rm $PGDATA/postmaster.pid
#
# the normal startup of pg
#
#export USER_ID=$(id -u)
#cp /opt/cpm/conf/passwd /tmp
#sed -i "s/USERID/$USER_ID/g" /tmp/passwd
#export LD_PRELOAD=libnss_wrapper.so NSS_WRAPPER_PASSWD=/tmp/passwd  NSS_WRAPPER_GROUP=/etc/group
echo "user id is..."
id

fill_conf_file


case "$PG_MODE" in 
	"slave")
	echo "working on slave"
	initialize_replica
	;;
	"master")
	echo "working on master..."
	initialize_master
	;;
esac

if [ -f /pgconf/postgresql.conf ]; then
       	echo "pgconf postgresql.conf is being used"
	postgres -c config_file=/pgconf/postgresql.conf -c hba_file=/pgconf/pg_hba.conf -D $PGDATA 
else
	postgres -D $PGDATA 
fi

