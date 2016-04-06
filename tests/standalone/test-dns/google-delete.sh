#!/bin/bash
curl -X PUT -d '{"Datacenter": "dc1", "Node": "google"}' http://192.168.122.138:8500/v1/catalog/deregister

