#!/bin/bash
IPADDRESS=`hostname --ip-address`
cat master-slave-rc-nfs-pv.json | sed -e "s/IPADDRESS/$IPADDRESS/g" | oc create -f -
oc create -f master-slave-rc-nfs-pvc.json
oc process -f master-slave-rc-nfs.json | oc create -f -
