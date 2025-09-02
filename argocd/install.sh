#!/bin/bash

set -e

helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update argocd 
kubectl create ns argocd || /bin/true
helm install \
	-f values.yaml \
	--set global.domain=argocd.$(cat ~/DNS_NAME) \
	argocd \
	argocd/argo-cd \
	-n argocd \
	--version 8.3.3 && \
kubectl apply -f config -R

export ARGOCD_SERVER=argocd.$(cat ~/DNS_NAME)
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


