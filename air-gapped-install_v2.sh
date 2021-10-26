#!/bin/bash

# Prerequisites:
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=environment-setting-up-bastion-compute-device

# From https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=environment-installing-operator-catalog

# 1. On the bastion host, create a directory that serves as the offline store.
# The following example directory is used in the subsequent steps.
mkdir $HOME/offline

# 2. Create environment variables for the installer and image inventory.
# On the bastion host, create the following environment variables with the installer image name and the
# image inventory to be able to connect to the internet and download the corresponding CASE file.
export NAMESPACE=cp4ba
export CASE_ARCHIVE=ibm-cp-automation-3.1.3.tgz
export CASE_INVENTORY_SETUP=cp4aOperatorSetup
export OFFLINEDIR=${HOME}/offline

# Set the environment variables for the IBM Entitled Registry cp.icr.io
export SOURCE_REGISTRY_1=cp.icr.io
export SOURCE_REGISTRY_USER_1=cp
export SOURCE_REGISTRY_PASS_1="xx"

# Set the environment variables for registry.redhat.io
export SOURCE_REGISTRY_2=registry.redhat.io
export SOURCE_REGISTRY_USER_2=gerard.mortel
export SOURCE_REGISTRY_PASS_2="xx"

# Set the environment variables for registry.access.redhat.com
export SOURCE_REGISTRY_3=registry.access.redhat.com
export SOURCE_REGISTRY_USER_3=gerard.mortel
export SOURCE_REGISTRY_PASS_3="xx"

# Create environment variables for the registry connection information.
export LOCAL_REGISTRY_HOST_2=cp4test1.fyre.ibm.com
export LOCAL_REGISTRY_PORT_2=8081
export LOCAL_REGISTRY_2=${LOCAL_REGISTRY_HOST_2}:${LOCAL_REGISTRY_PORT_2}
#export LOCAL_REGISTRY_REPO_2=${LOCAL_REGISTRY_2}/artifactory/regions
export LOCAL_REGISTRY_REPO_2=${LOCAL_REGISTRY_2}/regions
export LOCAL_REGISTRY_USER_2=admin
export LOCAL_REGISTRY_PASS_2=Passw0rd

# 3. Download the Cloud Pak archive and image inventory and put them in the offline store.
cloudctl case save \
  --case https://github.com/IBM/cloud-pak/raw/master/repo/case/${CASE_ARCHIVE} \
  --outputdir ${OFFLINEDIR}

# Go to the namespace where you want to install the Cloud Pak operator.
oc project ${NAMESPACE}

# The following command stores and caches the registry credentials in a file on your file system in the $HOME/.airgap/secrets folder.
# This is for cp.icr.io
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${SOURCE_REGISTRY_1} --user ${SOURCE_REGISTRY_USER_1} --pass ${SOURCE_REGISTRY_PASS_1}"

# The following command stores and caches the registry credentials in a file on your file system in the $HOME/.airgap/secrets folder.
# This is for registry.redhat.io
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${SOURCE_REGISTRY_2} --user ${SOURCE_REGISTRY_USER_2} --pass ${SOURCE_REGISTRY_PASS_2}"

# The following command stores and caches the registry credentials in a file on your file system in the $HOME/.airgap/secrets folder.
# This is for registry.access.redhat.com
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${SOURCE_REGISTRY_3} --user ${SOURCE_REGISTRY_USER_3} --pass ${SOURCE_REGISTRY_PASS_3}"

# For the 2nd Artifactory server, Do the same for the local registry, e.g. Artifactory
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_2} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASS_2}"

# For the 2nd Artifactory server, Optional: Test whether you can create the ImageContentSourcePolicy resource by doing a dry run
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-cluster-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASS_2} --inputDir ${OFFLINEDIR} --dryRun=client" \
  --tolerance 1

# For the 2nd Artifactory server, Configure a global image pull secret and the ImageContentSourcePolicy resource.
# The following command restarts all of the OCP cluster nodes. Depending on the applications that are running on the cluster, the nodes might take some time to be ready.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-cluster-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASS_2} --inputDir ${OFFLINEDIR}" \
  --tolerance 1

# After the imageContentsourcePolicy and global image pull secret are applied, you might see the node status
# as Ready, Scheduling, or Disabled. Wait until all the nodes show a Ready status.
# You can run the following command to verify the status before you move on to the next step.
oc get nodes -w

# Verify that the ImageContentSourcePolicy resource is created
oc get imageContentSourcePolicy

# Optional: If you are using an insecure registry, you must add the image registry to the cluster
# insecureRegistries list.
oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'

# For the 2nd Artifactory server, Optional: Test whether you can pull the images by doing a dry run.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP}   \
  --action mirror-images \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir  ${OFFLINEDIR} --dryRun=client"

# For the 2nd Artifactory server, Mirror the images to the image registry.
# The cloudctl case launch command is used to preserve manifest digests when an image is moved from one registry to another.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action mirror-images \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASS_2} --inputDir ${OFFLINEDIR}" \
  | tee ~/mirror-images2.log

# For the 2nd Artifactory server, Create the catalog source
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-catalog \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --inputDir ${OFFLINEDIR} --recursive" \
  --tolerance 1

# For the 2nd Artifactory server, Install Cloud Pak operator
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-operator \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --inputDir ${OFFLINEDIR}" \
  --tolerance 1
