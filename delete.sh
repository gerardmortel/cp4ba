#!/bin/bash

# Operator installation or upgrade fails with DeadlineExceeded error
# https://www.ibm.com/docs/en/cloud-paks/foundational-services/4.2?topic=issues-operator-installation-upgrade-fails-deadlineexceeded-error
oc get jobs -n openshift-marketplace | grep -v NAME | awk '{print $1}' > jobs.txt
cat jobs.txt | awk '{print $1}' | xargs oc delete job -n openshift-marketplace
cat jobs.txt | awk '{print $1}' | xargs oc delete cm -n openshift-marketplace
oc get installplan -n ibm-cert-manager | grep -v NAME | awk '{print $1}' | xargs oc delete installplan -n ibm-cert-manager
oc get subscription -n ibm-cert-manager | grep -v NAME | awk '{print $1}' | xargs oc delete subscription -n ibm-cert-manager
oc get csv -n ibm-cert-manager | grep -v NAME | awk '{print $1}' | xargs oc delete csv

# From https://www.ibm.com/docs/en/cloud-paks/1.0?topic=online-uninstalling-foundational-services
oc -n kube-system delete secret icp-metering-api-secret
oc -n kube-public delete configmap ibmcloud-cluster-info
oc -n kube-public delete secret ibmcloud-cluster-ca-cert
oc delete ValidatingWebhookConfiguration cert-manager-webhook ibm-cs-ns-mapping-webhook-configuration --ignore-not-found
oc delete MutatingWebhookConfiguration cert-manager-webhook ibm-common-service-webhook-configuration ibm-operandrequest-webhook-configuration namespace-admission-config --ignore-not-found
oc delete namespace services
oc delete nss --all

# cp4ba
oc get subscription -n cp4ba
oc delete subscription --all -n cp4ba

oc get csv -n cp4ba
oc delete csv --all -n cp4ba

oc get deployment -n cp4ba
oc delete deployment --all -n cp4ba

oc get svc -n cp4ba
oc delete svc --all -n cp4ba

oc get configmap -n cp4ba
oc delete configmap --all -n cp4ba

oc get statefulset -n cp4ba
oc delete statefulset --all -n cp4ba

oc get po -n cp4ba
oc delete po --all -n cp4ba

oc get pvc -n cp4ba
oc delete pvc --all -n cp4ba

oc get route -n cp4ba
oc delete route --all -n cp4ba

oc get job -n cp4ba
oc delete job --all -n cp4ba

oc get operandrequest  -n cp4ba
oc delete operandrequest --all -n cp4ba

oc get namespacescope -n cp4ba
oc delete namespacescope --all -n cp4ba

oc get secrets -n cp4ba
oc delete secrets --all -n cp4ba

# ibm-common-services
oc get subscription -n ibm-common-services
oc delete subscription --all -n ibm-common-services

oc get csv -n ibm-common-services
oc delete csv --all -n ibm-common-services

oc get deployment -n ibm-common-services
oc delete deployment --all -n ibm-common-services

oc get services -n ibm-common-services
oc delete services --all -n ibm-common-services

oc get configmap -n ibm-common-services
oc delete configmap --all -n ibm-common-services

oc get statefulset -n ibm-common-services
oc delete statefulset --all -n ibm-common-services

oc get po -n ibm-common-services
oc delete po --all -n ibm-common-services

oc get pvc -n ibm-common-services
oc delete pvc --all -n ibm-common-services

oc get route -n ibm-common-services
oc delete route --all -n ibm-common-services

oc get job -n ibm-common-services
oc delete job --all -n ibm-common-services

oc get operandrequest  -n ibm-common-services
oc delete operandrequest --all -n ibm-common-services

oc get namespacescope -n ibm-common-services
oc delete namespacescope --all -n ibm-common-services

oc get secrets -n ibm-common-services
oc delete secrets --all -n ibm-common-services





oc patch -n cp4ba rolebinding/admin -p '{"metadata": {"finalizers":null}}'
oc delete rolebinding admin -n ibm-common-services --ignore-not-found

