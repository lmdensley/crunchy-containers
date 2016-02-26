#!/bin/bash 

# Copyright 2016 Crunchy Data Solutions, Inc.
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

echo "starting badger..."

docker stop badger-example
docker rm badger-example

DATA_DIR=/tmp/crunchy-pg-data

sudo docker run \
	-p 12000:5432 \
	-v $DATA_DIR:/pgdata \
	-v $PGCONF:/pgconf \
	-e PG_MODE=master \
	-e PG_USER=testuser \
	-e PG_PASSWORD=testpsw \
	-e PG_DATABASE=testdb \
	--name=badger-example \
	--hostname=badger-example \
	-d crunchydata/crunchy-ose-pgbadger:latest

