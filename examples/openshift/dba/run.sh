#!/bin/bash

oc create -f dba-sa.json

oc policy add-role-to-group edit system:serviceaccounts -n openshift
oc policy add-role-to-user view system:serviceaccount:openshift:dba-sa

#
# this next commands lets the dba-sa service account have
# the permissions of 'cluster-admin' which allows it
# to create and delete PV and PVCs required by the backup job
# capability of the dba container
#
oadm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift:dba-sa

oc process -f master-dba.json | oc create -f -
