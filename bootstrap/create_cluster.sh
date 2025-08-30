#!/bin/bash

eksctl create cluster -f cluster.yaml && \
eksctl create addon -f addon.yaml && \
eksctl create nodegroup -f nodegroup.yaml
