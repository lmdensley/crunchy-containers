#!/bin/bash
oc delete dc m-s-rc-nfs-slave
oc delete pod m-s-rc-nfs-master 
oc delete pod ms-s-rc-nfs-slave
oc delete service m-s-rc-nfs-master
oc delete service m-s-rc-nfs-slave
oc delete pvc master-slave-rc-nfs-pvc
oc delete pv  master-slave-rc-nfs-pv
sudo rm -rf /nfsfileshare/m-s-rc-nfs*
