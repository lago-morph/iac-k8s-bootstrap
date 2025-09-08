#!/bin/bash

set -e

DNS_NAME=$(kubectl get cm dns-name -n default -o jsonpath={.data.dns-name})
export ARGOCD_SERVER=argocd.${DNS_NAME}

helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update argocd 
kubectl create ns argocd || /bin/true
helm install \
	-f values.yaml \
	--set global.domain=$ARGOCD_SERVER \
	argocd \
	argocd/argo-cd \
	-n argocd \
	--version 8.3.3 && \

jinja2 -D dnsName=$DNS_NAME cluster.yaml.j2 | kubectl apply -f -
kubectl apply -f config -R

echo "waiting for initial admin secret to be created..."
kubectl wait --for=create secret/argocd-initial-admin-secret -n argocd --timeout=30s
echo
export ARGOCD_PASSWORD=$(kubectl get secret \
    -n argocd \
    argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' \
    | base64 -d)
export ARGOCD_USER=admin

echo "The web interface will be at:"
echo "https://${ARGOCD_SERVER}"
echo
echo "username: $ARGOCD_USER"
echo "password: $ARGOCD_PASSWORD"
echo
echo "It will take some time for the load balancer to provision"
echo
echo "you can watch for the status of the load balancer with:"
echo "aws elbv2 describe-load-balancers --query "LoadBalancers[].State" --output text"


