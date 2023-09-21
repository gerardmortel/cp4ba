#!/bin/bash

####################################################################
#####                                                          #####
##### Setting up a host to mirror images to a private registry #####
#####                                                          #####
####################################################################
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/23.0.1?topic=deployment-setting-up-host-mirror-images-private-registry

echo "#### Install the oc OCP CLI tool. For more information, see OCP CLI tools."
curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.12.22/openshift-client-linux-4.12.22.tar.gz -o openshift-client-linux-4.12.22.tar.gz

echo "#### Untar oc tar"
tar -xzvf openshift-client-linux-4.12.22.tar.gz

echo "#### Move oc to $HOME/bin"
cd
mkdir $HOME/bin
mv oc $HOME/bin/
chmod +x $HOME/bin/oc
oc version

echo "#### Move kubectl to $HOME/bin"
mv kubectl $HOME/bin/
chmod +x $HOME/bin/kubectl
kubectl version

echo "#### Install Podman on an RHEL machine. For more information, see Podman installation instructions."
yum install -y git unzip podman

echo "#### Download and install the most recent version of the IBM Catalog Management Plug-in"
curl -L https://github.com/IBM/ibm-pak/releases/download/v1.10.0/oc-ibm_pak-linux-amd64.tar.gz -o oc-ibm_pak-linux-amd64.tar.gz

echo "#### Untar IBM Catalog Management Plug-in"
tar -zxvf oc-ibm_pak-linux-amd64.tar.gz

echo "#### Move oc-ibmpak to $HOME/bin"
mv oc-ibm_pak-linux-amd64 $HOME/bin/oc-ibm_pak
oc-ibm_pak --version

# Make sure that the following network ports are available on the host.
# *.icr.io:443 for the IBM Entitled Registry.
# *.quay.io:443 for foundational services. For more information, see Important firewall changes for customers pulling container images.
# github.com for CASE and tools.
# redhat.com for OpenShift upgrades.

####################################################################
#####                                                          #####
#####           Setting up a private registry                  #####
#####                                                          #####
####################################################################
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/23.0.1?topic=deployment-setting-up-private-registry

echo "#### Create a cp namespace to store the images from the IBM Entitled Registry cp.icr.io/cp."
oc new-project cp

echo "#### Create a ibmcom namespace to store all images from all IBM images that do not require credentials to pull."
oc new-project ibmcom

echo "#### Create a cpopen namespace to store all images from the icr.io/cpopen repository"
oc new-project cpopen

echo "#### reate a opencloudio namespace to store the images from quay.io/opencloudio."
oc new-project opencloudio

# Important: Verify that each namespace meets the following requirements:
# Supports auto-repository creation.
# Has credentials of a user who can write and create repositories. The host uses these credentials.
# Has credentials of a user who can read all repositories. The OpenShift Container Platform cluster uses these credentials.

####################################################################
#####                                                          #####
#####             Downloading the CASE files                   #####
#####                                                          #####
####################################################################
# https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation/23.0.1?topic=deployment-downloading-case-files

echo "#### View the current config of the IBM Catalog Management Plug-in (ibm-pak) v1.6 and later"
 

echo "#### Configure a repository that downloads the CASE files from the cp.icr.io registry"
oc ibm-pak config repo 'IBM Cloud-Pak OCI registry' -r oci:cp.icr.io/cpopen --enable
















export NAMESPACE=cp4ba
export CASE_ARCHIVE=ibm-cp-automation-3.1.6.tgz
export CASE_INVENTORY_SETUP=cp4aOperatorSetup
export OFFLINEDIR=${HOME}/offline_3.1.6

# Set the environment variables for the IBM Entitled Registry cp.icr.io
export SOURCE_REGISTRY_1=cp.icr.io
export SOURCE_REGISTRY_USER_1=cp
export SOURCE_REGISTRY_PASS_1="eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1NzQ0NDU1MTQsImp0aSI6IjY1NTRhMWE0MmI5ZjRmNmNhZDg5MzI5ZmQzNzY3NWI5In0.CQjQmwyYOnRBTgJLCPWW9pAq5L3Z_Bk4kB_yDjNhWwA"

