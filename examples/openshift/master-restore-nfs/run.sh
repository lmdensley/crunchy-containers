#!/bin/bash
oc create -f master-restore-nfs-pv.json
oc create -f master-restore-nfs-pvc.json
oc process -f master-restore-nfs.json | oc create -f -
