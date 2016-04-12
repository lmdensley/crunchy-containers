#!/bin/bash

IPADDRESS=`hostname --ip-address`
cat backup-job-pv.json | sed -e "s/IPADDRESS/$IPADDRESS/g" | oc create -f -
oc create -f backup-job-pvc.json
oc create -f backup-job-nfs.json