# Set the environment variables for the destination image registry such as Artifactory or docker registry
# running in a container
#export LOCAL_REGISTRY_HOST=swatartifactory011.fyre.ibm.com
export LOCAL_REGISTRY_HOST=api.bts68.cp.fyre.ibm.com
export LOCAL_REGISTRY_PORT=5000
export LOCAL_REGISTRY=${LOCAL_REGISTRY_HOST}:${LOCAL_REGISTRY_PORT}
export LOCAL_REGISTRY_REPO=${LOCAL_REGISTRY}
export LOCAL_REGISTRY_USER=admin
export LOCAL_REGISTRY_PASS=Passw0rd

# Step 3. Download the Cloud Pak archive and image inventory and put them in the offline store.
cloudctl case save \
  --case https://github.com/IBM/cloud-pak/raw/master/repo/case/${CASE_ARCHIVE} \
  --outputdir ${OFFLINEDIR}

# Step 4. Log in to the OCP cluster a cluster administrator
oc login <cluster host:port> --username=<cluster admin user> --password=<cluster admin password>

# Step 5. Create the OpenShift namespace
oc create ${NAMESPACE}

# Go to the namespace
oc projet ${NAMESPACE}


# Step 6a. The following command stores and caches the registry credentials in a file on your file system in the $HOME/.airgap/secrets folder.
# This is for cp.icr.io
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${SOURCE_REGISTRY_1} --user ${SOURCE_REGISTRY_USER_1} --pass ${SOURCE_REGISTRY_PASS_1}"

# Step 6b. Do the same for the local registry, e.g. Artifactory
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-creds-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS}"

# Step 6c. Check source registry credentials
cat $HOME/.airgap/secrets/${SOURCE_REGISTRY_1}.json

# Step 6d. Check desintation registry credentials
cat $HOME/.airgap/secrets/${LOCAL_REGISTRY}.json

# Step 6e. Optional: Test whether you can create the ImageContentSourcePolicy resource by doing a dry run
# cloudctl case launch \
#  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
#  --inventory ${CASE_INVENTORY_SETUP} \
#  --action configure-cluster-airgap \
#  --namespace ${NAMESPACE} \
#  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR} --dryRun=client" \
#  --tolerance 1

# Step 6f. Configure a global image pull secret and the ImageContentSourcePolicy resource.
# The following command restarts all of the OCP cluster nodes. Depending on the applications that are running on the cluster, the nodes might take some time to be ready.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action configure-cluster-airgap \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR}" \
  --tolerance 1

# 6c. After the imageContentsourcePolicy and global image pull secret are applied, you might see the node status
# as Ready, Scheduling, or Disabled. Wait until all the nodes show a Ready status.
# You can run the following command to verify the status before you move on to the next step.
watch oc get nodes

# 6d. Verify that the ImageContentSourcePolicy resource is created
oc get imageContentSourcePolicy

# 7. Optional: If you are using an insecure registry, you must add the image registry to the cluster
# insecureRegistries list.
oc patch image.config.openshift.io/cluster --type=merge -p '{"spec":{"registrySources":{"insecureRegistries":["'${LOCAL_REGISTRY}'"]}}}'

# 8a. Optional: Test whether you can pull the images by doing a dry run.
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP}   \
  --action mirror-images \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir  ${OFFLINEDIR} --dryRun"

