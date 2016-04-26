#!/bin/bash
oc process -f $BUILDBASE/examples/openshift/pgpooltest/pgpool-rc.json | oc create -f -
