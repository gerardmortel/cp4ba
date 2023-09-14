#!/bin/bash

echo "#### Generate the final CR"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
./cp4a-prerequisites.sh -m generate
