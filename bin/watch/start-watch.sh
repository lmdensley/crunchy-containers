#!/bin/bash  -x

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

#export OSE_HOST=openshift.default.svc.cluster.local
export SLEEP_TIME=$SLEEP_TIME
export PG_MASTER_SERVICE=$PG_MASTER_SERVICE
export PG_SLAVE_SERVICE=$PG_SLAVE_SERVICE
export PG_MASTER_PORT=$PG_MASTER_PORT
export PG_MASTER_USER=$PG_MASTER_USER
export PG_USER=$PG_USER
export PG_DATABASE=$PG_DATABASE


export PATH=$PATH:/opt/cpm/bin:/usr/pgsql-9.5/bin

function failover() {
	if [[ -v OSE_HOST ]]; then
		echo "openshift failover ....."
		ose_failover
	else
		echo "standalone failover....."
		standalone_failover
	fi
}

function standalone_failover() {
	echo "standalone failover is called"

	# env var is required to talk to older docker
	# server using a more recent docker client
	export DOCKER_API_VERSION=1.20
	echo "creating the trigger file on " $PG_MASTER_SERVICE
	docker exec -it $PG_MASTER_SERVICE touch /tmp/pg-failover-trigger
}

function ose_failover() {
	TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
	oc login https://$OSE_HOST --insecure-skip-tls-verify=true --token="$TOKEN"
	echo "performing failover..."
	oc get pod --selector=name=$PG_SLAVE_SERVICE
	oc exec -it $PG_SLAVE_SERVICE 'touch /tmp/pg-failover-trigger'
	oc label --overwrite=true pod $PG_SLAVE_SERVICE name=$PG_MASTER_SERVICE
	echo "sleeping 15 seconds to give failover a chance to work..."
	sleep 15
	echo "failover completed @ " `date`
}

while true; do 
	sleep $SLEEP_TIME
	pg_isready  --dbname=$PG_DATABASE --host=$PG_MASTER_SERVICE --port=$PG_MASTER_PORT --username=$PG_MASTER_USER
	if [ $? -eq 0 ]
	then
		echo "Successfully reached master @ " `date`
	else
		echo "Could not reach master @ " `date`
		failover
		exit 0
	fi
done