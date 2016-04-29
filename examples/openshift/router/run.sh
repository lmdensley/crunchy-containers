#!/bin/bash

docker pull registry.access.redhat.com/openshift3/ose-haproxy-router:latest

CA=/etc/origin/master
oadm ca create-server-cert --signer-cert=$CA/ca.crt \
	      --signer-key=$CA/ca.key --signer-serial=$CA/ca.serial.txt \
	            --hostnames='*.apps.crunchy.lab' \
		          --cert=cloudapps.crt --key=cloudapps.key


cat cloudapps.crt cloudapps.key $CA/ca.crt > cloudapps.router.pem


oadm router --replicas=1 --default-cert=cloudapps.router.pem --credentials='/etc/origin/master/openshift-router.kubeconfig' --service-account=router

iptables -I OS_FIREWALL_ALLOW -p tcp -m tcp --dport 1936 -j ACCEPT


