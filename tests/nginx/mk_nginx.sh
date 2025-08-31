#!/bin/bash
#
kubectl apply -f pod.yaml -f service.yaml
echo "{ \"dnsName\": \"$(cat ~/DNS_NAME)\" }" | jinja2 ingress.yaml.template | kubectl apply -f -
