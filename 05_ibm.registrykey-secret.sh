#!/bin/bash
oc project ${CP4BANAMESPACE}

oc delete secret ibm-registry
oc create secret docker-registry ibm-registry \
--docker-server=cp.icr.io \
--docker-username=cp \
--docker-password="${API_KEY_GENERATED}" \
--docker-email=${USER_EMAIL}
