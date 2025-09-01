#!/bin/bash

./request_cert.sh
eksctl create cluster -f cluster.yaml
./lbc.sh