oc delete catalogsource iaf-operators -n openshift-marketplace
oc delete catalogsource iaf-core-operators -n openshift-marketplace
oc delete catalogsource iaf-demo-cartridge -n openshift-marketplace
oc delete catalogsource opencloud-operators -n openshift-marketplace
oc delete catalogsource ibm-operator-catalog -n openshift-marketplace

oc get og iaf-group -n cp4ba
oc delete og iaf-group -n cp4ba

oc get crd -o name | grep "automation.ibm.com" || echo "crd no-automation-ibm"
oc delete --ignore-not-found $(oc get crd -o name | grep "automation.ibm.com" || echo "crd no-automation-ibm")
oc get crd -o name | grep "ai.ibm.com" || echo "crd no-ai-ibm"
oc delete --ignore-not-found $(oc get crd -o name | grep "ai.ibm.com" || echo "crd no-ai-ibm")

oc proxy

# Remove kubernetes/all finalizer
oc get namespace cp4ba -o json > tmp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/cp4ba/finalize

# Remove kubernetes/all finalizer
oc get namespace ibm-common-services -o json > tmp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/ibm-common-services/finalize

# Remove kubernetes/all finalizer
oc get namespace openshift-storage -o json > tmp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/openshift-storage/finalize

# Remove kubernetes/all finalizer
oc get namespace openshift-local-storage -o json > tmp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/openshift-local-storage/finalize

#### Uninstall OpenShift Container Storage
# 1. Get volume snapshots
$ oc get volumesnapshot -A

# 2. Delete any found volume snapshots
oc delete volumesnapshot <VOLUME-SNAPSHOT-NAME> -n <NAMESPACE>

# 3. Removing monitoring stack from OpenShift Container Storage
oc get pod,pvc -n openshift-monitoring

# 4.  If some use ocs-storagecluster-XX, edit the monitoring config map by removing any config sections that reference the OpenShift Container Storage storage classes as shown in the following example and save it.  https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.7/html/deploying_openshift_container_storage_using_bare_metal_infrastructure/assembly_uninstalling-openshift-container-storage_rhocs#removing-monitoring-stack-from-openshift-container-storage_rhocs
oc edit configmap cluster-monitoring-config -n openshift-monitoring

# 5. Delete relevant PVCs. Make sure you delete all the PVCs that are consuming the storage classes.
oc delete -n openshift-monitoring pvc <pvc-name> --wait=true --timeout=5m

# 6. Edit the configs.imageregistry.operator.openshift.io object and remove the content in the storage section.
# Before
storage:
  pvc:
    claim: registry-cephfs-rwx-pvc
# After
storage:
  emptyDir: {}

oc edit configs.imageregistry.operator.openshift.io

# 7. Identity OCS PVCs and OBCs
#!/bin/bash

RBD_PROVISIONER="openshift-storage.rbd.csi.ceph.com"
CEPHFS_PROVISIONER="openshift-storage.cephfs.csi.ceph.com"
NOOBAA_PROVISIONER="openshift-storage.noobaa.io/obc"
RGW_PROVISIONER="openshift-storage.ceph.rook.io/bucket"
NOOBAA_DB_PVC="noobaa-db"
NOOBAA_BACKINGSTORE_PVC="noobaa-default-backing-store-noobaa-pvc"

# Find all the OCS StorageClasses
OCS_STORAGECLASSES=$(oc get storageclasses | grep -e "$RBD_PROVISIONER" -e "$CEPHFS_PROVISIONER" -e "$NOOBAA_PROVISIONER" -e "$RGW_PROVISIONER" | awk '{print $1}')

# List PVCs in each of the StorageClasses
for SC in $OCS_STORAGECLASSES
do
        echo "======================================================================"
        echo "$SC StorageClass PVCs and OBCs"
        echo "======================================================================"
        oc get pvc  --all-namespaces --no-headers 2>/dev/null | grep $SC | grep -v -e "$NOOBAA_DB_PVC" -e "$NOOBAA_BACKINGSTORE_PVC"
        oc get obc  --all-namespaces --no-headers 2>/dev/null | grep $SC
        echo
