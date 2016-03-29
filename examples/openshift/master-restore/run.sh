#!/bin/bash
oc create -f master-restore-pv.json
oc create -f master-restore-pvc.json
oc process -f master-restore.json | oc create -f -
