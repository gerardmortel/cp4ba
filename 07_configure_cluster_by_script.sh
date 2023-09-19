#!/bin/bash

echo "#### Configure the cluster by script"

echo "#### Logout as user and in as cluster admin"
oc logout
oc login ${CLUSTER_URL} --username=${CLUSTER_USER} --password=${CLUSTER_PASS}
oc project ${CP4BANAMESPACE}

echo "#### Copy yq to /usr/local/bin"
cp -f ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/helper/yq/yq_linux_amd64 /usr/local/bin/yq

if [ ${IS_FIRST_CLOUDPAK_IN_CLUSTER} == "false"  ]; then
  echo "#### This is not the first cloudpak in the cluster. The response needs an extra Yes to confirm installation"
  #### cp4ba1 namespace
./cp4a-clusteradmin-setup.sh <<END
2
2
${CP4BANAMESPACE}
Yes
2
Yes
${API_KEY_GENERATED}
END
else
  echo "#### This is the first cloudpak in the cluster.  The response does not need an extra Yes to confirm installation"
./cp4a-clusteradmin-setup.sh <<END
2
2
Yes
${CP4BANAMESPACE}
2
Yes
${API_KEY_GENERATED}
END
fi