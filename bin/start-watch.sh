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

export OSE_HOST=openshift.default.svc.cluster.local
export PG_MASTER_SERVICE=$PG_MASTER_SERVICE
export PG_SLAVE_SERVICE=$PG_SLAVE_SERVICE
export PG_MASTER_PORT=$PG_MASTER_PORT
export PG_MASTER_USER=$PG_MASTER_USER
export PG_USER=$PG_USER
export PG_DATABASE=$PG_DATABASE

TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

export PATH=$PATH:/opt/cpm/bin:/usr/pgsql-9.5/bin

function failover() {
	oc login https://$OSE_HOST --insecure-skip-tls-verify=true --token="$TOKEN"
	echo "performing failover..."
	oc get pod --selector=name=pg-slave-rc
	oc exec -it pg-slave-rc-1-lt5a5 'touch /tmp/pg-failover-trigger'
	oc label --overwrite=true pod pg-slave-rc-1-lt5a5 name=pg-master-rc
	echo "sleeping 15 seconds to give failover a chance to work..."
	sleep 15
	echo "failover completed @ " `date`
}

while true; do 
	sleep 10
	pg_isready  --dbname=postgres --host=pg-master --port=5432 --username=testuser
	if [ $? -eq 0 ]
	then
		echo "Successfully reached master @ " `date`
	else
		echo "Could not reach master @ " `date`
		failover
	fi
done
