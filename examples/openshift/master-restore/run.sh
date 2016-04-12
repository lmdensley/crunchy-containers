#!/bin/bash
cat master-restore-pv.json | sed -e 's/IPADDRESS/$IPADDRESS' | oc create -f -
oc create -f master-restore-pvc.json
oc process -f master-restore.json | oc create -f -
