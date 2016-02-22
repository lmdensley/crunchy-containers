TOKEN="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

curl --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
	    "https://openshift.default.svc.cluster.local/api/v1" \
	        -H "Authorization: Bearer $TOKEN"
#    "https://openshift.default.svc.cluster.local/api/v1/namespaces/pgproject/pods" \
	#    "https://openshift.default.svc.cluster.local/oapi/v1" \
	#    "https://openshift.default.svc.cluster.local/oapi/v1/projects" \
	/opt/cpm/bin/oc login https://openshift.default.svc.cluster.local --insecure-skip-tls-verify=true --token="$TOKEN"
/opt/cpm/bin/oc get pods


