#!/bin/bash

echo "#### Apply CR"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/generated-cr
oc apply -f ibm_cp4a_cr_final.yaml