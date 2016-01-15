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

echo "starting crunchy-container..."
PGCONF=/home/jeffmc/openshift-dedicated-container/pgconf
sudo chown postgres:postgres $PGCONF
sudo chmod 0700 $PGCONF
sudo chcon -Rt svirt_sandbox_file_t $PGCONF

DATA_DIR=/tmp/crunchy-pg-data
sudo rm -rf $DATA_DIR
sudo mkdir -p $DATA_DIR
sudo chown postgres:postgres $DATA_DIR
sudo chcon -Rt svirt_sandbox_file_t $DATA_DIR
sudo docker run \
	-p 12000:5432 \
	-v $DATA_DIR:/pgdata \
	-v $PGCONF:/pgconf \
	-e TEMP_BUFFERS=9MB \
	-e MAX_CONNECTIONS=101 \
	-e SHARED_BUFFERS=129MB \
	-e MAX_WAL_SENDERS=7 \
	-e WORK_MEM=5MB \
	-e PG_MODE=standalone \
	-e PG_USER=testuser \
	-e PG_PASSWORD=testpsw \
	-e PG_DATABASE=testdb \
	--name=crunchy-pg \
	--hostname=crunchy-pg \
	-d crunchydata/crunchy-container:latest

