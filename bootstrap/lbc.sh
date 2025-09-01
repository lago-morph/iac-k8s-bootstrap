#!/bin/bash

set -e

# get policy
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json

# create policy and parse ARN
POLICY_RESP=$(aws iam create-policy \
   	--policy-name AWSLoadBalancerControllerIAMPolicy \
   	--policy-document file://iam_policy.json) && \
	rm iam_policy.json
POLICY_ARN=$(echo $POLICY_RESP | jq -r .Policy.Arn)

# enable cluster OIDC provider
eksctl utils associate-iam-oidc-provider \
	--cluster cluster \
	--approve

# create service account for LBC
eksctl create iamserviceaccount \
	--cluster cluster \
	--namespace=kube-system \
	--name=aws-load-balancer-controller \
	--attach-policy-arn $POLICY_ARN \
	--override-existing-serviceaccounts \
	--region $AWS_DEFAULT_REGION \
	--approve

helm repo add eks https://aws.github.io/eks-charts && \
helm repo update eks && \
        helm install aws-load-balancer-controller \
	eks/aws-load-balancer-controller   \
	-n kube-system   \
	--set clusterName=cluster   \
	--set serviceAccount.create=false   \
	--set serviceAccount.name=aws-load-balancer-controller   \
	--version 1.13.0

