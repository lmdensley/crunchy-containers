#!/bin/bash
oc delete pvc  scope-pvc
oc delete pv scope-pv
oc delete pod crunchy-scope
oc delete service crunchy-scope
