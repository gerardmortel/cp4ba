#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret aca-basedb
oc create secret generic aca-basedb \
--from-literal=BASE_DB_USER="${BASE_DB_USER}" \
--from-literal=BASE_DB_CONFIG="${BASE_DB_PWD}" \
--from-literal="${TENANT1DB_NAME}"_DB_CONFIG="${TENANT1_DB_PWD}" \
--from-literal="${TENANT2DB_NAME}"_DB_CONFIG="${TENANT2_DB_PWD}"