# 8b. Mirror the images to the image registry.
# The cloudctl case launch command is used to preserve manifest digests when an image is moved from one registry to another.
## Try to loop through and mirror images 30 times because sometimes it fails and just needs to restart
for i in $(seq 1 100);
do
  echo "This is run number:${i}"
  echo ""
  cloudctl case launch \
    --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
    --inventory ${CASE_INVENTORY_SETUP} \
    --action mirror-images \
    --namespace ${NAMESPACE} \
    --args "--registry ${LOCAL_REGISTRY_REPO} --user ${LOCAL_REGISTRY_USER} --pass ${LOCAL_REGISTRY_PASS} --inputDir ${OFFLINEDIR}" \
    | tee ./mirror-images-${i}.log
done

# 9. Create the configmap to hold the CA for the docker registry
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-registry-ca
  namespace: openshift-config
data:
  api.bts68.cp.fyre.ibm.com..5000: |
    -----BEGIN CERTIFICATE-----
    MIIGNzCCBB+gAwIBAgIUJREe2HULPJHd4MquLW1o4X32rpgwDQYJKoZIhvcNAQEL
    BQAwgZcxCzAJBgNVBAYTAlVTMQswCQYDVQQIDAJJTDEQMA4GA1UEBwwHQ2hpY2Fn
    bzEMMAoGA1UECgwDSUJNMRQwEgYDVQQLDAtFeHBlcnQgTGFiczEiMCAGA1UEAwwZ
    YXBpLmJ0czY4LmNwLmZ5cmUuaWJtLmNvbTEhMB8GCSqGSIb3DQEJARYSZ21vcnRl
    bEB1cy5pYm0uY29tMB4XDTIyMDIxMDIxMzQwN1oXDTIzMDIxMDIxMzQwN1owgZcx
    CzAJBgNVBAYTAlVTMQswCQYDVQQIDAJJTDEQMA4GA1UEBwwHQ2hpY2FnbzEMMAoG
    A1UECgwDSUJNMRQwEgYDVQQLDAtFeHBlcnQgTGFiczEiMCAGA1UEAwwZYXBpLmJ0
    czY4LmNwLmZ5cmUuaWJtLmNvbTEhMB8GCSqGSIb3DQEJARYSZ21vcnRlbEB1cy5p
    Ym0uY29tMIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAw0RwrYVGm6HT
    blGMjNsEzmoA01+jUi5RfODRNpwLLnwmLTgx0d45LNz8LHimckn7KDpi/nHXtCrG
    y6mpDEfTLhetquR2rneQS7xQTrTGcpDJUxtY5PHh5ZswxLGais3OmF4TmJ6uLWCy
    7waKuLSKackpviiHsaDJ5ZyVsQCbLs7LhQkzgFVBxEjr/BDD2gsBBeDlTOwfFhIZ
    9xlghHEclPr+vYobehY8/LFCCoInF/8xydb6ihAmhc8T+OJf9whqNpfOSoGAXK7c
    vQF+5eqelODSwwUeSSZYDau9AXcf+QFQRsjPrYKQ0BV0aJYm1Jw91vTvvbbxvFbO
    WBZDkP0tmNiNP+Xjiv9ovtWST5gkCrbuMdrwkKeyFj7byRZRr8oVXglsuEU2cOQ1
    BCGCR9N9JhKI/pBZZ3SrAVGO3r+zYwprdVP2M/d0WN7S3eBdNH4dY6fsboqasNIj
    zs8V2QGbmuj7fvEWS+EZJNFPDb6adq+Wfs6nzB7VbKOdn36nwYMpgr46eKDaL6ky
    EFkmNcGACyACoQAwJ5Qbc2cj98SU1RnWa+k+9MB5OUK8wADzD2cVBun/iqxcBSqX
    8MdUjtOaaE3/gGMv3nlg2jON55aReONHeo56tAKacHzK3i0sfbfQnHEB0T5jQ4Q9
    2q0Vrnc2AIoDd7qPCIEAX1ucoq6sAeUCAwEAAaN5MHcwHQYDVR0OBBYEFOoLyOJ3
    B6YrFc3AdZu+0+SxtYwmMB8GA1UdIwQYMBaAFOoLyOJ3B6YrFc3AdZu+0+SxtYwm
    MA8GA1UdEwEB/wQFMAMBAf8wJAYDVR0RBB0wG4IZYXBpLmJ0czY4LmNwLmZ5cmUu
    aWJtLmNvbTANBgkqhkiG9w0BAQsFAAOCAgEAN5ZrFrGUozE+VXH0crUMRBuuAPdz
    6aBIEiq1Qn/YtZ6KMwKPImSHO4UmAugllsf+KiEkhDY6hMqVG+DitU0hnQmXTle1
    L5nIbFEWRJo64J9EEq6noTcN2SBZFZw0JZ1JHxGmarjmtW/oFSI5fbDIA/oWPrHQ
    8M/9/ZuBs1TMRi6TmswIsZ3jkEZdWsdP2UqbagYYAtj5yokZgP57/XmvlL96pOUs
    /Uo15pkpVy0xVTcb7GB0IB41hhoGTM5/sGpxk4Hh/QNH9CYuAJQuaz37q46yTBNr
    FqkesMnFKmLGEOd+9NBUBfhEmolt5W4hGJA8s2OEO/T1GxK6pnDOyns7PeilEYmN
    m04d5aRB0uov7QyQ+G81RFXf7Ij2r8UYFkB+uRIUtWoV29LHA7ALa4+AdGm2EX3l
    +qlF3oblOW+ozPBXZEmuHNuXrx+H8ovddz951xWAyO6hnB0nEXokYrluWSVWCbun
    +cKvNgtxKRkrSknDWKqR3thRNpU0DDhLPliBcOQkHVMg+RNB02wL+wJZ0QOuYhD9
    oyaBAaDrcpaIDDD91azuDjm6NTovyhV9qVLKdQQFaHcLoG+lztdS92yZxb492oBi
    ciIhM+GtSk8VTNPGhRNxtMH0gUlMR7xmMgKwhexDU5epoLROuzZ3saskIVyYKjMB
    ES0sgeiHB4IdIl0=
    -----END CERTIFICATE-----

