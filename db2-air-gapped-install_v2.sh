#!/bin/bash
######################################################################################################
### Install DB2 Operator air gapped                                                                ###
### From: https://www.ibm.com/docs/en/db2/11.5?topic=environment-installing-through-bastion-host   ###
######################################################################################################
export NAMESPACE=cp4ba

# Set the environment variables for the IBM Entitled Registry cp.icr.io
export SOURCE_REGISTRY_1=cp.icr.io
export SOURCE_REGISTRY_USER_1=cp
export SOURCE_REGISTRY_PASS_1="xxx"

# Set the environment variables for Artifactory
export LOCAL_REGISTRY_HOST_2=cp4test1.fyre.ibm.com
export LOCAL_REGISTRY_PORT_2=8081
export LOCAL_REGISTRY_2=${LOCAL_REGISTRY_HOST_2}:${LOCAL_REGISTRY_PORT_2}
export LOCAL_REGISTRY_REPO_2=${LOCAL_REGISTRY_2}/regions
export LOCAL_REGISTRY_USER_2=admin
export LOCAL_REGISTRY_PASS_2=Passw0rd

# Set DB2 variables
export CASE_NAME=ibm-db2uoperator
export CASE_VERSION=1.0.11
export CASE_ARCHIVEDB2=${CASE_NAME}-${CASE_VERSION}.tgz
export OFFLINEDIRDB2=${HOME}/offlinedb2
export OFFLINECASE=${OFFLINEDIRDB2}/${CASE_NAME}
export CASEPATH="https://github.com/IBM/cloud-pak/raw/master/repo/case/${CASE_ARCHIVEDB2}"

# Create the DB2 offline directory
mkdir -p ${HOME}/offlinedb2

# Save DB2 case files to offflinedb2 directory
cloudctl case save --case ${CASEPATH} \
  --outputdir ${OFFLINEDIRDB2}

# Extract case files
cd ${OFFLINEDIRDB2}
tar -xvzf ${CASE_ARCHIVEDB2}

# Create registry secret for source image registry (if the registry is public which doesn't require credentials, this step can be skipped)
cloudctl case launch \
  --case ${OFFLINEDIRDB2}/${CASE_ARCHIVEDB2} \
  --namespace ${NAMESPACE}               \
  --inventory db2uOperatorSetup   \
  --action configure-creds-airgap \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASSWORD_2}"

# Upload images to Artifactory
cloudctl case launch               \
  --case ${OFFLINECASE}            \
  --namespace ${NAMESPACE}          \
  --inventory db2uOperatorSetup    \
  --action mirror-images           \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --inputDir ${OFFLINEDIRDB2}"

# Apply an image source content policy. Doing so causes each worker node to restart
cloudctl case launch                \
  --case ${OFFLINECASE}             \
  --namespace ${NAMESPACE}          \
  --inventory db2uOperatorSetup     \
  --action configure-cluster-airgap \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --inputDir ${OFFLINEDIRDB2}"

# Add the target registry to the cluster insecureRegistries list if the target
# registry isn't secured by a certificate. Run the following command to restart
# all nodes, one at a time:
#oc patch image.config.openshift.io/cluster --type=merge -p "{\"spec\":{\"registrySources\":{\"insecureRegistries\":[\"${LOCAL_REGISTRY_2}:${TARGET_REGISTRY_PORT}\", \"${TARGET_REGISTRY_HOST}\"]}}}" # Not needed for client environment

# Install the catalog source
cloudctl case launch                 \
    --case ${OFFLINECASE}            \
    --namespace ${NAMESPACE}         \
    --inventory db2uOperatorSetup    \
    --action installCatalog          \
    --tolerance 1

# Install the operator
cloudctl case launch                 \
    --case ${OFFLINECASE}            \
    --namespace ${NAMESPACE}         \
    --inventory db2uOperatorSetup    \
    --action installOperatorNative   \
    --tolerance 1
