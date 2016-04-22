#!/bin/bash
oc delete job master-dba-vac
oc delete job master-dba-backup
oc delete sa dba-sa
oc delete pod master-dba
oc delete service master-dba
