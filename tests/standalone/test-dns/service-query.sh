#!/bin/bash
# format for query:
# 	[tag.]<service>.service[.datacenter].<domain>

dig @192.168.122.138 -p 8600 jeff.service.dc1.consul. ANY

