#!/bin/bash

IPADDRESS=`hostname --ip-address`
cat master-nfs-pv.json | sed -e "s/IPADDRESS/$IPADDRESS/g" | oc create -f -
oc create -f master-nfs-pvc.json
oc process -f master-nfs.json | oc create -f -
