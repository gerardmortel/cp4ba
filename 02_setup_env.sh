#!/bin/bash

echo "#### Set up the environment variables"
### Get entitlement key from https://myibm.ibm.com/products-services/containerlibrary
export API_KEY_GENERATED=""
export USER_EMAIL=""

# htpasswd user and password
export HTPASSWDUSERNAME=""
export HTPASSWDPASSWORD=""
export CP4BANAMESPACE=""
export CLUSTER_USER=""
export CLUSTER_PASS=""
export CLUSTER_URL=""
export STORAGECLASS="" # NFS Storage
export NFSSERVER=""
export NFSSERVEROPERATORPATH=""
export NFSSERVERLOGSPATH=""

# Log in to the OCP cluster as a cluster administrator.
oc login ${CLUSTER_URL} --username=${CLUSTER_USER} --password=${CLUSTER_PASS}