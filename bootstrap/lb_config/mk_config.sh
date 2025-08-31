#!/bin/bash
#
echo "{ \"arn\": \"$(cat ~/CERT_ARN)\" }" | jinja2 icp.yaml.template | kubectl apply -f -
kubectl apply -f ic.yaml
