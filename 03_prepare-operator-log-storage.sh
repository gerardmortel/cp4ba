#!/bin/bash
oc project ${CP4BANAMESPACE}

### For OCS Storage
# Download the CASE (Container Application Software for Enterprises) package
wget https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-cp-automation-3.1.3.tgz

# Extract the package
tar -xzvf ibm-cp-automation-3.1.3.tgz

# Extract the cert-k8s-21.0.1.tar file
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs
tar -xvf cert-k8s-21.0.2.tar

# Make a copy of operator-shared-pvc.yaml and replace the <StorageClassName>
cd cert-kubernetes/descriptors
cp -p operator-shared-pvc.yaml new-operator-shared-pvc.yaml
sed -ri "s|<StorageClassName>|$STORAGECLASS|g" new-operator-shared-pvc.yaml
sed -ri "s|<Fast_StorageClassName>|$STORAGECLASS|g" new-operator-shared-pvc.yaml

# oc apply -f new-operator-shared-pvc.yaml

#### For NFS Storage
# cp -p yaml/operator-shared-pv-NFS.yaml yaml/new-operator-shared-pv-NFS.yaml
# sed -ri "s|<NFSSERVEROPERATORPATH>|$NFSSERVEROPERATORPATH|g" yaml/new-operator-shared-pv-NFS.yaml
# sed -ri "s|<NFSSERVER>|$NFSSERVER|g" yaml/new-operator-shared-pv-NFS.yaml
# cp -p yaml/cp4a-shared-log-pv-NFS.yaml yaml/new-cp4a-shared-log-pv-NFS.yaml
# sed -ri "s|<NFSSERVERLOGSPATH>|$NFSSERVERLOGSPATH|g" yaml/new-cp4a-shared-log-pv-NFS.yaml
# sed -ri "s|<NFSSERVER>|$NFSSERVER|g" yaml/new-cp4a-shared-log-pv-NFS.yaml
#
# oc apply -f yaml/new-operator-shared-pv-NFS.yaml
# oc apply -f yaml/new-cp4a-shared-log-pv-NFS.yaml
#
# cp -p yaml/operator-shared-pvc-NFS.yaml yaml/new-operator-shared-pvc-NFS.yaml
# sed -ri "s|<CP4BANAMESPACE>|$CP4BANAMESPACE|g" yaml/new-operator-shared-pvc-NFS.yaml
# cp -p yaml/cp4a-shared-log-pvc-NFS.yaml yaml/new-cp4a-shared-log-pvc-NFS.yaml
# sed -ri "s|<CP4BANAMESPACE>|$CP4BANAMESPACE|g" yaml/new-cp4a-shared-log-pvc-NFS.yaml
#
# oc apply -f yaml/new-operator-shared-pvc-NFS.yaml
# oc apply -f yaml/new-cp4a-shared-log-pvc-NFS.yaml
