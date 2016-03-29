#!/bin/bash
oc delete pod master-restore
oc delete service master-restore
oc delete pvc master-restore-pvc
oc delete pv master-restore-pv
