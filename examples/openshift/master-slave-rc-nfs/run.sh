#!/bin/bash
oc create -f master-slave-rc-nfs-pv.json
oc create -f master-slave-rc-nfs-pvc.json
oc process -f master-slave-rc-nfs.json | oc create -f -