# 10. 
apiVersion: config.openshift.io/v1
kind: Image
metadata:
  annotations:
    include.release.openshift.io/ibm-cloud-managed: 'true'
    include.release.openshift.io/self-managed-high-availability: 'true'
    include.release.openshift.io/single-node-developer: 'true'
    release.openshift.io/create-only: 'true'
  name: cluster
spec:
  additionalTrustedCA:
    name: my-registry-ca
  allowedRegistriesForImport:
    - domainName: quay.io
      insecure: false
    - domainName: registry.redhat.io
      insecure: false
    - domainName: 'image-registry.openshift-image-registry.svc:5000'
      insecure: false
    - domainName: 'api.bts68.cp.fyre.ibm.com:5000'
      insecure: false
    - domainName: 'k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2'
      insecure: true
  registrySources:
    allowedRegistries:
      - quay.io
      - registry.redhat.io
      - 'image-registry.openshift-image-registry.svc:5000'
      - 'api.bts68.cp.fyre.ibm.com:5000'
      - 'k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2'

# 10. Create the catalog source
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-catalog \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --inputDir ${OFFLINEDIR} --recursive" \
  --tolerance 1

# 11. Install Cloud Pak operator
cloudctl case launch \
  --case ${OFFLINEDIR}/${CASE_ARCHIVE} \
  --inventory ${CASE_INVENTORY_SETUP} \
  --action install-operator \
  --namespace ${NAMESPACE} \
  --args "--registry ${LOCAL_REGISTRY_REPO} --inputDir ${OFFLINEDIR}" \
  --tolerance 1

# allowed registries from image content source policy
source: cp.icr.io/cp
source: docker.io/ibmcom
source: icr.io/cpopen
source: icr.io/db2u
source: quay.io/opencloudio

