#!/bin/bash
oc delete job master-dba-vacuum-job
oc delete sa dba-sa
oc delete pod master-dba
oc delete service master-dba
