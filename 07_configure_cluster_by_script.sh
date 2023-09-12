#!/bin/bash

echo "#### Copy yq to /usr/local/bin"
cp ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/helper/yq/yq_linux_amd64 /usr/local/bin/yq

echo "#### Configure cluster by script"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
./cp4a-clusteradmin-setup.sh