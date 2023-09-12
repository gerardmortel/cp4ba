#!/bin/bash

# Generate property files
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts
./cp4a-clusteradmin-setup.sh

#printf "%s\n" 2 2 1 2 1 BAWDB,BAWAUDB,UMSDB,APPDB,AAEDB,AEOS,BAWTOS,BAWDOS,BAWDOCS,OS1DB,ICNDB,GCDDB nfs-managed-storage nfs-managed-storage nfs-managed-storage | ./baw-prerequisites.sh -m property