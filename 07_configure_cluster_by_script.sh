#!/bin/bash

echo "#### Configure the cluster by script"

echo "#### Logout as user and in as cluster admin"
oc logout
oc login ${CLUSTER_URL} --username=${CLUSTER_USER} --password=${CLUSTER_PASS}
oc project ${CP4BANAMESPACE}

echo "#### Copy yq to /usr/local/bin"
cp -f ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/helper/yq/yq_linux_amd64 /usr/local/bin/yq

echo "#### Configure cluster by script"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
./cp4a-clusteradmin-setup.sh <<END
2
2
Yes
${CP4BANAMESPACE}
2
Yes
${API_KEY_GENERATED}
END