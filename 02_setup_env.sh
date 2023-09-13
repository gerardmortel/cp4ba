#!/bin/bash

echo "#### Set up the environment variables"
### Get entitlement key from https://myibm.ibm.com/products-services/containerlibrary
export API_KEY_GENERATED=""
export USER_EMAIL=""

export HTPASSWDUSERNAME=""
export HTPASSWDPASSWORD=""
export CP4BANAMESPACE=""
export CLUSTER_USER=""
export CLUSTER_PASS=""
export CLUSTER_URL=""
export STORAGECLASS=""
export NFSSERVER=""
export NFSSERVEROPERATORPATH=""
export NFSSERVERLOGSPATH=""
export DB_USERNAME=""
export DB_PASSWORD=""
export DB_SERVER=""
export DB_PORT=""
export DB_SSL=""
export LDAP_SERVER=""
export LDAP_PORT=""
export LDAP_BASE_DN=""
export LDAP_BIND_DN=""
export LDAP_BIND_DN_PASSWORD=""
export LDAP_SSL_ENABLED=""

# Log in to the OCP cluster as a cluster administrator.
oc login ${CLUSTER_URL} --username=${CLUSTER_USER} --password=${CLUSTER_PASS}