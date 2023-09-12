#!/bin/bash

echo "#### Copy yq to /usr/local/bin"
cp ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts/helper/yq/yq_linux_amd64 /usr/local/bin/yq

echo "#### Configure cluster by script"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
#./cp4a-clusteradmin-setup.sh

# 2 2 cp4ba1 2 ${API_KEY_GENERATED}
printf "%s\n" 2 2 ${CP4BANAMESPACE} 2 ${API_KEY_GENERATED} | ./cp4a-clusteradmin-setup.sh

printf "%s\n" 2 2 1 2 1 BAWDB,BAWAUDB,UMSDB,APPDB,AAEDB,AEOS,BAWTOS,BAWDOS,BAWDOCS,OS1DB,ICNDB,GCDDB nfs-managed-storage nfs-managed-storage nfs-managed-storage | ./baw-prerequisites.sh -m property