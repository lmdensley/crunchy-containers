#!/bin/bash
oc create -f $BUILDBASE/examples/openshift/watchtest/watch-sa.json
oc policy add-role-to-group edit system:serviceaccounts -n openshift
oc policy add-role-to-group edit system:serviceaccounts -n default
oc process -f $BUILDBASE/examples/openshift/watchtest/watch.json | oc create -f -
