#!/bin/bash

helm repo add argocd https://argoproj.github.io/argo-helm && \
helm repo update argocd && \
kubectl create ns argocd && \
helm install \
	-f values.yaml \
	--set global.domain=argocd.$(cat ~/DNS_NAME) \
	argocd \
	argocd/argo-cd \
	-n argocd \
	--version 8.3.3

echo "The web interface will be at:"
echo "https://argocd.$(cat ~/DNS_NAME)"
echo
echo "username: admin"
ARGOCD_ADMIN_PASS=$(kubectl get secret \
    -n argocd \
    argocd-initial-admin-secret \
    -o jsonpath='{.data.password}' \
    | base64 -d)
echo "password: $ARGOCD_ADMIN_PASS"


