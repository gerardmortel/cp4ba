#!/bin/bash

# Prerequisites for your linux server here:
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=environment-setting-up-bastion-compute-device

# Image mirroring instructions can be found here:
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=environment-setting-up-mirror-image-registry

# Info on static provisioning for the operator can be found on Step 3, Choice 2a here:
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/21.0.x?topic=environment-installing-operator-catalog

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
export SOURCE_REGISTRY_PASS_1="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2MzQyMTk2NjAsImp0aSI6Ijc4ZGYzNTgzYzVkMDRkMTliYTQ0ZTVkOGMzN2MyZTk3In0.eSIdd5j5IYEUA53v8QNDrwg25ngLckyAr0xvYZYlYsE"

# # Set the environment variables for registry.redhat.io
# export SOURCE_REGISTRY_2=registry.redhat.io
# export SOURCE_REGISTRY_USER_2=<username>
# export SOURCE_REGISTRY_PASS_2="xxx"
#
# # Set the environment variables for registry.access.redhat.com
# export SOURCE_REGISTRY_3=registry.access.redhat.com
# export SOURCE_REGISTRY_USER_3=<username>
# export SOURCE_REGISTRY_PASS_3="xxx"

# Create environment variables for the Artifactory registry connection information.
#export LOCAL_REGISTRY_HOST=swatartifactory011.fyre.ibm.com
export LOCAL_REGISTRY_HOST=cp4test1.fyre.ibm.com
export LOCAL_REGISTRY_PORT=8081
export LOCAL_REGISTRY=${LOCAL_REGISTRY_HOST}:${LOCAL_REGISTRY_PORT}
export LOCAL_REGISTRY_REPO=${LOCAL_REGISTRY}/fannie
export LOCAL_REGISTRY_USER=admin
export LOCAL_REGISTRY_PASS=Passw0rd

# 3. Download the Cloud Pak archive and image inventory and put them in the offline store.
cloudctl case save \
  --case https://github.com/IBM/cloud-pak/raw/master/repo/case/${CASE_ARCHIVE} \
  --outputdir ${OFFLINEDIR}

# 4. Go to the namespace where you want to install the Cloud Pak operator.
# oc project ${NAMESPACE}

# 5a. The following command stores and caches the registry credentials in a file on your file system in the $HOME/.airgap/secrets folder.
# This is for cp.icr.io
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${SOURCE_REGISTRY_1} --user ${SOURCE_REGISTRY_USER_1} --pass ${SOURCE_REGISTRY_PASS_1}"

# 5b. The following command stores and caches the registry credentials in a file on your file system in the $HOME/.airgap/secrets folder.
# This is for registry.redhat.io
# cloudctl case launch \
#   --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#   --inventory ${CASE_INVENTORY_SETUP} \
#   --action configure-creds-airgap \
#   --namespace ${NAMESPACE} \
#   --args "--registry ${SOURCE_REGISTRY_2} --user ${SOURCE_REGISTRY_USER_2} --pass ${SOURCE_REGISTRY_PASS_2}"
#
# # 5c. The following command stores and caches the registry credentials in a file on your file system in the $HOME/.airgap/secrets folder.
# # This is for registry.access.redhat.com
# cloudctl case launch \
#   --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#   --inventory ${CASE_INVENTORY_SETUP} \
#   --action configure-creds-airgap \
#   --namespace ${NAMESPACE} \
#   --args "--registry ${SOURCE_REGISTRY_3} --user ${SOURCE_REGISTRY_USER_3} --pass ${SOURCE_REGISTRY_PASS_3}"

# 5d. Do the same for the local registry, e.g. Artifactory
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS}"

# 6a. Optional: Test whether you can create the ImageContentSourcePolicy resource by doing a dry run
# cloudctl case launch \
#  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#  --inventory ${CASE_INVENTORY_SETUP} \
#  --action configure-cluster-airgap \
#  --namespace ${NAMESPACE} \
#  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR} --dryRun=client" \
#  --tolerance 1

# 6b. Configure a global image pull secret and the ImageContentSourcePolicy resource.
# The following command restarts all of the OCP cluster nodes. Depending on the applications that are running on the cluster, the nodes might take some time to be ready.
# cloudctl case launch \
#   --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#   --inventory ${CASE_INVENTORY_SETUP} \
#   --action configure-cluster-airgap \
#   --namespace ${NAMESPACE} \
#   --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR}" \
#   --tolerance 1

# 6c. After the imageContentsourcePolicy and global image pull secret are applied, you might see the node status
# as Ready, Scheduling, or Disabled. Wait until all the nodes show a Ready status.
# You can run the following command to verify the status before you move on to the next step.
# watch oc get nodes

# 6d. Verify that the ImageContentSourcePolicy resource is created
# oc get imageContentSourcePolicy

# 7. Optional: If you are using an insecure registry, you must add the image registry to the cluster
# insecureRegistries list.
# oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'

# 8a. Optional: Test whether you can pull the images by doing a dry run.
# cloudctl case launch \
#   --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#   --inventory ${CASE_INVENTORY_SETUP}   \
#   --action mirror-images \
#   --namespace ${NAMESPACE} \
#   --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir  ${OFFLINEDIR} --dryRun"

# 8b. Mirror the images to the image registry.
# The cloudctl case launch command is used to preserve manifest digests when an image is moved from one registry to another.
## Try to loop through and mirror images 30 times because sometimes it fails and just needs to restart
for i in $(seq 1 1);
do
echo "This is run number:${i}"
echo ""
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action mirror-images \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR}" \
  | tee ~/mirror-images${i}.log
done

# 9. Create the catalog source
# cloudctl case launch \
#   --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#   --inventory ${CASE_INVENTORY_SETUP} \
#   --action install-catalog \
#   --namespace ${NAMESPACE} \
#   --args "--registry ${LOCAL_REGISTRY_REPO} --inputDir ${OFFLINEDIR} --recursive" \
#   --tolerance 1

# 10. Install Cloud Pak operator
# cloudctl case launch \
#   --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#   --inventory ${CASE_INVENTORY_SETUP} \
#   --action install-operator \
#   --namespace ${NAMESPACE} \
#   --args "--registry ${LOCAL_REGISTRY_REPO} --inputDir ${OFFLINEDIR}" \
#   --tolerance 1
