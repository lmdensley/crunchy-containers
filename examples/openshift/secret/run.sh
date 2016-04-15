#!/bin/bash
oc create -f pguser-secret-pg 
oc process -f secret-pg | oc create -f -
