#!/bin/bash

#
# run a vacuum job
#

oc create -f dba-sa.json

oc policy add-role-to-group edit system:serviceaccounts -n openshift
oc policy add-role-to-user view system:serviceaccount:openshift:dba-sa

oc process -f master-dba-vac.json | oc create -f -
