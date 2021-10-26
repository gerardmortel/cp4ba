#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-entitlement-key
oc create secret docker-registry ibm-entitlement-key \
--docker-username=cp \
--docker-password="${API_KEY_GENERATED}" \
--docker-server=cp.icr.io
