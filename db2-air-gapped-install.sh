#!/bin/bash
######################################################################################################
### Install DB2 Operator air gapped                                                                ###
### From: https://www.ibm.com/docs/en/db2/11.5?topic=environment-installing-through-bastion-host   ###
######################################################################################################
export NAMESPACE=cp4ba

# Set the environment variables for the IBM Entitled Registry cp.icr.io
export SOURCE_REGISTRY_1=cp.icr.io
export SOURCE_REGISTRY_USER_1=cp
export SOURCE_REGISTRY_PASS_1="eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA"

# Set the environment variables for registry.redhat.io
export SOURCE_REGISTRY_2=registry.redhat.io
export SOURCE_REGISTRY_USER_2=gerard.mortel
export SOURCE_REGISTRY_PASS_2="vBYedvkq8x8djvpkNDrEA@WD"

# Set the environment variables for registry.access.redhat.com
export SOURCE_REGISTRY_3=registry.access.redhat.com
export SOURCE_REGISTRY_USER_3=gerard.mortel
export SOURCE_REGISTRY_PASS_3="vBYedvkq8x8djvpkNDrEA@WD"

# Create environment variables for the registry connection information.
export LOCAL_REGISTRY_HOST=swatartifactory011.fyre.ibm.com
export LOCAL_REGISTRY_PORT=8081
export LOCAL_REGISTRY=${LOCAL_REGISTRY_HOST}:${LOCAL_REGISTRY_PORT}
export LOCAL_REGISTRY_REPO=${LOCAL_REGISTRY}/regions
export LOCAL_REGISTRY_USER=admin
export LOCAL_REGISTRY_PASS=Passw0rd

export LOCAL_REGISTRY_HOST_2=cp4test1.fyre.ibm.com
export LOCAL_REGISTRY_PORT_2=8081
export LOCAL_REGISTRY_2=${LOCAL_REGISTRY_HOST_2}:${LOCAL_REGISTRY_PORT_2}
export LOCAL_REGISTRY_REPO_2=${LOCAL_REGISTRY_2}/regions
export LOCAL_REGISTRY_USER_2=admin
export LOCAL_REGISTRY_PASS_2=Passw0rd

mkdir -p ${HOME}/offlinedb2

# Save DB2 to offflinedb2 directory
export CASE_NAME=ibm-db2uoperator
export CASE_VERSION=4.0.4
export CASE_ARCHIVEDB2=${CASE_NAME}-${CASE_VERSION}.tgz
export OFFLINEDIRDB2=${HOME}/offlinedb2
export OFFLINECASE=${OFFLINEDIRDB2}/${CASE_NAME}
export CASEPATH="https://github.com/IBM/cloud-pak/raw/master/repo/case/${CASE_ARCHIVEDB2}"

# Download case files
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
oc patch image.config.openshift.io/cluster --type=merge -p "{\"spec\":{\"registrySources\":{\"insecureRegistries\":[\"${LOCAL_REGISTRY_2}:${TARGET_REGISTRY_PORT}\", \"${TARGET_REGISTRY_HOST}\"]}}}"

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
