#!/bin/bash

echo "#### Create property files"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
printf "%s\n" 2 <enter> 1 2 3 <enter> 2 nfs-managed-storage nfs-managed-storage nfs-managed-storage nfs-managed-storage 1 dbserver1 | ./cp4a-prerequisites.sh -m property