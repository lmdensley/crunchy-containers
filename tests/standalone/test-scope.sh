#!/bin/bash


echo BUILDBASE is $BUILDBASE

#
# test scope
# requires nmap-ncat RPM!
#

docker stop crunchy-grafana
docker stop crunchy-scope

$BUILDBASE/examples/standalone/run-scope.sh

sleep 60

PROMETHEUS=`docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' crunchy-scope`
GRAFANA=`docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' crunchy-grafana`

curl http://$PROMETHEUS:9090 > /dev/null
rc=$?
echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "prometheus port open"
else
	echo "test scope prometheus FAILED"
	exit $rc
fi
curl http://$PROMETHEUS:9091 > /dev/null
rc=$?
echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "prometheus push gateway port open"
else
	echo "test scope prometheus push gateway FAILED"
	exit $rc
fi

curl http://$GRAFANA:3000 > /dev/null
rc=$?
echo $rc is the grafana rc

if [ 0 -eq $rc ]; then
	echo grafana port open
	echo "test scope passed"
else
	echo "test scope grafana FAILED"
	exit $rc
fi

exit 0
