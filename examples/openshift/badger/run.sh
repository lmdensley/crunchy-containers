#!/bin/bash
oc process -f master-badger.json | oc create -f -
