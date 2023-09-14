#!/bin/bash

echo "#### Create secrets"
# find . -name "*.yaml" -type f | xargs -I{} kubectl apply -f {}
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/cp4ba-prerequisites
./create_secret.sh