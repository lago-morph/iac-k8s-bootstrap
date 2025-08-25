define DOCS
Convenience helpers for Watch and Chill IaC

backend-init    Create S3 bucket, DynamoDB table, and output to backend.tf
kubectl         Update kubectl with auth from Terraform run

endef

MAKEFLAGS += --jobs

.ONESHELL:

# dummy target does nothing when make without arguments
export DOCS
show-usage: 
	@echo "$$DOCS"

kubectl: AWS_REGION = $(shell terraform output -raw region)
kubectl: AWS_EKS_NAME = $(shell terraform output -raw eks_cluster_name)
kubectl:
	aws eks update-kubeconfig --region $(AWS_REGION) --name $(AWS_EKS_NAME)

create-resources:
	aws s3 mb s3://$(S3B)
	aws dynamodb create-table \
		  --table-name $(DDBNAME) \
		  --key-schema AttributeName=$(DDBKEY),KeyType=HASH \
		  --attribute-definitions AttributeName=$(DDBKEY),AttributeType=S \
		  --billing-mode PAY_PER_REQUEST \
		  --no-cli-pager

output-file:
	cat <<EOF > $(TFBACKENDFILE)
	terraform {
	  backend "s3" {
	    bucket                 = "$(S3B)"
	    region                 = "$(REGION)"
	    key                    = "backend.tfstate"
	    dynamodb_table         = "$(DDBNAME)"
	  }
	}
	EOF

backend-init: S3B := chiller-state-bucket-$(shell openssl rand -hex 10)
backend-init: DDBNAME = terraformstatelock-$(shell openssl rand -hex 10)
backend-init: DDBKEY = LockID
backend-init: REGION = $(shell aws configure get region)
backend-init: TFBACKENDFILE := backend.tf

backend-init: create-resources output-file
	terraform fmt

