#!/bin/bash
oc process -f master-collect.json | oc create -f -
