#!/bin/bash
IPADDRESS=`hostname --ip-address`
cat master-restore-nfs-pv.json | sed -e 's/IPADDRESS/$IPADDRESS' | oc create -f  -
oc create -f master-restore-nfs-pvc.json
oc process -f master-restore-nfs.json | oc create -f -
