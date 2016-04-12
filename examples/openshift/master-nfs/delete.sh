#!/bin/bash
oc delete pod master-nfs
oc delete pvc master-nfs-pvc
oc delete pv master-nfs-pv
