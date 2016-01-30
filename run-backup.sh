#!/bin/bash 


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

echo "starting backup container..."

PGDATA=/tmp/backups

if [ ! -d "$PGDATA" ]; then
	echo "creating pgdata directory..."
	mkdir -p $PGDATA
fi

chown postgres:postgres $PGDATA
chcon -Rt svirt_sandbox_file_t $PGDATA

docker rm masterbackup

docker run \
	-v $PGDATA:/pgdata \
	-e BACKUP_HOST=192.168.122.71 \
	-e BACKUP_USER=masteruser \
	-e BACKUP_PASS=masterpsw \
	-e BACKUP_PORT=12000 \
	--name=masterbackup \
	--hostname=masterbackup \
	-d crunchydata/crunchy-backup:latest

