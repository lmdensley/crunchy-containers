#!/bin/bash
curl -X PUT http://192.168.122.138:8500/v1/agent/service/register \
-d @jeff.json --header "Content-Type: application/json"

