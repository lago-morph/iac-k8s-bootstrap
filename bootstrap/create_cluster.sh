#!/bin/bash

eksctl create cluster -f cluster.yaml && \
eksctl create nodegroup -f nodegroup.yaml && \
eksctl create addon -f pre_addon.yaml && \
eksctl create addon -f addon.yaml 
