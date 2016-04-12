#!/bin/bash

IPADDRESS=`hostname --ip-address`

cat master-nfs-badger-pv.json | sed -e "s/IPADDRESS/$IPADDRESS/g" | oc create -f -
oc create -f master-nfs-badger-pvc.json
oc process -f master-nfs-badger.json | oc create -f -
