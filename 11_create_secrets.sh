#!/bin/bash

echo "#### Create secrets"
# find . -name "*.yaml" -type f | xargs -I{} kubectl apply -f {}
cd /root/cp4ba-23.0.1/ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/cp4ba-prerequisites
./create_secret.sh

# # Create the ibm-entitlement-key secret
# oc delete secret ibm-entitlement-key
# oc create secret docker-registry ibm-entitlement-key \
# --docker-username=cp \
# --docker-password="${API_KEY_GENERATED}" \
# --docker-server=cp.icr.io