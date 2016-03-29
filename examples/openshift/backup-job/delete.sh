#!/bin/bash
oc delete job backup-job-nfs
oc delete pvc backup-job-pvc
oc delete pv backup-job-pv
