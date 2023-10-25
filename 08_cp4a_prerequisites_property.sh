#!/bin/bash

echo "#### Create property files"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
./cp4a-prerequisites.sh -m property <<END
2

1
2
3

2
${STORAGECLASS}
${STORAGECLASS}
${STORAGECLASS}
${STORAGECLASS}
1
dbserver1
END