# Example yaml of the operator group
apiVersion: v1
items:
- apiVersion: operators.coreos.com/v1
  kind: OperatorGroup
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"operators.coreos.com/v1","kind":"OperatorGroup","metadata":{"annotations":{},"name":"common-service","namespace":"cp4ba"},"spec":{"targetNamespaces":["cp4ba"]}}
    creationTimestamp: "2022-02-11T05:56:17Z"
    generation: 1
    name: common-service
    namespace: cp4ba
    resourceVersion: "288722"
    uid: 982ae9fd-0ea1-44b6-b5de-f98a85fb015a
  spec:
    targetNamespaces:
    - cp4ba
  status:
    lastUpdated: "2022-02-11T05:56:17Z"
    namespaces:
    - cp4ba
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""


# 1 try of the cluster Image
apiVersion: config.openshift.io/v1
kind: Image
metadata:
  annotations:
    include.release.openshift.io/ibm-cloud-managed: 'true'
    include.release.openshift.io/self-managed-high-availability: 'true'
    include.release.openshift.io/single-node-developer: 'true'
    release.openshift.io/create-only: 'true'
  name: cluster
spec:
  additionalTrustedCA:
    name: my-registry-ca
  registrySources:
    allowedRegistries:
      - quay.io
      - registry.redhat.io
      - 'image-registry.openshift-image-registry.svc:5000'
      - 'api.bts68.cp.fyre.ibm.com:5000'
      - 'k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2'
      - cp.icr.io/cp
      - docker.io/ibmcom
      - icr.io/cpopen
      - icr.io/db2u

# 2nd try of the cluser Image
apiVersion: config.openshift.io/v1
kind: Image
metadata:
  annotations:
    include.release.openshift.io/ibm-cloud-managed: 'true'
    include.release.openshift.io/self-managed-high-availability: 'true'
    include.release.openshift.io/single-node-developer: 'true'
    release.openshift.io/create-only: 'true'
  name: cluster
spec:
  additionalTrustedCA:
    name: my-registry-ca
  allowedRegistriesForImport:
    - domainName: quay.io
      insecure: false
    - domainName: registry.redhat.io
      insecure: false
    - domainName: 'image-registry.openshift-image-registry.svc:5000'
      insecure: false
    - domainName: 'api.bts68.cp.fyre.ibm.com:5000'
      insecure: false
    - domainName: 'k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2'
      insecure: false
    - domainName: cp.icr.io/cp
      insecure: false
    - domainName: docker.io/ibmcom
      insecure: false
    - domainName: icr.io/cpopen
      insecure: false
    - domainName: icr.io/db2u
      insecure: false
  registrySources:
    allowedRegistries:
      - quay.io
      - registry.redhat.io
      - 'image-registry.openshift-image-registry.svc:5000'
      - 'api.bts68.cp.fyre.ibm.com:5000'
      - 'k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2'
      - cp.icr.io/cp
      - docker.io/ibmcom
      - icr.io/cpopen
      - icr.io/db2u


# another try at the Image CRD
spec:
  additionalTrustedCA:
    name: my-registry-ca
  allowedRegistriesForImport:
    - domainName: quay.io
      insecure: false
    - domainName: registry.redhat.io
      insecure: false
    - domainName: 'image-registry.openshift-image-registry.svc:5000'
      insecure: false
    - domainName: 'api.bts68.cp.fyre.ibm.com:5000'
      insecure: false
    - domainName: 'k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2'
      insecure: false
    - domainName: cp.icr.io/cp
      insecure: false
    - domainName: docker.io/ibmcom
      insecure: false
    - domainName: icr.io/cpopen
      insecure: false
    - domainName: icr.io/db2u
      insecure: false
  registrySources:
    allowedRegistries:
      - quay.io
      - registry.redhat.io
      - 'image-registry.openshift-image-registry.svc:5000'
      - 'api.bts68.cp.fyre.ibm.com:5000'
      - 'k8s.gcr.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2'
      - cp.icr.io/cp
      - docker.io/ibmcom
      - icr.io/cpopen
      - icr.io/db2u