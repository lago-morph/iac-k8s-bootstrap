#!/bin/bash
#

set -e

pushd bootstrap
./create_cluster.sh
popd
pushd argocd
./install.sh
popd
