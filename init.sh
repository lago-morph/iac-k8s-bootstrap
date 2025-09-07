#!/bin/bash
#

set -e

pushd bootstrap
./create_cluster.sh
./efs_setup.sh
popd
pushd argocd
./install.sh
popd
