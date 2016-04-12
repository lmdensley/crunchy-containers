#!/bin/bash
oc delete pod master-nfs-badger
oc delete pvc master-nfs-badger-pvc
oc delete pv master-nfs-badger-pv
