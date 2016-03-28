#!/bin/bash

echo BUILDBASE is $BUILDBASE
#
# test backup
#

oc login -u system:admin
oc projects openshift
oc delete pvc scope-pvc
oc delete pv scope-pv
oc delete pod crunchy-scope
oc delete service crunchy-scope

sleep 30

oc create -f $BUILDBASE/examples/openshift/scope-pv.json
oc create -f $BUILDBASE/examples/openshift/scope-pvc.json
oc process -f $BUILDBASE/examples/openshift/scope.json | oc create -f -

echo "sleeping for 20 seconds to allow pods/services to startup"
sleep 20
export IP=`oc describe pod test-crunchy-scope | grep IP | cut -f2 -d':' `
echo $IP " is the IP address"

curl http://$IP:9090
rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "prometheus test passed"
else
	echo "prometheus test FAILED"
	exit $rc
fi
curl http://$IP:9091
rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "prometheus pushgateway test passed"
else
	echo "prometheus pushgateway test FAILED"
	exit $rc
fi
curl http://$IP:3000
rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "grafana test passed"
else
	echo "grafana test FAILED"
	exit $rc
fi

oc delete pod crunchy-scope
oc delete service  crunchy-scope

exit 0
