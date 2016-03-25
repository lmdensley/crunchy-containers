#!/bin/bash


echo BUILDBASE is $BUILDBASE

#
# test badger
#

oc login -u system:admin
oc projects openshift
oc delete pod badger-example
oc delete service badger-example
echo "sleeping for 10 seconds to allow any existing pods/services to terminate"
sleep 10
oc process -f $BUILDBASE/examples/openshift/master-badger.json |  oc create -f -

echo "sleeping for 10 seconds to allow pods/services to startup"
sleep 10
export IP=`oc describe pod badger-example | grep IP | cut -f2 -d':' `
curl http://$IP:10000/api/badgergenerate > /dev/null

rc=$?

echo $rc is the rc

if [ 0 -eq $rc ]; then
	echo "test badger passed"
else
	echo "test badger FAILED"
	exit $rc
fi

oc delete pod badger-example
oc delete service badger-example
exit 0
