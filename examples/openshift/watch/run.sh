#!/bin/bash
oc create -f $BUILDBASE/examples/openshift/watch/watch-sa.json
oc policy add-role-to-group edit system:serviceaccounts -n openshift
oc policy add-role-to-group edit system:serviceaccounts -n default
oc create -f $BUILDBASE/examples/openshift/watch/watch.json
