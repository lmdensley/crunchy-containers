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

echo "starting prometheus container..."

docker stop crunchy-prometheus
docker rm crunchy-prometheus

DATA_DIR=/tmp/crunchy-prometheus
sudo rm -rf $DATA_DIR
sudo mkdir -p $DATA_DIR
sudo chown root:root $DATA_DIR
sudo chcon -Rt svirt_sandbox_file_t $DATA_DIR

export HOSTIP=`hostname --ip-address`

sudo docker run \
	-p $HOSTIP:9090:9090/tcp \
	-p $HOSTIP:9091:9091/tcp \
	-v $DATA_DIR:/data \
	-e DC=dc1 \
	-e DOMAIN=crunchy.lab. \
	--name=crunchy-prometheus \
	--hostname=crunchy-prometheus \
	-d crunchydata/crunchy-prometheus:latest

sudo docker run \
	-p $HOSTIP:3000:3000/tcp \
	-v $DATA_DIR:/data \
	-e DC=dc1 \
	-e DOMAIN=crunchy.lab. \
	--link crunchy-prometheus:crunchy-prometheus \
	--name=crunchy-grafana \
	--hostname=crunchy-grafana \
	-d crunchydata/crunchy-grafana:latest
