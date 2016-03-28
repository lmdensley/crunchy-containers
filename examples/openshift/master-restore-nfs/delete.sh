#!/bin/bash
oc delete pod master-restore-nfs
oc delete pvc master-restore-nfs-pvc
oc delete pv master-restore-nfs-pv
