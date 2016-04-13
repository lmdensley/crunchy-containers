#!/bin/bash

IPADDRESS=`hostname --ip-address`
cat $BUILDBASE/examples/openshift/scope/scope-pv.json | sed -e "s/IPADDRESS/$IPADDRESS/g" | oc create -f -
oc create -f $BUILDBASE/examples/openshift/scope/scope-pvc.json
oc process -f $BUILDBASE/examples/openshift/scope/scope-nfs.json | oc create -f -
