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

echo "starting scope containers..."

docker stop crunchy-scope
docker rm crunchy-scope
docker stop crunchy-grafana
docker rm crunchy-grafana

DATA_DIR=/tmp/crunchy-scope
sudo rm -rf $DATA_DIR
sudo mkdir -p $DATA_DIR
sudo chown root:root $DATA_DIR
sudo chcon -Rt svirt_sandbox_file_t $DATA_DIR

export HOSTIP=`hostname --ip-address`

sudo docker run \
	-p $HOSTIP:9090:9090/tcp \
	-p $HOSTIP:9091:9091/tcp \
	-v $DATA_DIR:/data \
	--name=crunchy-scope \
	--hostname=crunchy-scope \
	-d crunchydata/crunchy-prometheus:latest

sudo docker run \
	-p $HOSTIP:3000:3000/tcp \
	-v $DATA_DIR:/data \
	--link crunchy-scope:crunchy-scope \
	--name=crunchy-grafana \
	--hostname=crunchy-grafana \
	-d crunchydata/crunchy-grafana:latest
