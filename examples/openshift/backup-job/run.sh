#!/bin/bash
oc create -f backup-job-pv.json
oc create -f backup-job-pvc.json
oc create -f backup-job-nfs.json
