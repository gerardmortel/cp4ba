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

# Do the same for the local registry, e.g. Artifactory
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS}"

# For the 2nd Artifactory server, Do the same for the local registry, e.g. Artifactory
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_2} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASS_2}"

# Optional: Test whether you can create the ImageContentSourcePolicy resource by doing a dry run
cloudctl case launch \
 --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
 --inventory ${CASE_INVENTORY_SETUP} \
 --action configure-cluster-airgap \
 --namespace ${NAMESPACE} \
 --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR} --dryRun=client" \
 --tolerance 1

# For the 2nd Artifactory server, Optional: Test whether you can create the ImageContentSourcePolicy resource by doing a dry run
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-cluster-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASS_2} --inputDir ${OFFLINEDIR} --dryRun=client" \
  --tolerance 1

# Configure a global image pull secret and the ImageContentSourcePolicy resource.
# The following command restarts all of the OCP cluster nodes. Depending on the applications that are running on the cluster, the nodes might take some time to be ready.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-cluster-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR}" \
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

# For the 2nd Artifactory server, Optional: If you are using an insecure registry, you must add the image registry to the cluster
# insecureRegistries list.
oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY_2}'"]}}}'

# Optional: Test whether you can pull the images by doing a dry run.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP}   \
  --action mirror-images \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir  ${OFFLINEDIR} --dryRun"

# For the 2nd Artifactory server, Optional: Test whether you can pull the images by doing a dry run.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP}   \
  --action mirror-images \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir  ${OFFLINEDIR} --dryRun"

# Mirror the images to the image registry.
# The cloudctl case launch command is used to preserve manifest digests when an image is moved from one registry to another.
## Try to loop through and mirror images
for i in $(seq 1 30);
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

# For the 2nd Artifactory server, Mirror the images to the image registry.
# The cloudctl case launch command is used to preserve manifest digests when an image is moved from one registry to another.
## Try to loop through and mirror images
for i in $(seq 1 30);
do
echo "This is run number:${i}"
echo ""
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action mirror-images \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --user ${LOCAL_REGISTRY_USER_2} --pass ${LOCAL_REGISTRY_PASS_2} --inputDir ${OFFLINEDIR}" \
  | tee ~/mirror-images${i}.log
done

# Create the catalog source
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-catalog \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --inputDir ${OFFLINEDIR} --recursive" \
  --tolerance 1

# For the 2nd Artifactory server, Create the catalog source
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-catalog \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --inputDir ${OFFLINEDIR} --recursive" \
  --tolerance 1

# Install Cloud Pak operator
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-operator \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --inputDir ${OFFLINEDIR}" \
  --tolerance 1

# For the 2nd Artifactory server, Install Cloud Pak operator
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-operator \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO_2} --inputDir ${OFFLINEDIR}" \
  --tolerance 1

#######################################
###    Manually skopeo copy MQ      ###
#######################################
cp.icr.io,cp/ibm-mqadvanced-server,9.1.5.0-r2-amd64,sha256:8dee84b6f41a5da4b0a3e10e4e7e29832f571c30fc4d85bbbe5ef5f554a7d7af,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.0.0-r1-amd64,sha256:10353222ecf9c0bd09034820d5c14a8ce03b9ffc18c9e148b99f7171da9be825,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.0.0-r2,sha256:2f3697dd13dfe9d6ff2286a304864758a118692382502cff77722f35f8d75207,LIST,"","","",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.0.0-r2-amd64,sha256:a56098a7a983381b3456c4b275a2846fd00ca714888a181ad3597fcd0a4a3df2,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.0.0-r2-s390x,sha256:e0c873aa2c64a04218ce25eb5ef7d44e50b8117a8ecd7a49279c0d32b9f292a7,IMAGE,linux,s390x,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.1.0-r1,sha256:4b8c399f887eea1003505f7a2ed9a299f1de71e55e634f9ac2f0380626ef015b,LIST,"","","",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.1.0-r1-amd64,sha256:3588b00e417418779eb14bd6bc1d46afd4a19e3e989779592c06e5733ef60f36,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.1.0-r1-s390x,sha256:f1a24eab21b1b53d7f8d874daa55e2c51a9ba451e494707f53e8cf64304903f6,IMAGE,linux,s390x,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.2.0-r1,sha256:97a9f4581957b8e5c72473b2d8061803d0b6883fa16f69525149d9968d7b947b,LIST,"","","",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.2.0-r1-amd64,sha256:b964892796a97c2cadbd07bdeb89a2064438fd469a382f5eabb71138f470a2d2,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.2.0-r1-s390x,sha256:430b706c6e3aaf82f003284786db6daaf860c02101aa0d16be5a70af4d1bbc66,IMAGE,linux,s390x,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.0.0-r3,sha256:3248bb3ece67b71245e78b00c93b773703b08420d1276178ac7787791d8c88cc,LIST,"","","",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.0.0-r3-amd64,sha256:dfa5792fe12348252c546bf2caa0922fca6e6a88497bd5f28f7c8f7f8ed26800,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.0.0-r3-s390x,sha256:d02426e8a78f0c5bc5d42a506c7a79026d1cdb48aed15e015ad17bfcf2e3a5b4,IMAGE,linux,s390x,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.1.0-r2,sha256:aa34e132da483f10d2e06617b5d46d916d461ad11f5b0aac579203c662baad68,LIST,"","","",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.1.0-r2-amd64,sha256:a3759570090f4252dfd078f50c561819e1946ce7e2c8928eafd714e16c71cd2a,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.1.0-r2-s390x,sha256:b77680bacfb36a1bd6bd86e86c268af841ac544eb9f794a5ff677131f049b77d,IMAGE,linux,s390x,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.3.0-r1,sha256:b611e0417ca9b7d8036074221783194d9f5128951de6687ee1e91069fcaadc76,LIST,"","","",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.3.0-r1-amd64,sha256:19c63f807c58d2670f23ed9620cf89bc03df8ae5d732d569d0a298430f3ac8ad,IMAGE,linux,amd64,"",0,CASE,"",""
cp.icr.io,cp/ibm-mqadvanced-server,9.2.3.0-r1-s390x,sha256:eee938bdf5b053bf93af14c9078fe44d172d307cf3029e93a103f08b07fc31a7,IMAGE,linux,s390x,"",0,CASE,"",""


skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:8dee84b6f41a5da4b0a3e10e4e7e29832f571c30fc4d85bbbe5ef5f554a7d7af docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.1.5.0-r2-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:10353222ecf9c0bd09034820d5c14a8ce03b9ffc18c9e148b99f7171da9be825 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.0.0-r1-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:2f3697dd13dfe9d6ff2286a304864758a118692382502cff77722f35f8d75207 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.0.0-r2 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:a56098a7a983381b3456c4b275a2846fd00ca714888a181ad3597fcd0a4a3df2 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.0.0-r2-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:e0c873aa2c64a04218ce25eb5ef7d44e50b8117a8ecd7a49279c0d32b9f292a7 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.0.0-r2-s390x --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:4b8c399f887eea1003505f7a2ed9a299f1de71e55e634f9ac2f0380626ef015b docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.1.0-r1 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:3588b00e417418779eb14bd6bc1d46afd4a19e3e989779592c06e5733ef60f36 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.1.0-r1-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:f1a24eab21b1b53d7f8d874daa55e2c51a9ba451e494707f53e8cf64304903f6 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.1.0-r1-s390x --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:97a9f4581957b8e5c72473b2d8061803d0b6883fa16f69525149d9968d7b947b docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.2.0-r1 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:b964892796a97c2cadbd07bdeb89a2064438fd469a382f5eabb71138f470a2d2 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.2.0-r1-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:430b706c6e3aaf82f003284786db6daaf860c02101aa0d16be5a70af4d1bbc66 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.2.0-r1-s390x --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:3248bb3ece67b71245e78b00c93b773703b08420d1276178ac7787791d8c88cc docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.0.0-r3 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:dfa5792fe12348252c546bf2caa0922fca6e6a88497bd5f28f7c8f7f8ed26800 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.0.0-r3-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:d02426e8a78f0c5bc5d42a506c7a79026d1cdb48aed15e015ad17bfcf2e3a5b4 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.0.0-r3-s390x --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:aa34e132da483f10d2e06617b5d46d916d461ad11f5b0aac579203c662baad68 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.1.0-r2 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:a3759570090f4252dfd078f50c561819e1946ce7e2c8928eafd714e16c71cd2a docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.1.0-r2-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:b77680bacfb36a1bd6bd86e86c268af841ac544eb9f794a5ff677131f049b77d docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.1.0-r2-s390x --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:b611e0417ca9b7d8036074221783194d9f5128951de6687ee1e91069fcaadc76 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.3.0-r1 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:19c63f807c58d2670f23ed9620cf89bc03df8ae5d732d569d0a298430f3ac8ad docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:,9.2.3.0-r1-amd64 --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
skopeo copy docker://cp.icr.io/cp/ibm-mqadvanced-server@sha256:eee938bdf5b053bf93af14c9078fe44d172d307cf3029e93a103f08b07fc31a7 docker://cp4test1.fyre.ibm.com:8082/regions/cp/ibm-mqadvanced-server:9.2.3.0-r1-s390x --dest-tls-verify=false --src-creds cp:eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA --dest-creds admin:Passw0rd
