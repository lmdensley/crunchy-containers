#!/bin/bash

IPADDRESS=`hostname --ip-address`
cat $BUILDBASE/examples/openshift/master-restore/master-restore-pv.json | sed -e "s/IPADDRESS/$IPADDRESS/g" | oc create -f -

oc create -f master-restore-pvc.json
oc process -f master-restore.json | oc create -f -
