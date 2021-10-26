#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret playback-server-admin-secret
oc create secret generic playback-server-admin-secret \
--from-literal=AE_DATABASE_PWD="${AEDBPASSWORD}" \
--from-literal=AE_DATABASE_USER="${AEDBUSERNAME}"
