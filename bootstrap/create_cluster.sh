#!/bin/bash

eksctl create cluster -f cluster.yaml
./request_cert.sh
./lbc.sh
