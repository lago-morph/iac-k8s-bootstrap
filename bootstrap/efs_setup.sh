#!/bin/bash
#
# This roughly follows the instructions here:
# https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/efs-create-filesystem.md

set -e

CLUSTER_NAME=cluster
CLUSTER_INFO=$(aws eks describe-cluster --name $CLUSTER_NAME)

################################################################
# Grab information about the cluster VPC
################################################################

vpc_id=$(echo $CLUSTER_INFO | jq -r .cluster.resourcesVpcConfig.vpcId)
echo "Setting up EFS PVCs for VPC ID $vpc_id"

cidr_range=$(aws ec2 describe-vpcs \
    --vpc-ids $vpc_id \
    --query "Vpcs[].CidrBlock" \
    --output text \
    --region ${AWS_DEFAULT_REGION})

echo "VPC has CIDR range $cidr_range"

################################################################
# Create security group allowing access from VPC CIDR range
################################################################

GROUP_NAME=EfsEKSSecurityGroup
security_group_id=$(aws ec2 create-security-group \
    --group-name $GROUP_NAME \
    --description "EFS security group" \
    --vpc-id $vpc_id \
    --query "GroupId" \
    --output text)

echo "Created security group $security_group_id"

# for debugging can delete this with:
# aws ec2 delete-security-group --group-id $(aws ec2 describe-security-groups | jq -r ".SecurityGroups[] | select(.GroupName==\"$GROUP_NAME\").GroupId" )

# give NFS access to security group from VPC
aws ec2 authorize-security-group-ingress \
    --group-id $security_group_id \
    --protocol tcp \
    --port 2049 \
    --cidr $cidr_range

echo "Authorized access from CIDR range $cidr_range"
echo "  to security group $security_group_id"

################################################################
# Create an EFS file system 
################################################################

file_system_id=$(aws efs create-file-system \
    --region ${AWS_DEFAULT_REGION} \
    --performance-mode generalPurpose \
    --query 'FileSystemId' \
    --output text)

echo "Created EFS file system $file_system_id"
echo $file_system_id > ~/EFS_FILE_SYSTEM_ID

################################################################
# Create access points for file system in each subnet
################################################################

while [[ "$(aws efs describe-file-systems --file-system-id `cat ~/EFS_FILE_SYSTEM_ID` --query "FileSystems[0].LifeCycleState" --output text)" != "available" ]]; do
    echo "waiting for file system to be available..."
    sleep 1
done
echo "file system $file_system_id is available"

subnets=$(echo $CLUSTER_INFO | jq -r .cluster.resourcesVpcConfig.subnetIds[])

for subnet in $subnets; do
    aws efs create-mount-target \
        --file-system-id $file_system_id \
        --subnet-id $subnet \
        --security-groups $security_group_id
    echo "Created EFS access point for subnet $subnet"
done

echo "Successfully set up EFS file system and access points for VPC $vpc_id"

################################################################
# Create storage classes
#   - efs-sc is default class using EFS as a provider
#   - efs-uid-xxx-sc make the owner uid and gid display as xxx.  
#     Required by e.g., PostgreSQL
################################################################

# avoid storage class create timeout (?)
sleep 10

jinja2 -D filesystemid=$file_system_id storageclasses.j2 | kubectl apply -f -
