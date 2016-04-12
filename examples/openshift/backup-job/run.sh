#!/bin/bash

IPADDRESS=`hostname --ip-address`
cat $BUILDBASE/examples/openshift/backup-job/backup-job-pv.json | sed -e "s/IPADDRESS/$IPADDRESS/g" | oc create -f -
oc create -f $BUILDBASE/examples/openshift/backup-job/backup-job-pvc.json
oc create -f $BUILDBASE/examples/openshift/backup-job/backup-job-nfs.json