done

# 8. Delete the found OBCs
oc delete obc <obc name> -n <project name>

# 9.  Delete the found PVCs
oc delete pvc <pvc name> -n <project-name>

# 10.  Delete the storage cluster object
oc delete -n openshift-storage storagecluster --all --wait=true

# 11. Check for cleanup pods if the uninstall.ocs.openshift.io/cleanup-policy was set to delete(default) and ensure that their status is Completed.
oc get pods -n openshift-storage | grep -i cleanup

# 12. Troubleshooting and deleting remaining resources during uninstall https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.6/html-single/troubleshooting_openshift_container_storage/index#troubleshooting-and-deleting-remaining-resources-during-uninstall_rhocs
oc get project openshift-storage

# 13. If stuck in terminating state get list of resources
oc get project openshift-storage -o yaml

# 14. Get all the resources, e.g. see below
oc get cephblockpools.ceph.rook.io -n openshift-storage
oc get cephclusters.ceph.rook.io -n openshift-storage
oc get cephfilesystems.ceph.rook.io -n openshift-storage
oc get cephobjectstores.ceph.rook.io -n openshift-storage
oc get cephobjectstoreusers.ceph.rook.io -n openshift-storage
oc get storageclusters.ocs.openshift.io -n openshift-storage

# 15. Patch all the resources, e.g. see below
oc patch -n <object>/<object name> \
--type=merge -p '{"metadata": {"finalizers":null}}'

oc patch -n openshift-storage cephobjectstoreusers.ceph.rook.io/ocs-storagecluster-cephobjectstoreuser \
--type=merge -p '{"metadata": {"finalizers":null}}'

oc patch -n openshift-storage cephobjectstores.ceph.rook.io/ocs-storagecluster-cephobjectstore \
--type=merge -p '{"metadata": {"finalizers":null}}'

oc patch -n openshift-storage cephfilesystems.ceph.rook.io/ocs-storagecluster-cephfilesystem \
--type=merge -p '{"metadata": {"finalizers":null}}'

oc patch -n openshift-storage cephclusters.ceph.rook.io/ocs-storagecluster-cephcluster \
--type=merge -p '{"metadata": {"finalizers":null}}'

oc patch -n openshift-storage cephblockpools.ceph.rook.io/ocs-storagecluster-cephblockpool \
--type=merge -p '{"metadata": {"finalizers":null}}'

oc patch -n openshift-storage storageclusters.ocs.openshift.io/ocs-storagecluster \
--type=merge -p '{"metadata": {"finalizers":null}}'

# 16. Delete local storage operator configurations if you have deployed OpenShift Container Storage using local storage devices. See Removing local storage operator configurations.

# 17. Unlabel the storage nodes.
oc label nodes  --all cluster.ocs.openshift.io/openshift-storage-
oc label nodes  --all topology.rook.io/rack-

# 18. Remove the OpenShift Container Storage taint if the nodes were tainted.
oc adm taint nodes --all node.ocs.openshift.io/storage-

# 19. Confirm all PVs provisioned using OpenShift Container Storage are deleted. If there is any PV left in the Released state, delete it.
oc get pv
oc delete pv <pv name>

# 20. Delete the Multicloud Object Gateway storageclass.
oc delete storageclass openshift-storage.noobaa.io --wait=true --timeout=5m
oc delete sc --all

# 21. Remove CustomResourceDefinitions.
oc delete crd backingstores.noobaa.io bucketclasses.noobaa.io cephblockpools.ceph.rook.io cephclusters.ceph.rook.io cephfilesystems.ceph.rook.io cephnfses.ceph.rook.io cephobjectstores.ceph.rook.io cephobjectstoreusers.ceph.rook.io noobaas.noobaa.io ocsinitializations.ocs.openshift.io storageclusters.ocs.openshift.io cephclients.ceph.rook.io cephobjectrealms.ceph.rook.io cephobjectzonegroups.ceph.rook.io cephobjectzones.ceph.rook.io cephrbdmirrors.ceph.rook.io --wait=true --timeout=5m
