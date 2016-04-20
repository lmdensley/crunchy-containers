#!/bin/bash

oc create -f dba-sa.json

oc policy add-role-to-group edit system:serviceaccounts -n openshift
oc policy add-role-to-group edit system:serviceaccounts -n default

oc process -f master-dba.json | oc create -f -
