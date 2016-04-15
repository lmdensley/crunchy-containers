#!/bin/bash
oc delete secret pguser-secret
oc delete pod secret-pg
oc delete service secret-pg
